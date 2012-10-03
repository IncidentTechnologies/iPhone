/*
 *  CMeasure.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "CNote.h"

class CMeasure
{
public:

	// Enables creation of a linked list of measures
	class CMeasure * m_next;
	
	// Linked list of notes
	CNote * m_notes;
	CNote * m_notesTail;
	
	unsigned int m_notesCount;
	
	// Data for this measure
	double m_startBeat;
	double m_beatCount;
	double m_beatValue;

	CMeasure() :
		m_next(NULL),
		m_notes(NULL),
		m_notesTail(NULL),
		m_notesCount(0),
		m_startBeat(0),
		m_beatCount(0),
		m_beatValue(0)
	{
		
	}
	
	~CMeasure()
	{
		CNote * nextNote = m_notes;
		
		while ( m_notes != NULL )
		{
			nextNote = m_notes->m_next;
			delete m_notes;
			m_notes = nextNote;
		}
	}
	
	void AddNote( CNote * newNote );
	void SortNotes();
	void AlignNotes( double alignmentThreshold );
//	CNote * GetNoteAtIndex( unsigned int requestedIndex );
	
};

class MeasureArray
{
public:
	
	unsigned int m_measureCount;
	unsigned int m_measureMax;
	CMeasure * m_measures;
	
	MeasureArray( unsigned int measureMax ) :
	m_measureCount(0)
	{
		m_measureMax = measureMax;
		m_measures = new CMeasure[ m_measureMax ]();
	}
	
	~MeasureArray()
	{
		delete[] m_measures;
	}
	
	bool AddMeasure( CMeasure * measure )
	{
		
		if ( m_measureCount >= m_measureMax )
		{
			return false;
		}
		
		m_measures[ m_measureCount ] = (*measure);
		
		m_measureCount++;
		
		return true;
	}
};