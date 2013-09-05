//
//  StoreSongListCell.h
//  gTarPlay
//
//  Created by Idan Beck on 8/31/13.

#import <UIKit/UIKit.h>
#import "StoreListBuyButtonView.h"
#import "StoreViewController.h"

@class UserSong;

@interface StoreSongListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet StoreViewController *parentStoreViewController;

@property (retain, nonatomic) IBOutlet UIView *titleArtistView;
@property (retain, nonatomic) IBOutlet UIView *skillView;
@property (retain, nonatomic) IBOutlet UIView *purchaseSongView;

@property (nonatomic, strong) IBOutlet UILabel *labelSongTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelSongArtist;
@property (retain, nonatomic) IBOutlet UIImageView *songSkill;

@property (retain, nonatomic) IBOutlet UIButton *buttonBuySong;
@property (retain, nonatomic) IBOutlet StoreListBuyButtonView *buyButtonView;

@property (retain, nonatomic) UserSong *userSong;

- (void)updateCell;

- (IBAction)onBuyButtonTouchUpInside:(id)sender;

-(void)IAPSongPurchaseCallbackWithContext:(id)pContext;

@end
