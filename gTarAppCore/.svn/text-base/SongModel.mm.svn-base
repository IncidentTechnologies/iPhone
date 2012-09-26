//
//  SongModel.cpp
//  gTar
//
//  Created by Marty Greenia on 10/13/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#include "SongModel.h"
#include "gTar.h"

void SongModel::StartModelAtTime( double time )
{
	
	m_currentBeat = ConvertTimeToBeat(time);

	m_endOfSong = NO;

	UpdateTargetNotes();
	
	UpdateUpcomingNotes();
	
}

void SongModel::AdvanceModelToAbsoluteBeat( double beat )
{
	
	m_currentBeat = beat;
	
	if ( CheckEndOfSong() == YES )
	{
		return;
	}
	
	if ( m_targetNotes.m_count == 0 || !CheckTargetNotesCloseToBeat( m_targetNotes.m_index ) )
	{
		UpdateTargetNotes();
		
		UpdateUpcomingNotes();
	}
	
}

void SongModel::AdvanceModelToAbsoluteTimeSeconds( double time )
{
	if ( m_endOfSong == YES )
	{
		return;
	}
	
	m_currentBeat = ConvertTimeToBeat(time);
	
	if ( CheckEndOfSong() == YES )
	{
		return;
	}
	
	if ( m_targetNotes.m_count == 0 || !CheckTargetNotesCloseToBeat( m_targetNotes.m_index ) )
	{
		UpdateTargetNotes();
	
		UpdateUpcomingNotes();
	}
	
}

void SongModel::AdvanceModelByDeltaTimeSeconds( double deltaTime )
{
	if ( m_endOfSong == YES )
	{
		return;
	}

	m_currentBeat += ConvertTimeToBeat( deltaTime );
	
	if ( CheckEndOfSong() == YES )
	{
		return;
	}
		
	if ( m_targetNotes.m_count == 0 || !CheckTargetNotesCloseToBeat( m_targetNotes.m_index ) )
	{
		UpdateTargetNotes();
	
		UpdateUpcomingNotes();
	}
}

void SongModel::AdvanceModelToNextTargetNotes()
{
	if ( m_endOfSong == YES )
	{
		return;
	}

	m_targetNotes = FindTargetNotesFromTargetNotes( m_targetNotes );

	TranscribeTargetNotesToBytes();

	if ( m_targetNotes.m_count == 0 )
	{
		m_endOfSong = YES;
		return;
	}
	
	m_currentBeat = m_noteArray->m_notes[ m_targetNotes.m_index ].m_absoluteBeatStart;
	
	UpdateUpcomingNotes();
}

void SongModel::AdvanceModelToNextTargetNotesFromBeat()
{

	if ( m_endOfSong == YES )
	{
		return;
	}
	
	m_targetNotes = FindTargetNotesFromBeat();
	
	if ( m_targetNotes.m_count == 0 )
	{

		TranscribeTargetNotesToBytes();
		
		// Scan to find the next set of notes, if they exist
		m_targetNotes = FindUpcomingNotesFromBeat();

		if ( m_targetNotes.m_count == 0 )
		{
			m_endOfSong = YES;
			return;
		}
	}
	
	TranscribeTargetNotesToBytes();
	
	m_currentBeat = m_noteArray->m_notes[ m_targetNotes.m_index ].m_absoluteBeatStart;
	
	UpdateUpcomingNotes();
	
}

bool SongModel::CheckEndOfSong()
{
	
	// Check if we are at the end of the song
	if ( m_noteArray->m_notes[ m_noteArray->m_noteCount-1].m_absoluteBeatStart + SONG_MODEL_TARGET_NOTE_WINDOW <= m_currentBeat )
	{
		m_endOfSong = YES;
		
		m_targetNotes.m_count = 0;
		m_targetNotes.m_index = 0;
		m_upcomingNotes.m_count = 0;
		m_upcomingNotes.m_index = 0;
		
		return YES;
	}
	
	return NO;
	
}

