//
//  PlayController.m
//  gTar
//
//  Created by Marty Greenia on 2/21/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "PlayControllerNew.h"

@implementation PlayControllerNew

@synthesize m_xmpName;
@synthesize m_songName;
@synthesize m_xmpBlob;
@synthesize m_tempo;
@synthesize m_accuracy;
@synthesize m_penalty;
@synthesize m_glView;
//@synthesize m_learnInstructionLabel;
@synthesize m_blackView;
@synthesize m_ampView;
@synthesize m_topmenuView;
@synthesize m_menuView;
@synthesize m_scoreView;
//@synthesize m_borderView;
@synthesize m_activityIndicator;
@synthesize m_progressView;
@synthesize m_playScoreController;
@synthesize m_lcdScoreView;
@synthesize m_lcdMultView;
@synthesize m_fillGaugeView;
@synthesize m_titleLabel;
@synthesize m_menuButton;
@synthesize m_menuLabel;

//@synthesize m_guitarModel;

#define AMP_HEIGHT (90.0)

- (void)initControllers
{

	// DisplayController
	m_displayController = [[DisplayController alloc] initWithView:m_glView];

	// SongModel
	m_songModel = new SongModel( m_xmpBlob );
	
	// initWithTempo doesn't honor its argument for now .. don't think we need it
	m_tempoRegulator = [[TempoRegulator alloc] initWithTempo:0];
	
	NoteArray * noteArray = m_songModel->GetNoteArray();
	MeasureArray * measureArray = m_songModel->GetMeasureArray();
		
	[m_displayController createPlayObjectWithStringCount:GTAR_GUITAR_STRING_COUNT notes:noteArray andMeasures:measureArray];
		
	[m_displayController changeDisplayMode:DisplayControllerModePlay];
	
	[m_progressView setNoteArray:noteArray];
	[m_progressView setMeasureArray:measureArray];

	[super initControllers];
	
}

- (void)resetAndRun
{

	// Init a second in the past so the person has time to respond
	m_songModel->StartModelAtTime(-0.5);
		
	m_songModel->ResetScore();
		
	if ( m_tempo != TempoNone )
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
			
		if ( m_tempo != TempoNone )
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
			
	self.m_loopDelay = 3.99f;
	
	[self updateScoreDisplay];

	[super resetAndRun];
}

- (void)viewDidLoad
{
	// This calls the initControllers function for us
    [super viewDidLoad];
	
//	[self initControllers];

	// Add the progress view to the top
	[self.view addSubview:m_topmenuView];
	
	// now layer the rest of the views on top of the border
	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;
	m_ampView.transform = CGAffineTransformMakeTranslation( 0, height );
	
	[self.view addSubview:m_blackView];
	
	[self.view addSubview:m_ampView];
	
	[m_titleLabel setText:m_songName];
	
	[m_lcdMultView initDigits];
	[m_lcdScoreView initDigits];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self resetAndRun];
}

- (void)dealloc
{

	if ( m_displayController != nil )
	{
		[m_displayController release];
		m_displayController = nil;
	}
	
	if ( m_songModel != NULL )
	{
		delete m_songModel;
		m_songModel = NULL;
	}
	
	if ( m_tempoRegulator != nil )
	{
		[m_tempoRegulator release];
		m_tempoRegulator = nil;
	}
	
	[super dealloc];
}

#pragma mark -
#pragma mark Button click handling

- (IBAction)replayButtonClicked
{
	
	// add the replay view button?
	[self resetAndRun];
	
	// send down the modal
	[self animateModal:NO];
		
	[m_menuButton setEnabled:NO];
	[m_menuLabel setEnabled:NO];
	
	// remove any views that might have been added
	[m_menuView removeFromSuperview];
	[m_playScoreController.view removeFromSuperview];

}

