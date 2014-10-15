//
//  NSSampler.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSSample.h"

#import "SoundMaker.h"

@interface NSSampler : NSObject
{
    NSMutableArray * m_samples;
}

@property (retain, nonatomic) NSMutableArray * m_samples;
@property (retain, nonatomic) SoundMaker * audio;

-(id)initWithXMPNode:(XMPNode *)xmpNode;
- (id)initWithXmlDom:(XmlDom *)dom;

-(id)init;

- (void)initAudioWithInstrument:(int)index andSoundMaster:(SoundMaster *)soundMaster stringSet:(NSArray *)stringSet stringPaths:(NSArray *)stringPaths;

-(XMPNode *)convertToXmp;

-(void)addSample:(NSSample *)sample;

@end
