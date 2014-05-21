//
//  SongSelectionViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>

#import "GtarController.h"
#import "CloudController.h"
#import "CloudResponse.h"
#import "CloudRequest.h"
#import "FileController.h"
#import "UserSong.h"
#import "UserSongs.h"
#import "XmlDom.h"
#import "SongPlaybackController.h"
#import <gTarAppCore/UserController.h>

#import "SongListCell.h"
#import "PlayViewController.h"
#import "SlidingModalViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"
#import "PlayerViewController.h"
#import "UIView+Gtar.h"
#import "UIButton+Gtar.h"
#import "PullToUpdateTableView.h"
#import "ExpandableSearchBar.h"
#import "SoundMaster.h"
//#import "UILevelSlider.h"

typedef enum {
    SORT_SONG_TITLE,
    SORT_SONG_ARTIST,
    SORT_SONG_SKILL,
    SORT_SONG_COST,
    SORT_SONG_INVALID
} SONG_SORT_ORDER_TYPE;

struct SongSortOrder {
    SONG_SORT_ORDER_TYPE type;
    BOOL fAscending;
};

@class PlayerViewController;
@class SlidingModalViewController;
@class UserSong;

@interface SongSelectionViewController : UIViewController <PullToUpdateTableViewDelegate, GtarControllerObserver, ExpandableSearchBarDelegate,SlidingInstrumentDelegate, PlayerViewDelegate>

// Audio Controller
@property (strong, nonatomic) SoundMaster *g_soundMaster;

// Song Options Modal
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

@property (strong, nonatomic) IBOutlet UIButton *practiceButton;
@property (strong, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonatomic) IBOutlet UIView *volumeView;
@property (strong, nonatomic) IBOutlet UIView *instrumentView;
@property (strong, nonatomic) IBOutlet UIView *songPlayerView;

@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (strong, nonatomic) IBOutlet ExpandableSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIButton *fullscreenButton;
@property (strong, nonatomic) IBOutlet UIButton *titleArtistButton;
@property (strong, nonatomic) IBOutlet UIButton *skillButton;
@property (strong, nonatomic) IBOutlet UIButton *scoreButton;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
//@property (strong, nonatomic) IBOutlet UILabel *backLabel;
@property (strong, nonatomic) IBOutlet UILabel *songListLabel;

@property (strong, nonatomic) IBOutlet PullToUpdateTableView *songListTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (void) localizeViews;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)practiceButtonClicked:(id)sender;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)closeModalButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)instrumentButtonClicked:(id)sender;
- (IBAction)difficulyButtonClicked:(id)sender;
- (IBAction)blackButtonClicked:(id)sender;
- (IBAction)fullscreenButtonClicked:(id)sender;

- (void)openSongOptionsForSongId:(NSInteger)songId;
- (void)openSongOptionsForSong:(UserSong*)userSong;

@end
