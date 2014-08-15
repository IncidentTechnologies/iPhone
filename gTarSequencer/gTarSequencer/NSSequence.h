//
//  NSSequence.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSTrack.h"

@interface NSSequence : NSObject
{
    NSString * m_name;
    double m_tempo;
    double m_volume;
    
    NSMutableArray * m_tracks;
}

@property (nonatomic, readonly) NSMutableArray * m_tracks;
@property (nonatomic, strong) NSString * m_name;
@property (nonatomic) double m_tempo;
@property (nonatomic) double m_volume;

@property (nonatomic) int m_selectedTrackIndex;

-(id)initWithXMPFilename:(NSString *)filename;
-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithName:(NSString *)name tempo:(double)tempo volume:(double)volume;

// convert from archaic format
-(id)initWithName:(NSString *)name tempo:(double)tempo volume:(double)volume instruments:(NSArray *)instruments;

-(XMPNode *)convertToXmp;
-(void)saveToFile:(NSString *)filename;

-(void)addTrack:(NSTrack *)track;

-(int)trackCount;

@end
