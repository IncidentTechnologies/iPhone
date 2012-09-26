//
//  BeatSequence.h
//  gTarSequencer
//
//  Created by Ilan Gray on 6/5/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Measure.h"

@interface Pattern : NSObject <NSCoding>
{
    int measureCount;

    Measure * selectedMeasure;
    int selectedMeasureIndex;
    
    NSMutableArray * measures;
}

- (void)playFret:(int)whichFret inRealMeasure:(int)realMeasure withInstrument:(int)instrumentIndex;
- (int)computeRealMeasureFromAbsolute:(int)absoluteMeasure;

- (void)changeNoteAtString:(int)str andFret:(int)fret;
- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret;

- (void)doubleMeasures;
- (void)halveMeasures;
- (void)clearSelectedMeasure;

- (void)turnOnAllFlags;

- (Measure *)selectMeasure:(NSUInteger)newSelection;

@property char selectionChanged;
@property char countChanged;
@property (nonatomic) int selectedMeasureIndex;
@property (nonatomic) int measureCount;
@property (nonatomic) Measure * selectedMeasure;
@property (nonatomic, readonly) NSMutableArray * measures;

@end
