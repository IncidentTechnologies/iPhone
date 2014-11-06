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
@synthesize m_xmpFileId;
@synthesize m_externalId;

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
        
        [sample GetAttributeValueWithName:@"xmpid"].GetValueInt(&m_xmpFileId);
        
        if([sample HasAttributeWithName:@"id"]){
            m_externalId = [[NSString alloc] initWithUTF8String:[sample GetAttributeValueWithName:@"id"].GetPszValue()];
        }else{
            m_externalId = @"";
        }
            
        DLog(@"SAMPLE %@",m_name);
        
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
        m_name = [dom getTextFromChildWithName:@"name"];
        
        m_value = [dom getTextFromChildWithName:@"value"];
        
        m_custom = [[dom getTextFromChildWithName:@"custom"] boolValue];
        
        m_xmpFileId = [[dom getTextFromChildWithName:@"xmpid"] intValue];
        
        m_externalId = [dom getTextFromChildWithName:@"id"];
        
        DLog(@"SAMPLE %@",m_name);
    }
    
    return self;
}

-(id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value externalId:(NSString *)externalId xmpFileId:(long)xmpFileId
{
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_value = value;
        m_custom = custom;
        m_xmpFileId = xmpFileId;
        m_externalId = externalId;
    }
    
    return self;
}

- (void)saveToFile
{
    NSString * filename = m_name;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Samples"];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Samples/" stringByAppendingString:[filename stringByAppendingString:@".xml"]]];
    
    char * filepath = (char *)[sequenceFilepath UTF8String];
    
    XMPNode *node = NULL;
    node = new XMPNode((char *)[@"xmp" UTF8String],NULL);
    node->AddChild([self convertToXmp]);
    
    XMPTree tree = NULL;
    
    tree.AddChild(node);
    
    tree.SaveXMPToFile(filepath, YES);
    
    DLog(@"Saved SAMPLE to path %s",filepath);
    
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"sample" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"name", (char *)[m_name UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"value", (char *)[m_value UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"custom", m_custom));
    
    node->AddAttribute(new XMPAttribute((char *)"xmpid", m_xmpFileId));
    
    node->AddAttribute(new XMPAttribute((char *)"id", (char *)[m_externalId UTF8String]));
    
    return node;
}

@end
