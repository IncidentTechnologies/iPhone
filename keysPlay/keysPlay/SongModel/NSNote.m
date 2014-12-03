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
        self.m_key = [self convertValueToKey:value];
		
        //DLog(@"NOTE VALUE IS %@ KEY IS %i",m_value,m_key);
        
	}
	
	return self;
	
}

- (int)convertValueToKey:(NSString *)value
{
    int keyValue = 0;
    NSArray * letterValues = [[NSArray alloc] initWithObjects:@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B", nil];
    
    // Value is composed of A-G, #?, and 0-10
    // These don't appear to include flats?
    NSString * octaveValue = [[value componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSString * noteValue = [[value componentsSeparatedByCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] componentsJoinedByString:@""];
    
    keyValue += KEYS_OCTAVE_COUNT * [octaveValue intValue];
    
    for(int k = 0; k < [letterValues count]; k++){
        if([noteValue isEqualToString:letterValues[k]]){
            keyValue += k;
            break;
        }
    }
    
    return keyValue;
}

- (NSComparisonResult)compareStartbeat:(NSNote*)note
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

- (NSComparisonResult)compareKey:(NSNote *)note
{
    if ( self.m_key < note.m_key )
    {
        return NSOrderedAscending;
    }
    if ( self.m_key > note.m_key )
    {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

@end
