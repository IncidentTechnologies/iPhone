//
//  keysPlayAppDelegate.m
//  keysPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "TestFlight.h"

#import "keysPlayAppDelegate.h"
#import "keysPlayApplication.h"

#import <CoreFoundation/CoreFoundation.h>

#import <TargetConditionals.h>

#import "TitleNavigationController.h"
#import "Mixpanel.h"

#import "CloudController.h"
#import "FileController.h"
#import <gTarAppCore/UserController.h>

#define MIXPANEL_TOKEN @"da24d59140097cb9672b348ef05c6fab"

//Facebook *g_facebook;

CloudController * g_cloudController;
//AudioController * g_audioController;
FileController * g_fileController;
KeysController * g_keysController;
UserController * g_userController;
//TelemetryController * g_telemetryController;

@implementation keysPlayAppDelegate

@synthesize m_window;
@synthesize m_navigationController;
@synthesize m_playApplication;

#pragma mark -
#pragma mark Application lifecycle

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        // Init the cloud controller
        g_cloudController = [[CloudController alloc] initWithServer:kServerAddress];
        
        // Restore the file controller so we can get all the cached content
        g_fileController = [[FileController alloc] initWithCloudController:g_cloudController];
        
        // Create the user controller to manage users
        g_userController = [[UserController alloc] initWithCloudController:g_cloudController];
#if 0
        // Create the telemetry controller to upload log data
        NSString * uuidString = [self generateUUID];
        
        g_telemetryController = [[TelemetryController alloc] initWithCloudController:g_cloudController];
        g_telemetryController.m_compileDate = @__DATE__;
        g_telemetryController.m_appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        g_telemetryController.m_appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        g_telemetryController.m_deviceId = uuidString;
        g_telemetryController.m_username = g_userController.m_loggedInUsername;
#else
        Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
#endif
        
        // Connect to the keys device
        g_keysController = [[KeysController alloc] init];
        g_keysController.responseThread = KeysControllerThreadMain;
        
        // By default it just outputs 'LevelError'
        g_keysController.logLevel = KeysControllerLogLevelAll;
        [g_keysController addObserver:self];
        
#if TARGET_IPHONE_SIMULATOR// | Debug_BUILD
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:g_keysController selector:@selector(debugSpoofConnected) userInfo:nil repeats:NO];
        //[NSTimer scheduledTimerWithTimeInterval:7.0 target:g_keysController selector:@selector(debugSpoofDisconnected) userInfo:nil repeats:NO];
#endif
        
#if Debug_BUILD
        NSLog(@"This is a debug build");
#endif
        
    }
    
    return self;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Test Flight Integration
    [TestFlight takeOff:@"ad6b7150-d397-4188-9f1a-58f56c83d967"];
    
    // Typical UI Setup
    //[TestFlight takeOff:@"ad6b7150-d397-4188-9f1a-58f56c83d967"];
    
    // Override point for customization after application launch.
    m_navigationController.navigationBarHidden = YES;
    
    // Add the navigation controller's view to the window and display.
    m_window.rootViewController = m_navigationController;
    
    // We need this in other parts of the app to properly display modals with transparent backgrounds
    m_window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    //application.statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
    
    [self.m_window setFrame:[[UIScreen mainScreen] bounds]];
    [m_navigationController.view setFrame:[[UIScreen mainScreen] bounds]];
    [self.m_window addSubview:m_navigationController.view];
    [self.m_window makeKeyAndVisible];
    
    // We never want to rotate
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Application launched"];
    [mixpanel.people increment:@"Application opens" by:[NSNumber numberWithInteger:1]];
    
    self.m_playApplication = (keysPlayApplication*)application;
    [self.m_playApplication resetIdleTimer];
    
    // Delay load some things
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(delayedLoad) userInfo:nil repeats:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    // This gets called when the home button is pressed
    
    // abort a firmware update, if in progress
    [g_keysController sendFirmwareUpdateCancelation];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    // This gets called when the home button is pushed
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Application background"];
    [mixpanel.people increment:@"Application closes" by:[NSNumber numberWithInteger:1]];
    
    //    [g_telemetryController synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Application foreground"];
    [mixpanel.people increment:@"Application opens" by:[NSNumber numberWithInteger:1]];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // This gets called when the app begins for the first time and when restarted from the multitask bar
    
    // Clear the cache if this changes in the background
    [self checkAndClearCache];
    
    [g_fileController checkCacheSize];
    
    //[g_facebook extendAccessTokenIfNeeded];
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Application terminated"];
    [mixpanel.people increment:@"Application closes" by:[NSNumber numberWithInteger:1]];
}

// For handling facebook URLs
/*
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [g_facebook handleOpenURL:url];
}
*/

#pragma mark -
#pragma mark Globals

- (void)checkAndClearCache
{
    
    if ( g_fileController == nil )
    {
        return;
    }
    
    // Clear the cache if this changes in the background
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings synchronize];
    
    BOOL clearCache = [settings boolForKey:@"ClearCache"];
    //    BOOL runBefore = [settings boolForKey:@"RunBefore"];
    
    if ( clearCache == YES )
    {
        // Clear the cache and then re-install the preloaded content
        [g_fileController clearCache];
        [g_userController clearCache];
        //[g_facebook logout];
        
        [settings setBool:NO forKey:@"ClearCache"];
        
        [settings synchronize];
        
    }
    //    else if ( runBefore == NO )
    //    {
    //        // If this is the first time we run, preinstall the content
    //    }
    
}

- (NSString*)generateUUID
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    NSString * uuidString = [settings stringForKey:@"UUIDString"];
    
    if ( uuidString != nil )
        return uuidString;
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    
    CFStringRef uuidCFString = CFUUIDCreateString(nil, uuid);
    
    // Convert to NSString
    uuidString = (__bridge NSString*)uuidCFString;
    
    
    // Save this UUID
    [settings setObject:uuidString forKey:@"UUIDString"];
    
    [settings synchronize];
    
    CFRelease(uuid);
    CFRelease(uuidCFString);
    
    return uuidString;
}

- (void)delayedLoad
{
    
    NSLog(@"Begin delayed loading");
    
    // Create the audio controller -- this can take awhile
    // g_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
    
    NSLog(@"Finished delayed loading");
    
    TitleNavigationController *titleController = (TitleNavigationController*)m_navigationController.visibleViewController;
    [titleController delayLoadingComplete];
    
    //    UIView * delayLoadView = ((RootViewController*)m_navigationController.visibleViewController).m_delayLoadView;
    //
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:1.0f];
    //    [UIView setAnimationDelegate:delayLoadView];
    //    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    //
    //    delayLoadView.alpha = 0.0f;
    //
    //    [UIView commitAnimations];
    
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Application memory warning"];
    
}



#pragma mark -
#pragma mark KeysControllerObserver

- (void)keysNoteOn:(KeysPress)press
{
    [m_playApplication resetIdleTimer];
}

@end

