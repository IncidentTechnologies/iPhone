//
//  PlayViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/28/13.
//
//

#import "PlayViewController.h"
#import "VolumeViewController.h"

#import "KeysController.h"

#import "CloudController.h"
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>
#import "UserSongSession.h"
#import "UserSong.h"
#import "KeysSongRecorder.h"
#import "NSSongCreator.h"
#import "NSSongModel.h"
#import "NSNote.h"
#import "NSSong.h"
#import "NSNoteFrame.h"
#import "NSScoreTracker.h"
#import "NSMarker.h"
#import "XmlDom.h"

#import "Mixpanel.h"
#import "SongDisplayController.h"
#import "UIButton+Keys.h"
#import "FrameGenerator.h"

//#define FRAME_TIMER_DURATION_MED (0.40f) // seconds
//#define FRAME_TIMER_DURATION_EASY (0.06f) // seconds

#define SONG_MODEL_NOTE_FRAME_WIDTH (0.2f) // beats, see also NSSongModel
#define SONG_MODEL_NOTE_FRAME_WIDTH_MAX (0.4f)

#define CHORD_DELAY_TIMER 0.000f
#define CHORD_GRACE_PERIOD 0.100f

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_MUFFLED 0.70f
#define AUDIO_CONTROLLER_AMPLITUDE_MUFFLED 0.15f

#define STANDALONE_SONG_BEATS_PER_SCREEN 1.5
#define NOTE_DEFERMENT_TIME 0.040f
#define INTER_FRAME_QUIET_PERIOD (0.60/(float)_song.m_tempo)

#define TEMP_BASE_SCORE 10

extern CloudController * g_cloudController;
extern KeysController * g_keysController;
extern UserController * g_userController;
//extern AudioController * g_audioController;
//extern TelemetryController * g_telemetryController;

@interface PlayViewController ()
{
    //SongDisplayController *_displayController;
    
    VolumeViewController *_volumeViewController;
    
    BOOL _animateSongScrolling;
    
    NSSong *_song;
    
    NSSongModel *_songModel;
    
    KeysSongRecorder *_songRecorder;
    
    NSNoteFrame *_currentFrame;
    NSNoteFrame *_nextFrame;
    
    NSScoreTracker *_scoreTracker;
    
    BOOL _refreshDisplay;
    BOOL _ignoreInput;
    BOOL _playMetronome;
    double lastMetronomeBeat;
    
    NSTimer *_interFrameDelayTimer;
    NSTimer *_delayedChordTimer;
    NSTimer *_metronomeTimer;
    
    KeyPosition _previousChordPlayKey;
    KeysPressVelocity _previousChordPlayVelocity;
    NSInteger _previousChordPlayDirection;
    
    KeyPosition _delayedChordMax;
    NSMutableArray * _delayedChords;
    
    NSMutableArray *_deferredNotesQueue;
    
    NSDate *_playTimeStart;
    NSDate *_audioRouteTimeStart;
    NSDate *_metronomeTimeStart;
    NSTimeInterval _playTimeAdjustment;
    
    BOOL _speakerRoute;
    BOOL _skipNotes;
    BOOL _menuIsOpen;
    BOOL _forceRestart;
    BOOL _songScoreIsOpen;
    BOOL _songIsPaused;
    BOOL _songUploadQueueFull;
    
    BOOL _postToFeed;
    BOOL _autocomplete;
    
    // Standalone
    CGPoint initPoint;
    BOOL isScrolling;
    BOOL isStandalone;
    BOOL isRestrictPlayFrame;
    NSMutableArray * activeTouchPoints;
    
    // Sheet Music View
    BOOL isSheetMusic;
    
    // Practice
    NSMutableArray * markerButtons;
    int m_loops;
    double m_loopStart;
    double m_loopEnd;
    int dragFirstX;
    int leftFirstX;
    int rightFirstX;
    BOOL isPracticeMode;
    BOOL _practiceViewOpen;
    
}

@property (strong, nonatomic) SongDisplayController *displayController;


@end

@implementation PlayViewController

@synthesize g_soundMaster;
@synthesize keyboardStandaloneEasy;
@synthesize keyboardStandaloneMedium;
@synthesize keyboardStandaloneHard;
@synthesize keyboard;
@synthesize keyboardGrid;
@synthesize keyboardRange;
@synthesize keyboardPosition;
@synthesize keyboardOverview;
@synthesize selectedKeyboard;
@synthesize selectedTrackIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster isStandalone:(BOOL)standalone practiceMode:(BOOL)practiceMode selectedTrack:(int)selectedTrack
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
        g_keysMath.delegate = self;
        
        // Custom initialization
        _playTimeAdjustment = 0;
        
        _playTimeStart = [NSDate date];
        _audioRouteTimeStart = [NSDate date];
        _metronomeTimeStart = [NSDate date];
        
        isScrolling = standalone;
        isStandalone = standalone;
        g_keysMath.isStandalone = standalone;
        
        isPracticeMode = practiceMode;
        
        selectedTrackIndex = selectedTrack;
        
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
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    float x = [frameGenerator getFullscreenWidth];
    float y = [frameGenerator getFullscreenHeight];
    
    CGRect fullScreen = CGRectMake(0,0,x,y);
    
    // Setup the menu
    [self.view addSubview:_menuView];
    [self.view addSubview:_songScoreView];
    [self.view addSubview:_practiceView];
    
    [_menuView setFrame:fullScreen];
    [_menuView setBounds:fullScreen];
    
    [_songScoreView setFrame:fullScreen];
    [_songScoreView setBounds:fullScreen];
    
    [_practiceView setFrame:fullScreen];
    [_practiceView setBounds:fullScreen];
    
    _menuView.transform = CGAffineTransformMakeTranslation( 0, self.view.frame.size.height );
    _songScoreView.transform = CGAffineTransformMakeTranslation( 0, self.view.frame.size.height );
    
    _practiceViewOpen = NO;
    _menuIsOpen = NO;
    _songScoreIsOpen = NO;
    _songIsPaused = NO;
    
    // Hide the widgets we don't need initially
    [_menuDownArrow setHidden:YES];
    [_finishPracticeButton setHidden:YES];
    [_finishButton setHidden:YES];
    [_finishRestartButton setHidden:YES];
    [_progressFillView setHidden:YES];
    
    // Setup the volume button which will take a second to load
    [_volumeButton setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 3, 0)];
    
    // Fill in song info
    _loadingLicenseInfo.text = _userSong.m_licenseInfo;
    _loadingSongArtist.text = _userSong.m_author;
    _loadingSongTitle.text = _userSong.m_title;
    
    // Hide the glview till it is done loading
    _glView.hidden = YES;
    
    [self initControls];
    ;
    [self updateDifficultyDisplay];
    
    // The first time we load this up, parse the song
    _song = [[NSSong alloc] initWithXmlDom:_userSong.m_xmlDom ophoXmlDom:_userSong.m_ophoXmlDom andTrackIndex:selectedTrackIndex];
    
    DLog(@"Song is %i",_userSong.m_songId);
    
    // Init song XML
    //[self initSongModel];
    
    [self setPracticeMode];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setStandalone];
}

- (void) viewWillDisappear:(BOOL)animated
{
    _songModel = nil;
    [self stopMainEventLoop];
}

- (void) setPracticeMode
{
    // Show dropdown when the view appears if specified
    if(isPracticeMode){
        
        _practiceViewOpen = YES;
        [_practiceView setHidden:NO];
        
        [_practiceSongTitleLabel setText:_userSong.m_title];
        [_practiceSongArtistLabel setText:_userSong.m_author];
        
        [self drawPracticeMarkersForSong];
        
    }else{
        
        _practiceViewOpen = NO;
        [_practiceView setHidden:YES];
        
    }
}

- (void) setStandalone
{
    if(g_keysController.connected == NO){
        
        DLog(@"KEYS DISCONNECTED USE STANDALONE");
        
        isStandalone = YES;
        g_keysMath.isStandalone = isStandalone;
        [self standaloneReady];
        
        [_tempoButton setTitle:@"100%" forState:UIControlStateNormal];
        
        [self setRestrictPlayFrame:NO];
        
    }else{
        
        DLog(@"KEYS IS CONNECTED USE NORMAL");
        
        isStandalone = NO;
        g_keysMath.isStandalone = isStandalone;
        
        [_tempoButton setTitle:NSLocalizedString(@"NONE", NULL) forState:UIControlStateNormal];
        
    }
    
    [self setScrolling:isStandalone];
}

- (void) setScrolling:(BOOL)scrolling
{
    isScrolling = scrolling;
    
    if(isScrolling){
        [self showPauseButton];
    }else{
        [self hidePauseButton];
    }
}

- (void) setRestrictPlayFrame:(BOOL)restrictPlayFrame
{
    isRestrictPlayFrame = restrictPlayFrame;
}

- (void) localizeViews {
    [_finishPracticeButton setTitle:NSLocalizedString(@"PRACTICE", NULL) forState:UIControlStateNormal];
    [_startPracticeButton setTitle:NSLocalizedString(@"PRACTICE", NULL) forState:UIControlStateNormal];
    [_practiceBackButton setTitle:NSLocalizedString(@"FINISH", NULL) forState:UIControlStateNormal];
    [_finishButton setTitle:NSLocalizedString(@"SAVE & FINISH", NULL) forState:UIControlStateNormal];
    [_finishRestartButton setTitle:NSLocalizedString(@"PLAY", NULL) forState:UIControlStateNormal];
    
    _scoreScoreLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SCORE", NULL)];
    _scoreBestSessionLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"BEST SESSION", NULL)];
    _scoreTotalLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SESSIONS", NULL)];
    _scoreNotesHitLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"NOTES HIT", NULL)];
    _scoreInARowLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"IN A ROW", NULL)];
    _scoreAccuracyLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ACCURACY", NULL)];
    
    _repeatLabel.text = NSLocalizedString(@"REPEAT", NULL);
    _tempoLabel.text = NSLocalizedString(@"TEMPO", NULL);
    _metronomeLabel.text = NSLocalizedString(@"METRONOME", NULL);
    
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
    _menuMetronomeLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Metronome", NULL)];
    
    //_multiplierTextLabel.layer.cornerRadius = _multiplierTextLabel.frame.size.width/2.0;
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
    
    // Attach the volume view controller
    CGRect targetFrame = [_topBar convertRect:_volumeSliderView.frame toView:self.view];
    
    _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster isInverse:NO];
    
    [_volumeViewController attachToSuperview:self.view withFrame:targetFrame];
    
    // Make sure the top bar stays on top
    //[self.view bringSubviewToFront:_topBar];
    
    [self performSelectorOnMainThread:@selector(delayedLoaded) withObject:nil waitUntilDone:NO];
    
    // This doesn't draw until the screen loads
    [self positionKeyboard:[g_keysMath getForcedRangeKeyMin]];
    
}

- (void)delayedLoaded
{
    // We want the main thread to finish running the above and updating the views
    // before this stuff runs. It will take awhile, and we want the user
    // to see all the views while they wait.
    
    // We let the previous screen set the sample pack of this song.
    [g_soundMaster start];
    
    //
    // Set the audio routing destination
    //
    NSString * audioRoute = [g_soundMaster getAudioRoute];
    _speakerRoute = ([audioRoute isEqualToString:@"Speaker"]) ? YES : NO;
    
    [self updateAudioState];
    
    // Observe the global guitar controller. This will call guitarConnected when it is connected.
    // This in turn starts the game mode.
    [g_keysController addObserver:self];
    
}

- (void)instrumentDidLoad:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
    if(g_keysController.connected){
        [g_keysController turnOffAllLeds];
    }
    [g_keysController removeObserver:self];
    
    [_displayController cancelPreloading];
    
    [_interFrameDelayTimer invalidate];
    _interFrameDelayTimer = nil;
    
    [_delayedChordTimer invalidate];
    _delayedChordTimer = nil;
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
}

#pragma mark - Button click handlers

