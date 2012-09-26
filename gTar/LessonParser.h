//
//  LessonParser.h
//  gTar
//
//  Created by wuda on 10/24/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lesson.h" 

@interface LessonParser : NSObject
{

	NSString * m_xmpName;
	Lesson * m_lesson;
	
	Lesson * m_currentLesson;
	Chapter * m_currentChapter;
	Segment * m_currentSegment;
	
	NSMutableString * m_currentText; 
	
}


@property (nonatomic) Lesson * m_lesson;

- (LessonParser*)initWithXmp:(NSString *)xmpName;
+ (Lesson*)lessonWithXmp:(NSString*)xmpName;

@end
