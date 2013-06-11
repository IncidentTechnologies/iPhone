//
//  SocialViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/12/13.
//
//

#import <UIKit/UIKit.h>

#import "PaginatedPullToUpdateTableView.h"
#import "ExpandableSearchBar.h"

@class SelectorControl;

@interface SocialViewController : UIViewController <PaginatedPullToUpdateTableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ExpandableSearchBarDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIView *topBar;
@property (retain, nonatomic) IBOutlet UIButton *profileButton;
@property (retain, nonatomic) IBOutlet SelectorControl *feedSelector;
@property (retain, nonatomic) IBOutlet PaginatedPullToUpdateTableView *feedTable;
@property (retain, nonatomic) IBOutlet UITableView *searchTable;
@property (retain, nonatomic) IBOutlet UIButton *fullscreenButton;
@property (retain, nonatomic) IBOutlet ExpandableSearchBar *searchBar;

@property (retain, nonatomic) IBOutlet UIImageView *picImageView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *cameraButton;
@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain, nonatomic) IBOutlet UIButton *followingButton;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)profileButtonClicked:(id)sender;
- (IBAction)accountButtonClicked:(id)sender;
- (IBAction)changePicButtonClicked:(id)sender;
- (IBAction)followButtonClicked:(id)sender;
- (IBAction)followingButtonClicked:(id)sender;
- (IBAction)feedSelectorChanged:(id)sender;
- (IBAction)fullscreenButtonClicked:(id)sender;

@end
