//
//  AppDelegate.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/19/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

CloudController * g_cloudController;
NSUser * g_loggedInUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // TestFlight integration
    [TestFlight takeOff:@"e41b934c-d707-4ea6-97d4-f53a09b7617e"];
    
    // Soundcloud integration
    [SCSoundCloud setClientID:@"6c1217b3e9097c9dcc3e562b1b22bed9" secret:@"eb11f50b5d2b9f80a34e61a92150230f" redirectURL:[NSURL URLWithString:@"sampleproject://oauth"]];
    
    // Launch app loading
    [self initAndLaunchApp];
    
    return YES;
}

- (void)initAndLaunchApp
{
    
    // init the viewing window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // init nav controller and first view controller
    LoadingViewController *loadingViewController = [[LoadingViewController alloc] initWithNibName:nil bundle:nil];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loadingViewController];
    
    navigationController.navigationBarHidden = YES;
    
    [self.window setRootViewController: navigationController];
    
    // init the cloud controller
    g_cloudController = [[CloudController alloc] initWithServer:kServerAddress];
    
    // init the logged in user
    g_loggedInUser = [[NSUser alloc] init];
    
    // display
    [self.window makeKeyAndVisible];

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    DLog(@"######## LOW MEMORY #########");
}

@end
