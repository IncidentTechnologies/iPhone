//
//  PlayController.m
//  gTar
//
//  Created by Marty Greenia on 10/18/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "PlayController.h"
#import "PlayScoreController.h"
#import "LearnScoreController.h"
#import "SaysScoreController.h"

@implementation PlayController

@synthesize m_mode;
@synthesize m_debugger;
@synthesize m_clone;
@synthesize m_xmpBlob;
@synthesize m_songName;
@synthesize m_tempo;
@synthesize m_accuracy;
@synthesize m_returnToController;
@synthesize m_scoreController;
@synthesize m_glView;
@synthesize m_learnInstructionLabel;
@synthesize m_playScoreLabel;
@synthesize m_titleLabel;
@synthesize m_blackView;
@synthesize m_ampView;
@synthesize m_topmenuView;
@synthesize m_menuView;
@synthesize m_scoreView;
@synthesize m_playScoreController;
@synthesize m_saysScoreController;
@synthesize m_progressView;
@synthesize m_borderView;
@synthesize m_activityIndicator;
@synthesize m_lcdScoreView, m_lcdMultView, m_fillGaugeView;

#define AMP_HEIGHT (90.0)

-(void)initControllers
{
	// AudioController
	if ( m_audioController == nil )
	{
		m_audioController = [[AudioController alloc] init];
		
		// TODO: dynamic Attenuation and Freq
		[m_audioController SetAttentuation:0.985f];
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
	if ( m_displayController == nil )
	{
		m_displayController = [[DisplayController alloc] initWithView:m_glView];
	}
	
	
	// SongModel
	if ( m_songModel == nil && m_mode == PlayControllerModePlay )
	{
		
		m_songModel = new SongModel( m_xmpBlob );
		
		NoteArray * noteArray = m_songModel->GetNoteArray();
		MeasureArray * measureArray = m_songModel->GetMeasureArray();
		
		[m_displayController createPlayObjectWithStringCount:GTAR_GUITAR_STRING_COUNT notes:noteArray andMeasures:measureArray];
		
		[m_progressView setNoteArray:noteArray];
		[m_progressView setMeasureArray:measureArray];
	}
	
	// LessonModel
	if ( m_lessonModel == nil && m_mode == PlayControllerModeLearn )
	{
		
		m_lessonModel = [[LessonModel alloc] init];
		m_accuracy = AccuracyExactNote;
		
		[m_displayController createLearnObject];
		
	}
	
	// SaysModel
	if ( m_saysModel == nil && m_mode == PlayControllerModeSays )
	{

		m_songModel = new SongModel( m_xmpBlob );

		m_saysModel = [[SaysModel alloc] initWithSongModel:m_songModel];
		
		[m_displayController createSaysObject];
		
	}
	
}

-(void)prepareToRun
{
	
	[self changeDisplayControllerMode];
	
	// Various init
	m_screenTouched = NO;
	m_screenTouchedBad = NO;
	
	// Init
	if ( m_mode == PlayControllerModePlay )
	{
		
		m_songModel->StartModelAtTime(0);

		m_songModel->ResetScore();
		
		if ( m_tempo > 0 )
		{
			char upcomingNotes[ GUITAR_MODEL_STRING_COUNT ];

			m_songModel->GetUpcomingNotesBytes( upcomingNotes );
		
			[self turnOnNotesColor:upcomingNotes];
		}
		
		// turn on leds if there are already target notes
		if ( m_songModel->TargetNotesRemaining() > 0 )
		{
			char targetNotes[ GUITAR_MODEL_STRING_COUNT ];
			
			m_songModel->GetTargetNotesBytes( targetNotes );
			
			if ( m_tempo > 0 )
			{
				[self turnOnNotesWhite:targetNotes];
			}
			else 
			{				
				[self turnOnNotesColor:targetNotes];
			}
		}

		[m_lcdMultView clearDigits];
		[m_lcdScoreView clearDigits];
		
		[self updatePlayLabels];
		
	}
	else if ( m_mode == PlayControllerModeLearn )
	{
		
		[m_lessonModel startModelOnChapter:1];
		
		char targetNotes[ GTAR_GUITAR_STRING_COUNT ];
		
		[m_lessonModel getTargetNotes:targetNotes];
		
		[m_displayController.m_learnObject setTargetNotes:targetNotes];
		
		[self turnOnNotesColor:targetNotes];
		
		[self updateLearnLabels];			
	}		
	else if ( m_mode == PlayControllerModeSays )
	{
		
		[m_saysModel resetModel];
		
		[m_displayController.m_saysObject focusReset];

	}
	
	// Main event loop	
	m_currentLoopTime = CACurrentMediaTime();	
	
	[self startMainEventLoop];
	
	
}

-(void)viewDidLoad
{
    [super viewDidLoad];

	[self initControllers];

	// put the menue view under the border 
	[self.view addSubview:m_topmenuView];
	//[self.view insertSubview:m_topmenuView aboveSubview:m_glView];
	
	//m_ampView.frame = CGRectMake(0, self.view.frame.size.height - AMP_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);

	// now layer the rest of the views on top of the border
	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;
	m_ampView.transform = CGAffineTransformMakeTranslation( 0, height );

	[self.view addSubview:m_blackView];
	
	[self.view addSubview:m_ampView];
	
	[m_titleLabel setText:m_songName];
	
	[m_lcdMultView initDigits];
	[m_lcdScoreView initDigits];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self prepareToRun];
		
}

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

