//
//  Pattern.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "Pattern.h"

@implementation Pattern

@synthesize selectedMeasureIndex;
@synthesize measureCount;
@synthesize measures;
@synthesize selectedMeasure;
@synthesize countChanged;
@synthesize selectionChanged;

- (id)init
{
    self = [super init];
    if (self)
    {
        measures = [[NSMutableArray alloc] init];
        
        Measure * firstMeasure = [[Measure alloc] init];
        [measures addObject:firstMeasure];
        
        measureCount = [measures count];
        
        selectedMeasureIndex = 0;
        selectedMeasure = [measures objectAtIndex:selectedMeasureIndex];
        
        selectionChanged = YES;
        countChanged = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        measures = [aDecoder decodeObjectForKey:@"Measures List"];
        measureCount = [measures count];
        
        selectedMeasureIndex = [aDecoder decodeIntForKey:@"Selected Measure Index"];
        selectedMeasure = [measures objectAtIndex:selectedMeasureIndex];
        
        selectionChanged = YES;
        countChanged = YES;
    }
    return self;
}

- (void)setMeasureCount:(int)newMeasureCount
{
    measureCount = newMeasureCount;
    countChanged = YES;
}

- (void)setSelectedMeasureIndex:(int)newSelectedMeasureIndex
{
    selectedMeasureIndex = newSelectedMeasureIndex;
    selectionChanged = YES;
}

- (void)setSelectedMeasure:(Measure *)newSelectedMeasure
{
    selectedMeasure = newSelectedMeasure;
    selectionChanged = YES;
}

#pragma mark Play/pause

- (void)playFret:(int)whichFret inRealMeasure:(int)realMeasure withInstrument:(int)instrumentIndex andAudio:(SoundMaker *)audioSource withAmplitude:(double)amplitude
{
    // Remove old playband:
    for (Measure * m in measures)
    {
        [m setPlayband:-1];
    }
    
    // Add new one:
    [[measures objectAtIndex:realMeasure] playNotesAtFret:whichFret withInstrument:instrumentIndex andAudio:audioSource withAmplitudeWeight:amplitude];
}

- (int)computeRealMeasureFromAbsolute:(int)absoluteMeasure
{
    if ( [measures count] == 4 )
    {
        return absoluteMeasure;
    }
    else if ( [measures count] == 2 )
    {
        if ( (absoluteMeasure + 1) % 2 == 0 )     // if absoluteMeasure is even
        {
            return 1;
        }
        else {                              // else, its odd
            return 0;
        }
    }
    else if ( [measures count] == 1 )
    {
        return 0;
    }
    else {
        NSLog(@"GIVEN BAD ABSOLUTE MEASURE TO PLAY");
        return -1;
    }
}

#pragma mark Change Note

- (void)changeNoteAtString:(int)str andFret:(int)fret
{
    [selectedMeasure changeNoteAtString:str andFret:fret];
}

- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret
{
    return [selectedMeasure isNoteOnAtString:str andFret:fret];
}

#pragma mark Add/Remove Measures

- (void)doubleMeasures
{
    NSLog(@"Doubling measures");
    
    countChanged = YES;
    
    int previousCount = measureCount;
    measureCount *= 2;
    
    for (int i=0;i<previousCount;i++)
    {
        Measure * oldMeasure = [measures objectAtIndex:i];
        [oldMeasure setUpdateNotesOnMinimap:YES];
        
        Measure * newMeasure = [[Measure alloc] initWithMeasure:oldMeasure];
        [measures addObject:newMeasure];
    }
    
    [self selectMeasure:selectedMeasureIndex+1];
}

- (void)halveMeasures
{
    NSLog(@"halving measures");
    
    countChanged = YES;
    
    int previousCount = measureCount;
    measureCount /= 2;
    
    int difference = previousCount - measureCount;
    
    for (int i=0;i<difference;i++){
        [measures removeLastObject];
    }
    
    if (selectedMeasureIndex >= [measures count]){
        [self selectMeasure:[measures count] - 1];
    }
}

#pragma mark Clearing Measures

- (void)clearSelectedMeasure
{
    [selectedMeasure clearNotes];
}

#pragma mark Selecting Measures

- (Measure *)selectMeasure:(NSUInteger)newSelection
{
    selectedMeasureIndex = newSelection;
    selectedMeasure = [measures objectAtIndex:newSelection];
    
    [selectedMeasure turnOnAllFlags];
    selectionChanged = YES;
    
    return selectedMeasure;
}

- (void)turnOnAllFlags
{
    countChanged = YES;
    selectionChanged = YES;
    
    for (Measure * m in measures)
    {
        [m turnOnAllFlags];
    }
}

#pragma mark Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:measures forKey:@"Measures List"];
    [aCoder encodeInt:selectedMeasureIndex forKey:@"Selected Measure Index"];
}

@end