//
//  NSNote.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NSNote.h"

#import "XmlDom.h"

#import "AppCore.h"

@implementation NSNote

@synthesize m_duration;
@synthesize m_value;
@synthesize m_measureStart;
@synthesize m_absoluteBeatStart;
@synthesize m_string;
@synthesize m_fret;

- (id)initWithXmlDom:(XmlDom*)xmlDom
{
    
    if ( xmlDom == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        self.m_value = [xmlDom getTextFromChildWithName:@"value"];
        
        self.m_duration = [[xmlDom getNumberFromChildWithName:@"duration"] floatValue];
        
        self.m_measureStart = [[xmlDom getNumberFromChildWithName:@"measurestart"] floatValue];
        
        XmlDom * guitarPositionDom = [xmlDom getChildWithName:@"guitarposition"];
        
        self.m_string = [[guitarPositionDom getNumberFromChildWithName:@"string"] integerValue];
//        self.m_string--; // convert to zero-based strings
        
        NSString * fretString = [guitarPositionDom getTextFromChildWithName:@"fret"];
        
        if ( [fretString isEqualToString:@"X"] == YES ||
             [fretString isEqualToString:@"x"] == YES )
        {
            self.m_fret = GTAR_GUITAR_FRET_MUTED;
        }
        else
        {
            self.m_fret = [fretString integerValue];
        }
        
    }
    
    return self;
    
}

- (id)initWithDuration:(double)duration
			  andValue:(NSString*)value
	   andMeasureStart:(double)measureStart
  andAbsoluteBeatStart:(double)absoluteBeatStart
			 andString:(GtarString)str
			   andFret:(GtarFret)fret
{
	
    self = [super init];
    
	if ( self )
	{
		
		self.m_duration = duration;
		self.m_value = value;
		self.m_measureStart = measureStart;
		self.m_absoluteBeatStart = absoluteBeatStart;
		self.m_string = str;
		self.m_fret = fret;
		
	}
	
	return self;
	
}

- (void)dealloc
{
    [m_value release];
    [super dealloc];
}

- (NSComparisonResult)compare:(NSNote*)note
{
	
	if ( self.m_absoluteBeatStart < note.m_absoluteBeatStart )
	{
		return NSOrderedAscending;
	}
	if ( self.m_absoluteBeatStart > note.m_absoluteBeatStart )
	{
		return NSOrderedDescending;
	}
	
	return NSOrderedSame;
	
}

@end
