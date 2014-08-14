//
//  NSInstrument.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSInstrument.h"

@implementation NSInstrument

@synthesize m_id;
@synthesize m_name;
@synthesize m_iconName;
@synthesize m_custom;
@synthesize m_sampler;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * instrument = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[instrument GetAttributeValueWithName:@"name"].GetPszValue()];
        
        m_iconName = [[NSString alloc] initWithUTF8String:[instrument GetAttributeValueWithName:@"iconname"].GetPszValue()];
        
        [instrument GetAttributeValueWithName:@"index"].GetValueInt(&m_id);
        
        [instrument GetAttributeValueWithName:@"custom"].GetValueBool(&m_custom);
        
        m_sampler = [[NSSampler alloc] initWithXMPNode:xmpNode->FindChildByName((char *)"sampler")];
        
    }
    
    return self;
}

-(id)initWithName:(NSString *)name id:(long)index iconName:(NSString *)iconName isCustom:(NSNumber *)isCustom
{
    
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_id = index;
        m_iconName = iconName;
        m_custom = isCustom;
        
        m_sampler = [[NSSampler alloc] init];
    }
    
    return self;
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"instrument" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"iconname", (char *)[m_iconName UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"index", m_id));
    
    node->AddAttribute(new XMPAttribute((char *)"custom", m_custom));
    
    node->AddChild([m_sampler convertToXmp]);
    
    return node;
}

@end
