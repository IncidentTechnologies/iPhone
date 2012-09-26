//
//  SongViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongViewController.h"

#import "AudioController.h"
#import "GuitarController.h"
#import "TelemetryController.h"

#import <CloudController.h>
#import <UserController.h>
#import <UserResponse.h>
#import <UserSongSession.h>
#import <NSNote.h>
#import <NSSong.h>
#import <UserSong.h>
#import <SongRecorder.h>
#import <SongCreator.h>
#import <NSSongModel.h>
#import <NSNoteFrame.h>
#import <NSScoreTracker.h>

#import "SongDisplayController.h"
#import "AmpViewController.h"

#define CHORD_DELAY_TIMER (0.01f)

#define FRAME_TIMER_DURATION_MED (0.40f) // seconds
#define FRAME_TIMER_DURATION_EASY (0.06f) // seconds

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_MUFFLED 0.70f
#define AUDIO_CONTROLLER_AMPLITUDE_MUFFLED 0.15f

#define INTER_FRAME_QUIET_PERIOD (6.0/(float)m_song.m_tempo)

#define TEMP_BASE_SCORE 10

extern SongViewController * g_songViewController;
extern CloudController * g_cloudController;
extern GuitarController * g_guitarController;
extern UserController * g_userController;
extern AudioController * g_audioController;
extern TelemetryController * g_telemetryController;

@implementation SongViewController

@synthesize m_difficulty;
@synthesize m_tempoModifier;
@synthesize m_muffleWrongNotes;
@synthesize m_userSong;

@synthesize m_glView;
@synthesize m_connectingView;

@synthesize m_bSpeakerRoute;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        g_songViewController = self;
        
        // disable idle sleeping
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        NSString * soundFilePath = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
        NSURL * newURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
        
        NSError * error;
        
//        m_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:&error];
//        m_audioPlayer.numberOfLoops = 1;
//        
//        // Registers this class as the delegate of the audio session.
//        [[AVAudioSession sharedInstance] setDelegate: self];
//        
//        // Initialize the AVAudioSession here.
//        if ( ![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error] )
//        {
//            // Handle the error here.
//            NSLog(@"Audio Session error %@, %@", error, [error userInfo] );
//        }
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    // enable idle sleeping
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
//    [m_audioPlayer stop];
//    [m_audioPlayer release];
    
    g_songViewController = nil;
    
    [m_displayController cancelPreloading];
    [m_displayController release];
    [m_song release];
    [m_userSong release];
    [m_songModel release];
    [m_songRecorder release];
    [m_userSongSession release];
    
    [m_currentFrame release];
    [m_nextFrame release];
    
    [m_scoreTracker release];
    
    [m_progressView release];
    [m_ampView release];
    
    [m_glView release];
    [m_connectingView release];
    
    [m_interFrameDelayTimer invalidate];
    m_interFrameDelayTimer = nil;
    
    [m_delayedChordTimer invalidate];
    m_delayedChordTimer = nil;
    
    [m_metronomeTimer invalidate];
    m_metronomeTimer = nil;
    
    g_audioController.m_delegate = nil;
    
    [m_audioController stopAUGraph];
    [m_audioController reset];
    [m_audioController release];
    
    [self ignoreGuitarController:g_guitarController];
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    // The first time we load this up, parse the song
    if ( m_song == nil )
    {
        m_song = [[NSSong alloc] initWithXmlDom:m_userSong.m_xmlDom];
        
        [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode beginning song #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                                                             withType:TelemetryControllerMessageTypeInfo];
        
    }
    
    // Also create the AC using the instrument from the song
    if ( m_audioController == nil )
    {
        //m_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:m_song.m_instrument];
        //[m_audioController initializeAUGraph];
        m_audioController = [g_audioController retain];
        g_audioController.m_delegate = self;
        [m_audioController setSamplePackWithName:m_song.m_instrument];
    }

    // Do any additional setup after loading the view from its nib.
    m_progressView = [[SongProgressViewController alloc] initWithNibName:nil bundle:nil];
    
    [m_progressView attachToSuperview:self.view];
    
    //
    // setup the amp view
    //
    m_ampView = [[AmpViewController alloc] initWithNibName:nil bundle:nil];
    
    m_ampView.m_delegate = self;

    [m_ampView attachToSuperview:self.view];
    
    //
    // Set the audio routing destination
    //
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // We need to synch first in case the value was set the the Settings dialog
    [settings synchronize];
    
    // Temporarily set the bool to the opposite of the actual value
    m_bSpeakerRoute = ![settings boolForKey:@"RouteToSpeaker"];
    
    // Toggle the route so that its what we actually want
    [self toggleAudioRoute];
    
    // Init the UI
    [m_ampView resetView];
    [m_ampView updateView];
    
    [self.view addSubview:m_connectingView];
    
    // Observe the global guitar controller. This will call guitarConnected when it is connected.
    [self observeGuitarController:g_guitarController];
    
    // testing
    if ( g_guitarController.m_connected == NO )
    {
        [g_guitarController debugSpoofConnected];
    }
    
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_glView = nil;
    self.m_connectingView = nil;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self backButtonClicked];
}

