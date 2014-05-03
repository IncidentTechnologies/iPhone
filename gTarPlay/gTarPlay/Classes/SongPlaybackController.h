//
//  SongPlaybackController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Gtar.h"
#import "GtarController.h"
#import <gTarAppCore/NSSongModel.h>

#import <gTarAppCore/AppCore.h>

#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSNoteFrame.h>
#import <gTarAppCore/NSNote.h>
#import <gTarAppCore/XmlDom.h>

#import "SoundMaster.h"

//@class AudioController;
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
	
    // NSSongModel
    NSSongModel * m_songModel;
    
    NSTimer * m_audioTrailOffTimer;
    
}

@property (nonatomic, readonly) NSSongModel * m_songModel;
@property (strong, nonatomic) SoundMaster * g_soundMaster;

//- (id)initWithAudioController:(AudioController*)audioController;
- (id)initWithSoundMaster:(SoundMaster*)soundMaster;
- (void)didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender;
- (void)stopAudioEffects;
- (NSInteger)getSelectedInstrumentIndex;
- (NSArray *)getInstrumentList;

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