-(void)dealloc
{
	[self stopMainEventLoop];
	
	if ( m_guitarModel != nil )
	{
		[m_guitarModel release];
	}
	
	if ( m_songModel != NULL )
	{
		delete m_songModel;
	}
	
	if ( m_lessonModel != nil )
	{
		[m_lessonModel release];
	}
	
	if ( m_lessonModel != nil )
	{
		[m_audioController release];
	}
	
	if ( m_displayController != nil )
	{
		[m_displayController release];
	}
	
	[super dealloc];
	
}

#pragma mark  -
#pragma mark Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	CGPoint point = [touch locationInView:self.view];
	

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

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Empty 
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Empty 
}


#pragma mark -
#pragma mark Button click handling

-(IBAction)backButtonClicked
{
	[self stopMainEventLoop];
	
	[self.navigationController popToViewController:m_returnToController animated:YES];
}

-(IBAction)replayButtonClicked
{

	// add the replay view button?
	[self prepareToRun];

	[self animateModal:NO];
	
	// remove any views that might have been added
	[m_menuView removeFromSuperview];
	[m_playScoreController.view removeFromSuperview];
	[m_saysScoreController.view removeFromSuperview];


}

-(IBAction)menuButtonClicked
{
	// if we are paused
	if ( m_eventLoopTimer == nil )
	{
		[self animateModal:YES];
		
		[self startMainEventLoop];
		
		[m_menuView removeFromSuperview];
	}
	else 
	{
		[m_scoreView addSubview:m_menuView];
		
		[self stopMainEventLoop];
		
		[self animateModal:NO];
	}

}

/*
-(IBAction)replayYesButtonClicked
{
	// is this animation blocking?
	[self animateModal:NO];

	[self prepareToRun];
}

-(IBAction)replayNoButtonClicked
{	
	[self animateModal:YES];	
	
	[self stopMainEventLoop];
}

-(IBAction)pausePlayButtonClicked
{
	// if we are paused
	if ( m_eventLoopTimer == nil )
	{
		[self startMainEventLoop];
	}
	else 
	{
		[self stopMainEventLoop];
	}
	
}
 */

#pragma mark -
#pragma mark Main event loop

