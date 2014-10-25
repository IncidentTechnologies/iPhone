//
//  NSNote.m
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "NSNote.h"

#import "XmlDom.h"

#import <gTarAppCore/AppCore.h>

@implementation NSNote

@synthesize m_duration;
@synthesize m_value;
@synthesize m_measureStart;
@synthesize m_absoluteBeatStart;
@synthesize m_key;

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
        
        self.m_key = [[xmlDom getNumberFromChildWithName:@"key"] integerValue];
        
        /*
        if ( [key isEqualToString:@"X"] == YES ||
             [key isEqualToString:@"x"] == YES )
        {
            self.m_key = KEYS_KEY_MUTED;
        }
        else
        {
            self.m_key = [key integerValue];
        }
         */
        
        self.m_standaloneActive = YES;
        
    }
    
    return self;
    
}

- (id)initWithDuration:(double)duration
			  andValue:(NSString*)value
	   andMeasureStart:(double)measureStart
  andAbsoluteBeatStart:(double)absoluteBeatStart
              andKey:(KeyPosition)key
{
	
    self = [super init];
    
	if ( self )
	{
		
		self.m_duration = duration;
		self.m_value = value;
		self.m_measureStart = measureStart;
		self.m_absoluteBeatStart = absoluteBeatStart;
		self.m_key = key;
		
	}
	
	return self;
	
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
