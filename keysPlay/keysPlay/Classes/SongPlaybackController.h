//
//  SongPlaybackController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/25/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Keys.h"
#import "KeysController.h"
#import "NSSongModel.h"

#import "AppCore.h"

#import "UserSong.h"
#import "NSSong.h"
#import "NSNoteFrame.h"
#import "NSNote.h"
#import "XmlDom.h"

#import "SoundMaster.h"

//@class AudioController;
@class UserSong;

//
// Functionally similar to the MainEventController but based on a NSObject
// instead of a UIViewController. Both have their own uses.
//
@interface SongPlaybackController : NSObject <KeysControllerObserver, NSSongModelDelegate>
{
    
    // Loop timer
    NSTimer * m_eventLoopTimer;
    
    
	KeysController * m_keysController;
	
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
- (long)getNumTracks;
- (void)changeTrack:(int)newTrackIndex;

- (void)observeKeysController:(KeysController*)keysController;
- (void)ignoreKeysController:(KeysController*)keysController;

- (void)mainEventLoop;
- (void)startMainEventLoop;
- (void)stopMainEventLoop;
- (void)audioTrailOffEvent;

- (void)seekToLocation:(double)percentComplete;
- (BOOL)isPlaying;
- (double)percentageComplete;

@end
