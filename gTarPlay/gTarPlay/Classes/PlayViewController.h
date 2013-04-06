//
//  PlayViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import <GtarController/GtarController.h>
#import <AudioController/AudioController.h>

//#import <gTarAppCore/AppCore.h>
#import <gTarAppCore/MainEventController.h>
#import <gTarAppCore/NSSongModel.h>

@class EAGLView;
@class UserSong;

//@class GuitarController;
//
//@class XmlDom;
//@class NSSong;
//@class SongRecorder;
//@class NSScoreTracker;
//@class NSNoteFrame;
//@class SongDisplayController;
//@class CloudCache;
//@class SongProgressViewController;
//@class UserSongSession;
//@class UserResponse;

enum PlayViewControllerDifficulty
{
    PlayViewControllerDifficultyEasy,
    PlayViewControllerDifficultyMedium,
    PlayViewControllerDifficultyHard
};

@interface PlayViewController : MainEventController <GtarControllerObserver, NSSongModelDelegate, AudioControllerDelegate>

@property (retain, nonatomic) IBOutlet EAGLView *glView;
@property (retain, nonatomic) IBOutlet UIView *menuView;
@property (retain, nonatomic) IBOutlet UIView *topBar;
@property (retain, nonatomic) IBOutlet UIView *progressFillView;
@property (retain, nonatomic) IBOutlet UIView *loadingView;

@property (retain, nonatomic) IBOutlet UIButton *menuButton;
@property (retain, nonatomic) IBOutlet UIButton *volumeButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *finishButton;
@property (retain, nonatomic) IBOutlet UIView *volumeSliderView;

@property (retain, nonatomic) IBOutlet UITextView *loadingLicenseInfo;
@property (retain, nonatomic) IBOutlet UILabel *loadingSongInfo;

@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;

@property (retain, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (retain, nonatomic) IBOutlet UILabel *completionLabel;

@property (retain, nonatomic) IBOutlet UIButton *difficultyButton;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;

@property (retain, nonatomic) IBOutlet UIButton *instrumentButton;
@property (retain, nonatomic) IBOutlet UILabel *instrumentLabel;

@property (retain, nonatomic) IBOutlet UIView *outputView;
@property (retain, nonatomic) IBOutlet UIView *postToFeedView;

@property (retain, nonatomic) IBOutlet UISwitch *outputSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *feedSwitch;


@property (nonatomic, assign) PlayViewControllerDifficulty difficulty;
@property (nonatomic, assign) double tempoModifier;
@property (nonatomic, assign) BOOL muffleWrongNotes;
@property (nonatomic, retain) UserSong *userSong;

//@property (nonatomic, retain) IBOutlet EAGLView * m_glView;
//@property (nonatomic, retain) IBOutlet UIView * m_connectingView;
//@property (nonatomic, retain) IBOutlet UIView * m_backgroundView;
//@property (nonatomic, retain) IBOutlet UITextView * m_licenseInfoView;
//@property (nonatomic, retain) IBOutlet UILabel * m_songTitle;
//@property (nonatomic, retain) IBOutlet UILabel * m_artistTitle;

- (IBAction)menuButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)finishButtonClicked:(id)sender;
- (IBAction)restartButtonClicked:(id)sender;
- (IBAction)outputSwitchChanged:(id)sender;
- (IBAction)feedSwitchChanged:(id)sender;

@end
