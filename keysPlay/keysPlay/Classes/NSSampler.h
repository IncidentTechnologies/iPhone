//
//  NSSampler.h
//  keysPlay
//
//  Created by Kate Schnippering on 1/6/15.
//
//

#import "AppCore.h"

#import "SoundMaster.h"

@class XmlDom;
@class NSSample;

@interface NSSampler : NSObject
{
    NSMutableArray * m_samples;
}

@property (retain, nonatomic) NSMutableArray * m_samples;
@property (retain, nonatomic) SoundMaster * audio;

- (id)initWithXmlDom:(XmlDom *)dom;

-(id)init;

- (void)initAudioWithInstrument:(int)index andName:(NSString *)name andSoundMaster:(SoundMaster *)soundMaster stringSet:(NSArray *)stringSet stringPaths:(NSArray *)stringPaths stringIds:(NSArray *)stringIds;

- (void)initAudioWithInstrument:(int)index andName:(NSString *)name andSoundMaster:(SoundMaster *)soundMaster;

-(void)addSample:(NSSample *)sample;


@end
