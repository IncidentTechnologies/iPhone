//
//  TitleFacebookViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FullScreenDialogViewController.h"

#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>

#import "Facebook.h"

@interface TitleFacebookViewController : FullScreenDialogViewController
{
    
    IBOutlet UILabel * m_statusLabel;
    
    UIView * m_fullScreenSpinnerView;

}

@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;

- (void)startSpinner;
- (void)endSpinner;
- (void)loginFailed;

//- (IBAction)fullScreenButtonClicked:(id)sender;

- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;

- (void)loginCallback:(UserResponse*)userResponse;

@end
