//
//  PlayViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import "PlayViewController.h"
#import "VolumeViewController.h"

#import "GtarController.h"

//#import <gTarAppCore/TelemetryController.h>

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

#import "Mixpanel.h"
#import "SongDisplayController.h"
#import "UIButton+Gtar.h"

//#define FRAME_TIMER_DURATION_MED (0.40f) // seconds
//#define FRAME_TIMER_DURATION_EASY (0.06f) // seconds

#define SONG_MODEL_NOTE_FRAME_WIDTH (0.2f) // beats, see also NSSongModel
#define SONG_MODEL_NOTE_FRAME_WIDTH_MAX (0.4f)

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
//extern AudioController * g_audioController;
//extern TelemetryController * g_telemetryController;

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
    BOOL _songIsPaused;
    BOOL _songUploadQueueFull;
    
    // Standalone
    CGPoint initPoint;
    BOOL isStandalone;
    
    BOOL fretOneOn;
    BOOL fretTwoOn;
    BOOL fretThreeOn;
    
}

@end

@implementation PlayViewController

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
        // Custom initialization
        _playTimeAdjustment = 0;
        
        _playTimeStart = [[NSDate date] retain];
        _audioRouteTimeStart = [[NSDate date] retain];
        _metronomeTimeStart = [[NSDate date] retain];
        
        // disable idle sleeping
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioRoute:) name:@"AudioRouteChange" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
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
    //_loadingView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    //_loadingView.layer.borderWidth = 2.0;
    
    // Fill in song info
    _loadingLicenseInfo.text = _userSong.m_licenseInfo;
    _loadingSongArtist.text = _userSong.m_author;
    _loadingSongTitle.text = _userSong.m_title;
    
    // Hide the glview till it is done loading
    _glView.hidden = YES;
    
    [self setStandalone];
    [self updateDifficultyDisplay];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setStandalone];
}

- (void) setStandalone
{
    if(g_gtarController.connected == NO){
        
        NSLog(@"GTAR DISCONNECTED USE STANDALONE");
        
        isStandalone = YES;
        [self standaloneReady];
        [self showPauseButton];
        
    }else{
        
        NSLog(@"GTAR IS CONNECTED USE NORMAL");
        
        isStandalone = NO;
        [self hidePauseButton];
        
    }
}

- (void) localizeViews {
    [_finishButton setTitle:NSLocalizedString(@"SAVE & FINISH", NULL) forState:UIControlStateNormal];
    
    //_scoreTextLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SCORE", NULL)];
    _outputLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"OUTPUT", NULL)];
    _auxLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"AUX", NULL)];
    _speakerLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SPEAKER", NULL)];
    _postToFeedLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"POST TO FEED", NULL)];
    _offLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"OFF", NULL)];
    _onLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ON", NULL)];
    
    NSString *easyStr = [[NSString alloc] initWithString:NSLocalizedString(@"Easy", NULL)];
    _easyLabel.text = [[NSString alloc] initWithString:easyStr];
    _quitLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Quit", NULL)];
    _restartLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Restart", NULL)];
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
    _songIsPaused = NO;
    
    _menuView.transform = CGAffineTransformMakeTranslation( 0, -self.view.frame.size.height );
    
    // Attach the volume view controller
    CGRect targetFrame = [_topBar convertRect:_volumeSliderView.frame toView:self.view];
    
    _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil isInverse:YES];
    
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
    
    // We let the previous screen set the sample pack of this song.
    //[g_soundMaster didSelectInstrument:_song.m_instrument withSelector:@selector(instrumentDidLoad:) andOwner:self];
    [g_soundMaster start];
    
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

