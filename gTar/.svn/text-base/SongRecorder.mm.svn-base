//
//  SongRecorder.m
//  gTar
//
//  Created by Marty Greenia on 1/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "SongRecorder.h"


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
		if ( tempo == 0 )
		{
			return nil;
		}
		
		m_isRecording = NO;
		m_tempo = tempo; // bpm
		
	}
	
	return self;	
}

- (void)beginSong
{
	if ( m_song != NULL )
	{
		delete m_song;
	}
	
	m_currentBeat = 0;
	m_currentTime = 0;
	m_isRecording = YES;
}

- (void)finishSong
{
	m_isRecording = NO;
	
	CNote * currentNote;
	currentNote = m_notes;

	// Create and fill up the song object
	m_song = new CSong();
	
	m_song->m_tempo = m_tempo;
	
	double absoluteBeatTime = 0;
	
	while ( currentNote != NULL )
	{
		CMeasure * measure = new CMeasure();
		
		measure->m_startBeat = absoluteBeatTime;
		measure->m_beatCount = 4;
		measure->m_beatValue = 1;

		// Add all the notes that fall within this measure.
		// No notes have to be added if there aren't any.
		while ( currentNote != NULL && currentNote->m_absoluteBeatStart < (absoluteBeatTime + 4) )
		{
			currentNote->m_measureStart = (currentNote->m_absoluteBeatStart - absoluteBeatTime) + 1;

			CNote * nextNote = currentNote->m_next;

			measure->AddNote( currentNote );
			
			currentNote = nextNote;
		}
		
		absoluteBeatTime += 4;
		
		measure->SortNotes();
		m_song->AddMeasure( measure );
	}
	
	m_song->SortMeasures();
	
}

- (void)advanceRecordingByTimeDelta:(double)delta
{
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
	CNote * note = new CNote();
	
	note->m_absoluteBeatStart = m_currentBeat;
	
	note->m_string = str;
	note->m_fret = fret;
	
	note->m_duration = 0.50;

	[self convertNoteValueString:str andFret:fret inValue:note->m_value];
	
	if ( m_notes == NULL )
	{
		m_notes = note;
		m_notesTail = note;
	}
	else 
	{
		m_notesTail->m_next = note;
		m_notesTail = note;
	}
	
}

- (double)convertTimeToBeat:(double)time
{
	return (time * (m_tempo/60.0));
}

- (void)convertNoteValueString:(char)str andFret:(char)fret inValue:(char*)value
{
	
	int midiValue = StringToMidiMap[ str ] + fret;
	
	// Base the midi number line at zero
	int normalizedMidiValue = midiValue - MidiBaseValue;
	
	int octaveNumber = normalizedMidiValue / 12;
	int noteNumber = normalizedMidiValue % 12;
	
	char * noteName = (char*)NoteNumberToNoteNameMap[ noteNumber ];
	
	sprintf( value, "%s%d\0", noteName, octaveNumber );
	
}

@end
