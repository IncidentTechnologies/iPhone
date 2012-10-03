/*
 *  CMeasure.c
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "CMeasure.h"

void CMeasure::AddNote( CNote * newNote )
{

	if ( m_notes == NULL )
	{
		m_notes = newNote;
	}
	else
	{
		m_notesTail->m_next = newNote;
	}

	m_notesTail = newNote;

	m_notesTail->m_next = NULL;

	m_notesCount++;

}

void CMeasure::SortNotes()
{
	
	// Simple bubble sort, good enough.
	unsigned int swaps;
	
	do
	{
		swaps = 0;

		CNote ** prevNoteNext = &m_notes;
		CNote * currentNote = m_notes;
		
		// Nothing to sort
		if ( currentNote == NULL )
		{
			return;
		}
		
		CNote * nextNote = currentNote->m_next;
		
		while ( nextNote != NULL )
		{
			
			if ( currentNote->m_measureStart > nextNote->m_measureStart )
			{
				// Swap current and next
				swaps++;
				
				(*prevNoteNext) = nextNote;
				currentNote->m_next = nextNote->m_next;
				nextNote->m_next = currentNote;
				
			}
			
			prevNoteNext = &(currentNote->m_next);
			currentNote = nextNote;
			nextNote = nextNote->m_next;
			
		}
		
		
	} while ( swaps > 0 );
	
	
}

void CMeasure::AlignNotes( double alignmentThreshold )
{

	CNote * currentNote = m_notes;
	
	if ( currentNote == NULL )
	{
		return;
	}
							
	CNote * nextNote = currentNote->m_next;
	
	// If they are within a threshold, snap to the first note
	while ( nextNote != NULL )
	{
		if ( fabs(currentNote->m_measureStart - nextNote->m_measureStart) < alignmentThreshold )
		{
			nextNote->m_measureStart = currentNote->m_measureStart;
			nextNote->m_absoluteBeatStart = currentNote->m_absoluteBeatStart;
		}
		
		currentNote = nextNote;
		nextNote = currentNote->m_next;

	}
}
/*
CNote * CMeasure::GetNoteAtIndex( unsigned int requestedIndex )
{
	
	if ( m_notesCount <= requestedIndex )
	{
		return NULL;
	}
	
	CNote * currentNote = m_notes;
	
	for ( unsigned int i = 0; i < requestedIndex; i++ )
	{
		// The index is out of bounds, nothing more we can do.
		if ( currentNote == NULL )
		{
			return NULL;
		}
		
		currentNote = currentNote->m_next;
		
	}
	
	// This takes us to the index just before out target.
	// Return the next and we are done.
	return currentNote->m_next;
	
}
*/