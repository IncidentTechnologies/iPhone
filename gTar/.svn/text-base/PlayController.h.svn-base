//
//  PlayController.h
//  gTar
//
//  Created by Marty Greenia on 10/18/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GuitarModel.h"
#import "AudioController.h"
#import "SongModel.h"
#import "SaysModel.h"
#import "LessonModel.h"
#import "DisplayController.h"
#import "EAGLView.h"
#import "gTar.h"
#import "gTarDebug.h"
#import "ScoreController.h"
#import "PlayScoreController.h"
#import "SaysScoreController.h"
#import "PlayControllerProgressView.h"
#import "PlayLcdMultView.h"
#import "PlayLcdScoreView.h"
#import "FillGaugeView.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

enum PlayControllerAccuracy
{
	AccuracyStringOnly = 0,
	AccuracyExactNote
};

enum PlayControllerMode
{
	PlayControllerModePlay = 0,
	PlayControllerModeLearn,
	PlayControllerModeSays
};

@interface PlayController : UIViewController
{
	// Misc
	PlayControllerMode m_mode;
	
	NSString * m_xmpName;
	NSString * m_songName;
	NSString * m_xmpBlob;
	NSInteger m_tempo;
	PlayControllerAccuracy m_accuracy;
	UIViewController * m_returnToController;
	
	// Main event loop
	NSTimer * m_eventLoopTimer;
	Boolean isAnimating;
	Boolean m_screenTouched;
	Boolean m_screenTouchedBad;
	double m_currentLoopTime;
	double m_previousLoopTime;
	double m_loopTimeDelta;
	NSInteger m_inputDelayLoops;
	
	// GuitarModel
	GuitarModel * m_guitarModel;
	gTarDebug * m_debugger;
	gTarDebug * m_clone;
	
	// SongModel
	SongModel * m_songModel;
	
	// LessonModel
	LessonModel * m_lessonModel;
	
	// SaysModel
	SaysModel * m_saysModel;
	
	// AudioController
	AudioController * m_audioController;
	
	// DisplayController
	DisplayController * m_displayController;
	
	// ScoreController
	ScoreController * m_scoreController;
	
	// View
	IBOutlet EAGLView * m_glView;
	IBOutlet UILabel * m_learnInstructionLabel;
	IBOutlet UILabel * m_playScoreLabel;
//	IBOutlet UILabel * m_playComboLabel;
//	IBOutlet UILabel * m_playHitsLabel;
	IBOutlet UILabel * m_titleLabel;
	
	IBOutlet UIView * m_blackView;
	IBOutlet UIView * m_ampView;
	IBOutlet UIView * m_topmenuView;
	IBOutlet UIView * m_menuView;
	IBOutlet UIView * m_scoreView;
	IBOutlet UIView * m_borderView;
	IBOutlet UIImageView * m_activityIndicator;
	
	IBOutlet PlayControllerProgressView * m_progressView;
	
	IBOutlet PlayScoreController * m_playScoreController;
	IBOutlet SaysScoreController * m_saysScoreController;
	
	IBOutlet PlayLcdScoreView * m_lcdScoreView;
	IBOutlet PlayLcdMultView * m_lcdMultView;
	IBOutlet FillGaugeView * m_fillGaugeView;
	
	bool m_popupVisible;
	
	bool stepModelForward;
	bool m_skipNotes;
	
}

@property (nonatomic) PlayControllerMode m_mode;
@property (nonatomic, retain) gTarDebug * m_debugger;
@property (nonatomic, retain) gTarDebug * m_clone;
@property (nonatomic, retain) NSString * m_xmpName;
@property (nonatomic, retain) NSString * m_songName;
@property (nonatomic, retain) NSString * m_xmpBlob;
@property (nonatomic) NSInteger m_tempo;
@property (nonatomic) PlayControllerAccuracy m_accuracy;

@property (nonatomic, retain) UIViewController * m_returnToController;
@property (nonatomic, retain) ScoreController * m_scoreController;

@property (nonatomic, retain) IBOutlet EAGLView * m_glView;
@property (nonatomic, retain) IBOutlet UILabel * m_learnInstructionLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_playScoreLabel;
//@property (nonatomic, retain) IBOutlet UILabel * m_playComboLabel;
//@property (nonatomic, retain) IBOutlet UILabel * m_playHitsLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_titleLabel;

@property (nonatomic, retain) IBOutlet UIView * m_blackView;
@property (nonatomic, retain) IBOutlet UIView * m_ampView;
@property (nonatomic, retain) IBOutlet UIView * m_topmenuView;
@property (nonatomic, retain) IBOutlet UIView * m_menuView;
@property (nonatomic, retain) IBOutlet UIView * m_scoreView;
@property (nonatomic, retain) IBOutlet UIView * m_borderView;
@property (nonatomic, retain) IBOutlet UIImageView * m_activityIndicator;

@property (nonatomic, retain) IBOutlet PlayControllerProgressView * m_progressView;

@property (nonatomic, retain) IBOutlet PlayScoreController * m_playScoreController;
@property (nonatomic, retain) IBOutlet SaysScoreController * m_saysScoreController;

@property (nonatomic, retain) IBOutlet PlayLcdScoreView * m_lcdScoreView;
@property (nonatomic, retain) IBOutlet PlayLcdMultView * m_lcdMultView;
@property (nonatomic, retain) IBOutlet FillGaugeView * m_fillGaugeView;



// Button click handling
- (IBAction)backButtonClicked;
- (IBAction)replayButtonClicked;
- (IBAction)menuButtonClicked;
//- (IBAction)replayYesButtonClicked;
//- (IBAction)replayNoButtonClicked;
//- (IBAction)pausePlayButtonClicked;


// Main event loop
- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;

// Helpers
- (void)turnOnNotesWhite:(char*)notes;
- (void)turnOnNotesColor:(char*)notes;
- (void)turnOnNoteWhiteAtString:(char)str andFret:(char)fret;
- (void)turnOnNoteColorAtString:(char)str andFret:(char)fret;
- (void)turnOffNotes:(char*)notes;
- (void)reachedEndOfSong;

- (void)changeDisplayMode:(PlayControllerMode)mode;
- (void)changeDisplayControllerMode;

@end
