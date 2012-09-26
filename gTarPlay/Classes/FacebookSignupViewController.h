//
//  FacebookSignupViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/20/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PopupViewController.h>

@class CloudResponse;

@protocol FacebookSignupDelegate <NSObject>

- (void)facebookSignupSucceeded;
- (void)facebookSignupFailed;

@end

@interface FacebookSignupViewController : PopupViewController <UITextFieldDelegate>
{
    
    id<FacebookSignupDelegate> m_delegate;
    
    IBOutlet UITextField * m_signupUsernameField;
    IBOutlet UITextField * m_signupEmailField;

    IBOutlet UIButton * m_screenButton;
    IBOutlet UILabel * m_errorLabel;
    IBOutlet UIView * m_doneButton;
    IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
    
    NSString * m_accessToken;
        
}

@property (nonatomic, assign) id<FacebookSignupDelegate> m_delegate;

@property (nonatomic, retain) IBOutlet UITextField * m_signupUsernameField;
@property (nonatomic, retain) IBOutlet UITextField * m_signupEmailField;

@property (nonatomic, retain) IBOutlet UIButton * m_screenButton;
@property (nonatomic, retain) IBOutlet UILabel * m_errorLabel;
@property (nonatomic, retain) IBOutlet UIView * m_doneButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicatorView;

@property (nonatomic, retain) NSString * m_accessToken;

- (IBAction)signupButtonClicked:(id)sender;

- (void)signup;
- (void)signupCallback:(CloudResponse*)cloudResponse;

@end
