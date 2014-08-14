//
//  NSTrack.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSTrack.h"

@implementation NSTrack

@synthesize m_patterns;
@synthesize m_name;
@synthesize m_volume;
@synthesize m_muted;
@synthesize m_instrument;

@synthesize selectedPattern;
@synthesize selectedPatternIndex;
@synthesize selectedPatternDidChange;
@synthesize isSelected;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * track = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[track GetAttributeValueWithName:@"name"].GetPszValue()];
        
        [track GetAttributeValueWithName:@"volume"].GetValueDouble(&m_volume);
        
        [track GetAttributeValueWithName:@"muted"].GetValueBool(&m_muted);
        
        m_instrument = [[NSInstrument alloc] initWithXMPNode:xmpNode->FindChildByName((char *)"instrument")];
        
        list<XMPNode *>* t_patterns = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_patterns->First(); it != NULL; it++){
            
            XMPNode * m_it = *it;
            
            if(strcmp(m_it->GetName(),"pattern") == 0){
                NSPattern * pattern = [[NSPattern alloc] initWithXMPNode:m_it];
                
                [self addPattern:pattern];
            }
        }
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name volume:(double)volume muted:(bool)muted
{
    
    self = [super init];
    
	if ( self )
    {
        m_patterns = [[NSMutableArray alloc] init];

        m_instrument = [[NSInstrument alloc] init];

        m_name = name;
        m_volume = volume;
        m_muted = muted;
        
        selectedPattern = nil;
        selectedPatternIndex = nil;
        selectedPatternDidChange = NO;
        
        isSelected = NO;
    }
    
    return self;
    
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"track" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"volume", m_volume));
    
    node->AddAttribute(new XMPAttribute((char *)"muted", m_muted));
    
    node->AddChild([m_instrument convertToXmp]);
    
    for(NSPattern * pattern in m_patterns){
        node->AddChild([pattern convertToXmp]);
    }
    
    return node;
}

-(void)addPattern:(NSPattern *)pattern
{
    [m_patterns addObject:pattern];
}

@end