- (IBAction)menuButtonClicked
{
	// if we are paused
	[self stopMainEventLoop];
	
	[m_scoreView addSubview:m_menuView];
	
	[self animateModal:YES];
	
	[m_menuButton setEnabled:NO];
	[m_menuLabel setEnabled:NO];
/*	
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
*/	
}

- (IBAction)menuDoneButtonClicked
{
	[self startMainEventLoop];
	
	[self animateModal:NO];
	
	[m_menuButton setEnabled:YES];
	[m_menuLabel setEnabled:YES];

	self.m_loopDelay = 0.99f;

	[m_menuView removeFromSuperview];

}

#pragma mark -
#pragma mark Main event loop
- (void)delayLoop
{

	// take down the delay over time
	NSInteger intValueBefore = [[NSNumber numberWithDouble:self.m_loopDelay] integerValue];	
	self.m_loopDelay -= self.m_loopTimeDelta;
	NSInteger intValueAfter = [[NSNumber numberWithDouble:self.m_loopDelay] integerValue];
	
	// play a beep on the transition between stages
	if ( intValueBefore != intValueAfter && self.m_loopDelay < 3.0 )
	{
		[self.m_audioController SetAttentuation:0.925f];
		[self emitBeepSound];
	}
	
	// also beep when we are done delaying
	if ( self.m_loopDelay < 0.0 )
	{
		[self.m_audioController SetAttentuation:0.5f];
		[self emitBeepSound];
	}
	
	// the loop delay varies from 4.0->0.0
	if ( self.m_loopDelay > 0.0 && self.m_loopDelay < 4.0)
	{
		[m_displayController.m_playObject countdownOn:intValueAfter];
	}
	else 
	{
		[m_displayController.m_playObject countdownOff];
		[self.m_audioController SetAttentuation:AUDIO_CONTROLLER_ATTENUATION];

	}
	
	[self updateDisplay];

}

- (void)handleDevice
{
	
	//
	// Get any new input from the device 
	//
//	char previousFretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char previousNotesOn[ GUITAR_MODEL_STRING_COUNT ];
	
//	char currentFretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char currentNotesOn[ GUITAR_MODEL_STRING_COUNT ];
	
//	[self.m_guitarModel getFretsDown:previousFretsDown];
	[self.m_guitarModel getNotesOn:previousNotesOn];

	[self.m_guitarModel handleDeviceOutput];
	
//	[self.m_guitarModel getFretsDown:currentFretsDown];
	[self.m_guitarModel getNotesOn:currentNotesOn];
	
	
	// debuggy stuff
	if ( self.m_skipNotes == YES ) 
	{
		self.m_skipNotes = NO;
		
		if ( m_songModel->TargetNotesRemaining() > 0 )
		{
			m_songModel->GetUnHitTargetNotesBytes( currentNotesOn );
		}
		else 
		{
			m_songModel->GetUpcomingNotesBytes( currentNotesOn );
		}
	}
	
	// make the notes failure notes, fret 99 that doesn't exist.
	if ( self.m_screenTouchedBad == YES )
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
	
	for ( unsigned int i = 0; i < GUITAR_MODEL_STRING_COUNT; i++ )
	{
		//
		// Look for note deltas ('edge triggered')
		//
		if ( currentNotesOn[i] != GTAR_GUITAR_NOTE_OFF )
		{
			int str = i;
			int fret = currentNotesOn[i];
			
			// flash the indicator light to show whats going on
			[m_activityIndicator setHidden:NO];
			
			//if ( m_songModel->IsTargetNote( str, fret ) )
			if ( m_accuracy == NewAccuracyExactNote )
			{
				// testing an incorrect note will reset the combo regardless
				if ( m_songModel->HitTestNote( str, fret ) )
				{
					// Send output to the AC
					[self playNoteAtString:str andFret:fret];
					
					// Turn off the LED for this note
					[self turnOffNoteAtString:str andFret:fret];

					if ( m_tempo == TempoAutoAdjust )
					{
						//[m_tempoRegulator playCorrectNote];
					}

				}
				else
				{

					if ( m_tempo == TempoAutoAdjust )
					{

						// see if we just played a note early
						if ( m_songModel->TestUpcomingNote( str, fret ) )
						{
							// jump towards the real sets of target notes
							//m_songModel->AdvanceModelToNextTargetNotes();
							m_songModel->AdvanceModelToNextTargetNotesFromBeat();
							
							m_songModel->HitTestNote( str, fret );

							// Send output to the AC
							[self playNoteAtString:str andFret:fret];
							
							// Turn off the LED for this note
							[self turnOffNoteAtString:str andFret:fret];
							
							// increase the tempo a bit
							[m_tempoRegulator increaseTempo];
							
						}
						else if ( m_penalty == YES )
						{ 
							[self playUglyNoteAtString:str andFret:fret];
						}
						
					}
					else if ( m_penalty == YES )
					{ 
						[self playUglyNoteAtString:str andFret:fret];
					}
					
				}
				
			}
			else if ( m_accuracy == NewAccuracyStringOnly )
			{
				
				char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
				
				m_songModel->GetUnHitTargetNotesBytes( unHitNotes );
				
				if ( m_songModel->HitTestString( str ) )
				{
					// Send output to the AC
					[self.m_audioController PluckStringFret:str atFret:unHitNotes[str]];
					
					// Turn off the LED for this note
					[self turnOffNoteAtString:str andFret:unHitNotes[str]];
					
					if ( m_tempo == TempoAutoAdjust )
					{
						//[m_tempoRegulator playCorrectNote];
					}
					
				}
				else
				{
					
					if ( m_penalty == YES )
					{
						[self playUglyNoteAtString:str andFret:unHitNotes[str]];
						//[self playDissonantChord];
					}
					
					if ( m_tempo == TempoAutoAdjust )
					{
						//[m_tempoRegulator playIncorrectNote];
					}

				}
				
			}
			
		}

	}
		
}

