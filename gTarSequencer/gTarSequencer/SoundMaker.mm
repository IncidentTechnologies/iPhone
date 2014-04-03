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
    LevelSubscriber *m_volumeSubscriber;
    
    SampleNode *m_sampNode;
    SamplerBankNode *m_samplerBank;
    
    SampleNode *m_silenceNode;
    SamplerBankNode *m_silenceBank;
    
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
    m_silenceBank = [m_soundMaster generateBank];
    
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
    
    // Load a silent sample
    //char * silencepath = (char *)[[[NSBundle mainBundle] pathForResource:@"Silence" ofType:@"mp3"] UTF8String];
    
    //m_silenceBank->LoadSampleIntoBank(silencepath, m_silenceNode);
}

- (void)flushBuffer
{
    // TODO: actually flush the buffer
    //m_silenceBank->TriggerSample(0);
    [m_soundMaster flushBuffer];
    
}

- (void)pluckString:(int)str
{
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
    
    //NSLog(@"%f", val);
    
    [slider setDisplayValue:val*[slider GetValue]];
}

@end
