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
#import "NSMeasure.h"

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
@synthesize m_startBeat;
@synthesize m_endBeat;

#define SONG_MODEL_NOTE_FRAME_WIDTH (0.2f) // beats, see also PlayViewController
#define SONG_MODEL_NOTE_FRAME_WIDTH_MAX (0.2f)

#define SCROLLING_BEATS_PER_SECOND 1.0
#define LOOP_GAP 0.0

#define RESTRICTFRAME_PREVIEW_BEATS 0.5

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
        
        m_loops = 0;
        
        NSArray * notesArray = [m_song getSortedNotes];
        
        // First set length of beats
        for ( NSNote * note in notesArray )
        {
            m_lengthBeats = MAX(m_lengthBeats,note.m_absoluteBeatStart + note.m_duration);
        }
        
        
    }
    
    return self;
    
}

- (void)dealloc
{
    [m_frameTimer invalidate];
    
    m_frameTimer = nil;
}

- (void)clearData
{
    [m_frameTimer invalidate];
    m_frameTimer = nil;
    
    [m_noteFramesPlayed removeAllObjects];
    m_noteFramesPlayed = nil;
    
    [m_noteFramesRemaining removeAllObjects];
    m_noteFramesRemaining = nil;
}

- (void)startWithDelegate:(id)delegate
{
    [self startWithDelegate:delegate andBeatOffset:0 fastForward:NO isScrolling:NO withTempoPercent:1.0 fromStart:0 toEnd:-1 withLoops:0];
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
    
    // clear remnants from last song
    m_currentFrame = nil;
    m_noteFrames = [[NSMutableArray alloc] init];
    m_noteFramesPlayed = [[NSMutableArray alloc] init];
    m_delegate = delegate;
    NSArray * notesArray = [m_song getSortedNotes];
    NSNoteFrame * noteFrame = nil;
    
    m_loops = loops;
    
    // First set length of beats
    //for ( NSNote * note in notesArray )
    //{
    //    m_lengthBeats = MAX(m_lengthBeats,note.m_absoluteBeatStart + note.m_duration);
    //}
    
    // Then set start and end
    double beatsPerMeasure = [[m_song.m_measures firstObject] m_beatCount];
    
    double startbeat = floorf(start*m_lengthBeats / beatsPerMeasure) * beatsPerMeasure;
    
    [self setStartBeat:startbeat];
    
    end = (end < start) ? 1.0 : end;
    
    double endbeat = ceilf(end*m_lengthBeats / beatsPerMeasure) * beatsPerMeasure;
    
    [self setEndBeat:endbeat];
    
    NSLog(@"Beats per measure is %f | startbeat is %f | endbeat is %f",beatsPerMeasure,startbeat,endbeat);
    
    // Detect first audible beat
    double firstAudibleBeat = [self getFirstAudibleBeat:notesArray];
    if(ffwd){
        beats += firstAudibleBeat;
    }
    
    // Sort the notes into note frames
    m_lengthBeats = 0;
    
    NSNote * firstNote = [notesArray firstObject];
    NSNote * lastNote = [notesArray lastObject];
//    double lastNoteGap = lastNote.m_absoluteBeatStart - floor(lastNote.m_absoluteBeatStart);
    
    widthGap = (m_endBeat - m_startBeat) - floor(m_endBeat - m_startBeat);
    firstNoteGap = ceil(firstNote.m_absoluteBeatStart) - firstNote.m_absoluteBeatStart;
    
    for( int l = 0; l <= loops; l++ ){
        for ( NSNote * note in notesArray )
        {
            if(note.m_absoluteBeatStart < m_endBeat && note.m_absoluteBeatStart-firstAudibleBeat >= m_startBeat){
                
                double timedNoteStart = (note.m_absoluteBeatStart - m_startBeat) + l*(m_endBeat - m_startBeat) + l*LOOP_GAP - l*widthGap + firstNoteGap;
                
                // firstAudibleBeat
                
                if ( noteFrame == nil ||
                    (timedNoteStart - noteFrame.m_absoluteBeatStart) > m_frameWidthBeats ) {
                    noteFrame = [[NSNoteFrame alloc] initWithStart:timedNoteStart andDuration:m_frameWidthBeats];
                    [m_noteFrames addObject:noteFrame];
                }
                
                NSNote * timedNote = [[NSNote alloc] initWithDuration:note.m_duration andValue:note.m_value andMeasureStart:note.m_measureStart andAbsoluteBeatStart:timedNoteStart andKey:note.m_key];
                
                [noteFrame addNote:timedNote];
                
                double noteEnd = timedNoteStart + note.m_duration;
                
                if ( noteEnd > m_lengthBeats )
                    m_lengthBeats = noteEnd;
            }
        }
    }
    
    [self sortNotesInNoteFrames];
    
    // Control the tempo throughout Standalone
    if(isScrolling) {
        m_beatsPerSecond = MIN((m_song.m_tempo * 0.75f) / 60.0, SCROLLING_BEATS_PER_SECOND);
        m_beatsPerSecond *= tempoPercent;
        //m_beatsPerSecond = SCROLLING_BEATS_PER_SECOND * tempoPercent;
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

- (void)skipToNextFrame
{
    // skip over all time between now and the next frame
    if ( m_nextFrame != nil )
    {
        double delta = m_nextFrame.m_absoluteBeatStart - m_currentBeat;
        
        [self incrementBeatSerialAccess:delta isRestrictFrame:NO];
    }
    else
    {
        [self loopSongOrEndSong];
    }
}

- (double)getFirstAudibleBeat:(NSArray *)notesArray
{
    if([notesArray count] > 0){
        
        NSNote * note = [notesArray objectAtIndex:0];
        
        return note.m_absoluteBeatStart;
    }
    
    return 0;
    
    /*if([m_noteFrames count] > 0){
        
        NSNoteFrame * nextFrame = [m_noteFrames objectAtIndex:0];
        NSNoteFrame * impliedNextFrame = m_nextFrame;
        
        if(nextFrame != nil){
            return nextFrame.m_absoluteBeatStart;
        }else{
            return 0;
        }
        
    }else{
        return 0;
    }*/
}

- (void)incrementBeatSerialAccess:(double)delta isRestrictFrame:(BOOL)restrictFrame
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
    
    [self checkFrames:restrictFrame];
    
}

- (double)incrementTimeSerialAccess:(double)delta isRestrictFrame:(BOOL)restrictFrame
{
    
    m_currentBeat += (delta * m_beatsPerSecond);
    m_percentageComplete = m_currentBeat / m_lengthBeats;
    
    if ( m_percentageComplete < 0.0 )
        m_percentageComplete = 0.0;
    
    if ( m_percentageComplete >= 1.0 ) {
        m_percentageComplete = 1.0;
        [self loopSongOrEndSong];
    }
    
    [self checkFrames:restrictFrame];
    
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
//        [self loopSongOrEndSong];
    }
    
}

