//
//  KeysSongRecorder.m
//  keysPlay
//
//  Created by Kate Schnippering on 11/24/14.
//
//

#import "KeysSongRecorder.h"


// a quarter beat
#define DEFAULT_NOTE_DURATION 0.25f
#define DEFAULT_SONG_ID (-1)
#define DEFAULT_SONG_TEMPO 120

#define DEFAULT_MEASURE_BEAT_VALUE 1
#define DEFAULT_MEASURE_BEAT_COUNT	4

@implementation KeysSongRecorder

@synthesize m_song;
@synthesize m_isRecording;
@synthesize m_currentTime;

- (KeysSongRecorder*)init
{
    if ( self = [super init] )
    {
        m_tempo = DEFAULT_SONG_TEMPO; // bpm
        m_isRecording = NO;
    }
    
    return self;
}

- (KeysSongRecorder*)initWithTempo:(double)tempo
{
    if ( self = [super init] )
    {
        
        m_isRecording = NO;
        
        if ( tempo == 0 )
        {
            m_tempo = DEFAULT_SONG_TEMPO;
        }
        else
        {
            m_tempo = tempo; // bpm
        }
        
    }
    
    return self;
}


- (void)beginSong
{
    m_notes = [[NSMutableArray alloc] init];
    
    m_currentBeat = 0;
    m_currentTime = 0;
    m_isRecording = YES;
}

- (void)pauseRecording
{
    m_isRecording = NO;
}

- (void)continueRecording
{
    m_isRecording = YES;
}

- (void)finishSong
{
    
    m_isRecording = NO;
    
    
    m_song = [[NSSong alloc] initWithAuthor:@"keysUser"
                                   andTitle:@"keysSong"
                                    andDesc:@"Recorded with Keys"
                                      andId:DEFAULT_SONG_ID
                                   andTempo:m_tempo];
    
    double measureStartBeat = 0;
    
    unsigned int index = 0;
    
    while ( index < [m_notes count] )
    {
        
        NSMeasure * measure = [[NSMeasure alloc] initWithStartBeat:measureStartBeat
                                                      andBeatCount:DEFAULT_MEASURE_BEAT_COUNT
                                                      andBeatValue:DEFAULT_MEASURE_BEAT_VALUE ];
        
        NSNote * currentNote = [m_notes objectAtIndex:index];
        
        // Add all the notes that fall within this measure.
        while ( currentNote.m_absoluteBeatStart < (measureStartBeat + DEFAULT_MEASURE_BEAT_COUNT) )
        {
            
            currentNote.m_measureStart = (currentNote.m_absoluteBeatStart - measureStartBeat) + 1;
            
            [measure addNote:currentNote];
            
            index++;
            
            if ( index >= [m_notes count] )
            {
                break;
            }
            
            currentNote = [m_notes objectAtIndex:index];
            
        }
        
        measureStartBeat += DEFAULT_MEASURE_BEAT_COUNT;
        
        [m_song addMeasure:measure];
        
        
    }
    
}

- (void)advanceRecordingByTimeDelta:(double)delta
{
    if ( m_isRecording == NO )
    {
        return;
    }
    
    double beatDelta = [self convertTimeToBeat:delta];
    
    m_currentBeat += beatDelta;
    m_currentTime += delta;
    
    if ( m_currentBeat > MAX_RECORDING_LENGTH )
    {
        [self finishSong];
    }
}

- (void)advanceRecordingToTime:(double)time
{
    if ( m_isRecording == NO )
    {
        return;
    }
    
    double beat = [self convertTimeToBeat:time];
    
    m_currentBeat = beat;
    m_currentTime = time;
    
    if ( m_currentBeat > MAX_RECORDING_LENGTH )
    {
        [self finishSong];
    }
}

- (void)pressKey:(KeyPosition)key
{
    if ( m_isRecording == NO )
    {
        return;
    }
    
    char value[8];
    
    [self convertNoteValueKey:key inValue:value];
    
    NSNote * note = [[NSNote alloc] initWithDuration:DEFAULT_NOTE_DURATION andValue:[NSString stringWithFormat:@"%s",value] andMeasureStart:0 andAbsoluteBeatStart:m_currentBeat andKey:key];
    
    [m_notes addObject:note];
    
}

- (double)convertTimeToBeat:(double)time
{
    return (time * (m_tempo/60.0));
}

- (void)convertNoteValueKey:(int)key inValue:(char*)value
{
    // this receives one-based strings but the math uses 0 based

    // Base the midi number line at zero
    int normalizedMidiValue = key;// - MidiBaseValue;
    
    int octaveNumber = normalizedMidiValue / 12;
    int noteNumber = normalizedMidiValue % 12;
    
    char * noteName = (char*)NoteNumberToNoteNameMap[ noteNumber ];
    
    sprintf( value, "%s%d", noteName, octaveNumber );
    
    DLog(@"Key %i converts to value %s",key,value);
    
}

@end
