//
//  AppDelegate.m
//  Sketch
//
//  Created by Franco on 6/6/13.
//
//

#import "AppDelegate.h"

#import <gTarAppCore/Facebook.h>

#import "Mixpanel.h"
#import "IQKeyBoardManager.h"

#define MIXPANEL_TOKEN @"c11530fd174560df8932558f936e08f9"

@implementation AppDelegate

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];        
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [IQKeyBoardManager installKeyboardManager];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Application launched"];
    [mixpanel.people increment:@"Application opens" by:[NSNumber numberWithInteger:1]];
    // Override point for customization after application launch.
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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Application background"];
    
    [mixpanel.people increment:@"Application closes" by:[NSNumber numberWithInteger:1]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Application foreground"];
    
    [mixpanel.people increment:@"Application opens" by:[NSNumber numberWithInteger:1]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [_facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Application terminated"];
    
    [mixpanel.people increment:@"Application closes" by:[NSNumber numberWithInteger:1]];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Application memory warning"];
}

// For handling facebook URLs
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [_facebook handleOpenURL:url];
}

@end
