//
//  keysPlayApplication.h
//  keysPlay
//
//  Created by Marty Greenia on 10/10/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ENABLE_TIMEOUT false

@interface keysPlayApplication : UIApplication
{
    NSTimer * m_idleTimer;
}

- (void)resetIdleTimer;
#if ENABLE_TIMEOUT
- (void)idleTimerExpired;
#endif

@end
