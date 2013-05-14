//
//  PlayViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import "PlayViewController.h"
#import "VolumeViewController.h"

#import <AudioController/AudioController.h>
#import <GtarController/GtarController.h>

#import <gTarAppCore/TelemetryController.h>

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/SongRecorder.h>
#import <gTarAppCore/NSSongCreator.h>
#import <gTarAppCore/NSSongModel.h>
#import <gTarAppCore/NSNote.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSNoteFrame.h>
#import <gTarAppCore/NSScoreTracker.h>

#import "SongDisplayController.h"
#import "AmpViewController.h"
#import "UIButton+Gtar.h"

//#define FRAME_TIMER_DURATION_MED (0.40f) // seconds
//#define FRAME_TIMER_DURATION_EASY (0.06f) // seconds

#define CHORD_DELAY_TIMER 0.010f
#define CHORD_GRACE_PERIOD 0.100f

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_MUFFLED 0.70f
#define AUDIO_CONTROLLER_AMPLITUDE_MUFFLED 0.15f

#define NOTE_DEFERMENT_TIME 0.040f
#define INTER_FRAME_QUIET_PERIOD (0.60/(float)_song.m_tempo)

#define TEMP_BASE_SCORE 10

extern CloudController * g_cloudController;
extern GtarController * g_gtarController;
extern UserController * g_userController;
extern AudioController * g_audioController;
extern TelemetryController * g_telemetryController;

@interface PlayViewController ()
{
    SongDisplayController *_displayController;
    
    VolumeViewController *_volumeViewController;
    
    BOOL _animateSongScrolling;
    
    NSSong *_song;
    
    NSSongModel *_songModel;
    
    SongRecorder *_songRecorder;
    
    NSNoteFrame *_currentFrame;
    NSNoteFrame *_nextFrame;
    
    NSScoreTracker *_scoreTracker;
    
    BOOL _refreshDisplay;
    BOOL _ignoreInput;
    BOOL _playMetronome;
    
    NSTimer *_interFrameDelayTimer;
    NSTimer *_delayedChordTimer;
    NSTimer *_metronomeTimer;
    
    GtarString _previousChordPluckString;
    GtarPluckVelocity _previousChordPluckVelocity;
    NSInteger _previousChordPluckDirection;
    
    NSInteger _delayedChordsCount;
    GtarFret _delayedChords[GTAR_GUITAR_STRING_COUNT];
    
    NSMutableArray *_deferredNotesQueue;
    
    NSDate *_playTimeStart;
    NSDate *_audioRouteTimeStart;
    NSDate *_metronomeTimeStart;
    NSTimeInterval _playTimeAdjustment;
    
    BOOL _speakerRoute;

    BOOL _skipNotes;
    
    BOOL _menuIsOpen;

}

@end

@implementation PlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
        _playTimeAdjustment = 0;
        
        _playTimeStart = [[NSDate date] retain];
        _audioRouteTimeStart = [[NSDate date] retain];
        _metronomeTimeStart = [[NSDate date] retain];
        
        // disable idle sleeping
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Hide the widgets we don't need initially
    [_menuDownArrow setHidden:YES];
    [_finishButton setHidden:YES];
    [_progressFillView setHidden:YES];
    
    // Fiddle with the button images
//    [_menuButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [_volumeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    // Fiddle with the switch images
    _outputSwitch.thumbTintColor = [[UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0] retain];
    _outputSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    _outputSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    _feedSwitch.thumbTintColor = [[UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0] retain];
    _feedSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    _feedSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    // Setup the loading screen
    _loadingView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _loadingView.layer.borderWidth = 2.0;
    
    // Fill in song info
    _loadingLicenseInfo.text = _userSong.m_licenseInfo;
    _loadingSongInfo.text = [[NSString stringWithFormat:@"%@ - %@", _userSong.m_author, _userSong.m_title] retain];
    
    // Hide the glview till it is done loading
    _glView.hidden = YES;
    
    [self updateDifficultyDisplay];
    
    // testing
//#ifdef Debug_BUILD
//    if ( g_gtarController.connected == NO )
//    {
//        NSLog(@"debugging this thing");
//        
//        [NSTimer scheduledTimerWithTimeInterval:1.0 target:g_gtarController selector:@selector(debugSpoofConnected) userInfo:nil repeats:NO];
//    }
//#endif
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Pass the new target frame to the volume slider, now that we resized
    CGRect targetFrame = [_topBar convertRect:_volumeSliderView.frame toView:self.view];
    
    [_volumeViewController setFrame:targetFrame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Setup the menu
    [self.view addSubview:_menuView];
    
    [_menuView setFrame:self.view.frame];
    [_menuView setBounds:self.view.bounds];
    
    _menuIsOpen = NO;
    
    _menuView.transform = CGAffineTransformMakeTranslation( 0, -self.view.frame.size.height );
    
    // Attach the volume view controller
    CGRect targetFrame = [_topBar convertRect:_volumeSliderView.frame toView:self.view];
    
    _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil];
    
    [_volumeViewController attachToSuperview:self.view withFrame:targetFrame];
    
    // Make sure the top bar stays on top
    [self.view bringSubviewToFront:_topBar];
    
    [self performSelectorOnMainThread:@selector(delayedLoaded) withObject:nil waitUntilDone:NO];
}

