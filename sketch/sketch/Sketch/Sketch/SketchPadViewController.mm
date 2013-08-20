//
//  SketchPadViewController.m
//  Sketch
//
//  Created by Franco on 6/6/13.
//
//

#import "SketchPadViewController.h"
#import "MenuViewController.h"
#import "AudioViewController.h"
#import "PlayerViewController.h"
#import <gTarAppCore/InstrumentTableViewController.h>

#import <AudioController/AudioController.h>
#import <gTarAppCore/SongRecorder.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSSongCreator.h>
#import <gTarAppCore/XmlDom.h>
#import "Mixpanel.h"

#import <QuartzCore/QuartzCore.h>

@interface SketchPadViewController ()
{
    GtarController* _gtarController;
    AudioController* _audioController;
    
    UIViewController* _currentMainVC;
    SongTableViewController* _songTableVC;
    
    SongRecorder* _songRecorder;
    
    NSInteger _tempo;
    
    // Keep track of song  recording time
    NSTimer* _songTimeCounterTimer;
    float _timeCounterInterval;
    NSTimeInterval _runningSongTime;
    NSDate* _lastNotePlayedTime;
    
    // songRecorderTimer
    NSTimer* _srTimer;
    float _srTimeInterval;
    
    
    MenuViewController* _menuVC;
    InstrumentTableViewController* _instrumentsVC;
    AudioViewController* _audioVC;
    PlayerViewController* _playBackVC;
}

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *playBackView;
@property (weak, nonatomic) IBOutlet UIButton *recordAndStopButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *songLengthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playPauseImage;
@property (weak, nonatomic) IBOutlet UIImageView *recordAndStopImage;
@property (weak, nonatomic) IBOutlet UILabel *gTarNotConnectedLabel;
@property (weak, nonatomic) IBOutlet UIView *dropShadowTop;
@property (weak, nonatomic) IBOutlet UIView *dropShadowBottom;

@end

