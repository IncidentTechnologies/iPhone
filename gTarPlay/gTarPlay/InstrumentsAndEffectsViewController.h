//
//  Instruments&EffectsViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "JamPad.h"
#import "EffectsTableViewController.h"
#import <gtarAppCore/InstrumentTableViewController.h>
#import "SoundMaster.h"

#import <UIKit/UIKit.h>

@class AudioController;

@interface InstrumentsAndEffectsViewController : UIViewController <XYInputViewDelegate, EffectSelectionDelegate, InstrumentSelectionDelegate>

//- (id)initWithAudioController:(AudioController*)AC;
- (id)initWithSoundMaster:(SoundMaster*)SM;

- (void)displayInstruments;
- (void)displayEffects;

@end
