/*
 *  CNote.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

class CNote
{
public:
	
	// Linked list of notes.
	class CNote * m_next;
	
	double m_duration;
	char m_value[8];
	
	// The beat within the measure where this note starts.
	// Although relative to the start of the measure,
	// it is actually one-indexed.
	double m_measureStart;
	
	// Absolute beat start (relative to the begining of the song, beat 0)
	double m_absoluteBeatStart;
	
	// Attributes of the 'guitarposition' element, stored in this note for simplicity
	unsigned int m_string; // 0-5
	unsigned int m_fret;
	
	CNote() :
		m_next(NULL),
		m_duration(NULL),
		m_measureStart(0),
		m_absoluteBeatStart(0),
		m_string(0),
		m_fret(0)
	{
		
	}
	
	~CNote()
	{
		
	}
	
	void SetValue( const char * str );
	
};

class NoteArray
{
public:
	
	unsigned int m_noteCount;
	unsigned int m_noteMax;
	CNote * m_notes;
	
	NoteArray( unsigned int noteMax ) :
		m_noteCount(0)
	{
		m_noteMax = noteMax;
		m_notes = new CNote[ m_noteMax ]();
	}
	
	~NoteArray()
	{
		delete[] m_notes;
	}
	
	bool AddNote( CNote * note )
	{
		
		if ( m_noteCount >= m_noteMax )
		{
			return false;
		}
		
		m_notes[ m_noteCount ] = (*note);
		
		m_noteCount++;
		
		return true;
	}
	
};

class NoteArrayRange
{
public:
	unsigned int m_index;
	unsigned int m_count;
	
	NoteArrayRange() :
		m_index(0),
		m_count(0)
	{
		
	}
};