-(void)handleDevice
{
	
	//
	// Get any new input from the device 
	//
	char previousFretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char previousNotesOn[ GUITAR_MODEL_STRING_COUNT ];
	
	char currentFretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char currentNotesOn[ GUITAR_MODEL_STRING_COUNT ];
	
	[m_guitarModel getFretsDown:previousFretsDown];
	//m_guitarModel->GetFretsDown( previousFretsDown );
	[m_guitarModel getNotesOn:previousNotesOn];
	//m_guitarModel->GetNotesOn( previousNotesOn );
	
	//m_guitarModel->HandleDeviceOutput();
	[m_guitarModel handleDeviceOutput];
	
	[m_guitarModel getFretsDown:currentFretsDown];
	//m_guitarModel->GetFretsDown( currentFretsDown );
	[m_guitarModel getNotesOn:currentNotesOn];
	//m_guitarModel->GetNotesOn( currentNotesOn );
	
	
	if ( m_skipNotes == YES ) 
	{
		m_skipNotes = NO;
		
		if ( m_mode == PlayControllerModePlay )
		{
			m_songModel->GetUnHitTargetNotesBytes( currentNotesOn );
		}
		else if ( m_mode == PlayControllerModeLearn )
		{
			[m_lessonModel getTargetNotes:currentNotesOn];
		}
		else if ( m_mode == PlayControllerModeSays )
		{
			m_saysModel.m_songModel->GetUnHitTargetNotesBytes( currentNotesOn );
		}

	}

	// make the notes failure notes, fret 99 that doesn't exist.
	if ( m_screenTouchedBad == YES )
	{
		char failNotes[ GUITAR_MODEL_STRING_COUNT ] = { 99, 99, 99, 99, 99, 99 };
		memcpy( currentNotesOn, failNotes, GUITAR_MODEL_STRING_COUNT );
	}
		
	// we skip handling input for a few loops
	// to avoid awkwardness
	if ( m_inputDelayLoops > 0 )
	{
		m_inputDelayLoops--;
		
		return;
	}
	
	// flash the indicator light to show whats going on
	[m_activityIndicator setHidden:YES];
	
	//
	// Target Note hit testing
	// Compare the device output to the song model.
	// Send output to the Audio controller as appropriate.
	//
	for ( unsigned int i = 0; i < GUITAR_MODEL_STRING_COUNT; i++ )
	{
		//
		// Look for note deltas ('edge triggered')
		//
//		if ( currentNotesOn[i] != GTAR_GUITAR_NOTE_OFF &&
//			currentNotesOn[i] != previousNotesOn[i] )
		if ( currentNotesOn[i] != GTAR_GUITAR_NOTE_OFF )
		{
			int str = i;
			int fret = currentNotesOn[i];
			
#pragma mark Play Mode input handle
			if ( m_mode == PlayControllerModePlay )
			{
				
				// flash the indicator light to show whats going on
				[m_activityIndicator setHidden:NO];
				
				//if ( m_songModel->IsTargetNote( str, fret ) )
				if ( m_accuracy == AccuracyExactNote )
				{
					
					if ( m_songModel->HitTestNote( str , fret ) )
					{
						// Send output to the AC
						[m_audioController PluckStringFret:str atFret:fret];
						
						// Turn off the LED for this note
						[self turnOffNoteAtString:str andFret:fret];
						
					}
					else
					{
						// Note was wrong, play a funny sound?
					}
				}
				else if ( m_accuracy == AccuracyStringOnly )
				{
					
					char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
					
					m_songModel->GetUnHitTargetNotesBytes( unHitNotes );
					
					if ( m_songModel->HitTestString( str ) )
					{
						// Send output to the AC
						[m_audioController PluckStringFret:str atFret:unHitNotes[str]];
						
						// Turn off the LED for this note
						//[self  turnOffString:str];
						[self turnOffNoteAtString:str andFret:unHitNotes[str]];
						
					}
					else
					{
						// Note was wrong, play a funny sound?
					}
					
				}
				
			}
#pragma mark Learn Mode input handle
			else if ( m_mode == PlayControllerModeLearn )
			{
				//if ( m_songModel->IsTargetNote( str, fret ) )
				if ( m_accuracy == AccuracyExactNote )
				{
					
					if ( [m_lessonModel hitTestNoteString:str andFret:fret] )
					{
						// Send output to the AC
						[m_audioController PluckStringFret:str atFret:fret];
						
						// Turn off the LED for this note
						[self turnOffNoteAtString:str andFret:fret];
						
					}
					else
					{
						// Note was wrong, play a funny sound?
					}
				}
				else if ( m_accuracy == AccuracyStringOnly )
				{
					
					char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
					
					[m_lessonModel getTargetNotes:unHitNotes];
					
					if ( [m_lessonModel hitTestString:str] )
					{
						// Send output to the AC
						[m_audioController PluckStringFret:str atFret:unHitNotes[str]];
						
						// Turn off the LED for this note
						//[self  turnOffString:str];						
						[self turnOffNoteAtString:str andFret:unHitNotes[str]];
						
					}
					else
					{
						// Note was wrong, play a funny sound?
					}
					
				}
			}
#pragma mark Says Mode input handle
			else if ( m_mode == PlayControllerModeSays )
			{
				if ( m_saysModel.m_mode == SaysModelModeListen )
				{
					if ( [m_saysModel hitTestNoteString:str andFret:fret] )
					{
						// Send output to the AC
						[m_audioController PluckStringFret:str atFret:fret];
						
						// one second
						[m_displayController.m_saysObject playNoteString:str andFret:fret forFrames:EVENT_LOOPS_PER_SECOND];
					
					}
					else 
					{
						
						// Play a really ugly noise
						[self playDissonantChord];
						
						// one second
						//[m_displayController.m_saysObject playNoteString:str andFret:fret forFrames:EVENT_LOOPS_PER_SECOND];

						[m_saysModel hitWrongNote];
						
						// we already failed, fall out
						break;

					}
				}
				else
				{
					// do nothing during the instructional part
				}
				
			} // End mode conditional
			
		}
	}
	
}

