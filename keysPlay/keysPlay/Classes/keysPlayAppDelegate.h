//
//  keysPlayAppDelegate.h
//  keysPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "AppCore.h"
#import "KeysController.h"
#import "keysNavigationController.h"
#import "KeysMath.h"

//#import <gTarAppCore/Facebbok/FBConnect.h>

@class keysPlayApplication;

@interface keysPlayAppDelegate : NSObject <UIApplicationDelegate, KeysControllerObserver>
{
    UIWindow * m_window;
    keysNavigationController * m_navigationController;
    keysPlayApplication * __weak m_playApplication;
}

@property (nonatomic, strong) IBOutlet UIWindow * m_window;
@property (nonatomic, strong) IBOutlet UINavigationController * m_navigationController;
@property (nonatomic, weak) keysPlayApplication * m_playApplication;

- (void)checkAndClearCache;
//- (void)installPreloadedContent;
- (NSString*)generateUUID;
- (void)delayedLoad;

@end

