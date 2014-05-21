//
//  gTarPlayAppDelegate.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestFlight.h"
#import "GtarController.h"
#import "gTarNavigationController.h"

//#import <gTarAppCore/Facebbok/FBConnect.h>

@class gTarPlayApplication;

@interface gTarPlayAppDelegate : NSObject <UIApplicationDelegate, GtarControllerObserver>
{
    UIWindow * m_window;
    gTarNavigationController * m_navigationController;
    gTarPlayApplication * __weak m_playApplication;
}

@property (nonatomic, strong) IBOutlet UIWindow * m_window;
@property (nonatomic, strong) IBOutlet UINavigationController * m_navigationController;
@property (nonatomic, weak) gTarPlayApplication * m_playApplication;

- (void)checkAndClearCache;
//- (void)installPreloadedContent;
- (NSString*)generateUUID;
- (void)delayedLoad;

@end

