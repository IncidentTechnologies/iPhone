//
//  EtarLearnPlayTabsViewController.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/1/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EtarLearnPlayTabsView.h"
#import "Song.h"
#import "AudioController.h"
#import "SerialPort.h"
#import "NoteVerifier.h"

#define LEFT_SCREEN_BUFFER 50
#define RIGHT_SCREEN_BUFFER 0
#define TOP_SCREEN_BUFFER 30
#define BOTTOM_SCREEN_BUFFER TOP_SCREEN_BUFFER

#define VIEW_HEIGHT 260
#define VIEW_WIDTH 480

//#define FRAMES_PER_SECOND 20.0
#define FRAMES_PER_SECOND 8.0
#define ANIMATE_BEATS_PER_SECOND (1.0 * tempoScale)
#define ANIMATE_BEATS_PER_FRAME (ANIMATE_BEATS_PER_SECOND / FRAMES_PER_SECOND)

#define BEAT_THRESHOLD 0.15

#define FAILURE_NOTE @"B4"

#define GUITAR_STRINGS 6

enum NoteType {
	TypeNormalNote = 0,
	TypeCurrentNote,
	TypeNextNote	
};

//@class EtarLearnPlayTabsView;
//@interface EtarLearnPlayTabsView : UIView {
//}
//@end

// For some reason, the 3.2 sdk doesn't like the parser delegate. Apparently it is safe to remove...
//@interface EtarLearnPlayTabsViewController : UIViewController <UIGestureRecognizerDelegate> {
@interface EtarLearnPlayTabsViewController : UIViewController <NSXMLParserDelegate, UIGestureRecognizerDelegate, NoteVerifierDelegate>
{
	IBOutlet EtarLearnPlayTabsView * tabView;
	IBOutlet UITextView * consoleView;
	IBOutlet UIButton * tempoButton;
	IBOutlet UIButton * playButton;
	IBOutlet UIButton * easyButton;
	NSMutableArray * song;

	AudioController * audioController;
	NoteVerifier * noteVerifier;
	
	SerialPort * serialPort;
	
	//Display related 
	NSMutableArray * displayElements;
	
	CGFloat maxBeat;
	CGFloat currentBeat;
	NSInteger measureStartIndex;
	NSInteger measureCount;
	NSInteger measureMaxCount;
	
	NSInteger currentNotesIndexStart;
	NSInteger currentNotesCount;
	NSInteger nextNotesIndexStart;
	NSInteger nextNotesCount;
	
	CGFloat pixelsWidth;
	CGFloat pixelsHeight;
	
	CGFloat activePixelsWidth;
	CGFloat activePixelsHeight;
	
	CGFloat beatsPerScreen;
	CGFloat pixelsPerBeat;
	
	CGFloat stringsPerScreen;
	CGFloat pixelsPerString;
	
	// Animation
    NSTimer *animationTimer;
	NSInteger framesRemaining;
	CGFloat beatDeltaPerFrame;
	Boolean continuousPlay;
	CGFloat tempoScale;

	Song * songObj;
	Note * currentNoteObj;
	Measure * currentMeasureObj;
	NSMutableArray * noteObjArray;
	NSMutableArray * displayObjArray;

	NSTimer *serialRxTimer;
	
	Boolean easyMode;
	
	Boolean ghostNotesOn[ GUITAR_STRINGS ];

}

@property (nonatomic, retain) IBOutlet EtarLearnPlayTabsView * tabView;
@property (nonatomic, retain) IBOutlet UITextView * consoleView;
@property (nonatomic, retain) IBOutlet UIButton * tempoButton;
@property (nonatomic, retain) IBOutlet UIButton * playButton;
@property (nonatomic, retain) IBOutlet UIButton * easyButton;
@property (nonatomic, retain) NSMutableArray * song;

@property (nonatomic, retain) NSMutableArray * displayElements;
@property (nonatomic, retain) NSMutableArray * noteObjArray;
@property (nonatomic, retain) NSMutableArray * displayObjArray;