double SongModel::ConvertTimeToBeat( double time )
{
	return time * m_beatsPerSecond;
}

double SongModel::ConvertBeatToTime( double beat )
{
	return beat / m_beatsPerSecond;
}

void SongModel::CreateNoteMeasureArrays()
{

	// Count how many notes are in every measure.
	CMeasure * currentMeasure = m_song->m_measures;
	unsigned int measureCount = 0;
	unsigned int noteCount = 0;
	
	// Count the measures
	while ( currentMeasure != NULL )
	{
		CNote * currentNote = currentMeasure->m_notes;
		
		while ( currentNote != NULL )
		{
			noteCount++;
			
			currentNote = currentNote->m_next;
		}
		
		measureCount++;
		
		currentMeasure = currentMeasure->m_next;
	}
	
	m_measureArray = new MeasureArray( measureCount );
	m_noteArray = new NoteArray( noteCount );
	
	currentMeasure = m_song->m_measures;
	
	while ( currentMeasure != NULL )
	{
		m_measureArray->AddMeasure( currentMeasure );
		
		CNote * currentNote = currentMeasure->m_notes;
		
		while ( currentNote != NULL )
		{
			m_noteArray->AddNote( currentNote );

			currentNote = currentNote->m_next;
		}

		currentMeasure = currentMeasure->m_next;

	}
	
}

void SongModel::UpdateTargetNotes()
{
	m_targetNotes = FindTargetNotesFromBeat();
	
	TranscribeTargetNotesToBytes();
}

void SongModel::UpdateUpcomingNotes()
{
	m_upcomingNotes = FindUpcomingNotesFromBeat();
	
	TranscribeUpcomingNotesToBytes();
}
/*
void SongModel::ProcessHitUpcomingNotes()
{
	// if we have preemptively hit some notes, 
	// we can check off some target notes early.
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		if ( m_upcomingNotesBytesPreemptiveHit[i] != -1 )
		{
			// preemptively count these notes in all the good ways
			HitTestNote( i, m_upcomingNotesBytesPreemptiveHit[i] );
		}
	}
}
*/
bool SongModel::CheckTargetNotesCloseToBeat( unsigned int index )
{

	CNote * currentNote = &m_noteArray->m_notes[ index ];
	
	// Find the starting index
	if ( fabs(currentNote->m_absoluteBeatStart - m_currentBeat) <= SONG_MODEL_TARGET_NOTE_WINDOW)
	{
		return true;
	}
	
	return false;
		
}

NoteArrayRange SongModel::FindTargetNotesFromBeat()
{
	
	NoteArrayRange targetNotes;
	
	targetNotes.m_index = 0;
	targetNotes.m_count = 0;
			

	// TODO: be more efficient than a linear search every time.
	for ( unsigned int i = 0; i < m_noteArray->m_noteCount; i++ )
	{

		// The next note is too far away, and logically there is nothing else
		// beyond that point. Stop now.
		if ( (m_noteArray->m_notes[i].m_absoluteBeatStart - SONG_MODEL_TARGET_NOTE_WINDOW) >= m_currentBeat )
		{
			break;
		}
		
		// Find the starting index
		if ( CheckTargetNotesCloseToBeat(i) )
		{
			
			targetNotes.m_index = i;
			targetNotes.m_count = NoteCountInGroup(i);
			
			break;
				
		}
		
	}
	
	return targetNotes;
	
}

