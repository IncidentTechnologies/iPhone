//
//  Measure.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "Measure.h"

@implementation Measure

@synthesize playband = playband;

- (id)init
{
    self = [super init];
    if (self)
    {
        for (int i=0;i<MAX_NOTES;i++)
        {
            notes[i] = false;
        }
        
        if(TESTMODE) [self initFakeNotes];
        
        [self sharedInit];
    }
    return self;
}

- (id)initWithMeasure:(Measure *)measure
{
    self = [super init];
    if (self)
    {
        for (int i=0;i<MAX_NOTES;i++)
        {
            notes[i] = [measure isNoteOnAtLocation:i];
        }
        
        [self sharedInit];
    }
    return self;
}

- (void)initFakeNotes
{
    int numnotes = random()%8;
    NSLog(@"initting for %i notes",numnotes);
    
    for(int i=0;i<numnotes;i++){
        int r = random()%MAX_NOTES;
        NSLog(@"at index %i",r);
        notes[r] = true;
    }
}

- (void)sharedInit
{
    playband = -1;
    
    guitarUpdateNotes = YES;
    guitarUpdatePlayband = YES;
    
    minimapUpdatePlayband = YES;
    minimapUpdateNotes = YES;
}

- (void)setPlayband:(int)newPlayband
{
    minimapUpdatePlayband = YES;
    guitarUpdatePlayband = YES;
    
    playband = newPlayband;
}

- (void)turnOnAllFlags
{
    [self turnOnGuitarFlags];
    [self turnOnMinimapFlags];
}

- (void)turnOnGuitarFlags
{
    guitarUpdateNotes = YES;
    guitarUpdatePlayband = YES;
}

- (void)turnOnMinimapFlags
{
    minimapUpdateNotes = YES;
    minimapUpdatePlayband = YES;
}

#pragma mark Should Update Playband

- (BOOL)shouldUpdatePlaybandOnGuitar
{
    return guitarUpdatePlayband;
}

- (BOOL)shouldUpdatePlaybandOnMinimap
{
    return minimapUpdatePlayband;
}

#pragma mark Done Updating Playband

- (void)setUpdatePlaybandOnGuitar:(BOOL)yesno
{
    guitarUpdatePlayband = yesno;
}

- (void)setUpdatePlaybandOnMinimap:(BOOL)yesno
{
    minimapUpdatePlayband = yesno;
}

#pragma mark Should Update Notes

- (BOOL)shouldUpdateNotesOnGuitar
{
    return guitarUpdateNotes;
}

- (BOOL)shouldUpdateNotesOnMinimap
{
    return minimapUpdateNotes;
}

#pragma mark Done Updating Notes

- (void)setUpdateNotesOnGuitar:(BOOL)yesno
{
    guitarUpdateNotes = yesno;
}

- (void)setUpdateNotesOnMinimap:(BOOL)yesno
{
    minimapUpdateNotes = yesno;
}

#pragma mark Playing Notes/Lights

- (void)playNotesAtFret:(int)fret withInstrument:(int)instrumentIndex andAudio:(SoundMaker *)audioSource
{
    if (instrumentIndex >= 0)
    {
        int startingLocation = fret * STRINGS_ON_GTAR;
        if(notes[startingLocation]) [audioSource PluckStringFret:0 atFret:0];
        if(notes[startingLocation+1]) [audioSource PluckStringFret:1 atFret:0];
        if(notes[startingLocation+2]) [audioSource PluckStringFret:2 atFret:0];
        if(notes[startingLocation+3]) [audioSource PluckStringFret:3 atFret:0];
        if(notes[startingLocation+4]) [audioSource PluckStringFret:4 atFret:0];
        if(notes[startingLocation+5]) [audioSource PluckStringFret:5 atFret:0];
        
        /*for (int i=0; i < STRINGS_ON_GTAR; i++)
        {
            if (notes[startingLocation+i])
            {
                [audioSource PluckStringFret:i atFret:0];
            }
        }*/
    }
    
    [self setPlayband:fret];
}

#pragma mark Change Note

- (void)changeNoteAtString:(int)str andFret:(int)fret
{
    guitarUpdateNotes = YES;
    minimapUpdateNotes = YES;
    
    int location = [self getLocationFromString:str andFret:fret];
    
    [self changeNoteStatusAtLocation:location];
}

- (void)changeNoteStatusAtLocation:(NSUInteger)location;
{
    notes[location] = !notes[location];
}

- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret
{
    int location = [self getLocationFromString:str andFret:fret];
    return notes[location];
}

- (BOOL)isNoteOnAtLocation:(int)location
{
    return notes[location];
}

#pragma mark Empty(ing)

- (void)clearNotes
{
    for (int i=0;i<MAX_NOTES;i++)
    {
        notes[i] = false;
    }
}

- (BOOL)isEmpty
{
    for (int i=0;i<MAX_NOTES;i++)
    {
        if (notes[i])
            return false;
    }
    return true;
}

#pragma mark Conversions

- (int)getLocationFromString:(int)str andFret:(int)fret
{
    return (str + fret*STRINGS_ON_GTAR);
}

#pragma mark Writing to Disk

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        NSString * tempString = [aDecoder decodeObjectForKey:@"MeasureNotes"];
        for (int i=0;i<96;i++)
        {
            char tempChar = [tempString characterAtIndex:i];
            notes[i] = tempChar - 48;
        }
        playband = -1;
        
        [self turnOnAllFlags];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSString * string = [[NSString alloc] initWithFormat:@""];
    for (int i=0;i<96;i++)
    {
        string = [string stringByAppendingFormat:@"%i", notes[i]];
    }
    
    [aCoder encodeObject:string forKey:@"MeasureNotes"];
}

@end