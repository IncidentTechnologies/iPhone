//
//  Song.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Song.h"


@implementation Song

@synthesize m_measures;
@synthesize m_artist;
@synthesize m_name;
@synthesize m_description;
@synthesize m_id;
@synthesize m_tempo;

-(id)init
{
	
	if (self = [super init]) {
		
		m_measures = [[NSMutableArray alloc] init];
		
	}
	
	return self;
	
}

-(void)dealloc
{
	[m_measures release];
    [super dealloc];
}

-(void)addMeasure:(Measure*)measure
{
	[m_measures addObject:measure];
	
	[self sortMeasures];
}

-(void)sortMeasures
{
	[m_measures sortUsingSelector:@selector(compare:)];
}

@end