NoteArrayRange SongModel::FindUpcomingNotesFromBeat()
{
	
	// Find the first note that is greater than the current beat.
	// (offset by the target window, since we don't want to count the target notes)
	NoteArrayRange targetNotes;
	
	targetNotes.m_index = 0;
	targetNotes.m_count = 0;
	
	// TODO: be more efficient than a linear search every time.
	for ( unsigned int i = 0; i < m_noteArray->m_noteCount; i++ )
	{
		
		CNote * currentNote = &m_noteArray->m_notes[i];
		
		// Find the starting index
		if ( (currentNote->m_absoluteBeatStart + SONG_MODEL_TARGET_NOTE_WINDOW) > m_currentBeat )
		{
			
			targetNotes.m_index = i;
			targetNotes.m_count = NoteCountInGroup( i );
			
			break;
			
		}
		
	}
	
	return targetNotes;
	
}


NoteArrayRange SongModel::FindTargetNotesFromTargetNotes( NoteArrayRange targetNotes )
{
	unsigned int startIndex = targetNotes.m_index + targetNotes.m_count;

	NoteArrayRange nextTargetNotes;

	if ( startIndex >= m_noteArray->m_noteCount )
	{
		nextTargetNotes.m_index = 0;
		nextTargetNotes.m_count = 0;
		
		return nextTargetNotes;
	}
	
	nextTargetNotes.m_index = startIndex;
	nextTargetNotes.m_count = NoteCountInGroup( startIndex );
		
	return nextTargetNotes;
	
}

NoteArrayRange SongModel::FindUpcomingNotesFromTargetNotes( NoteArrayRange targetNotes )
{
	
	// If there is a valid set of target note, find the next.
	// Otherwise, find the next after-beat set of notes.
	
	unsigned int startIndex = targetNotes.m_index + targetNotes.m_count;
	
	NoteArrayRange nextTargetNotes;
	
	if ( startIndex >= m_noteArray->m_noteCount )
	{
		nextTargetNotes.m_index = 0;
		nextTargetNotes.m_count = 0;
		
		return nextTargetNotes;
	}
	
	nextTargetNotes.m_index = startIndex;
	nextTargetNotes.m_count = 1;
	
	
	for ( unsigned int i = (startIndex+1); i < m_noteArray->m_noteCount; i++ )
	{
		
		if ( m_noteArray->m_notes[i].m_absoluteBeatStart == m_noteArray->m_notes[startIndex].m_absoluteBeatStart )
		{
			nextTargetNotes.m_count++;
			continue;
		}
		
		break;
		
	}
	
	return nextTargetNotes;
	
}

unsigned int SongModel::NoteCountInGroup( unsigned int startIndex )
{
	unsigned int noteCount = 1;
	
	CNote * targetNote = &m_noteArray->m_notes[ startIndex ];
	
	// Find out how many notes lie within the range
	for ( unsigned int i = (startIndex+1); i < m_noteArray->m_noteCount; i++ )
	{
		CNote * currentNote = &m_noteArray->m_notes[i];
		
		//if ( fabs(currentNote->m_absoluteBeatStart - targetNote->m_absoluteBeatStart) <= TARGET_NOTE_RANGE_PROXIMITY)
		if ( currentNote->m_absoluteBeatStart == targetNote->m_absoluteBeatStart )
		{
			noteCount++;
		}
		else
		{
			break;
		}
	}
	
	return noteCount;
}	

void SongModel::TranscribeTargetNotesToBytes()
{
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		m_targetNotesBytes[i] = -1;
		m_targetNotesBytesHitTest[i] = -1;
	}
	
	for ( unsigned int i = 0; i < m_targetNotes.m_count; i++ )
	{
		CNote * note = &m_noteArray->m_notes[ m_targetNotes.m_index + i ];
		
		m_targetNotesBytes[ note->m_string ] = note->m_fret;
		m_targetNotesBytesHitTest[ note->m_string ] = note->m_fret;
		
		m_notesAttempted++;
	}
	
}

