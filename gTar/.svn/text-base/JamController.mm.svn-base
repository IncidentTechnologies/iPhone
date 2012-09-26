//
//  JamController.m
//  gTar
//
//  Created by Marty Greenia on 1/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "JamController.h"

@implementation JamController

@synthesize m_cachedSongsTable;
@synthesize m_ampView, m_blackView, m_menuView, m_previewView, m_popupView, m_slideView;
@synthesize m_recLabel, m_recButton, m_timeLabel;
@synthesize m_jamPad;
@synthesize m_titleText;
@synthesize m_multiplayerMode, m_multiplayerController;

#define AMP_HEIGHT (84.0)

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	m_jamPad.m_delegate = self;
	
//	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;
//	m_ampView.transform = CGAffineTransformMakeTranslation( 0, height );
	
	[self.view addSubview:m_blackView];
	
	[self.view addSubview:m_ampView];

	NSInteger width = (self.view.frame.size.width - m_previewView.frame.size.width) / 2.0;
	m_previewView.transform = CGAffineTransformMakeTranslation( width, -(m_previewView.frame.size.height) );
	[self.view addSubview:m_previewView];

	
	// Load backing tracks dictionary
	NSString * path = [[NSBundle mainBundle] pathForResource:@"BackingTrackDictionary" ofType:@"plist"];	
	m_backingTrackDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

	[self loadSongCache];
	
	// init the state variables
	m_isRecording = NO;
	m_isPlaying = NO;
	m_isBacking = NO;
	
	// this is just a fun little initial animation to make the slider slide in dramatically
	m_slideView.transform = CGAffineTransformMakeTranslation( 0, -600 );

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5f];
	
	m_slideView.transform = CGAffineTransformMakeTranslation( 0, 0 );
		
	[UIView commitAnimations];

	// now the amp
	NSInteger height = self.view.frame.size.height - AMP_HEIGHT;

	m_ampView.transform = CGAffineTransformMakeTranslation( 0, height + 600 );
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75f];
	
	m_ampView.transform = CGAffineTransformMakeTranslation( 0, height );
	
	[UIView commitAnimations];
	
}

- (void)dealloc
{
	if ( m_recordedSongModel != NULL )
	{
		delete m_recordedSongModel;
	}
	
    [super dealloc];
}

#pragma mark -
#pragma mark Button Click Handlers

- (IBAction)previewDoneButtonClicked:(id)sender
{
	[self animatePreviewModal:NO];
}

- (IBAction)toggleBeatButtonClicked:(id)sender
{
	if ( m_backingTrackSongModel == NULL )
	{
		
		// TODO
		m_backingTrackXmpBlob = [[m_backingTrackDictionary allValues] objectAtIndex:0];
		NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString * documentsDirectory = [paths objectAtIndex:0];
		
		NSString * fileName = [NSString stringWithFormat:@"24.xmp"];
		
		NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
		
		m_backingTrackXmpBlob = [NSString stringWithContentsOfFile:xmpPath];
		
		if ( m_backingTrackXmpBlob != nil )
		{
			NSLog(m_backingTrackXmpBlob);
			m_backingTrackSongModel = new SongModel( m_backingTrackXmpBlob );
		
			m_backingTrackSongModel->StartModelAtTime(0);
			
			m_isBacking = YES;
		}
	}
	else 
	{
		m_isBacking = YES;
		delete m_backingTrackSongModel;
		m_backingTrackSongModel = NULL;
	}
}

- (IBAction)backButtonClicked:(id)sender
{
	// this needs to be cleared before we leave, else we get a circular reference 
	m_jamPad.m_delegate = nil;
	
	[super backButtonClicked:sender];
}

// this funct is dead
- (IBAction)stopButtonClicked:(id)sender
{
	[m_songRecorder finishSong];
	
	//CSong * recordedSong = m_songRecorder.m_song;
	
	// Save the song's xmp to a file
//	m_recordedXmpBlob = [[SongCreator xmpBlobWithSong:recordedSong] retain];
	
	 
	
	/*
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName = [NSString stringWithFormat:@"jam.xmp"];
	
	NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	[xmpBlob writeToFile:xmpPath atomically:YES];
*/
}

