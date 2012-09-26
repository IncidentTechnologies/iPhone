/*
 *  ExperienceController.mm
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "ExperienceController.h"

@implementation ExperienceController

@synthesize m_debugger;
@synthesize m_clone;
@synthesize m_returnToController;

@synthesize m_guitarModel;
@synthesize m_audioController;
@synthesize m_screenTouched;
@synthesize m_screenTouchedBad;
@synthesize m_skipNotes;
@synthesize m_loopTimeDelta;
@synthesize m_loopDelay;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self initControllers];
		
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self resetAndRun];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)dealloc
{
	[self stopMainEventLoop];
	
	if ( m_guitarModel != nil )
	{
		[m_guitarModel release];
		m_guitarModel = nil;
	}
	
	if ( m_audioController != nil )
	{
		[m_audioController release];
		m_audioController = nil;
	}
	
//	if ( m_displayController != nil )
//	{
//		[m_displayController release];
//	}
	
	[super dealloc];
	
}

- (void)initControllers
{
	// AudioController
	if ( m_audioController == nil )
	{
		m_audioController = [[AudioController alloc] init];
		
		// TODO: dynamic Attenuation and Freq
		[m_audioController SetAttentuation:AUDIO_CONTROLLER_ATTENUATION];
		[m_audioController initializeAUGraph:600.0f withWaveform:3];
		[m_audioController startAUGraph];
	}
	
	// GuitarModel
	if ( m_guitarModel == nil )
	{
		if ( m_debugger != nil && m_clone == nil )
		{
			m_guitarModel = [[GuitarModel alloc] initWithDebugger:m_debugger];
		}
		else if ( m_debugger == nil && m_clone != nil )
		{
			m_guitarModel = [[GuitarModel alloc] initWithClone:m_clone];
		}
		else if ( m_debugger != nil && m_clone != nil )
		{
			m_guitarModel = [[GuitarModel alloc] initWithDebugger:m_debugger andClone:m_clone];
		}
		else
		{
			m_guitarModel = [[GuitarModel alloc] init];
		}
	}
	
	// DisplayController
//	if ( m_displayController == nil )
//	{
//		m_displayController = [[DisplayController alloc] initWithView:m_glView];
//	}
	
}

- (void)resetAndRun
{
	
	// Various init
	m_screenTouched = NO;
	m_screenTouchedBad = NO;
	
	// Main event loop	
	//m_currentLoopTime = CACurrentMediaTime();	
	
	[self startMainEventLoop];
	
}

#pragma mark  -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	CGPoint point = [touch locationInView:self.view];
	
	// this provides a way to input 'wrong' input
	if ( point.x < 200 )
	{
		m_screenTouchedBad = YES;
	}
	else
	{
		m_screenTouched = YES;
	}
	
	m_skipNotes = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Empty 
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Empty 
}


#pragma mark -
#pragma mark Button click handling

- (IBAction)backButtonClicked:(id)sender
{
	[self stopMainEventLoop];
	
	[m_guitarModel disableState];
	
	[m_guitarModel turnOffAllLeds];
	
	//NSInteger count = [self retainCount];
	
	[self.navigationController popToViewController:m_returnToController animated:YES];
}

#pragma mark -
#pragma mark Main event loop

- (void)delayLoop
{
	// "pure virtual"
}

- (void)handleDevice
{
	// "pure virtual"
}

- (void)advanceModels
{
	// "pure virtual"
}

- (void)updateDisplay
{
	// "pure virtual"
}

- (void)mainEventLoop
{
	
	//
	// Handle the time accounting
	//
	//m_previousLoopTime = m_currentLoopTime;
	//m_currentLoopTime = CACurrentMediaTime();
	
	// Use a fixed loop time instead of actually tracking time.
	// This works better if there is every any lagginess 
	m_loopTimeDelta = SECONDS_PER_EVENT_LOOP;

	if ( m_loopDelay > 0.0 )
	{
		[self delayLoop];
		
		return;
	}

	// these can (should) be replaced in subclasses
	[self handleDevice];
	
	[self advanceModels];
	
	[self updateDisplay];
	
	m_screenTouched = NO;
	m_screenTouchedBad = NO;
	
}

- (void)startMainEventLoop
{
	if ( m_eventLoopTimer != nil )
	{
		[self stopMainEventLoop];
	}
	
	m_eventLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)SECONDS_PER_EVENT_LOOP target:self selector:@selector(mainEventLoop) userInfo:nil repeats:TRUE];
}

- (void)stopMainEventLoop
{
	if ( m_eventLoopTimer != nil )
	{
		[m_eventLoopTimer invalidate];
	
		m_eventLoopTimer = nil;
	}
}

#pragma mark -
#pragma mark Helper functions
#pragma mark Audio functions

- (void)playNotes:(char*)notes
{
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self playNoteAtString:str andFret:notes[str]];
		}
	}
}

- (void)playUglyNotes:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self playUglyNoteAtString:str andFret:notes[str]];
		}
	}

}

- (void)playNoteAtString:(char)str andFret:(char)fret
{

	[m_audioController SetAttentuation:AUDIO_CONTROLLER_ATTENUATION];
	
	[m_audioController PluckStringFret:str atFret:fret];

//	usleep( GTAR_GUITAR_MESSAGE_DELAY );
}

- (void)playUglyNoteAtString:(char)str andFret:(char)fret
{
	
	[m_audioController SetAttentuation:AUDIO_CONTROLLER_ATTENUATION_INCORRECT];

	[m_audioController PluckStringFret:str atFret:fret];

//	usleep( GTAR_GUITAR_MESSAGE_DELAY );

}

- (void)playDissonantChord
{
	unsigned int randString = rand() % 5 + 1;
	unsigned int randFret = rand() % 8 + 1;

	[m_audioController PluckStringFret:randString atFret:randFret];

}

#pragma mark Visual functions

- (void)turnOnNotes:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOnNoteAtString:str andFret:notes[str]];
		}
	}
}
- (void)turnOnNotesWhite:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOnNoteWhiteAtString:str andFret:notes[str]];
		}
	}
}

- (void)turnOnNotesColor:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOnNoteColorAtString:str andFret:notes[str]];
		}
	}
}

-(void)turnOnNoteColorAtString:(char)str andFret:(char)fret
{
	
	//m_guitarModel->TurnOnLed( str, fret );
	[m_guitarModel turnOnLedColorString:str andFret:fret];
	usleep( GTAR_GUITAR_MESSAGE_DELAY );
	
}

-(void)turnOnNoteWhiteAtString:(char)str andFret:(char)fret
{
	
	//m_guitarModel->TurnOnLed( str, fret );
	[m_guitarModel turnOnLedWhiteString:str andFret:fret];
	usleep( GTAR_GUITAR_MESSAGE_DELAY );
	
}

- (void)turnOnNoteAtString:(char)str andFret:(char)fret
{
	
	[m_guitarModel turnOnLedString:str andFret:fret];
	// TODO: the device can't handle too many of these at the moment.
	// The faster proc might be able to later, slow things down a bit for now.
	usleep( 10000 );
	
}

- (void)turnOnStrings:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOnString:str];
		}
	}
}

- (void)turnOnString:(char)str
{
	
	for ( unsigned int fret = 0; fret < GUITAR_MODEL_FRET_COUNT; fret++ )
	{
		[self turnOnNoteAtString:str andFret:fret];
	}		
}


- (void)turnOffNotes:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOffNoteAtString:str andFret:notes[str]];
		}
	}
}

- (void)turnOffNoteAtString:(char)str andFret:(char)fret
{
	
	//m_guitarModel->TurnOffLed( str, fret );
	[m_guitarModel turnOffLedString:str andFret:fret];
	usleep( 10000 );
	
}

- (void)turnOffStrings:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOffString:str];
		}
	}
}

- (void)turnOffString:(char)str
{
	
	for ( unsigned int fret = 0; fret < GUITAR_MODEL_FRET_COUNT; fret++ )
	{
		[self turnOffNoteAtString:str andFret:fret];
	}		
}

@end