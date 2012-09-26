//
//  LessonModel.mm
//  gTar
//
//  Created by wuda on 10/24/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "LessonModel.h"
#import "Segment.h"
#import "LessonParser.h"

@implementation LessonModel

@synthesize m_endOfLesson, m_endOfChapter, m_endOfInstruction;

-(LessonModel*)init
{
	
	if ( self = [super init] )
	{

		m_lesson = [LessonParser lessonWithXmp:@"stuff"];
		
	}
	
	return self;
}


-(void)advanceModelToAbsoluteTimeSeconds:(double)time
{
	
	
	
}

-(void)advanceModelByDeltaTimeSeconds:(double)deltaTime
{
	
}

-(void)startModelOnChapter:(NSInteger)chapNum
{
	
	m_endOfChapter = NO;
	m_endOfInstruction = NO;

	// Load the chapter from the lesson
	m_currentChapter = [m_lesson getChapterWithNumber:chapNum];
	
	// Get the first segment from the chapter
	m_currentSegment = [m_currentChapter getSegmentWithId:1];
	
	// Get the target notes (if any) from this segment.
	[m_currentSegment getTargetNotes:m_targetNotes];
	
}


-(void)advanceModelToNextSegment
{
	
	NSInteger nextSegmentId = m_currentSegment.m_nextId;
	
	if ( nextSegmentId == 0 )
	{
		// done
		//m_endOfChapter = YES;
		m_endOfInstruction = YES;
		
		m_currentSegment = nil;
		
		char allOff[] = { -1, -1, -1, -1, -1, -1 };
		
		memcpy( m_targetNotes, allOff, GTAR_GUITAR_STRING_COUNT );
		
		//NSInteger nextChapter = m_currentChapter.m_chapterNumber + 1;
		//m_currentChapter = [m_lesson getChapterWithNumber:nextChapter];
		//m_currentSegment = [m_currentChapter getSegmentWithId:1];
		//[m_currentSegment getTargetNotes:m_targetNotes];
		
	}
	else 
	{
		
		m_currentSegment = [m_currentChapter getSegmentWithId:nextSegmentId];
		
		[m_currentSegment getTargetNotes:m_targetNotes];
		
	}
	
}

-(NSString*)getCurrentText
{
	if ( m_currentSegment == nil )
	{
		return nil;
	}
	
	return m_currentSegment.m_instructionText;	
}

-(void)getTargetNotes:(char*)output
{
	memcpy( output, m_targetNotes, GTAR_GUITAR_STRING_COUNT );
}

-(SegmentAdvanceMethod)getCurrentAdvanceMethod
{
	return m_currentSegment.m_advanceMethod;	
}

-(NSString*)getChapterSongXmpName
{
	return m_currentChapter.m_songXmpName;
}

-(unsigned int)targetNotesRemaining
{
	
	unsigned int remaining = 0;
	
	for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		if ( m_targetNotes[ str ] != GTAR_GUITAR_NOTE_OFF )
		{
			remaining++;
		}
	}
	
	return remaining;
	
}

// This function is small, but important
-(bool)hitTestNoteString:(char)str andFret:(char)fret
{
	
	if ( m_targetNotes[ str ] == fret )
	{

		m_targetNotes[ str ] = -1;
		
		return true;
	}
	
	return false;

}

// This allows us to just look at a specific string.
-(bool)hitTestString:(char)str
{
	if ( m_targetNotes[ str ] == -1 )
	{
		return false;
	}
	
	return [self hitTestNoteString:str andFret: m_targetNotes[str]];
}

@end
