/*
 *  DisplayController.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/15/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#import "EAGLView.h"
#import "CNote.h"
#import "CMeasure.h"

class DisplayController
{
public:

	NoteArray * m_noteArray;
	MeasureArray * m_measureArray;
	
	EAGLView * m_glView;
	
	DisplayController( EAGLView * glView, 
					   unsigned int stringCount,
					   NoteArray * noteArray,
					   MeasureArray * measureArray )
	{

		m_glView = glView;
		
		[m_glView retain];

		m_noteArray = noteArray;
		m_measureArray = measureArray;

		[m_glView initWithStringCount:(unsigned int)stringCount notes:(NoteArray*)noteArray andMeasures:(MeasureArray*)measureArray];
		 
		//[m_glView startAnimation];
				
	}
	
	~DisplayController()
	{
		
		//[m_glView stopAnimation];
		
		[m_glView release];
		
	}
	
	void AdvanceToTime( double time );
	
};