//
//  SongSelectionViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/21/13.
//
//

#import <UIKit/UIKit.h>

#import "PullToUpdateTableView.h"
#import "ExpandableSearchBar.h"

@class PlayerViewController;
@class SlidingModalViewController;

@interface SongSelectionViewController : UIViewController <PullToUpdateTableViewDelegate> // <UISearchBarDelegate>

@property (retain, nonatomic) IBOutlet SlidingModalViewController *songOptionsModal;

@property (retain, nonatomic) IBOutlet UIButton *titleArtistButton;
@property (retain, nonatomic) IBOutlet UIButton *skillButton;
@property (retain, nonatomic) IBOutlet UIButton *scoreButton;

@property (retain, nonatomic) IBOutlet ExpandableSearchBar *searchBar;
@property (retain, nonatomic) IBOutlet PullToUpdateTableView *songListTable;

@property (retain, nonatomic) IBOutlet UIButton *closeModalButton;
@property (retain, nonatomic) IBOutlet UIButton *volumeButton;
@property (retain, nonatomic) IBOutlet UIButton *instrumentButton;

@property (retain, nonatomic) IBOutlet UIButton *easyButton;
@property (retain, nonatomic) IBOutlet UIButton *mediumButton;
@property (retain, nonatomic) IBOutlet UIButton *hardButton;

@property (retain, nonatomic) IBOutlet UIView *volumeView;
@property (retain, nonatomic) IBOutlet UIView *songPlayerView;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)closeModalButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)instrumentButtonClicked:(id)sender;
- (IBAction)difficulyButtonClicked:(id)sender;


@end
