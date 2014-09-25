//
//  NSSongModel.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "NSSongModel.h"

#import "NSNote.h"
#import "NSSong.h"


@implementation NSSongModel

@synthesize m_song;
@synthesize m_beatsPerSecond;
@synthesize m_currentBeat;
@synthesize m_percentageComplete;
@synthesize m_lengthBeats;
@synthesize m_lengthSeconds;
@synthesize m_startBeat;
@synthesize m_endBeat;

#define SONG_MODEL_NOTE_FRAME_WIDTH (1.0 / 50.0)

#define SCROLLING_BEATS_PER_SECOND 1.0
#define LOOP_GAP 2.0

#define MIN_BEATS 4.0

- (id)initWithSong:(NSSong*)song andInstruments:(NSArray *)instruments
{
    
    if ( song == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        m_song = song;
     
        m_loops = 0;
        
        m_instruments = instruments;
        
        [self calculateBeatLength];
        
    }
    
    return self;
    
}

- (void)calculateBeatLength
{
    m_lengthBeats = MIN_BEATS;
    
    for(NSTrack * track in m_song.m_tracks){
        
        for(NSClip * clip in track.m_clips){
            
            for(NSNote * note in clip.m_notes){
                m_lengthBeats = MAX(m_lengthBeats,note.m_beatstart + note.m_duration);
            }
        }
    }
}

- (void)startWithDelegate:(id)delegate
{
    [self startWithDelegate:delegate andBeatOffset:-0.97 fastForward:NO isScrolling:NO withTempoPercent:1.0 fromStart:0 toEnd:-1 withLoops:0];
}

- (void)startWithDelegate:(id)delegate
            andBeatOffset:(double)beats
              fastForward:(BOOL)ffwd
              isScrolling:(BOOL)isScrolling
         withTempoPercent:(double)tempoPercent
                fromStart:(double)start
                    toEnd:(double)end
                withLoops:(int)loops
{
    
    m_delegate = delegate;
    
    m_loops = loops;
    
    // Then set start and end
    [self setStartBeat:start*m_lengthBeats];
    
    end = (end < start) ? 1.0 : end;
    
    [self setEndBeat:end * m_lengthBeats];
    
    // Control the tempo throughout Standalone
    if(isScrolling) {
        m_beatsPerSecond = MIN((m_song.m_tempo * 0.75f) / 60.0, SCROLLING_BEATS_PER_SECOND);
        m_beatsPerSecond *= tempoPercent;
    }
    else {
        m_beatsPerSecond = m_song.m_tempo / 60.0;
    }
    
    m_lengthSeconds = m_lengthBeats / m_beatsPerSecond;
    
    if ( m_lengthBeats == 0 )
    {
        // this is an empty song
        m_percentageComplete = 1.0;
        [self loopSongOrEndSong];
    }
    else
    {
        // gets things bootstrapped
        [self changeBeatRandomAccess:beats];
    }
    
}

- (double)getFirstAudibleBeat:(NSArray *)notesArray
{
    if([notesArray count] > 0){
        
        NSNote * note = [notesArray objectAtIndex:0];
        
        return note.m_beatstart;
    }
    
    return 0;
}

- (void)incrementBeatSerialAccess:(double)delta
{
    
    m_currentBeat += delta;
    
    m_percentageComplete = m_currentBeat / m_lengthBeats;
    
    if ( m_percentageComplete < 0.0 )
    {
        m_percentageComplete = 0.0;
    }
    if ( m_percentageComplete >= 1.0 )
    {
        m_percentageComplete = 1.0;
        [self loopSongOrEndSong];
    }
    
    [self checkFrames];
    
}

- (double)incrementTimeSerialAccess:(double)delta
{
    m_currentBeat += (delta * m_beatsPerSecond);
    m_percentageComplete = m_currentBeat / m_lengthBeats;
    
    if ( m_percentageComplete < 0.0 )
        m_percentageComplete = 0.0;
    
    if ( m_percentageComplete >= 1.0 ) {
        m_percentageComplete = 1.0;
        [self loopSongOrEndSong];
    }
    
    [self checkFrames];
    
    return m_currentBeat;
    
}

- (void)changeBeatRandomAccess:(double)beat {
    m_currentBeat = beat;
    m_percentageComplete = m_currentBeat / m_lengthBeats;
    
    if ( m_percentageComplete < 0.0 )
        m_percentageComplete = 0.0;
    
    if ( m_percentageComplete >= 1.0 ) {
        m_percentageComplete = 1.0;
        [self loopSongOrEndSong];
    }
}

- (void)changePercentageComplete:(double)percentage
{
    
    double beat = percentage * m_lengthBeats;
    
    [self changeBeatRandomAccess:beat];
    
}

- (void)checkFrames
{
    for(NSTrack * track in m_song.m_tracks){
    
        // Get corresponding instrument
        NSTrack * instTrack;
        for(NSTrack * t in m_instruments){
            if([t.m_name isEqualToString:track.m_name]){
                instTrack = t;
                break;
            }
        }
        
        if(instTrack == nil){
            continue;
        }
        
        for(NSClip * clip in track.m_clips){
            
            if(!clip.m_muted){
                for(NSNote * note in clip.m_notes){
                    
                    if(m_currentBeat >= note.m_beatstart - SONG_MODEL_NOTE_FRAME_WIDTH && m_currentBeat <= note.m_beatstart + SONG_MODEL_NOTE_FRAME_WIDTH){
                        
                        [instTrack.m_instrument.m_sampler.audio pluckString:note.m_stringvalue];
                        
                    }
                }
            }
        }
    }
}

- (void)loopSongOrEndSong
{
    [m_delegate songModelEndOfSong];
}

- (void)setStartBeat:(double)start
{
    m_startBeat = start;
    
    //[self changeBeatRandomAccess:m_startBeat];
}

- (void)setEndBeat:(double)end
{
    m_endBeat = end;
}

@end
