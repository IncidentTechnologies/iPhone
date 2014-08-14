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

@interface NSTrack : NSObject
{
    NSString * m_name;
    double m_volume;
    bool m_muted;
    
    NSInstrument * m_instrument;
    NSMutableArray * m_patterns;
}
@property (retain, nonatomic) NSString * m_name;
@property (retain, nonatomic) NSInstrument * m_instrument;
@property (retain, nonatomic) NSMutableArray * m_patterns;

@property (nonatomic) double m_volume;
@property (nonatomic) bool m_muted;

// TODO: use a separate context save for these
@property (nonatomic) BOOL selectedPatternDidChange;
@property (retain, nonatomic) NSString * selectedPatternIndex; // key into the patterns
@property (retain, nonatomic) NSPattern * selectedPattern;
@property (nonatomic) BOOL isSelected;


-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithName:(NSString *)name volume:(double)volume muted:(bool)muted;

-(XMPNode *)convertToXmp;

-(void)addPattern:(NSPattern *)pattern;

/*
 
 - (void)playFret:(int)fret inRealMeasure:(int)measure withSound:(BOOL)sound withAmplitude:(double)amplitude;
 
 - (Pattern *)selectPattern:(int)newSelection;
 - (Measure *)selectMeasure:(int)newSelection;
 
 - (void)initAudioWithInstrumentName:(NSString *)instName andSoundMaster:(SoundMaster *)soundMaster;
 - (void)notePlayedAtString:(int)str andFret:(int)fret;
 
 - (void)addMeasure;
 - (void)removeMeasure;
 - (void)clearSelectedMeasure;
 
 - (void)displayAllNotes;
 
 - (void)setSelected:(BOOL)yesno;
 - (BOOL)isSelected;
 
 - (void)setCustom:(BOOL)yesno;
 - (BOOL)checkIsCustom;
 
 - (int)selectedPatternIndex;
 
 - (void)turnOnAllFlags;
 
 - (void)releaseSounds;
 
 - (double)getAmplitude;
 
 */

@end
