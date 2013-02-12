//
//  gTarPlayAppDelegate.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarController/GtarController.h>

#import "gTarNavigationController.h"
#import "FBConnect.h"

@class gTarPlayApplication;

@interface gTarPlayAppDelegate : NSObject <UIApplicationDelegate, GtarControllerObserver>
{
    UIWindow * m_window;
    gTarNavigationController * m_navigationController;
    gTarPlayApplication * m_playApplication;
}

@property (nonatomic, retain) IBOutlet UIWindow * m_window;
@property (nonatomic, retain) IBOutlet UINavigationController * m_navigationController;
@property (nonatomic, assign) gTarPlayApplication * m_playApplication;

- (void)checkAndClearCache;
//- (void)installPreloadedContent;
- (NSString*)generateUUID;

@end

