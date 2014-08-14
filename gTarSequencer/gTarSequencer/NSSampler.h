//
//  NSSampler.h
//  Sequence
//
//  Created by Kate Schnippering on 8/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "XMPNode.h"
#import "XMPObject.h"
#import "NSSample.h"

@interface NSSampler : NSObject
{
    NSMutableArray * m_samples;
}

@property (retain, nonatomic) NSMutableArray * m_samples;

-(id)initWithXMPNode:(XMPNode *)xmpNode;

-(id)init;

-(XMPNode *)convertToXmp;

-(void)addSample:(NSSample *)sample;

@end
