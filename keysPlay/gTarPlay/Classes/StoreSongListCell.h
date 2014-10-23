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

@property (strong, nonatomic) IBOutlet StoreViewController *parentStoreViewController;

@property (strong, nonatomic) IBOutlet UIView *titleArtistView;
@property (strong, nonatomic) IBOutlet UIView *skillView;
@property (strong, nonatomic) IBOutlet UIView *purchaseSongView;

@property (nonatomic, strong) IBOutlet UILabel *labelSongTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelSongArtist;
@property (strong, nonatomic) IBOutlet UIImageView *songSkill;

@property (strong, nonatomic) IBOutlet UIButton *buttonBuySong;
@property (strong, nonatomic) IBOutlet StoreListBuyButtonView *buyButtonView;

@property (strong, nonatomic) UserSong *userSong;

- (void)updateCell;

- (IBAction)onBuyButtonTouchUpInside:(id)sender;

-(void)IAPSongPurchaseCallbackWithContext:(id)pContext;

@end
