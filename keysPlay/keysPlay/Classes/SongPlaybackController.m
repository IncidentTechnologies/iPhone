//
//  SongPlaybackController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "SongPlaybackController.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_INCORRECT 0.80f
#define AUDIO_CONTROLLER_AMPLITUDE_MUFFLED 0.15f

@implementation SongPlaybackController

@synthesize m_songModel;
@synthesize g_soundMaster;

- (id)initWithSoundMaster:(SoundMaster *)soundMaster
{
    
    self = [super init];
    if ( self ) {
        
        if(soundMaster != nil){
            g_soundMaster = soundMaster;
            [g_soundMaster start];
        }
    }
    
    return self;
}

- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    [g_soundMaster didSelectInstrument:instrumentName withSelector:cb andOwner:sender];
}

- (void)stopAudioEffects
{
    [g_soundMaster stopAllEffects];
}

- (NSInteger)getSelectedInstrumentIndex
{
    return [g_soundMaster getCurrentInstrument];
}

- (NSArray *)getInstrumentList
{
    
    return [g_soundMaster getInstrumentList];
}

- (void)dealloc {
    
    [m_keysController removeObserver:self];
    
    
    /*if([g_soundMaster respondsToSelector:@selector(disconnectAndRelease)]){
     [g_soundMaster disconnectAndRelease];
     [g_soundMaster release];
     g_soundMaster = nil;
     }*/
    
    //[g_soundMaster releaseAfterUse];
    
    
    [m_eventLoopTimer invalidate];
    m_eventLoopTimer = nil;
    
    [m_audioTrailOffTimer invalidate];
    m_audioTrailOffTimer = nil;
    
    
}

- (void)startWithXmpBlob:(NSString*)xmpBlob
{
    if ( xmpBlob == nil )
        return;
    
    [g_soundMaster reset];
    
    // release the old song
    
    XmlDom * songDom = [[XmlDom alloc] initWithXmlString:xmpBlob];
    
    NSSong * song = [[NSSong alloc] initWithXmlDom:songDom];
    
    m_songModel = [[NSSongModel alloc] initWithSong:song];
    
    // Double tempo because for some reason it's incredibly slow in playback
    [m_songModel startWithDelegate:self andBeatOffset:-1 fastForward:YES isScrolling:NO withTempoPercent:2.0 fromStart:0 toEnd:-1 withLoops:0];
    
    [self startMainEventLoop];
    
}
/*
 - (void)startWithUserSong:(UserSong*)userSong
 {
 // TODO This function doesn't work right now because the m_xmlDom doesn't have the XMP in it
 if ( userSong == nil )
 return;
 
 [g_soundMaster reset];
 
 // release the old song
 
 NSSong * song = [[NSSong alloc] initWithXmlDom:userSong.m_xmlDom];
 
 m_songModel = [[NSSongModel alloc] initWithSong:song];
 
 [m_songModel startWithDelegate:self andBeatOffset:-1 fastForward:YES isScrolling:NO withTempoPercent:1.0 fromStart:0 toEnd:-1 withLoops:0];
 
 [self startMainEventLoop];
 }
 */
- (void)playSong {
    
    NSLog(@"Song Playback Controller: play song");
    
    [g_soundMaster reset];
    [self startMainEventLoop];
}

- (void)pauseSong {
    [self stopMainEventLoop];
    [g_soundMaster stop];
    //[m_audioController stopAUGraph];
}

- (void)endSong {
    [self stopMainEventLoop];
    
    [g_soundMaster reset];
    
    m_songModel = nil;
    
}

- (void)observeKeysController:(KeysController*)keysController {
    m_keysController = keysController;
    
    // Register ourself as an observer
    [m_keysController addObserver:self];
    
    if(m_keysController.connected){
        [m_keysController turnOffAllEffects];
        [m_keysController turnOffAllLeds];
    }
    
}

- (void)ignoreKeysController:(KeysController*)keysController {
    if(m_keysController.connected){
        [m_keysController turnOffAllEffects];
        [m_keysController turnOffAllLeds];
    }
    
    // Remove ourself as an observer
    [m_keysController removeObserver:self];
    
    
    m_keysController = nil;
    
}

