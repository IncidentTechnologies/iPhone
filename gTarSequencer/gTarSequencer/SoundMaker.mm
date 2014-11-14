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
    
    NSArray * audioSampleSet;
    
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


- (id)initWithInstrumentId:(NSInteger)instId andName:(NSString *)instName andSamples:(NSArray *)instSamples andSoundMaster:(SoundMaster *)soundMaster
{
    self = [super init];
    if(self){
        
        instIndex = instId;
        
        gain = DEFAULT_VOLUME;
        bankgain = AMPLITUDE_SCALE;
        
        m_soundMaster = soundMaster;
        
        DLog(@"Load instrument %i",instId);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            DLog(@"Loading files in background");
            
            [g_ophoMaster loadSamplesForInstrument:instId andName:instName andSamples:instSamples callbackObj:self selector:@selector(instrumentLoadedWithSamples:)];
            
        });
        
    }
    
    return self;
}

- (void)instrumentLoadedWithSamples:(NSArray *)samples
{
    DLog(@"Instrument loaded with %li samples",[samples count]);
    
    audioSampleSet = [[NSArray alloc] initWithArray:samples];
    
    m_samplerBank = [m_soundMaster generateBank];
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:samples[i] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        
        unsigned long int length = [decodedData length];
        
        m_samplerBank->LoadSampleStringIntoBank([decodedData bytes], length, m_sampNode);
    }

}

/*
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
*/

/*
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
*/
 
- (void)flushBuffer
{
    m_samplerBank->StopAllSamples();
}

- (void)queueNoteToPlay:(int)note
{
    if(notesToPlayQueue == nil){
        notesToPlayQueue = [[NSMutableArray alloc] init];
    }
    
    [notesToPlayQueue addObject:[NSNumber numberWithInt:note]];
}

- (void)playAllNotesInQueue
{
    
    @synchronized(notesToPlayQueue){
        NSMutableArray * notesToRemove = [[NSMutableArray alloc] init];
        
        for(NSNumber * note in notesToPlayQueue){
            [self pluckString:[note intValue]];
            [notesToRemove addObject:note];
        }
        
        [notesToPlayQueue removeObjectsInArray:notesToRemove];
    }
}

- (int)countNotesInQueue
{
    return [notesToPlayQueue count];
}

- (BOOL)isNoteQueueEmpty
{
    return ([notesToPlayQueue count] == 0);
}

- (void)pluckString:(int)str
{
    if(m_samplerBank != NULL && m_samplerBank->GetSample(str) != NULL){
        m_samplerBank->TriggerSample(str);
    }else{
        DLog(@"ERROR: Bank not found");
    }
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
    //[m_soundMaster releaseBank:m_samplerBank];
    [m_soundMaster releaseBankWithoutPause:m_samplerBank];
    // also m_soundMaster releaseBankAndDisconnect
}

#pragma mark - Level Sliders
- (void)releaseLevelSlider
{
    if(m_volumeSubscriber != nil){
        m_samplerBank->UnSubscribe(m_volumeSubscriber);
        m_volumeSubscriber = nil;
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
    
    if([slider respondsToSelector:@selector(GetValue)]){
        [slider setDisplayValue:val*[slider GetValue]];
    }
}

@end
