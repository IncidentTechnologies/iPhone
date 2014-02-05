//
//  Measure.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <GtarController/GtarController.h>
#import "AppData.h"
#import "SoundMaker.h"

#define MAX_NOTES 96
#define FIRST_FRET 0
#define LAST_FRET 15
#define FRETS_ON_GTAR 16
#define STRINGS_ON_GTAR 6

//extern SoundMaker * audio;

// A Measure containts 6*16 = 96 notes. It also contains the flags
//      that indicate whether things should be updated.
@interface Measure : NSObject <NSCoding>
{
    char notes[MAX_NOTES];
    
    BOOL guitarUpdateNotes;
    BOOL guitarUpdatePlayband;
    BOOL minimapUpdateNotes;
    BOOL minimapUpdatePlayband;
}

@property (nonatomic, readwrite) int playband;

- (id)init;
- (id)initWithMeasure:(Measure *)measure;

- (void)playNotesAtFret:(int)fret withInstrument:(int)instrumentIndex andAudio:(SoundMaker *)audioSource withAmplitudeWeight:(double)amplitudeweight;

- (void)changeNoteAtString:(int)str andFret:(int)fret;
- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret;

- (void)clearNotes;
- (BOOL)isEmpty;

- (BOOL)shouldUpdatePlaybandOnGuitar;
- (BOOL)shouldUpdatePlaybandOnMinimap;
- (BOOL)shouldUpdateNotesOnGuitar;
- (BOOL)shouldUpdateNotesOnMinimap;

- (void)turnOnAllFlags;
- (void)turnOnGuitarFlags;
- (void)turnOnMinimapFlags;
- (void)setUpdateNotesOnGuitar:(BOOL)yesno;
- (void)setUpdateNotesOnMinimap:(BOOL)yesno;
- (void)setUpdatePlaybandOnGuitar:(BOOL)yesno;
- (void)setUpdatePlaybandOnMinimap:(BOOL)yesno;

@end

