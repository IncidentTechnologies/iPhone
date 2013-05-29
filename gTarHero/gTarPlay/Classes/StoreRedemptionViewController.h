//
//  StoreRedemptionViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/19/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

@interface StoreRedemptionViewController : CustomViewController <UITextFieldDelegate>
{
    
    IBOutlet UITextField * m_textField;
    IBOutlet UIView * m_buttonView;
    IBOutlet UIActivityIndicatorView * m_activityIndicator;
    IBOutlet UILabel * m_statusLabel;
    
    NSString * m_previousText;
    BOOL m_intraStringEditing;
    
}

@property (nonatomic, retain) IBOutlet UITextField * m_textField;
@property (nonatomic, retain) IBOutlet UIView * m_buttonView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicator;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;

- (IBAction)redeemButtonClicked:(id)sender;
- (IBAction)textFieldDidChange:(id)sender;

- (void)redeemSucceeded;
- (void)redeemFailed:(NSString*)reason;

@end
