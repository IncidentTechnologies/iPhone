//
//  Chapter.m
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Chapter.h"


@implementation Chapter
							
@synthesize m_segments, m_song, m_chapterNumber, m_chapterName, m_songXmpName;

-(Chapter*)init
{
	
	if ( self = [super init] )
	{
		m_segments = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)dealloc
{
	[m_segments release];
}
  
-(NSComparisonResult)compare:(Chapter*)chapter
{
	
	if ( self.m_chapterNumber < chapter.m_chapterNumber )
	{
		return NSOrderedAscending;
	}
	else if ( self.m_chapterNumber > chapter.m_chapterNumber )
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}
		

-(void)addSegment:(Segment*)segment
{
	
	[m_segments addObject:segment];
	
	[m_segments sortUsingSelector:@selector(compare:) ];
	
}

-(Segment*)getSegmentWithId:(NSInteger)segId
{
	for ( unsigned int i = 0; i < [m_segments count]; i++ )
	{
		Segment * seg = [m_segments objectAtIndex:i];
		
		if ( segId == seg.m_id )
		{
			return seg;
		}
		
	}
	
	return nil;
	
}
@end