- (void)delayedLoaded
{
    // We want the main thread to finish running the above and updating the views
    // before this stuff runs. It will take awhile, and we want the user
    // to see all the views while they wait.
    
    // The first time we load this up, parse the song
    _song = [[NSSong alloc] initWithXmlDom:_userSong.m_xmlDom];
    
    // Also create the AC using the instrument from the song
    g_audioController.m_delegate = self;
    
    // We let the previous screen set the sample pack of this song.
//    [g_audioController setSamplePackWithName:_song.m_instrument];
    [g_audioController startAUGraph];
    
    //
    // Set the audio routing destination
    //
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // We need to synch first in case the value was set the the Settings dialog
    [settings synchronize];
    
    // Temporarily set the bool to the opposite of the actual value
    _speakerRoute = ![settings boolForKey:@"RouteToSpeaker"];
    
    // Toggle the route so that its what we actually want
    [self toggleAudioRoute];
    [self updateAudioState];
    
    // Observe the global guitar controller. This will call guitarConnected when it is connected.
    // This in turn starts the game mode.
    [g_gtarController addObserver:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    // enable idle sleeping
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [g_gtarController turnOffAllLeds];
    [g_gtarController removeObserver:self];
    
    [_displayController cancelPreloading];
    [_displayController release];
    [_volumeViewController release];
    
    [_song release];
    [_userSong release];
    [_songModel release];
    [_songRecorder release];
    
    [_currentFrame release];
    [_nextFrame release];
    
    [_scoreTracker release];
    
    [_interFrameDelayTimer invalidate];
    _interFrameDelayTimer = nil;
    
    [_delayedChordTimer invalidate];
    _delayedChordTimer = nil;
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    [_deferredNotesQueue release];
    
    [_playTimeStart release];
    
    [_audioRouteTimeStart release];
    
    [_metronomeTimeStart release];
    
    g_audioController.m_delegate = nil;
    
    [g_audioController stopAUGraph];
    [g_audioController reset];
    
    [_glView release];
    [_menuView release];
    [_topBar release];
    [_menuButton release];
    [_backButton release];
    [_volumeButton release];
    
    [_scoreLabel release];
    [_progressFillView release];
    [_songTitleLabel release];
    [_songArtistLabel release];
    [_completionLabel release];
    [_finishButton release];
    [_outputView release];
    [_postToFeedView release];
    
//    [_feedSwitch.thumbTintColor release];
    [_feedSwitch release];
    
//    [_outputSwitch.thumbTintColor release];
    [_outputSwitch release];
    
    [_loadingView release];
    [_loadingLicenseInfo release];
    [_loadingSongInfo release];
    [_difficultyButton release];
    [_difficultyLabel release];
    [_instrumentButton release];
    [_instrumentLabel release];
    [_volumeSliderView release];
    [_menuDownArrow release];
    [super dealloc];
}

#pragma mark - Button click handlers

- (IBAction)backButtonClicked:(id)sender
{
    
    // If the finish button is visible (i.e. we are done) we want
    // to shortcut there instead.
    // I'm disabling the cancel button now, don't need this.
//    if ( _finishButton.isHidden == NO )
//    {
//        [self finishButtonClicked:nil];
//        
//        return;
//    }
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarPlaySongAborted
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                     _userSong.m_title, @"Title",
                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                     nil]];
    
    [self finalLogging];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)volumeButtonClicked:(id)sender
{
    [_volumeViewController toggleView:YES];
}