- (void)changePercentageComplete:(double)percentage
{
    
    double beat = percentage * m_lengthBeats;
    
    [self changeBeatRandomAccess:beat];
    
}

- (void)checkFrames:(BOOL)restrictFrame
{
    
    if ( m_currentFrame != nil )
    {
        
        double beatEnd = m_currentFrame.m_absoluteBeatStart;
        
        // Check if we've passed the end of this frame
        if ( m_currentBeat > (beatEnd + SONG_MODEL_NOTE_FRAME_WIDTH_MAX/2.0) )
        {
            [self exitCurrentFrame];
        }
        
    }

    if ( m_nextFrame != nil )
    {
        
        double beatStart = m_nextFrame.m_absoluteBeatStart;

        if ( (!restrictFrame && m_currentBeat >= (beatStart - m_frameWidthBeats/2.0))
            || (restrictFrame && m_currentBeat + RESTRICTFRAME_PREVIEW_BEATS >= (beatStart - m_frameWidthBeats/2.0) && m_currentFrame == nil))
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

    [m_noteFramesPlayed addObject:m_currentFrame];
    
    m_currentFrame = nil;

}

- (void)enterCurrentFrame
{
    
    m_currentFrame = m_nextFrame;
    
    m_nextFrame = nil;
    
    [m_delegate songModelEnterFrame:m_currentFrame];
    
}

- (void)beginFrameTimer:(double)delta
{

    if ( m_frameTimer != nil )
    {
        DLog(@"Begin new timer, invalidate old %@", m_frameTimer);
        [m_frameTimer invalidate];
    }
    
    m_frameTimer = [NSTimer scheduledTimerWithTimeInterval:delta target:self selector:@selector(frameExpired) userInfo:nil repeats:NO];

}

- (void)frameExpired
{
    
    DLog(@"Frame timer expired!");
    [m_frameTimer invalidate];
    
    m_frameTimer = nil;
    
    [m_delegate songModelFrameExpired:m_currentFrame];
    
}

- (void)loopSongOrEndSong
{
    [m_delegate songModelEndOfSong];
}

- (int)getCurrentLoop
{
    // Song length
    NSNoteFrame  * lastNoteFrame = [m_noteFrames lastObject];
    NSNote * lastNote = [lastNoteFrame.m_notes lastObject];
    
    double numBeats = lastNote.m_absoluteBeatStart + lastNote.m_duration;
    
    int currentLoop = (m_currentBeat / numBeats) * (m_loops+1);
    
    return currentLoop;
}

- (int)getLoopForBeat:(double)beat
{
    // Song length
    NSNoteFrame  * lastNoteFrame = [m_noteFrames lastObject];
    NSNote * lastNote = [lastNoteFrame.m_notes lastObject];
    
    double numBeats = lastNote.m_absoluteBeatStart + lastNote.m_duration;
    
    int beatLoop = (beat / numBeats) * (m_loops+1);
    
    return beatLoop;
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

- (void)setSongLoops:(int)loops
{
    m_loops = loops;
}


- (NSDictionary *)getMinAndMaxNotesForSurroundingFrames
{
    KeyPosition maxNote = 0;
    KeyPosition minNote = KEYS_KEY_COUNT;
    
    // Check upcoming frames
    for(int i = 0; i < FRAME_LOOKAHEAD; i++){
        
        if([m_noteFramesRemaining count] <= i){
            break;
        }
        
        NSNoteFrame * nf = [m_noteFramesRemaining objectAtIndex:i];
        
        for(NSNote * note in nf.m_notes){
            
            //if([g_keysMath noteOutOfDisplayRange:note.m_key]){
            if(![g_keysMath noteOutOfRange:note.m_key]){
            
                // Offset by i to make difference less significant if further away
                maxNote = MAX(maxNote,note.m_key-fabs(note.m_key-maxNote)*0.25*i);
                minNote = MIN(minNote,note.m_key+fabs(minNote-note.m_key)*0.25*i);
            }
            
        }
        
    }
   
    // Check played frames
    
    for(int i = 0; i < FRAME_LOOKBACK; i++){
        
        if([m_noteFramesPlayed count] <= i){
            continue;
        }
        
        NSNoteFrame * nf = [m_noteFramesPlayed objectAtIndex:([m_noteFramesPlayed count]-i-1)];
        
        for(NSNote * note in nf.m_notes){
            
            if(![g_keysMath noteOutOfRange:note.m_key]){
                
                maxNote = MAX(maxNote,note.m_key-fabs(note.m_key-maxNote)*0.25*i);
                minNote = MIN(minNote,note.m_key+fabs(minNote-note.m_key)*0.25*i);
            }
            
        }
        
    }
    
    // Also check current frame and next frame
    for(NSNote * note in m_currentFrame.m_notes){
        
        if(![g_keysMath noteOutOfRange:note.m_key]){
            
            maxNote = MAX(maxNote,note.m_key);
            minNote = MIN(minNote,note.m_key);
        }
    }
    
    for(NSNote * note in m_nextFrame.m_notes){
        
        if(![g_keysMath noteOutOfRange:note.m_key]){
            
            maxNote = MAX(maxNote,note.m_key);
            minNote = MIN(minNote,note.m_key);
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:minNote],@"Min",[NSNumber numberWithInt:maxNote],@"Max", nil];
}

- (void)sortNotesInNoteFrames
{
    for(NSNoteFrame * noteFrame in m_noteFrames){
        
        [noteFrame sortNotesByKey];
        
    }
}

@end
