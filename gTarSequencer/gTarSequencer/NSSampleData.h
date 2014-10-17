//
//  NSSampleData.h
//  Sequence
//
//  Created by Kate Schnippering on 10/16/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"

@interface NSSampleData : NSObject
{
    NSString * m_dataname;
    long m_dataid;
    long m_datasize;
    NSString * m_dataencoding;
    
    NSData * m_binary;
    
}

@property (retain, nonatomic) NSString * m_dataname;
@property (assign, nonatomic) long m_dataid;
@property (assign, nonatomic) long m_datasize;
@property (retain, nonatomic) NSString * m_dataencoding;
@property (retain, nonatomic) NSData * m_binary;

- (id)initWithXMPNode:(XMPNode *)xmpNode;

- (id)initWithXmlDom:(XmlDom *)dom;

- (id)initWithData:(NSData *)data dataName:(NSString *)name dataId:(long)dataid dataSize:(long)datasize dataEncoding:(NSString *)encoding;

-(XMPNode *)convertToXmp;

@end
