//
//  AudioController.h
//  AudioController
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class Sampler;

typedef enum {
    KarplusStrong,
    SamplerSource,
    SinWave,
    SawWave,
    SquareWave
} AudioSource;

@interface AudioController : NSObject
{
	// Audio Graph Members
	AUGraph augraph;
	AudioUnit mixer;
    
    Sampler *m_sampler;
    
	// Sine Phase Indicator;
	double sinPhase;
	float frequency;
	
    Float32 *m_tempOut;
}

@property (assign) float frequency;
@property (assign) double sinPhase;
@property (assign) bool m_fNoteOn;

@property (assign) bool m_LimiterOn;

@property (assign) float m_volumeGain;

- (id) initWithAudioSource:(AudioSource)audioSource AndInstrument:(NSString*)instrument;
- (void) initializeAUGraph;
- (void) startAUGraph;
- (void) stopAUGraph;
- (void) reset;
- (void) ClearOutEffects;

- (bool) setSamplePackWithName:(NSString*)name;
- (void) setSamplePackWithName:(NSString*)name withSelector:(SEL)aSelector andOwner:(NSObject*)parent;
- (void) setSamplePackWithIndex:(int)index withSelector:(SEL)aSelector andOwner:(NSObject*)parent;
- (void) samplerFinishedLoadingCB:(NSNumber*)result;

- (void) RouteAudioToSpeaker;
- (void) RouteAudioToDefault;
- (CFStringRef) GetAudioRoute;
- (void) requestAudioRouteDetails;
- (void) AnnounceAudioRouteChange;

- (void) SetAudioSource:(AudioSource)audioSource;
- (void) SetWaveFrequency:(float)freq;

- (void) PluckString:(int)string atFret:(int)fret;
- (void) PluckString:(int)string atFret:(int)fret withAmplitude:(float)amp;
- (void) PluckMutedString:(int)string;
- (void) SetAttentuation:(float)atten;
- (void) SetKSAttenuation:(float)atten forString:(int)string;
- (bool) SetAttenuationVariation:(float)variation;

- (bool) SetBWCutoff:(double)cutoff;
- (bool) SetBWOrder:(int)order;

- (bool) SetKSBWCutoff:(double)cutoff;
- (bool) SetKSBWOrder:(int)order;

- (bool) FretDown:(int)fret onString:(int)string;
- (bool) FretUp:(int)fret onString:(int)string;

- (bool) NoteOnAtString:(int)string andFret:(int)fret;
- (bool) NoteOffAtString:(int)string andFret:(int)fret;

- (bool) SetReverbWet:(double)wet;
- (bool) SetReverbPassThrough:(bool)passThrough;
- (bool) SetReverbBandwidth:(double)bandwidth;
- (bool) SetReverbDamping:(double)damping;
- (bool) SetReverbDecay:(double)decay;
- (bool) SetReverbInputDiffusion1:(double)inputDiffusion1;
- (bool) SetReverbInputDiffusion2:(double)inputDiffusion2;
- (bool) SetReverbDecayDiffusion1:(double)decayDiffusion1;
- (bool) SetReverbDecayDiffusion2:(double)decayDiffusion2;
- (bool) SetPreDelayLineLength:(double)scale;
- (bool) SetDelayLineL1Length:(double)length;
- (bool) SetDelayLineL2Length:(double)length;
- (bool) SetDelayLineR1Length:(double)length;
- (bool) SetDelayLineR2Length:(double)length;
- (bool) SetDistortion2PassThrough:(bool)passThrough;
- (bool) SetTanhDistortionPosFactor:(double)factor;
- (bool) SetTanhDistortionNegFactor:(double)factor;
- (bool) SetCutffDistortionPassThrough:(bool)passThrough;
- (bool) SetCutoffDistortionCutoff:(double)cutoff;
- (bool) SetOverdrivePassThru:(bool)passThru;
- (bool) SetOverdrive:(double)gain;
- (bool) SetSoftClipOverdrivePassThru:(bool)passThru;
- (bool) SetSoftClipOverdriveThreshold:(double)threshold;
- (bool) SetSoftClipOverdriveMultiplier:(double)multiplier;
- (bool) SetFuzzExpPassThru:(bool)passThru;
- (bool) SetFuzzExpGain:(double)gain;

- (void) SetKS3rdOrderHarmonicOn:(bool)on;
- (void) SetKS5thOrderHarmonicOn:(bool)on;
- (bool) SetKSNoiseScale:(float)scale;
- (bool) SetKSNoiseVariation:(float)variation;
- (void) SetKSSawToothOn:(bool)on;
- (bool) SetKSSawToothMultiplier:(float)multiplier;
- (void) SetKSSqWaveOn:(bool)on;
- (bool) SetKSSqWaveMultiplier:(float)multiplier;

- (NSArray*) GetEffects;
- (NSArray*) getEffectNames;

- (NSArray*) getInstrumentNames;
- (int) getCurrentSamplePackIndex;

void AudioInterruptionListener (
                             void     *inClientData,
                             UInt32   inInterruptionState
                             );

// AudioSession callbacks
void AudioControllerPropertyListener (void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData);

//- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;
@end
