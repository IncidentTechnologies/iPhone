//
//  NSSongModel.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "NSSongModel.h"

#import "NSNoteFrame.h"
#import "NSNote.h"
#import "NSSong.h"

@implementation NSSongModel

@synthesize m_song;
@synthesize m_currentFrame;
@synthesize m_nextFrame;
@synthesize m_beatsPerSecond;
@synthesize m_currentBeat;
@synthesize m_percentageComplete;
@synthesize m_noteFrames;
@synthesize m_lengthBeats;
@synthesize m_lengthSeconds;
@synthesize m_frameWidthBeats;

#define SONG_MODEL_NOTE_FRAME_WIDTH (0.2f) // beats, see also PlayViewController
#define SONG_MODEL_NOTE_FRAME_WIDTH_MAX (0.2f)
#define STANDALONE_BEATS_PER_SECOND 42/60.0

//- (id)initWithSongXmp:(NSString*)xmpBlob
//{
//    
//}

- (id)initWithSong:(NSSong*)song
{
    
    if ( song == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_song = song;
        
        m_frameWidthBeats = SONG_MODEL_NOTE_FRAME_WIDTH;

    }
    
    return self;
    
}

- (void)dealloc
{

    
    [m_frameTimer invalidate];
    
    m_frameTimer = nil;

    
}

- (void)startWithDelegate:(id)delegate
{
    [self startWithDelegate:delegate andBeatOffset:0 fastForward:NO isStandalone:NO];
}

- (void)startWithDelegate:(id)delegate andBeatOffset:(double)beats fastForward:(BOOL)ffwd isStandalone:(BOOL)standalone
{
    // clear remnants from last song

    m_currentFrame = nil;
    
    m_delegate = delegate;
    
    m_noteFrames = [[NSMutableArray alloc] init];
    
    NSArray * notesArray = [m_song getSortedNotes];
    
    NSNoteFrame * noteFrame = nil;
    
    m_lengthBeats = 0;
    
    // sort the notes into note frames
    for ( NSNote * note in notesArray )
    {
        
        if ( noteFrame == nil ||
            (note.m_absoluteBeatStart - noteFrame.m_absoluteBeatStart) > m_frameWidthBeats )
        {
            
            noteFrame = [[NSNoteFrame alloc] initWithStart:note.m_absoluteBeatStart andDuration:m_frameWidthBeats];
            
            [m_noteFrames addObject:noteFrame];
            
            
        }
        
        [noteFrame addNote:note];
                
        double noteEnd = note.m_absoluteBeatStart + note.m_duration;
        
        if ( noteEnd > m_lengthBeats )
        {
            m_lengthBeats = noteEnd;
        }
        
    }
    
    // Control the tempo throughout Standalone
    if(standalone){
    
        m_beatsPerSecond = STANDALONE_BEATS_PER_SECOND;
    
    }else{
        
        m_beatsPerSecond = m_song.m_tempo / 60.0;
        
    }
    
    m_lengthSeconds = m_lengthBeats / m_beatsPerSecond;
    
    if(ffwd){
        
        double firstAudibleBeat = [self getFirstAudibleBeat];
        beats = beats + firstAudibleBeat;
        
    }
    
    if ( m_lengthBeats == 0 )
    {
        // this is an empty song
        m_percentageComplete = 1.0;
        [m_delegate songModelEndOfSong];
    }
    else
    {
        // gets things bootstrapped
        [self changeBeatRandomAccess:beats];
    }

}

- (void)skipToNextFrame
{
    // skip over all time between now and the next frame
    if ( m_nextFrame != nil )
    {
        double delta = m_nextFrame.m_absoluteBeatStart - m_currentBeat;
        
        [self incrementBeatSerialAccess:delta];
    }
    else
    {
        [m_delegate songModelEndOfSong];
    }
}

- (double)getFirstAudibleBeat
{
    if([m_noteFrames count] > 0){
        
        NSNoteFrame * nextFrame = [m_noteFrames objectAtIndex:0];
        
        if(nextFrame != nil){
            return nextFrame.m_absoluteBeatStart;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}

//- (void)incrementBeat:(double)delta
//{
//    
//    m_currentBeat += delta;
//    
//    [self checkFrames];
//    
//}
//
//- (void)incrementTime:(double)delta
//{
//    
//    m_currentBeat += (delta * m_beatsPerSecond);
//    
//    [self checkFrames];
//    
//}
//
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
        [m_delegate songModelEndOfSong];
    }    
    
    [self checkFrames];
    
}

- (void)incrementTimeSerialAccess:(double)delta
{
    
    m_currentBeat += (delta * m_beatsPerSecond);
        
    m_percentageComplete = m_currentBeat / m_lengthBeats;
    
    if ( m_percentageComplete < 0.0 )
    {
        m_percentageComplete = 0.0;
    }
    if ( m_percentageComplete >= 1.0 )
    {
        m_percentageComplete = 1.0;
        [m_delegate songModelEndOfSong];
    }
    
    [self checkFrames];
    
}

