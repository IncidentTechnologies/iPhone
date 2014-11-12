//
//  SoundMaster.mm
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
    DLog(@"Init Sound Master");
    
    audioController = [AudioController sharedAudioController];
    root = [[audioController GetNodeNetwork] GetRootNode];
    
    m_samplerNode = new SamplerNode;
    [self setChannelGain:DEFAULT_VOLUME];
    
    root->ConnectInput(0, m_samplerNode, 0);
    
    [self start];
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

-(void)releaseBank:(SamplerBankNode *)samplerBank
{
    [audioController stopAUGraph];
    //m_samplerNode->ReleaseBank(0);
    m_samplerNode->ReleaseBank(samplerBank);
    [audioController startAUGraph];
}

-(void)releaseBankWithoutPause:(SamplerBankNode *)samplerBank
{
    samplerBank->StopAllSamples();
    m_samplerNode->ReleaseBank(samplerBank);
}

-(void)releaseBankAndDisconnect:(SamplerBankNode *)m_samplerBank
{
    [audioController stopAUGraph];
    m_samplerNode->ReleaseBank(m_samplerBank);
    root->DeleteAndDisconnect(CONN_OUT);
    [audioController startAUGraph];
    
}

-(void)reset
{
    m_samplerNode->StopAllBankSamples();
}

-(void)setChannelGain:(double)gain
{
    if(masterGain != gain){
        
        DLog(@"Setting channel gain to %f",gain);
        
        masterGain = gain;
        m_samplerNode->SetChannelGain(masterGain, CONN_OUT);
    }
}

-(void)setGain:(double)gain forSamplerBank:(SamplerBankNode *)m_samplerBank
{
    m_samplerBank->SetBankGain(gain);
}

#pragma mark - File Recording
-(FileoutNode *)generateFileoutNode:(NSString *)filename
{
    // Ensure Sessions directory exists
    NSError * err = NULL;
    NSFileManager * fm = [[NSFileManager alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
    
    [fm createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&err];
    
    recordingFilepath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    DLog(@"Saving to %@",recordingFilepath);
    
    FileoutNode *fileNode = new FileoutNode((char*)[recordingFilepath UTF8String], true);
    
    fileNode->ConnectInput(0, m_samplerNode, 0);
    
    return fileNode;
    
}


#pragma mark - Level Sliders
- (void)releaseMasterLevelSlider
{
    if(m_volumeSubscriber != nil){
        m_samplerNode->UnSubscribe(m_volumeSubscriber);
    }
}

- (void)commitMasterLevelSlider:(UILevelSlider *)slider
{
    m_volumeSubscriber = m_samplerNode->SubscribeAbsoluteMean((__bridge void *)slider, cbLevel, NULL);
}

static void cbLevel(float val, void *pObject, void *pContext) {
    
    UILevelSlider *slider = (__bridge UILevelSlider*)(pObject);
    
    if(val < 0.0f){
        val = 0.0f;
    }
    
    [slider setDisplayValue:val*[slider GetValue]];
}

/* this has an error when done here instead of locally
 -(void)releaseFileoutNode:(FileoutNode *)fileNode
 {
 if(fileNode != NULL) {
 delete fileNode;
 fileNode = NULL;
 }
 }
 */

@end
