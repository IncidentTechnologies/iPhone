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

@interface SongSelectionViewController : UIViewController <PullToUpdateTableViewDelegate> // <UISearchBarDelegate>

@property (retain, nonatomic) IBOutlet UIButton *titleArtistButton;
@property (retain, nonatomic) IBOutlet UIButton *skillButton;
@property (retain, nonatomic) IBOutlet UIButton *scoreButton;

@property (retain, nonatomic) IBOutlet ExpandableSearchBar *searchBar;
@property (retain, nonatomic) IBOutlet PullToUpdateTableView *songListTable;

- (IBAction)backButtonClicked:(id)sender;

@end
