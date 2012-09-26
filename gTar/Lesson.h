//
//  Lesson.h
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chapter.h"

@interface Lesson : NSObject
{
	NSMutableArray * m_chapters;
	NSString * m_lessonName;	
	NSInteger m_lessonNumber;
	
}

@property (nonatomic, retain) NSMutableArray * m_chapters;
@property (nonatomic, retain) NSString * m_lessonName;	
@property (nonatomic) NSInteger m_lessonNumber;

-(NSComparisonResult)compare:(Lesson*)lesson;
-(void)addChapter:(Chapter*)chapter;
-(Chapter*)getChapterWithNumber:(NSInteger)chapNum;

@end
