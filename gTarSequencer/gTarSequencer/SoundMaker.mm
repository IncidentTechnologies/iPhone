//
//  SoundMaker.mm
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//


#import "SoundMaker.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

#define MAX_AMPLITUDE 0.55
#define MIN_AMPLITUDE 0.01
#define GTAR_NUM_STRINGS 6

@interface SoundMaker () {

    //WavetableNode *m_wavNode;
    //EnvelopeNode *m_envNode;
    SampleNode *m_sampNode;
    //DelayNode *m_delayNode;
    SamplerNode *m_samplerNode;
    SamplerBankNode *m_samplerBank;
    
    char * filepath[6];
    NSArray * audioStringSet;
    NSArray * audioStringPaths;
    
    double gain;
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

- (id)initWithStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths andIndex:(int)index
{
    self = [super init];
    if(self){
        
        AudioController * audioController = [AudioController sharedAudioController];
        AudioNode * root = [[audioController GetNodeNetwork] GetRootNode];
        
        audioStringSet = stringSet;
        audioStringPaths = stringPaths;
        
        instIndex = index;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
            NSLog(@"Loading files in background");
            
            [self loadStringSetAndStringPaths];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                NSLog(@"Connect input to root");
                root->ConnectInput(0, m_samplerNode, 0);
                
                [audioController startAUGraph];
            });

        });
    }
    
    return self;
}

- (void)loadStringSetAndStringPaths
{
    m_samplerNode = new SamplerNode();
    m_samplerBank = NULL;
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        filepath[i] = (char *)malloc(sizeof(char) * 1024);
    }
    
    m_samplerNode->CreateNewBank(m_samplerBank);
    
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        
        //m_samplerNode->CreateNewBank(newBank);
        
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
        
        m_samplerNode->LoadSampleIntoBank(0, filepath[i], m_sampNode);
        
    }
}

- (void)PluckStringFret:(int)str atFret:(int)fret withAmplitude:(double)amplitude
{
    if(amplitude > MAX_AMPLITUDE){
        amplitude = MAX_AMPLITUDE;
    }else if(amplitude < MIN_AMPLITUDE){
        amplitude = MIN_AMPLITUDE;
    }
    
    NSLog(@"Playing note on string %i fret %i with amplitude %f",str,fret,amplitude);
    
    if(gain != amplitude){
        m_samplerNode->SetBankGain(0, amplitude);
        gain = amplitude;
    }
    
    m_samplerBank->TriggerSample(str);
}

- (void)setSamplePackWithName:(NSString *)pack
{
    //[audioController setSamplePackWithName:pack];
}

@end
