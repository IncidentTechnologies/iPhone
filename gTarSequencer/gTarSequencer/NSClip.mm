//
//  NSClip.m
//  Sequence
//
//  Created by Kate Schnippering on 9/10/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSClip.h"

@implementation NSClip

@synthesize m_notes;
@synthesize m_name;
@synthesize m_color;
@synthesize m_startbeat;
@synthesize m_endbeat;
@synthesize m_cliplength;
@synthesize m_clipstart;
@synthesize m_looping;
@synthesize m_loopstart;
@synthesize m_looplength;


- (id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if ( xmpNode == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        XMPObject * m_clip = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[m_clip GetAttributeValueWithName:@"name"].GetPszValue()];
        
        m_color = [[NSString alloc] initWithUTF8String:[m_clip GetAttributeValueWithName:@"color"].GetPszValue()];
        
        [m_clip GetAttributeValueWithName:@"startbeat"].GetValueInt(&m_startbeat);
        
        [m_clip GetAttributeValueWithName:@"endbeat"].GetValueInt(&m_endbeat);
        
        [m_clip GetAttributeValueWithName:@"cliplength"].GetValueInt(&m_cliplength);
        
        [m_clip GetAttributeValueWithName:@"clipstart"].GetValueInt(&m_clipstart);
        
        [m_clip GetAttributeValueWithName:@"looping"].GetValueBool(&m_looping);
        
        [m_clip GetAttributeValueWithName:@"loopstart"].GetValueInt(&m_loopstart);
        
        [m_clip GetAttributeValueWithName:@"looplength"].GetValueInt(&m_looplength);
        
        DLog(@"CLIP name | %@",m_name);
        DLog(@"CLIP color | %@",m_color);
        DLog(@"CLIP startbeat | %li",m_startbeat);
        DLog(@"CLIP endbeat | %li",m_endbeat);
        DLog(@"CLIP cliplength | %li",m_cliplength);
        DLog(@"CLIP clipstart | %li",m_clipstart);
        DLog(@"CLIP looping | %i",m_looping);
        DLog(@"CLIP loopstart | %li",m_loopstart);
        DLog(@"CLIP looplength | %li",m_looplength);
        
        m_notes = [[NSMutableArray alloc] init];
        
        list<XMPNode *>* t_sections = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_sections->First(); it != NULL; it++){
            
            NSNote * m_note = [[NSNote alloc] initWithXMPNode:*it];
            
            [self addNote:m_note];
    
        }
        
    }
    
    return self;
    
}

- (id)initWithName:(NSString *)name startbeat:(long)startbeat endBeat:(long)endbeat clipLength:(long)cliplength clipStart:(long)clipstart looping:(bool)looping loopStart:(long)loopstart looplength:(long)looplength color:(NSString *)color
{
	
    self = [super init];
    
	if ( self )
	{
		
		m_notes = [[NSMutableArray alloc] init];
		
		m_name = name;
        m_startbeat = startbeat;
        m_endbeat = endbeat;
        m_cliplength = cliplength;
        m_clipstart = clipstart;
        m_looping = looping;
        m_loopstart = loopstart;
        m_looplength = looplength;
        
        m_color = color;
        
	}
	
	return self;
}

- (XMPNode *)convertToSongXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"clip" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"startbeat", m_startbeat));
    
    node->AddAttribute(new XMPAttribute((char *)"endbeat", m_endbeat));
    
    node->AddAttribute(new XMPAttribute((char *)"cliplength", m_cliplength));
    
    node->AddAttribute(new XMPAttribute((char *)"clipstart", m_clipstart));
    
    node->AddAttribute(new XMPAttribute((char *)"looping", m_looping));
    
    node->AddAttribute(new XMPAttribute((char *)"loopstart", m_loopstart));
    
    node->AddAttribute(new XMPAttribute((char *)"looplength", m_looplength));
    
    node->AddAttribute(new XMPAttribute((char *)"color", (char *)[m_color UTF8String]));
    
    for(NSNote * note in m_notes){
        node->AddChild([note convertToSongXmp]);
    }
    
    return node;
}

- (void)addNote:(NSNote *)note
{
    [m_notes addObject:note];
}


@end
