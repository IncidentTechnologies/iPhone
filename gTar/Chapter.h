//
//  Chapter.h
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSong.h"
#import "Segment.h"

@interface Chapter : NSObject
{
	NSMutableArray * m_segments;
	CSong * m_song;
	NSString * m_songXmpName;
	
	NSInteger m_chapterNumber;
	NSString * m_chapterName;
}

@property (nonatomic, retain) NSMutableArray * m_segments;
@property (nonatomic) CSong * m_song;
@property (nonatomic, retain) NSString * m_songXmpName;
@property (nonatomic) NSInteger m_chapterNumber;
@property (nonatomic, retain) NSString * m_chapterName;

-(void)addSegment:(Segment*)segment;
-(Segment*)getSegmentWithId:(NSInteger)segId;

@end
