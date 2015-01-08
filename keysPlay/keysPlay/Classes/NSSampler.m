//
//  NSSampler.m
//  keysPlay
//
//  Created by Kate Schnippering on 1/6/15.
//
//

#import "NSSampler.h"
#import "NSSample.h"
#import "XmlDom.h"

#define DEFAULT_SAMPLE_ID 1

@implementation NSSampler

@synthesize m_samples;
@synthesize audio;

-(id)initWithXmlDom:(XmlDom *)dom
{
    if(dom == nil){
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {
        DLog(@"SAMPLER");
        
        m_samples = [[NSMutableArray alloc] init];
        
        NSArray * bankchildren = [dom getChildArrayWithName:@"bank"];
        
        for(XmlDom * child in bankchildren){
            
            XmlDom * samplechild = [child getChildWithName:@"sample"];
            
            NSSample * sample = [[NSSample alloc] initWithXmlDom:samplechild];
            
            [self addSample:sample];
        }
    }
    
    return self;
}

-(id)init
{
    self = [super init];
    
    if ( self )
    {
        m_samples = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)initAudioWithInstrument:(int)index andName:(NSString *)name andSoundMaster:(SoundMaster *)soundMaster stringSet:(NSArray *)stringSet stringPaths:(NSArray *)stringPaths stringIds:(NSArray *)stringIds
{
    if([m_samples count] == 0){
        // Add all the samples for a new track
        for(int i = 0; i < [stringSet count]; i++){
            
            int stringId = [[stringIds objectAtIndex:i] intValue];
            if(stringId == 0){
                stringId = DEFAULT_SAMPLE_ID;
            }
            
            NSSample * sample = [[NSSample alloc] initWithName:[stringSet objectAtIndex:i] custom:[[stringPaths objectAtIndex:i] isEqualToString:@"Custom"] value:[NSString stringWithFormat:@"%i",i] externalId:[NSString stringWithFormat:@"sample_%i",i] xmpFileId:stringId];
            
            [self addSample:sample];
        }
    }
    
    //audio = [[SoundMaker alloc] initWithInstrumentId:index andName:name andSamples:m_samples andSoundMaster:soundMaster];
    
    DLog(@"Samples count is %li",[m_samples count]);
    
}

- (void)initAudioWithInstrument:(int)index andName:(NSString *)name andSoundMaster:(SoundMaster *)soundMaster
{
    // All the samples already exist
    DLog(@"Init audio for instrument %i with %li samples",index,[m_samples count]);
    
    //audio = [[SoundMaster alloc] initWithInstrumentId:index andName:name andSamples:m_samples andSoundMaster:soundMaster];
}

-(void)addSample:(NSSample *)sample
{
    for(NSSample * s in m_samples){
        if([s.m_name isEqualToString:sample.m_name] && [s.m_value isEqualToString:sample.m_value]){
            return;
        }
    }
    [m_samples addObject:sample];
}


@end