#pragma mark - Misc stuff

- (void)startWithSongXmlDom
{
    
    [m_displayController cancelPreloading];
    [m_displayController release];
    [m_songModel release];
    [m_scoreTracker release];
    [m_currentFrame release];
    [m_songRecorder release];
    
    m_currentFrame = nil;
    
    //
    // start off the song stuff
    //    
    m_songModel = [[NSSongModel alloc] initWithSong:m_song];
    
    // Very small frame window
    m_songModel.m_frameWidthBeats = 0.1f;
    
    // Give a little runway to the player
    [m_songModel startWithDelegate:self andBeatOffset:-4.0];
    
    // Light up the first frame
    [self turnOnFrame:m_songModel.m_nextFrame];
    
    m_songRecorder = [[SongRecorder alloc] initWithTempo:m_song.m_tempo];
    
    [m_songRecorder beginSong];
    
    switch ( m_difficulty )
    {

        case SongViewControllerDifficultyEasy:
        {

            m_scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:10];

        } break;
    
        default:
        case SongViewControllerDifficultyMedium:
        {
        
            m_scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:20];

        } break;

        case SongViewControllerDifficultyHard:
        {
        
            NSInteger baseScore = 40 + 40 * m_tempoModifier;
            
            m_scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:baseScore];

        } break;

    }
    
    //
    // Init display 
    //
   
    m_displayController = [[SongDisplayController alloc] initWithSong:m_songModel andView:m_glView];

    // The enterFrame delegate method will be called if we are already in a frame
//    if ( m_currentFrame == nil )
//    {
//        [m_songModel skipToNextFrame];
//    }
    
    //
    // setup the amp view
    //
    m_ampView.m_scoreTracker = m_scoreTracker;
    m_ampView.m_songTitle = m_songModel.m_song.m_title;
    m_ampView.m_songArtist = m_songModel.m_song.m_author;
    
    //
    // setup the progress view
    //
    m_progressView.m_songModel = m_songModel;
    
    [m_progressView resetView];
    [m_progressView updateView];
        
    [m_ampView resetView];
    [m_ampView updateView];
    
    // An initial display render
    [m_displayController renderImage];
    
    m_animateSongScrolling = YES;
    
    if ( m_playMetronome == YES )
    {
        m_metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/m_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
    }
    
    [self startMainEventLoop];

}

- (void)pauseSong
{
    [m_ampView menuButtonClicked:nil];
}

- (void)interFrameDelayExpired
{
    
//    NSLog(@"Ending chord");
    
    [m_interFrameDelayTimer invalidate];
    
    m_interFrameDelayTimer = nil;
    
//    [m_songModel skipToNextFrame];
    [self songModelExitFrame:m_currentFrame];

}

- (void)disableInput
{
    m_ignoreInput = YES;
    [self performSelector:@selector(enableInput) withObject:nil afterDelay:INTER_FRAME_QUIET_PERIOD];
}

- (void)enableInput
{
    m_ignoreInput = NO;
}

#pragma mark - Main event loop
BOOL m_skipNotes = NO;