- (IBAction)playbackButtonClicked:(id)sender
{
	if ( m_selectedSongDictionary != nil )
	{

		if ( m_recordedSongModel == NULL )
		{
			NSString * xmpBlob = [self getXmpFromEntry:m_selectedSongDictionary];
			NSLog(xmpBlob);
			m_recordedSongModel = new SongModel( xmpBlob );
		}

//		[m_recButton setTitle:@"Play"];
		[m_recLabel setText:@"Play"];
		
		m_recordedSongModel->StartModelAtTime(0);
		m_isPlaying = YES;
		
	}
}

- (IBAction)shareButtonClicked:(id)sender
{
	
}

- (IBAction)menuButtonClicked:(id)sender
{
	[m_popupView addSubview:m_menuView];
	[self animateAmpModal:YES];
}

- (IBAction)menuDoneButtonClicked:(id)sender
{
	[self animateAmpModal:NO];
	[m_menuView removeFromSuperview];
}
	 

// todo temp effect buttons
- (IBAction)ffButtonClicked:(id)sender
{
	[m_guitarModel enableFretFollow];
}

- (IBAction)naButtonClicked:(id)sender
{
	[m_guitarModel enableNoteActive];
}

- (IBAction)lmButtonClicked:(id)sender
{
	[m_guitarModel enableLightningMode];
}

- (IBAction)noneButtonClicked:(id)sender
{
	[m_guitarModel disableState];
}

#pragma mark -
#pragma mark Main event loop

- (void)handleDevice
{

	char previousFretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char previousNotesOn[ GUITAR_MODEL_STRING_COUNT ];
	
	char currentFretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char currentNotesOn[ GUITAR_MODEL_STRING_COUNT ];
	
	[m_guitarModel getFretsDown:previousFretsDown];
	[m_guitarModel getNotesOn:previousNotesOn];

	// Get any new output
	[m_guitarModel handleDeviceOutput];
	
	[m_guitarModel getFretsDown:currentFretsDown];
	[m_guitarModel getNotesOn:currentNotesOn];

	if ( m_screenTouched == YES )
	{
		m_screenTouched = NO;
		
		char fret = (m_debugTouchPoint.x / (CGFloat)self.view.frame.size.width) * GTAR_GUITAR_FRET_COUNT;
		char str = (m_debugTouchPoint.y / (CGFloat)self.view.frame.size.height) * GTAR_GUITAR_STRING_COUNT;

		currentNotesOn[str] = fret;
	}
	
	//
	// Send output to the Audio controller as appropriate.
	//
	for ( unsigned int i = 0; i < GUITAR_MODEL_STRING_COUNT; i++ )
	{
		//
		// Look for note deltas ('edge triggered')
		//
		if ( currentNotesOn[i] != GTAR_GUITAR_NOTE_OFF &&
			 currentNotesOn[i] != previousNotesOn[i] )
		{
			int str = i;
			int fret = currentNotesOn[i];
			
			// Play the note
			// strings are zero based
			[self playNoteAtString:str andFret:fret];
			
			if ( m_songRecorder.m_isRecording == YES )
			{
				// record this note to xmp
				[m_songRecorder playString:str andFret:fret];
			}
		}
	}
	
}