- (IBAction)backButtonClicked:(id)sender
{
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    // Save the scores/stars to persistent storage
    [g_userController addStars:_scoreTracker.m_stars forSong:_userSong.m_songId];
    [g_userController addScore:_scoreTracker.m_score forSong:_userSong.m_songId];
    
    // Logging
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play aborted" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInteger:delta], @"PlayTime",
                                                [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                _userSong.m_title, @"Title",
                                                [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];
    
    [g_soundMaster stop];
    
    [self finalLogging];
    
    // If user finished more that 15% of a song and they chose to share the song, upload the userSong session
    if (_songModel.m_percentageComplete >= 0.15)
    {
        // Show end of song screen
        [self endSong];
    }else{
        // Otherwise, we should do it manually
        [g_userController saveCache];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
    
    if ( _postToFeed == YES )
    {
        // This implicitly saves the user cache
        [self uploadUserSongSession];
    }
    else
    {
        // Otherwise, we should do it manually
        [g_userController saveCache];
    }
    
    [g_soundMaster stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishPracticeButtonClicked:(id)sender
{
    isPracticeMode = YES;
    
    [self practiceButtonClicked:sender];
    
    [self drawPracticeMarkersForSong];
    
}

- (IBAction)practiceButtonClicked:(id)sender
{
    _practiceViewOpen = !_practiceViewOpen;
    
    if( _practiceViewOpen == YES) {
        
        [_practiceView setHidden:NO];
        
        [self stopMainEventLoop];
        [g_soundMaster stop];
        [self drawPlayButton:_pauseButton];
        [self restartSong:NO];
        
        // return LEDs to off
        if(g_keysController.connected == YES){
            [g_keysController turnOffAllLeds];
        }
        
    }else{
        
        // Animate out
        int prevheight = _practiceView.frame.size.height;
        int newheight = _practiceView.frame.size.height - 46;
        
        [_startPracticeButton setHidden:YES];
        [_practiceBackButton setHidden:YES];
        [_practiceView setFrame:CGRectMake(0, 0, _practiceView.frame.size.width, newheight)];
        
        [UIView setAnimationsEnabled:YES];
        
        [UIView animateWithDuration:0.5 animations:^(void){
            [_practiceView setFrame:CGRectMake(0,-prevheight,_practiceView.frame.size.width,newheight)];
        }completion:^(BOOL finished){
            [_practiceView setFrame:CGRectMake(0,0,_practiceView.frame.size.width,prevheight)];
            [_practiceView setHidden:YES];
            [_startPracticeButton setHidden:NO];
            [_practiceBackButton setHidden:NO];
        }];
        
        
        [self startEventLoop];
        
    }
}

- (void)repeatButtonClicked:(id)sender
{
    int repeatLoops = [[_repeatButton.titleLabel.text stringByReplacingOccurrencesOfString:@"x" withString:@""] intValue];
    repeatLoops *= 2;
    repeatLoops %= 15;
    
    [_repeatButton setTitle:[NSString stringWithFormat:@"%ix",repeatLoops] forState:UIControlStateNormal];
}

- (void)tempoButtonClicked:(id)sender
{
    NSString *tempo = _tempoButton.titleLabel.text;
    NSString *newTempo;
    
    if([tempo isEqualToString:NSLocalizedString(@"NONE", NULL)] || [tempo isEqualToString:@"125%"]){
        newTempo = @"25%";
    }else if([tempo isEqualToString:@"25%"]){
        newTempo = @"50%";
    }else if([tempo isEqualToString:@"50%"]){
        newTempo = @"66%";
    }else if([tempo isEqualToString:@"66%"]){
        newTempo = @"75%";
    }else if([tempo isEqualToString:@"75%"]){
        newTempo = @"100%";
    }else{
        if(isStandalone){
            newTempo = @"125%";
        }else{
            newTempo = NSLocalizedString(@"NONE", NULL);
        }
    }
    
    [_tempoButton setTitle:newTempo forState:UIControlStateNormal];
    
}

- (IBAction)startPracticeButtonClicked:(id)sender
{
    // Get start and end from the heatmap section selected
    double loops = [_repeatButton.titleLabel.text intValue] - 1;
    double loopStart = _heatMapSelector.frame.origin.x / _practiceHeatMapView.frame.size.width;
    double loopEnd = (_heatMapSelector.frame.origin.x + _heatMapSelector.frame.size.width) / _practiceHeatMapView.frame.size.width;
    
    // Set tempo
    isScrolling = [_tempoButton.titleLabel.text isEqualToString:NSLocalizedString(@"NONE", NULL)] ? NO : YES;
    double tempoPercent = 1.0;
    [self setScrolling:isScrolling];
    [self setRestrictPlayFrame:(isScrolling && g_keysController.connected)];
    
    if(isScrolling){
        tempoPercent = [[_tempoButton.titleLabel.text stringByReplacingOccurrencesOfString:@"%" withString:@""] doubleValue]/100;
    }
    
    // Set metronome
    if(_practiceMetronomeSwitch.isOn != _playMetronome){
        [self toggleMetronome];
    }
    
    [self startWithSongXmlDomPracticeFrom:loopStart toEnd:loopEnd withLoops:loops andTempoPercent:tempoPercent];
    
    [self startMetronomeIfOn];
    
    // Load screen
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLicenseScroll) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(revealPlayView) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeLoadingView) userInfo:nil repeats:NO];
    
    
    // Close the practice selector view
    [self practiceButtonClicked:sender];
}

- (IBAction)menuButtonClicked:(id)sender
{
    if(!_menuIsOpen){
        _forceRestart = NO;
    }
    
    _menuIsOpen = !_menuIsOpen;
    
    // Close the volume everytime we push the menu button
    [_volumeViewController closeView:YES];
    
    if ( _menuIsOpen == YES )
    {
        [_metronomeSwitch setOn:_playMetronome];
        [_sheetMusicSwitch setOn:isSheetMusic];
        [self showHideMenu:_menuView isOpen:YES];
        //[_menuDownArrow setHidden:NO];
    }
    else
    {
        // Toggle Metronome?
        if(_metronomeSwitch.isOn != _playMetronome){
            [self toggleMetronome];
            [self startMetronomeIfOn];
            [self stopMetronomeIfOff];
        }
        
        // Toggle Sheet Music?
        // Restart song?
        if(!_menuIsOpen && _forceRestart){
            [self restartSong:YES];
        }
        
        //if(_sheetMusicSwitch.isOn != isSheetMusic){
        //    [self toggleSheetMusic];
        //}
        
        [self showHideMenu:_menuView isOpen:NO];
    }
}

- (IBAction)songScoreButtonClicked:(id)sender
{
    _songScoreIsOpen = !_songScoreIsOpen;
    
    if( _songScoreIsOpen == YES) {
        
        [self showHideMenu:_songScoreView isOpen:YES];
        
    }else{
        
        [self showHideMenu:_songScoreView isOpen:NO];
        
    }
}

- (void)showHideMenu:(UIView *)menu isOpen:(BOOL)open
{
    
    if(open){
        
        if(!isPracticeMode){
            [_metronomeSwitch setAlpha:0.5];
            [_metronomeSwitch setEnabled:NO];
            
            [_menuMetronomeLabel setAlpha:0.5];
        }else{
            [_metronomeSwitch setAlpha:1.0];
            [_metronomeSwitch setEnabled:YES];
            
            [_menuMetronomeLabel setAlpha:1.0];
        }
        
        if(isStandalone){
            [_sheetMusicSwitch setAlpha:0.5];
            [_sheetMusicSwitch setEnabled:NO];
            [_sheetMusicLabel setAlpha:0.5];
        }else{
            [_sheetMusicSwitch setAlpha:1.0];
            [_sheetMusicSwitch setEnabled:YES];
            [_sheetMusicLabel setAlpha:1.0];
        }
        
        [self stopMainEventLoop];
        [g_soundMaster stop];
        [self drawPlayButton:_pauseButton];
        _songIsPaused = YES;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        menu.transform = CGAffineTransformMakeTranslation(0,46);
        
        [UIView commitAnimations];
        
    }else{
        
        if(!_practiceViewOpen){
            [self startEventLoop];
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(menuSlideComplete)];
        
        menu.transform = CGAffineTransformMakeTranslation( 0, menu.frame.size.height );
        
        [UIView commitAnimations];
    }
}

- (IBAction)pauseButtonClicked:(id)sender
{
    if(!_menuIsOpen){
        _songIsPaused = !_songIsPaused;
        
        if(_songIsPaused == YES){
            
            [self stopMainEventLoop];
            [g_soundMaster stop];
            
            [self drawPlayButton:_pauseButton];
            
        }else{
            [self startEventLoop];
        }
    }
}

- (IBAction)restartButtonClicked:(id)sender
{
    if(!isPracticeMode){
        
        [self restartSong:YES];
        
    }else{
        
        _practiceViewOpen = YES; // Fake view open so it doesn't load again
        [self startPracticeButtonClicked:_startPracticeButton];
        
        [self menuButtonClicked:_menuButton];
    }
    
}

- (IBAction)restartPlayButtonClicked:(id)sender
{
    [self restartSong:YES];
    
    _songScoreIsOpen = YES; // Ensure view closes
    [self songScoreButtonClicked:sender];
}

- (void)restartSong:(BOOL)resetPractice
{
    if(resetPractice){
        isPracticeMode = NO;
        [self setScrolling:isStandalone];
        [self setPracticeMode];
        [self setRestrictPlayFrame:NO];
    }
    
    // Only upload at the end of a song
    if ( _finishButton.isHidden == NO && _postToFeed == YES )
    {
        [self uploadUserSongSession];
    }
    
    if(g_keysController.connected == YES){
        [g_keysController turnOffAllLeds];
    }
    //[_displayController shiftView:0];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play restarted" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:delta], @"PlayTime",
                                                  [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                  _userSong.m_title, @"Title",
                                                  [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                  [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                  nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];
    
    [g_soundMaster start];
    
    [_songModel clearData];
    
    [self startWithSongXmlDom];
    
    if(_menuIsOpen){
        [self menuButtonClicked:nil];
    }
    
    if(_songScoreIsOpen){
        [self songScoreButtonClicked:nil];
    }
    
    // This will also help flush the renderer
    [self updateDifficultyDisplay];
    
}

- (IBAction)outputSwitchChanged:(id)sender
{
    [self toggleAudioRoute];
}

- (IBAction)feedSwitchChanged:(id)sender
{
    /*if ( [g_userController isUserSongSessionQueueFull] == YES && _feedSwitch.isOn == YES )
    {
        [_feedSwitch setOn:NO];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Post"
                                                        message:@"The upload queue is full, cannot post songs until network connectivity restored."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }*/
}

- (IBAction)difficultyButtonClicked:(id)sender
{
    
    switch ( _difficulty )
    {
        default:
        case PlayViewControllerDifficultyEasy:
        {
            _difficulty = PlayViewControllerDifficultyMedium;
            //_scoreTracker.m_baseScore = 20;
        } break;
            
        case PlayViewControllerDifficultyMedium:
        {
            _difficulty = PlayViewControllerDifficultyHard;
            //_scoreTracker.m_baseScore = 40;
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            _difficulty = PlayViewControllerDifficultyEasy;
            //_scoreTracker.m_baseScore = 10;
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

#pragma mark - Practice Mode

- (void)drawPracticeMarkersForSong
{
    
    UIColor * yellowMarkerColor = [UIColor colorWithRed:238/255.0 green:188/255.0 blue:53/255.0 alpha:1.0];
    
    // Check for markers in the song or use defaults
    double songBeats = MAX(_songModel.m_lengthBeats,1); // ensure not 0 in case of error
    NSArray * songMarkers = _songModel.m_song.m_markers;
    if(songMarkers == nil || [songMarkers count] == 0){
        NSMarker * markerOne = [[NSMarker alloc] initWithStartBeat:0.0*songBeats andName:@"Section I"];
        NSMarker * markerTwo = [[NSMarker alloc] initWithStartBeat:0.25*songBeats andName:@"Section II"];
        NSMarker * markerThree = [[NSMarker alloc] initWithStartBeat:0.5*songBeats andName:@"Section III"];
        NSMarker * markerFour = [[NSMarker alloc] initWithStartBeat:0.75*songBeats andName:@"Section IV"];
        
        NSArray * defaultMarkers = [[NSArray alloc] initWithObjects:markerOne,markerTwo,markerThree,markerFour,nil];
        songMarkers = defaultMarkers;
    }
    
    markerButtons = [[NSMutableArray alloc] init];
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    double mapWidth = [frameGenerator getFullscreenWidth] - 34;
    
    DLog(@"MapWidth is %f",mapWidth);
    
    for(int d = 0; d < [songMarkers count]; d++){
        
        NSMarker * marker = [songMarkers objectAtIndex:d];
        
        UIButton * markerButton = [[UIButton alloc] initWithFrame:CGRectMake(mapWidth*(marker.m_startBeat/songBeats), 0, MARKER_SIZE*5, MARKER_HEIGHT*1.5)];
        
        // Draw marker
        
        CGSize size = CGSizeMake(markerButton.frame.size.width, markerButton.frame.size.height);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetStrokeColorWithColor(context, yellowMarkerColor.CGColor);
        CGContextSetFillColorWithColor(context, yellowMarkerColor.CGColor);
        
        CGContextSetLineWidth(context, 2.0);
        
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 0, MARKER_HEIGHT);
        CGContextAddLineToPoint(context, MARKER_SIZE, MARKER_HEIGHT);
        CGContextClosePath(context);
        
        CGContextFillPath(context);
        
        UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
        
        [markerButton addSubview:image];
        
        UIGraphicsEndImageContext();
        
        UILabel * markerTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARKER_SIZE-2,-2,100,MARKER_HEIGHT)];
        [markerTextLabel setFont:[UIFont fontWithName:@"Avenir Next" size:10.0]];
        [markerTextLabel setTextColor:yellowMarkerColor];
        [markerTextLabel setAlpha:0.7];
        markerTextLabel.text = marker.m_name;
        
        [markerButton addSubview:markerTextLabel];
        
        //
        
        [_practiceHeatMapMarkerArea addSubview:markerButton];
        
        [markerButton addTarget:self action:@selector(selectSection:) forControlEvents:UIControlEventTouchUpInside];
        
        [markerButtons addObject:markerButton];
        
    }
    
    // Clear previous
    [_heatMapSelector removeFromSuperview];
    [_heatMapLeftSlider removeFromSuperview];
    [_heatMapRightSlider removeFromSuperview];
    
    // Draw section selection area and invisible left/right draggers
    UIButton * firstMarker = [markerButtons firstObject];
    UIButton * secondMarker = [markerButtons objectAtIndex:1];
    double start = firstMarker.frame.origin.x / mapWidth;
    double end = secondMarker.frame.origin.x / mapWidth;
    
    _heatMapSelector = [[UIButton alloc] initWithFrame:CGRectMake(start*mapWidth, 0, (end-start)*mapWidth, _practiceHeatMapView.frame.size.height)];
    [_heatMapSelector setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
    
    _heatMapLeftSlider = [[UIButton alloc] initWithFrame:CGRectMake(start*mapWidth-ADJUSTOR_SIZE/2.0, 0, ADJUSTOR_SIZE, _practiceHeatMapView.frame.size.height)];
    [_heatMapLeftSlider setBackgroundColor:[UIColor whiteColor]];
    [_heatMapLeftSlider setAlpha:0.5];
    _heatMapLeftSlider.layer.cornerRadius = ADJUSTOR_SIZE/2.0;
    
    _heatMapRightSlider = [[UIButton alloc] initWithFrame:CGRectMake(end*mapWidth-ADJUSTOR_SIZE/2.0, 0, ADJUSTOR_SIZE, _practiceHeatMapView.frame.size.height)];
    [_heatMapRightSlider setBackgroundColor:[UIColor whiteColor]];
    [_heatMapRightSlider setAlpha:0.5];
    _heatMapRightSlider.layer.cornerRadius = ADJUSTOR_SIZE/2.0;
    
    [_practiceHeatMapView addSubview:_heatMapSelector];
    [_practiceHeatMapView addSubview:_heatMapLeftSlider];
    [_practiceHeatMapView addSubview:_heatMapRightSlider];
    
    
    UIPanGestureRecognizer * heatMapDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHeatMap:)];
    UIPanGestureRecognizer * leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHeatMapLeft:)];
    UIPanGestureRecognizer * rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHeatMapRight:)];
    
    [_heatMapSelector addGestureRecognizer:heatMapDrag];
    [_heatMapLeftSlider addGestureRecognizer:leftPan];
    [_heatMapRightSlider addGestureRecognizer:rightPan];
    
    // Draw tempo standard
    _tempoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
}

