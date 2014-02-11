//
//  SoundMaker.mm
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/27/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//


#import "SoundMaker.h"
#import <AudioController/AudioController.h>

@implementation SoundMaker

- (id)init
{
    self = [super init];
    if ( self )
    {
        audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:@"Sequence"];
        //[audioController initializeAUGraph];
        [audioController startAUGraph];
    }
    return self;
}

- (id)initWithStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths
{
    self = [super init];
    if(self){
        
        audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:@"Silence" AndStringSet:stringSet AndStringPaths:stringPaths];
        //[audioController initializeAUGraph];
        [audioController startAUGraph];
    }
    
    return self;
}

- (void)PluckStringFret:(int)str atFret:(int)fret withAmplitude:(double)amplitude
{
    NSLog(@"Playing note with amplitude %f",amplitude);
    [audioController PluckString:str atFret:fret withAmplitude:amplitude];
}

- (void)setSamplePackWithName:(NSString *)pack
{
    [audioController setSamplePackWithName:pack];
}

@end