- (void)advanceModels
{
	
	// recorder
	if ( m_isRecording && m_songRecorder != nil && [m_songRecorder m_isRecording] )
	{
		[m_songRecorder advanceRecordingByTimeDelta:m_loopTimeDelta];
		double time = m_songRecorder.m_currentTime;
		[self updateTimeDisplay:time];
	}
	
	// playback
	if ( m_isPlaying && m_recordedSongModel != nil && !m_recordedSongModel->IsEndOfSong() )
	{
		NoteArrayRange previousTargetNotes = m_recordedSongModel->GetTargetNotes();

		// Advance our song model
		m_recordedSongModel->AdvanceModelByDeltaTimeSeconds( m_loopTimeDelta );
		
		NoteArrayRange currentTargetNotes = m_recordedSongModel->GetTargetNotes();
		
		// If the target notes changed
		if ( (currentTargetNotes.m_index != previousTargetNotes.m_index || 
			  currentTargetNotes.m_count != previousTargetNotes.m_count) )
		{
			
			if ( currentTargetNotes.m_count > 0 )
			{					
				// Play the audio associated with this new set of notes
				
				char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
				
				m_recordedSongModel->GetUnHitTargetNotesBytes(unHitNotes);
				
				for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
				{
					if ( unHitNotes[ str ] != GTAR_GUITAR_NOTE_OFF )
					{
						[m_audioController PluckStringFret:str atFret:unHitNotes[str]];

					}
				}
				
			}
			
		} 
		
		double time = m_recordedSongModel->GetCurrentTime();
		[self updateTimeDisplay:time];

		if ( m_recordedSongModel->IsEndOfSong()	)
		{
			[m_recButton setTitle:@"Record" forState:UIControlStateNormal];
			[m_recLabel setText:@"Stop"];
			
			m_isPlaying = NO;
		}

	}
	
	// backing track
	if ( m_isBacking && m_backingTrackSongModel != nil )
	{
		NoteArrayRange previousTargetNotes = m_backingTrackSongModel->GetTargetNotes();
		
		// Advance our song model
		m_backingTrackSongModel->AdvanceModelByDeltaTimeSeconds( m_loopTimeDelta );
		
		NoteArrayRange currentTargetNotes = m_backingTrackSongModel->GetTargetNotes();
		
		// If the target notes changed
		if ( (currentTargetNotes.m_index != previousTargetNotes.m_index || 
			  currentTargetNotes.m_count != previousTargetNotes.m_count) )
		{
			
			if ( currentTargetNotes.m_count > 0 )
			{					
				// Play the audio associated with this new set of notes
				
				char unHitNotes[ GUITAR_MODEL_STRING_COUNT ];
				
				m_backingTrackSongModel->GetUnHitTargetNotesBytes(unHitNotes);
				
				for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
				{
					if ( unHitNotes[ str ] != GTAR_GUITAR_NOTE_OFF )
					{
						[m_audioController PluckStringFret:str atFret:unHitNotes[str]];
						
						// Also save the backing track to the recorder
						if ( m_songRecorder.m_isRecording == YES )
						{
							// record this note to xmp
							[m_songRecorder playString:str andFret:unHitNotes[ str ]];
						}
					}
				}
				
			}
			
		} 
	
		// we are running on a loop, so just reset after we hit the end
		if ( m_backingTrackSongModel->IsEndOfSong() )
		{
			m_backingTrackSongModel->StartModelAtTime(0);
		}
		
	}
	
}

- (void)updateDisplay
{
	// nothing to do in this controller
}

#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	m_debugTouchPoint = [touch locationInView:self.view];
	
	m_screenTouched = YES;

}

- (void)displayModalForCacheEntry:(NSInteger)index
{
	
	if ( index > JAM_CACHE_SIZE )
	{
		return;
	}
	
	m_selectedSongDictionary = [self getEntryFromCache:index];
	
	NSString * songTitle = [self getTitleFromCache:index];
	
	[m_titleText setText:songTitle];
	
	// popup the preview screen
	[self animatePreviewModal:YES];
	
}

#pragma mark Modals

- (void)animateAmpModal:(BOOL)popup
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
		
		m_blackView.alpha = 0.8;
	}
	else 
	{
		// so hide it
		m_ampView.transform = CGAffineTransformMakeTranslation( 0, height );
		
		m_blackView.alpha = 0.0;
	}
	
	[UIView commitAnimations];
	
}

