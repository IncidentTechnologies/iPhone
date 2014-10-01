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
    double m_duration;
    long m_stringvalue;
}

@property (nonatomic) XMPObject * m_note;

@property (retain, nonatomic) NSString * m_value;
@property (nonatomic) double m_beatstart;
@property (nonatomic) double m_duration;
@property (nonatomic) long m_stringvalue;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithValue:(NSString *)value beatstart:(double)beatstart;
-(id)initWithValue:(NSString *)value beatstart:(double)beatstart duration:(double)duration;

-(XMPNode *)convertToSequenceXmp;
-(XMPNode *)convertToSongXmp;


@end
