//
//  Segment.m
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Segment.h"


@implementation Segment

@synthesize m_instructionText;
@synthesize m_id, m_nextId, m_nextIdSuccess, m_nextIdFailure;
@synthesize m_advanceMethod;

-(Segment*)init
{
	if ( self = [super init] )
	{
		char allOff[] = { -1, -1, -1, -1, -1, -1 };
		
		memcpy( m_targetNotes, allOff, GTAR_GUITAR_STRING_COUNT );
	}
	
	return self;
}
		
		
-(void)setTargetNotes:(char*)targetNote
{
	memcpy( m_targetNotes, targetNote, GTAR_GUITAR_STRING_COUNT );
}

-(void)getTargetNotes:(char*)output
{
	memcpy( output, m_targetNotes, GTAR_GUITAR_STRING_COUNT );
}

-(void)setTargetNoteString:(char)str andFret:(char)fret
{
	
	m_targetNotes[ str ] = fret;
	
}

-(NSComparisonResult)compare:(Segment*)segment
{
	
	if ( self.m_id < segment.m_id )
	{
		return NSOrderedAscending;
	}
	else if ( self.m_id > segment.m_id )
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}
@end
