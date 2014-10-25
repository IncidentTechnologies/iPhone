//
//  NSMarker.m
//  gTarAppCore
//
//  Created by Kate Schnippering on 5/12/14.
//
//


#import "NSMarker.h"
#import "XmlDom.h"

@implementation NSMarker

@synthesize m_startBeat;
@synthesize m_name;

- (id)initWithXmlDom:(XmlDom*)xmlDom
{
    
    if ( xmlDom == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_startBeat = [[xmlDom getNumberFromChildWithName:@"startbeat"] doubleValue];
        
        m_name = [xmlDom getTextFromChildWithName:@"name"];
        
    }
    
    return self;
    
}

- (id)initWithStartBeat:(double)startBeat andName:(NSString *)name
{
	
    self = [super init];
    
	if ( self )
	{
		self.m_startBeat = startBeat;
        self.m_name = name;
	}
	
	return self;
    
}

@end