@implementation SketchPadViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
    [_audioController startAUGraph];
    
    _songTableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SongViewControlerID"];
    _songTableVC.delegate = self;
    
    _menuVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewControllerID"];
    
    _audioVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioViewControllerID"];
    _audioVC.audioController = _audioController;
    
    _playBackVC = [[PlayerViewController alloc] initWithAudioController:_audioController];
    _playBackVC.view.frame = _playBackView.frame;
    [_playBackVC recordMode];
    [self addChildViewController:_playBackVC];
    [_playBackView addSubview:_playBackVC.view];
    [_playBackVC didMoveToParentViewController:self];
    
    // Set up initial main content VC to be songTableVC
    [self addChildViewController:_songTableVC];
    [_mainContentView addSubview:_songTableVC.view];
    [_songTableVC didMoveToParentViewController:self];
    _currentMainVC = _songTableVC;
    
    _instrumentsVC = [[InstrumentTableViewController alloc] initWithAudioController:_audioController];
    
    _gtarController = [GtarController sharedInstance];
    // By default it just outputs 'LevelError'
    _gtarController.logLevel = GtarControllerLogLevelAll;
    [_gtarController addObserver:self];
    
    _tempo = 120.0;
    _srTimeInterval = 60.0/_tempo/16.0;
    _timeCounterInterval = 0.2;

    // Add drop shadows to top and bottom bars
    _dropShadowTop.layer.shadowRadius = 4.0;
    _dropShadowTop.layer.shadowColor = [[UIColor blackColor] CGColor];
    _dropShadowTop.layer.shadowOffset = CGSizeMake(0, 0);
    _dropShadowTop.layer.shadowOpacity = 0.5;
    
    _dropShadowBottom.layer.shadowRadius = 4.0;
    _dropShadowBottom.layer.shadowColor = [[UIColor blackColor] CGColor];
    _dropShadowBottom.layer.shadowOffset = CGSizeMake(0, 0);
    _dropShadowBottom.layer.shadowOpacity = 0.5;
    
    
    //_songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songPlayBackEnded:) name:@"SongPlayBackEnded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioEngineStopped:) name:@"AudioEngineStopped" object:nil];
    
    [[NSNotificationCenter defaultCenter]
                            addObserver:self
                            selector:@selector(applicationDidReceiveMemoryWarning:)
                            name:UIApplicationDidReceiveMemoryWarningNotification
                            object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SongPlayBackEnded" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioEngineStopped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _instrumentsVC.tableView.frame = _mainContentView.bounds;
    _audioVC.view.frame = _mainContentView.bounds;
    _menuVC.view.frame = _mainContentView.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma class methods

- (void)serviceSongRecorderTimer:(NSTimer*)theTimer
{
    [_songRecorder advanceRecordingByTimeDelta:(_srTimeInterval)];
}

- (void)serviceSongLengthTimer:(NSTimer *)timer {
    
    _runningSongTime = _runningSongTime + _timeCounterInterval;
    
    int minutes = _runningSongTime/60;
    int seconds = _runningSongTime - minutes * 60;
    
    NSString* time = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    _songLengthLabel.text = time;
}

// Finds the next default song name to use based on existing song names.
// The song name format is "New Song #". So if songs "New Song",  "New Song 2",
// "New Song 3" exist then this function should return "New Song 4". If only "New Song"
// and "New Song 3" exist then "New Song 2" should be returned.
- (NSString*)getNewSongName
{
    // Find next unused "New Song #" slot available
    NSString* baseName = @"New Song";
    NSMutableArray* songNames = [[NSMutableArray alloc] init];
    for (UserSongSession* s in _songTableVC.songList)
    {
        [songNames addObject:s.m_notes];
    }
    
    // First find all songNames that contain "New Song"
    NSPredicate *exactlyBaseNamePredicate = [NSPredicate predicateWithFormat:@"SELF matches %@",baseName];
    NSPredicate *containsBaseNamePredicate = [NSPredicate predicateWithFormat:@"SELF contains %@",baseName];
    NSArray *exactlyBaseNameSong = [songNames filteredArrayUsingPredicate:exactlyBaseNamePredicate];
    NSArray *songsWithBaseName = [songNames filteredArrayUsingPredicate:containsBaseNamePredicate];
    
    // Get regex to find # in strings matching "New Song #". Add # to array to find new availabel #
    NSString* searchRegEx = [NSString stringWithFormat:@"^%@\\s+(\\d+)\\s*$", baseName];
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:searchRegEx options:0 error:&error];
    // usedNumber array representing which #s in the format "New Song #" are already taken 
    NSMutableArray* usedNumbers = [[NSMutableArray alloc] init];
    if ([exactlyBaseNameSong count] > 0)
    {
        // the progression of names is "New Song" "New Song 2", i.e. no "New Song 1",
        // so "New Song" represents both the 0 and 1 values, add them to the usedNumber array.
        [usedNumbers addObject:[NSNumber numberWithInt:0]];
        [usedNumbers addObject:[NSNumber numberWithInt:1]];
    }
    for (NSString* s in songsWithBaseName)
    {
        NSTextCheckingResult* match = [regex firstMatchInString:s options:0 range:NSMakeRange(0, [s length])];
        NSRange r = [match rangeAtIndex:1];
        if (r.length > 0)
        {
            // An actual match for a number after "New Song", add it to number array
            NSString* stringMatch = [s substringWithRange:[match rangeAtIndex:1]];
            [usedNumbers addObject:[NSNumber numberWithInt:[stringMatch intValue]]];
        }
    }
    
    // If no songs currently exist cointaing the base name return baseName
    if ([usedNumbers count] == 0)
    {
        return baseName;
    }
    
    // Sort through song names containing baseName and find the next available numer to use
    NSSortDescriptor* lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [usedNumbers sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    int nextFreeNum = 0;
    if ([[usedNumbers objectAtIndex:0] intValue] == 0)
    {
        // find an open slot, i.e. for 0,1,2,4,5 find 3
        for (int index=0; index < [usedNumbers count] - 1; index++)
        {
            int currentNum = [[usedNumbers objectAtIndex:index] intValue];
            int nextNum = [[usedNumbers objectAtIndex:index+1] intValue];
            // if the nextNum is not currentNumm + 1 then we have found our open slot
            if (currentNum + 1 != nextNum)
            {
                nextFreeNum = currentNum + 1;
                break;
            }
            nextFreeNum = nextNum + 1;
        }
    }
    
    NSString* newSongName;
    if (nextFreeNum == 0)
    {
        newSongName = baseName;
    }
    else
    {
        newSongName = [NSString stringWithFormat:@"%@ %d", baseName, nextFreeNum];
    }
    
    return newSongName;
}


#pragma mark IBActions

// TODO: for UI, have jsut one button for starting/stoping recording (it will toggle between record icon
// a stop icon.) as a result might only need 1 IBaction for the 1 button, and keep stop/start state)
- (IBAction)toggleRecording:(UIButton*)sender
{
    // Toggle the buttons state (between record and stop)
    _recordAndStopButton.selected = !_recordAndStopButton.selected;
    
    if (_recordAndStopButton.selected)
    {
        // Adjust UI
        _recordAndStopButton.backgroundColor = [UIColor colorWithRed:(199/255.0) green:(46/255.0) blue:(0/255.0) alpha:1];
        _playPauseButton.selected = YES;
        _playPauseImage.highlighted = YES;
        _recordAndStopImage.highlighted = YES;
        _songLengthLabel.hidden = NO;
        [_playBackVC recordMode];
        NSString* time = [NSString stringWithFormat:@"%d:%02d", 0, 0];
        _songLengthLabel.text = time;
        
        // Setup timers
        _lastNotePlayedTime = [NSDate date];
        _runningSongTime = 0;
        _songTimeCounterTimer = [NSTimer scheduledTimerWithTimeInterval:_timeCounterInterval target:self selector:@selector(serviceSongLengthTimer:) userInfo:nil repeats:YES];
        
        // run timer at say every 1/8th notes, check how much time is left on timer to get how much time has passed, add this time to the advance timer. can choose a quantization setting and quantize your song if you want (just run timer every quantization interval and when note goes in record it without adjusting time passed, to make it quantize to nearest interval instead of just to one that has passed: check how much time has passed to figure out which quantizatoin interval is closer, the last one to have passed or the next one coming up.
        [_srTimer invalidate];
        _srTimer = [NSTimer scheduledTimerWithTimeInterval:(_srTimeInterval) target:self selector:@selector(serviceSongRecorderTimer:) userInfo:nil repeats:YES];
        
        // Turn off any LEDs that may be on.
        [[GtarController sharedInstance] turnOffAllLeds];
        
        // Start Song recording
        _songRecorder = [[SongRecorder alloc] initWithTempo:_tempo];
        [_songRecorder beginSong];
    }
    else
    {
        [_songRecorder finishSong];
        
        // Adjust UI
        _recordAndStopButton.backgroundColor = [UIColor colorWithRed:(39/255.0) green:(47/255.0) blue:(50/255.0) alpha:1];
        _playPauseButton.selected = NO;
        _playPauseImage.highlighted = NO;
        _recordAndStopImage.highlighted = NO;
        
        // Stop timmers
        [_srTimer invalidate];
        _srTimer = nil;
        [_songTimeCounterTimer invalidate];
        _songTimeCounterTimer = nil;
        
        // Create and save song session if appropriate
        
        // Calculate actual play time (beginning of recording to last note played)
        NSTimeInterval deadTimeAtEnd = [[NSDate date] timeIntervalSinceDate:_lastNotePlayedTime];
        NSTimeInterval songPlayTime = _runningSongTime - deadTimeAtEnd;
        if (songPlayTime < 1)
        {
            // If the song is less than a second do not save it.
            return;
        }
        UserSongSession * session = [[UserSongSession alloc] init];
        
        session.m_length = songPlayTime;
        session.m_notes = [self getNewSongName];
        session.m_created = [[NSDate date] timeIntervalSince1970];
        
        _songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
        
        // Create the xmp
        session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
        session.m_created = time(NULL);
        
        [self logSongCreated:session];
        
        [_songTableVC addSongSession:session];
        
        // Upload song to server. This also persists the upload in case of network failure
        //[g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    }
}

- (IBAction)togglePlayPause:(UIButton *)sender
{
    _playPauseButton.selected = !_playPauseButton.selected;
    _playPauseImage.highlighted = _playPauseButton.selected;
    
    // Different pause play behavior depending on wether we are currently
    // recording.
    if (_recordAndStopButton.selected)
    {
        // If currently recording, pause/play the recording
        if (_playPauseButton.selected)
        {
            _songTimeCounterTimer = [NSTimer scheduledTimerWithTimeInterval:_timeCounterInterval target:self selector:@selector(serviceSongLengthTimer:) userInfo:nil repeats:YES];
            [_songRecorder continueRecording];
        }
        else
        {
            [_songTimeCounterTimer invalidate];
            _songTimeCounterTimer = nil;
            [_songRecorder pauseRecording];
        }
    }
    else
    {
        // Control song playback
        if (_playPauseButton.selected)
        {
            _songLengthLabel.hidden = YES;
            
            [_playBackVC continueSong];

        }
        else
        {
            [_playBackVC pauseSong];
        }
        
    }
    
}

- (IBAction)displaySongList:(id)sender
{
    [self switchMainContentControllerToVC:_songTableVC];
}

- (IBAction)displayInstrumentList:(id)sender
{
    [self switchMainContentControllerToVC:_instrumentsVC];
}

- (IBAction)displayMenuView:(id)sender
{
    [self switchMainContentControllerToVC:_menuVC];
}


- (IBAction)displayAudioView:(id)sender
{
     [self switchMainContentControllerToVC:_audioVC];
}

#pragma mark SongTableVCDelegate

- (void)selectedSong:(UserSongSession*)songSession
{
    // If we were in the middle of a recording, ignore the selection. Force
    // the user to explicitly stop a recording.
    if (_recordAndStopButton.selected)
    {
        return;
    }
    
    _songLengthLabel.hidden = YES;
    _playPauseButton.selected = NO;
    _playPauseImage.highlighted = NO;
    
    [_playBackVC setUserSongSession:songSession];
}

- (void)playSong:(UserSongSession*)songSession
{
    // If we were in the middle of a recording, ignore the selection. Force
    // the user to explicitly stop a recording.
    if (_recordAndStopButton.selected)
    {
        return;
    }

    _playPauseButton.selected = YES;
    _playPauseImage.highlighted = YES;
    [_playBackVC setUserSongSession:songSession];
    [_playBackVC startSong];
}

#pragma mark Other

#ifdef DEBUG
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
    CGPoint point = [touch locationInView:self.view];
    
    int str = point.x / (self.view.frame.size.width/GtarStringCount);
    if ( str >= GtarFretCount ) str = (GtarFretCount-1);
    
    int fret = point.y / (self.view.frame.size.height/GtarFretCount);
    if ( fret >= GtarFretCount ) fret = (GtarFretCount-1);
    
    GtarPluck pluck;
    pluck.velocity = GtarMaxPluckVelocity;
    pluck.position.fret = (GtarFretCount-fret-1);
    pluck.position.string = (str+1);
    
    [self gtarNoteOn:pluck];
}
#endif

#pragma mark gTarControllerObserver

- (void)gtarFretDown:(GtarPosition)position
{
    
}

- (void)gtarFretUp:(GtarPosition)position
{
    
}

- (void)gtarNoteOn:(GtarPluck)pluck
{
    [_audioController PluckString:pluck.position.string - 1 atFret:pluck.position.fret];
    [_songRecorder playString:pluck.position.string andFret:pluck.position.fret];
    
    _lastNotePlayedTime = [NSDate date];
}

- (void)gtarNoteOff:(GtarPosition)position
{
    
}

- (void)gtarConnected
{
    _gTarNotConnectedLabel.hidden = YES;
    
    // Prevent app from timing out due to touch inactivity (could be jamming)
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)gtarDisconnected
{
    _gTarNotConnectedLabel.hidden = NO;
    
    // re-enable the gTar
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void) songPlayBackEnded:(NSNotification *) notification
{
    _playPauseButton.selected = NO;
    _playPauseImage.highlighted = NO;
}

- (void) audioEngineStopped:(NSNotification *) notification
{
    [_audioController startAUGraph];
}

#pragma mark helpers

-(void) switchMainContentControllerToVC:(UIViewController *)newVC
{
    if (_currentMainVC ==  newVC)
    {
        // already on this view, do nothing
        return;
    }
    
    UIViewController *oldVC = _currentMainVC;
    
    [oldVC willMoveToParentViewController:nil];
    
    [self addChildViewController:newVC];
    
    [self transitionFromViewController:oldVC  toViewController:newVC duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL finished) {
                                [oldVC removeFromParentViewController];
                                [newVC didMoveToParentViewController:self];
                                _currentMainVC = newVC;
                            }];
}

- (void) applicationDidReceiveMemoryWarning:(NSNotification *) notification
{
    [self toggleRecording:_recordAndStopButton];
    [_songTableVC saveData];
}

#pragma Mixpanel logging

- (void)logSongCreated:(UserSongSession*)songSession
{
    
    XmlDom * songDom = [[XmlDom alloc] initWithXmlString:songSession.m_xmpBlob];
    NSSong * song = [[NSSong alloc] initWithXmlDom:songDom];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    // Don't bother adding song name since it will just be a generic "New Song #" at this point
    [mixpanel track:@"Song Created" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInteger:songSession.m_length], @"Song Length",
                                                song.m_instrument, @"Instrument",
                                                nil]];
}

@end