-(void)setPracticeHeatMapViewImageView:(UIImageView*)imageView
{
    if(_practiceHeatMapViewImageView != nil){
        [_practiceHeatMapViewImageView removeFromSuperview];
    }
    
    _practiceHeatMapViewImageView = imageView;
    
    [_practiceHeatMapView addSubview:imageView];
    
    [_practiceHeatMapView bringSubviewToFront:_heatMapSelector];
    [_practiceHeatMapView bringSubviewToFront:_heatMapLeftSlider];
    [_practiceHeatMapView bringSubviewToFront:_heatMapRightSlider];
}

-(void)selectSection:(id)sender
{
    UIButton * senderButton = (UIButton*)sender;
    UIButton * nextButton = nil;
    
    for(int b = 0; b < [markerButtons count]-1; b++){
        if([markerButtons objectAtIndex:b] == senderButton){
            nextButton = [markerButtons objectAtIndex:b+1];
        }
    }
    
    // Move the left slider and heat map selector to this button
    double leftX = senderButton.frame.origin.x;
    double rightX;
    
    if(nextButton == nil){
        rightX = _practiceHeatMapView.frame.size.width;
    }else{
        rightX = nextButton.frame.origin.x;
    }
    
    [_heatMapLeftSlider setFrame:CGRectMake(leftX-ADJUSTOR_SIZE/2.0,0,ADJUSTOR_SIZE,_practiceHeatMapView.frame.size.height)];
    
    [_heatMapRightSlider setFrame:CGRectMake(rightX-ADJUSTOR_SIZE/2.0,0,ADJUSTOR_SIZE,_practiceHeatMapView.frame.size.height)];
    
    [_heatMapSelector setFrame:CGRectMake(leftX, 0, rightX-leftX, _heatMapSelector.frame.size.height)];
    
}

-(void)panHeatMap:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:_practiceHeatMapView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        dragFirstX = _heatMapSelector.frame.origin.x;
    }
    
    float minX = 0;
    float maxX = _practiceHeatMapView.frame.size.width - _heatMapSelector.frame.size.width;
    float newX = newPoint.x + dragFirstX;
    
    // wrap to boundary
    if(newX < minX){
        newX=minX;
    }else if(newX > maxX){
        newX = maxX;
    }
    
    if(newX >= minX && newX <= maxX){
        
        CGRect newHeatMapFrame = CGRectMake(newX, 0, _heatMapSelector.frame.size.width, _heatMapSelector.frame.size.height);
        
        [_heatMapSelector setFrame:newHeatMapFrame];
        
        CGRect newLeftFrame = CGRectMake(newX-ADJUSTOR_SIZE/2.0,0,ADJUSTOR_SIZE,_practiceHeatMapView.frame.size.height);
        CGRect newRightFrame = CGRectMake(newX+_heatMapSelector.frame.size.width-ADJUSTOR_SIZE/2.0,0,ADJUSTOR_SIZE,_practiceHeatMapView.frame.size.height);
        [_heatMapLeftSlider setFrame:newLeftFrame];
        [_heatMapRightSlider setFrame:newRightFrame];
    }
    
}

-(void)panHeatMapLeft:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:_practiceHeatMapView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        leftFirstX = _heatMapLeftSlider.frame.origin.x;
        [_heatMapLeftSlider setAlpha:0.8];
    }
    
    float minX = -ADJUSTOR_SIZE/2.0;
    float maxX = _heatMapRightSlider.frame.origin.x - ADJUSTOR_SIZE;
    float newX = newPoint.x + leftFirstX;
    
    // wrap to boundary
    if(newX < minX || newX < minX+0.2*ADJUSTOR_SIZE/2){
        newX=minX;
    }
    
    if(newX >= minX && newX <= maxX){
        CGRect newLeftFrame = CGRectMake(newX,0,ADJUSTOR_SIZE,_practiceHeatMapView.frame.size.height);
        
        [_heatMapLeftSlider setFrame:newLeftFrame];
        
        CGRect newHeatMapFrame = CGRectMake(newX+ADJUSTOR_SIZE/2, 0, _heatMapRightSlider.frame.origin.x-_heatMapLeftSlider.frame.origin.x, _practiceHeatMapView.frame.size.height);
        
        [_heatMapSelector setFrame:newHeatMapFrame];
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        [_heatMapLeftSlider setAlpha:0.5];
    }
}

- (void)panHeatMapRight:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:_practiceHeatMapView];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        rightFirstX = _heatMapRightSlider.frame.origin.x;
        [_heatMapRightSlider setAlpha:0.8];
    }
    
    float minX = _heatMapLeftSlider.frame.origin.x + ADJUSTOR_SIZE;
    float maxX = _practiceHeatMapView.frame.size.width - ADJUSTOR_SIZE/2.0;
    float newX = newPoint.x + rightFirstX;
    
    // wrap to boundary
    if(newX > maxX || newX > maxX-0.2*ADJUSTOR_SIZE/2){
        newX=maxX;
    }
    
    if(newX >= minX && newX <= maxX){
        CGRect newRightFrame = CGRectMake(newX,0,ADJUSTOR_SIZE,_practiceHeatMapView.frame.size.height);
        
        [_heatMapRightSlider setFrame:newRightFrame];
        
        CGRect newHeatMapFrame = CGRectMake(_heatMapSelector.frame.origin.x, 0, _heatMapRightSlider.frame.origin.x-_heatMapLeftSlider.frame.origin.x, _practiceHeatMapView.frame.size.height);
        
        [_heatMapSelector setFrame:newHeatMapFrame];
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        [_heatMapRightSlider setAlpha:0.5];
    }
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
    UIColor * transparentWhite = [UIColor colorWithRed:171/255.0 green:135/255.0 blue:35/255.0 alpha:1.0];
    
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
    
    [button setBackgroundColor:[UIColor colorWithRed:237/255.0 green:132/255.0 blue:63/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(button.frame.size.width, button.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int pauseWidth = 8;
    
    CGFloat pauseHeight = button.frame.size.height - 22;
    CGRect pauseFrameLeft = CGRectMake(button.frame.size.width/2 - pauseWidth - 3, 12, pauseWidth, pauseHeight);
    CGRect pauseFrameRight = CGRectMake(pauseFrameLeft.origin.x+pauseWidth+4, 12, pauseWidth, pauseHeight);
    
    CGContextAddRect(context,pauseFrameLeft);
    CGContextAddRect(context,pauseFrameRight);
    CGContextSetFillColorWithColor(context,[UIColor colorWithRed:170/255.0 green:93/255.0 blue:43/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context,pauseFrameLeft);
    CGContextFillRect(context,pauseFrameRight);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [button addSubview:image];
    
    UIGraphicsEndImageContext();
}

#pragma mark - UI & Misc related helpers

- (void)initControls
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    _postToFeed = ![settings boolForKey:@"DisablePostToFeed"];
    _autocomplete = [settings boolForKey:@"CompleteChords"];
    isSheetMusic = [settings boolForKey:@"SheetMusic"];
    
    if(isStandalone){
        isSheetMusic = NO;
    }
    
    g_keysMath.isSheetMusic = isSheetMusic;
    [_displayController setSheetMusic:isSheetMusic];
}

- (void)handleResignActive
{
    [self pauseSong];
    
    _playTimeAdjustment += [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970];
}

- (void)handleBecomeActive
{
    
    _playTimeStart = [NSDate date];
    _audioRouteTimeStart = [NSDate date];
    _metronomeTimeStart = [NSDate date];
}

- (void)removeLoadingView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6f];
    //    [UIView setAnimationDelegate:_loadingView];
    //    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    
    _loadingView.alpha = 0.0f;
    
    [UIView commitAnimations];
    
    if(!_practiceViewOpen){
        [self startEventLoop];
    }
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
        
        [_volumeButton setImage:[UIImage imageNamed:@"SpeakerIcon"] forState:UIControlStateNormal];
        [_volumeButton setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 3, 0)];
        
    }
    else
    {
        [_volumeButton setImage:[UIImage imageNamed:@"AuxIcon"] forState:UIControlStateNormal];
        [_volumeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
    }
    
    // Invert it so we log the route we came from
    NSString * route = !_speakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_audioRouteTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    if ( delta > 0 )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle audio route" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSNumber numberWithInteger:delta], @"PlayTime",
                                                               [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                               _userSong.m_title, @"Title",
                                                               [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                               [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                               route, @"AudioRoute",
                                                               nil]];
        
        _audioRouteTimeStart = [NSDate date];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:_speakerRoute forKey:@"RouteToSpeaker"];
    
    [settings synchronize];
    
}

- (IBAction)toggleSheetMusic:(id)sender
{
    isSheetMusic = _sheetMusicSwitch.isOn;
    g_keysMath.isSheetMusic = isSheetMusic;
    [_displayController setSheetMusic:isSheetMusic];
    
    _forceRestart = YES;
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setBool:isSheetMusic forKey:@"SheetMusic"];
    
    [settings synchronize];
}

- (void)toggleMetronome
{
    
    if ( _playMetronome == NO )
    {
        
        _playMetronome = YES;
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle metronome" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                             _userSong.m_title, @"Title",
                                                             [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                             [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                             @"On", @"Metronome",
                                                             nil]];
        
        _metronomeTimeStart = [NSDate date];
        
    }
    else
    {
        _playMetronome = NO;
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_metronomeTimeStart timeIntervalSince1970] + _playTimeAdjustment;
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Play toggle metronome" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                             _userSong.m_title, @"Title",
                                                             [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                             [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                             @"Off", @"Metronome",
                                                             [NSNumber numberWithInteger:delta], @"PlayTime",
                                                             nil]];
        
        _metronomeTimeStart = [NSDate date];
        
    }
    
}

- (void)startMetronomeIfOn
{
    // Metronome is being called in main loop instead of a separate timer
    
    if(_playMetronome && isPracticeMode && _metronomeTimer == nil){
        
        [_metronomeTimer invalidate];
        _metronomeTimer = nil;
        
        //_metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
        
        DLog(@"Beat is %f",1.0/_songModel.m_beatsPerSecond);
    }
}

- (void)stopMetronomeIfOff
{
    if(!_playMetronome && isPracticeMode){
        
        [_metronomeTimer invalidate];
        _metronomeTimer = nil;
    }
}

- (void)playMetronomeTick
{
    if(!_songIsPaused && !_menuIsOpen){
        [g_soundMaster playMetronomeTick];
    }
}

- (void)setVolumeGain:(float)gain
{
    [g_soundMaster setChannelGain:gain];
}

