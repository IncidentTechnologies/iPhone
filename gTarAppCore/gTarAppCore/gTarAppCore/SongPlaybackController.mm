//
//  SongPlaybackController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "SongPlaybackController.h"

#import <AudioController/AudioController.h>

#import "AppCore.h"

#import "UserSong.h"
#import "NSSong.h"
#import "NSNoteFrame.h"
#import "NSNote.h"
#import "XmlDom.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_INCORRECT 0.80f
#define AUDIO_CONTROLLER_AMPLITUDE_MUFFLED 0.15f

@implementation SongPlaybackController

@synthesize m_songModel;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        
        // Create audio controller
        m_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
        
        [m_audioController initializeAUGraph];
        
    }
    
    return self;
    
}

- (id)initWithAudioController:(AudioController*)audioController
{
    
    self = [super init];
    
    if ( self )
    {
        // Create audio controller
        m_audioController = [audioController retain];
    }
    
    return self;
    
}


- (void)dealloc
{
    
    [m_gtarController removeObserver:self];
    
    [m_gtarController release];
    
	[m_audioController release];
	
    [m_songModel release];

	[m_eventLoopTimer invalidate];
    
    m_eventLoopTimer = nil;
    
    [m_audioTrailOffTimer invalidate];
    
    m_audioTrailOffTimer = nil;
    
    [super dealloc];

}

- (void)startWithXmpBlob:(NSString*)xmpBlob
{
    
    if ( xmpBlob == nil )
    {
        return;
    }
    
    [m_audioController reset];
    
    // release the old song
    [m_songModel release];
    
    XmlDom * songDom = [[[XmlDom alloc] initWithXmlString:xmpBlob] autorelease];
    
    NSSong * song = [[[NSSong alloc] initWithXmlDom:songDom] autorelease];
    
    m_songModel = [[NSSongModel alloc] initWithSong:song];
    
    [m_songModel startWithDelegate:self];
    
    [self startMainEventLoop];

}

- (void)startWithUserSong:(UserSong*)userSong
{
    // TODO This function doesn't work right now because the m_xmlDom doesn't have the XMP in it
    if ( userSong == nil )
    {
        return;
    }
    
    [m_audioController reset];
    
    // release the old song
    [m_songModel release];
    
    NSSong * song = [[[NSSong alloc] initWithXmlDom:userSong.m_xmlDom] autorelease];
    
    m_songModel = [[NSSongModel alloc] initWithSong:song];
    
    [m_songModel startWithDelegate:self];
    
    [self startMainEventLoop];

}

- (void)playSong
{
    
    [self startMainEventLoop];
    
}

- (void)pauseSong
{
    
    [self stopMainEventLoop];
    
    [m_audioController stopAUGraph];
    
}

- (void)endSong
{
    
    [self stopMainEventLoop];
    
    [m_audioController stopAUGraph];
    [m_audioController reset];
    
    [m_songModel release];

    m_songModel = nil;
    
}

- (void)observeGtarController:(GtarController*)gtarController
{
    
    m_gtarController = [gtarController retain];
    
    // Register ourself as an observer
    [m_gtarController addObserver:self];
    
    [m_gtarController turnOffAllEffects];
    [m_gtarController turnOffAllLeds];
    
}

- (void)ignoreGtarController:(GtarController*)gtarController
{
    
    [m_gtarController turnOffAllEffects];
    [m_gtarController turnOffAllLeds];
    
    // Remove ourself as an observer
    [m_gtarController removeObserver:self];
    
    [m_gtarController release];
    
    m_gtarController = nil;
    
}

- (void)startMainEventLoop
{
    
    if ( m_songModel.m_percentageComplete >= 1.0 )
    {
        return;
    }
    
    [m_eventLoopTimer invalidate];
    
    m_eventLoopTimer = nil;
	
    [m_audioTrailOffTimer invalidate];
    
    m_audioTrailOffTimer = nil;
    
    [m_audioController startAUGraph];
    
	m_eventLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)SECONDS_PER_EVENT_LOOP target:self selector:@selector(mainEventLoop) userInfo:nil repeats:TRUE];
    
}