void SongModel::TranscribeUpcomingNotesToBytes()
{
	
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		m_upcomingNotesBytes[i] = -1;
		//m_upcomingNotesBytesPreemptiveHit[i] = -1;
	}
	
	for ( unsigned int i = 0; i < m_upcomingNotes.m_count; i++ )
	{
		CNote * note = &m_noteArray->m_notes[ m_upcomingNotes.m_index + i ];
		
		m_upcomingNotesBytes[ note->m_string ] = note->m_fret;
		//m_upcomingNotesBytesPreemptiveHit[ note->m_string ] = note->m_fret;
		
	}
	
}

void SongModel::GetTargetNotesBytes( char * output )
{
	
	memcpy( output, m_targetNotesBytes, GTAR_GUITAR_STRING_COUNT );
	
}

void SongModel::GetUnHitTargetNotesBytes( char * output )
{
	
	memcpy( output, m_targetNotesBytesHitTest, GTAR_GUITAR_STRING_COUNT );
	
}

void SongModel::GetUpcomingNotesBytes( char * output )
{
	
	memcpy( output, m_upcomingNotesBytes, GTAR_GUITAR_STRING_COUNT );
	
}

bool SongModel::IsTargetNote( char str, char fret )
{

	if ( m_targetNotesBytes[ str ] == fret )
	{
		return true;
	}
		
	return false;
}

bool SongModel::IsTargetString( char str )
{
	
	if ( m_targetNotesBytes[ str ] != GTAR_GUITAR_NOTE_OFF )
	{
		return true;
	}
	
	return false;
}

// This function is small, but important esp. for score handling.
bool SongModel::HitTestNote( char str, char fret )
{
	
	if ( m_targetNotesBytesHitTest[ str ] == fret &&
		m_targetNotesBytesHitTest[ str ] != -1 )
	{
		m_targetNotesBytesHitTest[ str ] = -1;

		return true;
	}
	else
	{
		// wrong notes must be penalized
		m_combo = 0;
		m_multiplier = 1;
		
		m_notesWrong++;
	}
	
	return false;

}

// This allows us to just look at a specific string.
bool SongModel::HitTestString( char str )
{
	return HitTestNote( str, m_targetNotesBytesHitTest[ str ] );
}

bool SongModel::TestUpcomingNote( char str, char fret )
{
	return ( m_upcomingNotesBytes[ str ] == fret );
}

unsigned int SongModel::TargetNotesRemaining()
{
	unsigned notesRemaining = 0;
	
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		if ( m_targetNotesBytesHitTest[i] != -1 )
		{
			notesRemaining++;
		}
	}
	
	return notesRemaining;

}

int SongModel::TargetNoteIndex( char str, char fret )
{
	
	for ( unsigned int i = 0; i < m_targetNotes.m_count; i++ )
	{
		CNote * note = &m_noteArray->m_notes[ m_targetNotes.m_index + i ];
		
		if ( note->m_fret == fret && note->m_string == str )
		{
			return m_targetNotes.m_index + i;
		}
	}
	
	return -1;
}

/*
unsigned int UpcomingTargetNotesRemaining()
{

	unsigned notesRemaining = 0;
	
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		if ( m_upcomingNotesBytesPreemptiveHit[i] != 1 )
		{
			notesRemaining++;
		}
	}
	
	return notesRemaining;
	
}
*/

void SongModel::CalculateAndAccumulateScore()
{
	// convinience .. sometimes this is just easier/faster
	CalculateAndAccumulateScore( m_targetNotesBytes, m_targetNotesBytesHitTest );
}