- (void)updateDifficultyDisplay
{    
    [self hideAllKeyboards];
    [self showKeyboard:_difficulty];
    
    [_displayController updateDifficulty:_difficulty];
    [g_keysMath setDifficulty:_difficulty];
    
    switch ( _difficulty )
    {
        default:
        case PlayViewControllerDifficultyEasy:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffEasyButton"] forState:UIControlStateNormal];
            [_scoreDifficultyButton setImage:[UIImage imageNamed:@"DiffEasyButton"] forState:UIControlStateNormal];
            [_practiceDifficultyButton setImage:[UIImage imageNamed:@"DiffEasyButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Easy", NULL);
            _scoreDifficultyLabel.text = NSLocalizedString(@"Easy", NULL);
            _practiceDifficultyLabel.text = NSLocalizedString(@"Easy", NULL);
            
        } break;
            
        case PlayViewControllerDifficultyMedium:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffMedButton"] forState:UIControlStateNormal];
            [_scoreDifficultyButton setImage:[UIImage imageNamed:@"DiffMedButton"] forState:UIControlStateNormal];
            [_practiceDifficultyButton setImage:[UIImage imageNamed:@"DiffMedButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Medium", NULL);
            _scoreDifficultyLabel.text = NSLocalizedString(@"Medium", NULL);
            _practiceDifficultyLabel.text = NSLocalizedString(@"Medium", NULL);
            
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            [_scoreDifficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            [_practiceDifficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            _scoreDifficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            _practiceDifficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            
        } break;
    }
}

- (void)hideAllKeyboards
{
    [keyboard setHidden:YES];
    [keyboardGrid setHidden:YES];
    [keyboardRange setHidden:YES];
    [keyboardStandaloneEasy setHidden:YES];
    [keyboardStandaloneMedium setHidden:YES];
    [keyboardStandaloneHard setHidden:YES];

}

- (void)showKeyboard:(PlayViewControllerDifficulty)difficulty
{
    if(isSheetMusic){
        return;
    }
    
    float keyboardOnAlpha = 0.9;
    
    if(!isStandalone){
        
        DLog(@"Show standard keyboard");
        [keyboardGrid setAlpha:keyboardOnAlpha];
        [keyboardGrid setHidden:NO];
        [keyboardRange setHidden:NO];
        
        // Refresh keyboard is done when the data is set for song
        //[self refreshKeyboardToKeyMin];
        
        selectedKeyboard = keyboardGrid;
        
    }else{
        
        switch (_difficulty) {
            case PlayViewControllerDifficultyEasy:
                DLog(@"Show easy keyboard");
                [keyboardStandaloneEasy setAlpha:keyboardOnAlpha];
                [keyboardStandaloneEasy setHidden:NO];
                selectedKeyboard = keyboardStandaloneEasy;
                break;
            
            case PlayViewControllerDifficultyMedium:
                DLog(@"Show medium keyboard");
                [keyboardStandaloneMedium setAlpha:keyboardOnAlpha];
                [keyboardStandaloneMedium setHidden:NO];
                selectedKeyboard = keyboardStandaloneMedium;
                break;
                
            case PlayViewControllerDifficultyHard:
                DLog(@"Show hard keyboard");
                [keyboardStandaloneHard setAlpha:keyboardOnAlpha];
                [keyboardStandaloneHard setHidden:NO];
                selectedKeyboard = keyboardStandaloneHard;
                break;
        }
        
        [self setStandaloneKeysToExactSize];
    }
    
}

- (void)setStandaloneKeysToExactSize
{
    int whiteKeyCount = KEYS_WHITE_KEY_EASY_COUNT;
    if(_difficulty == PlayViewControllerDifficultyMedium) whiteKeyCount = KEYS_WHITE_KEY_MED_COUNT;
    if(_difficulty == PlayViewControllerDifficultyHard) whiteKeyCount = KEYS_WHITE_KEY_HARD_COUNT;
    
    float keyWidth = [g_keysMath getBlackKeyFrameSize:whiteKeyCount inSize:CGSizeMake(g_keysMath.glScreenWidth,g_keysMath.glScreenHeight)].width;
    
    for(UIView * keyView in selectedKeyboard.subviews){
        if(keyView.tag == 1){
            // Ensure centers stay the same
            float keyCenter = keyView.frame.origin.x+keyView.frame.size.width/2.0;
            float keyX = keyCenter-keyWidth/2.0;
            float keyDiff = keyView.frame.origin.x-keyX;
            
            // Set width
            for(NSLayoutConstraint * constraint in keyView.constraints){
                
                // Adjust width constraint
                if(constraint.firstAttribute == NSLayoutAttributeWidth){
                    constraint.constant = keyWidth;
                }
            }
            
            // Set horizontal
            for(NSLayoutConstraint * constraint in selectedKeyboard.constraints){
                
                // Adjust width constraint
                if(constraint.firstAttribute == NSLayoutAttributeLeading && constraint.firstItem == keyView){
                    constraint.constant -= keyDiff;
                }
            }
        }
    }
}

- (void)positionKeyboard:(int)keyboardKey
{
    double keyboardRangeWidth = keyboardRange.frame.size.width;
    int keyboardWhiteKey = [g_keysMath getWhiteKeyFromNthKey:keyboardKey];
    int keyboardMin = [g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]]; // Count through the white key prior
    
    DLog(@"POSITION KEYBOARD TO %i",keyboardWhiteKey);
    
    DLog(@"Key white key is r%iw%i rel %i (song range key min is r%iw%i)",keyboardKey,keyboardWhiteKey,keyboardWhiteKey-keyboardMin,[g_keysMath getForcedRangeKeyMin],[g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]]);

    double keyboardX = ((double)(keyboardWhiteKey - keyboardMin) / (double)[g_keysMath getForcedRangeWhiteKeyCount]) * keyboardRangeWidth;
    double keyboardWidth = ((double)(ceilf([g_keysMath cameraScale]*KEYS_WHITE_KEY_DISPLAY_COUNT)) / (double)[g_keysMath getForcedRangeWhiteKeyCount]) * keyboardRangeWidth;
    
    g_keysMath.keyboardPositionKey = keyboardKey;
    
    DLog(@"Updating keyboard position to %i",g_keysMath.keyboardPositionKey);
    
    
    [UIView animateWithDuration:0.3 animations:^(void){
       [keyboardPosition setFrame:CGRectMake(keyboardX,1,keyboardWidth,keyboardPosition.frame.size.height)];
    }completion:^(BOOL finished){
        
    }];
}

- (void)refreshKeyboardToKeyMin:(BOOL)forceRefresh
{
    //NSDictionary * songRange = [_displayController getNoteRangeForSong];
    
    //int keyboardKey = [[songRangse objectForKey:@"Min"] intValue];
    
    if(!isStandalone){
        [g_keysMath resetCameraScale];
        
        [self checkHorizonForCameraPosition:forceRefresh];
    }
    
    //[self positionKeyboard:keyboardKey];
    //[self drawKeyboardGridFromMin:keyboardKey];
    //[_displayController shiftViewToKey:keyboardKey];
    
}

- (void)refreshKeyboardToKey:(KeyPosition)key
{
    [self positionKeyboard:key];
    [self drawKeyboardGridFromMin:key];
    [_displayController shiftViewToKey:key];
}

- (void)displayKeyboardRangeChanged
{
    [g_keysMath drawKeyboardInFrame:keyboardRange fromKeyMin:[g_keysMath getForcedRangeKeyMin] withNumberOfKeys:[g_keysMath getForcedRangeKeyCount] andNumberOfWhiteKeys:[g_keysMath getForcedRangeWhiteKeyCount] invertColors:TRUE colorActive:YES drawKeysDown:NO];
}

- (void)drawKeyboardGridFromMin:(int)keyMin
{
    // This is slightly hacked at the moment, but other methods calculate the range with different rounding and this approximates the match better than ceil or round
    
    [g_keysMath drawKeyboardInFrame:keyboardGrid fromKeyMin:keyMin withNumberOfKeys:ceil(0.99*[g_keysMath cameraScale]*KEYS_DISPLAYED_NOTES_COUNT) andNumberOfWhiteKeys:ceil(0.99*[g_keysMath cameraScale]*KEYS_WHITE_KEY_DISPLAY_COUNT) invertColors:FALSE colorActive:NO drawKeysDown:YES];
}

- (void)lightKeyOnUserPlay:(KeyPosition)key
{
    [g_keysMath lightKeyDown:[g_keysMath getForcedRangeKey:key]];
    
    [self drawKeyboardGridFromMin:[g_keysMath keyboardPositionKey]];
    
    // Timer to key up
    
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(lightKeyUp:) userInfo:[NSNumber numberWithInt:key] repeats:NO];
     
    
}

- (void)lightKeyUp:(NSTimer *)timer
{
    KeyPosition key = [[timer userInfo] intValue];
    
    [g_keysMath lightKeyUp:[g_keysMath getForcedRangeKey:key]];
    
    [self drawKeyboardGridFromMin:[g_keysMath keyboardPositionKey]];
    
}

- (void)lightKeyOnPlay:(KeyPosition)key isIncorrect:(BOOL)incorrect isMissed:(BOOL)isMissed
{
    // Light key on full range keyboard
    
    key = [g_keysMath getForcedRangeKey:key];
    
    double keyWidth = keyboardOverview.frame.size.width / [g_keysMath getForcedRangeWhiteKeyCount];
    double drawKeyWidth = keyboardOverview.frame.size.width / KEYS_TOTAL_WHITE_KEY_COUNT;
    double overlayWidth = 1.5*drawKeyWidth;
    BOOL isBlackKey = [g_keysMath isKeyBlackKey:key];
    
    int whiteKey = [g_keysMath getWhiteKeyFromNthKey:key] - [g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]];
    
    double whiteKeyX = whiteKey*keyWidth;
    double nextWhiteKeyX = (whiteKey+1)*keyWidth;
    
    double keyCenter = (isBlackKey) ? (whiteKeyX - drawKeyWidth/2.0) : (whiteKeyX+nextWhiteKeyX)/2.0 - drawKeyWidth/2.0;
    
    UIView * keyView = [[UIView alloc] initWithFrame:CGRectMake(keyCenter,keyboardOverview.frame.size.height/2.0-drawKeyWidth/2.0,drawKeyWidth,drawKeyWidth)];
    
    UIView * keyOverlay = [[UIView alloc] initWithFrame:CGRectMake(keyView.frame.origin.x-(overlayWidth-drawKeyWidth)/2.0,keyView.frame.origin.y-(overlayWidth-drawKeyWidth)/2.0,overlayWidth,overlayWidth)];
    
    if(isMissed){
        [keyView setBackgroundColor:[UIColor colorWithRed:222/255.0 green:85/255.0 blue:49/255.0 alpha:1.0]];
        [keyOverlay setBackgroundColor:[UIColor colorWithRed:222/255.0 green:85/255.0 blue:49/255.0 alpha:1.0]];
    }else if(incorrect){
        [keyView setBackgroundColor:[UIColor colorWithRed:238/255.0 green:188/255.0 blue:53/255.0 alpha:1.0]];
        [keyOverlay setBackgroundColor:[UIColor colorWithRed:238/255.0 green:188/255.0 blue:53/255.0 alpha:1.0]];
    }else if(!isBlackKey){
        [keyView setBackgroundColor:[UIColor whiteColor]];
        [keyOverlay setBackgroundColor:[UIColor whiteColor]];
    }else{
        [keyView setBackgroundColor:[UIColor blackColor]];
        [keyOverlay setBackgroundColor:[UIColor blackColor]];
    }
    
    keyView.layer.cornerRadius = 2.0f;
    keyOverlay.layer.cornerRadius = 2.0f;
    
    [keyView setAlpha:0.9];
    [keyOverlay setAlpha:0.4];
    [keyboardOverview addSubview:keyView];
    [keyboardOverview addSubview:keyOverlay];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        [keyView setAlpha:0.0];
        [keyOverlay setAlpha:0.0];
    }completion:^(BOOL finished){
        [keyView removeFromSuperview];
        [keyOverlay removeFromSuperview];
    }];
    
}

- (void)updateScoreDisplayWithAccuracy:(double)accuracy
{
    //int prevScore = [[self unformatScore:_scoreLabel.text] intValue];
    int newScore = _scoreTracker.m_score;
    //int scoreDiff = newScore - prevScore;
    
    // Determine accuracy color
    UIColor * accuracyColor;
    
    if(accuracy < 0){
        // Starting accuracy
        accuracyColor = [UIColor whiteColor];
    }
    if(accuracy < 0.5){
        accuracyColor = [UIColor colorWithRed:1.0 green:((2.0*accuracy)*115.0+65.0)/255.0 blue:50/255.0 alpha:0.9];
    }else{
        accuracyColor = [UIColor colorWithRed:2.0*(1.0-accuracy)*255.0/255.0 green:180/255.0 blue:50/255.0 alpha:0.9];
    }
    
    //[_scoreLabel setTextColor:accuracyColor];
    
    // Animate subscore
    //if(scoreDiff > 0){
    //    [self animateSubscoreWithText:[NSString stringWithFormat:@"+%i",scoreDiff] andColor:accuracyColor];
    //}
    
    // Update score label
    //[_scoreLabel setText:[self formatScore:_scoreTracker.m_score]];
    //[self setScoreMultiplier:_scoreTracker.m_multiplier];
    
    // Update stars
    [self displayStars:_scoreTracker.m_stars isFinal:NO];
    
}

