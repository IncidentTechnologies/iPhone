//
//  SoundMaker.mm
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//


#import "SoundMaker.h"
#import "SoundMaster_.mm"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

#define GTAR_NUM_STRINGS 6

@interface SoundMaker () {

    SoundMaster *m_soundMaster;
    
    SampleNode *m_sampNode;
    SamplerBankNode *m_samplerBank;
    
    char * filepath[6];
    NSArray * audioStringSet;
    NSArray * audioStringPaths;
    
    double gain;
    double bankgain;
}

@end

@implementation SoundMaker

- (id)init
{
    self = [super init];
    if ( self )
    {
        
    }
    return self;
}

- (id)initWithStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths andIndex:(int)index andSoundMaster:(SoundMaster *)soundMaster
{
    self = [super init];
    if(self){
        
        audioStringSet = stringSet;
        audioStringPaths = stringPaths;
        
        instIndex = index;
        
        gain = DEFAULT_VOLUME;
        bankgain = AMPLITUDE_SCALE;
        
        m_soundMaster = soundMaster;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
            NSLog(@"Loading files in background");
            
            [self loadStringSetAndStringPaths];

        });
    }
    
    return self;
}

- (void)loadStringSetAndStringPaths
{
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        filepath[i] = (char *)malloc(sizeof(char) * 1024);
    }
    
    m_samplerBank = [m_soundMaster generateBank];
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        
        // Determine filetype
        if([audioStringPaths[i] isEqualToString:@"Custom"]){
            
            // local sound
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * path = [paths objectAtIndex:0];
            NSString * filename = [path stringByAppendingPathComponent:@"Samples"];
            filename = [filename stringByAppendingPathComponent:audioStringSet[i]];
            filename = [filename stringByAppendingString:@".m4a"];
            
            filepath[i] = (char *) [filename UTF8String];
            
        }else{
            filepath[i] = (char *)[[[NSBundle mainBundle] pathForResource:audioStringSet[i] ofType:@"mp3"] UTF8String];
        }
        
        NSLog(@"Loading sample %s",filepath[i]);
        
        if(filepath[i] != NULL){
            m_samplerBank->LoadSampleIntoBank(filepath[i], m_sampNode);
        }
    }
}

- (void)pluckString:(int)str
{
    if(TESTMODE) NSLog(@"Playing note on string %i",str);
    
    m_samplerBank->TriggerSample(str);
}

- (void)updateAmplitude:(double)amplitude
{
    if(bankgain != amplitude){
        
        bankgain = amplitude;
        
        NSLog(@"Setting track gain to %f",bankgain);
        
        [m_soundMaster setGain:bankgain forSamplerBank:m_samplerBank];
    }
}

- (void)updateMasterAmplitude:(double)amplitude
{
    if(gain != amplitude){
        
        amplitude = MIN(amplitude,MAX_VOLUME);
        amplitude = MAX(amplitude,MIN_VOLUME);
        gain = amplitude;
        
        NSLog(@"Setting channel gain to %f",gain);
        
        [m_soundMaster setChannelGain:gain];
    }
}

- (void)releaseSounds
{
    [m_soundMaster releaseBank:m_samplerBank];
}

@end
