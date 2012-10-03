//
//  SongPlaybackController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "gTar.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

#import "GuitarController.h"
#import "NSSongModel.h"

@class GuitarController;
@class AudioController;
@class UserSong;
@class NSSongModel;

//
// Functionally similar to the MainEventController but based on a NSObject 
// instead of a UIViewController. Both have their own uses.
//
@interface SongPlaybackController : NSObject <GuitarControllerObserver, NSSongModelDelegate>
{
    
    // Loop timer
    NSTimer * m_eventLoopTimer;
    
    // GuitarModel
	GuitarController * m_guitarController;
	
	// AudioController
	AudioController * m_audioController;
    
    // NSSongModel
    NSSongModel * m_songModel;
    
    NSTimer * m_audioTrailOffTimer;
    
}

@property (nonatomic, readonly) NSSongModel * m_songModel;

- (id)initWithAudioController:(AudioController*)audioController;

- (void)startWithXmpBlob:(NSString*)xmpBlob;
- (void)startWithUserSong:(UserSong*)userSong;
- (void)playSong;
- (void)pauseSong;
- (void)endSong;

- (void)observeGuitarController:(GuitarController*)guitarController;
- (void)ignoreGuitarController:(GuitarController*)guitarController;

- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;
- (void)audioTrailOffEvent;

- (void)seekToLocation:(double)percentComplete;
- (BOOL)isPlaying;

@end
