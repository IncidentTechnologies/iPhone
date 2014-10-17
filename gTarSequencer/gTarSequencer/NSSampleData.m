//
//  NSSampleData.m
//  Sequence
//
//  Created by Kate Schnippering on 10/16/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSSampleData.h"

@implementation NSSampleData

@synthesize m_dataname;
@synthesize m_dataid;
@synthesize m_datasize;
@synthesize m_dataencoding;
@synthesize m_binary;

- (id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        XMPObject * data = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        m_dataname = [[NSString alloc] initWithUTF8String:[data GetAttributeValueWithName:@"dataname"].GetPszValue()];
        
        [data GetAttributeValueWithName:@"dataid"].GetValueInt(&m_dataid);
        
        [data GetAttributeValueWithName:@"datasize"].GetValueInt(&m_datasize);
        
        m_dataencoding = [[NSString alloc] initWithUTF8String:[data GetAttributeValueWithName:@"dataencoding"].GetPszValue()];
        
        // m_binary
        
        DLog(@"DATA %@",m_dataname);
        
    }
    
    return self;
    
}

- (id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        
        m_dataname = [dom getTextFromChildWithName:@"dataname"];
        
        m_dataid = [[dom getTextFromChildWithName:@"dataid"] intValue];
        
        m_datasize = [[dom getTextFromChildWithName:@"datasize"] intValue];
        
        m_dataencoding = [dom getTextFromChildWithName:@"dataencoding"];
        
        DLog(@"TODO: generate m_binary");
        
    }
    
    return self;
}

- (id)initWithData:(NSData *)data dataName:(NSString *)name dataId:(long)dataid dataSize:(long)datasize dataEncoding:(NSString *)encoding
{
    self = [super init];
    
    if ( self )
    {
        m_binary = data;
        m_dataname = name;
        m_dataid = dataid;
        m_datasize = datasize;
        m_dataencoding = encoding;
    }
    
    return self;
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"data" UTF8String],NULL);
    
    node->AddAttribute(new XMPAttribute((char *)"dataname", (char *)[m_dataname UTF8String]));
    
    node->AddAttribute(new XMPAttribute((char *)"dataid", m_dataid));
    
    node->AddAttribute(new XMPAttribute((char *)"datasize", m_datasize));
    
    node->AddAttribute(new XMPAttribute((char *)"dataencoding", (char *)[m_dataencoding UTF8String]));
    
    //
    
    const unsigned char *dataBuffer = (const unsigned char *)[m_binary bytes];
    
    NSUInteger dataLength = [m_binary length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    //NSString * datastring = hexString;
    
    node->AppendContentNode((char *)[m_binary bytes]);
    
    //node->AppendContentNode((char *)[@"abcd" UTF8String]);
    
    return node;
}

@end
