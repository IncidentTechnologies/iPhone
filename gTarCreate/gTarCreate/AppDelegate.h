//
//  AppDelegate.h
//  gTarCreate
//
//  Created by Idan Beck on 2/11/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DefaultViewController.h"
#import "GtarControllerInternal.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GtarControllerObserver>
{
    
}

@property (strong, nonatomic) UIWindow *window;

@end
