//
//  Sequencer.h
//  gTarSequencer
//
//  Created by Ilan Gray on 6/4/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GuitarController.h"
#import "Pattern.h"
#import "SoundMaker.h" 

#define MAX_BEAT_SEQUENCES 4
#define FIRST_FRET 0
#define LAST_FRET 15

extern SoundMaker * audio;
extern GuitarController * guitar;

@interface Instrument : NSObject <NSCoding>
{
    BOOL isSelected;
    
    int selectedPatternIndex;
    
    NSMutableArray * patterns;
}

- (void)playFret:(int)fret inRealMeasure:(int)measure withSound:(BOOL)sound;

- (Pattern *)selectPattern:(int)newSelection;
- (Measure *)selectMeasure:(int)newSelection;

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
@property (retain, nonatomic) Pattern * selectedPattern;
@property (nonatomic) BOOL selectedPatternDidChange;
@property (nonatomic) BOOL isMuted;

@end