// TODO hacky hack
char tmpPreviousNotes[6];
bool firstTime;

-(void)advanceModels
{
	
	// Song model time advancement and target note expiration
#pragma mark Play Mode advancement
	if ( m_mode == PlayControllerModePlay )
	{
		if ( m_tempo > 0 )
		{
			NoteArrayRange previousTargetNotes = m_songModel->GetTargetNotes();
			
			char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
			
			m_songModel->GetUnHitTargetNotesBytes( unHitNotes );
			
			
			// Advance our song model
			m_songModel->AdvanceModelByDeltaTimeSeconds( m_loopTimeDelta );
			
			NoteArrayRange currentTargetNotes = m_songModel->GetTargetNotes();
			
			//
			// If the notes expired un-hit, turn off the LEDs.
			//
			if ( currentTargetNotes.m_index != previousTargetNotes.m_index ||
				currentTargetNotes.m_count != previousTargetNotes.m_count )
			{
				
				if ( m_accuracy == AccuracyExactNote )
				{
					if ( previousTargetNotes.m_count > 0 )
					{
						[self turnOffNotes:unHitNotes];
					}
					
					if ( currentTargetNotes.m_count == 0 )
					{
						char upcomingNotes[ GUITAR_MODEL_STRING_COUNT ];
						
						m_songModel->GetUpcomingNotesBytes( upcomingNotes );
						
						[self turnOnNotesColor:upcomingNotes];
					}
					
					if ( currentTargetNotes.m_count > 0 )
					{
						char targetNotes[ GUITAR_MODEL_STRING_COUNT ];
						
						m_songModel->GetTargetNotesBytes( targetNotes );
						
						[self turnOnNotesWhite:targetNotes];
					}
					
				} 
				else if ( m_accuracy == AccuracyStringOnly )
				{
					if ( previousTargetNotes.m_count > 0 )
					{
						//[self turnOffStrings:unHitNotes];
						[self turnOffNotes:unHitNotes];
					}
					
					if ( currentTargetNotes.m_count == 0 )
					{
						char upcomingNotes[ GUITAR_MODEL_STRING_COUNT ];
						
						m_songModel->GetUpcomingNotesBytes( upcomingNotes );
						
						//[self turnOnStrings:upcomingNotes];
						[self turnOnNotesColor:upcomingNotes];
					}
				}
				
			}
			
		}
		else 
		{
			// All notes have been hit.
			if ( m_songModel->TargetNotesRemaining() == 0 
				|| stepModelForward == true)
			{
				
				stepModelForward = false;
				
				// delay handling input for a few loops to avoid 
				// advancing too quickly
				m_inputDelayLoops = 2; // ~66 ms
				
				// If we are in step-mode, and all the notes are hit, we advance
				m_songModel->AdvanceModelToNextTargetNotes();
				
				char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
				
				m_songModel->GetUnHitTargetNotesBytes( unHitNotes );
				
				if ( m_accuracy == AccuracyExactNote )
				{
					// Turn on new LEDs
					[self turnOnNotesColor:unHitNotes];
				}
				else
				{
					//[self turnOnStrings:unHitNotes];
					[self turnOnNotesColor:unHitNotes];
				}
				
			}
			
		}
	}
#pragma mark Learn Mode advancement
	else if ( m_mode == PlayControllerModeLearn )
	{
		
		if ( [m_lessonModel getCurrentAdvanceMethod] == AdvanceMethodNotes )
		{

			unsigned int previousTargetNotesCount = [m_lessonModel targetNotesRemaining];
			char previousTargetNotes[ GUITAR_MODEL_STRING_COUNT ];
			[m_lessonModel getTargetNotes:previousTargetNotes];
			
			if ( previousTargetNotesCount == 0 )
			{
				[m_lessonModel advanceModelToNextSegment];
				
				unsigned int currentTargetNotesCount = [m_lessonModel targetNotesRemaining];
				char currentTargetNotes[ GUITAR_MODEL_STRING_COUNT ];
				[m_lessonModel getTargetNotes:currentTargetNotes];
				
				if ( currentTargetNotesCount > 0 )
				{
					
					if ( m_accuracy == AccuracyExactNote )
					{
						// Turn on new LEDs
						[self turnOnNotesColor:currentTargetNotes];
					}
					else
					{
						//[self turnOnStrings:currentTargetNotes];
						[self turnOnNotesColor:currentTargetNotes];
					}
				}
			}
		}
		else if ( [m_lessonModel getCurrentAdvanceMethod] == AdvanceMethodTouch )
		{

			if ( m_screenTouched == YES )
			{
				m_screenTouched = NO;
				
				[m_lessonModel advanceModelToNextSegment];
				
				unsigned int currentTargetNotesCount = [m_lessonModel targetNotesRemaining];
				char currentTargetNotes[ GUITAR_MODEL_STRING_COUNT ];
				[m_lessonModel getTargetNotes:currentTargetNotes];
				
				if ( currentTargetNotesCount > 0 )
				{
					
					if ( m_accuracy == AccuracyExactNote )
					{
						// Turn on new LEDs
						[self turnOnNotesColor:currentTargetNotes];
					}
					else
					{
						//[self turnOnStrings:currentTargetNotes];
						[self turnOnNotesColor:currentTargetNotes];
					}
				}
			}
		}
				
	}
#pragma mark Says Mode advancement
	else if ( m_mode == PlayControllerModeSays )
	{
		if ( m_saysModel.m_mode == SaysModelModeDelay )
		{
			[m_saysModel delayForTimeDelta:m_loopTimeDelta];
		}		
		else if ( m_saysModel.m_mode == SaysModelModeInstruct )
		{
			// Time based
			NoteArrayRange previousTargetNotes = [m_saysModel getTargetNotes];

			char previousUnHitNotes[ GUITAR_MODEL_STRING_COUNT ];
			[m_saysModel getTargetInstructNotes:previousUnHitNotes ];
			[m_saysModel getTargetInstructNotes:tmpPreviousNotes ];
			firstTime = true;
			
			NSInteger previousSequenceLength = m_saysModel.m_currentSequenceLength;
			
			// Advance our song model
			[m_saysModel advanceModelByDeltaTimeSeconds:m_loopTimeDelta];
			
			NoteArrayRange currentTargetNotes = [m_saysModel getTargetNotes];
			
			// If the target notes changed
			if ( (currentTargetNotes.m_index != previousTargetNotes.m_index || currentTargetNotes.m_count != previousTargetNotes.m_count) ||
				 (previousSequenceLength == 0 && currentTargetNotes.m_count > 0) )
			{
				
				if ( previousTargetNotes.m_count > 0 )
				{
					[self turnOffNotes:previousUnHitNotes];
				}
				
				if ( currentTargetNotes.m_count > 0 )
				{					
					// Play the audio associated with this new set of notes

					char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
					
					[m_saysModel getTargetInstructNotes:unHitNotes];
					
					[self turnOnNotesColor:unHitNotes];
					
					for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
					{
						if ( unHitNotes[ str ] != GTAR_GUITAR_NOTE_OFF )
						{
							[m_audioController PluckStringFret:str atFret:unHitNotes[str]];
							// one second
							[m_displayController.m_saysObject playNoteString:str andFret:unHitNotes[str] forFrames:EVENT_LOOPS_PER_SECOND];
							// zoom to include this note
							[m_displayController.m_saysObject focusAddString:str andFret:unHitNotes[str]];
						}
					}
						
					
				}
			
			}
			
		}
		else if ( m_saysModel.m_mode == SaysModelModeListen ) 
		{
			if ( firstTime == true )
			{
				firstTime = false;
				
				[self turnOffNotes:tmpPreviousNotes];
			}
			
			// Input/step based
			if ( [m_saysModel targetNotesRemaining] == 0 )
			{
				
				// If we are in step-mode, and all the notes are hit, we advance
				[m_saysModel advanceModelToNextTargetNotes];
				
			}
			
		}
		
	}

	
}

