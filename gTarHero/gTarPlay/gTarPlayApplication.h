//
//  gTarPlayApplication.h
//  gTarPlay
//
//  Created by Marty Greenia on 10/10/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gTarPlayApplication : UIApplication
{
    NSTimer * m_idleTimer;
}

- (void)resetIdleTimer;
- (void)idleTimerExpired;

@end
