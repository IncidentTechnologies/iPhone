//
//  FreePlayAudioController.h
//  keysPlay
//
//  Created by Kate Schnippering on 4/8/14.
//
//

#import "AppCore.h"
#import "OphoMaster.h"

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
    
    OphoMaster * ophoMaster;
    
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
- (void) setCurrentInstrumentByXmpId:(NSInteger)xmpId withSelector:(SEL)cb andOwner:(id)sender;
- (void) setCurrentInstrument:(NSInteger)index withSelector:(SEL)cb andOwner:(id)sender;
- (NSInteger) getCurrentInstrument;
- (NSArray *) getInstrumentList;
- (NSInteger) getIndexForInstrument:(NSString *)instrumentName;

- (void) routeToSpeaker;
- (void) routeToDefault;
- (NSString *) getAudioRoute;

- (void) setChannelGain:(float)gain;
- (float) getChannelGain;

- (void) playMetronomeTick;
- (void) playKey:(int)key withDuration:(double)duration;
- (void) playMutedKey:(int)key;


- (void) enableSliding;
- (void) disableSliding;
- (BOOL) isSlideEnabled;

- (bool) NoteOnForKey:(int)key withDuration:(double)duration;
- (bool) NoteOffForKey:(int)key;

@property (strong) NSArray *m_instruments;
//@property (strong) NSArray *m_tuning;
//@property (strong) NSArray *m_standardTuning;

@end
