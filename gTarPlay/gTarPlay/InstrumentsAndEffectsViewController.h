//
//  Instruments&EffectsViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import <UIKit/UIKit.h>

@class AudioController;

@interface InstrumentsAndEffectsViewController : UIViewController

- (id)initWithAudioController:(AudioController*)AC;

- (void)displayInstruments;
- (void)displayEffects;

@end
