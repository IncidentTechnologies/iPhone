//
//  TitleNavigationController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <UIKit/UIKit.h>

#import "GtarController.h"
#import "GtarControllerInternal.h"
#import <gTarAppCore/Facebook.h>

#import "PaginatedPullToUpdateTableView.h"

#import "SoundMaster.h"

@class SelectorControl;
@class SlidingModalViewController;
@class CyclingTextField;

@interface TitleNavigationController : UIViewController <UITableViewDataSource, PaginatedPullToUpdateTableViewDelegate, UITextFieldDelegate, GtarControllerObserver, GtarControllerDelegate, FBSessionDelegate>

// Audio Controller
@property (strong, nonatomic) SoundMaster *g_soundMaster;

// Main
@property (strong, nonatomic) IBOutlet UIView *topBarView;
@property (strong, nonatomic) IBOutlet UIImageView *gtarLogoImage;
@property (strong, nonatomic) IBOutlet UIView *rightPanel;
@property (strong, nonatomic) IBOutlet UIView *leftPanel;
@property (strong, nonatomic) IBOutlet UIView *videoRightPanel;
@property (strong, nonatomic) IBOutlet UIView *delayLoadingView;
@property (strong, nonatomic) IBOutlet UIImageView *videoPreviewImage;

- (void)delayLoadingComplete;

- (void)localizeView;

// Top bar
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;
@property (strong, nonatomic) UILabel *profileLabel;

- (IBAction)profileButtonClicked:(id)sender;

// Panels
@property (strong, nonatomic) IBOutlet UIView *loggedoutLeftPanel;
@property (strong, nonatomic) IBOutlet UIView *signupRightPanel;
@property (strong, nonatomic) IBOutlet UIView *signinRightPanel;
@property (strong, nonatomic) IBOutlet UIView *gatekeeperLeftPanel;
@property (strong, nonatomic) IBOutlet UIView *menuLeftPanel;
@property (strong, nonatomic) IBOutlet UIView *feedRightPanel;
@property (strong, nonatomic) IBOutlet UIView *loadingRightPanel;

@property (strong, nonatomic) IBOutlet UIView *disconnectedGtarLeftPanel;
@property (strong, nonatomic) IBOutlet UILabel *pleaseConnectLabel;

// Left Panel buttons + clicks
@property (strong, nonatomic) IBOutlet UIButton *signinButton;
@property (strong, nonatomic) IBOutlet UIButton *signupButton;
//@property (retain, nonatomic) IBOutlet UILabel *signInOrLabel;
//@property (retain, nonatomic) IBOutlet UILabel *signUpOrLabel;

@property (strong, nonatomic) IBOutlet UILabel *signInLoginLabel;
@property (strong, nonatomic) IBOutlet UILabel *signUpLoginLabel;

@property (strong, nonatomic) IBOutlet UIButton *gatekeeperVideoButton;
@property (strong, nonatomic) IBOutlet UIButton *gatekeeperSigninButton;
@property (strong, nonatomic) IBOutlet UIButton *gatekeeperWebsiteButton;

@property (strong, nonatomic) IBOutlet UIButton *loggedoutSignupButton;
@property (strong, nonatomic) IBOutlet UIButton *loggedoutSigninButton;

@property (strong, nonatomic) IBOutlet UIButton *menuPlayButton;
@property (strong, nonatomic) IBOutlet UIButton *menuFreePlayButton;
@property (strong, nonatomic) IBOutlet UIButton *menuStoreButton;

@property (strong, nonatomic) IBOutlet CyclingTextField *signinUsernameText;
@property (strong, nonatomic) IBOutlet CyclingTextField *signinPasswordText;

@property (strong, nonatomic) IBOutlet CyclingTextField *signupUsernameText;
@property (strong, nonatomic) IBOutlet CyclingTextField *signupPasswordText;
@property (strong, nonatomic) IBOutlet CyclingTextField *signupEmailText;

- (IBAction)loggedoutSigninButtonClicked:(id)sender;
- (IBAction)loggedoutSignupButtonClicked:(id)sender;

- (IBAction)gatekeeperVideoButtonClicked:(id)sender;
- (IBAction)gatekeeperSigninButtonClicked:(id)sender;
- (IBAction)gatekeeperWebsiteButtonClicked:(id)sender;

- (IBAction)menuPlayButtonClicked:(id)sender;
- (IBAction)menuFreePlayButtonClicked:(id)sender;
- (IBAction)menuStoreButtonClicked:(id)sender;

// Right Panel buttons + clicks
- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)signupFacebookButtonClicked:(id)sender;
- (IBAction)signinButtonClicked:(id)sender;
- (IBAction)signinFacebookButtonClicked:(id)sender;
- (IBAction)videoButtonClicked:(id)sender;

// Feed
@property (strong, nonatomic) IBOutlet PaginatedPullToUpdateTableView *feedTable;
@property (strong, nonatomic) IBOutlet SelectorControl *feedSelectorControl;

- (IBAction)feedSelectorChanged:(id)sender;

@end
