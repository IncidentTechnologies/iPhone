//
//  NSNote.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSNote.h"

@implementation NSNote

@synthesize m_value;
@synthesize m_beatstart;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * note = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_value = [[NSString alloc] initWithUTF8String:[note GetAttributeValueWithName:@"value"].GetPszValue()];
        
        [note GetAttributeValueWithName:@"beatstart"].GetValueDouble(&m_beatstart);
        
    }
    
    return self;
    
}

-(id)initWithValue:(NSString *)value beatstart:(double)beatstart
{
    self = [super init];
    
	if ( self )
    {
        m_value = value;
        m_beatstart = beatstart;
    }
    
    return self;
}

-(XMPNode *)convertToXmp
{
    
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"note" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"value", (char *)[m_value UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"beatstart", m_beatstart));
    
    return node;
}

@end
