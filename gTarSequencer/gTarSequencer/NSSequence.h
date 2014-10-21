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
#import "XmlDom.h"

@interface NSSequence : NSObject
{
    NSString * m_name;
    double m_tempo;
    double m_volume;
    bool m_originSequenceRoot;
    long m_id;
    
    NSMutableArray * m_tracks;
}

@property (nonatomic, readonly) NSMutableArray * m_tracks;
@property (nonatomic, strong) NSString * m_name;
@property (nonatomic) double m_tempo;
@property (nonatomic) double m_volume;
@property (nonatomic) long m_id;
@property (nonatomic, readonly) bool m_originSequenceRoot;

@property (nonatomic) int m_selectedTrackIndex;

- (id)initWithXMPFilename:(NSString *)filename fromBundle:(BOOL)fromBundle;
- (id)initWithXMPNode:(XMPNode *)xmpNode;
- (id)initWithXmlDom:(XmlDom *)dom;

- (id)initWithName:(NSString *)name tempo:(double)tempo volume:(double)volume;

// convert from archaic format
- (id)initWithName:(NSString *)name tempo:(double)tempo volume:(double)volume instruments:(NSArray *)instruments;

- (XMPNode *)convertToXmp;
- (NSString *)saveToFile:(NSString *)filename;
- (void)deleteFile;

- (void)addTrack:(NSTrack *)track;

- (int)trackCount;

- (void)renameToName:(NSString *)newName;

- (void)giveUserOwnership;
- (void)giveAppOwnership;

@end
