//
//  gTarPlayAppDelegate.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "gTarPlayAppDelegate.h"
#import "gTarPlayApplication.h"

#import <CoreFoundation/CoreFoundation.h>

#import <TargetConditionals.h>

#import "SongViewController.h"
#import "SongPlayerViewController.h"
#import "RootViewController.h"

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/TelemetryController.h>

#import <AudioController/AudioController.h>

SongViewController * g_songViewController;
RootViewController * g_rootViewController;
SongPlayerViewController * g_songPlayerViewController;
Facebook * g_facebook;

CloudController * g_cloudController;
AudioController * g_audioController;
FileController * g_fileController;
GtarController * g_gtarController;
UserController * g_userController;
TelemetryController * g_telemetryController;
//ContentController * g_contentController;

@implementation gTarPlayAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize playApplication;

#pragma mark -
#pragma mark Application lifecycle

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        //
        // Init the cloud controller
        //
        
        g_cloudController = [[CloudController alloc] initWithServer:@"http://50.18.250.24/v1.0.6firm"];
//        g_cloudController = [[CloudController alloc] initWithServer:@"http://184.169.154.56/v1.0.6"];
      
        //
        // Restore the file controller so we can get all the cached content
        //
        g_fileController = [[FileController alloc] initWithCloudController:g_cloudController];
        
        //
        // Create the content controller 
        //
//        g_contentController = [[ContentController alloc] initWithCloudController:g_cloudController];
        
        //
        // Connect to the gtar device
        //
        g_gtarController = [[GtarController alloc] init];
        
        g_gtarController.responseThread = GtarControllerThreadMain;
        
        // By default it just outputs 'LevelError'
        //g_gtarController.logLevel = GtarControllerLogLevelInfo;
        
        [g_gtarController addObserver:self];
        
        // Create the audio controller
        g_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
        [g_audioController initializeAUGraph];
        
#if TARGET_IPHONE_SIMULATOR
        [g_gtarController debugSpoofConnected];
#endif
        
        //
        // Create the user controller to manage users
        //
        g_userController = [[UserController alloc] initWithCloudController:g_cloudController];
        
        //
        // Create the telemetry controller to upload log data
        //
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        NSString * uuidString = [[settings stringForKey:@"UUIDString"] retain];
        
        if ( uuidString == nil )
        {
            
            CFUUIDRef uuid = CFUUIDCreate(nil);
            
            CFStringRef uuidCFString = CFUUIDCreateString(nil, uuid);
            
            // Convert to NSString
            uuidString = (NSString*)uuidCFString;
            
            // Add a reference to match the above -- technically it already has +1
            // but we will CFRelease it in a moment.
            [uuidString retain];
            
            CFRelease(uuidString);
            CFRelease(uuid);
            
            [settings setObject:uuidString forKey:@"UUIDString"];
            
            [settings synchronize];
            
        }

        g_telemetryController = [[TelemetryController alloc] initWithCloudController:g_cloudController];
        g_telemetryController.m_compileDate = @__DATE__;
        g_telemetryController.m_appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        g_telemetryController.m_appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
        g_telemetryController.m_deviceId = uuidString;
        
        [uuidString release];
        
    }
    
    return self;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    
    // Override point for customization after application launch.
	navigationController.navigationBarHidden = YES;
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    // We never want to rotate
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [g_telemetryController logMessage:@"Application launched" withType:TelemetryControllerMessageTypeInfo];
    
    self.playApplication = application;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    // This gets called when the home button is pressed
    
    // if there is a currently running song player instance, pause that.
    if ( g_songViewController != nil )
    {
        [g_songViewController pauseSong];
    }
    
    // if they are listening to a song, pause that.
    if ( g_songPlayerViewController != nil )
    {
        [g_songPlayerViewController pauseSongPlayback];
    }
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
    // This gets called when the home button is pushed
    
    [g_telemetryController logMessage:@"Application did enter background" withType:TelemetryControllerMessageTypeInfo];
    
    [g_telemetryController synchronize];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    // This gets called when the app is re-started
    
    [g_telemetryController logMessage:@"Application will enter foreground" withType:TelemetryControllerMessageTypeInfo];

}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // This gets called when the app begins for the first time and when restarted from the multitask bar
    
    // Clear the cache if this changes in the background
    [self checkAndClearCache];
    
    if ( g_rootViewController.m_waitingForFacebook == YES )
    {
        [g_rootViewController displayWelcomeDialog];
    }
    
    [g_facebook extendAccessTokenIfNeeded];

}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    [g_telemetryController logMessage:@"Application will terminate" withType:TelemetryControllerMessageTypeInfo];
    
    [g_telemetryController synchronize];
}

// For handling facebook URLs
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [g_facebook handleOpenURL:url]; 
}

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
        [g_facebook logout];
        
        [settings setBool:NO forKey:@"ClearCache"];
        
        [settings synchronize];
        
    }
//    else if ( runBefore == NO )
//    {
//        // If this is the first time we run, preinstall the content
//    }
    
}

//- (void)installPreloadedContent
//{
//    
//    // 'install' the preloaded content into the FileController
//    NSString * plistName = [[NSBundle mainBundle] pathForResource:@"preloaded-content" ofType:@"plist"];
//    NSDictionary * preloadedContentDict = [NSDictionary dictionaryWithContentsOfFile:plistName];
//    NSArray * preloadedContentArray = [preloadedContentDict objectForKey:@"PreloadedContent"];
//    
//    for ( NSString * fileName in preloadedContentArray )
//    {
//        
//        NSString * filePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
//        
//        NSLog(@"Installing %@", filePath);
//        
//        // this gets us the file id
//        NSString * fileIdStr = [[fileName lastPathComponent] stringByDeletingPathExtension];
//        
//        BOOL result = [g_fileController saveFilePath:filePath withFileId:[fileIdStr integerValue]];
//        
//        if ( result == NO )
//        {
//            NSLog(@"Failed to install fileid %@ %@", fileIdStr, filePath);
//        }
//    }
//}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [g_telemetryController logMessage:@"Application did receive memory warning" withType:TelemetryControllerMessageTypeInfo];
    
}


- (void)dealloc
{
    
    [g_userController release];
    
    [g_gtarController release];
    
//    [g_contentController release];
    
    [g_fileController release];
    
    [g_telemetryController release];
    
    [g_cloudController release];
    
	[navigationController release];
    
	[window release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark GtarControllerObserver

- (void)gtarNoteOn:(GtarPluck)pluck
{
    [playApplication resetIdleTimer];
}

@end