- (void)instrumentDidLoad:(id)sender
{
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
    if(g_gtarController.connected){
        [g_gtarController turnOffAllLeds];
    }
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
    
    //[g_soundMaster releaseAfterUse];
    
    [_glView release];
    [_menuView release];
    [_topBar release];
    [_menuButton release];
    [_backButton release];
    [_pauseButton release];
    [_volumeButton release];
    
    [_scoreLabel release];
    [_progressFillView release];
    [_songTitleLabel release];
    [_songArtistLabel release];
    [_finishButton release];
    [_outputView release];
    [_postToFeedView release];
    
//    [_feedSwitch.thumbTintColor release];
    [_feedSwitch release];
    
//    [_outputSwitch.thumbTintColor release];
    [_outputSwitch release];
    
    [_loadingView release];
    [_loadingLicenseInfo release];
    [_loadingSongArtist release];
    [_loadingSongTitle release];
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
    
    // Save the scores/stars to persistent storage
    [g_userController addStars:_scoreTracker.m_stars forSong:_userSong.m_songId];
    [g_userController addScore:_scoreTracker.m_score forSong:_userSong.m_songId];
    
    // If user finished more that 15% of a song and they chose to share the song, upload the userSong session
    if (_songModel.m_percentageComplete >= 0.15 && _feedSwitch.isOn == YES)
    {
        [_songRecorder finishSong];
        // This implicitly saves the user cache
        [self uploadUserSongSession];
    }
    else
    {
        // Otherwise, we should do it manually
        [g_userController saveCache];
    }
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
//    [g_telemetryController logEvent:GtarPlaySongAborted
//                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithInteger:delta], @"PlayTime",
//                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                     _userSong.m_title, @"Title",
//                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play aborted" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInteger:delta], @"PlayTime",
                                                [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                _userSong.m_title, @"Title",
                                                [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];

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
        // This implicitly saves the user cache
        [self uploadUserSongSession];
    }
    else
    {
        // Otherwise, we should do it manually
        [g_userController saveCache];
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
        [self drawPlayButton:_pauseButton];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        //_menuView.transform = CGAffineTransformIdentity;
        
        _menuView.transform = CGAffineTransformMakeTranslation(0,-46);
        
        [UIView commitAnimations];
    }
    else
    {
        if ( _playMetronome == YES )
        {
            _metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
        }
        
        [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
        [self drawPauseButton:_pauseButton];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(menuSlideComplete)];
        
        _menuView.transform = CGAffineTransformMakeTranslation( 0, -_menuView.frame.size.height );
        
        [UIView commitAnimations];
    }
}

