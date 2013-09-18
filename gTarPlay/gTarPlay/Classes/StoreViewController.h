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
#import "ExpandableSearchBar.h"

@class UserSong;

typedef enum {
    SORT_TITLE,
    SORT_ARTIST,
    SORT_SKILL,
    SORT_COST,
    SORT_INVALID
} STORE_SORT_ORDER_TYPE;

struct StoreSortOrder {
    STORE_SORT_ORDER_TYPE type;
    BOOL fAscending;
};

@interface StoreViewController : UIViewController <PullToUpdateTableViewDelegate, ExpandableSearchBarDelegate> {

}

@property (retain, nonatomic) IBOutlet ExpandableSearchBar *searchBar;

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

-(IBAction)onTitleArtistClick:(id)sender;
-(IBAction)onSkillClick:(id)sender;
-(IBAction)onBuyClick:(id)sender;

@end