- (void)mainEventLoop
{
    
#ifdef Debug_BUILD
    // DEBUG tapping screen hits the current notes
    if ( m_skipNotes == YES )
    {
        
        m_skipNotes = NO;
        
//        if ( YES )
//        {
//            [self guitarNotesOnFret:15 andString:2];
//        } 
//        else
        if ( [m_songModel.m_currentFrame.m_notesPending count] > 0 )
        {
            NSNote * note = [m_songModel.m_currentFrame.m_notesPending objectAtIndex:0];
            
            [self guitarNotesOnFret:note.m_fret andString:note.m_string];
        }
        else if ( [m_songModel.m_nextFrame.m_notesPending count] > 0 )
        {
            NSNote * note = [m_songModel.m_nextFrame.m_notesPending objectAtIndex:0];
            
            [self guitarNotesOnFret:note.m_fret andString:note.m_string];
        }
        
        m_refreshDisplay = YES;
        
    }
#endif
    
    if ( m_delay > 0.0f )
    {
        [NSThread sleepForTimeInterval:m_delay];
        m_delay = 0.0f;
    }
    
    //
    // Advance song model and recorder
    //
    
//    if ( m_difficulty == SongViewControllerDifficultyHard )
//    {
//        // discounted by the tempo modifier
//        double effectiveTime = SECONDS_PER_EVENT_LOOP * m_tempoModifier;
//
//        [m_songModel incrementTimeSerialAccess:effectiveTime];
//        
//    }
    
    if ( m_animateSongScrolling == YES )
    {
        [m_songModel incrementTimeSerialAccess:SECONDS_PER_EVENT_LOOP];
    }
    
    // song recorder always records in real time
    [m_songRecorder advanceRecordingByTimeDelta:SECONDS_PER_EVENT_LOOP];
    
    //
    // Update displays
    //
    
    [m_progressView updateView];
    [m_ampView updateView];
    
    // Only refresh when we need to
//    if ( m_refreshDisplay == YES )
    if ( m_animateSongScrolling == YES || m_refreshDisplay == YES )
    {
        m_refreshDisplay = NO;
        [m_displayController renderImage];
    }
	
}

#pragma mark - Offline Guitar Handling

// This function is to be run on the main RunLoop thread.
- (void)guitarInputHandling:(NSDictionary*)dict
{
    
    // This should only be used sparingly, but sometimes we 
    // just want to completely drop the input e.g. in certain 
    // chord strumming situations.
    if ( m_ignoreInput == YES )
    {
        return;
    }
    
    m_refreshDisplay = YES;
    
    NSNumber * value;
    
    value = [dict objectForKey:@"String"];
    GuitarString str = [value integerValue];
    
    value = [dict objectForKey:@"Fret"];
    GuitarString fret = [value integerValue];
    
    // Tell the user that the input is working
    [m_ampView flickerIndicator];
    
    if ( m_currentFrame == nil )
    {
        [m_songModel skipToNextFrame];
    }
    
    NSNote * hit;
    
    if ( m_difficulty == SongViewControllerDifficultyEasy )
    {
        hit = [m_currentFrame hitTestAndRemoveStringOnly:str];
//        hit = [m_nextFrame hitTestAndRemoveStringOnly:str];
    }
    else
    {
        hit = [m_currentFrame hitTestAndRemoveString:str andFret:fret];
//        hit = [m_nextFrame hitTestAndRemoveString:str andFret:fret];
    }
    
    // Handle the hit
    if ( hit != nil )
    {
        [self correctHitFret:hit.m_fret andString:hit.m_string];
    }
    else
    {
        [self incorrectHitFret:fret andString:str];
    }
    
}

#pragma mark - GuitarControllerObserver

