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
    FileController* _fileController;
    
    NSInteger _tempo;
    // songRecorderTimer
    NSTimer* _srTimer;
    
    SongPlaybackController* _songPlayer;
}

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
    
    _gtarController = [[GtarController alloc] init];
    // By default it just outputs 'LevelError'
    _gtarController.logLevel = GtarControllerLogLevelAll;
    [_gtarController addObserver:self];
    
    _tempo = 120;
    _songRecorder = [[SongRecorder alloc] initWithTempo:_tempo];
    
    _audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
    [_audioController startAUGraph];
    
    //_songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
    
    
    _songPlayer = [[SongPlaybackController alloc] initWithAudioController:_audioController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma class methods

- (void)serviceSongRecorderTimer:(NSTimer*)theTimer
{
    [_songRecorder advanceRecordingByTimeDelta:(60/_tempo)];
}


#pragma mark IBActions

// TODO for UI, have jsut one button for starting/stoping recording (it will toggle between record icon
// a stop icon.) as a result might only need 1 IBaction for the 1 button, and keep stop/start state)
- (IBAction)startRecording:(id)sender
{
    [_songRecorder beginSong];
    // run timer at say every 1/8th notes, check how much time is left on timer to get how much time has passed, add this time to the advance timer. can choose a quantization setting and quantize your song if you want (just run timer every quantization interval and when note goes in record it without adjusting time passed, to make it quantize to nearest interval instead of just to one that has passed: check how much time has passed to figure out which quantizatoin interval is closer, the last one to have passed or the next one coming up.
    [_srTimer invalidate];
    _srTimer = [NSTimer scheduledTimerWithTimeInterval:(60/_tempo) target:self selector:@selector(serviceSongRecorderTimer:) userInfo:nil repeats:YES];
    
}

- (IBAction)stopRecording:(id)sender
{
    [_songRecorder finishSong];

    [_srTimer invalidate];
    _srTimer = nil;
    
    UserSongSession * session = [[UserSongSession alloc] init];
    
    //session.m_userSong = _userSong;
    session.m_notes = @"Created in sketch";
    
    _songRecorder.m_song.m_instrument = [[_audioController getInstrumentNames] objectAtIndex:[_audioController getCurrentSamplePackIndex]];
    
    // Create the xmp
    session.m_xmpBlob = [NSSongCreator xmpBlobWithSong:_songRecorder.m_song];
    session.m_created = time(NULL);
    
    // Upload song to server. This also persists the upload in case of network failure
    //[g_userController requestUserSongSessionUpload:session andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:)];
    
    [_songPlayer startWithXmpBlob:session.m_xmpBlob];
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
    [_audioController PluckString:pluck.position.string atFret:pluck.position.fret];
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
