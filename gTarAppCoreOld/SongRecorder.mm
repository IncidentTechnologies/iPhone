//
//  SongRecorder.m
//  gTar
//
//  Created by Marty Greenia on 1/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "SongRecorder.h"

#import "NSSong.h"
#import "NSMeasure.h"
#import "NSNote.h"

// a quarter beat
#define GTAR_DEFAULT_NOTE_DURATION 0.25f
#define GTAR_DEFAULT_SONG_ID (-1)
#define GTAR_DEFAULT_SONG_TEMPO 120

#define GTAR_DEFAULT_MEASURE_BEAT_VALUE 1
#define GTAR_DEFAULT_MEASURE_BEAT_COUNT	4

@implementation SongRecorder

@synthesize m_song;
@synthesize m_isRecording;
@synthesize m_currentTime;

- (SongRecorder*)init
{
	if ( self = [super init] )
	{
		m_tempo = 120; // bpm
		m_isRecording = NO;
	}
	
	return self;
}

- (SongRecorder*)initWithTempo:(double)tempo
{
	if ( self = [super init] )
	{

		m_isRecording = NO;
        
        if ( tempo == 0 )
		{
			m_tempo = 120;
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

	[m_notes release];
	
	m_notes = [[NSMutableArray alloc] init];
	
	m_currentBeat = 0;
	m_currentTime = 0;
	m_isRecording = YES;
}

- (void)finishSong
{
	
	m_isRecording = NO;

    [m_song release];
    
	m_song = [[NSSong alloc] initWithAuthor:@"gTarUser"
								   andTitle:@"gTarSong"
									andDesc:@"Recorded on a gTar"
									  andId:GTAR_DEFAULT_SONG_ID
								   andTempo:m_tempo];
	
	double measureStartBeat = 0;

	unsigned int index = 0;
	
	while ( index < [m_notes count] )
	{

		NSMeasure * measure = [[NSMeasure alloc] initWithStartBeat:measureStartBeat
													  andBeatCount:GTAR_DEFAULT_MEASURE_BEAT_COUNT
													  andBeatValue:GTAR_DEFAULT_MEASURE_BEAT_VALUE ];
		
		NSNote * currentNote = [m_notes objectAtIndex:index];

		// Add all the notes that fall within this measure.
		while ( currentNote.m_absoluteBeatStart < (measureStartBeat + GTAR_DEFAULT_MEASURE_BEAT_COUNT) )
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
		
		measureStartBeat += GTAR_DEFAULT_MEASURE_BEAT_COUNT;
		
		[m_song addMeasure:measure];
        
        [measure release];

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

- (void)playString:(char)str andFret:(char)fret
{

	char value[8];
    
	[self convertNoteValueString:str andFret:fret inValue:value];
	
	NSNote * note = [[NSNote alloc] initWithDuration:GTAR_DEFAULT_NOTE_DURATION
											andValue:[NSString stringWithFormat:@"%s", value]
									 andMeasureStart:0
								andAbsoluteBeatStart:m_currentBeat
										   andString:str
											 andFret:fret];
	[m_notes addObject:note];
	
	[note release];

}

- (double)convertTimeToBeat:(double)time
{
	return (time * (m_tempo/60.0));
}

- (void)convertNoteValueString:(char)str andFret:(char)fret inValue:(char*)value
{
	
    // this receives one-based strings but the math uses 0 based
    str--;

	int midiValue = StringToMidiMap[ str ] + fret;
	
	// Base the midi number line at zero
	int normalizedMidiValue = midiValue - MidiBaseValue;
	
	int octaveNumber = normalizedMidiValue / 12;
	int noteNumber = normalizedMidiValue % 12;
	
	char * noteName = (char*)NoteNumberToNoteNameMap[ noteNumber ];
	
	sprintf( value, "%s%d", noteName, octaveNumber );
	
}

@end
