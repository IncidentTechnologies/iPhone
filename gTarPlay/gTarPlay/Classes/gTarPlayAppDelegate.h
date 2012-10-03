//
//  gTarPlayAppDelegate.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBConnect.h"

@interface gTarPlayAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate>
{
    UIWindow * window;
    UINavigationController * navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet UINavigationController * navigationController;

- (void)checkAndClearCache;
- (void)installPreloadedContent;

@end

