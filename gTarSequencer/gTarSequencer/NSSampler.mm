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

-(id)initWithXMPNode:(XMPNode *)xmpNode
{
    
    if (xmpNode == nil){
        return nil;
    }
    
    self = [super init];
    
    if( self )
    {
        //XMPObject * sampler = [[XMPObject alloc] initWithXMPNode:xmpNode];
        
        list<XMPNode *>* t_samples = xmpNode->GetChildren();
        
        for(list<XMPNode *>::iterator it = t_samples->First(); it != NULL; it++){
            
            NSSample * sample = [[NSSample alloc] initWithXMPNode:*it];
            
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
    [m_samples addObject:sample];
}


@end
