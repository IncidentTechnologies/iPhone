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
@synthesize m_stringvalue;
@synthesize m_duration;

@synthesize m_note;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        m_note = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_value = [[NSString alloc] initWithUTF8String:[m_note GetAttributeValueWithName:@"value"].GetPszValue()];
        
        [m_note GetAttributeValueWithName:@"beatstart"].GetValueDouble(&m_beatstart);
        
        [m_note GetAttributeValueWithName:@"value"].GetValueInt(&m_stringvalue);
        
        DLog(@"NOTE");
    }
    
    return self;
    
}

-(id)initWithValue:(NSString *)value beatstart:(double)beatstart
{
    self = [super init];
    
	if ( self )
    {
        m_value = value;
        m_stringvalue = [value intValue];
        m_beatstart = beatstart;
    }
    
    return self;
}

-(id)initWithValue:(NSString *)value beatstart:(double)beatstart duration:(double)duration
{
    self = [super init];
    
	if ( self )
    {
        m_value = value;
        m_stringvalue = [value intValue];
        m_beatstart = beatstart;
        m_duration = duration;
    }
    
    return self;
}

-(XMPNode *)convertToSequenceXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"note" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"value", (char *)[m_value UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"beatstart", m_beatstart));
    
    return node;
}

-(XMPNode *)convertToSongXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"note" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"value", (char *)[m_value UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"beatstart", m_beatstart));
    
    node->AddAttribute(new XMPAttribute((char *)"duration", m_duration));
    
    XMPNode *tempNode = new XMPNode((char *)"guitarposition", node);
    tempNode->AddAttribute(new XMPAttribute((char *)"string", m_stringvalue));
    tempNode->AddAttribute(new XMPAttribute((char *)"fret", 0));
    node->AddChild(tempNode);
    
    return node;
}

@end
