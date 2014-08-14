//
//  NSNote.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"

@interface NSNote : NSObject
{
    NSString * m_value;
    double m_beatstart;
}

@property (retain, nonatomic) NSString * m_value;
@property (nonatomic) double m_beatstart;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithValue:(NSString *)value beatstart:(double)beatstart;

-(XMPNode *)convertToXmp;

@end
