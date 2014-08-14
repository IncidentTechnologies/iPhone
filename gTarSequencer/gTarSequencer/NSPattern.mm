//
//  NSPattern.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSPattern.h"

@implementation NSPattern

@synthesize m_name;
@synthesize m_on;
@synthesize m_notes;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * pattern = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[pattern GetAttributeValueWithName:@"name"].GetPszValue()];
        
        [pattern GetAttributeValueWithName:@"on"].GetValueBool(&m_on);
        
        list<XMPNode *>* t_notes = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_notes->First(); it != NULL; it++){
            
            NSNote * note = [[NSNote alloc] initWithXMPNode:*it];
            
            [self addNote:note];
        }
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name on:(bool)on
{
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_on = on;
        
        m_notes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"pattern" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"on", m_on));
    
    return node;
}

-(void)addNote:(NSNote *)note
{
    [m_notes addObject:note];
}

@end
