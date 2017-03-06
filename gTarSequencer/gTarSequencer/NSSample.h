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

@interface NSSample : NSObject
{
    NSString * m_name;
    NSString * m_value;
    bool m_custom;
    
    long m_xmpFileId;
}

@property (retain, nonatomic) NSString * m_name;
@property (retain, nonatomic) NSString * m_value;
@property (nonatomic) bool m_custom;
@property (nonatomic, assign) long m_xmpFileId;

- (id)initWithXMPNode:(XMPNode *)xmpNode;

- (id)initWithXmlDom:(XmlDom *)dom;

- (id)initWithName:(NSString *)name custom:(bool)custom value:(NSString *)value xmpFileId:(long)xmpFileId;

- (void)saveToFile;

-(XMPNode *)convertToXmp;

@end
