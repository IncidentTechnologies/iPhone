//
//  NSNote.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSNote.h"

#define DEFAULT_NOTE_DURATION 0.25

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
        
        [m_note GetAttributeValueWithName:@"beatstart"].GetValueDouble(&m_beatstart);
        
        if([m_note HasChildWithName:@"guitarposition"]){
            
            m_value = [[NSString alloc] initWithUTF8String:[[m_note GetChildWithName:@"guitarposition"] GetAttributeValueWithName:@"string"].GetPszValue()];
            
            m_value = [NSString stringWithFormat:@"%i",[m_value intValue] - 1];
            
            [[m_note GetChildWithName:@"guitarposition"] GetAttributeValueWithName:@"string"].GetValueInt(&m_stringvalue);
            
            m_stringvalue -= 1;
            
        }else{
        
            m_value = [[NSString alloc] initWithUTF8String:[m_note GetAttributeValueWithName:@"value"].GetPszValue()];
            
            [m_note GetAttributeValueWithName:@"value"].GetValueInt(&m_stringvalue);
            
        }
        
        [m_note GetAttributeValueWithName:@"duration"].GetValueDouble(&m_duration);
        
        DLog(@"NOTE");
    }
    
    return self;
    
}

-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        m_beatstart = [[dom getTextFromChildWithName:@"beatstart"] doubleValue];
        
        XmlDom * guitarposition = [dom getChildWithName:@"guitarposition"];
        
        if(guitarposition != nil){
            
            m_stringvalue = [[guitarposition getTextFromChildWithName:@"string"] intValue] - 1;
            
            m_value = [NSString stringWithFormat:@"%i",[[guitarposition getTextFromChildWithName:@"string"] intValue] - 1 ];
            
        }else{
            
            m_stringvalue = [[dom getTextFromChildWithName:@"value"] intValue];
            
            m_value = [dom getTextFromChildWithName:@"value"];
        }
        
        m_duration = [[dom getTextFromChildWithName:@"duration"] doubleValue];
        
        DLog(@"NOTE value %@ stringvalue %li",m_value,m_stringvalue);
        
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
        m_duration = DEFAULT_NOTE_DURATION;
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
    
    if(m_duration <= 0){
        node->AddAttribute(new XMPAttribute((char *)"duration", DEFAULT_NOTE_DURATION));
    }else{
        node->AddAttribute(new XMPAttribute((char *)"duration", m_duration));
    }
    
    XMPNode *tempNode = new XMPNode((char *)"guitarposition", node);
    tempNode->AddAttribute(new XMPAttribute((char *)"string", m_stringvalue+1));
    tempNode->AddAttribute(new XMPAttribute((char *)"fret", 0));
    node->AddChild(tempNode);
    
    return node;
}

@end
