//
//  GatekeeperViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 9/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CyclingTextField.h"

extern CloudController * g_cloudController;
extern NSUser * g_loggedInUser;

@protocol GatekeeperDelegate <NSObject>

- (void) loggedIn:(BOOL)animate;
- (void) loggedOut:(BOOL)animate;

@end

@interface GatekeeperViewController : UIViewController <UITextFieldDelegate,FBLoginViewDelegate>
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

@property (weak, nonatomic) IBOutlet FBLoginView * loginView;

- (IBAction)loggedoutSigninButtonClicked:(id)sender;
- (IBAction)loggedoutSignupButtonClicked:(id)sender;

- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)signinButtonClicked:(id)sender;

- (void)requestLogout;
- (void)requestCachedLogin;

- (void)resetScreen;

@end
