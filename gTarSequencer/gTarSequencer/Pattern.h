//
//  Pattern.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
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