-(void)updateDisplay
{

#pragma mark Play Mode display 
	if ( m_mode == PlayControllerModePlay )
	{
		NoteArrayRange targetNotes = m_songModel->GetTargetNotes();
		
		[m_displayController.m_playObject setTargetNotes:targetNotes];
		
		double currentBeat = m_songModel->GetCurrentBeat();
		
		[m_displayController.m_playObject setCurrentBeat:currentBeat];
		
		[self updatePlayLabels];
		
		m_progressView.m_currentBeat = currentBeat;
		
		[m_progressView setNeedsDisplay];
		
		if ( m_songModel->IsEndOfSong() )
		{
			[self reachedEndOfSong];
		}
	}
#pragma mark Learn Mode display 
	else if ( m_mode == PlayControllerModeLearn )
	{
		
		char targetNotes[ GTAR_GUITAR_STRING_COUNT ];
		[m_lessonModel getTargetNotes:targetNotes];
		
		[m_displayController.m_learnObject setTargetNotes:targetNotes];
		
		[self updateLearnLabels];
		
		if ( m_lessonModel.m_endOfInstruction == YES )
		{
			[self reachedEndOfInstruction];
		}
		
		if ( m_lessonModel.m_endOfChapter == YES )
		{
			//[self reachedEndOfChapter];
		}
		
		if ( m_lessonModel.m_endOfLesson == YES )
		{
			[self reachedEndOfLesson];
		}
		
	}
#pragma mark Says Mode display 
	else if ( m_mode == PlayControllerModeSays )
	{
		
		[self updateSaysLabels];
		
		if ( m_saysModel.m_mode == SaysModelModeInstruct )
		{
			// Time based
			
		}
		else if ( m_saysModel.m_mode == SaysModelModeListen ) 
		{
			// Input/step based
			
		}
		
		if ( [m_saysModel isEndOfSong] == YES )
		{
			[self reachedEndOfSong];
		}
	}		
	
}

