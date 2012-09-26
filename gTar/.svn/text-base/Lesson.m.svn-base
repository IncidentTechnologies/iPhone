//
//  Lesson.m
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Lesson.h"


@implementation Lesson

@synthesize m_chapters;
@synthesize m_lessonName;
@synthesize m_lessonNumber;

-(Lesson*)init
{
	if ( self = [super init] )
	{
		m_chapters = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)dealloc
{
	
	[m_chapters release];
	
}

-(NSComparisonResult)compare:(Lesson*)lesson
{
	
	if ( self.m_lessonNumber < lesson.m_lessonNumber )
	{
		return NSOrderedAscending;
	}
	else if ( self.m_lessonNumber > lesson.m_lessonNumber )
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

-(void)addChapter:(Chapter*)chapter
{
	[m_chapters addObject:chapter];
	
	[m_chapters sortUsingSelector:@selector(compare:)];
}

-(Chapter*)getChapterWithNumber:(NSInteger)chapNum
{	
	for ( unsigned int i = 0; i < [m_chapters count]; i++ )
	{
		Chapter * chap = [m_chapters objectAtIndex:i];
		
		if ( chapNum == chap.m_chapterNumber )
		{
			return chap;
		}
		
	}

	return nil;
}

@end
