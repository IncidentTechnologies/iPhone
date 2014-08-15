//
//  NSInstrument.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSSampler.h"

@interface NSInstrument : NSObject
{
    long m_id;
    NSString * m_name;
    NSString * m_iconName;
    bool m_custom;
    
    NSSampler * m_sampler;
}

@property (nonatomic) long m_id;
@property (retain, nonatomic) NSString * m_name;
@property (retain, nonatomic) NSString * m_iconName;
@property (nonatomic) bool m_custom;

@property (retain, nonatomic) NSSampler * m_sampler;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithName:(NSString *)name id:(long)index iconName:(NSString *)iconName isCustom:(BOOL)isCustom;

-(id)init;

-(XMPNode *)convertToXmp;

- (void)releaseSounds;



@end
