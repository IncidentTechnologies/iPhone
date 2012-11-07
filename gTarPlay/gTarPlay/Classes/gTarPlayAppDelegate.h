//
//  gTarPlayAppDelegate.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarController/GtarController.h>

#import "FBConnect.h"

@class gTarPlayApplication;

@interface gTarPlayAppDelegate : NSObject <UIApplicationDelegate, GtarControllerObserver>
{
    UIWindow * window;
    UINavigationController * navigationController;
    gTarPlayApplication * playApplication;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet UINavigationController * navigationController;
@property (nonatomic, assign) gTarPlayApplication * playApplication;

- (void)checkAndClearCache;
//- (void)installPreloadedContent;

@end

