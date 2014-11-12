//
//  SoundMaker.mm
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SimpleSoundMaker.h"
#import "SoundMaster_.mm"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

@interface SimpleSoundMaker () {
    
    SoundMaster * m_soundMaster;
    SamplerBankNode * m_bankNode;
    SampleNode * m_sampNode;
}

@end

@implementation SimpleSoundMaker

#pragma mark - Init

- (id)init
{
    self = [super init];
    if ( self )
    {
        m_soundMaster = [[SoundMaster alloc] init];
        bankSamples = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithSoundMaster:(SoundMaster *)soundMaster
{
    self = [super init];
    if ( self )
    {
        m_soundMaster = soundMaster;
        bankSamples = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Single Sample

- (void)addSingleSampleByName:(NSString *)filename useBundle:(BOOL)useBundle
{
    if(!m_bankNode){
        m_bankNode = [m_soundMaster generateBank];
    }
    
    // Reload sound into bank after new record
    char * filepath = (char *)malloc(sizeof(char) * 1024);
    
    if(useBundle){
        filepath = (char *)[[[NSBundle mainBundle] pathForResource:filename ofType:@"wav"] UTF8String];
    }else{
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * path = [paths objectAtIndex:0];
        NSString * sampleFilename = [path stringByAppendingPathComponent:filename];
        
        filepath = (char *) [sampleFilename UTF8String];
    }
    
    m_bankNode->LoadSampleIntoBank(filepath, m_sampNode);
    
    // SoundMaster reset?
}

- (void)saveSingleSampleToFilepath:(NSString *)filepath
{
    char * pathName = (char *)malloc(sizeof(char) * [filepath length]);
    pathName = (char *) [filepath UTF8String];
    
    m_sampNode->SaveToFile(pathName, YES);
}

- (void)playSingleSample
{
    [self playSample:0];
}

- (void)pauseSingleSample
{
    m_sampNode->Stop();
}

- (void)resumeSingleSample
{
    m_sampNode->Resume();
}

- (void)setSampleStart:(float)ms
{
    m_sampNode->SetStart(ms);
}

- (void)setSampleEnd:(float)ms
{
    m_sampNode->SetEnd(ms);
}

- (unsigned long int)fetchAudioBufferSize
{
    return m_sampNode->GetSampleBuffer()->GetByteSize();
}

- (float)fetchSampleRate
{
    return m_sampNode->GetSampleBuffer()->GetSampleRate();
}

- (float *)fetchAudioBuffer
{
    return (float *)m_sampNode->GetSampleBuffer()->GetBufferArray();
}

- (float)getSampleLength
{
    return m_sampNode->GetLength();
}

- (void)playSample:(int)sample
{
    DLog(@"Play sample %i",sample);
    
    [m_soundMaster start];
    
    m_bankNode->TriggerSample(sample);
}

#pragma mark - Multiple Samples (for XMP)

- (void)addBase64Sample:(NSString *)datastring forXmpId:(NSInteger)xmpId
{
    if(!m_bankNode){
        m_bankNode = [m_soundMaster generateBank];
    }
    
    // Base 64 decode
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:datastring options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    unsigned long int length = [decodedData length];
    
    DLog(@"Length of decoded data is %lu",length);
    
    m_bankNode->LoadSampleStringIntoBank([decodedData bytes], length, m_sampNode);
    
    [bankSamples addObject:[NSNumber numberWithInt:xmpId]];
    
}

- (void)playSampleForXmpId:(NSInteger)xmpId
{
    [self playSample:[bankSamples indexOfObject:[NSNumber numberWithInt:xmpId]]];
}

- (BOOL)sampleForXmpId:(NSInteger)xmpId
{
    return [bankSamples containsObject:[NSNumber numberWithInt:xmpId]];
}

#pragma mark - Cleanup

- (void)releaseAll
{
    DLog(@"Release all");
    
    [m_soundMaster releaseBankAndDisconnect:m_bankNode];
    m_bankNode = NULL;
    
    [bankSamples removeAllObjects];
}

- (void)releaseSounds
{
    DLog(@"Release sounds");
    
    [m_soundMaster releaseBank:m_bankNode];
    //[m_soundMaster releaseBankAndDisconnect:m_bankNode];
    m_bankNode = NULL;
    
    [bankSamples removeAllObjects];
}


@end
