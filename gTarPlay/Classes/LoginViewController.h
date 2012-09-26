//
//  LoginViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/16/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewsViewController.h"
#import "LegacySignupViewController.h"

@class RoundedRectangleButton;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginSucceeded;
- (void)loginFailed;
- (void)loginFacebookLogin;
- (void)loginShowProfile;

@end

@class MarqueeExpandingRoundedRectangleView;
@class RoundedRectangleView;
@class CloudResponse;

@interface LoginViewController : NewsViewController <UITextFieldDelegate, LegacySignupDelegate>
{
    
    id<LoginViewControllerDelegate> m_delegate;
    
    IBOutlet UIView * m_loginActiveAreaView;
	IBOutlet UIView * m_loginLargeView;
	IBOutlet UIView * m_loginSmallView;
	IBOutlet MarqueeExpandingRoundedRectangleView * m_loginMarqueeView;
    IBOutlet UIView * m_loginOptionsButtons;
    
    IBOutlet RoundedRectangleButton * m_loginButton;
    IBOutlet RoundedRectangleButton * m_logoutButton;
    IBOutlet UIButton * m_facebookLoginButton;
    
    IBOutlet UIButton * m_loginStatus;
	IBOutlet UILabel * m_loginError;
    
    IBOutlet UITextField * m_loginUsernameField;
    IBOutlet UITextField * m_loginPasswordField;
    
    IBOutlet UIActivityIndicatorView * m_loginActivityIndicator;
    
    IBOutlet UIButton * m_screenButton;
    
    LegacySignupViewController * m_signupViewController;
    
}

@property (nonatomic, retain) id<LoginViewControllerDelegate> m_delegate;

@property (nonatomic, retain) IBOutlet UIView * m_loginActiveAreaView;
@property (nonatomic, retain) IBOutlet UIView * m_loginLargeView;
@property (nonatomic, retain) IBOutlet UIView * m_loginSmallView;
@property (nonatomic, retain) IBOutlet MarqueeExpandingRoundedRectangleView * m_loginMarqueeView;
@property (nonatomic, retain) IBOutlet UIView * m_loginOptionsButtons;

@property (nonatomic, retain) IBOutlet RoundedRectangleButton * m_loginButton;
@property (nonatomic, retain) IBOutlet RoundedRectangleButton * m_logoutButton;
@property (nonatomic, retain) IBOutlet UIButton * m_facebookLoginButton;

@property (nonatomic, retain) IBOutlet UIButton * m_loginStatus;
@property (nonatomic, retain) IBOutlet UILabel * m_loginError;

@property (nonatomic, retain) IBOutlet UITextField * m_loginUsernameField;
@property (nonatomic, retain) IBOutlet UITextField * m_loginPasswordField;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_loginActivityIndicator;

@property (nonatomic, retain) IBOutlet UIButton * m_screenButton;

- (void)attemptLoginWithUsername:(NSString*)username andPassword:(NSString*)password;
- (void)attemptLogin;
- (void)attemptCachedLogin;

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)logoutButtonClicked:(id)sender;
//- (IBAction)screenButtonClicked:(id)sender;
- (IBAction)facebookLoginButtonClicked:(id)sender;
- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)profileButtonClicked:(id)sender;

- (void)authenticatingMode;
- (void)offlineMode;
- (void)authenticatedMode;
- (void)connectionFailedMode;

- (void)requestLoginCallback:(CloudResponse*)cloudResponse;
- (void)requestLogoutCallback:(CloudResponse*)cloudResponse;

- (void)hideView:(UIView*)v;
- (void)showView:(UIView*)v;

@end