- (IBAction)finishButtonClicked:(id)sender
{
    // Stop the metronome from running
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    // Log our final state before exiting
    [self finalLogging];
    
    if ( _feedSwitch.isOn == YES )
    {
        UserSongSession * session = [[UserSongSession alloc] init];
        
        session.m_userSong = _userSong;
        session.m_score = _scoreTracker.m_score;
        session.m_stars = _scoreTracker.m_stars;
        session.m_combo = _scoreTracker.m_streak;
        session.m_notes = @"Recorded in gTar Play";
        
//        _songRecorder.m_song.m_instrument = _song.m_instrument;
        _songRecorder.m_song.m_instrument = [[g_audioController getInstrumentNames] objectAtIndex:[g_audioController getCurrentSamplePackIndex]];
        
        // Create the xmp
        session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
        session.m_created = time(NULL);
        
        // Upload song to server. This also persists the upload in case of failure
        [g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
        
        [g_telemetryController logEvent:GtarPlaySongShared
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                         _userSong.m_title, @"Title",
                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                         nil]];
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)menuButtonClicked:(id)sender
{
    
    _menuIsOpen = !_menuIsOpen;
    
    // Close the volume everytime we push the menu button
    [_volumeViewController closeView:YES];
    
    if ( _menuIsOpen == YES )
    {
        [_metronomeTimer invalidate];
        _metronomeTimer = nil;
        
        [_menuDownArrow setHidden:NO];
        
        [self stopMainEventLoop];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        _menuView.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
    }
    else
    {
        if ( _playMetronome == YES )
        {
            _metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
        }
        
        [self startMainEventLoop];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(menuSlideComplete)];
        
        _menuView.transform = CGAffineTransformMakeTranslation( 0, -_menuView.frame.size.height );
        
        [UIView commitAnimations];
    }
}

- (IBAction)restartButtonClicked:(id)sender
{
    
    [g_audioController reset];
    [g_gtarController turnOffAllLeds];
    [_displayController shiftView:0];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarPlaySongRestarted
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                     _userSong.m_title, @"Title",
                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                     nil]];
    
    [self startWithSongXmlDom];
    
    [self menuButtonClicked:nil];
    
}

- (IBAction)outputSwitchChanged:(id)sender
{
    [self toggleAudioRoute];
}

- (IBAction)feedSwitchChanged:(id)sender
{
    
}

- (IBAction)difficultyButtonClicked:(id)sender
{
    
    switch ( _difficulty )
    {
        default:
        case PlayViewControllerDifficultyEasy:
        {
            _difficulty = PlayViewControllerDifficultyMedium;
            _scoreTracker.m_baseScore = 20;
        } break;
            
        case PlayViewControllerDifficultyMedium:
        {
            _difficulty = PlayViewControllerDifficultyHard;
            _scoreTracker.m_baseScore = 40;
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            _difficulty = PlayViewControllerDifficultyEasy;
            _scoreTracker.m_baseScore = 10;
        } break;
    }

    [self updateDifficultyDisplay];
}

- (IBAction)instrumentButtonClicked:(id)sender {
}

#pragma mark - UI & Misc related helpers

- (void)handleResignActive
{
    [self pauseSong];
    
    _playTimeAdjustment += [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970];
}

- (void)handleBecomeActive
{
    [_playTimeStart release];
    [_audioRouteTimeStart release];
    [_metronomeTimeStart release];
    
    _playTimeStart = [[NSDate date] retain];
    _audioRouteTimeStart = [[NSDate date] retain];
    _metronomeTimeStart = [[NSDate date] retain];
}

- (void)removeLoadingView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6f];
//    [UIView setAnimationDelegate:_loadingView];
//    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    
    _loadingView.alpha = 0.0f;
    
    [UIView commitAnimations];
    
    [self startMainEventLoop];
}

- (void)revealPlayView
{
    _glView.alpha = 0.0f;
    _glView.hidden = NO;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6f];

    _glView.alpha = 1.0f;
    
    [UIView commitAnimations];
}

- (void)menuSlideComplete
{
    [_menuDownArrow setHidden:YES];
}

- (void)startLicenseScroll
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2.0f];
    
    [_loadingLicenseInfo setContentOffset:CGPointMake(0, MAX(_loadingLicenseInfo.contentSize.height-_loadingLicenseInfo.frame.size.height, 0) )];
    
    [UIView commitAnimations];
}

- (void)toggleAudioRoute
{
    
    _speakerRoute = !_speakerRoute;
    
    if ( _speakerRoute == YES)
    {
        [g_audioController RouteAudioToSpeaker];
    }
    else
    {
        [g_audioController RouteAudioToDefault];
    }
    
}

- (void)updateAudioState
{
    
    if ( _speakerRoute == YES )
    {
        [_outputSwitch setOn:YES];
        [_volumeViewController enableAppleSlider];
    }
    else
    {
        [_outputSwitch setOn:NO];
        
        // The global volume slider is not available when audio is routed to LineOut.
        // If the audio is not being output to LineOut, hide the global volume slider,
        // and display our own slider that controls volume in this mode.
        NSString * routeName = (NSString *)[g_audioController GetAudioRoute];

        if ([routeName isEqualToString:@"LineOut"])
        {
            [_volumeViewController enableManualSlider];
        }
        else
        {
            [_volumeViewController enableAppleSlider];
        }
    }
    
    // Invert it so we log the route we came from
    NSString * route = !_speakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_audioRouteTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    if ( delta > 0 )
    {
        [g_telemetryController logEvent:GtarPlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                         _userSong.m_title, @"Title",
                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                         route, @"AudioRoute",
                                         nil]];
        
        [_audioRouteTimeStart release];
        _audioRouteTimeStart = [[NSDate date] retain];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:_speakerRoute forKey:@"RouteToSpeaker"];
    
    [settings synchronize];
    
}

