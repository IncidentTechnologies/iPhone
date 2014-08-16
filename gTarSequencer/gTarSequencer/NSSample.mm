//
//  NSSample.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSSample.h"

@implementation NSSample

@synthesize m_name;
@synthesize m_value;
@synthesize m_custom;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * sample = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_name = [[NSString alloc] initWithUTF8String:[sample GetAttributeValueWithName:@"name"].GetPszValue()];
        
        m_value = [[NSString alloc] initWithUTF8String:[sample GetAttributeValueWithName:@"value"].GetPszValue()];
        
        [sample GetAttributeValueWithName:@"custom"].GetValueBool(&m_custom);
        
        DLog(@"SAMPLE %@",m_name);
        
        
    }
    
    return self;
    
}

-(id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value
{
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_value = value;
        m_custom = custom;
    }
    
    return self;
}

-(XMPNode *)convertToXmp
{
    
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"sample" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"value", (char *)[m_value UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"custom", m_custom));
    
    return node;
}

@end