- (void)animateSlideRightModal:(BOOL)popup
{
	
	//NSInteger height = self.view.frame.size.height / 2 + AMP_HEIGHT;
	//NSInteger height = (self.view.frame.size.height - m_previewView.frame.size.height) / 2.0;
	//NSInteger width = (self.view.frame.size.width - m_previewView.frame.size.width) / 2.0;
	NSInteger right = 200;
	
	// slide the popup off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];

	if ( popup == YES )
	{
		// so make it visible
		m_slideView.transform = CGAffineTransformMakeTranslation( -right, 0 );
		
	}
	else 
	{
		// so hide it
		m_slideView.transform = CGAffineTransformMakeTranslation( 0, 0 );
		
	}
	
	[UIView commitAnimations];
	
}

- (void)animateSlideLeftModal:(BOOL)popup
{
	
	//NSInteger height = self.view.frame.size.height / 2 + AMP_HEIGHT;
	//NSInteger height = (self.view.frame.size.height - m_previewView.frame.size.height) / 2.0;
	//NSInteger width = (self.view.frame.size.width - m_previewView.frame.size.width) / 2.0;
	NSInteger left = 200;
	
	// slide the popup off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	
	if ( popup == YES )
	{
		// so make it visible
		m_slideView.transform = CGAffineTransformMakeTranslation( left, 0 );
		
	}
	else 
	{
		// so hide it
		m_slideView.transform = CGAffineTransformMakeTranslation( 0, 0 );

	}
	
	[UIView commitAnimations];
	
}


