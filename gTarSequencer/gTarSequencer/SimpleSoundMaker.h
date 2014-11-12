//
//  SimpleSoundMaker.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 11/12/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "SoundMaster.h"
#import "UILevelSlider.h"

@class AudioController;
extern OphoMaster * g_ophoMaster;

@interface SimpleSoundMaker : NSObject
{
    NSMutableArray * bankSamples;
}

- (id)init;
- (id)initWithSoundMaster:(SoundMaster *)soundMaster;

- (void)addSingleSampleByName:(NSString *)filename useBundle:(BOOL)useBundle;
- (void)playSingleSample;
- (void)pauseSingleSample;
- (void)resumeSingleSample;
- (void)saveSingleSampleToFilepath:(NSString *)filepath;
- (void)setSampleStart:(float)ms;
- (void)setSampleEnd:(float)ms;
- (unsigned long int)fetchAudioBufferSize;
- (float)fetchSampleRate;
- (float *)fetchAudioBuffer;
- (float)getSampleLength;

- (void)addBase64Sample:(NSString *)datastring forXmpId:(NSInteger)xmpId;
- (void)playSampleForXmpId:(NSInteger)xmpId;
- (BOOL)sampleForXmpId:(NSInteger)xmpId;

- (void)releaseAll;
- (void)releaseSounds;

@end
