//
//  SoundMakerInterface.m
//  Sequence
//
//  Created by Kate Schnippering on 3/11/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "SoundMaster.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

@interface SoundMaster () {
    
    SamplerNode *m_samplerNode;
    AudioController *audioController;
    AudioNode *root;
    
    SamplerBankNode * bankToRelease;
    
    double masterGain;
    
    NSString * recordingFilepath;
}

-(SamplerBankNode *)generateBank;
-(void)releaseBank:(SamplerBankNode *)m_samplerBank;
-(void)releaseBankAndDisconnect:(SamplerBankNode *)m_samplerBank;

-(FileoutNode *)generateFileoutNode:(NSString *)filename;

-(void)setChannelGain:(double)gain;
-(void)setGain:(double)gain forSamplerBank:(SamplerBankNode *)m_samplerBank;

-(void)flushBuffer;
//-(NSString *)showRecordingFilepath;

@end
