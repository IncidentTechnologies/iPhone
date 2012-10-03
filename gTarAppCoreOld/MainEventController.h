//
//  MainEventController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "gTar.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

#import "GuitarController.h"

@class GuitarController;
@class AudioController;

@interface MainEventController : UIViewController <GuitarControllerObserver>
{

    // Loop timer
    NSTimer * m_eventLoopTimer;

    // GuitarModel
	GuitarController * m_guitarController;
	
	// AudioController
	AudioController * m_audioController;
    
    BOOL m_isRunning;

}

@property (nonatomic, readonly) BOOL m_isRunning;

- (void)sharedInit;

- (void)observeGuitarController:(GuitarController*)guitarController;
- (void)ignoreGuitarController:(GuitarController*)guitarController;

- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;

@end
