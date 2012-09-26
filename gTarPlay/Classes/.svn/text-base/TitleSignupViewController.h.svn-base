//
//  TitleSignupViewController.h
//  gTarPlay
//
//  Created by Joel Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FullScreenDialogViewController.h"

#import "UserController.h"
#import "UserResponse.h"

@interface TitleSignupViewController : FullScreenDialogViewController
{
    
    UserController * m_userController;
    
    IBOutlet UITextField * m_usernameTextField;
    IBOutlet UITextField * m_passwordTextField;
    IBOutlet UITextField * m_emailTextField;
    IBOutlet UILabel * m_statusLabel;
    
    UIButton * m_fullScreenButton;
    UIView * m_fullScreenSpinnerView;

}

@property (nonatomic, retain) UserController * m_userController;
@property (nonatomic, retain) IBOutlet UITextField * m_usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField * m_passwordTextField;
@property (nonatomic, retain) IBOutlet UITextField * m_emailTextField;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;

- (void)startSpinner;
- (void)endSpinner;
- (void)expandKeyboard;
- (void)retractKeyboard;

- (IBAction)fullScreenButtonClicked:(id)sender;
- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)loginButtonClicked:(id)sender;

- (void)signupCallback:(UserResponse*)userResponse;

- (IBAction)textFieldSelected:(id)sender;

@end
