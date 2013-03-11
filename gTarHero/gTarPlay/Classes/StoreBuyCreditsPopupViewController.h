//
//  StoreBuyCreditsPopupViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 2/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <gTarAppCore/PopupViewController.h>

@class StoreNavigationViewController;

@interface StoreBuyCreditsPopupViewController : PopupViewController
{
    StoreNavigationViewController * m_navigationController;
    UIView * m_fullScreenActivityView;
}

@property (nonatomic, assign) StoreNavigationViewController * m_navigationController;

- (void)startPurchaseAnimation;
- (void)purchaseSuccessful;
- (void)purchaseFailed:(NSString*)error;

- (IBAction)buyCreditsAClicked:(id)sender;
- (IBAction)buyCreditsBClicked:(id)sender;
- (IBAction)buyCreditsCClicked:(id)sender;

@end
