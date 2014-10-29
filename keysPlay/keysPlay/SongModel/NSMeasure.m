//
//  NSMeasure.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NSMeasure.h"

#import "NSNote.h"
#import "XmlDom.h"

@implementation NSMeasure

@synthesize m_notes;
@synthesize m_startBeat;
@synthesize m_beatCount;
@synthesize m_beatValue;

- (id)initWithXmlDom:(XmlDom*)xmlDom
{
    
    if ( xmlDom == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_notes = [[NSMutableArray alloc] init];
        
        XmlDom * startbeatDom = [xmlDom getChildWithName:@"startbeat"];
        m_startBeat = [[startbeatDom getNumberFromChildWithName:@"value"] integerValue];
        
        XmlDom * beatcountDom = [xmlDom  getChildWithName:@"beatcount"];
        m_beatCount = [[beatcountDom getNumberFromChildWithName:@"value"] integerValue];
        
        XmlDom * beatvalue = [xmlDom getChildWithName:@"beatvalue"];
        m_beatValue = [[beatvalue getNumberFromChildWithName:@"value"] integerValue];
        
        NSArray * noteArray = [xmlDom getChildArrayWithName:@"note"];
        
//        DLog(@"Measure start %f", m_startBeat);
        
        for ( XmlDom * noteDom in noteArray )
        {

            //
            // Get each note
            //
            NSNote * note = [[NSNote alloc] initWithXmlDom:noteDom];
            
            note.m_absoluteBeatStart = note.m_measureStart + m_startBeat - 1;
            
            [self addNote:note];
            
            
        }
        
        // done
        
    }
    
    return self;
    
}

- (id)initWithStartBeat:(double)startBeat
		   andBeatCount:(double)beatCount
		   andBeatValue:(double)beatValue
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_notes = [[NSMutableArray alloc] init];
		
		self.m_startBeat = startBeat;
		self.m_beatCount = beatCount;
		self.m_beatValue = beatValue;
		
	}
	
	return self;
    
}


- (void)addNote:(NSNote*)note
{
    
	[m_notes addObject:note];
	
	[m_notes sortUsingSelector:@selector(compare:)];
    
}

- (NSComparisonResult)compare:(NSMeasure*)measure
{
	
	if ( self.m_startBeat < measure.m_startBeat )
	{
		return NSOrderedAscending;
	}
	if ( self.m_startBeat > measure.m_startBeat )
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
    
}
		
@end
