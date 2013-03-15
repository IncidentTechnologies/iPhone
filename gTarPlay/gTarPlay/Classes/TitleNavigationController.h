//
//  TitleNavigationController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <UIKit/UIKit.h>

#import "PullToUpdateTableView.h"

@class SelectorControl;
@class SlidingModalViewController;

@interface TitleNavigationController : UIViewController <UITableViewDataSource, PullToUpdateTableViewDelegate, UITextFieldDelegate>

// Main
@property (retain, nonatomic) IBOutlet UIView *topBarView;
@property (retain, nonatomic) IBOutlet UIImageView *gtarLogoImage;
@property (retain, nonatomic) IBOutlet UIView *rightPanel;
@property (retain, nonatomic) IBOutlet UIView *leftPanel;
@property (retain, nonatomic) IBOutlet UIView *learnMoreRightPanel;

// Modal
@property (retain, nonatomic) IBOutlet SlidingModalViewController *activityFeedModal;

// Panels
@property (retain, nonatomic) IBOutlet UIView *loggedoutLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *signupRightPanel;
@property (retain, nonatomic) IBOutlet UIView *signinRightPanel;
@property (retain, nonatomic) IBOutlet UIView *gatekeeperLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *menuLeftPanel;
@property (retain, nonatomic) IBOutlet UIView *feedRightPanel;

// Left Panel buttons / clicks

@property (retain, nonatomic) IBOutlet UIButton *gatekeeperLearnMoreButton;
@property (retain, nonatomic) IBOutlet UIButton *gatekeeperSigninButton;

@property (retain, nonatomic) IBOutlet UIButton *loggedoutSignupButton;
@property (retain, nonatomic) IBOutlet UIButton *loggedoutSigninButton;

@property (retain, nonatomic) IBOutlet UIButton *menuPlayButton;
@property (retain, nonatomic) IBOutlet UIButton *menuFreePlayButton;
@property (retain, nonatomic) IBOutlet UIButton *menuStoreButton;

- (IBAction)loggedoutSigninButtonClicked:(id)sender;
- (IBAction)loggedoutSignupButtonClicked:(id)sender;

- (IBAction)gatekeeperLearnMoreButtonClicked:(id)sender;
- (IBAction)gatekeeperSigninButtonClicked:(id)sender;

- (IBAction)menuPlayButtonClicked:(id)sender;
- (IBAction)menuFreePlayButtonClicked:(id)sender;
- (IBAction)menuStoreButtonClicked:(id)sender;

// Right Panel buttons / clicks

- (IBAction)signupButtonClicked:(id)sender;
- (IBAction)signupFacebookButtonClicked:(id)sender;
- (IBAction)signinButtonClicked:(id)sender;
- (IBAction)signinFacebookButtonClicked:(id)sender;

// Feed
@property (retain, nonatomic) IBOutlet UITableView *feedTable;
@property (retain, nonatomic) IBOutlet SelectorControl *feedSelectorControl;

- (IBAction)feedSelectorChanged:(id)sender;

@end
