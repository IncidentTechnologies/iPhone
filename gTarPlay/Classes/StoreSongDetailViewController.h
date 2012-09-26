//
//  StoreSongDetailViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"
@class UserSong;
@class StarRatingView;

@interface StoreSongDetailViewController : CustomViewController
{
    
    IBOutlet UIImageView * m_albumArtView;
    IBOutlet UILabel * m_songAuthor;
    IBOutlet UILabel * m_songTitle;
    IBOutlet UILabel * m_songGenre;
    IBOutlet UITextView * m_songDesc;
    IBOutlet StarRatingView * m_starRatingView;
    IBOutlet UIButton * m_buyButton;
    IBOutlet UIButton * m_confirmButton;
    IBOutlet UIActivityIndicatorView * m_buyActivityIndicator;
    IBOutlet UILabel * m_statusLabel;
    IBOutlet UILabel * m_creditsLabel;
    
    UserSong * m_userSong;
    NSInteger m_credits;
    BOOL m_owned;
    
}

@property (nonatomic, retain) IBOutlet UIImageView * m_albumArtView;
@property (nonatomic, retain) IBOutlet UILabel * m_songAuthor;
@property (nonatomic, retain) IBOutlet UILabel * m_songTitle;
@property (nonatomic, retain) IBOutlet UILabel * m_songGenre;
@property (nonatomic, retain) IBOutlet UITextView * m_songDesc;
@property (nonatomic, retain) IBOutlet StarRatingView * m_starRatingView;
@property (nonatomic, retain) IBOutlet UIButton * m_buyButton;
@property (nonatomic, retain) IBOutlet UIButton * m_confirmButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_buyActivityIndicator;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_creditsLabel;

@property (nonatomic, retain) UserSong * m_userSong;

@property (nonatomic, assign) BOOL m_owned;

- (IBAction)buyButtonClicked:(id)sender;
- (IBAction)confirmButtonClicked:(id)sender;
- (IBAction)redeemButtonClicked:(id)sender;
- (IBAction)buyCreditsButtonClicked:(id)sender;

- (void)purchaseSuccessful;
- (void)purchaseFailed:(NSString*)error;

- (void)startPurchaseAnimation;
- (void)updateCreditCount:(NSInteger)credits;

@end
