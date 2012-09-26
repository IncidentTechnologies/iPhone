//
//  LessonSegment.h
//  gTar
//
//  Created by wuda on 10/28/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "gTar.h"

enum LessonSegmentAdvanceMethod
{
	LessonSegmentAdvanceMethodTouch,
	LessonSegmentAdvanceMethodNotes,
	LessonSegmentAdvanceMethodTime
};

@interface LessonSegment : NSObject
{

	LessonSegmentAdvanceMethod m_method;
	
	LessonSegment * m_next;
	
	char m_targetNotes[ GTAR_GUITAR_STRING_COUNT ];
	
	NSString * m_instructionText;
	
}

@property (nonatomic) LessonSegmentAdvanceMethod m_method;
@property (nonatomic, retain) LessonSegment * m_next;
@property (nonatomic, retain) NSString * m_instructionText;


- (void)setTargetNotes:(char*)targetNotes;
- (void)getTargetNotes:(char*)output;
- (LessonSegment*)getNextLessonSegment;
@end