-(void)mainEventLoop
{

	//
	// Handle the time accounting
	//
	m_previousLoopTime = m_currentLoopTime;
	m_currentLoopTime = CACurrentMediaTime();
	
	//double loopTimeDelta = currentLoopTime - previousLoopTime;
	m_loopTimeDelta = 1.0/30.0;
	
	// Modify our base time by the provided tempo.
	// A tempo of 1 means real-time.
	if ( m_tempo > 0 )
	{
		m_loopTimeDelta /= m_tempo;
	}
	
	//double bps = m_songModel->m_beatsPerSecond;
	
	[self handleDevice];
	
	[self advanceModels];
	
	[self updateDisplay];
	

	//
	// Animate our frame given all the input we've gotten from the other models
	//
	[m_displayController drawView];

	//[m_glView drawRect:b];
	
	m_screenTouched = NO;
	m_screenTouchedBad = NO;
	
}

-(void)startMainEventLoop
{
	m_eventLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)SECONDS_PER_EVENT_LOOP target:self selector:@selector(mainEventLoop) userInfo:nil repeats:TRUE];
}

-(void)stopMainEventLoop
{
	[m_eventLoopTimer invalidate];

	m_eventLoopTimer = nil;
}

#pragma mark -
#pragma mark Helper functions

-(void)playDissonantChord
{
	[m_audioController PluckStringFret:1 atFret:1];
//	[m_audioController PluckStringFret:2 atFret:1];
//	[m_audioController PluckStringFret:3 atFret:1];
//	[m_audioController PluckStringFret:4 atFret:1];
//	[m_audioController PluckStringFret:5 atFret:1];
//	[m_audioController PluckStringFret:6 atFret:1];
}

-(void)turnOnNotesWhite:(char*)notes
{

	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOnNoteWhiteAtString:str andFret:notes[str]];
		}
	}
}

-(void)turnOnNotesColor:(char*)notes
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


-(void)turnOnStrings:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOnString:str];
		}
	}
}

-(void)turnOnString:(char)str
{

	for ( unsigned int fret = 0; fret < GUITAR_MODEL_FRET_COUNT; fret++ )
	{
		[self turnOnNoteAtString:str andFret:fret];
	}		
}


-(void)turnOffNotes:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOffNoteAtString:str andFret:notes[str]];
		}
	}
}

-(void)turnOffNoteAtString:(char)str andFret:(char)fret
{
	
	//m_guitarModel->TurnOffLed( str, fret );
	[m_guitarModel turnOffLedString:str andFret:fret];
	usleep( GTAR_GUITAR_MESSAGE_DELAY );
	
}

-(void)turnOffStrings:(char*)notes
{
	
	for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
	{
		if ( notes[str] != -1 )
		{
			[self turnOffString:str];
		}
	}
}

-(void)turnOffString:(char)str
{
	
	for ( unsigned int fret = 0; fret < GUITAR_MODEL_FRET_COUNT; fret++ )
	{
		[self turnOffNoteAtString:str andFret:fret];
	}		
}
#pragma mark -
#pragma mark EOx

