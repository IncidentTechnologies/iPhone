//
//  AppDelegate.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/15/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "AppDelegate.h"

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"

#import <GtarController/GtarController.h>

GtarController * g_gtarController;

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize imageView = _imageView;
@synthesize blackView = _blackView;
@synthesize whiteView = _whiteView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    g_gtarController = [[GtarController alloc] init];
    
    [g_gtarController turnOffAllEffects];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    FirstViewController * viewController1;
    SecondViewController * viewController2;
    ThirdViewController * viewController3;
    FourthViewController * viewController4;
    
    viewController1 = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    viewController2 = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    viewController3 = [[ThirdViewController alloc] initWithNibName:@"ThirdViewController" bundle:nil];
    viewController4 = [[FourthViewController alloc] initWithNibName:@"FourthViewController" bundle:nil];
    
    viewController1.m_secondViewController = viewController2;
    viewController2.m_thirdViewController = viewController3;
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, viewController4, nil];
    self.window.rootViewController = self.tabBarController;
    
    self.blackView = [[UIView alloc] initWithFrame:self.tabBarController.view.frame];
    self.blackView.backgroundColor = [UIColor blackColor];
    self.blackView.alpha = 0.0f;

    self.whiteView = [[UIView alloc] initWithFrame:self.tabBarController.view.frame];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.alpha = 0.0f;

    viewController3.m_blackScreen = self.blackView;
    viewController3.m_whiteScreen = self.whiteView;
     
    [self.tabBarController.view addSubview:self.blackView];
    [self.tabBarController.view addSubview:self.whiteView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.tabBarController.view.frame];
    self.imageView.alpha = 0.0f;
    
    viewController3.m_splashScreen = self.imageView;
    
    [self.tabBarController.view addSubview:self.imageView];
    
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
