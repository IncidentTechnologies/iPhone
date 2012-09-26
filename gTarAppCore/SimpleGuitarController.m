//
//  SimpleGuitarController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "SimpleGuitarController.h"

#import "AudioController.h"

#define AUDIO_CONTROLLER_ATTENUATION 0.99f
#define AUDIO_CONTROLLER_ATTENUATION_INCORRECT 0.80f

@implementation SimpleGuitarController

- (id)init
{
    self = [super init];
    
    if ( self )
    {

        // Create audio controller
        m_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
		
		[m_audioController SetAttentuation:AUDIO_CONTROLLER_ATTENUATION];
		[m_audioController initializeAUGraph];
		[m_audioController startAUGraph];
        
        // Create guitar controller
        m_guitarController = [[GuitarController alloc] init];
        
        [m_guitarController turnOffAllEffects];
        
        m_guitarController.m_delegate = self;

    }
    
    return self;
    
}

#pragma GuitarControllerDelegate

- (void)guitarFretDown:(GuitarFret)fret atString:(GuitarString)str
{
    
}

- (void)guitarFretUp:(GuitarFret)fret atString:(GuitarString)str
{
    
}

- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str
{
    [m_audioController PluckString:str-1 atFret:fret];
}

- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
    
}

- (void)guitarConnected
{
    
}

- (void)guitarDisconnected
{
    
}

@end
