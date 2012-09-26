//
//  TitleFacebookViewController.h
//  gTarPlay
//
//  Created by Joel Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FullScreenDialogViewController.h"

#import <UserController.h>
#import <UserResponse.h>

#import "Facebook.h"

extern UserController * g_userController;
extern Facebook * g_facebook;

@interface TitleFacebookViewController : FullScreenDialogViewController
{
    
    UserController * m_userController;
    
    IBOutlet UILabel * m_statusLabel;
    
    UIView * m_fullScreenSpinnerView;

}

@property (nonatomic, retain) UserController * m_userController;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;

- (void)startSpinner;
- (void)endSpinner;
- (void)loginFailed;

- (IBAction)fullScreenButtonClicked:(id)sender;

- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

- (void)loginCallback:(UserResponse*)userResponse;

@end
