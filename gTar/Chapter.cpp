/*
 *  Chapter.cpp
 *  gTar
 *
 *  Created by Marty Greenia on 10/24/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "Chapter.h"
#if 0
void Chapter::AddSegment( Segment * segment)
{
	
	if ( m_segments == NULL )
	{
		m_segments = segment;
	}
	else
	{
		m_segmentsTail->m_next = segment;
	}
	
	m_segmentsTail = segment;
	
	m_segmentsTail->m_next = NULL;
	
	m_segmentsCount++;
	
}
#endif