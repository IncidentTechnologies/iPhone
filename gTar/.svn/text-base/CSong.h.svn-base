/*
 *  CSong.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "CMeasure.h";

#define CSONG_MAX_STRING_LENGTH 63

class CSong
{
public:
	
	// Linked list of measures
	CMeasure * m_measures;
	CMeasure * m_measuresTail;
	
	unsigned int m_measuresCount;
	
	// Data for this particular song
	char m_artist[CSONG_MAX_STRING_LENGTH+1];
	char m_name[CSONG_MAX_STRING_LENGTH+1];
	char m_description[CSONG_MAX_STRING_LENGTH+1];
	unsigned int m_id;
	double m_tempo;
	
	CSong() :
		m_measures(NULL),
		m_measuresTail(NULL),
		m_measuresCount(NULL),
		m_id(0),
		m_tempo(0)
	{
		m_artist[0] = 0;
		m_name[0] = 0;
		m_description[0] = 0;
	}
	
	~CSong()
	{
		CMeasure * nextMeasure = m_measures;

		while ( m_measures != NULL )
		{
			nextMeasure = m_measures->m_next;
			delete m_measures;
			m_measures = nextMeasure;
		}
	}
	
	void AddMeasure( CMeasure * newMeasure );
	void SortMeasures();
//	CMeasure * GetMeasureAtIndex( unsigned int requestedIndex );
//	CNote * GetNoteAtIndex( unsigned int requestedIndex );
	unsigned int GetNoteCount();

	void SetArtist( const char * artist );
	void SetName( const char * name );
	void SetDescription( const char * description );
};