-(void)reachedEndOfSong
{
	// All done, end the main loop
	[self stopMainEventLoop];
	
	ScoreController * scoreController = m_scoreController;

	scoreController.m_score = m_songModel->GetScore();
	scoreController.m_scoreMax = m_songModel->GetScoreMax();
	
	scoreController.m_notesHit = m_songModel->GetNotesHit();
	scoreController.m_notesMax = m_songModel->GetNotesTotal();
	scoreController.m_combo = m_songModel->GetComboMax();
	
	// TODO make this less hacky ...
	if ( [scoreController isKindOfClass:[PlayScoreController class]] )
	{
		
		PlayScoreController * playSc = m_playScoreController;

		playSc.m_score = m_songModel->GetScore();
		playSc.m_scoreMax = m_songModel->GetScoreMax();
		
		playSc.m_notesHit = m_songModel->GetNotesHit();
		playSc.m_notesMax = m_songModel->GetNotesTotal();
		playSc.m_combo = m_songModel->GetComboMax();
		
		playSc.m_score = m_songModel->GetScore();
		playSc.m_scoreMax = m_songModel->GetScoreMax();
		
		playSc.m_notesHit = m_songModel->GetNotesHit();
		playSc.m_notesMax = m_songModel->GetNotesTotal();
		playSc.m_combo = m_songModel->GetComboMax();
		
		playSc.m_songName = m_songName;
		
		[playSc updateScores];
		
		[m_scoreView addSubview:playSc.view];
		
		//playSc.m_replayController = self; 

		//[self.navigationController pushViewController:playSc animated:YES];
		
		[self animateModal:YES];
						
	}
	else if ( [scoreController isKindOfClass:[LearnScoreController class]] )
	{
		
		LearnScoreController * learnSc = (LearnScoreController*)scoreController;
		
		learnSc.m_replayController = self;

		[self.navigationController pushViewController:learnSc animated:YES];

		// Flip back to learn mode.
		[self changeDisplayMode:PlayControllerModeLearn];
		
	}
	else if ( [scoreController isKindOfClass:[SaysScoreController class]] )
	{
		
		if ( m_saysModel != nil )
		{

			SaysScoreController * saysSc = m_saysScoreController;
			
			/*
			saysSc.m_score = m_songModel->GetScore();
			saysSc.m_scoreMax = m_songModel->GetScoreMax();
			
			saysSc.m_notesHit = m_songModel->GetNotesHit();
			saysSc.m_notesMax = m_songModel->GetNotesTotal();
			saysSc.m_combo = m_songModel->GetComboMax();
*/
			saysSc.m_status = m_saysModel.m_status;
			saysSc.m_maxSequence = m_saysModel.m_maxSequence;
			
			/*
			SaysScoreController * saysSc = (SaysScoreController*)scoreController;
			
			saysSc.m_replayController = self;
			saysSc.m_status = m_saysModel.m_status;
			saysSc.m_maxSequence = m_saysModel.m_maxSequence;
			*/
			//[m_saysModel release];
			//m_saysModel = nil;
			
			//delete m_songModel;
			//m_songModel = NULL;
			
			[m_saysScoreController updateScores];
			
			[m_scoreView addSubview:m_saysScoreController.view];
			
			[self animateModal:YES];

			
			//[self.navigationController pushViewController:saysSc animated:YES];
			
		}		
	}
	
}

-(void)reachedEndOfLesson
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)reachedEndOfInstruction
{
	
	// Load the song we are about to play and switch mode
	
	if ( m_songModel != NULL )
	{
		delete m_songModel;
	}
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Tears_in_Heaven_Eric_Clapton" ofType:@"xmp"];
	
	NSString * xmpBlob = [NSString stringWithContentsOfFile:filePath];
	m_songModel = new SongModel( xmpBlob );
	
	NoteArray * noteArray = m_songModel->GetNoteArray();
	MeasureArray * measureArray = m_songModel->GetMeasureArray();
	
	[m_displayController createPlayObjectWithStringCount:GTAR_GUITAR_STRING_COUNT notes:noteArray andMeasures:measureArray];
	
	[self updatePlayLabels];
	
	// Switch to play mode
	[self changeDisplayMode:PlayControllerModePlay];
	
}

-(void)reachedEndOfChapter
{
	
	
}

#pragma mark Helpers

