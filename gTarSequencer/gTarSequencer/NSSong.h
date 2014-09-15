//
//  NSSong.h
//  Sequence
//
//  Created by Kate Schnippering on 9/10/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSTrack.h"

@interface NSSong : NSObject
{
    long m_id;
    NSString * m_title;
    NSString * m_author;
    NSString * m_description;
    long m_tempo;
    
    bool m_looping;
    long m_loopstart;
    long m_loopend;
    
    NSString * m_sequenceName;
    long m_sequenceId;
    
    // TODO: loopsettings
    
    NSMutableArray * m_tracks;
}


@property (nonatomic) long m_id;
@property (nonatomic, readonly) NSString * m_title;
@property (nonatomic, readonly) NSString * m_author;
@property (nonatomic, readonly) NSString * m_description;
@property (nonatomic) long m_tempo;
@property (nonatomic) bool m_looping;
@property (nonatomic) long m_loopstart;
@property (nonatomic) long m_loopend;
@property (nonatomic, readonly) NSString * m_sequenceName;
@property (nonatomic) long m_sequenceId;

@property (nonatomic, readonly) NSMutableArray * m_tracks;

@property (nonatomic, assign) double startbeat;

@property (nonatomic, assign) double duration;

- (id)initWithXMPFilename:(NSString *)filename;
- (id)initWithXMPNode:(XMPNode *)xmpNode;

- (XMPNode *)convertToXmp;
- (void)printTree;
- (void)saveToFile:(NSString *)filename;

- (id)initWithTitle:(NSString *)title author:(NSString *)author description:(NSString *)description tempo:(long)tempo looping:(bool)looping loopstart:(long)loopstart loopend:(long)loopend sequenceName:(NSString *)sequenceName sequenceId:(long)sequenceId;

- (void)addTrack:(NSTrack *)track;
- (NSTrack *)trackWithName:(NSString *)name volume:(double)volume mute:(bool)mute instrument:(NSInstrument *)inst;
- (void)finishTracks;

- (void)renameToName:(NSString *)name andDescription:(NSString *)description;


@end
