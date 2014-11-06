//
//  NSSampler.m
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "NSSampler.h"

@implementation NSSampler

@synthesize m_samples;
@synthesize audio;

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        //XMPObject * sampler = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        DLog(@"SAMPLER");
        
        m_samples = [[NSMutableArray alloc] init];
        
        list<XMPNode *>* t_banks = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_banks->First(); it != NULL; it++){
            
            XMPNode * bank = *it;
            
            NSSample * sample = [[NSSample alloc] initWithXMPNode:bank->FindChildByName((char *)"sample")];
            
            [self addSample:sample];
        }
    }
    
    return self;
}

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
    
    //audio = [[SoundMaker alloc] initWithStringSamples:m_samples andInstrument:index andSoundMaster:soundMaster];
    
    audio = [[SoundMaker alloc] initWithInstrumentId:index andName:name andSamples:m_samples andSoundMaster:soundMaster];
    
    DLog(@"Samples count is %li",[m_samples count]);
    
}

- (void)initAudioWithInstrument:(int)index andName:(NSString *)name andSoundMaster:(SoundMaster *)soundMaster
{
    // All the samples already exist
    DLog(@"Init audio for instrument %i with %li samples",index,[m_samples count]);
    
    audio = [[SoundMaker alloc] initWithInstrumentId:index andName:name andSamples:m_samples andSoundMaster:soundMaster];
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    node = new XMPNode((char *)[@"sampler" UTF8String],NULL);
    
    for(NSSample * sample in m_samples){
        
        XMPNode *bank = NULL;
        bank = new XMPNode((char *)[@"bank" UTF8String],NULL);
        node->AddChild(bank);
        bank->AddChild([sample convertToXmp]);
    }
    
    return node;
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