- (void)startMainEventLoop {
    
    NSLog(@"Song Playback Controller: start main event loop");
    
    if ( m_songModel.m_percentageComplete >= 1.0 )
        return;
    
    [m_eventLoopTimer invalidate];
    
    m_eventLoopTimer = nil;
    
    [m_audioTrailOffTimer invalidate];
    
    m_audioTrailOffTimer = nil;
    
    //[m_audioController startAUGraph];
    [g_soundMaster start];
    
    //[m_songModel skipToNextFrame];
    m_eventLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)SECONDS_PER_EVENT_LOOP target:self selector:@selector(mainEventLoop) userInfo:nil repeats:TRUE];
    
}

- (void)stopMainEventLoop {
    if ( m_eventLoopTimer != nil ) {
        [m_eventLoopTimer invalidate];
        m_eventLoopTimer = nil;
    }
}

- (void)audioTrailOffEvent {
    [m_audioTrailOffTimer invalidate];
    
    m_audioTrailOffTimer = nil;
    
    [g_soundMaster reset];
    
}
- (void)mainEventLoop {
    
    [m_songModel incrementTimeSerialAccess:SECONDS_PER_EVENT_LOOP isRestrictFrame:NO];
}

#pragma mark - GuitarControllerObserver

- (void)keysNoteOn:(KeysPress)press {
    //KeysFret fret = press.position.fret;
    //KeysString str = press.position.string;
    
    //KeysPressVelocity velocity = press.velocity;
    
    //[m_audioController PluckString:str-1 atFret:fret withAmplitude:(float)velocity/127.0f];
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame {
    
    //NSLog(@"Song playback controller: song model enter frame");
    
    for ( NSNote * note in frame.m_notes ) {
        if ( note.m_key == KEYS_KEY_MUTED ) {
            
            NSLog(@"play muted key %i",note.m_key-1);
            
            [g_soundMaster playMutedKey:note.m_key-1];
            
        }
        else {
            NSLog(@"pluck string %i",note.m_key-1);
            
            [g_soundMaster playKey:note.m_key-1];
            
            //[m_keysController turnOnLedAtPosition:KeysPositionMake(note.m_fret, note.m_string) withColor:KeysLedColorMake(KeysMaxLedIntensity, KeysMaxLedIntensity, KeysMaxLedIntensity)];
            
            //[self performSelector:@selector(delayedTurnLedOff:) withObject:note afterDelay:0.1];
        }
    }
}


- (void)songModelExitFrame:(NSNoteFrame*)frame {
    
}


- (void)delayedTurnLedOff:(NSNote *)note
{
    [m_keysController turnOffLedAtPosition:note.m_key];
}

- (void)songModelNextFrame:(NSNoteFrame*)frame
{
    if(m_keysController.connected){
        [m_keysController turnOffAllLeds];
    }
    
    for ( NSNote * note in frame.m_notes )
    {
        
        if(m_keysController.connected){
            
            if ( note.m_key == KEYS_KEY_MUTED )
            {
                [m_keysController turnOnLedAtPositionWithColorMap:note.m_key];
            }
            else
            {
                [m_keysController turnOnLedAtPositionWithColorMap:note.m_key];
            }
            
        }
    }
}

/*
 - (void)songModelFrameExpired:(NSNoteFrame*)frame {
 
 }
 */

- (void)songModelEndOfSong {
    
    if(m_keysController.connected){
        [m_keysController turnOffAllLeds];
    }
    
    [self stopMainEventLoop];
    
    m_audioTrailOffTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(audioTrailOffEvent) userInfo:nil repeats:NO];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SongPlayBackEnded"
     object:self userInfo:nil];
}

#pragma mark - Misc

// Not sure if percentComplete is the most intuitive
// parameter to seek on, but worth trying it out.
/*- (void)seekToLocation:(double)percentComplete {
 double newBeat;
 
 if ( percentComplete < 0.01 )
 newBeat = 0;           // reset to the beginning at this point
 else if ( percentComplete > 1.0 )
 newBeat = 1.0;
 else
 newBeat= m_songModel.m_lengthBeats * percentComplete;
 
 [m_songModel changeBeatRandomAccess:newBeat];
 
 }*/

- (BOOL)isPlaying {
    
    if ( m_eventLoopTimer != nil )
        return true;
    else
        return false;
}

- (double)percentageComplete {
    return m_songModel.m_percentageComplete;
}

@end
