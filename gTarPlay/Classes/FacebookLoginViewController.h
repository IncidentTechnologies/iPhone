//
//  FacebookLoginViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/17/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <FacebookController.h>
#import "NewsViewController.h"
#import "FacebookSignupViewController.h"

@protocol FacebookLoginViewControllerDelegate <NSObject>

- (void)facebookLoginSucceeded;
- (void)facebookLoginFailed;
- (void)facebookLegacyLogin;
- (void)facebookShowProfile;

@end

@class RoundedRectangleView;
@class MarqueeExpandingRoundedRectangleView;

@interface FacebookLoginViewController : NewsViewController <FacebookControllerDelegate, FacebookSignupDelegate>
{
    
    id<FacebookLoginViewControllerDelegate> m_delegate;
    
    IBOutlet MarqueeExpandingRoundedRectangleView * m_facebookLoginMarqueeView;
    IBOutlet RoundedRectangleView * m_facebookLoginBackgroundView;
    IBOutlet MarqueeExpandingRoundedRectangleView * m_facebookLoginMidgroundView;
    IBOutlet UIView * m_facebookLoginLargeView;
    IBOutlet UIView * m_facebookLoginButton;
    IBOutlet UIView * m_facebookLogoutButton;
    IBOutlet UIActivityIndicatorView * m_facebookLoginActivityIndicator;
    IBOutlet UIButton * m_facebookWelcomeLabel;
    IBOutlet UILabel * m_facebookLoginLabel;
    IBOutlet UILabel * m_facebookLogoutLabel;
    
    FacebookController * m_facebookController;
    FacebookSignupViewController * m_facebookSignupViewController;
    
}

@property (nonatomic, assign) id<FacebookLoginViewControllerDelegate> m_delegate;

@property (nonatomic, retain) IBOutlet MarqueeExpandingRoundedRectangleView * m_facebookLoginMarqueeView;
@property (nonatomic, retain) IBOutlet RoundedRectangleView * m_facebookLoginBackgroundView;
@property (nonatomic, retain) IBOutlet MarqueeExpandingRoundedRectangleView * m_facebookLoginMidgroundView;
@property (nonatomic, retain) IBOutlet UIView * m_facebookLoginLargeView;
@property (nonatomic, retain) IBOutlet UIView * m_facebookLoginButton;
@property (nonatomic, retain) IBOutlet UIView * m_facebookLogoutButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_facebookLoginActivityIndicator;
@property (nonatomic, retain) IBOutlet UIButton * m_facebookWelcomeLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_facebookLoginLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_facebookLogoutLabel;

- (void)attemptCachedLogin;

- (IBAction)facebookLoginButtonClicked:(id)sender;
- (IBAction)facebookLogoutButtonClicked:(id)sender;
- (IBAction)facebookNoAccountButtonClicked:(id)sender;

- (IBAction)facebookLoginButtonTouchDown:(id)sender;
- (IBAction)facebookLogoutButtonTouchDown:(id)sender;

- (IBAction)facebookLoginButtonTouchUpOutside:(id)sender;
- (IBAction)facebookLogoutButtonTouchUpOutside:(id)sender;

- (IBAction)facebookProfileButtonClicked:(id)sender;

- (void)facebookLoggedInAnimation;
- (void)facebookLoggedOutAnimation;

@end