- (void)toggleMetronome
{
    
    if ( _playMetronome == NO )
    {
        
        _playMetronome = YES;
        
        [g_telemetryController logEvent:GtarPlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                         _userSong.m_title, @"Title",
                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                         @"On", @"Metronome",
                                         nil]];
        
        [_metronomeTimeStart release];
        _metronomeTimeStart = [[NSDate date] retain];
        
    }
    else
    {
        _playMetronome = NO;
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_metronomeTimeStart timeIntervalSince1970] + _playTimeAdjustment;
        
        [g_telemetryController logEvent:GtarPlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                         _userSong.m_title, @"Title",
                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                         @"Off", @"Metronome",
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         nil]];
        
        [_metronomeTimeStart release];
        _metronomeTimeStart = [[NSDate date] retain];
        
    }
    
}

- (void)playMetronomeTick
{
    [g_audioController PluckMutedString:0];
}

- (void)setVolumeGain:(float)gain
{
    [g_audioController setM_volumeGain:gain];
}

- (void)updateDifficultyDisplay
{
    switch ( _difficulty )
    {
        default:
        case PlayViewControllerDifficultyEasy:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffEasyButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = @"Easy";
        } break;
            
        case PlayViewControllerDifficultyMedium:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffMedButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = @"Medium";
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = @"Hard";
        } break;
    }
}

- (void)updateScoreDisplay
{
    NSNumberFormatter * numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString * numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:_scoreTracker.m_score]];
    
    [_scoreLabel setText:numberAsString];
}

- (void)updateProgressDisplay
{
    CGFloat delta = _songModel.m_percentageComplete * _progressFillView.frame.size.width;
    
    [_progressFillView setHidden:NO];
    
    _progressFillView.layer.transform = CATransform3DMakeTranslation( -_progressFillView.frame.size.width + delta, 0, 0 );
}

- (void)finalLogging
{
    
    NSString* route = _speakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_audioRouteTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarPlayToggleFeature
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     route, @"AudioRoute",
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     nil]];
    
    if ( _playMetronome == YES )
    {
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_metronomeTimeStart timeIntervalSince1970] + _playTimeAdjustment;
        
        [g_telemetryController logEvent:GtarPlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                         _userSong.m_title, @"Title",
                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                         @"Off", @"Metronome",
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         nil]];
    }
    
}

#pragma mark - Main event loop

- (void)mainEventLoop
{
    
#ifdef Debug_BUILD
    // DEBUG tapping screen hits the current notes
    if ( _skipNotes == YES )
    {
        
        _skipNotes = NO;
        
        if ( [_songModel.m_currentFrame.m_notesPending count] > 0 )
        {
            NSNote * note = [_songModel.m_currentFrame.m_notesPending objectAtIndex:0];
            
            GtarPluck pluck;
            pluck.velocity = GtarMaxPluckVelocity;
            pluck.position.fret = note.m_fret;
            pluck.position.string = note.m_string;
            
            [self gtarNoteOn:pluck];
        }
        else if ( [_songModel.m_nextFrame.m_notesPending count] > 0 )
        {
            NSNote * note = [_songModel.m_nextFrame.m_notesPending objectAtIndex:0];
            
            GtarPluck pluck;
            pluck.velocity = GtarMaxPluckVelocity;
            pluck.position.fret = note.m_fret;
            pluck.position.string = note.m_string;
            
            [self gtarNoteOn:pluck];
        }
        
        _refreshDisplay = YES;
        
    }
#endif
    
    //
    // Advance song model and recorder
    //
    
    if ( _animateSongScrolling == YES )
    {
        [_songModel incrementTimeSerialAccess:SECONDS_PER_EVENT_LOOP];
    }
    
    // song recorder always records in real time
    [_songRecorder advanceRecordingByTimeDelta:SECONDS_PER_EVENT_LOOP];
    
    // Only refresh when we need to
    if ( _animateSongScrolling == YES || _refreshDisplay == YES )
    {
        _refreshDisplay = NO;
        
        [_displayController renderImage];
        
        [self updateProgressDisplay];
    }
	
}

#pragma mark - GuitarControllerObserver

- (void)gtarFretDown:(GtarPosition)position
{
    
}

- (void)gtarFretUp:(GtarPosition)position
{
    
}

