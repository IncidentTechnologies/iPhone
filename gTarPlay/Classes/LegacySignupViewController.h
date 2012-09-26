//
//  LegacySignupViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/23/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PopupViewController.h"

@protocol LegacySignupDelegate <NSObject>

- (void)legacySignupSucceeded;
- (void)legacySignupFailed;

@end

@class RoundedRectangleView;
@class RoundedRectangleButton;
@class CloudResponse;

@interface LegacySignupViewController : PopupViewController <UITextFieldDelegate>
{

    id<LegacySignupDelegate> m_delegate;
    
    IBOutlet UITextField * m_signupUsernameField;
    IBOutlet UITextField * m_signupEmailField;
    IBOutlet UITextField * m_signupPassword1Field;
    IBOutlet UITextField * m_signupPassword2Field;
    
	IBOutlet RoundedRectangleButton * m_signupDoneButton;

	IBOutlet UILabel * m_signupStatus;
    
    IBOutlet UIActivityIndicatorView * m_signupActivityIndicator;
	
}

@property (nonatomic, assign) id<LegacySignupDelegate> m_delegate;
@property (nonatomic, retain) IBOutlet UITextField * m_signupUsernameField;
@property (nonatomic, retain) IBOutlet UITextField * m_signupEmailField;
@property (nonatomic, retain) IBOutlet UITextField * m_signupPassword1Field;
@property (nonatomic, retain) IBOutlet UITextField * m_signupPassword2Field;

@property (nonatomic, retain) IBOutlet RoundedRectangleButton * m_signupDoneButton;

@property (nonatomic, retain) IBOutlet UILabel * m_signupStatus;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_signupActivityIndicator;

- (IBAction)doneButtonClicked:(id)sender;
//- (IBAction)screenButtonClicked:(id)sender;

- (void)requestRegisterCallback:(CloudResponse*)cloudResponse;

@end
