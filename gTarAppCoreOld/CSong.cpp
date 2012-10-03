/*
 *  CSong.c
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "CSong.h"

void CSong::AddMeasure( CMeasure * newMeasure )
{
	
	if ( m_measures == NULL )
	{
		m_measures = newMeasure;
	}
	else
	{
		m_measuresTail->m_next = newMeasure;
	}
	
	m_measuresTail = newMeasure;
	
	m_measuresTail->m_next = NULL;
	
	m_measuresCount++;
	
}

void CSong::SortMeasures()
{
	
	// Simple bubble sort, good enough.
	unsigned int swaps;
	
	do
	{
		swaps = 0;
		
		CMeasure ** prevMeasureNext = &m_measures;
		CMeasure * currentMeasure = m_measures;
		
		// Nothing to sort
		if ( currentMeasure == NULL )
		{
			return;
		}
		
		CMeasure * nextMeasure = currentMeasure->m_next;
		
		while ( nextMeasure != NULL )
		{
			
			if ( currentMeasure->m_startBeat > nextMeasure->m_startBeat )
			{
				// Swap current and next
				swaps++;
				
				(*prevMeasureNext) = nextMeasure;
				currentMeasure->m_next = nextMeasure->m_next;
				nextMeasure->m_next = currentMeasure;
				
			}
			
			prevMeasureNext = &(currentMeasure->m_next);
			currentMeasure = nextMeasure;
			nextMeasure = nextMeasure->m_next;
			
		}
		
	} while ( swaps > 0 );
	
}

unsigned int CSong::GetNoteCount()
{
	
	CMeasure * currentMeasure = m_measures;
	unsigned int noteCount = 0;
	
	while ( currentMeasure != NULL )
	{
		
		noteCount += currentMeasure->m_notesCount;
		
		currentMeasure = currentMeasure->m_next;
		
	}
	
	return noteCount;
	
}

void CSong::SetArtist( const char * artist )
{
	if ( artist == NULL )
    {
        m_artist[0] = '\0';
        return;
    }
    
    int len = strlen(artist);
	int size = (len > CSONG_MAX_STRING_LENGTH) ? CSONG_MAX_STRING_LENGTH : len;
	
	memcpy(m_artist, artist, size);

	m_artist[size] = '\0';
}

void CSong::SetName( const char * name )
{
	if ( name == NULL )
    {
        m_name[0] = '\0';
        return;
    }
    
    int len = strlen(name);
	int size = (len > CSONG_MAX_STRING_LENGTH) ? CSONG_MAX_STRING_LENGTH : len;

	memcpy(m_name, name, size);
	
	m_name[size] = '\0';
}

void CSong::SetDescription( const char * description )
{
	if ( description == NULL )
    {
        m_description[0] = '\0';
        return;
    }
    
    int len = strlen(description);
	int size = (len > CSONG_MAX_STRING_LENGTH) ? CSONG_MAX_STRING_LENGTH : len;

	memcpy(m_description, description, size);
	
	m_description[size] = '\0';
}

void CSong::SetInstrument( const char * instrument )
{
    if ( instrument == NULL )
    {
        m_instrument[0] = '\0';
        return;
    }
    
	int len = strlen(instrument);
	int size = (len > CSONG_MAX_STRING_LENGTH) ? CSONG_MAX_STRING_LENGTH : len;
    
	memcpy(m_instrument, instrument, size);
	
	m_instrument[size] = '\0';
}
