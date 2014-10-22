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
        
        list<XMPNode *>* t_samples = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_samples->First(); it != NULL; it++){
            
            NSSample * sample = [[NSSample alloc] initWithXMPNode:*it];
            
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
        
        NSArray * samplechildren = [dom getChildArrayWithName:@"sample"];
        
        for(XmlDom * child in samplechildren){
            
            NSSample * sample = [[NSSample alloc] initWithXmlDom:child];
            
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
                stringId = DEFAULT_STRING_ID;
            }
            
            NSSample * sample = [[NSSample alloc] initWithName:[stringSet objectAtIndex:i] custom:[[stringPaths objectAtIndex:i] isEqualToString:@"Custom"] value:[NSString stringWithFormat:@"%i",i] xmpFileId:stringId];
            
            [self addSample:sample];
        }
    }
    
    //audio = [[SoundMaker alloc] initWithStringSamples:m_samples andInstrument:index andSoundMaster:soundMaster];
    
    audio = [[SoundMaker alloc] initWithInstrumentId:index andName:name andSamples:m_samples andSoundMaster:soundMaster];
    
    DLog(@"Samples count is %i",[m_samples count]);
    
}

-(XMPNode *)convertToXmp
{
    XMPNode *node = NULL;
    
    node = new XMPNode((char *)[@"sampler" UTF8String],NULL);
    
    for(NSSample * sample in m_samples){
        node->AddChild([sample convertToXmp]);
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