@property (nonatomic, retain) AudioController * audioController;
@property (nonatomic, retain) NoteVerifier * noteVerifier;

//Display
@property (nonatomic) CGFloat maxBeat;
@property (nonatomic) CGFloat currentBeat;
@property (nonatomic) NSInteger measureStartIndex;
@property (nonatomic) NSInteger measureCount;
@property (nonatomic) NSInteger measureMaxCount;
@property (nonatomic) NSInteger currentNotesIndexStart;
@property (nonatomic) NSInteger currentNotesCount;
@property (nonatomic) NSInteger nextNotesIndexStart;
@property (nonatomic) NSInteger nextNotesCount;

@property (nonatomic) CGFloat pixelsWidth;
@property (nonatomic) CGFloat pixelsHeight;
@property (nonatomic) CGFloat activePixelsWidth;
@property (nonatomic) CGFloat activePixelsHeight;
@property (nonatomic) CGFloat beatsPerScreen;
@property (nonatomic) CGFloat pixelsPerBeat;
@property (nonatomic) CGFloat stringsPerScreen;
@property (nonatomic) CGFloat pixelsPerString;

// Animation
@property (nonatomic, retain) NSTimer *animationTimer;
@property (nonatomic) NSInteger framesRemaining;
@property (nonatomic) CGFloat beatDeltaPerFrame;
@property (nonatomic) Boolean continuousPlay;
@property (nonatomic) CGFloat tempoScale;

@property (nonatomic, retain) Song * songObj;
@property (nonatomic, retain) Note * currentNoteObj;
@property (nonatomic, retain) Measure * currentMeasureObj;

@property (nonatomic, retain) NSTimer *serialRxTimer;
@property (nonatomic) Boolean easyMode;

- (void)initDisplayAndStepToActiveNotes;

// XML (XMP) functions
- (void)parseXmp:(NSString*)xmpName;

// Display functions

- (void)initDisplayParameters;
- (CGFloat)convertBeatToPixel:(CGFloat)beatStart;
- (CGFloat)convertAndNormalizeBeatToPixel:(CGFloat)beatStart;
- (CGFloat)convertStringToPixel:(NSInteger)string;
- (void)insertStringLines;
- (void)insertCurrentLine;
- (void)insertMeasureAtBeat:(CGFloat)beat;
- (void)insertBeatAtBeat:(CGFloat)beat;
- (void)insertNote:(Note*)note ofType:(NoteType)type;
- (void)stepToNextActiveNoteGroupIsAnimated:(Boolean)animated;
- (void)stepToBeatAbsolute:(CGFloat)absolute isAnimated:(Boolean)animated;
- (void)stepToBeat:(CGFloat)delta isAnimated:(Boolean)animated;
- (void)stepToPixel:(CGFloat)delta isAnimated:(Boolean)animated;
- (void)findCurrentMeasure;
- (void)convertToDisplayElementsAndDisplay;

// State
//- (NSInteger)findNextNote;
- (NSInteger)findNextNoteAfterBeat:(CGFloat)beat;
- (NSInteger)findNotesCloseToNote:(NSInteger)noteIndex;

// Animation
- (void)eachFrame;
- (void)startAnimation;
- (void)stopAnimation;
- (void)toggleContinuousPlay;

// Button clicks
- (IBAction)pauseButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;
- (IBAction)stepForwardButtonClicked:(id)sender;
- (IBAction)stepBackwardButtonClicked:(id)sender;
- (IBAction)tempoButtonClicked:(id)sender;
- (IBAction)debugButtonClicked:(id)sender;
- (IBAction)easyButtonClicked:(id)sender;

// Gestures
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer;

// External access
- (CGFloat)getPercentCompletion;
- (void)printToConsole:(NSString*)msg;

- (Boolean)getEasyMode;


@end
