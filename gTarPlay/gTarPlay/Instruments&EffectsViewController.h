//
//  Instruments&EffectsViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import <UIKit/UIKit.h>

@class AudioController;

@interface Instruments_EffectsViewController : UIViewController

- (id)initWithAudioController:(AudioController*)AC instrumentList:(NSArray*)instruments;

@end
