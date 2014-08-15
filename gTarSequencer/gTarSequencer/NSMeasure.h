//
//  NSMeasure.h
//  Sequence
//
//  Created by Kate Schnippering on 8/14/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "GtarController.h"
#import "SoundMaker.h"

#define FIRST_FRET 0
#define LAST_FRET 15

@interface NSMeasure : NSObject
{
    char notes[MAX_NOTES];
    
    BOOL guitarUpdateNotes;
    BOOL guitarUpdatePlayband;
    BOOL minimapUpdateNotes;
    BOOL minimapUpdatePlayband;

}

@property (nonatomic, readwrite) int playband;
@property (nonatomic) bool activated;

- (id)init;
- (id)initWithMeasure:(NSMeasure *)measure;

- (void)playNotesAtFret:(int)fret withInstrument:(int)instrumentIndex andAudio:(SoundMaker *)audioSource withAmplitudeWeight:(double)amplitudeweight;

- (void)changeNoteAtString:(int)str andFret:(int)fret;
- (BOOL)isNoteOnAtString:(int)str andFret:(int)fret;

- (void)clearNotes;
- (BOOL)isEmpty;

- (char *)getNotes;

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