- (IBAction)pauseButtonClicked:(id)sender
{
    if(!_menuIsOpen){
        _songIsPaused = !_songIsPaused;
        
        if(_songIsPaused == YES){
            
            [self stopMainEventLoop];
            
            [self drawPlayButton:_pauseButton];
            
        }else{
            
            [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
            
            [self drawPauseButton:_pauseButton];
        }
    }
}

- (IBAction)restartButtonClicked:(id)sender
{
    
    // Only upload at the end of a song
    if ( _finishButton.isHidden == NO && _feedSwitch.isOn == YES )
    {
        [self uploadUserSongSession];
    }
    
    NSLog(@"TODO: reset audio");
    //[g_audioController reset];
    if(g_gtarController.connected == YES){
        [g_gtarController turnOffAllLeds];
    }
    [_displayController shiftView:0];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
//    [g_telemetryController logEvent:GtarPlaySongRestarted
//                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithInteger:delta], @"PlayTime",
//                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                     _userSong.m_title, @"Title",
//                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play restarted" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:delta], @"PlayTime",
                                                  [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                  _userSong.m_title, @"Title",
                                                  [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                  [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                  nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];

    [self startWithSongXmlDom];
    
    [self menuButtonClicked:nil];
    
}

- (IBAction)outputSwitchChanged:(id)sender
{
    [self toggleAudioRoute];
}

- (IBAction)feedSwitchChanged:(id)sender
{
    if ( [g_userController isUserSongSessionQueueFull] == YES && _feedSwitch.isOn == YES )
    {
        [_feedSwitch setOn:NO];

        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Cannot Post"
                                                         message:@"The upload queue is full, cannot post songs until network connectivity restored."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
    }
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
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play toggle difficulty" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                          _userSong.m_title, @"Title",
                                                          [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                          [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                          nil]];
    
    [self updateDifficultyDisplay];
}

- (IBAction)instrumentButtonClicked:(id)sender {
}

#pragma mark - Pause Button
// Pause Button drawing a logic
// TODO: move this somewhere generic/reusable

- (void)showPauseButton
{
    [_pauseButton setHidden:NO];
    [self drawPauseButton:_pauseButton];
}

- (void)hidePauseButton
{
    [_pauseButton setHidden:YES];
}

- (void)clearButton:(UIButton*)button
{
    NSArray *viewsToRemove = [button subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)drawPlayButton:(UIButton*)button
{
    [self clearButton:button];
    
    [button setBackgroundColor:[UIColor colorWithRed:238/255.0 green:188/255.0 blue:53/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(button.frame.size.width, button.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 20;
    int playX = button.frame.size.width/2 - playWidth/2;
    int playY = 12;
    CGFloat playHeight = button.frame.size.height - 2*playY;
    UIColor * transparentWhite = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
    
    CGContextSetStrokeColorWithColor(context, transparentWhite.CGColor);
    CGContextSetFillColorWithColor(context, transparentWhite.CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [button addSubview:image];
    
    UIGraphicsEndImageContext();
}

- (void)drawPauseButton:(UIButton*)button
{
    [self clearButton:button];
    
    [button setBackgroundColor:[UIColor colorWithRed:244/255.0 green:151/255.0 blue:39/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(button.frame.size.width, button.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int pauseWidth = 8;
    
    CGFloat pauseHeight = button.frame.size.height - 22;
    CGRect pauseFrameLeft = CGRectMake(button.frame.size.width/2 - pauseWidth - 3, 12, pauseWidth, pauseHeight);
    CGRect pauseFrameRight = CGRectMake(pauseFrameLeft.origin.x+pauseWidth+4, 12, pauseWidth, pauseHeight);
    
    CGContextAddRect(context,pauseFrameLeft);
    CGContextAddRect(context,pauseFrameRight);
    CGContextSetFillColorWithColor(context,[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor);
    CGContextFillRect(context,pauseFrameLeft);
    CGContextFillRect(context,pauseFrameRight);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [button addSubview:image];
    
    UIGraphicsEndImageContext();
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
    
    [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
    [self drawPauseButton:_pauseButton];
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
        [g_soundMaster routeToSpeaker];
    }
    else
    {
        [g_soundMaster routeToDefault];
    }
    
}

- (void)updateAudioState
{
    
    if ( _speakerRoute == YES )
    {
        [_outputSwitch setOn:YES];
    }
    else
    {
        [_outputSwitch setOn:NO];
    }
    
    // Invert it so we log the route we came from
    NSString * route = !_speakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_audioRouteTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    if ( delta > 0 )
    {
//        [g_telemetryController logEvent:GtarPlayToggleFeature
//                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                         [NSNumber numberWithInteger:delta], @"PlayTime",
//                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                         _userSong.m_title, @"Title",
//                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                         route, @"AudioRoute",
//                                         nil]];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle audio route" properties:[NSDictionary dictionaryWithObjectsAndKeys:
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
        
//        [g_telemetryController logEvent:GtarPlayToggleFeature
//                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                         _userSong.m_title, @"Title",
//                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                         @"On", @"Metronome",
//                                         nil]];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle metronome" properties:[NSDictionary dictionaryWithObjectsAndKeys:
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
        
//        [g_telemetryController logEvent:GtarPlayToggleFeature
//                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                         _userSong.m_title, @"Title",
//                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                         @"Off", @"Metronome",
//                                         [NSNumber numberWithInteger:delta], @"PlayTime",
//                                         nil]];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle metronome" properties:[NSDictionary dictionaryWithObjectsAndKeys:
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
    NSLog(@"TODO: play metronome tick");
    //[g_audioController PluckMutedString:0];
}

- (void)setVolumeGain:(float)gain
{
    [g_soundMaster setChannelGain:gain];
}

- (void)updateDifficultyDisplay
{
    [self hideFrets];
    
    [_displayController updateDifficulty:_difficulty];
    
    switch ( _difficulty )
    {
        default:
        case PlayViewControllerDifficultyEasy:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffEasyButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Easy", NULL);
            
        } break;
            
        case PlayViewControllerDifficultyMedium:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffMedButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Medium", NULL);
            
            if(isStandalone){
                [self showFrets];
            }
            
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            
            if(isStandalone){
                [self showFrets];
            }
            
        } break;
    }
}

- (void)hideFrets
{
    fretOneOn = NO;
    fretTwoOn = NO;
    fretThreeOn = NO;
    
    [_fretOne setHidden:YES];
    [_fretTwo setHidden:YES];
    [_fretThree setHidden:YES];
}

- (void)showFrets
{
    fretOneOn = NO;
    fretTwoOn = NO;
    fretThreeOn = NO;
    
    [_fretOne setHidden:NO];
    [_fretTwo setHidden:NO];
    [_fretThree setHidden:NO];
    
    _fretOne.layer.cornerRadius = 50.0;
    _fretTwo.layer.cornerRadius = 50.0;
    _fretThree.layer.cornerRadius = 50.0;
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
    
//    [g_telemetryController logEvent:GtarPlayToggleFeature
//                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     route, @"AudioRoute",
//                                     [NSNumber numberWithInteger:delta], @"PlayTime",
//                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play toggle audio route" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInteger:delta], @"PlayTime",
                                                           [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                           _userSong.m_title, @"Title",
                                                           [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                           [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                           route, @"AudioRoute",
                                                           nil]];
    
    if ( _playMetronome == YES )
    {
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_metronomeTimeStart timeIntervalSince1970] + _playTimeAdjustment;
        
//        [g_telemetryController logEvent:GtarPlayToggleFeature
//                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                         [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                         _userSong.m_title, @"Title",
//                                         [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                         [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                         @"Off", @"Metronome",
//                                         [NSNumber numberWithInteger:delta], @"PlayTime",
//                                         nil]];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle metronome" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                             _userSong.m_title, @"Title",
                                                             [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                             [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                             @"Off", @"Metronome",
                                                             [NSNumber numberWithInteger:delta], @"PlayTime",
                                                             nil]];

    }
    
}

- (void)uploadUserSongSession
{
    UserSongSession * session = [[[UserSongSession alloc] init] autorelease];
    
    session.m_userSong = _userSong;
    session.m_score = _scoreTracker.m_score;
    session.m_stars = _scoreTracker.m_stars;
    session.m_combo = _scoreTracker.m_streak;
    session.m_notes = @"Recorded in gTar Play";

    _songRecorder.m_song.m_instrument = [[g_soundMaster getInstrumentList] objectAtIndex:[g_soundMaster getCurrentInstrument]];
    
    NSLog(@"Get current instrument is %@",_songRecorder.m_song.m_instrument);
   // _songRecorder.m_song.m_instrument = [[g_audioController getInstrumentNames] objectAtIndex:[g_audioController getCurrentSamplePackIndex]];
    
    // Create the xmp
    session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
    session.m_created = time(NULL);
    
    // Upload song to server. This also persists the upload in case of network failure
    [g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
//    [g_telemetryController logEvent:GtarPlaySongShared
//                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithInteger:delta], @"PlayTime",
//                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                     _userSong.m_title, @"Title",
//                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play song shared" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:delta], @"PlayTime",
                                                    [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                    _userSong.m_title, @"Title",
                                                    [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                    [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                    nil]];

}

#pragma mark - Main event loop

- (void)mainEventLoop
{
    
#ifdef Debug_BUILD
    if(g_gtarController.connected){
        
        // DEBUG tapping screen hits the current notes (see: touchesbegan)
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
                
                [self gtarNoteOn:pluck forFrame:nil];
            }
            else if ( [_songModel.m_nextFrame.m_notesPending count] > 0 )
            {
                NSNote * note = [_songModel.m_nextFrame.m_notesPending objectAtIndex:0];
                
                GtarPluck pluck;
                pluck.velocity = GtarMaxPluckVelocity;
                pluck.position.fret = note.m_fret;
                pluck.position.string = note.m_string;
                
                [self gtarNoteOn:pluck forFrame:nil];
            }
            
            _refreshDisplay = YES;
            
        }
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

- (void)gtarNoteOn:(GtarPluck)pluck forFrame:(NSNoteFrame*)frameToPlay
{
    // If we are not running (i.e. paused) then we ignore input from the midi
    if ( m_isRunning == NO )
    {
        return;
    }
    
    // This should only be used sparingly, but sometimes we
    // just want to completely drop the input e.g. in certain
    // chord strumming situations.
    // But never in standalone
    if ( _ignoreInput == YES && !isStandalone )
    {
        return;
    }
    
    GtarFret fret = pluck.position.fret;
    GtarString str = pluck.position.string;
    GtarPluckVelocity velocity = pluck.velocity;
    
    if ( _currentFrame == nil && frameToPlay == nil)
    {
        [_songModel skipToNextFrame];
    }
    
    if(frameToPlay == nil){
        frameToPlay = _currentFrame;
    }
    
    // Play a pluck noise immediately
    NSNote * hit;
    
    if ( _difficulty == PlayViewControllerDifficultyEasy )
    {
        hit = [frameToPlay testString:str];
    }
    else
    {
        hit = [frameToPlay testString:str andFret:fret];
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
    
    if(isStandalone && hit != nil){
        
        //
        // Standalone Song Recorder
        //
        
        [_songRecorder playString:str andFret:fret];
        
    }else{
        
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
}

- (void)gtarNoteOff:(GtarPosition)position
{
    
    // Always mute notes on note-off for hard
    NSLog(@"TODO: attenuate and mute note");
    //[g_audioController NoteOffAtString:position.string - 1 andFret:position.fret];
    
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

- (void)standaloneReady
{
    NSLog(@"Standalone ready");
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLicenseScroll) userInfo:nil repeats:NO];
    
    // Stop ourselves before we start so the connecting screen can display
    [self stopMainEventLoop];
    [self drawPlayButton:_pauseButton];

    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(startWithSongXmlDom) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(revealPlayView) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeLoadingView) userInfo:nil repeats:NO];
    
}

- (void)gtarConnected
{
    
    NSLog(@"SongViewController: gTar has been connected");
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLicenseScroll) userInfo:nil repeats:NO];
    
    [g_gtarController setMinimumInterarrivalTime:0.10f];
    
    [self startWithSongXmlDom];
    
    // Stop ourselves before we start so the connecting screen can display
    [self stopMainEventLoop];
    [self drawPlayButton:_pauseButton];
    
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
    
//    [g_telemetryController logEvent:GtarPlaySongDisconnected
//                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithInteger:delta], @"PlayTime",
//                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                     _userSong.m_title, @"Title",
//                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play disconnected" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                     _userSong.m_title, @"Title",
                                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                     nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Gameplay related helpers

- (void)startWithSongXmlDom
{
    if(g_gtarController.connected){
        [g_gtarController turnOffAllLeds];
    }
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
    [_finishButton setHidden:YES];
    [_outputView setHidden:NO];
    [_backButton setEnabled:YES];
    
    //
    // Start off the song stuff
    //
    _songModel = [[NSSongModel alloc] initWithSong:_song];
    
    // Very small frame window
    _songModel.m_frameWidthBeats = SONG_MODEL_NOTE_FRAME_WIDTH;
    
    // Give a little runway to the player
    [_songModel startWithDelegate:self andBeatOffset:-4 fastForward:YES isStandalone:isStandalone];
    
    // Light up the first frame
    if(g_gtarController.connected == YES){
        [self turnOnFrame:_songModel.m_nextFrame];
    }
    
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
    _displayController = [[SongDisplayController alloc] initWithSong:_songModel andView:_glView isStandalone:isStandalone setDifficulty:_difficulty];
    
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
    
    [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
    [self drawPauseButton:_pauseButton];
    
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
//        [self pluckString:str andFret:fret andVelocity:velocity];
        
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
    if(g_gtarController.connected){
    
        if ( fret == GTAR_GUITAR_FRET_MUTED )
        {
            [g_gtarController turnOnLedAtPositionWithColorMap:GtarPositionMake(0, str)];
        }
        else
        {
            [g_gtarController turnOnLedAtPositionWithColorMap:GtarPositionMake(fret, str)];
        }
        
    }
}

- (void)turnOnWhiteString:(GtarString)str andFret:(GtarFret)fret
{
    
    if(g_gtarController.connected){
        
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
    
}

- (void)turnOffString:(GtarString)str andFret:(GtarFret)fret
{
    if(g_gtarController.connected){
        if ( fret == GTAR_GUITAR_FRET_MUTED )
        {
            [g_gtarController turnOffLedAtPosition:GtarPositionMake(0, str)];
        }
        else
        {
            [g_gtarController turnOffLedAtPosition:GtarPositionMake(fret, str)];
        }
    }
    
}

- (void)pluckString:(GtarString)str andFret:(GtarFret)fret andVelocity:(GtarPluckVelocity)velocity
{
    
    if ( fret == GTAR_GUITAR_FRET_MUTED )
    {
        NSLog(@"TODO: pluck muted");
        [g_soundMaster PluckString:str-1 atFret:fret];
        //[g_audioController PluckMutedString:str-1];
    }
    else
    {
        NSLog(@"Play View Controller Pluck String");
        [g_soundMaster PluckString:str-1 atFret:fret];
       // [g_audioController PluckString:str-1 atFret:fret withAmplitude:((float)velocity)/GtarMaxPluckVelocity];
    }
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame
{
    NSLog(@"Song model enter frame");
    [_currentFrame release];
    
    _currentFrame = [frame retain];
    
    // Align us more pefectly with the frame
    if(!isStandalone){
        [_songModel incrementBeatSerialAccess:(frame.m_absoluteBeatStart - _songModel.m_currentBeat)];
    }
    
    _refreshDisplay = YES;
    
    if(isStandalone){
        _animateSongScrolling = YES;
    }else{
        _animateSongScrolling = NO;
    }
}

- (void)songModelExitFrame:(NSNoteFrame*)frame
{
    NSLog(@"Song model exit frame");
    
    // Miss all the remaining notes
    for(NSNote * n in frame.m_notesPending){
        
        [_displayController missNote:n];
        
    }
    
    
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
    [self drawPlayButton:_pauseButton];
    
    // Turn of the LEDs
    if(g_gtarController.connected){
        [g_gtarController turnOffAllLeds];
    }
    
    [_songRecorder finishSong];
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
//    [g_telemetryController logEvent:GtarPlaySongCompleted
//                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
//                                     [NSNumber numberWithInteger:delta], @"PlayTime",
//                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
//                                     _userSong.m_title, @"Title",
//                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
//                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
//                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play completed" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:delta], @"PlayTime",
                                                  [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                  _userSong.m_title, @"Title",
                                                  [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                  [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                  nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];
    
    // Save the scores/stars to persistent storage
    [g_userController addStars:_scoreTracker.m_stars forSong:_userSong.m_songId];
    [g_userController addScore:_scoreTracker.m_score forSong:_userSong.m_songId];
    
    [_finishButton setHidden:NO];
    [_backButton setEnabled:NO];
    
    // If our queue is full, don't let them upload more songs
    if ( [g_userController isUserSongSessionQueueFull] == YES )
    {
        [_feedSwitch setOn:NO];
    }
    
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

- (void)didChangeAudioRoute:(NSNotification *) notification
{
    _speakerRoute = [[[notification userInfo] objectForKey:@"isRouteSpeaker"] boolValue];
    
    [self updateAudioState];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
    CGPoint touchPoint = [touch locationInView:self.glView];
    initPoint = touchPoint;
    
    // If double-tap reset the shift to zero
    if ( [touch tapCount] == 2 )
    {
        [_displayController shiftView:0];
        _refreshDisplay = YES;
    }
    
    //NSLog(@"Touch is %f %f",touchPoint.x,touchPoint.y);
    //NSLog(@"Current frame is %@",_currentFrame);
    
    // Determine whether to play the tapped string
    if(isStandalone){
        [self tapNoteFromTouchPoint:touchPoint];
    }
    
    // Debug
    if(g_gtarController.connected){
        _skipNotes = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    CGFloat deltaX = currentPoint.x - previousPoint.x;
    
    // Only shift render view if delta x is large enough
    if(!isStandalone){
        if(abs(initPoint.x - currentPoint.x) > 50){
                [_displayController shiftViewDelta:-deltaX];
        }
    }
    
    // If delta y is large enough then strum
    if(isStandalone && abs(initPoint.y - currentPoint.y) > 10){
        
        CGPoint touchPoint = [touch locationInView:self.glView];
        [self strumNoteFromTouchPoint:touchPoint];
        
    }
    
    _refreshDisplay = YES;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}


#pragma mark - Standalone logic
- (void)tapNoteFromTouchPoint:(CGPoint)touchPoint
{
    NSMutableDictionary * frameWithString = [_displayController getStringPluckFromTap:touchPoint];
    
    if(frameWithString == nil){
        return;
    }
    
    int tappedString = [[frameWithString objectForKey:@"String"] intValue];
    NSNoteFrame * tappedFrame = [frameWithString objectForKey:@"Frame"];
    
    if(tappedString >= 0 && [tappedFrame.m_notesPending count] == 1){
        [self playNoteOnString:tappedString atFrame:tappedFrame];
    }else if(tappedString >= 0 && [tappedFrame.m_notesPending count] == 2){
        
        NSNote * firstNote = [tappedFrame.m_notesPending objectAtIndex:0];
        NSNote * secondNote = [tappedFrame.m_notesPending objectAtIndex:1];
        
        if([_displayController getMappedStringFromString:firstNote.m_string] == [_displayController getMappedStringFromString:secondNote.m_string]){
            [self playNoteOnString:tappedString atFrame:tappedFrame];
        }
        
    }
}

- (void)strumNoteFromTouchPoint:(CGPoint)touchPoint
{
    NSMutableDictionary * frameWithString = [_displayController getStringPluckFromTap:touchPoint];
    
    if(frameWithString == nil){
        return;
    }
    
    int tappedString = [[frameWithString objectForKey:@"String"] intValue];
    NSNoteFrame * tappedFrame = [frameWithString objectForKey:@"Frame"];
    
    if(tappedString >= 0 && [tappedFrame.m_notesPending count] > 0){
        [self playNoteOnString:tappedString atFrame:tappedFrame];
    }
}

- (void)playNoteOnString:(int)tappedString atFrame:(NSNoteFrame*)tappedFrame
{

    NSNote * firstNote = nil;
    
    if(_difficulty == PlayViewControllerDifficultyHard){
        
        BOOL playFretOne = FALSE;
        BOOL playFretTwo = FALSE;
        BOOL playFretThree = FALSE;
        int fretsOn = 0;
        
        // Hard: make sure the exact right fretting is held
        for(NSNote * n in tappedFrame.m_notes){
            
            // Ignore hidden notes
            if(!n.m_standaloneActive){
                continue;
            }
            
            int fret = [_displayController getStandaloneFretFromFret:n.m_fret];
            
            switch(fret){
                case 1:
                    if(!playFretOne) fretsOn++;
                    playFretOne = TRUE;
                    break;
                case 2:
                    if(!playFretTwo) fretsOn++;
                    playFretTwo = TRUE;
                    break;
                case 3:
                    if(!playFretThree) fretsOn++;
                    playFretThree = TRUE;
                    break;
            }
        }
        
        // Look at expected fretting and return if held fret combo violates
        switch(fretsOn){
            case 0:
                if(fretOneOn || fretTwoOn || fretThreeOn){
                    return;
                }
                break;
            case 1:
                if(playFretOne && (!fretOneOn || fretTwoOn || fretThreeOn)){
                    return;
                }else if(playFretTwo && (!fretTwoOn || fretOneOn || fretThreeOn)){
                    return;
                }else if(playFretThree && (!fretThreeOn || fretOneOn || fretTwoOn)){
                    return;
                }
                break;
            case 2:
                if(playFretOne && playFretTwo && (!fretOneOn || !fretTwoOn || fretThreeOn)){
                    return;
                }else if(playFretOne && playFretThree && (!fretOneOn || !fretThreeOn || fretTwoOn)){
                    return;
                }else if(playFretTwo && playFretThree && (!fretTwoOn || !fretThreeOn || fretOneOn)){
                    return;
                }
                break;
            case 3:
                if(!fretOneOn || !fretTwoOn || !fretThreeOn){
                    return;
                }
                break;
                
        }
        
    }else if(_difficulty == PlayViewControllerDifficultyMedium){
       
        // Medium: make sure the fret for the first note is held
        // (UI ensures only 1 fret down at a time)
        for(NSNote * n in tappedFrame.m_notes){
            
            if(!firstNote){
                firstNote = n;
            }
            
            // Ignore hidden notes
            if(!n.m_standaloneActive){
                continue;
            }
            
            int fret = [_displayController getStandaloneFretFromFret:firstNote.m_fret];
            
            switch (fret) {
                case 0:
                    if(fretOneOn || fretTwoOn || fretThreeOn){
                        return;
                    }
                    break;
                case 1:
                    if(!fretOneOn){
                        return;
                    }
                    break;
                case 2:
                    if(!fretTwoOn){
                        return;
                    }
                    break;
                case 3:
                    if(!fretThreeOn){
                        return;
                    }
                    break;
            }
        }
    }
    
    
    // Go through and play the notes if the string mapping is correct
    NSMutableArray * notesToRemove = [[NSMutableArray alloc] init];
    
    for(NSNote * n in tappedFrame.m_notesPending){
        
        if([_displayController getMappedStringFromString:n.m_string] == tappedString){
            
            // Strummed with the right fretting, autocomplete
            
            //if(_difficulty == PlayViewControllerDifficultyEasy || _difficulty == PlayViewControllerDifficultyMedium){
                
                for(NSNote * nn in tappedFrame.m_notesPending){
                    
                    GtarPluck pluck;
                    pluck.velocity = GtarMaxPluckVelocity;
                    pluck.position.fret = nn.m_fret;
                    pluck.position.string = nn.m_string;
                    
                    NSLog(@"Pluck string %i",nn.m_string);
                    
                    [_displayController hitNote:nn];
                    
                    [self gtarNoteOn:pluck forFrame:tappedFrame];
                    
                    [notesToRemove addObject:nn];
                    
                }
                
            /*}else{
            
                GtarPluck pluck;
                pluck.velocity = GtarMaxPluckVelocity;
                pluck.position.fret = n.m_fret;
                pluck.position.string = n.m_string;
                
                NSLog(@"Pluck string %i",n.m_string);
                
                [_displayController hitNote:n];
                
                [self gtarNoteOn:pluck forFrame:tappedFrame];
                
                [notesToRemove addObject:n];
                
            }*/
            
            break;
        }
    }
    
    for(NSNote * nnn in notesToRemove){
        [tappedFrame removeString:nnn.m_string andFret:nnn.m_fret];
    }

}

- (void)fretDown:(id)sender
{
    UIButton * fret = (UIButton *)sender;
    
    [fret setAlpha:1.0];
    
    if(fret == _fretOne){
        fretOneOn = YES;
        
        // highlight one fret at a time on Medium
        if(_difficulty == PlayViewControllerDifficultyMedium){
            [self fretUp:_fretTwo];
            [self fretUp:_fretThree];
        }
        
    }else if(fret == _fretTwo){
        fretTwoOn = YES;
        
        // highlight one fret at a time on Medium
        if(_difficulty == PlayViewControllerDifficultyMedium){
            [self fretUp:_fretOne];
            [self fretUp:_fretThree];
        }
        
    }else if(fret == _fretThree){
        fretThreeOn = YES;
        
        // highlight one fret at a time on Medium
        if(_difficulty == PlayViewControllerDifficultyMedium){
            [self fretUp:_fretOne];
            [self fretUp:_fretTwo];
        }
    }
    
    [_displayController fretsDownOne:fretOneOn fretTwo:fretTwoOn fretThree:fretThreeOn];
}

- (void)fretUp:(id)sender
{
    UIButton * fret = (UIButton *)sender;
    
    [fret setAlpha:0.5];
    
    if(fret == _fretOne){
        fretOneOn = NO;
    }else if(fret == _fretTwo){
        fretTwoOn = NO;
    }else if(fret == _fretThree){
        fretThreeOn = NO;
    }
    
    [_displayController fretsDownOne:fretOneOn fretTwo:fretTwoOn fretThree:fretThreeOn];
}

@end