- (void)changeBeatRandomAccess:(double)beat
{
    
    m_currentBeat = beat;
    
    m_percentageComplete = m_currentBeat / m_lengthBeats;
    
    if ( m_percentageComplete < 0.0 )
    {
        m_percentageComplete = 0.0;
    }
    if ( m_percentageComplete >= 1.0 )
    {
        m_percentageComplete = 1.0;
        [m_delegate songModelEndOfSong];
    }
    
    
    m_noteFramesRemaining = [[NSMutableArray alloc] init];
    
    // recreate the noteFramesRemainng array based on our new position
    for ( NSNoteFrame * noteFrame in m_noteFrames )
    {
        
        if ( noteFrame.m_absoluteBeatStart >= m_currentBeat )
        {
            [m_noteFramesRemaining addObject:noteFrame];
        }
        
    }
    
    // clear out the old current frame if it exists
    if ( m_currentFrame != nil )
    {
        
        [m_delegate songModelExitFrame:m_currentFrame];
        
        m_currentFrame = nil;
        
    }
    
    // grab the next frame off the top of the stack and run with it
    if ( [m_noteFramesRemaining count] > 0 )
    {
        
        m_nextFrame = [m_noteFramesRemaining objectAtIndex:0];
        
        [m_noteFramesRemaining removeObjectAtIndex:0];
        
        [m_delegate songModelNextFrame:m_nextFrame];
        
//        [self checkFrames];
        
    }
    else
    {
//        [m_delegate songModelEndOfSong];
    }
    
}

- (void)changePercentageComplete:(double)percentage
{
    
    double beat = percentage * m_lengthBeats;
    
    [self changeBeatRandomAccess:beat];
    
}


//- (void)changeBeat:(double)beat
//{
//    
//    m_currentBeat = beat;
//    
//    [m_noteFramesRemaining release];
//    
//    m_noteFramesRemaining = [[NSMutableArray alloc] init];
//
//    // recreate the noteFramesRemainng array based on our new position
//    for ( NSNoteFrame * noteFrame in m_noteFrames )
//    {
//        
//        if ( noteFrame.m_absoluteBeatStart >= m_currentBeat )
//        {
//            [m_noteFramesRemaining addObject:noteFrame];
//        }
//        
//    }
//    
//    // clear out the old current frame if it exists
//    if ( m_currentFrame != nil )
//    {
//        
//        [m_delegate songModelExitFrame:m_currentFrame];
//        
//        m_currentFrame = nil;
//
//    }
//    
//    // grab the next frame off the top of the stack and run with it
//    if ( [m_noteFramesRemaining count] > 0 )
//    {
//        
//        m_nextFrame = [m_noteFramesRemaining objectAtIndex:0];
//        
//        [m_noteFramesRemaining removeObjectAtIndex:0];
//        
//        [m_delegate songModelNextFrame:m_nextFrame];
//        
////        [self checkFrames];
//        
//    }
//    else
//    {
//        [m_delegate songModelEndOfSong];
//    }
//
//}

- (void)checkFrames
{
    
    // these three conditionals can both be hit no problem    
    if ( m_currentFrame != nil )
    {
//        double beatEnd = m_currentFrame.m_absoluteBeatStart + m_currentFrame.m_duration;
        double beatEnd = m_currentFrame.m_absoluteBeatStart;
        
        //
        // Check if we've passed the end of this frame
        //
        
        //if ( m_currentBeat > (beatEnd + m_frameWidthBeats/2.0) )
        if ( m_currentBeat > (beatEnd + SONG_MODEL_NOTE_FRAME_WIDTH_MAX/2.0) )
        {
            //NSLog(@"Current beat is %f, beat end is %f",m_currentBeat,(beatEnd + m_frameWidthBeats/2.0));
            [self exitCurrentFrame];
        }
        
    }

    if ( m_nextFrame != nil )
    {
        
        double beatStart = m_nextFrame.m_absoluteBeatStart;

        if ( m_currentBeat >= (beatStart - m_frameWidthBeats/2.0) )
        {
            [self enterCurrentFrame];
            
            // Also grab the next frame in line
            if ( [m_noteFramesRemaining count] > 0 )
            {
                
                m_nextFrame = [m_noteFramesRemaining objectAtIndex:0];
                
                [m_noteFramesRemaining removeObjectAtIndex:0];
                
                [m_delegate songModelNextFrame:m_nextFrame];
                
            }

        }
    
    }
        
}

- (void)exitCurrentFrame
{
    
    // cancel the timer if we are done with this frame
    [m_frameTimer invalidate];
    
    m_frameTimer = nil;

    // we are done with this frame
    
    [m_delegate songModelExitFrame:m_currentFrame];

    m_currentFrame = nil;
    
    // nothing to look forward too
//    if ( m_nextFrame == nil )
//    {
//        // otherwise we are done
//        [m_delegate songModelEndOfSong];
//    }
    
//    if ( [m_noteFramesRemaining count] > 0 )
//    {
//        
//        m_nextFrame = [m_noteFramesRemaining objectAtIndex:0];
//        
//        [m_noteFramesRemaining removeObjectAtIndex:0];
//        
//        [m_delegate songModelNextFrame:m_nextFrame];
//        
//    }

}

- (void)enterCurrentFrame
{
    
    m_currentFrame = m_nextFrame;
    
    m_nextFrame = nil;
    
    [m_delegate songModelEnterFrame:m_currentFrame];
    
//    if ( [m_noteFramesRemaining count] > 0 )
//    {
//        
//        m_nextFrame = [m_noteFramesRemaining objectAtIndex:0];
//        
//        [m_noteFramesRemaining removeObjectAtIndex:0];
//        
//        [m_delegate songModelNextFrame:m_nextFrame];
//        
//    }
    
}

- (void)beginFrameTimer:(double)delta
{

    if ( m_frameTimer != nil )
    {
        NSLog(@"Begin new timer, invalidate old %@", m_frameTimer);
        [m_frameTimer invalidate];
    }
    
    m_frameTimer = [NSTimer scheduledTimerWithTimeInterval:delta target:self selector:@selector(frameExpired) userInfo:nil repeats:NO];

}

- (void)frameExpired
{
    
    NSLog(@"Frame timer expired!");
    [m_frameTimer invalidate];
    
    m_frameTimer = nil;
    
    [m_delegate songModelFrameExpired:m_currentFrame];
    
}

@end