- (void)gtarNoteOn:(GtarPluck)pluck
{
    
    // If we are not running (i.e. paused) then we ignore input from the midi
    if ( m_isRunning == NO )
    {
        return;
    }
    
    // This should only be used sparingly, but sometimes we
    // just want to completely drop the input e.g. in certain
    // chord strumming situations.
    if ( _ignoreInput == YES )
    {
        return;
    }
    
    GtarFret fret = pluck.position.fret;
    GtarString str = pluck.position.string;
    GtarPluckVelocity velocity = pluck.velocity;
    
    if ( _currentFrame == nil )
    {
        [_songModel skipToNextFrame];
    }
    
    // Play a pluck noise immediately
    NSNote * hit;
    
    if ( _difficulty == PlayViewControllerDifficultyEasy )
    {
        hit = [_currentFrame testString:str];
    }
    else
    {
        hit = [_currentFrame testString:str andFret:fret];
    }
    
    // Play the note.
    if ( _difficulty == PlayViewControllerDifficultyHard )
    {
        [self pluckString:str andFret:fret andVelocity:velocity];
    }
    else if ( hit != nil )
    {
        [self pluckString:hit.m_string andFret:hit.m_fret andVelocity:GtarMaxPluckVelocity];
        
        fret = hit.m_fret;
    }
    
    //
    // The rest of the handling is deferred till later.
    //
    
    // If this is called from the midi thread, there won't be an autorelease pool in place.
    // I'll handle all the alloc's manually just in case.
    NSNumber * fretNumber = [[NSNumber alloc] initWithChar:fret];
    NSNumber * strNumber = [[NSNumber alloc] initWithChar:str];
    NSNumber * velNumber = [[NSNumber alloc] initWithChar:velocity];
    
    NSDate * when = [[NSDate alloc] initWithTimeIntervalSinceNow:NOTE_DEFERMENT_TIME];
    
    NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        fretNumber, @"Fret",
                                        strNumber, @"String",
                                        velNumber, @"Velocity",
                                        nil];
    
    NSTimer * timer = [[NSTimer alloc] initWithFireDate:when
                                               interval:0.0
                                                 target:self
                                               selector:@selector(deferredNoteOn:)
                                               userInfo:dictionary
                                                repeats:NO];
    
    [dictionary setObject:timer forKey:@"Timer"];
    
    @synchronized ( _deferredNotesQueue )
    {
        [_deferredNotesQueue addObject:dictionary];
    }
    
    // Add the timer to the run loop
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
    // release everything
    [timer release];
    
    [when release];
    
    [fretNumber release];
    [strNumber release];
    [velNumber release];
    
    [dictionary release];
}

- (void)gtarNoteOff:(GtarPosition)position
{
    
    // Always mute notes on note-off for hard
    [g_audioController NoteOffAtString:position.string - 1 andFret:position.fret];
    
    @synchronized ( _deferredNotesQueue )
    {
        NSDictionary * canceledPluck = nil;
        
        for ( NSDictionary * pluck in _deferredNotesQueue )
        {
            NSNumber * fretNumber = [pluck objectForKey:@"Fret"];
            NSNumber * strNumber = [pluck objectForKey:@"String"];
            
            GtarFret fret = [fretNumber charValue];
            GtarString str = [strNumber charValue];
            
            // If this is a cancelation, kill this timer.
            // Break out of the loop because the for(...) doesn't like
            // the array object mutating under it.
            if ( fret == position.fret && str == position.string )
            {
                canceledPluck = pluck;
                break;
            }
        }
        
        if ( canceledPluck != nil )
        {
            NSTimer * timer = [canceledPluck objectForKey:@"Timer"];
            
            [timer invalidate];
            
            [_deferredNotesQueue removeObject:canceledPluck];
        }
    }
}

- (void)gtarConnected
{
    
    NSLog(@"SongViewController: gTar has been connected");
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLicenseScroll) userInfo:nil repeats:NO];
    
    [g_gtarController setMinimumInterarrivalTime:0.10f];
    
    [self startWithSongXmlDom];
    
    // Stop ourselves before we start so the connecting screen can display
    [self stopMainEventLoop];
    
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(revealPlayView) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeLoadingView) userInfo:nil repeats:NO];

}

- (void)gtarDisconnected
{
    
    NSLog(@"SongViewController: gTar has been disconnected");
    
//    [self backButtonClicked:nil];
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarPlaySongDisconnected
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                     _userSong.m_title, @"Title",
                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                     nil]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Gameplay related helpers