// The MIDI run loop is in a different thread than the main thread, so there 
// is some funny behavior when certain things are done in here. Especially
// things having to do with NSTimers and UI manipulation. The safest things is 
// to just run everything in the main thread.
- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{

//    NSLog(@"Guitar on %u %u", fret, str);
    
    // If we are not running (i.e. paused) then we ignore input from the midi
    if ( m_isRunning == NO )
    {
        return;
    }
    
    // This selector is called from the midi stack running in a separate thread.
    // We need to be running in the main thread in order to do anything UI related,
    // so we need to schedule a work item to run for us
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSNumber * strValue = [[NSNumber alloc] initWithInteger:str];
    NSNumber * fretValue = [[NSNumber alloc] initWithInteger:fret];
    
    [dict setObject:strValue forKey:@"String"];
    [dict setObject:fretValue forKey:@"Fret"];
    
    // Run in the main thread
    [self performSelectorOnMainThread:@selector(guitarInputHandling:)
                           withObject:dict
                        waitUntilDone:YES];
    
    [strValue release];
    [fretValue release];
    [dict release];
        
}

- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarConnected
{
    
    NSLog(@"SongViewController: gTar has been connected");
    
    [m_connectingView removeFromSuperview];
    
    [m_guitarController setMinimumInterarrivalTime:0.10f];
    
    [self startWithSongXmlDom];
    
}

- (void)guitarDisconnected
{
    
    NSLog(@"SongViewController: gTar has been disconnected");
    
    [self backButtonClicked:nil];
    
}

#pragma mark - Various helpers

// These functions need to be called from the main thread RunLoop.
// If they are called from a MIDI interrupt thread, stuff won't work properly.
- (void)correctHitFret:(GuitarFret)fret andString:(GuitarString)str
{
    
    // set it to the correct attenuation
    if ( m_interFrameDelayTimer == nil )
    {
                
        // Play the note
        [self pluckString:str andFret:fret];
        
        // Record the note
        [m_songRecorder playString:str andFret:fret];
    }
    
    [self turnOffString:str andFret:fret];
    
    //
    // Begin a frame timer if there are any more note left
    //
    if ( [m_currentFrame.m_notesPending count] > 0 )
    {
        
        //
        // This block of code handles chords
        //
        
        // If there is already a timer pending, we don't need to create another one
        if ( m_interFrameDelayTimer == nil )
        {
            
            for ( NSInteger index = 0; index < GTAR_GUITAR_STRING_COUNT; index++ )
            {
                m_delayedChords[index] = GTAR_GUITAR_NOTE_OFF;
            }
            
            // Play the notes up front
            for ( NSNote * note in m_currentFrame.m_notesPending )
            {
                m_delayedChords[note.m_string-1] = note.m_fret;
            }
            
            // Schedule an event to play the chords over time
            m_delayedChordsCount = 6;
            m_delayedChordTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_DELAY_TIMER target:self selector:@selector(handleDelayedChord) userInfo:nil repeats:NO];
            
            // Schedule an event to push us to the next frame after a moment
            m_interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.100 target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
            
            m_previousChordPluckTime = CACurrentMediaTime();
            m_previousChordPluckString = str;
            m_previousChordPluckDirection = 0;
            
        }
        else
        {
            // See if we are changing the direction
            [self handleDirectionChange:str];
            
        }
        
    }
    else
    {
        //
        // There are no notes left in this frame, skip along.
        //
//        [m_songModel skipToNextFrame];
//        [self songModelExitFrame:m_currentFrame];
        m_animateSongScrolling = YES;
        
        //
        // We want to kill the timer so we don't get a "double-skip"
        //
        if ( m_interFrameDelayTimer != nil )
        {
            [m_interFrameDelayTimer invalidate];
            m_interFrameDelayTimer = nil;
        }
        
    }

}

- (void)incorrectHitFret:(GuitarFret)fret andString:(GuitarString)str
{
//    NSLog(@"Incorrect on %u %u", fret, str);
    
    // See if we are trying to play a new chord
    if ( m_interFrameDelayTimer != nil )
    {
        [self handleDirectionChange:str];
    }
    
    if ( m_difficulty != SongViewControllerDifficultyEasy )
    {
        
        if ( m_difficulty == SongViewControllerDifficultyMedium )
        {
            // Play the note, but muffled
//            [m_audioController PluckMutedString:str - 1];
        }
        else if ( m_difficulty == SongViewControllerDifficultyHard )
        {
            // Play the note at normal intensity
            [self pluckString:str andFret:fret];
            
            // Record the note
            [m_songRecorder playString:str andFret:fret];
        }
        
    }

}

