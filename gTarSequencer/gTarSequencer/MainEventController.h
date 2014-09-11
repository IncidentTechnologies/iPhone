//
//  MainEventController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EVENT_LOOPS_PER_SECOND 50.0

#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

@interface MainEventController : UIViewController
{
    
    // Loop timer
    NSTimer * m_eventLoopTimer;
    
    BOOL m_isRunning;
    
}

@property (nonatomic, readonly) BOOL m_isRunning;

- (void)sharedInit;

- (void)mainEventLoop;
- (void)startMainEventLoop:(double)timeInterval;
- (void)stopMainEventLoop;

@end
