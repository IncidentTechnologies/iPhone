//
//  LessonModel.h
//  gTar
//
//  Created by wuda on 10/24/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lesson.h"

@interface LessonModel : NSObject
{
	
	Lesson * m_lesson;
	bool m_endOfLesson;
	bool m_endOfChapter;
	bool m_endOfInstruction;
	
	Chapter * m_currentChapter;
	Segment * m_currentSegment;
	
	CSong * m_currentSong;
	
	char m_targetNotes[ GTAR_GUITAR_STRING_COUNT];

}

//@property (nonatomic, retain) NSMutableArray * m_segments;
@property (nonatomic, retain) Segment * m_currentSegment;
@property (nonatomic, readonly) bool m_endOfLesson;
@property (nonatomic, readonly) bool m_endOfChapter;
@property (nonatomic, readonly) bool m_endOfInstruction;

-(void)advanceModelToAbsoluteTimeSeconds:(double)time;
-(void)advanceModelByDeltaTimeSeconds:(double)deltaTime;
-(void)advanceModelToNextSegment;

-(NSString*)getCurrentText;
-(void)getTargetNotes:(char*)output;
-(SegmentAdvanceMethod)getCurrentAdvanceMethod;
-(NSString*)getChapterSongXmpName;
-(unsigned int)targetNotesRemaining;

-(bool)hitTestNoteString:(char)str andFret:(char)fret;
-(bool)hitTestString:(char)str;

@end
