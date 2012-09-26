//
//  PlayController.h
//  gTar
//
//  Created by Marty Greenia on 2/21/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "ExperienceController.h"
#import "DisplayController.h"
#import "SongModel.h"
#import "PlayControllerProgressView.h"
#import "PlayScoreController.h"
#import "PlayLcdScoreView.h"
#import "PlayLcdMultView.h"
#import "FillGaugeView.h"
#import "TempoRegulator.h"

enum PlayControllerNewAccuracy
{
	NewAccuracyStringOnly = 0,
	NewAccuracyExactNote
};

enum PlayControllerTempo
{
	TempoNone = 0,
	TempoAutoAdjust,
	TempoReal
};

@interface PlayControllerNew : ExperienceController
{
	// Provides the OpenGL main screen
	DisplayController * m_displayController;
	
	// SongModel
	SongModel * m_songModel;
	
	TempoRegulator * m_tempoRegulator;
	
	// State for the song we are playing
	NSString * m_xmpName;
	NSString * m_songName;
	NSString * m_xmpBlob;
	//NSInteger m_tempo;
	PlayControllerTempo m_tempo;
	PlayControllerNewAccuracy m_accuracy;
	bool m_penalty;
	
	// IB connections
	IBOutlet EAGLView * m_glView;
	
	IBOutlet UIView * m_blackView;
	IBOutlet UIView * m_ampView;
	IBOutlet UIView * m_topmenuView;
	IBOutlet UIView * m_menuView;
	IBOutlet UIView * m_scoreView;
//	IBOutlet UIView * m_borderView;
	IBOutlet UIImageView * m_activityIndicator;
	
	IBOutlet PlayControllerProgressView * m_progressView;
	IBOutlet PlayScoreController * m_playScoreController;

	IBOutlet PlayLcdScoreView * m_lcdScoreView;
	IBOutlet PlayLcdMultView * m_lcdMultView;
	IBOutlet FillGaugeView * m_fillGaugeView;

	IBOutlet UILabel * m_titleLabel;
	IBOutlet UIButton * m_menuButton;
	IBOutlet UILabel * m_menuLabel;

	// Misc
	NSInteger m_inputDelayLoops;
	
//	GuitarModel * m_guitarModel;
}

@property (nonatomic, retain) NSString * m_xmpName;
@property (nonatomic, retain) NSString * m_songName;
@property (nonatomic, retain) NSString * m_xmpBlob;
@property (nonatomic, assign) PlayControllerTempo m_tempo;
@property (nonatomic, assign) bool m_penalty;
@property (nonatomic) PlayControllerNewAccuracy m_accuracy;

@property (nonatomic, retain) IBOutlet EAGLView * m_glView;
//@property (nonatomic, retain) IBOutlet UILabel * m_learnInstructionLabel;

@property (nonatomic, retain) IBOutlet UIView * m_blackView;
@property (nonatomic, retain) IBOutlet UIView * m_ampView;
@property (nonatomic, retain) IBOutlet UIView * m_topmenuView;
@property (nonatomic, retain) IBOutlet UIView * m_menuView;
@property (nonatomic, retain) IBOutlet UIView * m_scoreView;
//@property (nonatomic, retain) IBOutlet UIView * m_borderView;
@property (nonatomic, retain) IBOutlet UIImageView * m_activityIndicator;

@property (nonatomic, retain) IBOutlet PlayControllerProgressView * m_progressView;
@property (nonatomic, retain) IBOutlet PlayScoreController * m_playScoreController;

@property (nonatomic, retain) IBOutlet PlayLcdScoreView * m_lcdScoreView;
@property (nonatomic, retain) IBOutlet PlayLcdMultView * m_lcdMultView;
@property (nonatomic, retain) IBOutlet FillGaugeView * m_fillGaugeView;

@property (nonatomic, retain) IBOutlet UILabel * m_titleLabel;
@property (nonatomic, retain) IBOutlet UIButton * m_menuButton;
@property (nonatomic, retain) IBOutlet UILabel * m_menuLabel;

//@property (nonatomic, readonly) GuitarModel * m_guitarModel;

- (IBAction)replayButtonClicked;
- (IBAction)menuButtonClicked;
- (IBAction)menuDoneButtonClicked;

// Main event loop
- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;

- (void)animateModal:(BOOL)popup;
- (void)updateScoreDisplay;
- (void)displayScoreScreen;
- (void)emitBeepSound;

@end
