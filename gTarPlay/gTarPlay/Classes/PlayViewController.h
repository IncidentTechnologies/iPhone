//
//  PlayViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import "GtarController.h"
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster isStandalone:(BOOL)standalone;

- (void) localizeViews;

@property (strong, nonatomic) SoundMaster *g_soundMaster;


@property (strong, nonatomic) IBOutlet EAGLView *glView;
@property (strong, nonatomic) IBOutlet UIView *menuView;
@property (strong, nonatomic) IBOutlet UIView *songScoreView;
@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (strong, nonatomic) IBOutlet UIView *progressFillView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;

@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *volumeButton;
@property (strong, nonatomic) IBOutlet UIButton *pauseButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) IBOutlet UIButton *finishRestartButton;
@property (strong, nonatomic) IBOutlet UIView *volumeSliderView;
@property (strong, nonatomic) IBOutlet UIImageView *menuDownArrow;

@property (strong, nonatomic) IBOutlet UITextView *loadingLicenseInfo;
@property (strong, nonatomic) IBOutlet UILabel *loadingSongArtist;
@property (strong, nonatomic) IBOutlet UILabel * loadingSongTitle;

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *multiplierTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *subscoreLabel;

@property (strong, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *songArtistLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreSongTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreSongArtistLabel;

@property (strong, nonatomic) IBOutlet UILabel *scoreScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreNotesHitLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreInARowLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreAccuracyLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreScore;
@property (strong, nonatomic) IBOutlet UILabel *scoreNotesHit;
@property (strong, nonatomic) IBOutlet UILabel *scoreInARow;
@property (strong, nonatomic) IBOutlet UILabel *scoreAccuracy;
@property (strong, nonatomic) IBOutlet UIView *heatMapView;

@property (strong, nonatomic) IBOutlet UIButton *difficultyButton;
@property (strong, nonatomic) IBOutlet UIButton *scoreDifficultyButton;
@property (strong, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreDifficultyLabel;

@property (strong, nonatomic) IBOutlet UIButton *instrumentButton;
@property (strong, nonatomic) IBOutlet UILabel *instrumentLabel;

@property (strong, nonatomic) IBOutlet UIView *outputView;
@property (strong, nonatomic) IBOutlet UIView *postToFeedView;

@property (strong, nonatomic) IBOutlet UISwitch *outputSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *feedSwitch;

@property (strong, nonatomic) IBOutlet UILabel *outputLabel;
@property (strong, nonatomic) IBOutlet UILabel *auxLabel;
@property (strong, nonatomic) IBOutlet UILabel *speakerLabel;
@property (strong, nonatomic) IBOutlet UILabel *postToFeedLabel;
@property (strong, nonatomic) IBOutlet UILabel *offLabel;
@property (strong, nonatomic) IBOutlet UILabel *onLabel;
@property (strong, nonatomic) IBOutlet UILabel *easyLabel;
@property (strong, nonatomic) IBOutlet UILabel *quitLabel;
@property (strong, nonatomic) IBOutlet UILabel *restartLabel;

@property (strong, nonatomic) IBOutlet UIButton *fretOne;
@property (strong, nonatomic) IBOutlet UIButton *fretTwo;
@property (strong, nonatomic) IBOutlet UIButton *fretThree;

@property (nonatomic, weak) NSNoteFrame * lastTappedFrame;
@property (nonatomic, assign) enum PlayViewControllerDifficulty difficulty;
@property (nonatomic, assign) double tempoModifier;
@property (nonatomic, assign) BOOL muffleWrongNotes;
@property (nonatomic, strong) UserSong *userSong;

//@property (nonatomic, retain) IBOutlet EAGLView * m_glView;
//@property (nonatomic, retain) IBOutlet UIView * m_connectingView;
//@property (nonatomic, retain) IBOutlet UIView * m_backgroundView;
//@property (nonatomic, retain) IBOutlet UITextView * m_licenseInfoView;
//@property (nonatomic, retain) IBOutlet UILabel * m_songTitle;
//@property (nonatomic, retain) IBOutlet UILabel * m_artistTitle;

- (IBAction)menuButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)pauseButtonClicked:(id)sender;
- (IBAction)volumeButtonClicked:(id)sender;
- (IBAction)finishButtonClicked:(id)sender;
- (IBAction)restartButtonClicked:(id)sender;
- (IBAction)outputSwitchChanged:(id)sender;
- (IBAction)feedSwitchChanged:(id)sender;
- (IBAction)difficultyButtonClicked:(id)sender;
- (IBAction)instrumentButtonClicked:(id)sender;

- (IBAction)fretDown:(id)sender;
- (IBAction)fretUp:(id)sender;

@end
