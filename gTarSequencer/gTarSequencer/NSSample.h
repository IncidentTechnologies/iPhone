//
//  NSSample.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSSampleData.h"

@interface NSSample : NSObject
{
    NSString * m_name;
    NSString * m_value;
    NSString * m_encoding;
    bool m_custom;
    
    NSSampleData * m_data;
}

@property (retain, nonatomic) NSString * m_name;
@property (retain, nonatomic) NSString * m_value;
@property (retain, nonatomic) NSString * m_encoding;
@property (nonatomic) bool m_custom;

@property (retain, nonatomic) NSSampleData * m_data;

- (id)initWithXMPNode:(XMPNode *)xmpNode;

- (id)initWithXmlDom:(XmlDom *)dom;

- (id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value encoding:(NSString *)encoding;

- (id)initWithData:(NSSampleData *)data Name:(NSString *)name custom:(bool)custom value:(NSString *)value encoding:(NSString *)encoding;

- (void)saveToFile;

-(XMPNode *)convertToXmp;

@end