- (void)handleDirectionChange:(GuitarString)str
{
    
    // Check for direction changes
    NSInteger stringDelta = str - m_previousChordPluckString;
    
    m_previousChordPluckString = str;
    
    // The same string was plucked twice, change in direction
    if ( stringDelta == 0 )
    {
//        NSLog(@"Same note in a row");
        [self interFrameDelayExpired];
    }
    
    // We are going 'down'
    if ( stringDelta > 0 )
    {
        // We were going 'up'
        if ( m_previousChordPluckDirection < 0 )
        {
//            NSLog(@"Changed direction: up->down");
            [self interFrameDelayExpired];
        }
        else
        {
            // Save the direction and reset the timer
//            NSLog(@"Going down, reup the timer");
            m_previousChordPluckDirection = +1;
            [m_interFrameDelayTimer invalidate];
            m_interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.100 target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
        }
    }
    
    // We are going 'up'
    if ( stringDelta < 0 )
    {
        // We were going 'down'
        if ( m_previousChordPluckDirection > 0 )
        {
//            NSLog(@"Changed direction: down->up");
            [self interFrameDelayExpired];
        }
        else
        {
            // Save the direction and reset the timer
//            NSLog(@"Going up, reup the timer");
            m_previousChordPluckDirection = -1;
            [m_interFrameDelayTimer invalidate];
            m_interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.100 target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
        }
    }
    
}

- (void)handleDelayedChord
{
    
    [m_delayedChordTimer invalidate];
    m_delayedChordTimer = nil;
    
    if ( m_delayedChordsCount <= 0 )
    {
        return;
    }
    
    GuitarString str = m_delayedChordsCount;
    
    m_delayedChordsCount--;
    
    GuitarFret fret = m_delayedChords[str-1];
    
    if ( m_delayedChordsCount > 0 )
    {
        m_delayedChordTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_DELAY_TIMER target:self selector:@selector(handleDelayedChord) userInfo:nil repeats:NO];
    }
    
    if ( fret != GTAR_GUITAR_NOTE_OFF )
    {
        
        // Play the note
        [self pluckString:str andFret:fret];
        
        // Record the note
        [m_songRecorder playString:str andFret:fret];
    }
    
}

- (void)turnOnFrame:(NSNoteFrame*)frame
{
    
    for ( NSNote * note in frame.m_notes )
    {
        [self turnOnString:note.m_string andFret:note.m_fret];
    }
    
}

- (void)turnOnFrameWhite:(NSNoteFrame*)frame
{
    
    for ( NSNote * note in frame.m_notes )
    {
        [self turnOnWhiteString:note.m_string andFret:note.m_fret];
    }
    
}

- (void)turnOffFrame:(NSNoteFrame*)frame
{
    
    for ( NSNote * note in frame.m_notes )
    {
        [self turnOffString:note.m_string andFret:note.m_fret];
    }
    
}

- (void)turnOnString:(GuitarString)str andFret:(GuitarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [m_guitarController turnOnLedWithColorMappingAtString:str andFret:0];
    }
    else
    {
        [m_guitarController turnOnLedWithColorMappingAtString:str andFret:fret];
    }
    
}

- (void)turnOnWhiteString:(GuitarString)str andFret:(GuitarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [m_guitarController turnOnLedAtString:str andFret:fret withRed:3 andGreen:3 andBlue:3];
    }
    else
    {
        [m_guitarController turnOnLedAtString:str andFret:fret withRed:3 andGreen:3 andBlue:3];
    }
    
}

- (void)turnOffString:(GuitarString)str andFret:(GuitarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [m_guitarController turnOffLedAtString:str andFret:0];
    }
    else
    {
        [m_guitarController turnOffLedAtString:str andFret:fret];
    }
    
}

