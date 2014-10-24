//
//  StoreViewController.h
//  keysPlay
//
//  Created by Franco on 8/28/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "PaginatedPullToUpdateTableView.h"
#import "ExpandableSearchBar.h"

#import "SoundMaster.h"
#import "KeysController.h"
#import "SlidingInstrumentViewController.h"

#import "PlayViewController.h"
#import "PlayerViewController.h"
#import "SlidingModalViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"

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

@class SlidingModalViewController;

@interface StoreViewController : UIViewController <KeysControllerObserver, PullToUpdateTableViewDelegate, ExpandableSearchBarDelegate,SlidingInstrumentDelegate, PlayerViewDelegate> {

}

// Options Modal
@property (strong, nonatomic) SoundMaster *g_soundMaster;

@property (strong, nonatomic) IBOutlet SlidingModalViewController *songOptionsModal;
@property (strong, nonatomic) IBOutlet UIButton *closeModalButton;
@property (strong, nonatomic) IBOutlet UIButton *volumeButton;
@property (strong, nonatomic) IBOutlet UIButton *instrumentButton;

@property (strong, nonatomic) IBOutlet UIButton *easyButton;
@property (strong, nonatomic) IBOutlet UILabel *easyLabel;

@property (strong, nonatomic) IBOutlet UIButton *mediumButton;
@property (strong, nonatomic) IBOutlet UILabel *mediumLabel;

@property (strong, nonatomic) IBOutlet UIButton *hardButton;
@property (strong, nonatomic) IBOutlet UILabel *hardLabel;

@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *practiceButton;

@property (strong, nonatomic) IBOutlet UIView *volumeView;
@property (strong, nonatomic) IBOutlet UIView *instrumentView;
@property (strong, nonatomic) IBOutlet UIView *songPlayerView;

@property (strong, nonatomic) IBOutlet ExpandableSearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIButton *buttonGetProductList;
@property (strong, nonatomic) IBOutlet PullToUpdateTableView *pullToUpdateSongList;
@property (strong, nonatomic) IBOutlet UIButton *buttonGetServerSongList;

@property (strong, nonatomic) IBOutlet UIView *viewTopBar;
@property (strong, nonatomic) IBOutlet UIView *colBar;

@property (strong, nonatomic) IBOutlet UIButton *buttonTitleArtist;
@property (strong, nonatomic) IBOutlet UIButton *buttonSkill;
@property (strong, nonatomic) IBOutlet UIButton *buttonBuy;

//@property (strong, nonatomic) IBOutlet UILabel *backLabel;
@property (strong, nonatomic) IBOutlet UILabel *shopLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSoundMaster:(SoundMaster *)soundMaster;

- (void)localizeViews;

- (IBAction)getProductList:(id)sender;
- (IBAction)onGetServerSongListTouchUpInside:(id)sender;
- (void)refreshDisplayedStoreSongList;
- (void)refreshSongList;

- (IBAction)onBackButtonTouchUpInside:(id)sender;

-(void)openSongListToSong:(UserSong*)userSong;

-(IBAction)onTitleArtistClick:(id)sender;
-(IBAction)onSkillClick:(id)sender;
-(IBAction)onBuyClick:(id)sender;

// Song Selection
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)practiceButtonClicked:(id)sender;
- (IBAction)closeModalButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)instrumentButtonClicked:(id)sender;
- (IBAction)difficulyButtonClicked:(id)sender;
- (IBAction)blackButtonClicked:(id)sender;
//- (IBAction)fullscreenButtonClicked:(id)sender;

@end
