//
//  AppDelegate.m
//  gTarCreate
//
//  Created by Idan Beck on 2/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (id)init {
    self = [super init];
    
    if ( self ) {
        // Hide status bar
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        /*
         // Init the cloud controller
         g_cloudController = [[CloudController alloc] initWithServer:kServerAddress];
         
         // Restore the file controller so we can get all the cached content
         g_fileController = [[FileController alloc] initWithCloudController:g_cloudController];
         
         // Create the user controller to manage users
         g_userController = [[UserController alloc] initWithCloudController:g_cloudController];
         
         // Connect to the gtar device
         g_gtarController = [[GtarController alloc] init];
         g_gtarController.responseThread = GtarControllerThreadMain;
         
         // By default it just outputs 'LevelError'
         g_gtarController.logLevel = GtarControllerLogLevelAll;
         [g_gtarController addObserver:self];
         
         #if TARGET_IPHONE_SIMULATOR | Debug_BUILD
         [NSTimer scheduledTimerWithTimeInterval:5.0 target:g_gtarController selector:@selector(debugSpoofConnected) userInfo:nil repeats:NO];
         #endif
         
         #if Debug_BUILD
         NSLog(@"This is a debug build");
         #endif
         */
        
#ifdef _MIXPANEL
        Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
#endif
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    self.window.rootViewController = navController;
    
    // Load Title view
    DefaultViewController *defaultViewController = [[DefaultViewController alloc] initWithNibName:@"DefaultViewController" bundle:nil];
    [navController pushViewController:defaultViewController animated:false];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
