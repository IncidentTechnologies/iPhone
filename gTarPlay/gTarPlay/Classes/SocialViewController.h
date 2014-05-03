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
#import "SoundMaster.h"

@class SelectorControl;

@interface SocialViewController : UIViewController <PaginatedPullToUpdateTableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ExpandableSearchBarDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) SoundMaster * g_soundMaster;

@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) IBOutlet SelectorControl *feedSelector;
@property (strong, nonatomic) IBOutlet PaginatedPullToUpdateTableView *feedTable;
@property (strong, nonatomic) IBOutlet UITableView *searchTable;
//@property (retain, nonatomic) IBOutlet UIButton *fullscreenButton;
@property (strong, nonatomic) IBOutlet ExpandableSearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UIImageView *picImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) IBOutlet UIButton *followingButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@property (strong, nonatomic) IBOutlet UILabel *profileLabel;
@property (strong, nonatomic) IBOutlet UILabel *backLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)profileButtonClicked:(id)sender;
- (IBAction)accountButtonClicked:(id)sender;
- (IBAction)changePicButtonClicked:(id)sender;
- (IBAction)followButtonClicked:(id)sender;
- (IBAction)followingButtonClicked:(id)sender;
- (IBAction)feedSelectorChanged:(id)sender;
//- (IBAction)fullscreenButtonClicked:(id)sender;

- (void)localizeViews;

@end
