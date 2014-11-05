//
//  LoginViewController.h
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OphoController.h"

@class UserResponse;

@interface LoginViewController : UIViewController <UITextFieldDelegate, OphoLoginDelegate> {
    
}

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UIButton *signinButton;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;


- (IBAction)signinButtonClicked:(id)sender;

//- (IBAction)signupButtonClicked:(id)sender;

@end
