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
#import "SoundMaster.h"
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

@interface PlayViewController : MainEventController <GtarControllerObserver, NSSongModelDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster;

- (void) localizeViews;

@property (retain, nonatomic) SoundMaster *g_soundMaster;

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
@property (retain, nonatomic) IBOutlet UIImageView *menuDownArrow;

@property (retain, nonatomic) IBOutlet UITextView *loadingLicenseInfo;
@property (retain, nonatomic) IBOutlet UILabel *loadingSongArtist;
@property (retain, nonatomic) IBOutlet UILabel * loadingSongTitle;

@property (retain, nonatomic) IBOutlet UILabel *scoreLabel;

@property (retain, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *songArtistLabel;

@property (retain, nonatomic) IBOutlet UIButton *difficultyButton;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;

@property (retain, nonatomic) IBOutlet UIButton *instrumentButton;
@property (retain, nonatomic) IBOutlet UILabel *instrumentLabel;

@property (retain, nonatomic) IBOutlet UIView *outputView;
@property (retain, nonatomic) IBOutlet UIView *postToFeedView;

@property (retain, nonatomic) IBOutlet UISwitch *outputSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *feedSwitch;

@property (retain, nonatomic) IBOutlet UILabel *scoreTextLabel;
@property (retain, nonatomic) IBOutlet UILabel *outputLabel;
@property (retain, nonatomic) IBOutlet UILabel *auxLabel;
@property (retain, nonatomic) IBOutlet UILabel *speakerLabel;
@property (retain, nonatomic) IBOutlet UILabel *postToFeedLabel;
@property (retain, nonatomic) IBOutlet UILabel *offLabel;
@property (retain, nonatomic) IBOutlet UILabel *onLabel;
@property (retain, nonatomic) IBOutlet UILabel *easyLabel;
@property (retain, nonatomic) IBOutlet UILabel *quitLabel;
@property (retain, nonatomic) IBOutlet UILabel *restartLabel;

@property (nonatomic, assign) enum PlayViewControllerDifficulty difficulty;
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
- (IBAction)difficultyButtonClicked:(id)sender;
- (IBAction)instrumentButtonClicked:(id)sender;

@end
