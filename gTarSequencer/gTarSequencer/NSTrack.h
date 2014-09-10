//
//  NSTrack.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSInstrument.h"
#import "NSPattern.h"
#import "NSMeasure.h"
#import "NSClip.h"

#define MAX_BEAT_SEQUENCES 4
#define FIRST_FRET 0
#define LAST_FRET 15

@interface NSTrack : NSObject
{
    NSString * m_name;
    double m_volume;
    bool m_muted;
    
    NSInstrument * m_instrument;
    NSMutableArray * m_patterns;
    NSMutableArray * m_clips;
}
@property (retain, nonatomic) NSString * m_name;
@property (retain, nonatomic) NSInstrument * m_instrument;
@property (retain, nonatomic) NSMutableArray * m_patterns;
@property (retain, nonatomic) NSMutableArray * m_clips;

@property (nonatomic) double m_volume;
@property (nonatomic) bool m_muted;

// TODO: use a separate context save for these
@property (nonatomic) BOOL selectedPatternDidChange;
@property (nonatomic) int selectedPatternIndex; // TODO: convert to string
@property (retain, nonatomic) NSPattern * selectedPattern;
@property (nonatomic) BOOL isSelected;

- (id)initWithXMPNode:(XMPNode *)xmpNode;

- (id)initWithName:(NSString *)name volume:(double)volume muted:(bool)muted;

- (XMPNode *)convertToSongXmp;
- (XMPNode *)convertToSequenceXmp;

// Track Actions
- (void)setSelected:(BOOL)selected;
- (BOOL)isSelected;

// Track's Clip Actions
- (void)addClip:(NSClip *)clip;
- (NSClip *)firstClip;

// Track's Pattern Actions
- (void)addPattern:(NSPattern *)pattern;
- (NSPattern *)selectPattern:(int)newSelection;
- (void)turnOnAllFlags;
- (void)notePlayedAtString:(int)str andFret:(int)fret;

// Track's Pattern's Measure Actions
- (NSMeasure *)selectMeasure:(int)newSelection;
- (void)addMeasure;
- (void)removeMeasure;
- (void)clearSelectedMeasure;

// Playing Notes
- (void)playFret:(int)fret inRealMeasure:(int)measure withSound:(BOOL)sound withAmplitude:(double)amplitude;
- (void)displayAllNotes;
- (void)releaseSounds;

@end
