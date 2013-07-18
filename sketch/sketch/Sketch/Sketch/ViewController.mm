//
//  ViewController.m
//  Sketch
//
//  Created by Franco on 6/6/13.
//
//

#import "ViewController.h"

#import <AudioController/AudioController.h>
#import <gTarAppCore/SongRecorder.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSSongCreator.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/SongPlaybackController.h>

@interface ViewController ()
{
    GtarController* _gtarController;
    AudioController* _audioController;
    
    SongRecorder* _songRecorder;
    NSMutableArray* _songList;
    FileController* _fileController;
    
    NSInteger _tempo;
    NSTimer* _songLengthTimer;
    NSDate* _songStartTime;
    // songRecorderTimer
    NSTimer* _srTimer;
    float _srTimeInterval;
    
    SongPlaybackController* _songPlayer;
}

@property (weak, nonatomic) IBOutlet UITableView *songTableView;
@property (weak, nonatomic) IBOutlet UIButton *recordAndStopButton;
@property (weak, nonatomic) IBOutlet UILabel *songLengthLabel;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _gtarController = [[GtarController alloc] init];
    // By default it just outputs 'LevelError'
    _gtarController.logLevel = GtarControllerLogLevelAll;
    [_gtarController addObserver:self];
    
    //////////// TODO: load list from archive
    /*_songList = [[NSMutableArray alloc] init];
    
    //// set up fake initial item for testing TODO: remove this code /////
    UserSongSession * session = [[UserSongSession alloc] init];
    
    //session.m_userSong = _userSong;
    session.m_notes = @"Song number 1";
    
    _songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
    
    // Create the xmp
    session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
    session.m_created = time(NULL);
    
    [_songList addObject:session];
     */
    ////////////////// end remove this code chunk //////////
    
    
    _tempo = 120;
    _srTimeInterval = 60.0/_tempo/16.0;
    
    _audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
    [_audioController startAUGraph];
    
    //_songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
    
    
    _songPlayer = [[SongPlaybackController alloc] initWithAudioController:_audioController];
    
    NSString* songListPath = [self getSongListPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: songListPath])
    {        
        _songList = [NSKeyedUnarchiver unarchiveObjectWithFile: songListPath];
    }
    else
    {
        _songList = [[NSMutableArray alloc] init];
    }
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
        _songLengthTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(serviceSongLengthTimer:) userInfo:nil repeats:YES];
    }
    else
    {
        [_songRecorder finishSong];
        
        [_srTimer invalidate];
        _srTimer = nil;
        
        [_songLengthTimer invalidate];
        _songLengthTimer = nil;
        
        UserSongSession * session = [[UserSongSession alloc] init];
        
        //session.m_userSong = _userSong;
        session.m_notes = @"Created in sketch";
        
        _songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
        
        // Create the xmp
        session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
        session.m_created = time(NULL);
        
        [_songList insertObject:session atIndex:0];
        [_songTableView reloadData];
        
        /************ SAVE SONG TO DISK CODE, TODO: move code else where ************/
        //////////////////////////////////////////////////////////////////
        
        NSString* songListPath = [self getSongListPath];
        
        [NSKeyedArchiver archiveRootObject:_songList toFile:songListPath];
        
        
        /************ END SAVE SONG TO DISK CODE            ************/
        //////////////////////////////////////////////////////////////////
        
        
        // Upload song to server. This also persists the upload in case of network failure
        //[g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    }
    
}

- (NSString*)getSongListPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    /*NSString *songsPath = [documentsDirectory stringByAppendingPathComponent:@"Data"];
    NSLog(@"song list path %@", songsPath);
    
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:songsPath] )
    {
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:songsPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
        
        if ( error != nil )
        {
            NSLog(@"Error: '%@' creating File cache path: '%@'", [error localizedDescription], songsPath);
            return nil;
        }
    }
     */
    
    NSString *songListPath = [documentsDirectory stringByAppendingPathComponent:@"songlist.archive"];
    
    return songListPath;
}

#pragma mark Other

#ifdef DEBUG
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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

#pragma mark - UITableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_songList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SongTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    UserSongSession * session = [_songList objectAtIndex:indexPath.row];
    cell.textLabel.text = session.m_notes;
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:(55/255.0) green:(132/255.0) blue:(153/255.0) alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSongSession * session = [_songList objectAtIndex:indexPath.row];
    [_songPlayer startWithXmpBlob:session.m_xmpBlob];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