- (void)animatePreviewModal:(BOOL)popup
{
	
	//NSInteger height = self.view.frame.size.height / 2 + AMP_HEIGHT;
	//NSInteger height = (self.view.frame.size.height - m_previewView.frame.size.height) / 2.0;
	NSInteger width = (self.view.frame.size.width - m_previewView.frame.size.width) / 2.0;
	
	// we want to go down and just touch the top of the 'amp'
	// magic
	NSInteger height = 19;
	
	// slide the popup off the screen
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	
	if ( popup == YES )
	{
		// so make it visible
		m_previewView.transform = CGAffineTransformMakeTranslation( width, height );
		
		m_blackView.alpha = 0.8;
	}
	else 
	{
		// so hide it
		m_previewView.transform = CGAffineTransformMakeTranslation( width, -(m_previewView.frame.size.height) );
		
		m_blackView.alpha = 0.0;
	}
	
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

	// Return the number of rows in the section.
	if ( m_cachedSongs != nil )
	{
		return [m_cachedSongs count];
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//[[NSBundle mainBundle] loadNibNamed:@"PlayCell" owner:cell options:nil];
		cell.backgroundColor = [UIColor clearColor]; 
	}

	
	// Configure the cell...
	NSDictionary * entry = [self getEntryFromCache:[indexPath row]];
	NSString * songTitle = [self getTitleFromEntry:entry];
	NSNumber * length = [self getLengthFromEntry:entry];
	
	NSString * timeStr = [self formatTimeIntToString: [length unsignedIntValue]];
	
	[cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", songTitle, timeStr]];
	return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	// clear out all the old stale data
	[self clearStaleRecordedData];
	
	m_selectedSongDictionary = [self getEntryFromCache:[indexPath row] ];
	
	NSString * xmpBlob = [self getXmpFromCache:[indexPath row] ];
	NSLog(xmpBlob);

	m_recordedSongModel = new SongModel( xmpBlob );
	
	NSString * songTitle = [self getTitleFromCache:[indexPath row] ];
	[m_titleText setText:songTitle ];
	
	[self animatePreviewModal:YES];
}

#pragma mark -
#pragma mark Button click handling

- (IBAction)leftSlideButtonClicked:(id)sender
{
	if ( m_slide == NO )
	{
		m_slide = YES;
		[self animateSlideLeftModal:YES];
	}
	else 
	{
		m_slide = NO;
		[self animateSlideLeftModal:NO];
	}
}

- (IBAction)rightSlideButtonClicked:(id)sender
{
	if ( m_slide == NO )
	{
		m_slide = YES;
		[self animateSlideRightModal:YES];
	}
	else 
	{
		m_slide = NO;
		[self animateSlideRightModal:NO];
	}
}

- (IBAction)recordButtonClicked:(id)sender
{
	
	if ( m_multiplayerMode == JamControllerMultiplayerModeSinglePlayer || 
		m_multiplayerMode == JamControllerMultiplayerModeServer )
	{
		// If song is already recording, stop it.
		if ( m_isRecording == YES )
		{
			
			if ( m_multiplayerMode == JamControllerMultiplayerModeServer )
			{
				// alert the clients that we are stoping
				// TODO
				[self stopRecording];

				JamIntranetMultiplayerServer * server = (JamIntranetMultiplayerServer*)m_multiplayerController;
				
				[server stopRecording];
				
			}
			else 
			{
				[self stopRecording];
			
				[self saveRecordedXmpBlobToCache];
			
				[self displayModalForCacheEntry:0];
			}
			
		}
		else 
		{
			
			if ( m_multiplayerMode == JamControllerMultiplayerModeServer )
			{
				// alert the clients that we are starting
				JamIntranetMultiplayerServer * server = (JamIntranetMultiplayerServer*)m_multiplayerController;

				[server startRecording];

				// not until we get an ack
				//[self startRecording];

			}
			else 
			{
				[self startRecording];
			}
			
		}
	}
	// if you are the server, send the clients a message to tell them to record
	
	// button does nothing if you are a client
	
}

#pragma mark -
#pragma mark Helpers

- (void)updateTimeDisplay:(double)time
{
//	unsigned int intTime = (unsigned int)time;
	
	NSString * str = [self formatTimeIntToString:time];
	[m_timeLabel setText:str];
	
}

- (NSString*)formatTimeIntToString:(unsigned int)time
{
	unsigned int seconds = time % 60;
	unsigned int minutes = time / 60;
	
	return [NSString stringWithFormat:@"%02u:%02u", minutes, seconds];
}

- (void)changeRecordedSongTitle:(NSString*)newTitle
{

	if ( m_selectedSongDictionary != nil )
	{

		// get a song object from the old xmp
		NSString * xmpBlob = [self getXmpFromEntry:m_selectedSongDictionary];
		CSong * song = [SongParser songWithXmpBlob:xmpBlob];

		// change the name
		song->SetName([newTitle cString]);
		
		// convert it into a new xmp blob
		NSString * newBlob  = [[SongCreator xmpBlobWithSong:song] retain];
		NSLog(newBlob);

		// replace it in our entry
		[self replaceXmp:newBlob inEntry:m_selectedSongDictionary];
		[self replaceTitle:newTitle inEntry:m_selectedSongDictionary];
		
		// clear out all the old stale data
		[self clearStaleRecordedData];
		
		// reflect the new changes
		[m_cachedSongsTable reloadData];
		
	}
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSString * newTitle = textField.text;
	
	if ( [newTitle length] > 0 )
	{
		[self changeRecordedSongTitle:newTitle];
	}
	
	[textField resignFirstResponder];
	
	return NO;
}

#pragma mark -
#pragma mark JamPad delegate

-(void)jamPad:(JamPad*)jamPad positionChanged:(CGPoint)position
{
	char colorMap[GTAR_GUITAR_STRING_COUNT][3] = 
	{
		{3, 0, 0},
		{2, 1, 0},
		{3, 3, 0},
		{0, 3, 0},
		{0, 0, 3},
		{2, 0, 2}
	};
	
	unsigned int ypos = position.y;
	if ( ypos < GTAR_GUITAR_STRING_COUNT )
	{
		[m_guitarModel changeStateColorRed:colorMap[ypos][0]
								  andGreen:colorMap[ypos][1]
								   andBlue:colorMap[ypos][2] ];
	}
	else 
	{
		[m_guitarModel changeStateColorRed:3
								  andGreen:3
								   andBlue:3 ];
		
	}

	unsigned int xpos = position.x;
	if ( xpos < GTAR_GUITAR_STRING_COUNT )
	{
		[m_guitarModel changeFretFollowColorRed:colorMap[xpos][0]
									   andGreen:colorMap[xpos][1]
										andBlue:colorMap[xpos][2] ];
	}
	else 
	{
		[m_guitarModel changeFretFollowColorRed:3
									   andGreen:3
										andBlue:3 ];
		
	}
	
}

#pragma mark -
#pragma mark Recording

- (void)startRecording
{
	m_isRecording = YES;
	
	[m_recLabel setText:@"Rec"];
	[m_recButton setTitle:@"Stop" forState:UIControlStateNormal];
	
	// Clear out any old state from previous recording
	[self clearStaleRecordedData];
	
	m_songRecorder = [[SongRecorder alloc] init];
	
	[m_songRecorder beginSong];
}

- (void)stopRecording
{
	m_isRecording = NO;
	
	[m_recLabel setText:@"Stop"];
	[m_recButton setTitle:@"Record" forState:UIControlStateNormal];
	
	[m_songRecorder finishSong];
}


- (void)saveRecordedXmpBlobToCache
{
	
	NSString * xmpBlob = [self makeRecordedXmpBlob];

	double currentTime = m_songRecorder.m_currentTime;
	
	// insert this object to the front of the cache
	[self addToCacheXmp:xmpBlob andTitle:@"Jam Song" andLength:[NSNumber numberWithDouble:currentTime]];
	
	[m_cachedSongsTable reloadData];
	
}

- (NSString*)makeRecordedXmpBlob
{
	
	CSong * recordedSong = m_songRecorder.m_song;
	
	// Save the song's xmp to a file
	NSString * xmpBlob = [SongCreator xmpBlobWithSong:recordedSong];

	return xmpBlob;
	
}

- (void)clearStaleRecordedData
{
	if ( m_recordedSongModel != NULL )
	{
		delete m_recordedSongModel;
		m_recordedSongModel = NULL;
	}
}


#pragma mark -
#pragma mark JamIntranetMultiplayerClientDelegate, JamIntranetMultiplayerServerDelegate

// client
- (void)clientBeginSession:(JamIntranetMultiplayerClient *)client
{
	//[m_returnToController.navigationController pushViewController:self animated:YES];
}

- (void)clientEndSession:(JamIntranetMultiplayerClient *)client
{
	// pop us back to where we started.
	// this is basically a server-initiated back button click
	[self backButtonClicked];
}

- (void)client:(JamIntranetMultiplayerClient*)client startRecordingInTimeDelta:(double)delta
{
	[NSThread sleepForTimeInterval:delta];
	
	[self startRecording];
}

- (void)clientStopRecordingSendXmp:(JamIntranetMultiplayerClient*)client
{
	[self stopRecording];
	
	NSString * xmpBlob = [self makeRecordedXmpBlob];
	
	[client sendXmpBlobToServer:xmpBlob];
}

// server
- (void)server:(JamIntranetMultiplayerServer*)server mergedXmpCompleted:(NSString*)xmpBlob
{
	// TODO real time
	double currentTime = 0;

	NSString * localXmpBlob = [self makeRecordedXmpBlob];
	NSLog(xmpBlob);
	NSLog(localXmpBlob);
	NSString * mergedBlob = [SongMerger xmpBlobWithXmpBlob:localXmpBlob andXmpBlob:xmpBlob];

	NSLog(mergedBlob);
	// insert this object to the front of the cache
	[self addToCacheXmp:mergedBlob andTitle:@"Multiplayer Jam Song" andLength:[NSNumber numberWithDouble:currentTime]];
	
//	[m_cachedSongsTable reloadData];
	
//	[self saveRecordedXmpBlobToCache];
	
	[self displayModalForCacheEntry:0];
}

- (void)serverBeginRecording:(JamIntranetMultiplayerServer *)server
{
	[self startRecording];
}

#pragma mark Cache

- (NSString*)getXmpFromCache:(NSInteger)index
{
	NSDictionary * entry = [m_cachedSongs objectAtIndex:index];
	
	return [entry objectForKey:@"XmpBlob"];
}
- (NSString*)getLengthFromCache:(NSInteger)index
{
	NSDictionary * entry = [m_cachedSongs objectAtIndex:index];
	
	return [entry objectForKey:@"Length"];
}
- (NSString*)getTitleFromCache:(NSInteger)index
{
	NSDictionary * entry = [m_cachedSongs objectAtIndex:index];
	
	return [entry objectForKey:@"Title"];
}
- (NSDictionary*)getEntryFromCache:(NSInteger)index
{
	return [m_cachedSongs objectAtIndex:index];
}

- (NSString*)getXmpFromEntry:(NSDictionary*)entry
{
	return [entry objectForKey:@"XmpBlob"];
}
- (NSString*)getTitleFromEntry:(NSDictionary*)entry
{
	return [entry objectForKey:@"Title"];
}
- (NSNumber*)getLengthFromEntry:(NSDictionary*)entry
{
	return [entry objectForKey:@"Length"];
}


// cache is always LRU, so just stick it in front
- (void)addXmpToCache:(NSString*)xmpBlob
{
	[m_cachedSongs insertObject:xmpBlob atIndex:0];
	
	// if we have more than 10, remove the last object.
	// this just keeps our cache size reasonable.
	if ( m_cachedSongs.count > JAM_CACHE_SIZE )
	{
		[m_cachedSongs removeLastObject];
	}
	
	[self saveSongCache];
	
}

- (void)addToCacheXmp:(NSString*)xmpBlob andTitle:(NSString*)songTitle andLength:(NSNumber*)length
{
	NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
	
	[dict setObject:xmpBlob forKey:@"XmpBlob"];
	[dict setObject:songTitle forKey:@"Title"];
	[dict setObject:length forKey:@"Length"];
	
	[m_cachedSongs insertObject:dict atIndex:0];
	
	// if we have more than 10, remove the last object.
	// this just keeps our cache size reasonable.
	if ( m_cachedSongs.count > JAM_CACHE_SIZE )
	{
		[m_cachedSongs removeLastObject];
	}
	
	[self saveSongCache];
}

- (void)addSongToCache:(CSong*)song
{
	
}

- (void)removeXmpFromCache:(NSString*)xmpBlob
{
	
}

- (void)replaceXmpInCache:(NSString*)oldXmp withXmp:(NSString*)newXmp
{
	[m_cachedSongs removeObject:oldXmp];
	
	[m_cachedSongs insertObject:newXmp atIndex:0];
	
	[self saveSongCache];
}

- (void)replaceXmp:(NSString*)xmpBlob inEntry:(NSMutableDictionary*)entry
{
	[entry setObject:xmpBlob forKey:@"XmpBlob"];
}
- (void)replaceTitle:(NSString*)songTitle inEntry:(NSMutableDictionary*)entry
{
	[entry setObject:songTitle forKey:@"Title"];
}
- (void)replaceLength:(NSString*)length inEntry:(NSMutableDictionary*)entry
{
	[entry setObject:length forKey:@"Length"];
}


- (void)loadSongCache
{
	// load any cached songs
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:@"JamControllerCache.archive"];
	
	m_cachedSongs = [[NSKeyedUnarchiver unarchiveObjectWithFile:archivePath] retain];
	
	if ( m_cachedSongs == nil )
	{
		m_cachedSongs = [[NSMutableArray alloc] init];
	}
}	

- (void)saveSongCache
{
	// save this cache
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:@"JamControllerCache.archive"];
	
	[NSKeyedArchiver archiveRootObject:m_cachedSongs toFile:archivePath];
}


@end
