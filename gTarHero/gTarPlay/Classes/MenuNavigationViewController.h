//
//  MenuNavigationViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 2/29/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuIndexViewController.h"
#import "MenuLoginViewController.h"
#import "MenuSignupViewController.h"
#import "MenuTutorialViewController.h"

#import "CustomNavigationViewController.h"

@interface MenuNavigationViewController : CustomNavigationViewController
{
    
    MenuIndexViewController * m_menuIndexViewController;
    MenuLoginViewController * m_menuLoginViewController;
    MenuSignupViewController * m_menuSignupViewController;
    MenuTutorialViewController * m_menuTutorialViewController;
    
}

- (void)displaySignupViewController;
- (void)displayLoginViewController;

- (void)displayTutorialViewController;
- (void)hideTutorialViewController;

@end
