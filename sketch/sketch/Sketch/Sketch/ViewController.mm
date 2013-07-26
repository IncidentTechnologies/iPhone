//
//  ViewController.m
//  Sketch
//
//  Created by Franco on 6/6/13.
//
//

#import "ViewController.h"
#import "SongViewCell.h"
#import "PlayerViewController.h"

#import <AudioController/AudioController.h>
#import <gTarAppCore/SongRecorder.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSSongCreator.h>

@interface ViewController ()
{
    GtarController* _gtarController;
    AudioController* _audioController;
    
    UIViewController* _currentMainVC;
    SongTableViewController* _songTableVC;
    
    SongRecorder* _songRecorder;
    
    NSInteger _tempo;
    NSDate* _songStartTime;
    // songRecorderTimer
    NSTimer* _srTimer;
    float _srTimeInterval;
    
    PlayerViewController* _playBackVC;
}

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIView *playBackView;
@property (weak, nonatomic) IBOutlet UITableView *songTableView;
@property (weak, nonatomic) IBOutlet UIButton *recordAndStopButton;
@property (weak, nonatomic) IBOutlet UILabel *songLengthLabel;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _songTableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SongViewControlerID"];
    _songTableVC.delegate = self;
    _currentMainVC = _songTableVC;
    [_mainContentView addSubview:_currentMainVC.view];
    
    _audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
    [_audioController startAUGraph];
    
    _playBackVC = [[PlayerViewController alloc] initWithAudioController:_audioController];
    _playBackVC.view.frame = _playBackView.frame;
    [_playBackView addSubview:_playBackVC.view];
    
    
    _gtarController = [[GtarController alloc] init];
    // By default it just outputs 'LevelError'
    _gtarController.logLevel = GtarControllerLogLevelAll;
    [_gtarController addObserver:self];
    
    _tempo = 120;
    _srTimeInterval = 60.0/_tempo/16.0;
    
    
    
    //_songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
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
    
    NSTimeInterval currentSongLength = [[NSDate date] timeIntervalSinceDate: _songStartTime];
    
    int minutes = currentSongLength/60;
    int seconds = currentSongLength - minutes * 60;
    
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
        _songRecorder = [[SongRecorder alloc] initWithTempo:_tempo];
        [_songRecorder beginSong];
        
        // run timer at say every 1/8th notes, check how much time is left on timer to get how much time has passed, add this time to the advance timer. can choose a quantization setting and quantize your song if you want (just run timer every quantization interval and when note goes in record it without adjusting time passed, to make it quantize to nearest interval instead of just to one that has passed: check how much time has passed to figure out which quantizatoin interval is closer, the last one to have passed or the next one coming up.
        [_srTimer invalidate];
        _srTimer = [NSTimer scheduledTimerWithTimeInterval:(_srTimeInterval) target:self selector:@selector(serviceSongRecorderTimer:) userInfo:nil repeats:YES];
        
        _songStartTime = [NSDate date];
    }
    else
    {
        [_songRecorder finishSong];
        
        [_srTimer invalidate];
        _srTimer = nil;
        
        UserSongSession * session = [[UserSongSession alloc] init];
        
        session.m_notes = [self getNewSongName];
        session.m_length = [[NSDate date] timeIntervalSinceDate: _songStartTime];;
        session.m_created = [[NSDate date] timeIntervalSince1970];
        
        _songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
        
        // Create the xmp
        session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
        session.m_created = time(NULL);
        
        [_songTableVC addSongSession:session];
        
        // Upload song to server. This also persists the upload in case of network failure
        //[g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    }
}


#pragma mark SongTableVCDelegate

- (void)playSong:(UserSongSession*)songSession
{
    [_playBackVC setUserSongSession:songSession];
    [_playBackVC playSong];
}

- (void)pauseCurrentSong
{
    
}

#pragma mark Other

#ifdef DEBUG
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
    CGPoint point = [touch locationInView:self.view];
    
    int str = point.x / (self.view.frame.size.height/GtarStringCount);
    if ( str >= GtarFretCount ) str = (GtarFretCount-1);
    
    int fret = point.y / (self.view.frame.size.width/GtarFretCount);
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
    // Currently after playing back a song the audioController AUGraph is stopped, so the
    // audioController is stopped and there is no audio. For now just make a call to start the graph
    // on every noteOn, this is cheap as nothing happens if it's already started.
    // TODO: fix the having to call startAUGraph on every note problem.
    [_audioController startAUGraph];
    [_audioController PluckString:pluck.position.string - 1 atFret:pluck.position.fret];
    [_songRecorder playString:pluck.position.string andFret:pluck.position.fret];
}

- (void)gtarNoteOff:(GtarPosition)position
{
    
}

- (void)gtarConnected
{
    
}

- (void)gtarDisconnected
{
    
}

@end