- (void)stopMainEventLoop
{
	if ( m_eventLoopTimer != nil )
	{
        
		[m_eventLoopTimer invalidate];
		
		m_eventLoopTimer = nil;

	}
}

- (void)audioTrailOffEvent
{
    
    [m_audioTrailOffTimer invalidate];
    
    m_audioTrailOffTimer = nil;
    
    [m_audioController stopAUGraph];
    [m_audioController reset];

}
- (void)mainEventLoop
{
	[m_songModel incrementTimeSerialAccess:SECONDS_PER_EVENT_LOOP];
}

#pragma mark - GuitarControllerObserver

- (void)gtarNoteOn:(GtarPluck)pluck
{
    
    GtarFret fret = pluck.position.fret;
    GtarString str = pluck.position.string;
    
    GtarPluckVelocity velocity = pluck.velocity;
    
    //[m_audioController PluckString:str-1 atFret:fret withAmplitude:(float)velocity/127.0f];
    
}

#pragma mark - NSSongModel delegate

- (void)songModelEnterFrame:(NSNoteFrame*)frame
{
    for ( NSNote * note in frame.m_notes )
    {
        if ( note.m_fret == GTAR_GUITAR_FRET_MUTED )
        {
            [m_audioController PluckMutedString:note.m_string-1];
        }
        else
        {
            [m_audioController PluckString:note.m_string-1 atFret:note.m_fret];
            
            //[m_gtarController turnOnLedAtPosition:GtarPositionMake(note.m_fret, note.m_string) withColor:GtarLedColorMake(GtarMaxLedIntensity, GtarMaxLedIntensity, GtarMaxLedIntensity)];
            
            //[self performSelector:@selector(delayedTurnLedOff:) withObject:note afterDelay:0.1];
        }
    }
}

- (void)songModelExitFrame:(NSNoteFrame*)frame
{

}

- (void)delayedTurnLedOff:(NSNote *)note
{
    [m_gtarController turnOffLedAtPosition:GtarPositionMake(note.m_fret, note.m_string)];
}

- (void)songModelNextFrame:(NSNoteFrame*)frame
{
    [m_gtarController turnOffAllLeds];
    for ( NSNote * note in frame.m_notes )
    {
        if ( note.m_fret == GTAR_GUITAR_FRET_MUTED )
        {
            [m_gtarController turnOnLedAtPositionWithColorMap:GtarPositionMake(0, note.m_string)];
        }
        else
        {
            [m_gtarController turnOnLedAtPositionWithColorMap:GtarPositionMake(note.m_fret, note.m_string)];
        }
    }
}

- (void)songModelFrameExpired:(NSNoteFrame*)frame
{
    
    
}

- (void)songModelEndOfSong
{
    [m_gtarController turnOffAllLeds];
    
    [self stopMainEventLoop];
    
    m_audioTrailOffTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(audioTrailOffEvent) userInfo:nil repeats:NO];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SongPlayBackEnded"
     object:self userInfo:nil];
}

#pragma mark - Misc

- (void)seekToLocation:(double)percentComplete
{
        
    // not sure if percentComplete is the most intuitive
    // parameter to seek on, but worth trying it out.
    
    double newBeat;
    
    if ( percentComplete < 0.01 )
    {
        
        // reset to the beginning at this point
        newBeat = 0;
        
    }
    else if ( percentComplete > 1.0 )
    {
        
        newBeat = 1.0;
        
    }
    else
    {
        
        newBeat= m_songModel.m_lengthBeats * percentComplete;
        
    }
    
    [m_songModel changeBeatRandomAccess:newBeat];
    
}

- (BOOL)isPlaying
{
    
    if ( m_eventLoopTimer != nil )
    {
        return true;
    }
    else
    {
        return false;
    }
    
}

- (double)percentageComplete
{
    return m_songModel.m_percentageComplete;
}

@end
