//
//  SongPlaybackController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GtarController/Gtar.h>
#import <GtarController/GtarController.h>

#import "NSSongModel.h"

@class AudioController;
@class UserSong;

//
// Functionally similar to the MainEventController but based on a NSObject 
// instead of a UIViewController. Both have their own uses.
//
@interface SongPlaybackController : NSObject <GtarControllerObserver, NSSongModelDelegate>
{
    
    // Loop timer
    NSTimer * m_eventLoopTimer;
    
    // GuitarModel
	GtarController * m_gtarController;
	
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

- (void)observeGtarController:(GtarController*)gtarController;
- (void)ignoreGtarController:(GtarController*)gtarController;

- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;
- (void)audioTrailOffEvent;

- (void)seekToLocation:(double)percentComplete;
- (BOOL)isPlaying;
- (double)percentageComplete;

@end
