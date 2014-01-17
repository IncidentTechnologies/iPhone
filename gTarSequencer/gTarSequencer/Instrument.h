//
//  Instrument.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <GtarController/GtarController.h>
#import "Pattern.h"
#import "SoundMaker.h"

#define MAX_BEAT_SEQUENCES 4
#define FIRST_FRET 0
#define LAST_FRET 15

//extern GtarController * guitar;

@interface Instrument : NSObject <NSCoding>
{
    BOOL isSelected;
    
    int selectedPatternIndex;
    
    NSMutableArray * patterns;
    
    SoundMaker * audio;
    
}

- (void)playFret:(int)fret inRealMeasure:(int)measure withSound:(BOOL)sound;

- (Pattern *)selectPattern:(int)newSelection;
- (Measure *)selectMeasure:(int)newSelection;

- (void)initAudioWithInstrumentName:(NSString *)instName;
- (void)notePlayedAtString:(int)str andFret:(int)fret;

- (void)addMeasure;
- (void)removeMeasure;
- (void)clearSelectedMeasure;

- (void)displayAllNotes;

- (void)setSelected:(BOOL)yesno;
- (BOOL)isSelected;

- (int)selectedPatternIndex;

- (void)turnOnAllFlags;

@property (nonatomic) int instrument;
@property (retain, nonatomic) NSString * instrumentName;
@property (retain, nonatomic) NSString * iconName;
@property (retain, nonatomic) NSArray * stringSet;

@property (retain, nonatomic) Pattern * selectedPattern;
@property (nonatomic) BOOL selectedPatternDidChange;
@property (nonatomic) BOOL isMuted;

@end
