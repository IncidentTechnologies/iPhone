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
@synthesize m_encoding;
@synthesize m_data;

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
        
        m_encoding = [[NSString alloc] initWithUTF8String:[sample GetAttributeValueWithName:@"encoding"].GetPszValue()];
        
        [sample GetAttributeValueWithName:@"custom"].GetValueBool(&m_custom);
        
        DLog(@"SAMPLE %@",m_name);
        
        if(xmpNode->HasChild((char*)"data")){
            m_data = [[NSSampleData alloc] initWithXMPNode:xmpNode->FindChildByName((char *)"data")];
        }
        
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
        
        m_encoding = [dom getTextFromChildWithName:@"encoding"];
        
        m_custom = [[dom getTextFromChildWithName:@"custom"] boolValue];
        
        if([dom getChildWithName:@"data"] != nil){
            m_data = [[NSSampleData alloc] initWithXmlDom:[dom getChildWithName:@"data"]];
        }
        
        DLog(@"SAMPLE %@",m_name);
    }
    
    return self;
}

-(id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value encoding:(NSString *)encoding
{
    self = [super init];
    
	if ( self )
    {
        m_name = name;
        m_value = value;
        m_custom = custom;
        m_encoding = encoding;
        
        m_data = [[NSSampleData alloc] init];
    }
    
    return self;
}

- (id)initWithData:(NSSampleData *)data Name:(NSString *)name custom:(bool)custom value:(NSString *)value encoding:(NSString *)encoding
{
    self = [super init];
    
    if ( self )
    {
        m_name = name;
        m_value = value;
        m_custom = custom;
        m_encoding = encoding;
        
        m_data = data;
        
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
    
    node->AddAttribute(new XMPAttribute((char *)"encoding", (char *)[m_encoding UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"custom", m_custom));
    
    node->AddChild([m_data convertToXmp]);
    
    return node;
}

@end