- (void)startWithSongXmlDom
{
    
    [g_gtarController turnOffAllLeds];
    [_displayController cancelPreloading];
    [_displayController release];
    [_songModel release];
    [_scoreTracker release];
    [_currentFrame release];
    [_songRecorder release];
    
    _currentFrame = nil;
    
    // Update the menu labels
    [_songTitleLabel setText:_userSong.m_title];
    [_songArtistLabel setText:_userSong.m_author];
    [_completionLabel setHidden:YES];
    [_finishButton setHidden:YES];
    [_outputView setHidden:NO];
    [_postToFeedView setHidden:YES];
    [_backButton setEnabled:YES];
    
    //
    // Start off the song stuff
    //
    _songModel = [[NSSongModel alloc] initWithSong:_song];
    
    // Very small frame window
    _songModel.m_frameWidthBeats = 0.1f;
    
    // Give a little runway to the player
    [_songModel startWithDelegate:self andBeatOffset:-4.0];
    
    // Light up the first frame
    [self turnOnFrame:_songModel.m_nextFrame];
    
    _songRecorder = [[SongRecorder alloc] initWithTempo:_song.m_tempo];
    
    [_songRecorder beginSong];
    
    switch ( _difficulty )
    {
            
        case PlayViewControllerDifficultyEasy:
        {
            _scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:10];
        } break;
            
        default:
        case PlayViewControllerDifficultyMedium:
        {
            _scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:20];
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            _scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:40];
        } break;
            
    }
    
    //
    // Init display
    //
    _displayController = [[SongDisplayController alloc] initWithSong:_songModel andView:_glView];
    
    // An initial display render
    [_displayController renderImage];
    
    [self updateProgressDisplay];
    
    _animateSongScrolling = YES;
    
    if ( _playMetronome == YES )
    {
        _metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
    }
    
    [_deferredNotesQueue release];
    
    _deferredNotesQueue = [[NSMutableArray alloc] init];
    
    [self startMainEventLoop];
    
}

- (void)pauseSong
{
    [self menuButtonClicked:nil];
}

- (void)interFrameDelayExpired
{
    
    //    NSLog(@"Ending chord");
    
    [_interFrameDelayTimer invalidate];
    
    _interFrameDelayTimer = nil;
    
    //    [m_songModel skipToNextFrame];
    [self songModelExitFrame:_currentFrame];
    
}

- (void)disableInput
{
    _ignoreInput = YES;
    
    [self performSelector:@selector(enableInput) withObject:nil afterDelay:INTER_FRAME_QUIET_PERIOD];
}

- (void)enableInput
{
    _ignoreInput = NO;
}

#pragma mark - Input response helpers

- (void)deferredNoteOn:(NSTimer*)timer
{
    
    NSDictionary * pluck = timer.userInfo;
    
    NSNumber * fretNumber = [pluck objectForKey:@"Fret"];
    NSNumber * strNumber = [pluck objectForKey:@"String"];
    NSNumber * velNumber = [pluck objectForKey:@"Velocity"];
    
    GtarFret fret = [fretNumber charValue];
    GtarString str = [strNumber charValue];
    GtarPluckVelocity velocity = [velNumber charValue];
    
    @synchronized ( _deferredNotesQueue )
    {
        [_deferredNotesQueue removeObject:pluck];
    }
    
    _refreshDisplay = YES;
    
    NSNote * hit;
    
    if ( _difficulty == PlayViewControllerDifficultyEasy )
    {
        hit = [_currentFrame hitTestAndRemoveStringOnly:str];
    }
    else
    {
        hit = [_currentFrame hitTestAndRemoveString:str andFret:fret];
    }
    
    // Handle the hit
    if ( hit != nil )
    {
        [self correctHitFret:hit.m_fret andString:hit.m_string andVelocity:velocity];
    }
    else
    {
        [self incorrectHitFret:fret andString:str andVelocity:velocity];
    }
    
}

