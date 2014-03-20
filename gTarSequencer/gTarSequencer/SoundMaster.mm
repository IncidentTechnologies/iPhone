//
//  SoundMaster.m
//  Sequence
//
//  Created by Kate Schnippering on 3/11/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "SoundMaster.h"
#import "SoundMaster_.mm"

@implementation SoundMaster

- (id)init
{
    self = [super init];
    if ( self )
    {
        [self initAudio];
    }
    return self;
}

- (void)initAudio
{
    if(TESTMODE) NSLog(@"Init Sound Master");
    
    audioController = [AudioController sharedAudioController];
    root = [[audioController GetNodeNetwork] GetRootNode];
    
    m_samplerNode = new SamplerNode;
    m_samplerNode->SetChannelGain(DEFAULT_VOLUME, CONN_OUT);
    
    root->ConnectInput(0, m_samplerNode, 0);
    [audioController startAUGraph];
}

-(void)start
{
    [audioController startAUGraph];
}

-(void)stop
{
   [audioController stopAUGraph];
}

-(SamplerBankNode *)generateBank
{
    SamplerBankNode * m_samplerBank = NULL;
    m_samplerNode->CreateNewBank(m_samplerBank);
    
    return m_samplerBank;
}

-(void)releaseBank:(SamplerBankNode *)m_samplerBank
{
    [audioController stopAUGraph];
    //m_samplerNode->ReleaseBank(0);
    m_samplerNode->ReleaseBank(m_samplerBank);
    [audioController startAUGraph];
}

-(void)releaseBankAndDisconnect:(SamplerBankNode *)m_samplerBank
{
    [audioController stopAUGraph];
    m_samplerNode->ReleaseBank(m_samplerBank);
    root->DeleteAndDisconnect(CONN_OUT);
    [audioController startAUGraph];
    
}

-(void)setChannelGain:(double)gain
{
    //[audioController stopAUGraph];
    m_samplerNode->SetChannelGain(gain, CONN_OUT);
    //[audioController startAUGraph];
}

-(void)setGain:(double)gain forSamplerBank:(SamplerBankNode *)m_samplerBank
{
    m_samplerBank->SetBankGain(gain);
}

@end
