//
//  SoundMaker.m
//  gTarSequencer
//
//  Created by Ilan Gray on 7/30/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "SoundMaker.h"
#import "AudioController.h"

@implementation SoundMaker

- (id)init
{
    self = [super init];
    if ( self )
    {
        audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:@"Percussion"];
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
