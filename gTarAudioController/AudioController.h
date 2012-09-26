//
//  AudioController.h
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <vector>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class Sampler;

class Effect;
class Parameter;

class Distortion;
class TanhDistortion;
class Overdrive;
class HardCutoffDistortion;
class SoftClippingOverdrive;
class FuzzExpDistortion;
class DelayEffect;
class ChorusEffect;
class Reverb;
class ButterWorthFilter;
class KSObject;
//namespace iZTrashFX { class TrashFXEngine; }
//namespace iZCoreFX { class CoreFXEngine; }
class Compressor;

enum AudioSource
{
    KarplusStrong,
    SamplerSource,
    SinWave,
    SawWave,
    SquareWave
};

@protocol AudioControllerDelegate <NSObject>
-(void) audioRouteChanged:(bool)routeIsSpeaker;
@end

@interface AudioController : NSObject 
{
	// Audio Graph Members
	AUGraph augraph;
	AudioUnit mixer;
    
    Sampler *m_sampler;
    
	// Sine Phase Indicator;
	double sinPhase;
	float frequency;
	
	AudioSource m_audioSource;
	
	KSObject *m_pksobjects;
	int m_pksobjects_n;
    
    ButterWorthFilter *m_pBwFilter;
    
    bool m_fNoteOn;
    
    ChorusEffect *m_pChorusEffect;
    DelayEffect *m_pDelayEffect;
    Distortion *m_pDistortion;
    Overdrive *m_pOverdrive;
    Reverb *m_pReverbEffect;
    TanhDistortion *m_pTanhDistortion;
    HardCutoffDistortion *m_pHardCutoffDistortion;
    SoftClippingOverdrive *m_pSoftClipOverdriveEffect;
    FuzzExpDistortion *m_pFuzzExpDistortion;
    
//    iZTrashFX::TrashFXEngine *m_pTrashFXEngine;
//    iZCoreFX::CoreFXEngine *m_pCoreFXEngine;
    
    ButterWorthFilter *m_pEndBwFilter;
    Float32 *m_tempOut;
    
    Compressor *m_pCompressor;
    
    // User visible and controllable effects
    std::vector<Effect*> m_effects;
    
}

@property (nonatomic, assign) id<AudioControllerDelegate> m_delegate;

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

- (void) setSamplePackWithName:(NSString*)name;
- (void) setSamplePackWithName:(NSString*)name withSelector:(SEL)aSelector andOwner:(NSObject*)parent;
- (void) setSamplePackWithIndex:(int)index withSelector:(SEL)aSelector andOwner:(NSObject*)parent;
- (void) samplerFinishedLoadingCB:(NSNumber*)result;

- (void) RouteAudioToSpeaker;
- (void) RouteAudioToDefault;
- (CFStringRef) GetAudioRoute;
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

//- (void) SetTrashEnabled:(bool)bEnabled;
//- (void) SetTrashDistortionAlgorithm:(unsigned int)uAlgorithm;
//- (void) SetIZotopeReverbEnabled:(bool)bEnabled;
//- (void) SetIZotopeReverbWet:(float)wet;
//- (void) SetReverbRoomSize:(float)roomSize;
//- (void) SetIZotopeReverbDamping:(float)damping;
//- (void) SetIzotopeReverbWidth:(float)width;
//
//- (void) SetLimiterParams:(double)threshold thrshldDb:(double)db r:(double)ratio a:(double)attackMs rel:(double)releaseMs;
//- (void) SetIZLimiterEnabled:(bool)bEnabled;

- (std::vector<Effect*>) GetEffects;

- (Parameter&) getReverbLFO;
- (Parameter&) getReverbExcursion;

- (NSArray*) getInstrumentNames;
- (int) getCurrentSamplePackIndex;

// AudioSession callbacks
void AudioControllerPropertyListener (void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData);

- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;
@end
