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
#import "NSSample.h"

#define GTAR_NUM_STRINGS 6

@interface SoundMaker () {
    
    SoundMaster *m_soundMaster;
    LevelSubscriber *m_volumeSubscriber;
    
    SampleNode *m_sampNode;
    SamplerBankNode *m_samplerBank;
    
    char * filepath[6];
    NSArray * audioStringSet;
    NSArray * audioStringPaths;
    NSArray * audioStringSamples;
    
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


- (id)initWithStringSamples:(NSArray *)stringSet andInstrument:(int)index andSoundMaster:(SoundMaster *)soundMaster
{
    self = [super init];
    if(self){
        
        audioStringSamples = stringSet;
        
        instIndex = index;
        
        gain = DEFAULT_VOLUME;
        bankgain = AMPLITUDE_SCALE;
        
        m_soundMaster = soundMaster;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            DLog(@"Loading files in background");
            
            [self loadStringSamples];
            
        });
        
    }
    
    return self;
}

- (void)loadStringSamples
{
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        filepath[i] = (char *)malloc(sizeof(char) * 1024);
    }
    
    m_samplerBank = [m_soundMaster generateBank];
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        
        NSSample * sample = audioStringSamples[i];
        
        // Determine filetype
        if(sample.m_custom){
            
            // local sound
            NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * path = [paths objectAtIndex:0];
            NSString * filename = [path stringByAppendingPathComponent:@"Samples"];
            filename = [filename stringByAppendingPathComponent:sample.m_name];
            filename = [filename stringByAppendingString:@"."];
            filename = [filename stringByAppendingString:sample.m_encoding];
            
            filepath[i] = (char *) [filename UTF8String];
            
        }else{
            NSString * fname = [sample.m_name stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            filepath[i] = (char *)[[[NSBundle mainBundle] pathForResource:fname ofType:sample.m_encoding] UTF8String];
        }
        
        DLog(@"Loading sample %s",filepath[i]);
        
        if(filepath[i] != NULL){
            m_samplerBank->LoadSampleIntoBank(filepath[i], m_sampNode);
        }
    }
}

- (void)flushBuffer
{
    m_samplerBank->StopAllSamples();
}

- (void)pluckString:(int)str
{
    m_samplerBank->TriggerSample(str);
}

- (void)updateAmplitude:(double)amplitude
{
    if(bankgain != amplitude){
        
        bankgain = amplitude;
        
        DLog(@"Setting track gain to %f",bankgain);
        
        [m_soundMaster setGain:bankgain forSamplerBank:m_samplerBank];
    }
}

- (void)updateMasterAmplitude:(double)amplitude
{
    if(gain != amplitude){
        
        amplitude = MIN(amplitude,MAX_VOLUME);
        amplitude = MAX(amplitude,MIN_VOLUME);
        gain = amplitude;
        
        [m_soundMaster setChannelGain:gain];
    }
}

- (void)releaseSounds
{
    [m_soundMaster releaseBank:m_samplerBank];
}

#pragma mark - Level Sliders
- (void)releaseLevelSlider
{
    if(m_volumeSubscriber != nil){
        m_samplerBank->UnSubscribe(m_volumeSubscriber);
    }
}

- (void)commitLevelSlider:(UILevelSlider *)slider
{
    m_volumeSubscriber = m_samplerBank->SubscribeAbsoluteMean((__bridge void *)slider, cbLevel, NULL);
    
}

static void cbLevel(float val, void *pObject, void *pContext) {
    
    UILevelSlider *slider = (__bridge UILevelSlider*)(pObject);
    
    //val = 1.0f - val;
    
    val *= 10.0f;
    
    if(val > 1.0f)
        val = 1.0f;
    else if(val < 0.0f)
        val = 0.0f;
    
    //DLog(@"%f", val);
    
    [slider setDisplayValue:val*[slider GetValue]];
}

@end
