//
//  Measure.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Measure.h"


@implementation Measure

@synthesize m_notes;
@synthesize m_startBeat;
@synthesize m_beatCount;
@synthesize m_beatValue;

-(id)init
{

	if (self = [super init]) {
		
		m_startBeat = 0;
		m_beatCount = 0;
		m_beatValue = 0;
	
		m_notes = [[NSMutableArray alloc] init];
		
	}
	
	return self;
	
}

-(void)dealloc
{
	[m_notes release];
    [super dealloc];
}

-(void)addNote:(Note*)note
{
	[m_notes addObject:note ];
	
	[self sortNotes];
}

-(void)sortNotes
{
	[m_notes sortUsingSelector:@selector(compare:)];
}

-(NSComparisonResult)compare:(Measure*)measure
{
	
	if ( self.m_startBeat < measure.m_startBeat )
	{
		return NSOrderedAscending;
	}
	else if ( self.m_startBeat < measure.m_startBeat )
	{
		return NSOrderedAscending;
	}
	
	return NSOrderedSame;
}

@end