-(void)changeDisplayMode:(PlayControllerMode)mode
{
	
	m_mode = mode;
	
	[self changeDisplayControllerMode];
	
}

-(void)changeDisplayControllerMode
{
	
	if ( m_displayController == nil )
	{
		return;		
	}
	
	switch ( m_mode )
	{
		case PlayControllerModePlay:
		{
			
//			[m_playScoreLabel setHidden:NO];
//			[m_playComboLabel setHidden:NO];
//			[m_playHitsLabel setHidden:NO];
			
			[m_learnInstructionLabel setHidden:YES];

			[m_displayController changeDisplayMode:DisplayControllerModePlay];
			
		} break;
			
		case PlayControllerModeLearn:
		{
			[m_learnInstructionLabel setHidden:NO];
	
			[m_playScoreLabel setHidden:YES];
			//[m_playComboLabel setHidden:YES];
			//[m_playHitsLabel setHidden:YES];
			
			[m_displayController changeDisplayMode:DisplayControllerModeLearn];
			
		} break;
			
		case PlayControllerModeSays:
		{
			[m_learnInstructionLabel setHidden:YES];
			
			[m_playScoreLabel setHidden:YES];
			//[m_playComboLabel setHidden:YES];
			//[m_playHitsLabel setHidden:YES];
			
			[m_displayController changeDisplayMode:DisplayControllerModeSays];
			
		}
		default:
		{
			// Empty
		} break;
	}
	
}

-(void)updatePlayLabels
{
	
	unsigned int score = m_songModel->GetScore();
	unsigned int combo = m_songModel->GetCombo();
	unsigned int hits = m_songModel->GetNotesHit();
	unsigned int multiplier = m_songModel->GetMultiplier();
	
	[m_lcdScoreView setDigitsValue:score];
	[m_lcdMultView setDigitsValue:multiplier];
	[m_fillGaugeView setLevelWithRollover:combo];
	
}

-(void)updateLearnLabels
{
	
	NSString * currentText = [m_lessonModel getCurrentText];
	
	[m_learnInstructionLabel setText:currentText];

}

- (void)updateSaysLabels
{
	
	// Hijack this label for now
	[m_playScoreLabel setHidden:NO];

	NoteArrayRange targetNotes = [m_saysModel getTargetNotes];
	
	NSString * label;
	if ( m_saysModel.m_mode == SaysModelModeListen )
	{
		label = [NSString stringWithFormat:@"Listen %d %d %d %d", m_saysModel.m_currentSequenceLength, m_saysModel.m_currentSequenceLengthTarget, targetNotes.m_index, targetNotes.m_count ];
	}
	else if ( m_saysModel.m_mode == SaysModelModeInstruct )
	{
		label = [NSString stringWithFormat:@"Instruct %d %d %d %d", m_saysModel.m_currentSequenceLength, m_saysModel.m_currentSequenceLengthTarget, targetNotes.m_index, targetNotes.m_count ];
	}
	else if ( m_saysModel.m_mode == SaysModelModeDelay )
	{
		label = [NSString stringWithFormat:@"Delay %f", m_saysModel.m_delay];
	}
	
	[m_playScoreLabel setText:label];

}

#pragma mark -
#pragma mark Modals

- (void)animateModal:(BOOL)popup
{
	
	//NSInteger height = self.view.frame.size.height / 2 + AMP_HEIGHT;
	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;
	
	// slide the popup off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	
	if ( m_popupVisible == NO )
	{
		// so make it visible
		
		m_ampView.transform = 
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height - (self.view.frame.size.height - m_modalView.frame.size.height)/2 );
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height + (m_modalView.frame.size.height/2) );
		CGAffineTransformMakeTranslation( 0, 0 );
		
		m_topmenuView.transform =
		CGAffineTransformMakeTranslation( 0, -height );
		
		m_blackView.alpha = 0.8;
	}
	else 
	{
		// so hide it
		
		m_ampView.transform = 
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height - (self.view.frame.size.height - m_modalView.frame.size.height)/2 );
		//CGAffineTransformMakeTranslation( 0, +self.view.frame.size.height + (m_modalView.frame.size.height/2) );
		CGAffineTransformMakeTranslation( 0, height );
		
		m_topmenuView.transform = 
		CGAffineTransformMakeTranslation( 0, 0 );
		
		m_blackView.alpha = 0.0;
	}
	
	m_popupVisible = !m_popupVisible;
	
	[UIView commitAnimations];
	
}	


@end