// These functions need to be called from the main thread RunLoop.
// If they are called from a MIDI interrupt thread, stuff won't work properly.
- (void)correctHitFret:(GtarFret)fret andString:(GtarString)str andVelocity:(GtarPluckVelocity)velocity
{
    
    // set it to the correct attenuation
    if ( _interFrameDelayTimer == nil )
    {
        // Record the note
        [_songRecorder playString:str andFret:fret];
    }
    
    [self turnOffString:str andFret:fret];
    
    //
    // Begin a frame timer if there are any more note left
    //
    if ( [_currentFrame.m_notesPending count] > 0 )
    {
        
        //
        // This block of code handles chords
        //
        
        // If there is already a timer pending, we don't need to create another one
        if ( _interFrameDelayTimer == nil )
        {
            
            for ( NSInteger index = 0; index < GTAR_GUITAR_STRING_COUNT; index++ )
            {
                _delayedChords[index] = GTAR_GUITAR_NOTE_OFF;
            }
            
            _delayedChordsCount = 0;
            
            // Figure out what notes we will be playing for each string.
            // Also figure out what the max string we will be starting with.
            for ( NSNote * note in _currentFrame.m_notesPending )
            {
                _delayedChords[note.m_string-1] = note.m_fret;
                
                _delayedChordsCount = MAX(_delayedChordsCount, note.m_string);
            }
            
            // We don't want to play notes that are already queues up.
            @synchronized ( _deferredNotesQueue )
            {
                for ( NSDictionary * pluck in _deferredNotesQueue )
                {
                    
                    NSNumber * fretNumber = [pluck objectForKey:@"Fret"];
                    NSNumber * strNumber = [pluck objectForKey:@"String"];
                    
                    GtarFret fret = [fretNumber charValue];
                    GtarString str = [strNumber charValue];
                    
                    // This one is queues up, so don't play it
                    if ( _delayedChords[str-1] == fret )
                    {
                        NSLog(@"Aborted delayed");
                        _delayedChords[str-1] = GTAR_GUITAR_NOTE_OFF;
                    }
                }
            }
            
            _previousChordPluckString = str;
            _previousChordPluckVelocity = velocity;
            _previousChordPluckDirection = 0;
            
            // Schedule an event to play the chords over time
            // m_delayedChordTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_DELAY_TIMER target:self selector:@selector(handleDelayedChord) userInfo:nil repeats:NO];
            
            // Play a chord right now
            [self handleDelayedChord];
            
            // Schedule an event to push us to the next frame after a moment
            // if another chord doesn't come in.
            _interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_GRACE_PERIOD target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
            
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
        _animateSongScrolling = YES;
        
        //
        // We want to kill the timer so we don't get a "double-skip"
        //
        if ( _interFrameDelayTimer != nil )
        {
            [_interFrameDelayTimer invalidate];
            _interFrameDelayTimer = nil;
        }
        
    }
    
}

- (void)incorrectHitFret:(GtarFret)fret andString:(GtarString)str andVelocity:(GtarPluckVelocity)velocity
{
    
    // See if we are trying to play a new chord
    if ( _interFrameDelayTimer != nil )
    {
        [self handleDirectionChange:str];
    }
    
    if ( _difficulty == PlayViewControllerDifficultyHard )
    {
        // Play the note at normal intensity
        [self pluckString:str andFret:fret andVelocity:velocity];
        
        // Record the note
        [_songRecorder playString:str andFret:fret];
    }
    
}

- (void)handleDirectionChange:(GtarString)str
{
    
    // Check for direction changes
    NSInteger stringDelta = str - _previousChordPluckString;
    
    _previousChordPluckString = str;
    
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
        if ( _previousChordPluckDirection < 0 )
        {
//            NSLog(@"Changed direction: up->down");
            [self interFrameDelayExpired];
        }
        else
        {
            // Save the direction and reset the timer
//            NSLog(@"Going down, reup the timer");
            _previousChordPluckDirection = +1;
            [_interFrameDelayTimer invalidate];
            _interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_GRACE_PERIOD target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
        }
    }
    
    // We are going 'up'
    if ( stringDelta < 0 )
    {
        // We were going 'down'
        if ( _previousChordPluckDirection > 0 )
        {
//            NSLog(@"Changed direction: down->up");
            [self interFrameDelayExpired];
        }
        else
        {
            // Save the direction and reset the timer
//            NSLog(@"Going up, reup the timer");
            _previousChordPluckDirection = -1;
            [_interFrameDelayTimer invalidate];
            _interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_GRACE_PERIOD target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
        }
    }
    
}

- (void)handleDelayedChord
{
    
    [_delayedChordTimer invalidate];
    _delayedChordTimer = nil;
    
    if ( _delayedChordsCount <= 0 )
    {
        return;
    }
    
    GtarString str = _delayedChordsCount;
    
    _delayedChordsCount--;
    
    GtarFret fret = _delayedChords[str-1];
    
    if ( _delayedChordsCount > 0 )
    {
        _delayedChordTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_DELAY_TIMER target:self selector:@selector(handleDelayedChord) userInfo:nil repeats:NO];
    }
    
    if ( fret != GTAR_GUITAR_NOTE_OFF )
    {
        
        // Play the note
        if ( _difficulty == PlayViewControllerDifficultyHard )
        {
            [self pluckString:str andFret:fret andVelocity:_previousChordPluckVelocity];
        }
        else
        {
            [self pluckString:str andFret:fret andVelocity:GtarMaxPluckVelocity];
        }
        
        // Record the note
        [_songRecorder playString:str andFret:fret];
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

- (void)turnOnString:(GtarString)str andFret:(GtarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [g_gtarController turnOnLedAtPositionWithColorMap:GtarPositionMake(0, str)];
    }
    else
    {
        [g_gtarController turnOnLedAtPositionWithColorMap:GtarPositionMake(fret, str)];
    }
    
}

