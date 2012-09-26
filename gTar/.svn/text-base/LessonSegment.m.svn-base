//
//  LessonSegment.m
//  gTar
//
//  Created by wuda on 10/28/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "LessonSegment.h"

@implementation LessonSegment

@synthesize m_method;
@synthesize m_next;
@synthesize m_instructionText;

- (void)setTargetNotes:(char*)targetNotes
{
	memcpy( m_targetNotes, targetNotes, GTAR_GUITAR_STRING_COUNT );
}
- (void)getTargetNotes:(char*)output
{
	memcpy( output, m_targetNotes, GTAR_GUITAR_STRING_COUNT );
}

- (LessonSegment*)getNextLessonSegment
{
	return m_next;
}
@end
