//
//  GatekeeperViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "CloudController.h"
#import "CloudRequest.h"
#import "CloudResponse.h"
#import "CyclingTextField.h"

extern CloudController * g_cloudController;
extern Facebook * g_facebook;


@protocol GatekeeperDelegate <NSObject>

- (void) loggedIn;
- (void) loggedOut;

@end

@interface GatekeeperViewController : UIViewController <UITextFieldDelegate,FBSessionDelegate>
{
    
}

@property (weak, nonatomic) id<GatekeeperDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (strong, nonatomic) IBOutlet UIView * notificationView;

@property (strong, nonatomic) IBOutlet UIView * signupTopPanel;
@property (strong, nonatomic) IBOutlet UIView * signinTopPanel;
@property (strong, nonatomic) IBOutlet UIView * loadingTopPanel;

@property (strong, nonatomic) IBOutlet CyclingTextField *signinUsernameText;
@property (strong, nonatomic) IBOutlet CyclingTextField *signinPasswordText;

@property (strong, nonatomic) IBOutlet CyclingTextField *signupUsernameText;
@property (strong, nonatomic) IBOutlet CyclingTextField *signupPasswordText;
@property (strong, nonatomic) IBOutlet CyclingTextField *signupEmailText;

@property (strong, nonatomic) IBOutlet UIView * bottomPanel;

@property (strong, nonatomic) IBOutlet UIButton * loggedoutSigninButton;
@property (strong, nonatomic) IBOutlet UIButton * loggedoutSignupButton;

@property (strong, nonatomic) IBOutlet UIView * view;

// TODO: add these to a user object
@property (strong, nonatomic) NSString * loggedInFacebookToken;
@property (strong, nonatomic) NSString * loggedInUsername;
@property (strong, nonatomic) NSString * loggedInPassword;

- (IBAction)loggedoutSigninButtonClicked:(id)sender;
- (IBAction)loggedoutSignupButtonClicked:(id)sender;

- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)signinButtonClicked:(id)sender;
- (IBAction)signinFacebookButtonClicked:(id)sender;

@end