- (void)pluckString:(GuitarString)str andFret:(GuitarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [m_audioController PluckMutedString:str - 1];
    }
    else
    {
        [m_audioController PluckString:str-1 atFret:fret];
    }
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame
{
    
    [m_currentFrame release];
    
    m_currentFrame = [frame retain];
    
//    if ( m_difficulty == SongViewControllerDifficultyHard )
//    {
//        [self turnOnFrameWhite:frame];
//    }
//    else
//    {
//        [self turnOnFrame:frame];
//    }
    
    // Align us more pefectly with the frame
    [m_songModel incrementBeatSerialAccess:(frame.m_absoluteBeatStart - m_songModel.m_currentBeat)];
    
    m_refreshDisplay = YES;
    
    m_animateSongScrolling = NO;
    
}

- (void)songModelExitFrame:(NSNoteFrame*)frame
{
    
    [m_currentFrame release];
    
    m_currentFrame = nil;
    
    // account the score for this frame
    [m_scoreTracker scoreFrame:frame];
    
    // turn off any lights that might have been skipped
    [self turnOffFrame:frame];
    
    // turn on the next frame
    [self turnOnFrame:m_nextFrame];
    
    [self disableInput];
    
//    if ( m_difficulty == SongViewControllerDifficultyHard )
//    {
//        [self turnOnFrame:m_nextFrame];
//    }
    
    m_refreshDisplay = YES;
    
    m_animateSongScrolling = YES;
    
}

- (void)songModelNextFrame:(NSNoteFrame*)frame
{
    
    [m_nextFrame release];
    
    m_nextFrame = [frame retain];
    
//    [self turnOnFrame:m_nextFrame];
    
}

- (void)songModelFrameExpired:(NSNoteFrame*)frame
{
    
    if ( m_difficulty == SongViewControllerDifficultyEasy )
    {
        // On easy mode, we play the notes that haven't been hit yet
        for ( NSNote * note in frame.m_notesPending )
        {
            [self pluckString:note.m_string andFret:note.m_fret];
        }

        [self songModelExitFrame:m_currentFrame];
        
    }
    else if ( m_difficulty == SongViewControllerDifficultyMedium || 
              m_difficulty == SongViewControllerDifficultyHard )
    {
        // On medium/hard mode, we don't play anything. The lack of sound is punishment enough.
        
//        [m_songModel skipToNextFrame];
        [self songModelExitFrame:m_currentFrame];
        
    }
    
    // Refresh the display to show the new state
    m_refreshDisplay = YES;
    
}

- (void)songModelEndOfSong
{
    
    [self stopMainEventLoop];
    
    // Turn of the LEDs
    [m_guitarController turnOffAllLeds];
    
    [m_songRecorder finishSong];
    
    [m_metronomeTimer invalidate];
    m_metronomeTimer = nil;
    
    [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode ending song #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                             withType:TelemetryControllerMessageTypeInfo];
    
    UserSongSession * session = [[UserSongSession alloc] init];
    
    session.m_userSong = m_userSong;
    session.m_score = m_scoreTracker.m_score;
    session.m_stars = m_scoreTracker.m_stars;
    session.m_combo = m_scoreTracker.m_streak;
    session.m_notes = @"Recorded in gTar Play";
    
    //
    // Save the scores/stars to persistent storage
    //
    [g_userController addStars:m_scoreTracker.m_stars forSong:m_userSong.m_songId];
    [g_userController addScore:m_scoreTracker.m_score forSong:m_userSong.m_songId];
    
    m_songRecorder.m_song.m_instrument = m_song.m_instrument;
    
    // Create the xmp
    // TODO it would be great if we didn't need CSong as an intermidiary
    CSong * song = [m_songRecorder.m_song convertToCSong];
    
    session.m_xmpBlob = [SongCreator xmpBlobWithSong:song];
    
    delete song;
    
    [m_userSongSession release];
    
    m_userSongSession = [session retain];

    m_userSongSession.m_created = time(NULL);
    
    [m_ampView displayScore];
    [m_progressView hideProgressView];
    
}

#pragma mark - Cloud callbacks

- (void)requestUploadUserSongSessionCallback:(UserResponse*)userResponse
{
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        // Stop spinning the thing
        [m_ampView shareSucceeded];
    }
    else
    {
        // Also stop, but say something extra
        [m_ampView shareFailed];
    }
        
}

#pragma mark - Amp Delegate

