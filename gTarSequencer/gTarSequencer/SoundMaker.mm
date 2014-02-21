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

#define MAX_AMPLITUDE 4.0
#define MIN_AMPLITUDE 0.02

@interface SoundMaker () {

    AudioController * audioController;
    AudioNode * root;
    
    WavetableNode *m_wavNode;
    EnvelopeNode *m_envNode;
    SampleNode *m_sampNode;
    DelayNode *m_delayNode;
    SamplerNode *m_samplerNode;
    
    char * filepath[6];
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

- (id)initWithStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths
{
    self = [super init];
    if(self){
        
        audioController = [AudioController sharedAudioController];
        root = [[audioController GetNodeNetwork] GetRootNode];
        
        m_samplerNode = new SamplerNode();
        SamplerBankNode * newBank = NULL;
        
        for(int i = 0; i < 6; i++){
            filepath[i] = (char *)malloc(sizeof(char) * 1024);
        }
        
        for(int i = 0; i < 6; i++){
            
            m_samplerNode->CreateNewBank(newBank);
            
            // Determine filetype
            if([stringPaths[i] isEqualToString:@"Custom"]){
                
                // local sound
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * path = [paths objectAtIndex:0];
                NSString * filename = [path stringByAppendingPathComponent:@"Samples"];
                filename = [filename stringByAppendingPathComponent:stringSet[i]];
                filename = [filename stringByAppendingString:@".m4a"];
                
                filepath[i] = (char *) [filename UTF8String];
                
                //filepath[i] = (char *)[[[NSBundle mainBundle] pathForResource:@"Violin 1" ofType:@"mp3"] UTF8String];
                
            }else{
                
                filepath[i] = (char *)[[[NSBundle mainBundle] pathForResource:stringSet[i] ofType:@"mp3"] UTF8String];
            }
            
            NSLog(@"Loading sample %s",filepath[i]);
            
            m_samplerNode->LoadSampleIntoBank(i, filepath[i], m_sampNode);
            
        }
        
        root->ConnectInput(0, m_samplerNode, 0);
        
        [audioController startAUGraph];
        
    }
    
    return self;
}

- (void)PluckStringFret:(int)str atFret:(int)fret withAmplitude:(double)amplitude
{
    if(amplitude > MAX_AMPLITUDE){
        amplitude = MAX_AMPLITUDE;
    }else if(amplitude < MIN_AMPLITUDE){
        amplitude = MIN_AMPLITUDE;
    }
    
    NSLog(@"Playing note on string %i fret %i with amplitude %f",str,fret,amplitude);
    
    m_samplerNode->TriggerBankSample(str, 0);
    
    //[audioController PluckString:str atFret:fret withAmplitude:amplitude];
}

- (void)setSamplePackWithName:(NSString *)pack
{
    //[audioController setSamplePackWithName:pack];
}

@end
