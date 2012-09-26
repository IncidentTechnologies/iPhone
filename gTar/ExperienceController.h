/*
 *  ExperienceController.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#import "GuitarModel.h"
#import "AudioController.h"
#import "DisplayController.h"
#import "gTar.h"
#import "gTarDebug.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

#define AUDIO_CONTROLLER_ATTENUATION 0.985f
#define AUDIO_CONTROLLER_ATTENUATION_INCORRECT 0.80f

@interface ExperienceController : UIViewController
{

	// Where to go when we are done
	UIViewController * m_returnToController;
	
	// Main event loop
	NSTimer * m_eventLoopTimer;
	double m_currentLoopTime;
	double m_previousLoopTime;
	double m_loopTimeDelta;
	double m_loopDelay;
	
	// GuitarModel
	GuitarModel * m_guitarModel;
	gTarDebug * m_debugger;
	gTarDebug * m_clone;
	
	// AudioController
	AudioController * m_audioController;
	
	// DisplayController
	// display controller is instance specific (view, rendering)
	// so it doesn't make sense to have it here.
//	DisplayController * m_displayController;
	
	// debug / testing
	bool m_screenTouched;
	bool m_screenTouchedBad;
	bool m_skipNotes;
	
}

@property (nonatomic, retain) gTarDebug * m_debugger;
@property (nonatomic, retain) gTarDebug * m_clone;

@property (nonatomic, retain) UIViewController * m_returnToController;

@property (nonatomic, retain) GuitarModel * m_guitarModel;
@property (nonatomic, retain) AudioController * m_audioController;
@property (nonatomic, assign) bool m_screenTouched;
@property (nonatomic, assign) bool m_screenTouchedBad;
@property (nonatomic, assign) bool m_skipNotes;
@property (nonatomic, assign) double m_loopTimeDelta;
@property (nonatomic, assign) double m_loopDelay;

// init
- (void)initControllers;
- (void)resetAndRun;

// Button click handling
- (IBAction)backButtonClicked:(id)sender;

// Main event loop
- (void)delayLoop;
- (void)handleDevice;
- (void)advanceModels;
- (void)updateDisplay;

- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;

// Audio
- (void)playNotes:(char*)notes;
- (void)playUglyNotes:(char*)notes;
- (void)playNoteAtString:(char)str andFret:(char)fret;
- (void)playUglyNoteAtString:(char)str andFret:(char)fret;
- (void)playDissonantChord;

// LEDs
- (void)turnOnNotes:(char*)notes;
- (void)turnOnNotesWhite:(char*)notes;
- (void)turnOnNotesColor:(char*)notes;
- (void)turnOnNoteColorAtString:(char)str andFret:(char)fret;
- (void)turnOnNoteWhiteAtString:(char)str andFret:(char)fret;

- (void)turnOnNoteAtString:(char)str andFret:(char)fret;
- (void)turnOnStrings:(char*)notes;
- (void)turnOnString:(char)str;
- (void)turnOffNotes:(char*)notes;
- (void)turnOffNoteAtString:(char)str andFret:(char)fret;
- (void)turnOffStrings:(char*)notes;
- (void)turnOffString:(char)str;

@end
