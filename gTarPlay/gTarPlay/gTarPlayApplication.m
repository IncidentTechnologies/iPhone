//
//  gTarPlayApplication.m
//  gTarPlay
//
//  Created by Marty Greenia on 10/10/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "gTarPlayApplication.h"

#define IDLE_TIMEOUT 120

@implementation gTarPlayApplication

#pragma mark -
#pragma mark UIApplication

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    NSSet * touches = [event allTouches];
    
    if ( [touches count] > 0 )
    {
        // See what phase we are in, the specific object doesn't matter
        UITouchPhase phase = ((UITouch*)[touches anyObject]).phase;
        
        if ( phase == UITouchPhaseBegan )
        {
            [self resetIdleTimer];
        }
    }
}

#pragma mark -
#pragma mark Idle user detection

- (void)resetIdleTimer
{
    
    [m_idleTimer invalidate];
    [m_idleTimer release];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    m_idleTimer = [[NSTimer scheduledTimerWithTimeInterval:IDLE_TIMEOUT target:self selector:@selector(idleTimerExpired) userInfo:nil repeats:NO] retain];
    
}

- (void)idleTimerExpired
{
    
    [m_idleTimer release];
    
    m_idleTimer = nil;
    
    NSLog(@"User idle, preparing to sleep.");
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}

@end