- (void)advanceModels
{

	if ( m_tempo != TempoNone )
	{
		NoteArrayRange previousTargetNotes = m_songModel->GetTargetNotes();
		
		char targetNotes[ GUITAR_MODEL_STRING_COUNT ];
		char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
		
		m_songModel->GetTargetNotesBytes( targetNotes );
		m_songModel->GetUnHitTargetNotesBytes( unHitNotes );

		// Advance our song model
		if ( m_tempo == TempoAutoAdjust )
		{
			double tempoTimeScaler = [m_tempoRegulator currentTempoTimeScaler];
			m_songModel->AdvanceModelByDeltaTimeSeconds( self.m_loopTimeDelta * tempoTimeScaler );			
		}
		else 
		{			
			m_songModel->AdvanceModelByDeltaTimeSeconds( self.m_loopTimeDelta );
		}
		
		NoteArrayRange currentTargetNotes = m_songModel->GetTargetNotes();
		
		//
		// If the notes expired un-hit, turn off the LEDs.
		//
		if ( currentTargetNotes.m_index != previousTargetNotes.m_index ||
			currentTargetNotes.m_count != previousTargetNotes.m_count )
		{
			
			// commit what points they did get.
			m_songModel->CalculateAndAccumulateScore( targetNotes, unHitNotes );
			
			if ( m_accuracy == NewAccuracyExactNote )
			{

				if ( previousTargetNotes.m_count > 0 )
				{
					[self turnOffNotes:unHitNotes];
					
					// some notes may have expired, turne them off
					for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
					{
						if ( unHitNotes[str] != -1 )
						{
							// play a bad sound if appropriated
							if ( m_penalty == YES )
							{ 
								[self playUglyNotes:unHitNotes];
								//[self playDissonantChord];
							}
							
							// adjust their tempo
							if ( m_tempo == TempoAutoAdjust )
							{
								[m_tempoRegulator decreaseTempo];
							}
							
						}
						
					}
					
				}
				
				// we might need to light up some upcoming notes
				if ( currentTargetNotes.m_count == 0 )
				{
					char upcomingNotes[ GUITAR_MODEL_STRING_COUNT ];
					
					m_songModel->GetUpcomingNotesBytes( upcomingNotes );
					
					[self turnOnNotesColor:upcomingNotes];
				}
				
				// we might need to light some current notes
				if ( currentTargetNotes.m_count > 0 )
				{
					char targetNotes[ GUITAR_MODEL_STRING_COUNT ];
					
					m_songModel->GetTargetNotesBytes( targetNotes );
					
					[self turnOnNotesWhite:targetNotes];
				}
				
				
			} 
			else if ( m_accuracy == NewAccuracyStringOnly )
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
		if ( m_songModel->TargetNotesRemaining() == 0 )
		{
			
			// delay handling input for a few loops to avoid 
			// advancing too quickly
			m_inputDelayLoops = 2; // ~66 ms
			
			// commit the points they got
			m_songModel->CalculateAndAccumulateScore();

			// If we are in step-mode, and all the notes are hit, we advance
			m_songModel->AdvanceModelToNextTargetNotes();
			
			char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
			
			m_songModel->GetUnHitTargetNotesBytes( unHitNotes );
			
			if ( m_accuracy == NewAccuracyExactNote )
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
	
	// If the song is done, this will be our last loop.
	if ( m_songModel->IsEndOfSong() == YES )
	{
		[self stopMainEventLoop];
	}
}

- (void)updateDisplay
{

//	[m_displayController.m_playObject countdownOn:2];
	
	NoteArrayRange targetNotes = m_songModel->GetTargetNotes();
	
	[m_displayController.m_playObject setTargetNotes:targetNotes];
	
	double currentBeat = m_songModel->GetCurrentBeat();
	
	[m_displayController.m_playObject setCurrentBeat:currentBeat];
	
	m_progressView.m_currentBeat = currentBeat;
	
	[m_progressView setNeedsDisplay];

	[self updateScoreDisplay];

	// if this is the end of the song, pop up the score screen
	if ( m_songModel->IsEndOfSong() == YES )
	{
		[self displayScoreScreen];
	}
	else 
	{
		[m_displayController drawView];
	}
	
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
	
	if ( popup == YES )
	{
		// so make it visible
		
		m_ampView.transform = CGAffineTransformMakeTranslation( 0, 0 );
		
		m_topmenuView.transform = CGAffineTransformMakeTranslation( 0, -height );
		
		m_blackView.alpha = 0.8;
	}
	else 
	{
		// so hide it
		
		m_ampView.transform = CGAffineTransformMakeTranslation( 0, height );
		
		m_topmenuView.transform = CGAffineTransformMakeTranslation( 0, 0 );
		
		m_blackView.alpha = 0.0;
	}
	
	[UIView commitAnimations];
	
}	

#pragma mark -
#pragma mark Helpers

- (void)updateScoreDisplay
{
	
	unsigned int score = m_songModel->GetScore();
	unsigned int combo = m_songModel->GetCombo();
//	unsigned int hits = m_songModel->GetNotesHit();
	unsigned int multiplier = m_songModel->GetMultiplier();
	
	[m_lcdScoreView setDigitsValue:score];
	[m_lcdMultView setDigitsValue:multiplier];
	
	if ( multiplier >= SONG_MODEL_COMBO_MULTIPLIER )
	{
		[m_fillGaugeView setLevelToMax];
	}
	else
	{
		[m_fillGaugeView setLevelWithRollover:combo];
	}
}

- (void)displayScoreScreen
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
	
	[self animateModal:YES];
}

- (void)emitBeepSound
{
	
	//AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	//AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
	[self.m_audioController PluckStringFret:0 atFret:0];

}

@end
