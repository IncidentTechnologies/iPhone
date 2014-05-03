//
//  FreePlayAudioController.h
//  gTarPlay
//
//  Created by Kate Schnippering on 4/8/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AudioController;

@interface SoundMaster : NSObject
{
    NSInteger currentInstrumentIndex;
    
    NSInteger numEffects;
    NSInteger numInstruments;
    NSArray * effectNames;
    NSMutableArray * effectStatus;
    
    BOOL isLoadingInstrument;
    
    NSTimer * releaseTimer;
    
}

- (void) reset;
- (void) start;
- (void) stop;
- (void) releaseAfterUse;
- (void) releaseCompletely;

- (void) stopAllEffects;
- (void) toggleEffect:(NSInteger)index isOn:(BOOL)on;
- (NSInteger) getNumEffects;
- (NSString *) getEffectNameAtIndex:(NSInteger)index;
- (BOOL) isEffectOnAtIndex:(NSInteger)index;
- (CGPoint) getPointForEffectAtIndex:(NSInteger)index;
- (void)adjustEffectAtIndex:(NSInteger)index toPoint:(CGPoint)position;

- (void) didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender;
- (void) setCurrentInstrument:(NSInteger)index;
- (NSInteger) getCurrentInstrument;
- (NSArray *) getInstrumentList;
- (NSInteger) getIndexForInstrument:(NSString *)instrumentName;

- (void) routeToSpeaker;
- (void) routeToDefault;
- (NSString *) getAudioRoute;

- (void) setChannelGain:(float)gain;

- (void) PluckString:(int)string atFret:(int)fret;
//- (void) PluckString:(int)string atFret:(int)fret withAmplitude:(float)amp;
//- (void) PluckMutedString:(int)string;
//- (void) SetAttentuation:(float)atten;
//- (void) SetKSAttenuation:(float)atten forString:(int)string;
//- (bool) SetAttenuationVariation:(float)variation;

// TODO: go into BW filter
- (bool) SetBWCutoff:(double)cutoff;
// - (bool) SetBWOrder:(int)order;

// TODO: go into KS BW filter
// - (bool) SetKSBWCutoff:(double)cutoff;
// - (bool) SetKSBWOrder:(int)order;

// TODO: go into guitar model
 - (bool) FretDown:(int)fret onString:(int)string;
 - (bool) FretUp:(int)fret onString:(int)string;

 - (bool) NoteOnAtString:(int)string andFret:(int)fret;
 - (bool) NoteOffAtString:(int)string andFret:(int)fret;

@property (strong) NSArray *m_instruments;
@property (strong) NSArray *m_tuning;
@property (strong) NSArray *m_standardTuning;

@end