void SongModel::CalculateAndAccumulateScore( char targetNotes[], char hitNotes[] )
{

	// The scoring method is this:
	// -The combo represents how many notes (and strings) have been hit in a row.
	// -The multiplier is based on how long the combo is.
	// -A subtotal is multiplied by the multiplier and added to the score.
	// --Each string hit is worth 1 point.
	// --Each note hit is worth N points, where N is the number of notes in this group
	//
	// Basically points go up linearlly with the number of strings (because they are easy)
	// and go up exponentially with number of notes (because they are hard).
	// With a six string guitar, the highest base subtotal would be 6x6 = 36 points.
	// With a max multiplier of 4x, the most points for a single group would be 144 points.
	//
	
	NSInteger stringsHit = 0;
	NSInteger stringsTotal = 0;
	NSInteger notesHit = 0;
	NSInteger notesTotal = 0;
	
	// check to see which target notes were / were not hit
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		// strings are worth less points
		if ( targetNotes[i] == 0 )
		{
			stringsTotal++;
			
			if ( hitNotes[i] == -1 )
			{
				stringsHit++;
			}
			else 
			{
				m_combo = 0;
				m_multiplier = 1;
			}
			
		}

		// notes are worth more
		if ( targetNotes[i] > 0 )
		{
			notesTotal++;
			
			if ( hitNotes[i] == -1 )
			{
				notesHit++;
			}
			else 
			{
				m_combo = 0;
				m_multiplier = 1;
			}
		}

	}
	
	// use that info to calculate a nice score for them
	m_notesHit = (m_notesHit + stringsHit + notesHit);

	// a combo is not the number of notes, but the number of groups of notes
	//m_combo = (m_combo + stringsHit + notesHit);
	//m_comboTheoreticalMax = (m_comboTheoreticalMax + stringsTotal + notesTotal);
	if ( notesHit > 0 || stringsHit > 0 )
	{
		m_combo++;
	}
	if ( notesTotal > 0 || stringsTotal > 0)
	{
		m_comboTheoreticalMax++;
	}
	
	if ( m_combo > m_comboMax )
	{
		m_comboMax = m_combo;
	}
	
	// We increase the multiplier up to a max value.
	if ( m_combo == 0 )
	{
		m_multiplier = 1;
	}
	else 
	{	
		m_multiplier = ((m_combo-1) / SONG_MODEL_COMBO_MULTIPLIER) + 1;
	}
		
	if ( m_comboTheoreticalMax == 0 )
	{
		m_multiplierTheoreticalMax = 1;
	}
	else 
	{
		m_multiplierTheoreticalMax = ((m_comboTheoreticalMax-1) / SONG_MODEL_COMBO_MULTIPLIER) + 1;
	}
	
	
	// bounds checking
	if ( m_multiplier < 1 )
	{
		m_multiplier = 1;
	}
	if ( m_multiplier > SONG_MODEL_COMBO_MULTIPLIER_MAX )
	{
		m_multiplier = SONG_MODEL_COMBO_MULTIPLIER_MAX;
	}
	
	if ( m_multiplierTheoreticalMax < 1 )
	{
		m_multiplierTheoreticalMax = 1;
	}
	if ( m_multiplierTheoreticalMax > SONG_MODEL_COMBO_MULTIPLIER_MAX )
	{
		m_multiplierTheoreticalMax = SONG_MODEL_COMBO_MULTIPLIER_MAX;
	}
	
	// multiply out the total score for this instance.

	//m_score += m_multiplier * SONG_MODEL_BASE_SCORE;
	m_score += m_multiplier * ((notesHit * notesTotal) + stringsHit) * SONG_MODEL_BASE_SCORE;
		
	//m_scoreTheoreticalMax += m_multiplierTheoreticalMax * SONG_MODEL_BASE_SCORE;
	m_scoreTheoreticalMax += m_multiplierTheoreticalMax * ((notesTotal * notesTotal) + stringsTotal) * SONG_MODEL_BASE_SCORE;	
	
}

void SongModel::ResetScore()
{
	
	m_notesHit = 0;
	m_notesAttempted = 0;
	m_notesWrong = 0;
	m_score = 0;
	m_scoreTheoreticalMax = 0;
	m_combo = 0;
	m_comboMax = 0;
	m_comboTheoreticalMax = 0;
	m_multiplier = 1;
	m_multiplierTheoreticalMax = 1;

}

void SongModel::ChangeTempo( double tempo )
{
	m_beatsPerSecond = tempo / 60.0;
}