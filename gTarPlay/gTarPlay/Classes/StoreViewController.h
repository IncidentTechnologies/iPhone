//
//  StoreViewController.h
//  gTarPlay
//
//  Created by Franco on 8/28/13.
//
//

#import <QuartzCore/QuartzCore.h>"
#import <UIKit/UIKit.h>
#import "PaginatedPullToUpdateTableView.h"

@class UserSong;

@interface StoreViewController : UIViewController <PullToUpdateTableViewDelegate> {

}

@property (retain, nonatomic) IBOutlet UIButton *buttonGetProductList;
@property (retain, nonatomic) IBOutlet PullToUpdateTableView *pullToUpdateSongList;
@property (retain, nonatomic) IBOutlet UIButton *buttonGetServerSongList;

@property (retain, nonatomic) IBOutlet UIView *viewTopBar;
@property (retain, nonatomic) IBOutlet UIView *colBar;

@property (retain, nonatomic) IBOutlet UIButton *buttonTitleArtist;
@property (retain, nonatomic) IBOutlet UIButton *buttonSkill;
@property (retain, nonatomic) IBOutlet UIButton *buttonBuy;


- (IBAction)getProductList:(id)sender;
- (IBAction)onGetServerSongListTouchUpInside:(id)sender;
- (void)refreshDisplayedStoreSongList;
- (void)refreshSongList;

- (IBAction)onBackButtonTouchUpInside:(id)sender;

-(void)openSongListToSong:(UserSong*)userSong;

@end
