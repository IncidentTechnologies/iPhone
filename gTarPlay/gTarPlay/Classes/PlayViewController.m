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

#import "CloudController.h"
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>
#import "UserSongSession.h"
#import "UserSong.h"
#import <gTarAppCore/SongRecorder.h>
#import <gTarAppCore/NSSongCreator.h>
#import <gTarAppCore/NSSongModel.h>
#import <gTarAppCore/NSNote.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSNoteFrame.h>
#import <gTarAppCore/NSScoreTracker.h>
#import <gTarAppCore/NSMarker.h>

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

#define STANDALONE_SONG_BEATS_PER_SCREEN 3.0
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
    //SongDisplayController *_displayController;
    
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
    BOOL _songScoreIsOpen;
    BOOL _songIsPaused;
    BOOL _songUploadQueueFull;
    
    BOOL _postToFeed;
    
    // Standalone
    CGPoint initPoint;
    BOOL isScrolling;
    BOOL isStandalone;
    
    BOOL fretOneOn;
    BOOL fretTwoOn;
    BOOL fretThreeOn;
    
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster isStandalone:(BOOL)standalone practiceMode:(BOOL)practiceMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
        // Custom initialization
        _playTimeAdjustment = 0;
        
        _playTimeStart = [NSDate date];
        _audioRouteTimeStart = [NSDate date];
        _metronomeTimeStart = [NSDate date];
        
        isScrolling = standalone;
        isStandalone = standalone;
        isPracticeMode = practiceMode;
        
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
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect fullScreen = CGRectMake(0,0,screenBounds.size.height,screenBounds.size.width);
    
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
    
    _menuView.transform = CGAffineTransformMakeTranslation( 0, -self.view.frame.size.height );
    _songScoreView.transform = CGAffineTransformMakeTranslation( 0, -self.view.frame.size.height );
    
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
    
    // Fiddle with the switch images
    _outputSwitch.thumbTintColor = [UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0];
    _outputSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    _outputSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    _feedSwitch.thumbTintColor = [UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0];
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
    
    [self initPostToFeed];
    ;
    [self updateDifficultyDisplay];
    
    // The first time we load this up, parse the song
    _song = [[NSSong alloc] initWithXmlDom:_userSong.m_xmlDom];
    
    // Init song XML
    [self initSongModel];
    
    [self setPracticeMode];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setStandalone];
    
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
    if(g_gtarController.connected == NO){
        
        NSLog(@"GTAR DISCONNECTED USE STANDALONE");
        
        isStandalone = YES;
        [self standaloneReady];
        
        [_tempoButton setTitle:@"100%" forState:UIControlStateNormal];
    }else{
        
        NSLog(@"GTAR IS CONNECTED USE NORMAL");
        
        isStandalone = NO;
        
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

- (void) localizeViews {
    [_finishPracticeButton setTitle:NSLocalizedString(@"PRACTICE", NULL) forState:UIControlStateNormal];
    [_startPracticeButton setTitle:NSLocalizedString(@"PRACTICE", NULL) forState:UIControlStateNormal];
    [_practiceBackButton setTitle:NSLocalizedString(@"BACK", NULL) forState:UIControlStateNormal];
    [_finishButton setTitle:NSLocalizedString(@"SAVE & FINISH", NULL) forState:UIControlStateNormal];
    [_finishRestartButton setTitle:NSLocalizedString(@"PLAY", NULL) forState:UIControlStateNormal];
    
    _scoreScoreLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SCORE", NULL)];
    _scoreBestSessionLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"BEST SESSION", NULL)];
    _scoreTotalLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"TOTAL", NULL)];
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
    
    _multiplierTextLabel.layer.cornerRadius = _multiplierTextLabel.frame.size.width/2.0;
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
    
    _volumeViewController = [[VolumeViewController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster isInverse:YES];
    
    [_volumeViewController attachToSuperview:self.view withFrame:targetFrame];
    
    // Make sure the top bar stays on top
    //[self.view bringSubviewToFront:_topBar];
    
    [self performSelectorOnMainThread:@selector(delayedLoaded) withObject:nil waitUntilDone:NO];
    
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

- (void)viewDidDisappear:(BOOL)animated
{
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
    if(g_gtarController.connected){
        [g_gtarController turnOffAllLeds];
    }
    [g_gtarController removeObserver:self];
    
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
        
        
        [g_soundMaster start];
        [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
        [self drawPauseButton:_pauseButton];
        
    }
}

- (void)repeatButtonClicked:(id)sender
{
    int repeatLoops = [[_repeatButton.titleLabel.text stringByReplacingOccurrencesOfString:@"x" withString:@""] intValue];
    repeatLoops *= 2;
    repeatLoops %= 63;
    
    [_repeatButton setTitle:[NSString stringWithFormat:@"%ix",repeatLoops] forState:UIControlStateNormal];
}

- (void)tempoButtonClicked:(id)sender
{
    NSString *tempo = _tempoButton.titleLabel.text;
    NSString *newTempo;
    
    if([tempo isEqualToString:NSLocalizedString(@"NONE", NULL)] || [tempo isEqualToString:@"150%"]){
        newTempo = @"25%";
    }else if([tempo isEqualToString:@"25%"]){
        newTempo = @"50%";
    }else if([tempo isEqualToString:@"50%"]){
        newTempo = @"66%";
    }else if([tempo isEqualToString:@"66%"]){
        newTempo = @"75%";
    }else if([tempo isEqualToString:@"75%"]){
        newTempo = @"100%";
    }else if([tempo isEqualToString:@"100%"]){
        newTempo = @"125%";
    }else{
        if(isStandalone){
            newTempo = @"150%";
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
    _menuIsOpen = !_menuIsOpen;
    
    // Close the volume everytime we push the menu button
    [_volumeViewController closeView:YES];
    
    if ( _menuIsOpen == YES )
    {
        [_metronomeSwitch setOn:_playMetronome];
        [self showHideMenu:_menuView isOpen:YES];
        [_menuDownArrow setHidden:NO];
    }
    else
    {
        // Toggle Metronome?
        if(_metronomeSwitch.isOn != _playMetronome){
            [self toggleMetronome];
            [self startMetronomeIfOn];
            [self stopMetronomeIfOff];
        }
        
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
        
        [_metronomeSwitch setHidden:!isPracticeMode];
        [_menuMetronomeLabel setHidden:!isPracticeMode];
        
        [self stopMainEventLoop];
        [g_soundMaster stop];
        [self drawPlayButton:_pauseButton];
        _songIsPaused = YES;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        
        menu.transform = CGAffineTransformMakeTranslation(0,-46);
        
        [UIView commitAnimations];
        
    }else{
        
        if(!_practiceViewOpen){
            [g_soundMaster start];
            [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
            [self drawPauseButton:_pauseButton];
            _songIsPaused = NO;
        }
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(menuSlideComplete)];
        
        menu.transform = CGAffineTransformMakeTranslation( 0, -menu.frame.size.height );
        
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
            
            [g_soundMaster start];
            [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
            
            [self drawPauseButton:_pauseButton];
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

- (void)restartSong:(BOOL)resetPractice
{
    if(resetPractice){
        isPracticeMode = NO;
        [self setScrolling:isStandalone];
        [self setPracticeMode];
    }
    
    // Only upload at the end of a song
    if ( _finishButton.isHidden == NO && _postToFeed == YES )
    {
        [self uploadUserSongSession];
    }
    
    if(g_gtarController.connected == YES){
        [g_gtarController turnOffAllLeds];
    }
    [_displayController shiftView:0];
    
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
    if ( [g_userController isUserSongSessionQueueFull] == YES && _feedSwitch.isOn == YES )
    {
        [_feedSwitch setOn:NO];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Post"
                                                         message:@"The upload queue is full, cannot post songs until network connectivity restored."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
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
    
    double mapWidth = [[UIScreen mainScreen] bounds].size.height - 34;
    
    NSLog(@"MapWidth is %f",mapWidth);
    
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

- (void)initPostToFeed
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    _postToFeed = ![settings boolForKey:@"DisablePostToFeed"];
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
        [g_soundMaster start];
        [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
        [self drawPauseButton:_pauseButton];
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
    
    if(_playMetronome && isPracticeMode){
        
        [_metronomeTimer invalidate];
        _metronomeTimer = nil;
        
        _metronomeTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/_songModel.m_beatsPerSecond) target:self selector:@selector(playMetronomeTick) userInfo:nil repeats:YES];
        
        NSLog(@"Beat is %f",1.0/_songModel.m_beatsPerSecond);
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
    [self hideFrets];
    
    [_displayController updateDifficulty:_difficulty];
    
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
            
            if(isStandalone){
                [self showFrets];
            }
            
        } break;
            
        case PlayViewControllerDifficultyHard:
        {
            [_difficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            [_scoreDifficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            [_practiceDifficultyButton setImage:[UIImage imageNamed:@"DiffHardButton"] forState:UIControlStateNormal];
            _difficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            _scoreDifficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            _practiceDifficultyLabel.text = NSLocalizedString(@"Hard", NULL);
            
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

- (void)updateScoreDisplayWithAccuracy:(double)accuracy
{
    int prevScore = [[self unformatScore:_scoreLabel.text] intValue];
    int newScore = _scoreTracker.m_score;
    int scoreDiff = newScore - prevScore;
    
    // Determine accuracy color
    UIColor * accuracyColor;
    
    if(accuracy < 0){
        accuracyColor = [UIColor whiteColor];
    }
    if(accuracy < 0.5){
        accuracyColor = [UIColor colorWithRed:1.0 green:((2.0*accuracy)*115.0+65.0)/255.0 blue:50/255.0 alpha:0.9];
    }else{
        accuracyColor = [UIColor colorWithRed:2.0*(1.0-accuracy)*255.0/255.0 green:180/255.0 blue:50/255.0 alpha:0.9];
    }
    
    //[_scoreLabel setTextColor:accuracyColor];
    
    // Animate subscore
    if(scoreDiff > 0){
        [self animateSubscoreWithText:[NSString stringWithFormat:@"+%i",scoreDiff] andColor:accuracyColor];
    }
    
    // Update score label
    [_scoreLabel setText:[self formatScore:_scoreTracker.m_score]];
    [self setScoreMultiplier:_scoreTracker.m_multiplier];
    

}

- (void)animateSubscoreWithText:(NSString*)subscore andColor:(UIColor *)textColor
{
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
}

- (void)setScoreMultiplier:(int)multiplier
{
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
    CGFloat delta = _songModel.m_percentageComplete * _progressFillView.frame.size.width;
    
    [_progressFillView setHidden:NO];
    
    _progressFillView.layer.transform = CATransform3DMakeTranslation( -_progressFillView.frame.size.width + delta, 0, 0 );
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

- (void)gtarNoteOn:(GtarPluck)pluck
{
    [self gtarNoteOn:pluck forFrame:nil];
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
        
    }
}

- (void)gtarNoteOff:(GtarPosition)position
{
    
    // Always mute notes on note-off for hard
    [g_soundMaster NoteOffAtString:position.string-1 andFret:position.fret];
    
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

- (void)gtarConnected
{
    // Standalone -> Normal
    NSLog(@"SongViewController: gTar has been connected");

    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    // Only disconnect if mid-song
    if(isStandalone){
        
        [g_soundMaster stop];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }else{
        
        [g_gtarController setMinimumInterarrivalTime:0.10f];
        
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

- (void)gtarDisconnected
{
 
    // Normal -> Standalone
    NSLog(@"SongViewController: gTar has been disconnected");
    
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
    if(g_gtarController.connected){
        [g_gtarController turnOffAllLeds];
    }
    [_displayController cancelPreloading];
    
    _currentFrame = nil;
    _lastTappedFrame = nil;
    
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
    
    _songRecorder = [[SongRecorder alloc] initWithTempo:_song.m_tempo];
    
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
    _displayController = [[SongDisplayController alloc] initWithSong:_songModel andView:_glView isStandalone:isStandalone setDifficulty:_difficulty andLoops:loops];
    
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
    
    [self initSongModel]; // reinit
    [self updateMenuLabelsForSongStart];
    
    // Give a little runway to the player
    [_songModel startWithDelegate:self andBeatOffset:-4 fastForward:YES isScrolling:(isScrolling || isStandalone) withTempoPercent:tempoPercent fromStart:start toEnd:end withLoops:loops];
    
    // Light up the first frame
    //if(g_gtarController.connected == YES){
        [self turnOnFrame:_songModel.m_nextFrame];
    //}
    
    [self initSongRecorder];
    
    [self initSongDisplayWithLoops:loops];
    
    if(!_practiceViewOpen){
        [g_soundMaster start];
        [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
        [self drawPauseButton:_pauseButton];
    }
    
    [self updateScoreDisplayWithAccuracy:-1];
    
}

// This is the normal song init for standalone/regular
- (void)startWithSongXmlDom
{
    
    m_loopStart = 0;
    m_loopEnd = 1.0;
    m_loops = 0;
    
    [self initSongModel]; // reinit
    [self updateMenuLabelsForSongStart];
    
    // Give a little runway to the player
    [_songModel startWithDelegate:self andBeatOffset:-4 fastForward:YES isScrolling:(isScrolling || isStandalone) withTempoPercent:1.0 fromStart:0 toEnd:-1 withLoops:0];
    
    // Light up the first frame
    //if(g_gtarController.connected == YES){
        [self turnOnFrame:_songModel.m_nextFrame];
    //}
    
    [self initSongRecorder];

    [self initSongDisplayWithLoops:0];
    
    if(!_practiceViewOpen){
        [g_soundMaster start];
        [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
        [self drawPauseButton:_pauseButton];
    }
    
    [self updateScoreDisplayWithAccuracy:-1];
    
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
        [g_soundMaster NoteOffAtString:str-1 andFret:fret];
        
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
        NSLog(@"Play View Controller Pluck Muted String");
        [g_soundMaster PluckMutedString:str-1];
    }
    else
    {
        NSLog(@"Play View Controller Pluck String");
        [g_soundMaster PluckString:str-1 atFret:fret];
    }
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame
{
    NSLog(@"Song model enter frame");
    
    _currentFrame = frame;
    
    // Align us more pefectly with the frame
    if(!isScrolling){
        [_songModel incrementBeatSerialAccess:(frame.m_absoluteBeatStart - _songModel.m_currentBeat)];
    }
    
    _refreshDisplay = YES;
    
    if(isScrolling){
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
    
    _currentFrame = nil;
    
    if(!isStandalone && frame != nil){
        // Calculate score only on frame release for regular play
        double accuracy = [_scoreTracker scoreFrame:frame onBeat:-1 withComplexity:0 endStreak:NO isStandalone:NO forLoop:MIN([_songModel getCurrentLoop],m_loops)];
        [self updateScoreDisplayWithAccuracy:accuracy];
    }
    
    // Score checking on frame release
    if(frame != nil){
        [_scoreTracker scoreEndOfFrame:frame];
    }
    
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
    // Light up in advance
    if(isScrolling){
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
    
    
    //NSLog(@"FrameHits is %@ for %i frames",frameHits,[frameHits count]);
    
    double numSlices = [tempFrameHits count];
    double sliceWidth = _heatMapView.frame.size.width / [tempFrameHits count];
    
    // Aggregate frame hits
    if(isPracticeMode){
        
        int framesPerSlice = numSlices/(m_loops+1);
        
        for(int i = 0; i < framesPerSlice; i++){
            
            double sliceAccuracy = 0;
            
            for(int j = 0; j < m_loops; j++){
                sliceAccuracy += [[tempFrameHits objectAtIndex:i*j+j] doubleValue];
            }
            
            sliceAccuracy /= (m_loops+1);
            
            [frameHits addObject:[NSNumber numberWithDouble:sliceAccuracy]];
            
        }
    }else{
        frameHits = tempFrameHits;
    }
    
    // Draw
    CGSize size = CGSizeMake(_heatMapView.frame.size.width,_heatMapView.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for(int f = 0, g = 0; f < numSlices; f++){
        
        // Calculate accuracy color
        double accuracy = 0;
        UIColor * accuracyColor = [UIColor blackColor];
        
        double trimmedSliceWidth = sliceWidth+0.25;
        double trimmedSliceExtra = 0;
        
        if((double)f/(double)numSlices >= m_loopStart && (double)f/(double)numSlices < m_loopEnd){
        
            accuracy = [[frameHits objectAtIndex:g] doubleValue];
        
            if(accuracy < 0.5){
                accuracyColor = [UIColor colorWithRed:1.0 green:((2.0*accuracy)*115.0+65.0)/255.0 blue:50/255.0 alpha:0.9];
            }else{
                accuracyColor = [UIColor colorWithRed:2.0*(1.0-accuracy)*255.0/255.0 green:180/255.0 blue:50/255.0 alpha:0.9];
            }
            
            g++;
            
            // Ensure that wide frames don't go over the expected area
            if(m_loopEnd < 1 && sliceWidth*f+sliceWidth+0.25 > _heatMapView.frame.size.width * m_loopEnd){
                trimmedSliceWidth = _heatMapView.frame.size.width * m_loopEnd - sliceWidth*f;
                trimmedSliceExtra = sliceWidth+0.25 - trimmedSliceWidth;
            }
            
        }
        
        CGRect sliceRect = CGRectMake(sliceWidth*f,0,trimmedSliceWidth,_heatMapView.frame.size.height);
        
        CGContextAddRect(context,sliceRect);
        CGContextSetFillColorWithColor(context, accuracyColor.CGColor);
        CGContextFillRect(context, sliceRect);
        
        // Add in extra filler if area gets cropped
        if(trimmedSliceExtra > 0){
            
            CGRect sliceExtraRect = CGRectMake(sliceWidth*f+trimmedSliceWidth,0,trimmedSliceExtra,_heatMapView.frame.size.height);
            
            CGContextAddRect(context,sliceExtraRect);
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextFillRect(context, sliceExtraRect);
        }
        
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
    if ( [g_userController isUserSongSessionQueueFull] == YES )
    {
        [_feedSwitch setOn:NO];
    }
    
}

- (void)endSong
{
    
    [_metronomeTimer invalidate];
    _metronomeTimer = nil;
    
    NSDictionary * scoreData = [_scoreTracker aggregateScoreEndOfSong];
    
    double totalscore = [[scoreData objectForKey:@"TotalScore"] doubleValue];
    double bestscore = [[scoreData objectForKey:@"BestScore"] doubleValue];
    double score = [[scoreData objectForKey:@"Score"] doubleValue];
    double percentNotesHit = 100*[[scoreData objectForKey:@"PercentNotesHit"] doubleValue];
    double maxStreak = [[scoreData objectForKey:@"MaxStreak"] doubleValue];
    double accuracy = 100*[[scoreData objectForKey:@"AverageTiming"] doubleValue];
    
    
    [_scoreBestSession setHidden:!isPracticeMode];
    [_scoreBestSessionLabel setHidden:!isPracticeMode];
    [_scoreTotal setHidden:!isPracticeMode];
    [_scoreTotalLabel setHidden:!isPracticeMode];
    
    if(isPracticeMode){
        
        _scoreBestSession.text = [self formatScore:(int)bestscore];
        _scoreScore.text = [self formatScore:(int)score];
        _scoreTotal.text = [self formatScore:(int)totalscore];
        
    }else{
        
        _scoreScore.text = [self formatScore:(int)score];
    }
    
    _scoreNotesHit.text = [NSString stringWithFormat:@"%i%%",(int)percentNotesHit];
    _scoreInARow.text = [NSString stringWithFormat:@"%i",(int)maxStreak];
    _scoreAccuracy.text = [NSString stringWithFormat:@"%i%%",(int)accuracy];
    
    // Build the heat map
    [self drawHeatMap];
    
    // Turn of the LEDs
    if(g_gtarController.connected){
        [g_gtarController turnOffAllLeds];
    }
    
    [_songRecorder finishSong];
    
    // Show final screen
    [_finishPracticeButton setHidden:NO];
    [_finishButton setHidden:NO];
    [_finishRestartButton setHidden:NO];
    [_backButton setEnabled:NO];
    
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
    if(isStandalone && !_songIsPaused){
        //[self performSelectorInBackground:@selector(tapNoteFromTouchPoint:) withObject:[NSValue valueWithCGPoint:touchPoint]];
        [self tapNoteFromTouchPoint:[NSValue valueWithCGPoint:touchPoint]];
    }
    
    // Debug
#ifdef Debug_BUILD
    if(g_gtarController.connected){
        _skipNotes = YES;
    }
#endif
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    
    CGFloat deltaX = currentPoint.x - previousPoint.x;
    
    // Only shift render view if delta x is large enough
    if(!isScrolling){
        if(abs(initPoint.x - currentPoint.x) > 50){
                [_displayController shiftViewDelta:-deltaX];
        }
    }
    
    // If delta y is large enough then strum
    if(isStandalone && abs(initPoint.y - currentPoint.y) > 10 && !_songIsPaused){
        
        CGPoint touchPoint = [touch locationInView:self.glView];
        [self strumNoteFromTouchPoint:[NSValue valueWithCGPoint:touchPoint]];
        
    }
    
    _refreshDisplay = YES;
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}


#pragma mark - Standalone logic
// Standalone
- (void)tapNoteFromTouchPoint:(NSValue *)touchPointVaue
{
    CGPoint touchPoint = [touchPointVaue CGPointValue];
    
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

// Standalone
- (void)strumNoteFromTouchPoint:(NSValue *)touchPointValue
{
    CGPoint touchPoint = [touchPointValue CGPointValue];
    
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

// Standalone
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
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }
                break;
            case 1:
                if(playFretOne && (!fretOneOn || fretTwoOn || fretThreeOn)){
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }else if(playFretTwo && (!fretTwoOn || fretOneOn || fretThreeOn)){
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }else if(playFretThree && (!fretThreeOn || fretOneOn || fretTwoOn)){
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }
                break;
            case 2:
                if(playFretOne && playFretTwo && (!fretOneOn || !fretTwoOn || fretThreeOn)){
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }else if(playFretOne && playFretThree && (!fretOneOn || !fretThreeOn || fretTwoOn)){
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }else if(playFretTwo && playFretThree && (!fretTwoOn || !fretThreeOn || fretOneOn)){
                    [_displayController attemptFrame:tappedFrame];
                    return;
                }
                break;
            case 3:
                if(!fretOneOn || !fretTwoOn || !fretThreeOn){
                    [_displayController attemptFrame:tappedFrame];
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
                        [_displayController attemptFrame:tappedFrame];
                        return;
                    }
                    break;
                case 1:
                    if(!fretOneOn){
                        [_displayController attemptFrame:tappedFrame];
                        return;
                    }
                    break;
                case 2:
                    if(!fretTwoOn){
                        [_displayController attemptFrame:tappedFrame];
                        return;
                    }
                    break;
                case 3:
                    if(!fretThreeOn){
                        [_displayController attemptFrame:tappedFrame];
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
            
            @synchronized(tappedFrame.m_notesPending){
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
    
    @synchronized(tappedFrame.m_notesPending){
        for(NSNote * nnn in notesToRemove){
            [tappedFrame removeString:nnn.m_string andFret:nnn.m_fret];
        }
    }

    // Prepare data to score
    if([tappedFrame.m_notesHit count] > 0){
        
        // Count number of frets on
        int numFretsOn = 0;
        if(fretOneOn) numFretsOn++;
        if(fretTwoOn) numFretsOn++;
        if(fretThreeOn) numFretsOn++;

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
        
        double accuracy = [_scoreTracker scoreFrame:tappedFrame onBeat:_songModel.m_currentBeat withComplexity:numFretsOn endStreak:endStreak isStandalone:isStandalone forLoop:MIN([_songModel getLoopForBeat:tappedFrame.m_absoluteBeatStart],m_loops)];
        
        // Save the accuracy in note.m_hit
        for(NSNote * nn in tappedFrame.m_notes){
            [_displayController setNoteHit:nn toValue:accuracy];
        }
        
        [self updateScoreDisplayWithAccuracy:accuracy];
        
        _lastTappedFrame = tappedFrame;
        
    }
    
}

// Standalone
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

// Standalone
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

