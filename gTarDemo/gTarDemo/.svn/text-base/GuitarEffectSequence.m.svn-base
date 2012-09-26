//
//  GuitarEffectSequence.m
//  gTarDemo
//
//  Created by Joel Greenia on 11/16/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "GuitarEffectSequence.h"
#import "GuitarEffect.h"
#import "GuitarEffectSerialized.h"

#define STRING_COUNT 6
#define FRET_COUNT 16

@implementation GuitarEffectSequence

@synthesize m_effectSequenceSerialized;
@synthesize m_duration;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        
        self.m_effectSequenceSerialized = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}

- (void)serializeEffectArray:(NSArray*)array
{
    
    for ( GuitarEffect * effect in array )
    {
        
        NSArray * serializedEffects = [self serializeEffect:effect];
        
        // do something
        
        [m_effectSequenceSerialized addObjectsFromArray:serializedEffects];
        
    }
    
}

- (NSArray*)serializeEffect:(GuitarEffect*)effect
{

    NSMutableArray * serializedEffects = [[NSMutableArray alloc] init];
    
    if ( effect.m_clearFirst == YES )
    {
        
        GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
        
        serialized.m_effectTime = 0;
        serialized.m_effectType = GuitarEffectTypeClear;
        
        [serializedEffects addObject:serialized];
        
    }
    
    [serializedEffects addObjectsFromArray:[self serializeDirectionEffect:effect]];
    
    return serializedEffects;
    
}

- (NSArray*)serializeDirectionEffect:(GuitarEffect*)effect
{
    
    NSMutableArray * serializedEvents = [[NSMutableArray alloc] init];
    
    // same seed each time so we get same results
    srand(0);
    
    if ( effect.m_direction == 0 )
    {
        
        if ( effect.m_directionScattering == NO )
        {
            NSInteger ledEvents = FRET_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = (FRET_COUNT - i);
                serialized.m_string = 0;
                
                [serializedEvents addObject:serialized];
                
            }

        }
        else
        {
            NSInteger ledEvents = FRET_COUNT * STRING_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = ((ledEvents-i-1) / STRING_COUNT)+1;
                serialized.m_string = ((ledEvents-i-1) % STRING_COUNT)+1;
                
                [serializedEvents addObject:serialized];
                
            }
        }
        
    }
    
    if ( effect.m_direction == 1 )
    {
        
        if ( effect.m_directionScattering == NO )
        {
            NSInteger ledEvents = FRET_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = i + 1;
                serialized.m_string = 0;
                
                [serializedEvents addObject:serialized];
                
            }
            
        }
        else
        {
            NSInteger ledEvents = FRET_COUNT * STRING_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = ((i+1) / STRING_COUNT)+1;
                serialized.m_string = ((i+1) % STRING_COUNT)+1;
                
                [serializedEvents addObject:serialized];
                
            }
        }

    }

    if ( effect.m_direction == 2 )
    {
        
        if ( effect.m_directionScattering == NO )
        {
            NSInteger ledEvents = STRING_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = 0;
                serialized.m_string = i + 1;
                
                [serializedEvents addObject:serialized];
                
            }
            
        }
        else
        {
            NSInteger ledEvents = FRET_COUNT * STRING_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = ((i+1) % FRET_COUNT)+1;
                serialized.m_string = ((i+1) / FRET_COUNT)+1;
                
                [serializedEvents addObject:serialized];
                
            }
        }
        
    }
    
    if ( effect.m_direction == 3 )
    {
        
        if ( effect.m_directionScattering == NO )
        {
            NSInteger ledEvents = STRING_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = 0;
                serialized.m_string = (STRING_COUNT - i);
                
                [serializedEvents addObject:serialized];
                
            }
            
        }
        else
        {
            NSInteger ledEvents = FRET_COUNT * STRING_COUNT;
            
            CGFloat stepTime = effect.m_duration / (CGFloat)ledEvents;
            
            for ( NSInteger i = 0; i < ledEvents; i++ )
            {
                
                GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
                
                serialized.m_effectType = GuitarEffectTypeLedOn;
                serialized.m_effectTime = stepTime;
                
                if ( effect.m_colorRandom == YES )
                {
                    serialized.m_red = rand() % 4;
                    serialized.m_green = rand() % 4;
                    serialized.m_blue = rand() % 4;
                }
                else
                {
                    serialized.m_red = effect.m_colorRed;
                    serialized.m_green = effect.m_colorGreen;
                    serialized.m_blue = effect.m_colorBlue;
                }
                
                serialized.m_fret = ((ledEvents-i-1) % FRET_COUNT)+1;
                serialized.m_string = ((ledEvents-i-1) / FRET_COUNT)+1;
                
                [serializedEvents addObject:serialized];
                
            }
        }
        
    }
    
    if ( effect.m_direction == 4 )
    {
        
                
        GuitarEffectSerialized * serialized = [[GuitarEffectSerialized alloc] init];
        
        serialized.m_effectType = GuitarEffectTypeLedOn;
        serialized.m_effectTime = 0.050f;
        
        if ( effect.m_colorRandom == YES )
        {
            serialized.m_red = rand() % 4;
            serialized.m_green = rand() % 4;
            serialized.m_blue = rand() % 4;
        }
        else
        {
            serialized.m_red = effect.m_colorRed;
            serialized.m_green = effect.m_colorGreen;
            serialized.m_blue = effect.m_colorBlue;
        }
        
        serialized.m_fret = 0;
        serialized.m_string = 0;
        
        [serializedEvents addObject:serialized];
                
    }
    
    return serializedEvents;
    
}

@end
