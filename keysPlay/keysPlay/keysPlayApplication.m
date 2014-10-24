//
//  keysPlayApplication.m
//  keysPlay
//
//  Created by Marty Greenia on 10/10/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "keysPlayApplication.h"

#define IDLE_TIMEOUT 120

@implementation keysPlayApplication

#pragma mark -
#pragma mark UIApplication

// This function resets the idle timer everytime there is a touch event.
#if ENABLE_TIMEOUT
- (void)sendEvent:(UIEvent*)event
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
#endif

#pragma mark -
#pragma mark Idle user detection

- (void)resetIdleTimer
{
#if ENABLE_TIMEOUT
    [m_idleTimer invalidate];
    [m_idleTimer release];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    m_idleTimer = [[NSTimer scheduledTimerWithTimeInterval:IDLE_TIMEOUT target:self selector:@selector(idleTimerExpired) userInfo:nil repeats:NO] retain];
#else
    [UIApplication sharedApplication].idleTimerDisabled = YES;
#endif
}

#if ENABLE_TIMEOUT
- (void)idleTimerExpired
{
    
    [m_idleTimer release];
    
    m_idleTimer = nil;
    
    NSLog(@"User idle, preparing to sleep.");
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
}
#endif
@end