- (void)animateSubscoreWithText:(NSString*)subscore andColor:(UIColor *)textColor
{
    /*
    _subscoreLabel.text = subscore;
    [_subscoreLabel setTextColor:textColor];
    [_subscoreLabel setAlpha:0.8];
    [_subscoreLabel setHidden:NO];
    [self.view bringSubviewToFront:_subscoreLabel];
    
    [_subscoreLabel setFrame:CGRectMake(_subscoreLabel.frame.origin.x,252,_subscoreLabel.frame.size.width,_subscoreLabel.frame.size.height)];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        
        [_subscoreLabel setAlpha:0.0];
        //[_subscoreLabel setFrame:CGRectMake(_subscoreLabel.frame.origin.x,282,_subscoreLabel.frame.size.width,_subscoreLabel.frame.size.height)];
        
    } completion:^(BOOL finished){
        //[_subscoreLabel setHidden:YES];
        //[_subscoreLabel setFrame:CGRectMake(_subscoreLabel.frame.origin.x,252,_subscoreLabel.frame.size.width,_subscoreLabel.frame.size.height)];
    }];
    */
}

- (void)setScoreMultiplier:(int)multiplier
{
    /*
    _multiplierTextLabel.text = [NSString stringWithFormat:@"%iX",multiplier];
    
    // Determine color
    if(multiplier <= 1){
        [_multiplierTextLabel setBackgroundColor:[UIColor colorWithRed:255/255.0 green:180/255.0 blue:50/255.0 alpha:1.0]];
    }else if(multiplier < 4){
        [_multiplierTextLabel setBackgroundColor:[UIColor colorWithRed:180/255.0 green:180/255.0 blue:50/255.0 alpha:1.0]];
    }else if(multiplier < 6){
        [_multiplierTextLabel setBackgroundColor:[UIColor colorWithRed:135/255.0 green:180/255.0 blue:50/255.0 alpha:1.0]];
    }else if(multiplier < 8){
        [_multiplierTextLabel setBackgroundColor:[UIColor colorWithRed:85/255.0 green:180/255.0 blue:50/255.0 alpha:1.0]];
    }else{
        [_multiplierTextLabel setBackgroundColor:[UIColor colorWithRed:0/255.0 green:180/255.0 blue:50/255.0 alpha:1.0]];
    }
     */
}

- (void)displayStars:(double)numStars isFinal:(BOOL)final
{
    UIButton * starFive = (final) ? _scoreSumStarFive : _scoreStarFive;
    UIButton * starFour = (final) ? _scoreSumStarFour : _scoreStarFour;
    UIButton * starThree = (final) ? _scoreSumStarThree : _scoreStarThree;
    UIButton * starTwo = (final) ? _scoreSumStarTwo : _scoreStarTwo;
    UIButton * starOne = (final) ? _scoreSumStarOne : _scoreStarOne;
    
    if(numStars >= 5){
        [starFive setAlpha:1.0];
    }else if(numStars > 4){
        [starFive setAlpha:0.6];
    }else{
        [starFive setAlpha:0.3];
    }
    
    if(numStars >= 4){
        [starFour setAlpha:1.0];
    }else if(numStars > 3){
        [starFour setAlpha:0.6];
    }else{
        [starFour setAlpha:0.3];
    }
    
    if(numStars >= 3){
        [starThree setAlpha:1.0];
    }else if(numStars > 2){
        [starThree setAlpha:0.6];
    }else{
        [starThree setAlpha:0.3];
    }
    
    if(numStars >= 2){
        [starTwo setAlpha:1.0];
    }else if(numStars > 1){
        [starTwo setAlpha:0.6];
    }else{
        [starTwo setAlpha:0.3];
    }
    
    if(numStars >= 1){
        [starOne setAlpha:1.0];
    }else if(numStars > 0){
        [starOne setAlpha:0.6];
    }else{
        [starOne setAlpha:0.3];
    }
}

- (NSString *)formatScore:(int)scoreVal
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString * numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:scoreVal]];
    
    return numberAsString;
}

- (NSString *)unformatScore:(NSString*)scoreStr
{
    scoreStr = [scoreStr stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    return scoreStr;
}

- (void)updateProgressDisplay
{
    
    //  _progressFillView.frame.size.height
    CGFloat delta = _songModel.m_percentageComplete * 275;
    
    [_progressFillView setHidden:NO];
    
    [_progressFillView setFrame:CGRectMake(_progressFillView.frame.origin.x, _progressFillView.frame.origin.y, _progressFillView.frame.size.width, delta)];
    
}

- (void)finalLogging
{
    
    NSString* route = _speakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_audioRouteTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
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
    
    UserSongSession * session = [[UserSongSession alloc] init];
    
    session.m_userSong = _userSong;
    session.m_score = _scoreTracker.m_score;
    session.m_stars = _scoreTracker.m_stars;
    session.m_combo = _scoreTracker.m_streak;
    session.m_notes = @"Recorded in gTar Play";
    
    DLog(@"User song title is %@",_userSong.m_title);
    
    if([g_soundMaster getCurrentInstrument] < [[g_soundMaster getInstrumentList] count]){
        _songRecorder.m_song.m_instrument = [[g_soundMaster getInstrumentList] objectAtIndex:[g_soundMaster getCurrentInstrument]];
    }
    
    DLog(@"Get current instrument is %@",_songRecorder.m_song.m_instrument);
    //_songRecorder.m_song.m_instrument = [[g_audioController getInstrumentNames] objectAtIndex:[g_audioController getCurrentSamplePackIndex]];
    
    // Create the xmp
    session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
    session.m_created = time(NULL);
    
    // Upload song to server. This also persists the upload in case of network failure
    [g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    //    [g_telemetryController logEvent:KeysPlaySongShared
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

- (void)startEventLoop
{
    [g_soundMaster start];
    [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
    [self drawPauseButton:_pauseButton];
    
    _songIsPaused = NO;
    
}

- (void)mainEventLoop {
    
//#ifdef Debug_BUILD
    if(g_keysController.connected) {
        
        // DEBUG tapping screen hits the current notes (see: touchesbegan)
        if ( _skipNotes == YES ) {
            
            _skipNotes = NO;
            
            if ( [_songModel.m_currentFrame.m_notesPending count] > 0 ) {
                
                NSNote * note = [_songModel.m_currentFrame.m_notesPending objectAtIndex:0];
                
                KeysPress press;
                press.velocity = KeysMaxPressVelocity;
                press.position = [g_keysMath getForcedRangeKey:note.m_key];
                
                [self keysNoteOn:press forFrame:nil];
                
            } else if ( [_songModel.m_nextFrame.m_notesPending count] > 0 ) {
                
                NSNote * note = [_songModel.m_nextFrame.m_notesPending objectAtIndex:0];
                
                KeysPress press;
                press.velocity = KeysMaxPressVelocity;
                press.position = [g_keysMath getForcedRangeKey:note.m_key];
                
                [self keysNoteOn:press forFrame:nil];
            }
            
            _refreshDisplay = YES;
            
        }
    }
//#endif
    
    if(g_keysController.connected && !isStandalone) {
        
        // Play notes out of keyboard range
        
        BOOL allNotesOutOfRange = [g_keysMath allNotesOutOfRangeForFrame:_songModel.m_currentFrame];
        
        if ( ([_songModel.m_currentFrame.m_notesPending count] > 0) && (allNotesOutOfRange || [_songModel.m_currentFrame.m_notesHit count] > 0)) {
         
            for(NSNote * note in _songModel.m_currentFrame.m_notesPending){
                
                if([g_keysMath noteOutOfRange:note.m_key]){
                    //DLog(@"Note out of range value is %i",note.m_key);
                    
                    /*UIAlertView * _alertView = [[UIAlertView alloc] initWithTitle:@"Note out of range"
                     message:[NSString stringWithFormat:@"n=%i min=%i, max=%i",note.m_key,g_keysController.range.keyMin,g_keysController.range.keyMax]
                     delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
                     [_alertView show];*/
                    
                    KeysPress press;
                    press.velocity = KeysMaxPressVelocity;
                    press.position = note.m_key;
                    
                    [self keysNoteOn:press forFrame:nil];
                    
                    _refreshDisplay = YES;
                    
                }
                
            }
        }
    }
    
    // Advance song model and recorder
    
    if ( _animateSongScrolling == YES ) {
        double currentBeat = [_songModel incrementTimeSerialAccess:SECONDS_PER_EVENT_LOOP isRestrictFrame:isRestrictPlayFrame];
        
        if(_playMetronome){
            if(currentBeat >= lastMetronomeBeat + 1.0){
                lastMetronomeBeat = floor(currentBeat);
                [self playMetronomeTick];
            }
        }
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

- (void)checkHorizonForCameraPosition:(BOOL)forceRefresh
{
    NSDictionary * horizonMinMax = [_songModel getMinAndMaxNotesForSurroundingFrames];
    KeyPosition maxNote = [[horizonMinMax objectForKey:@"Max"] intValue];
    KeyPosition minNote = [[horizonMinMax objectForKey:@"Min"] intValue];
    
    int margin = 0; // Note padding
    
    minNote = MAX(minNote-margin,0);
    maxNote = MIN(maxNote+margin,KEYS_KEY_COUNT-1);
    
    // If minNote+displayCount is out of range
    // use rangeMax-displayCount as min (because all the notes to highlight
    // are within range)
    if(minNote+KEYS_DISPLAYED_NOTES_COUNT > [g_keysController range].keyMax){
        minNote = [g_keysController range].keyMax-KEYS_DISPLAYED_NOTES_COUNT+1;
    }
    
    if(maxNote > 0 || minNote < KEYS_KEY_COUNT){
        [g_keysMath expandCameraToMin:minNote andMax:maxNote forceRefresh:forceRefresh];
    }
}

#pragma mark - KeysControllerObserver

- (void)keysDown:(KeyPosition)position
{
    
}

- (void)keysUp:(KeyPosition)position
{
    
}

- (void)keysNoteOn:(KeysPress)press
{
    [self keysNoteOn:press forFrame:nil];
}

- (void)keysNoteOn:(KeysPress)press forFrame:(NSNoteFrame*)frameToPlay
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
    
    KeyPosition key = press.position;
    KeysPressVelocity velocity = press.velocity;
    
    if ( _currentFrame == nil && frameToPlay == nil && !isRestrictPlayFrame)
    {
        [_songModel skipToNextFrame];
    }
    
    if(frameToPlay == nil){
        frameToPlay = _currentFrame;
    }
    
    // Play a pluck noise immediately
    NSNote * hit;
    
    hit = [frameToPlay testKey:[g_keysMath getForcedKeyBaseKey:key]];
    
    // Play the note.
    //if ( _difficulty == PlayViewControllerDifficultyHard )
    //{
    //    [self pressKey:key andVelocity:velocity andDuration:hit.m_duration];
    //}
    if ( hit != nil )
    {
        [self pressKey:[g_keysMath getForcedKeyBaseKey:key] andVelocity:KeysMaxPressVelocity andDuration:hit.m_duration];
        [self lightKeyOnUserPlay:[g_keysMath getForcedKeyBaseKey:key]];
    }
    
    if(isStandalone && hit != nil){
        
        //
        // Standalone Song Recorder
        //
        
        [_songRecorder pressKey:[g_keysMath getForcedKeyBaseKey:key]];
        
    }else{
        
        //
        // The rest of the handling is deferred till later.
        //
        
        // If this is called from the midi thread, there won't be an autorelease pool in place.
        // I'll handle all the alloc's manually just in case.
        //NSNumber * fretNumber = [[NSNumber alloc] initWithChar:fret];
        NSNumber * keyNumber = [[NSNumber alloc] initWithChar:key];
        NSNumber * velNumber = [[NSNumber alloc] initWithChar:velocity];
        
        NSDate * when = [[NSDate alloc] initWithTimeIntervalSinceNow:NOTE_DEFERMENT_TIME];
        
        NSMutableDictionary * dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            keyNumber, @"Key",
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
        
    }
}

- (void)keysNoteOff:(KeyPosition)position
{
    
    // Always mute notes on note-off for hard
    [g_soundMaster NoteOffForKey:position];
    
    @synchronized ( _deferredNotesQueue )
    {
        NSDictionary * canceledPluck = nil;
        
        for ( NSDictionary * pluck in _deferredNotesQueue )
        {
            NSNumber * keyNumber = [pluck objectForKey:@"Key"];
            
            KeyPosition key = [keyNumber charValue];
            
            // If this is a cancelation, kill this timer.
            // Break out of the loop because the for(...) doesn't like
            // the array object mutating under it.
            if ( key == position)
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
    DLog(@"Standalone ready");
    
    // Stop ourselves before we start so the connecting screen can display
    [self stopMainEventLoop];
    [self drawPlayButton:_pauseButton];
    
    if(!isPracticeMode){
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLicenseScroll) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(startWithSongXmlDom) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(revealPlayView) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeLoadingView) userInfo:nil repeats:NO];
    }
}

- (void)keysRangeChange:(KeysRange)range
{
    NSDictionary * songRange = [_displayController getNoteRangeForSong];
    
    int songMinKey = [[songRange objectForKey:@"Min"] intValue];
    int songMaxKey = [[songRange objectForKey:@"Max"] intValue];
    
    DLog(@"Keys range change to %i, %i, with songMin=%i, songMax=%i",range.keyMin,range.keyMax,songMinKey,songMaxKey);
    
    /*UIAlertView * _alertView = [[UIAlertView alloc] initWithTitle:@"Keys Range Change"
                                                          message:[NSString stringWithFormat:@"min=%i | max=%i",range.keyMin,range.keyMax]
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [_alertView show];*/
    
    
    [g_keysMath setSongRangeFromMin:MIN(songMinKey,range.keyMin) andMax:MAX(songMaxKey,range.keyMax)];
    
    [self refreshKeyboardToKeyMin:NO];
    
    _refreshDisplay = YES;
}

- (void)keysConnected
{
    // Standalone -> Normal
    DLog(@"SongViewController: gTar has been connected");
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    // Only disconnect if mid-song
    if(isStandalone){
        
        [g_soundMaster stop];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }else{
        
        [g_keysController setMinimumInterarrivalTime:0.10f];
        
        if(!isPracticeMode){
            [self startWithSongXmlDom];
        }
        
        // Stop ourselves before we start so the connecting screen can display
        [self stopMainEventLoop];
        [g_soundMaster stop];
        [self drawPlayButton:_pauseButton];
        
        if(!isPracticeMode){
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startLicenseScroll) userInfo:nil repeats:NO];
            [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(revealPlayView) userInfo:nil repeats:NO];
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeLoadingView) userInfo:nil repeats:NO];
        }
        
    }
    
    [g_soundMaster routeToDefault];
    
}

