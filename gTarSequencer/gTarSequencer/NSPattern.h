//
//  NSPattern.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSNote.h"
#import "NSMeasure.h"
#import "SoundMaker.h"

@interface NSPattern : NSObject
{
    NSString * m_name;
    bool m_on;
    
    NSMutableArray * m_notes;
    
    // archaic
    
    int measureCount;
    
    NSMeasure * selectedMeasure;
    int selectedMeasureIndex;
    
    NSMutableArray * m_measures;
}

@property (retain, nonatomic) NSString * m_name;
@property (nonatomic) bool m_on;
@property (nonatomic, retain) NSMutableArray * m_notes;

@property char selectionChanged;
@property char countChanged;
@property (nonatomic) int selectedMeasureIndex;
@property (nonatomic) int measureCount;
@property (nonatomic) NSMeasure * selectedMeasure;
@property (nonatomic, readonly) NSMutableArray * m_measures;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)initWithName:(NSString *)name on:(bool)on;

-(XMPNode *)convertToXmp;

- (void)addNote:(NSNote *)note;
- (void)addMeasure:(NSMeasure *)measure;

- (void)turnOnAllFlags;

- (void)changeNoteAtString:(int)str andFret:(int)fret forMeasure:(NSMeasure *)measure;
- (void)doubleMeasures:(BOOL)duplicate;
- (void)halveMeasures;
- (void)clearSelectedMeasure;

- (NSMeasure *)selectMeasure:(NSUInteger)newSelection;

/********* archaic ***********/

- (void)playFret:(int)whichFret inRealMeasure:(int)realMeasure withInstrument:(int)instrumentIndex andAudio:(SoundMaker *)audioSource withAmplitude:(double)amplitude;
- (int)computeRealMeasureFromAbsolute:(int)absoluteMeasure;

- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret;

//

@end