- (void)menuButtonClicked
{
    
    [self stopMainEventLoop];
    
    [m_metronomeTimer invalidate];
    m_metronomeTimer = nil;
    
    [m_progressView hideProgressView];
    
}

- (void)backButtonClicked
{
    
    [m_metronomeTimer invalidate];
    m_metronomeTimer = nil;
    
    [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode exiting #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                             withType:TelemetryControllerMessageTypeInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)restartButtonClicked
{

    [m_audioController reset];
    [m_guitarController turnOffAllLeds];
    [m_displayController shiftView:0];
    
    [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode restarting song #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                             withType:TelemetryControllerMessageTypeInfo];
    
    [self startWithSongXmlDom];
    
    [m_progressView showProgressView];
    
}

- (void)continueButtonClicked
{
    
    [m_progressView showProgressView];
    
    if ( m_playMetronome == YES )
    {
        m_metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/m_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
    }
    
    [self startMainEventLoop];
    
}

- (void)shareButtonClicked
{
    
    // Upload song to server. This also persists the upload in case of failure
    [g_userController requestUserSongSessionUpload:m_userSongSession andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    
    [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode sharing song #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                             withType:TelemetryControllerMessageTypeInfo];

}

- (void)toggleAudioRoute
{
    
    if (m_bSpeakerRoute)
    {
        [m_audioController RouteAudioToDefault];
        m_bSpeakerRoute = NO;
        [m_ampView disableSpeaker];
        [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode speaker off #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                                 withType:TelemetryControllerMessageTypeInfo];

    }
    else
    {
        [m_audioController RouteAudioToSpeaker];
        m_bSpeakerRoute = YES;
        [m_ampView enableSpeaker];
        [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode speaker on #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                                 withType:TelemetryControllerMessageTypeInfo];
    }
    
    // The global volume slider is not available when audio is routed to lineout. 
    // If the audio is not being outputed to lineout hide the global volume slider,
    // and display our own slider that controlls volume in this mode.
    NSString * routeName = (NSString *)[m_audioController GetAudioRoute];
    
    if ([routeName isEqualToString:@"LineOut"])
    {
        [[m_ampView m_volumeSlider] setHidden:NO];
        [[m_ampView m_volumeView] setHidden:YES];
    }
    else
    {
        [[m_ampView m_volumeSlider] setHidden:YES];
        [[m_ampView m_volumeView] setHidden:NO];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:m_bSpeakerRoute forKey:@"RouteToSpeaker"];
    
    [settings synchronize];
    
}

- (void)toggleMetronome
{
    
    if ( m_playMetronome == NO )
    {
        m_playMetronome = YES;
        [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode metronome on #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                                 withType:TelemetryControllerMessageTypeInfo];
    }
    else
    {
        m_playMetronome = NO;
        [g_telemetryController logMessage:[NSString stringWithFormat:@"PlayMode metronome off #%u '%@' difficulty: %u percent: %f", m_userSong.m_songId, m_userSong.m_title, m_difficulty, m_songModel.m_percentageComplete]
                                 withType:TelemetryControllerMessageTypeInfo];
    }
    
}

- (void)playMetronomeTick
{
    [g_audioController PluckMutedString:0];
//    [m_audioPlayer play];
    
}

- (void)setVolumeGain:(float)gain
{
    [m_audioController setM_volumeGain:gain];
}

#pragma mark - AudioControllerDelegate

-(void)audioRouteChanged:(bool)routeIsSpeaker
{
    m_bSpeakerRoute = routeIsSpeaker;
    
    if (m_bSpeakerRoute)
    {
        [m_ampView enableSpeaker];
    }
    else
    {
        [m_ampView disableSpeaker];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:m_bSpeakerRoute forKey:@"RouteToSpeaker"];
    
    [settings synchronize];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];

    // If double-tap reset the shift to zero
    if ( [touch tapCount] == 2 )
    {
        [m_displayController shiftView:0];
        m_refreshDisplay = YES;
    }
    
	m_skipNotes = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    CGFloat delta = currentPoint.x - previousPoint.x;
    
    [m_displayController shiftViewDelta:-delta];
    
    m_refreshDisplay = YES;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

@end
