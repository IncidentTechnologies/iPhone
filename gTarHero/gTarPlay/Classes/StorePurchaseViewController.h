//
//  StorePurchaseViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/1/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"
@class UserSong;

@interface StorePurchaseViewController : CustomViewController
{
    
    IBOutlet UILabel * m_currentAction;
    IBOutlet UILabel * m_statusLabel;
    IBOutlet UIActivityIndicatorView * m_activityIndicator;
    IBOutlet UIButton * m_actionButton;
    IBOutlet UIButton * m_cancelButton;
    IBOutlet UIButton * m_backButton;

    UserSong * m_userSong;
    
}


@property (nonatomic, retain) IBOutlet UILabel * m_currentAction;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicator;
@property (nonatomic, retain) IBOutlet UIButton * m_actionButton;
@property (nonatomic, retain) IBOutlet IBOutlet UIButton * m_cancelButton;

@property (nonatomic, retain) UserSong * m_userSong;

- (void)startPurchasing;
- (void)purchaseSuccessful;
- (void)purchaseFailed:(NSString*)error;
- (void)purchasePending:(NSString*)error;
- (IBAction)actionButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
