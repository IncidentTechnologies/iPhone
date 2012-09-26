//
//  SongModel.h
//  gTar
//
//  Created by Marty Greenia on 10/13/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#include "CSong.h"
#include "gTar.h"

#include "SongParser.h"

#define SONG_MODEL_TARGET_NOTE_WINDOW (0.15f)
//#define SONG_MODEL_TARGET_NOTE_RANGE_PROXIMITY (0.1f)

#define SONG_MODEL_COMBO_MULTIPLIER 4
#define SONG_MODEL_COMBO_MULTIPLIER_MAX 4
#define SONG_MODEL_BASE_SCORE 1

// TODO: convert me to objc

class SongModel
{
public:
	// The song we are modeling
	CSong * m_song;
	bool m_endOfSong;

	// Time related members
	double m_currentBeat;
	
	// Song related members
//	double m_secondsPerBeat;
	double m_beatsPerSecond;
	
	// Convenience arrays
	NoteArray * m_noteArray;
	MeasureArray * m_measureArray;
	
	// Special note tracking
	NoteArrayRange m_targetNotes;
	NoteArrayRange m_upcomingNotes;
	
	char m_targetNotesBytes[ GTAR_GUITAR_STRING_COUNT ];
	char m_targetNotesBytesHitTest[ GTAR_GUITAR_STRING_COUNT ];
	char m_upcomingNotesBytes[ GTAR_GUITAR_STRING_COUNT ];
//	char m_upcomingNotesBytesPreemptiveHit[ GTAR_GUITAR_STRING_COUNT ];
	
	// Scoring
	unsigned int m_notesHit;
	unsigned int m_notesAttempted;
	unsigned int m_notesWrong;
	unsigned int m_score;
	unsigned int m_scoreMax;
	unsigned int m_scoreTheoreticalMax;
	unsigned int m_combo;
	unsigned int m_comboMax;
	unsigned int m_comboTheoreticalMax;
	unsigned int m_multiplier;
	unsigned int m_multiplierTheoreticalMax;
	
	
	SongModel( NSString * xmpBlob ) :
		m_endOfSong(false),
		m_currentBeat(0),
//		m_secondsPerBeat(1.0),
		m_beatsPerSecond(1.0),
		m_noteArray(NULL),
		m_measureArray(NULL),
		m_notesHit(0),
		m_notesAttempted(0),
		m_notesWrong(0),
		m_score(0),
		m_scoreTheoreticalMax(0),
		m_combo(0),
		m_comboMax(0),
		m_comboTheoreticalMax(0),
		m_multiplier(1),
		m_multiplierTheoreticalMax(1)
	{
		m_song = [SongParser songWithXmpBlob:xmpBlob];
		
		CreateNoteMeasureArrays();
		
		//m_secondsPerBeat = m_song->m_tempo / 60.0; // temp in bpm
		m_beatsPerSecond = m_song->m_tempo / 60.0; // temp in bpm
		
		m_targetNotes.m_index = 0;
		m_targetNotes.m_count = 0;

		for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
		{
			m_targetNotesBytes[i] = -1;
			m_targetNotesBytesHitTest[i] = -1;
			m_upcomingNotesBytes[i] = -1;
		}

		// Start off the model.
		AdvanceModelToAbsoluteTimeSeconds( 0 );
	}

	~SongModel()
	{
		delete m_song;
	}
	
	void StartModelAtTime( double time );
	void AdvanceModelToAbsoluteBeat( double beat );
	void AdvanceModelToAbsoluteTimeSeconds( double time );
	void AdvanceModelByDeltaTimeSeconds( double deltaTime );
	void AdvanceModelToNextTargetNotes();
	void AdvanceModelToNextTargetNotesFromBeat();
	
	bool CheckEndOfSong();
	double ConvertTimeToBeat( double time );
	double ConvertBeatToTime( double beat );
	void CreateNoteMeasureArrays();

	void UpdateTargetNotes();
	void UpdateUpcomingNotes();
//	void ProcessHitUpcomingNotes();

	bool CheckTargetNotesCloseToBeat( unsigned int index );

	NoteArrayRange FindTargetNotesFromBeat();
	NoteArrayRange FindUpcomingNotesFromBeat();

	NoteArrayRange FindTargetNotesFromTargetNotes( NoteArrayRange targetNotes );
	NoteArrayRange FindUpcomingNotesFromTargetNotes( NoteArrayRange targetNotes );
	
	unsigned int NoteCountInGroup( unsigned int startIndex );

	void TranscribeTargetNotesToBytes();
	void TranscribeUpcomingNotesToBytes();

	void GetTargetNotesBytes( char * output );
	void GetUnHitTargetNotesBytes( char * output );
	void GetUpcomingNotesBytes( char * output );
	
	bool IsTargetNote( char str, char fret );
	bool IsTargetString( char str );
	
	bool HitTestNote( char str, char fret );
	bool HitTestString( char str );
	void CalculateAndAccumulateScore();
	void CalculateAndAccumulateScore( char * targetNotes, char * hitNotes );
//	bool PreemptiveHitTestNote( char str, char fret );
	bool TestUpcomingNote( char str, char fret );
	
	unsigned int TargetNotesRemaining();
	unsigned int UpcomingTargetNotesRemaining();
	
	// Get
	NoteArray * GetNoteArray() { return m_noteArray; }
	MeasureArray * GetMeasureArray() { return m_measureArray; }
	
	bool IsEndOfSong() { return m_endOfSong; }
	double GetCurrentBeat() { return m_currentBeat; }
	double GetCurrentTime() { return ConvertBeatToTime(m_currentBeat); }
	NoteArrayRange GetTargetNotes() { return m_targetNotes; }

	unsigned int GetScore() { return m_score; }
	unsigned int GetScoreMax() { return m_scoreTheoreticalMax; }
	unsigned int GetNotesAttempted() { return m_notesAttempted; }
	unsigned int GetNotesHit() { return m_notesHit; }
	unsigned int GetNotesTotal() { return m_noteArray->m_noteCount; }
	unsigned int GetCombo() { return m_combo; }
	unsigned int GetComboMax() { return m_comboMax; }
	unsigned int GetMultiplier() { return m_multiplier; }
	char * GetSongName() { return m_song->m_name; }
	char * GetArtistName() { return m_song->m_artist; }
	char * GetDescription() { return m_song->m_description; }
	
	void ResetScore();
	void ChangeTempo( double tempo );
};
