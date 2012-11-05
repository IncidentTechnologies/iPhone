//
//  RootViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/PopupViewController.h>
#import <gTarAppCore/TransitionRectangleViewController.h>
#import <gTarAppCore/UserController.h>

#import <GtarController/GtarControllerInternal.h>

#import "Facebook.h"
#import "AccountViewController.h"

#import "UserProfileNavigationController.h"

#import "FullScreenDialogViewController.h"
#import "TitleGatekeeperViewController.h"
#import "TitleWelcomeViewController.h"
#import "TitleLoginViewController.h"
#import "TitleSignupViewController.h"
#import "TitleTutorialViewController.h"
#import "TitleFacebookViewController.h"
#import "TitleFirmwareViewController.h"
#import "SongPlayerViewController.h"

@class AccountViewController;

@interface RootViewController : UIViewController <UserProfileNavControllerDelegate, PopupViewControllerDelegate, GtarControllerObserver, FBSessionDelegate, SongPlayerDelegate, GtarControllerDelegate>
{
	
    BOOL m_requireLogin;
    
//    IBOutlet UIView * m_disconnectedDeviceView;
    
    IBOutlet UIView * m_buttonView;
    IBOutlet UIButton * m_button1;
    IBOutlet UIButton * m_button2;
    IBOutlet UIButton * m_button3;
    
    IBOutlet UIView * m_accountContainerView;

    IBOutlet PopupViewController * m_pleaseLoginPopup;
    IBOutlet PopupViewController * m_disconnectedDevicePopup;
    IBOutlet PopupViewController * m_tutorialIndexPopup;
    IBOutlet PopupViewController * m_creditsPopup;
    IBOutlet PopupViewController * m_infoPopup;
    
    IBOutlet UILabel * m_firmwareCurrentVersion;
    IBOutlet UILabel * m_firmwareAvailableVersion;
    IBOutlet UIButton * m_firmwareUpdateButton;
    
    IBOutlet UIImageView * m_gtarLogoRed;
    
    TransitionRectangleViewController * m_tutorialViewController;

    AccountViewController * m_accountViewController;
    
    UserSong * m_displayUserSong;
    
    FullScreenDialogViewController * m_currentFullScreenDialog;
    
    TitleGatekeeperViewController * m_titleGatekeeperViewController;
    TitleWelcomeViewController * m_titleWelcomeViewController;
    TitleLoginViewController * m_titleLoginViewController;
    TitleSignupViewController * m_titleSignupViewController;
    TitleTutorialViewController * m_titleTutorialViewController;
    TitleFacebookViewController * m_titleFacebookViewController;
    TitleFirmwareViewController * m_titleFirmwareViewController;
    
    SongPlayerViewController * m_songPlaybackViewController;
    
    NSInteger m_sequenceFret;
    
    BOOL m_waitingForFacebook;
        
}

//@property (nonatomic, retain) IBOutlet UIView * m_disconnectedDeviceView;

@property (nonatomic, retain) IBOutlet UIView * m_buttonView;
@property (nonatomic, retain) IBOutlet UIButton * m_button1;
@property (nonatomic, retain) IBOutlet UIButton * m_button2;
@property (nonatomic, retain) IBOutlet UIButton * m_button3;

@property (nonatomic, retain) IBOutlet PopupViewController * m_pleaseLoginPopup;
@property (nonatomic, retain) IBOutlet PopupViewController * m_disconnectedDevicePopup;
@property (nonatomic, retain) IBOutlet PopupViewController * m_tutorialIndexPopup;
@property (nonatomic, retain) IBOutlet PopupViewController * m_creditsPopup;
@property (nonatomic, retain) IBOutlet PopupViewController * m_infoPopup;

@property (nonatomic, retain) IBOutlet UILabel * m_firmwareCurrentVersion;
@property (nonatomic, retain) IBOutlet UILabel * m_firmwareAvailableVersion;
@property (nonatomic, retain) IBOutlet UIButton * m_firmwareUpdateButton;

@property (nonatomic, retain) IBOutlet UIImageView * m_gtarLogoRed;

@property (nonatomic, retain) IBOutlet UIView * m_accountContainerView;
@property (nonatomic, readonly) BOOL m_waitingForFacebook;

- (IBAction)playButtonClicked:(id)sender;
- (IBAction)freePlayButtonClicked:(id)sender;
- (IBAction)storeButtonClicked:(id)sender;
- (IBAction)tutorialButtonClicked:(id)sender;
- (IBAction)infoButtonClicked:(id)sender;
- (IBAction)logoutButtonClicked:(id)sender;
- (IBAction)retryButtonClicked:(id)sender;

- (IBAction)welcomeTutorialButtonClicked:(id)sender;
- (IBAction)freePlayTutorialButtonClicked:(id)sender;
- (IBAction)playTutorialButtonClicked:(id)sender;
- (IBAction)storeTutorialButtonClicked:(id)sender;
- (IBAction)creditsButtonClicked:(id)sender;

// misc
- (void)playStartupLightSequence;
- (void)sequenceIteration;

// popups
- (void)displayTutorialIndexPopup;
- (void)displayLoggedOutPopup;
- (void)displayWelcomeTutorialPopup;
- (void)displayFreePlayTutorialPopup;
- (void)displayPlayTutorialPopup;
- (void)displayStoreTutorialPopup;
- (void)displayCreditsPopup;

// full screens
- (void)attachFullScreenDialog:(FullScreenDialogViewController*)dialog;
- (void)returnToPreviousFullScreenDialog;
- (void)displayWelcomeDialog;
- (void)displayLoginDialog;
- (void)displaySignupDialog;
- (void)displayFacebookDialog;
- (void)checkUserLoggedIn;
- (void)userLoggedIn;
- (void)loginCallback:(UserResponse*)userResponse;
- (void)loginToFacebook;

// shortcuts
- (void)accountViewDisplayUserProfile:(UserProfile*)userProfile;
- (void)accountViewDisplayUserSong:(UserSong*)userSong;
- (void)accountViewDisplayUserSongSession:(UserSongSession*)session;

@end
