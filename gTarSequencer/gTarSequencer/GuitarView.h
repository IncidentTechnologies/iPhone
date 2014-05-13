//
//  GuitarView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/23/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "GtarController.h"
#import "Measure.h"

@protocol GuitarViewDelegate <NSObject>

- (void)notePlayedAtString:(int)str andFret:(int)fr;
- (void)gtarConnected:(BOOL)toConnect;

@end

// GuitarView governs all interaction with the gTar. It receives direct input from the gTar and passes it up to the controller
//      as well as receiving input from the controller about what to change on the gTar. Another function of the GuitarView is
//      to act similarly to MeasureView, in that it displays a single measure to the gTar fretboard. Like MV, it has a measure ptr
//      and pulls the necessary data when updating. The user must manage the Measure ptr and make sure it accurately reflects
//      whichever measure should be displayed to the gTar.
@interface GuitarView : NSObject <GtarControllerObserver>
{
    char notesOn[STRINGS_ON_GTAR][FRETS_ON_GTAR];
    
    int playband;
}

@property (retain, nonatomic) GtarController * guitar;
@property (weak, nonatomic) Measure * measure;
@property (weak, nonatomic) id <GuitarViewDelegate> delegate;

- (void)turnOffEffects;
- (void)update;
- (void)clearData;
- (void)observeGtar;
- (BOOL)isGtarConnected;
@end
