//
//  SoundMaster_.mm
//  Sequence
//
//  Created by Kate Schnippering on 3/11/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "SoundMaster.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"
#import "EnvelopeNode.h"

@interface SoundMaster () {
    
    LevelSubscriber *m_volumeSubscriber;
    
    AudioController *audioController;
    AudioNode *root;
    
    SamplerNode * m_samplerNode;
    GtarSamplerNode *m_gtarSamplerNode;
    
    EnvelopeNode * m_envelopeNode;
    ChorusEffectNode * m_chorusEffectNode;
    
    int m_activeBankNode;
    
    double masterGain;
    
    NSString * recordingFilepath;
    
}

-(SamplerBankNode *)generateBank;
-(void)releaseBank:(SamplerBankNode *)samplerBank;
-(void)releaseBankAndDisconnect:(SamplerBankNode *)samplerBank;
-(void)loadSample:(char *)filepath intoBank:(SamplerBankNode *)samplerBank;
-(void)triggerSample:(int)sample forBank:(SamplerBankNode *)samplerBank;

-(FileoutNode *)generateFileoutNode:(NSString *)filename;

-(void)setChannelGain:(double)gain;
-(void)setGain:(double)gain forSamplerBank:(SamplerBankNode *)m_samplerBank;

-(void)flushBuffer;
//-(NSString *)showRecordingFilepath;

@end
