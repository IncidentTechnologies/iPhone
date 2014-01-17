//
//  Instrument.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "Instrument.h"

@implementation Instrument

@synthesize instrumentName;
@synthesize iconName;
@synthesize instrument;
@synthesize stringSet;
@synthesize selectedPattern;
@synthesize selectedPatternDidChange;
@synthesize isMuted;

- (id)init
{
    self = [super init];
    if (self)
    {
        patterns = [[NSMutableArray alloc] init];
        for (int i=0;i<MAX_BEAT_SEQUENCES;i++)
        {
            Pattern * bs = [[Pattern alloc] init];
            [patterns addObject:bs];
        }
        selectedPatternIndex = 0;
        selectedPattern = [patterns objectAtIndex:0];
        
        isSelected = NO;
        selectedPatternDidChange = YES;
        isMuted = NO;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if ( self )
    {
        instrument = [aDecoder decodeIntForKey:@"Instrument"];
        
        patterns = [aDecoder decodeObjectForKey:@"Patterns"];
        
        selectedPatternIndex = [aDecoder decodeIntForKey:@"Selected Pattern Index"];
        selectedPattern = [patterns objectAtIndex:selectedPatternIndex];
        
        instrumentName = [aDecoder decodeObjectForKey:@"Instrument Name"];
        iconName = [aDecoder decodeObjectForKey:@"Icon Name"];
        
        isSelected = [aDecoder decodeBoolForKey:@"Is Selected"];
        
        stringSet = [aDecoder decodeObjectForKey:@"Strings"];
        
        selectedPatternDidChange = YES;
        
    }
    return self;
}

- (void)initAudioWithInstrumentName:(NSString *)instName
{
    audio = [[SoundMaker alloc] initWithInstrumentName:instName];
    
}

- (void)setSelected:(BOOL)yesno
{
    isSelected = yesno;
    
    if ( yesno == YES )
    {
        selectedPattern.selectionChanged = YES;
    }
}

- (BOOL)isSelected
{
    return isSelected;
}

- (void)turnOnAllFlags
{
    selectedPatternDidChange = YES;
    [selectedPattern turnOnAllFlags];
}

#pragma Playing Notes

// Play audio:
- (void)playFret:(int)fret inRealMeasure:(int)measure withSound:(BOOL)sound
{
    if (sound)
        [selectedPattern playFret:fret inRealMeasure:measure withInstrument:instrument andAudio:audio];
    else
        [selectedPattern playFret:fret inRealMeasure:measure withInstrument: -1 andAudio:audio];
}

- (void)displayAllNotes {
    for (Measure * m in selectedPattern.measures)
        [m setUpdateNotesOnMinimap:YES];
}

- (int)selectedPatternIndex
{
    return selectedPatternIndex;
}

#pragma mark Adding/Removing Measures

- (void)addMeasure
{
    if ( selectedPattern.measureCount == MAX_BEAT_SEQUENCES )
    {
        return;
    }
    
    // Update data structure:
    [selectedPattern doubleMeasures];
}

- (void)removeMeasure {
    
    if (selectedPattern.measureCount == 1){
        return;
    }
    
    @synchronized(selectedPattern){
        // Remove half the measures:
        [selectedPattern halveMeasures];
    }
}

- (void)clearSelectedMeasure {
    [selectedPattern clearSelectedMeasure];
}

#pragma mark Selecting Measures

- (Measure *)selectMeasure:(int)newSelection {
    Measure * newlySelectedMeasure = [selectedPattern selectMeasure:newSelection];
    return newlySelectedMeasure;
}

#pragma mark Selecting Beat Sequences

- (Pattern *)selectPattern:(int)newSelection
{
    // -- update flag
    selectedPatternDidChange = YES;
    
    // -- remove playband from old beat seq
    selectedPattern.selectedMeasure.playband = -1;
    
    // -- formally select new beat seq
    selectedPatternIndex = newSelection;
    selectedPattern = [patterns objectAtIndex:selectedPatternIndex];
    
    // -- update beat seq's flags
    [selectedPattern turnOnAllFlags];
    
    return selectedPattern;
}

#pragma mark Guitar Functions

- (void)notePlayedAtString:(int)str andFret:(int)fret
{
    [selectedPattern changeNoteAtString:str andFret:fret];
}

#pragma mark Saving To Disk

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:patterns forKey:@"Patterns"];
    [aCoder encodeInt:instrument forKey:@"Instrument"];
    [aCoder encodeInt:selectedPatternIndex forKey:@"Selected Pattern Index"];
    [aCoder encodeObject:instrumentName forKey:@"Instrument Name"];
    [aCoder encodeObject:iconName forKey:@"Icon Name"];
    [aCoder encodeBool:isSelected forKey:@"Is Selected"];
    [aCoder encodeObject:stringSet forKey:@"Strings"];
}

@end

