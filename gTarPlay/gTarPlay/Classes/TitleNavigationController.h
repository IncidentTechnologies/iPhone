//
//  TitleNavigationController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <UIKit/UIKit.h>

#import <GtarController/GtarController.h>
#import <GtarController/GtarControllerInternal.h>

#import "Facebook.h"

#import "PullToUpdateTableView.h"

@class SelectorControl;
@class SlidingModalViewController;
@class CyclingTextField;

@interface TitleNavigationController : UIViewController <UITableViewDataSource, PullToUpdateTableViewDelegate, UITextFieldDelegate, GtarControllerObserver, FBSessionDelegate>

// Main
@property (retain, nonatomic) IBOutlet UIView *topBarView;
@property (retain, nonatomic) IBOutlet UIImageView *gtarLogoImage;
@property (retain, nonatomic) IBOutlet UIView *rightPanel;
@property (retain, nonatomic) IBOutlet UIView *leftPanel;
@property (retain, nonatomic) IBOutlet UIView *videoRightPanel;
@property (retain, nonatomic) IBOutlet UILabel *notificationLabel;
@property (retain, nonatomic) IBOutlet UIView *delayLoadingView;
@property (retain, nonatomic) IBOutlet UIImageView *videoPreviewImage;

- (void)delayLoadingComplete;

// Panels
@property (retain, nonatomic) IBOutlet UIView *loggedoutLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *signupRightPanel;
@property (retain, nonatomic) IBOutlet UIView *signinRightPanel;
@property (retain, nonatomic) IBOutlet UIView *gatekeeperLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *menuLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *feedRightPanel;
@property (retain, nonatomic) IBOutlet UIView *loadingRightPanel;
@property (retain, nonatomic) IBOutlet UIView *disconnectedGtarLeftPanel;

// Left Panel buttons + clicks
@property (retain, nonatomic) IBOutlet UIButton *gatekeeperVideoButton;
@property (retain, nonatomic) IBOutlet UIButton *gatekeeperSigninButton;
@property (retain, nonatomic) IBOutlet UIButton *gatekeeperWebsiteButton;

@property (retain, nonatomic) IBOutlet UIButton *loggedoutSignupButton;
@property (retain, nonatomic) IBOutlet UIButton *loggedoutSigninButton;

@property (retain, nonatomic) IBOutlet UIButton *menuPlayButton;
@property (retain, nonatomic) IBOutlet UIButton *menuFreePlayButton;
@property (retain, nonatomic) IBOutlet UIButton *menuStoreButton;

@property (retain, nonatomic) IBOutlet CyclingTextField *signinUsernameText;
@property (retain, nonatomic) IBOutlet CyclingTextField *signinPasswordText;

@property (retain, nonatomic) IBOutlet CyclingTextField *signupUsernameText;
@property (retain, nonatomic) IBOutlet CyclingTextField *signupPasswordText;
@property (retain, nonatomic) IBOutlet CyclingTextField *signupEmailText;

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
@property (retain, nonatomic) IBOutlet PullToUpdateTableView *feedTable;
@property (retain, nonatomic) IBOutlet SelectorControl *feedSelectorControl;

- (IBAction)feedSelectorChanged:(id)sender;

@end
