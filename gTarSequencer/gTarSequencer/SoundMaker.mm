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
        [audioController initializeAUGraph];
        [audioController startAUGraph];
    }
    return self;
}

- (id)initWithInstrumentName:(NSString *)instrument
{
    self = [super init];
    if(self){
    
        
        NSLog(@"Trying instrument %@",instrument);
        audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:instrument];
        [audioController initializeAUGraph];
        [audioController startAUGraph];
    }
    
    return self;
}

- (void)PluckStringFret:(int)str atFret:(int)fret
{
    [audioController PluckString:str atFret:fret];
}

- (void)setSamplePackWithName:(NSString *)pack
{
    [audioController setSamplePackWithName:pack];
}

@end