- (void)keysDisconnected
{
    
    // Normal -> Standalone
    DLog(@"SongViewController: gTar has been disconnected");
    
    //    [self backButtonClicked:nil];
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Play disconnected" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                                     [NSNumber numberWithInteger:_userSong.m_songId], @"SongId",
                                                     _userSong.m_title, @"Title",
                                                     [NSNumber numberWithInteger:_difficulty], @"Difficulty",
                                                     [NSNumber numberWithInteger:(_songModel.m_percentageComplete*100)], @"Percent",
                                                     nil]];
    
    [mixpanel.people increment:@"PlayTime" by:[NSNumber numberWithInteger:delta]];
    
    [g_soundMaster stop];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Gameplay related helpers
- (void)initSongModel
{
    if(g_keysController.connected){
        [g_keysController turnOffAllLeds];
    }
    [_displayController cancelPreloading];
    
    _currentFrame = nil;
    _lastTappedFrame = nil;
    _songModel = nil;
    
    //
    // Start off the song stuff
    //
    _songModel = [[NSSongModel alloc] initWithSong:_song];
    
    // Very small frame window
    _songModel.m_frameWidthBeats = SONG_MODEL_NOTE_FRAME_WIDTH;
    
    _deferredNotesQueue = [[NSMutableArray alloc] init];
    
}


- (void)initSongRecorder
{
    //
    // Init recorder
    //
    
    _songRecorder = [[KeysSongRecorder alloc] initWithTempo:_song.m_tempo];
    
    [_songRecorder beginSong];
}

- (void)initSongDisplayWithLoops:(int)loops
{
    //
    // Init score with difficulty
    //
    
    switch ( _difficulty )
    {
            
        case PlayViewControllerDifficultyEasy:
        {
            _scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:10 isPracticeMode:isPracticeMode numLoops:loops];
        } break;
            
        default:
        case PlayViewControllerDifficultyMedium:
        {
            _scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:20 isPracticeMode:isPracticeMode numLoops:loops];
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            _scoreTracker = [[NSScoreTracker alloc] initWithBaseScore:40 isPracticeMode:isPracticeMode numLoops:loops];
        } break;
            
    }
    
    //
    // Init display
    //
    _displayController = [[SongDisplayController alloc] initWithSong:_songModel andView:_glView isStandalone:isStandalone isSheetMusic:isSheetMusic setDifficulty:_difficulty andLoops:loops];
    
    // MIN and MAX have been set, refresh
    [self refreshKeyboardToKeyMin:YES];
    
    // An initial display render
    [_displayController renderImage];
    
    [self updateProgressDisplay];
    
    _animateSongScrolling = YES;
}

- (void)updateMenuLabelsForSongStart
{
    
    // Update the menu labels
    [_songTitleLabel setText:_userSong.m_title];
    [_scoreSongTitleLabel setText:_userSong.m_title];
    [_practiceSongTitleLabel setText:_userSong.m_title];
    [_songArtistLabel setText:_userSong.m_author];
    [_scoreSongArtistLabel setText:_userSong.m_author];
    [_practiceSongArtistLabel setText:_userSong.m_author];
    [_finishPracticeButton setHidden:YES];
    [_finishButton setHidden:YES];
    [_finishRestartButton setHidden:YES];
    [_outputView setHidden:NO];
    [_backButton setEnabled:YES];
    
}

// This is the song init for practice mode standalone/regular
- (void)startWithSongXmlDomPracticeFrom:(double)start toEnd:(double)end withLoops:(int)loops andTempoPercent:(double)tempoPercent
{
    
    m_loopStart = start;
    m_loopEnd = end;
    m_loops = loops;
    lastMetronomeBeat = -2;
    
    [self initSongModel]; // reinit
    [self updateMenuLabelsForSongStart];
    
    // Give a little runway to the player
    [_songModel startWithDelegate:self andBeatOffset:-4 fastForward:YES isScrolling:(isScrolling || isStandalone) withTempoPercent:tempoPercent fromStart:start toEnd:end withLoops:loops];
    
    // Light up the first frame
    if(!isRestrictPlayFrame){
        [self turnOnFrame:_songModel.m_nextFrame];
    }
    
    [self initSongRecorder];
    
    [self initSongDisplayWithLoops:loops];
    
    if(!_practiceViewOpen){
        [self startEventLoop];
    }
    
    [self updateScoreDisplayWithAccuracy:-1];
    
}

// This is the normal song init for standalone/regular
- (void)startWithSongXmlDom
{
    
    m_loopStart = 0;
    m_loopEnd = 1.0;
    m_loops = 0;
    lastMetronomeBeat = -2;
    
    [self initSongModel]; // reinit
    [self updateMenuLabelsForSongStart];
    
    // Give a little runway to the player
    [_songModel startWithDelegate:self andBeatOffset:-4 fastForward:YES isScrolling:(isScrolling || isStandalone) withTempoPercent:1.0 fromStart:0 toEnd:-1 withLoops:0];
    
    // Light up the first frame
    //if(g_keysController.connected == YES){
    [self turnOnFrame:_songModel.m_nextFrame];
    //}
    
    [self initSongRecorder];
    
    [self initSongDisplayWithLoops:0];
    
    if(!_practiceViewOpen){
        [self startEventLoop];
    }
    
    [self updateScoreDisplayWithAccuracy:-1];
    
}

- (void)pauseSong
{
    [self menuButtonClicked:nil];
}

- (void)interFrameDelayExpired
{
    
    //    DLog(@"Ending chord");
    
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
    
    NSNumber * keyNumber = [pluck objectForKey:@"Key"];
    NSNumber * velNumber = [pluck objectForKey:@"Velocity"];
    
    KeyPosition key = [keyNumber charValue];
    KeysPressVelocity velocity = [velNumber charValue];
    
    @synchronized ( _deferredNotesQueue )
    {
        [_deferredNotesQueue removeObject:pluck];
    }
    
    _refreshDisplay = YES;
    
    NSNote * hit;
    
    hit = [_currentFrame hitTestAndRemoveKey:[g_keysMath getForcedKeyBaseKey:key]];
    
    // Handle the hit
    if ( hit != nil )
    {
        [self correctHitKey:[g_keysMath getForcedKeyBaseKey:key] andVelocity:velocity];
    }
    else if(![g_keysMath noteOutOfRange:[g_keysMath getForcedKeyBaseKey:key]])
    {
        [self incorrectHitKey:[g_keysMath getForcedKeyBaseKey:key] andVelocity:velocity];
    }
    
}

// These functions need to be called from the main thread RunLoop.
// If they are called from a MIDI interrupt thread, stuff won't work properly.
- (void)correctHitKey:(KeyPosition)key andVelocity:(KeysPressVelocity)velocity
{
    
    // set it to the correct attenuation
    if ( _interFrameDelayTimer == nil )
    {
        // Record the note
        [_songRecorder pressKey:key];
    }
    
    [self turnOffKey:key];
    
    //
    // Frame ended
    //
    if([_currentFrame.m_notesPending count] == 0){
        
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
        
        return;
        
    }else if (_autocomplete || _difficulty == PlayViewControllerDifficultyEasy){

        //
        // Autocomplete chords
        //
        
        // If there is already a timer pending, we don't need to create another one
        if ( _interFrameDelayTimer == nil )
        {
            if(_delayedChords == nil){
                _delayedChords = [[NSMutableArray alloc] init];
            }
            
            // Figure out what notes we will be playing
            for ( NSNote * note in _currentFrame.m_notesPending )
            {
                [_delayedChords addObject:note];
            }
            
            for(int i = 0; i < [_currentFrame.m_notesPending count]; i++){
                NSNote * note = [_currentFrame.m_notesPending objectAtIndex:i];
                
                [_delayedChords addObject:note];
            }
            
            // We don't want to play notes that are already queues up.
            @synchronized ( _deferredNotesQueue )
            {
                //for ( NSDictionary * hit in _deferredNotesQueue )
                //{
                
                for(int i = 0; i < [_deferredNotesQueue count]; i++){
                    NSDictionary * hit = [_deferredNotesQueue objectAtIndex:i];
                    
                    
                    NSNumber * keyNumber = [hit objectForKey:@"Key"];
                    
                    KeyPosition key = [keyNumber charValue];
                    
                    // This one is queued up, so don't play it
                    // for(NSNote * note in _delayedChords){
                    for(int j = 0; j < [_delayedChords count]; j++){
                        NSNote * note = [_delayedChords objectAtIndex:j];
                        
                        if(key == note.m_key){
                            [_delayedChords removeObject:note];
                        }
                        
                    }
                    // }
                    
                }
                //}
                
            }
            
            _previousChordPlayKey = key;
            _previousChordPlayVelocity = velocity;
            _previousChordPlayDirection = 0;
            
            // Play a chord right now
            [self handleDelayedChord];
            
        }
    }
    
    if(_interFrameDelayTimer == nil){
        
        // Schedule an event to push us to the next frame after a moment
        // if another note doesn't come in.
        _interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_GRACE_PERIOD target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
    }
    
}

- (void)incorrectHitKey:(KeyPosition)key andVelocity:(KeysPressVelocity)velocity
{
    
    // See if we are trying to play a new chord
    if ( _interFrameDelayTimer != nil )
    {
        //[self handleDirectionChange:str];
    }
    
    if ( _difficulty == PlayViewControllerDifficultyHard )
    {
        // Play the note at normal intensity
        //        [self pluckString:str andFret:fret andVelocity:velocity];
        [g_soundMaster NoteOnForKey:key withDuration:(KEYS_DEFAULT_NOTE_DURATION/4.0)];
        
        // Record the note
        [_songRecorder pressKey:key];
        
    }
    
    [self lightKeyOnPlay:key isIncorrect:YES isMissed:NO];
    [self lightKeyOnUserPlay:key];
    
}

/*
- (void)handleDirectionChange:(KeysString)str
{
    
    // Check for direction changes
    NSInteger stringDelta = str - _previousChordPluckString;
    
    _previousChordPluckString = str;
    
    // The same string was plucked twice, change in direction
    if ( stringDelta == 0 )
    {
        //        DLog(@"Same note in a row");
        [self interFrameDelayExpired];
    }
    
    // We are going 'down'
    if ( stringDelta > 0 )
    {
        // We were going 'up'
        if ( _previousChordPluckDirection < 0 )
        {
            //            DLog(@"Changed direction: up->down");
            [self interFrameDelayExpired];
        }
        else
        {
            // Save the direction and reset the timer
            //            DLog(@"Going down, reup the timer");
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
            //            DLog(@"Changed direction: down->up");
            [self interFrameDelayExpired];
        }
        else
        {
            // Save the direction and reset the timer
            //            DLog(@"Going up, reup the timer");
            _previousChordPluckDirection = -1;
            [_interFrameDelayTimer invalidate];
            _interFrameDelayTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_GRACE_PERIOD target:self selector:@selector(interFrameDelayExpired) userInfo:nil repeats:NO];
        }
    }
    
}
 */

- (void)handleDelayedChord
{

    [_delayedChordTimer invalidate];
    _delayedChordTimer = nil;
    
    if ( [_delayedChords count] <= 0 )
    {
        return;
    }
    
    //KeyPosition maxKey = _delayedChordMax;
    
    //_delayedChordsCount--;
    
    NSNote * note = [_delayedChords firstObject];
    KeyPosition key = note.m_key;
    
    [_delayedChords removeObject:[_delayedChords firstObject]];
    
    if ( [_delayedChords count] > 0 )
    {
        _delayedChordTimer = [NSTimer scheduledTimerWithTimeInterval:CHORD_DELAY_TIMER target:self selector:@selector(handleDelayedChord) userInfo:nil repeats:NO];
    }
    
    if ( [g_keysMath getForcedRangeKey:key] >= [g_keysMath getForcedRangeKeyMin] && key <= [g_keysMath getForcedRangeKeyMax] )
    {
        
        // Play the note
        if ( _difficulty == PlayViewControllerDifficultyHard )
        {
            [self pressKey:key andVelocity:_previousChordPlayVelocity andDuration:note.m_duration];
            [self lightKeyOnUserPlay:key];
        }
        else
        {
            [self pressKey:key andVelocity:KeysMaxPressVelocity andDuration:note.m_duration];
            //[self lightKeyOnUserPlay:key];
        }
        
        // Record the note
        [_songRecorder pressKey:key];
    }
    
}

