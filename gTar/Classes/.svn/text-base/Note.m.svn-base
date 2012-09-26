//
//  Note.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Note.h"


@implementation Note

@synthesize m_duration;
@synthesize m_value;
@synthesize m_measureStart;
@synthesize m_absoluteBeatStart;
@synthesize m_string;
@synthesize m_fret;

- (id)init
{
	if (self = [super init]) {

		m_measureStart = 0;
		m_duration = 0;
		m_value = 0;
		m_absoluteBeatStart = 0;
		m_measureStart = 0;
		m_string = 0;
		m_fret = 0;
		
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSComparisonResult)compare:(Note*)note
{
	
	if ( self.m_absoluteBeatStart < note.m_absoluteBeatStart )
	{
		return NSOrderedAscending;
	}
	else if ( self.m_absoluteBeatStart > note.m_absoluteBeatStart )
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

// NSCopying delegate function
- (id)copyWithZone:(NSZone *)zone
{
	return [self mutableCopy];
}

- (id)mutableCopy
{

	Note * note = [[Note alloc] init];

	note.m_duration = self.m_duration;
	note.m_value = self.m_value;
	note.m_absoluteBeatStart = self.m_absoluteBeatStart;
	note.m_measureStart = self.m_measureStart;
	note.m_string = self.m_string;
	note.m_fret = self.m_fret;
	
	return note;
	
}

@end