- (void)turnOnWhiteString:(GtarString)str andFret:(GtarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, str)
                                    withColor:GtarLedColorMake(3, 3, 3)];
    }
    else
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, str)
                                    withColor:GtarLedColorMake(3, 3, 3)];
    }
    
}

- (void)turnOffString:(GtarString)str andFret:(GtarFret)fret
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [g_gtarController turnOffLedAtPosition:GtarPositionMake(0, str)];
    }
    else
    {
        [g_gtarController turnOffLedAtPosition:GtarPositionMake(fret, str)];
    }
    
}

- (void)pluckString:(GtarString)str andFret:(GtarFret)fret andVelocity:(GtarPluckVelocity)velocity
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        [g_audioController PluckMutedString:str-1];
    }
    else
    {
        [g_audioController PluckString:str-1 atFret:fret withAmplitude:((float)velocity)/GtarMaxPluckVelocity];
    }
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame
{
    
    [_currentFrame release];
    
    _currentFrame = [frame retain];
    
    // Align us more pefectly with the frame
    [_songModel incrementBeatSerialAccess:(frame.m_absoluteBeatStart - _songModel.m_currentBeat)];
    
    _refreshDisplay = YES;
    
    _animateSongScrolling = NO;
    
}

- (void)songModelExitFrame:(NSNoteFrame*)frame
{
    
    [_currentFrame release];
    
    _currentFrame = nil;
    
    // account the score for this frame
    [_scoreTracker scoreFrame:frame];
    
    [self updateScoreDisplay];
    
    // turn off any lights that might have been skipped
    [self turnOffFrame:frame];
    
    // turn on the next frame
    [self turnOnFrame:_nextFrame];
    
    [self disableInput];
    
    _refreshDisplay = YES;
    
    _animateSongScrolling = YES;
    
}

- (void)songModelNextFrame:(NSNoteFrame*)frame
{
    
    [_nextFrame release];
    
    _nextFrame = [frame retain];
    
    //    [self turnOnFrame:m_nextFrame];
    
}

- (void)songModelFrameExpired:(NSNoteFrame*)frame
{
    
    if ( _difficulty == PlayViewControllerDifficultyEasy )
    {
        // On easy mode, we play the notes that haven't been hit yet
        for ( NSNote * note in frame.m_notesPending )
        {
            [self pluckString:note.m_string andFret:note.m_fret andVelocity:GtarMaxPluckVelocity];
        }
        
        [self songModelExitFrame:_currentFrame];
        
    }
    else if ( _difficulty == PlayViewControllerDifficultyMedium ||
             _difficulty == PlayViewControllerDifficultyHard )
    {
        // On medium/hard mode, we don't play anything. The lack of sound is punishment enough.
//        [m_songModel skipToNextFrame];
        [self songModelExitFrame:_currentFrame];
        
    }
    
    // Refresh the display to show the new state
    _refreshDisplay = YES;
    
}

- (void)songModelEndOfSong
{
    
    [self stopMainEventLoop];
    
    // Turn of the LEDs
    [g_gtarController turnOffAllLeds];
    
    [_songRecorder finishSong];
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarPlaySongCompleted
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                     _userSong.m_title, @"Title",
                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                     nil]];
    
    // Save the scores/stars to persistent storage
    [g_userController addStars:_scoreTracker.m_stars forSong:_userSong.m_songId];
    [g_userController addScore:_scoreTracker.m_score forSong:_userSong.m_songId];
    
    [_completionLabel setHidden:NO];
    [_finishButton setHidden:NO];
    [_backButton setEnabled:NO];
    
    [self menuButtonClicked:nil];
    
    [_outputView setHidden:YES];
    [_postToFeedView setHidden:NO];
    
}

#pragma mark - Cloud callbacks

- (void)requestUploadUserSongSessionCallback:(UserResponse*)userResponse
{
    
//    if ( userResponse.m_status == UserResponseStatusSuccess )
//    {
//        // Stop spinning the thing
//        [m_ampView shareSucceeded];
//    }
//    else
//    {
//        // Also stop, but say something extra
//        [m_ampView shareFailed];
//    }
    
}

#pragma mark - AudioControllerDelegate

-(void)audioRouteChanged:(bool)routeIsSpeaker
{
    _speakerRoute = routeIsSpeaker;
    
    [self updateAudioState];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
    // If double-tap reset the shift to zero
    if ( [touch tapCount] == 2 )
    {
        [_displayController shiftView:0];
        _refreshDisplay = YES;
    }
    
	_skipNotes = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    CGFloat delta = currentPoint.x - previousPoint.x;
    
    [_displayController shiftViewDelta:-delta];
    
    _refreshDisplay = YES;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

@end