- (void)turnOnFrame:(NSNoteFrame*)frame
{
    
    for ( NSNote * note in frame.m_notes )
    {
        [self turnOnKey:note.m_key];
    }
    
}

- (void)turnOffFrame:(NSNoteFrame*)frame
{
    
    for ( NSNote * note in frame.m_notes )
    {
        [self turnOffKey:note.m_key];
    }
    
}

- (void)turnOnKey:(KeyPosition)key
{
    if(g_keysController.connected){
        
        if ( key == KEYS_KEY_MUTED )
        {
            [g_keysController turnOnLedAtPositionWithColorMap:key];
        }
        else
        {
            [g_keysController turnOnLedAtPositionWithColorMap:key];
        }
        
    }
}

- (void)turnOffKey:(KeyPosition)key
{
    if(g_keysController.connected){
        
        [g_keysController turnOffLedAtPosition:key];
        
    }
    
}

- (void)pressKey:(KeyPosition)key andVelocity:(KeysPressVelocity)velocity andDuration:(double)duration
{

    if ( key == KEYS_KEY_MUTED )
    {
        DLog(@"Play View Controller Pluck Muted String");
        [g_soundMaster playMutedKey:key];
        [self lightKeyOnPlay:key isIncorrect:YES isMissed:NO];
    }
    else
    {
        DLog(@"Play View Controller Pluck String");
        [g_soundMaster playKey:key withDuration:duration];
        [self lightKeyOnPlay:key isIncorrect:NO isMissed:NO];
    }
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame
{
   // DLog(@"Song model enter frame");
    
    _currentFrame = frame;
    
    // Align us more pefectly with the frame
    if(!isScrolling){
        [_songModel incrementBeatSerialAccess:(frame.m_absoluteBeatStart - _songModel.m_currentBeat) isRestrictFrame:NO];
    }
    
    // If restricted play frame then turn on frame
    if(isRestrictPlayFrame){
        [self turnOnFrame:_currentFrame];
    }
    
    _refreshDisplay = YES;
    
    if(isScrolling){
        _animateSongScrolling = YES;
    }else{
        _animateSongScrolling = NO;
    }
    
    // Check for keyboard range change to update camera and position
    DLog(@"Range diff is %i vs %i",[g_keysController range].keyMax-[g_keysController range].keyMin,KEYS_DISPLAYED_NOTES_COUNT);
    
    if(!isStandalone && ([g_keysController range].keyMax-[g_keysController range].keyMin) > KEYS_DISPLAYED_NOTES_COUNT){
        [self checkHorizonForCameraPosition:NO];
    }

}

- (void)songModelExitFrame:(NSNoteFrame*)frame
{
    // DLog(@"Song model exit frame");
    
    // Miss all the remaining notes
    
    for(NSNote * n in frame.m_notesPending){
        
        if(!isStandalone && ((_difficulty != PlayViewControllerDifficultyEasy && !_autocomplete) || [frame.m_notesHit count] == 0)){
            [self lightKeyOnPlay:n.m_key isIncorrect:NO isMissed:YES];
        }else if(isStandalone){
            [self showMissedKey:n];
        }
        
        [_displayController missNote:n];
        
    }
    
    if(isRestrictPlayFrame){
        [self turnOffFrame:_currentFrame];
    }
    
    _currentFrame = nil;
    
    if(!isStandalone && frame != nil){
        // Calculate score only on frame release for regular play
        double accuracy = [_scoreTracker scoreFrame:frame onBeat:-1 withComplexity:0 endStreak:NO isStandalone:NO forLoop:MIN([_songModel getCurrentLoop],m_loops)];
        [self updateScoreDisplayWithAccuracy:accuracy];
    }
    
    // Score checking on frame release
    if(frame != nil){
        [_scoreTracker scoreEndOfFrame:frame percentageComplete:_songModel.m_percentageComplete];
    }
    
    // turn off any lights that might have been skipped
    [self turnOffFrame:frame];
    
    // turn on the next frame
    if(!isRestrictPlayFrame){
        [self turnOnFrame:_nextFrame];
    }
    
    [self disableInput];
    
    _refreshDisplay = YES;
    
    _animateSongScrolling = YES;
    
}

- (void)songModelNextFrame:(NSNoteFrame*)frame
{
    // Light up in advance
    if(isScrolling && !isRestrictPlayFrame){
        [self turnOffFrame:_nextFrame];
        [self turnOnFrame:frame];
    }
    
    _nextFrame = frame;
    
}

- (void)songModelFrameExpired:(NSNoteFrame*)frame
{
    
    if ( _difficulty == PlayViewControllerDifficultyEasy )
    {
        // On easy mode, we play the notes that haven't been hit yet
        for ( NSNote * note in frame.m_notesPending )
        {
            [self pressKey:note.m_key andVelocity:KeysMaxPressVelocity andDuration:note.m_duration];
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

// Accuracy heat map
- (void)drawHeatMap
{
    
    NSMutableArray * tempFrameHits = [[NSMutableArray alloc] init];
    NSMutableArray * frameHits = [[NSMutableArray alloc] init];
    
    double runningAccuracy[4];
    
    for (int f = 0; f < [_songModel.m_noteFrames count]; f++)
    {
        
        double accuracy;
        NSNoteFrame * frame = [_songModel.m_noteFrames objectAtIndex:f];
        
        if(isStandalone){
            accuracy = [_displayController getNoteHit:[frame.m_notes firstObject]];
        }else{
            accuracy = (double)[frame.m_notesHit count] / (double)([frame.m_notesHit count]+[frame.m_notesPending count]+frame.m_notesWrong);
        }
        
        // build average
        if(f==0){
            for(int r=0; r < 4; r++){
                runningAccuracy[r] = accuracy;
            }
        }else{
            runningAccuracy[0] = runningAccuracy[1];
            runningAccuracy[1] = runningAccuracy[2];
            runningAccuracy[2] = runningAccuracy[3];
            runningAccuracy[3] = accuracy;
        }
        
        // calculate average
        double avgaccuracy = 0;
        for(int r=0;r<4;r++){
            avgaccuracy+=runningAccuracy[r];
        }
        avgaccuracy/=4.0;
        
        [tempFrameHits addObject:[NSNumber numberWithDouble:avgaccuracy]];
        
    }
    
    double numSlices = [tempFrameHits count];
    
    DLog(@"TempFrameHits is %@ for %i frames",tempFrameHits,[tempFrameHits count]);
    
    // Aggregate frame hits
    if(isPracticeMode){
        
        int framesPerSlice = numSlices/(m_loops+1);
        
        for(int i = 0; i < framesPerSlice; i++){
            
            double sliceAccuracy = 0;
            
            for(int j = 0; j < m_loops+1; j++){
                if((i*j+i) < [tempFrameHits count]){
                    sliceAccuracy += [[tempFrameHits objectAtIndex:(i*j+i)] doubleValue];
                }
            }
            
            sliceAccuracy /= (m_loops+1);
            
            [frameHits addObject:[NSNumber numberWithDouble:sliceAccuracy]];
            
        }
    }else{
        frameHits = tempFrameHits;
    }
    
    DLog(@"FrameHits is %@ for %i frames",frameHits,[frameHits count]);
    
    // Draw
    CGSize size = CGSizeMake(_heatMapView.frame.size.width,_heatMapView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double sliceWidth = _heatMapView.frame.size.width * (m_loopEnd - m_loopStart) / [frameHits count];
    
    double slicesToFill = _heatMapView.frame.size.width / sliceWidth;
    double slicesToPrefill = slicesToFill * m_loopStart;
    
    //DLog(@"SliceWidth is %f from %f to %f for %i slices",sliceWidth, m_loopStart,m_loopEnd,[frameHits count]);
    
    for(int f = 0; f < slicesToPrefill; f++){
        
        double trimmedSliceWidth = sliceWidth+0.25;
        UIColor * accuracyColor = [UIColor blackColor];
        
        CGRect sliceRect = CGRectMake(sliceWidth*f,0,trimmedSliceWidth,_heatMapView.frame.size.height);
        
        CGContextAddRect(context,sliceRect);
        CGContextSetFillColorWithColor(context, accuracyColor.CGColor);
        CGContextFillRect(context, sliceRect);
    }
    
    for(int f = slicesToPrefill, g = 0; f < slicesToFill; f++){
        
        // Calculate accuracy color
        double accuracy = 0;
        UIColor * accuracyColor = [UIColor blackColor];
        
        double trimmedSliceWidth = sliceWidth+0.25;
        double trimmedSliceExtra = 0;
        
        //if((double)f/(double)numSlices >= m_loopStart && (double)f/(double)numSlices < m_loopEnd){
        
        if(g < [frameHits count]){
            accuracy = [[frameHits objectAtIndex:g] doubleValue];
            
            if(accuracy < 0.5){
                accuracyColor = [UIColor colorWithRed:1.0 green:((2.0*accuracy)*115.0+65.0)/255.0 blue:50/255.0 alpha:0.9];
            }else{
                accuracyColor = [UIColor colorWithRed:2.0*(1.0-accuracy)*255.0/255.0 green:180/255.0 blue:50/255.0 alpha:0.9];
            }
            
        }else{
            accuracyColor = [UIColor blackColor];
        }
        
        g++;
        
        // Ensure that wide frames don't go over the expected area
        //if(m_loopEnd < 1 && sliceWidth*f+sliceWidth+0.25 > _heatMapView.frame.size.width * m_loopEnd){
        //trimmedSliceWidth = _heatMapView.frame.size.width * m_loopEnd - sliceWidth*f;
        //trimmedSliceExtra = sliceWidth+0.25 - trimmedSliceWidth;
        //}
        
        //}
        
        CGRect sliceRect = CGRectMake(sliceWidth*f,0,trimmedSliceWidth,_heatMapView.frame.size.height);
        
        CGContextAddRect(context,sliceRect);
        CGContextSetFillColorWithColor(context, accuracyColor.CGColor);
        CGContextFillRect(context, sliceRect);
        
        // Add in extra filler if area gets cropped
        /*if(trimmedSliceExtra > 0){
         
         CGRect sliceExtraRect = CGRectMake(sliceWidth*f+trimmedSliceWidth,0,trimmedSliceExtra,_heatMapView.frame.size.height);
         
         CGContextAddRect(context,sliceExtraRect);
         CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
         CGContextFillRect(context, sliceExtraRect);
         }*/
        
    }
    
    UIImage * rectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:rectImage];
    UIImageView * practiceImage = [[UIImageView alloc] initWithImage:rectImage];
    
    // First clear subviews for heat map view
    for(UIView * v in [_heatMapView subviews]){
        [v removeFromSuperview];
    }
    
    // Add new subviews
    [_heatMapView addSubview:image];
    [self setPracticeHeatMapViewImageView:practiceImage];
    
    UIGraphicsEndImageContext();
    
}

- (void)songModelEndOfSong
{
    
    [self stopMainEventLoop];
    [self drawPlayButton:_pauseButton];
    
    [self endSong];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [_playTimeStart timeIntervalSince1970] + _playTimeAdjustment;
    
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
    
    // If our queue is full, don't let them upload more songs
    //if ( [g_userController isUserSongSessionQueueFull] == YES )
    //{
    //   [_feedSwitch setOn:NO];
    //}
    
}

- (void)endSong
{
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSDictionary * scoreData = [_scoreTracker aggregateScoreEndOfSong];
    
    long numsessions = [[scoreData objectForKey:@"NumSessions"] longValue];
    //double totalscore = [[scoreData objectForKey:@"TotalScore"] doubleValue];
    double bestscore = [[scoreData objectForKey:@"BestScore"] doubleValue];
    double perfectscore = [[scoreData objectForKey:@"PerfectScore"] doubleValue];
    double score = [[scoreData objectForKey:@"Score"] doubleValue];
    double percentNotesHit = 100*[[scoreData objectForKey:@"PercentNotesHit"] doubleValue];
    double maxStreak = [[scoreData objectForKey:@"MaxStreak"] doubleValue];
    double accuracy = 100*[[scoreData objectForKey:@"AverageTiming"] doubleValue];
    
    [_scoreBestSession setHidden:!isPracticeMode];
    [_scoreBestSessionStar setHidden:!isPracticeMode];
    [_scoreBestSessionLabel setHidden:!isPracticeMode];
    [_scoreTotal setHidden:!isPracticeMode];
    [_scoreTotalLabel setHidden:!isPracticeMode];
    
    if(isPracticeMode){
        
        _scoreBestSession.text = [NSString stringWithFormat:@"%i",(int)[_scoreTracker getStarsForRatio:(bestscore/perfectscore) percentageComplete:_songModel.m_percentageComplete]]; //[self formatScore:(int)bestscore];
        _scoreTotal.text = [NSString stringWithFormat:@"%li",numsessions];//[self formatScore:(int)totalscore];
        
    }
    
    [self displayStars:[_scoreTracker getStarsForRatio:(score/perfectscore) percentageComplete:_songModel.m_percentageComplete] isFinal:YES];
    
    _scoreNotesHit.text = [NSString stringWithFormat:@"%i%%",(int)percentNotesHit];
    _scoreInARow.text = [NSString stringWithFormat:@"%i",(int)maxStreak];
    _scoreAccuracy.text = [NSString stringWithFormat:@"%i%%",(int)accuracy];
    
    // Build the heat map
    [self drawHeatMap];
    
    // Turn of the LEDs
    if(g_keysController.connected){
        [g_keysController turnOffAllLeds];
    }
    
    [_songRecorder finishSong];
    
    // Show final screen
    [_finishPracticeButton setHidden:NO];
    [_finishButton setHidden:NO];
    [_finishRestartButton setHidden:NO];
    [_backButton setEnabled:NO];
    
    _songModel = nil;
    
    if(_menuIsOpen){
        [self menuButtonClicked:nil];
    }
    
    [self songScoreButtonClicked:nil];
    
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
    if(isStandalone && !_songIsPaused){
        if(activeTouchPoints == nil){
           activeTouchPoints = [[NSMutableArray alloc] init];
            
            [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(tapNoteFromTouchPoint) userInfo:nil repeats:NO];
            
        }
        
        // Gather all the touches to send with a timer
        for(UITouch * touch in [event allTouches]){
            CGPoint touchPoint = [touch locationInView:self.glView];
        
            [activeTouchPoints addObject:[NSValue valueWithCGPoint:touchPoint]];
        }
        
        //[self tapNoteFromTouchPoint:touchPoints];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Only allow the bar to move if the range isn't auto-changing
    if(!isStandalone && ([g_keysController range].keyMax-[g_keysController range].keyMin) <= KEYS_DISPLAYED_NOTES_COUNT){
        
        UITouch * touch = [[touches allObjects] objectAtIndex:0];
        CGPoint currentPoint = [touch locationInView:self.view];
        CGPoint previousPoint = [touch previousLocationInView:self.view];
        CGPoint positionPoint = [touch locationInView:keyboardPosition];
        
        // Detect moving the Keyboard Position Bar
        if(positionPoint.x >= 0 && positionPoint.x <= keyboardPosition.frame.size.width && positionPoint.y >= -10.0){
            
            CGFloat deltaX = currentPoint.x - previousPoint.x;
            
            if(keyboardPosition.frame.origin.x+deltaX < 0){
                deltaX = -keyboardPosition.frame.origin.x;
            }else if(keyboardPosition.frame.origin.x+keyboardPosition.frame.size.width+deltaX > keyboardRange.frame.size.width){
                deltaX = keyboardRange.frame.size.width-(keyboardPosition.frame.origin.x+keyboardPosition.frame.size.width);
            }
            
            // Shift keyboard position bar
            [keyboardPosition setFrame:CGRectMake(keyboardPosition.frame.origin.x+deltaX, keyboardPosition.frame.origin.y, keyboardPosition.frame.size.width, keyboardPosition.frame.size.height)];
            
            // Shift view to a new white key
            int newWhiteKey = (keyboardPosition.frame.origin.x / (keyboardRange.frame.size.width-keyboardPosition.frame.size.width))*([g_keysMath getForcedRangeWhiteKeyCount]-ceil([g_keysMath cameraScale]*KEYS_WHITE_KEY_DISPLAY_COUNT)) + [g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]];
            
            int newKey = [g_keysMath getNthKeyForWhiteKey:newWhiteKey];
            
            DLog(@"New white key is %i , Nth key is %i",newWhiteKey,newKey);
            
            //DLog(@"New starting key is %i",newKey);
            
            [self drawKeyboardGridFromMin:newKey];
            [_displayController shiftViewToKey:newKey];
            g_keysMath.keyboardPositionKey = newKey;
            
            _refreshDisplay = YES;
        }
     
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    // Release key touches
    for(UITouch * touch in touches){
        CGPoint touchPoint = [touch locationInView:self.glView];
        
        [self releaseKeyFromTap:touchPoint];
    }
    
    
    // Only allow the bar to move if the range isn't auto-changing
    if(([g_keysController range].keyMax-[g_keysController range].keyMin) <= KEYS_DISPLAYED_NOTES_COUNT){
        
        float margin = 1.0;
        
        int newWhiteKey = ((keyboardPosition.frame.origin.x+margin) / (keyboardRange.frame.size.width-keyboardPosition.frame.size.width))*([g_keysMath getForcedRangeWhiteKeyCount]-ceil([g_keysMath cameraScale]*KEYS_WHITE_KEY_DISPLAY_COUNT)) + [g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]];
        
        // Snap to key
        float whiteKeyWidth = keyboardRange.frame.size.width / [g_keysMath getForcedRangeWhiteKeyCount];
        
        DLog(@"White key width is %f * %i",whiteKeyWidth,(newWhiteKey-[g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]]));
        
        [keyboardPosition setFrame:CGRectMake((newWhiteKey-[g_keysMath getWhiteKeyFromNthKey:[g_keysMath getForcedRangeKeyMin]]) * whiteKeyWidth, keyboardPosition.frame.origin.y, keyboardPosition.frame.size.width, keyboardPosition.frame.size.height)];
        
    }
    
    if(!isStandalone){
        
        // Debug
//#ifdef Debug_BUILD
        if(g_keysController.connected){
            _skipNotes = YES;
        }
//#endif
    
    }
    
}

#pragma mark - Standalone logic
// Standalone
- (void)showMissedKey:(NSNote *)note
{
    float keyPosition = [g_keysMath convertKeyToCoordSpace:note.m_key];
    float keyWidth = 20.0;
 
    for(UIView * view in selectedKeyboard.subviews){
        
        if(keyPosition-keyWidth > view.frame.origin.x && keyPosition+keyWidth < view.frame.origin.x+view.frame.size.width){
        
            [self colorKeyOnTap:view withAccuracy:-1];
            
        }
        
    }
    
}

- (void)releaseKeyFromTap:(CGPoint)tap
{
    
    for(UIView * view in selectedKeyboard.subviews){
        
        if(tap.x > view.frame.origin.x && tap.x < view.frame.origin.x+view.frame.size.width){
            
            [self uncolorKey:view];
            
        }
        
    }
}

- (void)tapNoteFromTouchPoint
{
    NSMutableArray * touchPoints = [[NSMutableArray alloc] initWithArray:activeTouchPoints copyItems:YES];
    
    NSMutableDictionary * frameWithKey = [_displayController getKeyPressFromTap:touchPoints];
    
    double accuracy = -1;
    
    if(frameWithKey != nil){
        
        // @"Key" is now an array of all tapped keys
        // Since it autocompletes
        NSMutableArray * keysHit = [frameWithKey objectForKey:@"Key"];
        
        int tappedKey = [[keysHit firstObject] intValue];
        NSNoteFrame * tappedFrame = [frameWithKey objectForKey:@"Frame"];
        accuracy = [[frameWithKey objectForKey:@"Accuracy"] doubleValue];
        
        DLog(@"Play note for key? %i with accuracy %f",tappedKey,accuracy);
        
        [self playNoteForKey:tappedKey atFrame:tappedFrame withAccuracy:accuracy];
        
    }
    
    float screenTopBuffer = 46.0;
    
    // Get the UIViews that were hit
    for(NSValue * touchPointValue in touchPoints){
        
        CGPoint touchPoint = [touchPointValue CGPointValue];
        
        UIView * minHeightSubview;
        for(UIView * subview in selectedKeyboard.subviews){
            
            if(touchPoint.x > subview.frame.origin.x && touchPoint.x < subview.frame.origin.x+subview.frame.size.width){
                
                if(minHeightSubview == nil || subview.frame.size.height < minHeightSubview.frame.size.height){
                    minHeightSubview = subview;
                }
            }
            
        }

        [self colorKeyOnTap:minHeightSubview withAccuracy:accuracy];
    }
    
    [activeTouchPoints removeAllObjects];
    activeTouchPoints = nil;

}

- (void)colorKeyOnTap:(UIView *)key withAccuracy:(float)accuracy
{
    float hitCorrect = TOUCH_HIT_EASY_CORRECT;
    float hitNear = TOUCH_HIT_EASY_NEAR;
    float hitIncorrect = TOUCH_HIT_EASY_INCORRECT;
    
    if(_difficulty == PlayViewControllerDifficultyMedium){
        hitCorrect = TOUCH_HIT_MEDIUM_CORRECT;
        hitNear = TOUCH_HIT_MEDIUM_NEAR;
        hitIncorrect = TOUCH_HIT_MEDIUM_INCORRECT;
    }else if(_difficulty == PlayViewControllerDifficultyHard){
        hitCorrect = TOUCH_HIT_HARD_CORRECT;
        hitNear = TOUCH_HIT_HARD_NEAR;
        hitIncorrect = TOUCH_HIT_HARD_INCORRECT;
    }
    
    UIColor * uncolored = (key.tag == 0) ? [UIColor whiteColor] : [UIColor colorWithRed:53/255.0 green:194/255.0 blue:241/255.0 alpha:1.0];
    UIColor * accuracyColor = (key.tag == 0) ? [UIColor colorWithRed:185/255.0 green:212/255.0 blue:222/255.0 alpha:1.0] : [UIColor colorWithRed:154/255.0 green:184/255.0 blue:195/255.0 alpha:1.0];
    
    if(accuracy > hitCorrect){
        //accuracyColor = [UIColor colorWithRed:31/255.0 green:195/255.0 blue:72/266.0 alpha:1.0];
        accuracyColor = [UIColor colorWithRed:31/255.0 green:227/255.0 blue:84/266.0 alpha:1.0];
    }else if(accuracy > hitNear){
        //accuracyColor = [UIColor colorWithRed:238/255.0 green:188/255.0 blue:53/255.0 alpha:1.0];
        accuracyColor = [UIColor colorWithRed:255/255.0 green:235/255.0 blue:66/255.0 alpha:1.0];
    }else if(accuracy > hitIncorrect){
        //accuracyColor = [UIColor colorWithRed:239/255.0 green:92/255.0 blue:53/255.0 alpha:1.0];
        accuracyColor = [UIColor colorWithRed:255/255.0 green:113/255.0 blue:66/255.0 alpha:1.0];
    }
    
    [key setBackgroundColor:accuracyColor];
    
    if(accuracy <= hitIncorrect){
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(uncolorKeyTimeout:) userInfo:key repeats:NO];
    }else{
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(uncolorKeyTimeout:) userInfo:key repeats:NO];
    }
    
}

- (void)uncolorKeyTimeout:(NSTimer*)timer
{
    UIView * key = (UIView *)[timer userInfo];
    
    [self uncolorKey:key];
}

- (void)uncolorKey:(UIView *)key
{
    UIColor * uncolored = (key.tag == 0) ? [UIColor whiteColor] : [UIColor colorWithRed:53/255.0 green:194/255.0 blue:241/255.0 alpha:1.0];
    
    [key setBackgroundColor:uncolored];
}

// Standalone
- (void)playNoteForKey:(int)tappedKey atFrame:(NSNoteFrame *)tappedFrame withAccuracy:(double)accuracy;
{
    
    //[_displayController attemptFrame:tappedFrame];
    
    // Go through and play the notes if the string mapping is correct
    NSMutableArray * notesToRemove = [[NSMutableArray alloc] init];
    
    for(NSNote * n in tappedFrame.m_notesPending){
        
        if(n.m_key == tappedKey){
            
            @synchronized(tappedFrame.m_notesPending){
                // Autocompletes
                for(NSNote * nn in tappedFrame.m_notesPending){
                    
                    KeysPress press;
                    press.velocity = KeysMaxPressVelocity;
                    press.position = nn.m_key;
                    
                    DLog(@"Play key %i",nn.m_key);
                    
                    [_displayController hitNote:nn withAccuracy:accuracy];
                    
                    [self keysNoteOn:press forFrame:tappedFrame];
                    
                    [notesToRemove addObject:nn];
                    
                }
            }
            
            break;
        }
    }
    
    @synchronized(tappedFrame.m_notesPending){
        for(NSNote * nnn in notesToRemove){
            [tappedFrame removeKey:nnn.m_key];
        }
    }
    
    // Prepare data to score
    if([tappedFrame.m_notesHit count] > 0){
        
        // Count the number of frets on?
        
        // Check if the streak ends
        // Check everything between a frame hit and the last hit frame
        BOOL endStreak = NO;
        
        for(NSNoteFrame * ff in _songModel.m_noteFrames){
            if(ff.m_absoluteBeatStart < tappedFrame.m_absoluteBeatStart && [ff.m_notesPending count] > 0 && (!_lastTappedFrame || _lastTappedFrame.m_absoluteBeatStart < ff.m_absoluteBeatStart)){
                endStreak = YES;
            }else if(ff.m_absoluteBeatStart > _songModel.m_currentBeat + STANDALONE_SONG_BEATS_PER_SCREEN){
                break;
            }
        }
        
        double accuracy = [_scoreTracker scoreFrame:tappedFrame onBeat:_songModel.m_currentBeat withComplexity:1 endStreak:endStreak isStandalone:isStandalone forLoop:MIN([_songModel getLoopForBeat:tappedFrame.m_absoluteBeatStart],m_loops)];
        
        // Save the accuracy in note.m_hit
        //for(NSNote * nn in tappedFrame.m_notes){
        //    [_displayController setNoteHit:nn toValue:accuracy];
        //}
        
        [self updateScoreDisplayWithAccuracy:accuracy];
        
        _lastTappedFrame = tappedFrame;
        
    }
    
}

@end

