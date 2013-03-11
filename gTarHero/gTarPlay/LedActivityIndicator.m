//
//  LedActivityIndicator.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/11/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "LedActivityIndicator.h"


@implementation LedActivityIndicator

@synthesize m_indicatorImage;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_indicatorImage release];
    
    [m_timer invalidate];
    
    m_timer = nil;
    
    [super dealloc];
    
}

- (void)flickerLed
{
    // default
    [self flickerLedForTime:0.1f];
}

- (void)flickerLedForTime:(double)delta
{
    
//    NSLog(@"LED Begin new timer, invalidate old %@", m_timer);

    [m_indicatorImage setHidden:NO];
    
    [m_timer invalidate];
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:delta target:self selector:@selector(endFlicker) userInfo:nil repeats:NO];
    
}

- (void)endFlicker
{

//    NSLog(@"LED timer expired!");
    
    [m_indicatorImage setHidden:YES];
    
    [m_timer invalidate];
    
    m_timer = nil;
    
}

@end
