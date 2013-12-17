//
//  AppDelegate.h
//  gtarLearn
//
//  Created by Idan Beck on 11/10/13.
//  Copyright (c) 2013 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LearnNavigationController.h"

@interface LearnAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *m_window;
    LearnNavigationController *m_navigationController;
}

@property (strong, nonatomic) UIWindow *m_window;
@property (nonatomic, retain) IBOutlet UINavigationController *m_navigationController;

@end
