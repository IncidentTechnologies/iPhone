//
//  SoundMaker.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "SoundMaster.h"
#import "UILevelSlider.h"
//#import "NSInstrument.h"

@class AudioController;
extern OphoMaster * g_ophoMaster;

// Serves as a wrapper class for the AudioController, because
//      whoever #imports the AC (or a file that #imports the AC)
//      needs to be a .mm file. This prevents refactoring, which
//      I find to be a useful tool, so i made this dummy class.
@interface SoundMaker : NSObject
{
    int instIndex;
}

- (id)initWithInstrumentId:(NSInteger)instId andName:(NSString *)instName andSamples:(NSArray *)instSamples andSoundMaster:(SoundMaster *)soundMaster;

- (id)initWithStringSamples:(NSArray *)stringSet andInstrument:(int)index andSoundMaster:(SoundMaster *)soundMaster;

- (void)instrumentLoadedWithSamples:(NSArray *)samples;

- (void)pluckString:(int)str;
- (void)flushBuffer;

- (void)updateAmplitude:(double)amplitude;
- (void)updateMasterAmplitude:(double)amplitude;

- (void)releaseSounds;

- (void)releaseLevelSlider;
- (void)commitLevelSlider:(UILevelSlider *)slider;

@end
