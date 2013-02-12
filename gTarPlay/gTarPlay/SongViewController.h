//
//  SongViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import <GtarController/GtarController.h>
#import <AudioController/AudioController.h>

#import <gTarAppCore/AppCore.h>
#import <gTarAppCore/MainEventController.h>
#import <gTarAppCore/NSSongModel.h>

#import "SongProgressViewController.h"
#import "AmpViewController.h"

@class GuitarController;

@class XmlDom;
@class UserSong;
@class NSSong;
@class SongRecorder;
@class NSScoreTracker;
@class NSNoteFrame;
@class SongDisplayController;
@class EAGLView;
@class CloudCache;
@class SongProgressViewController;
@class UserSongSession;
@class UserResponse;

enum SongViewControllerDifficulty
{
    SongViewControllerDifficultyEasy,
    SongViewControllerDifficultyMedium,
    SongViewControllerDifficultyHard
};

@interface SongViewController : MainEventController <GtarControllerObserver, NSSongModelDelegate, AmpViewDelegate, AudioControllerDelegate>
{

    SongDisplayController * m_displayController;
    
    SongViewControllerDifficulty m_difficulty;
    
//    AVAudioPlayer * m_audioPlayer;
    
    double m_tempoModifier;
    
    double m_delay;
    
    BOOL m_muffleWrongNotes;
    
    BOOL m_animateSongScrolling;
    
    NSSong * m_song;
    
    UserSong * m_userSong;
    
    NSSongModel * m_songModel;
    
    SongRecorder * m_songRecorder;
    
    UserSongSession * m_userSongSession;
    
    NSNoteFrame * m_currentFrame;
    NSNoteFrame * m_nextFrame;
    
    NSScoreTracker * m_scoreTracker;
    
    // View Stuff
    SongProgressViewController * m_progressView;
    
    AmpViewController * m_ampView;
    
    // IB stuff
    IBOutlet EAGLView * m_glView;
    
    IBOutlet UIView * m_connectingView;

    BOOL m_refreshDisplay;
    BOOL m_ignoreInput;
    BOOL m_playMetronome;
    
    NSTimer * m_interFrameDelayTimer;
    NSTimer * m_delayedChordTimer;
    NSTimer * m_metronomeTimer;
    
//    double m_previousChordPluckTime;
    GtarString m_previousChordPluckString;
    GtarPluckVelocity m_previousChordPluckVelocity;
    NSInteger m_previousChordPluckDirection;
    
    NSInteger m_delayedChordsCount;
    GtarFret m_delayedChords[GTAR_GUITAR_STRING_COUNT];
    
    NSMutableArray * m_deferredNotesQueue;
    
    NSDate * m_playTimeStart;
    NSTimeInterval m_playTimeAdjustment;
    
}

@property (nonatomic, assign) SongViewControllerDifficulty m_difficulty;
@property (nonatomic, assign) double m_tempoModifier;
@property (nonatomic, assign) BOOL m_muffleWrongNotes;
@property (nonatomic, retain) UserSong * m_userSong;

@property (nonatomic, retain) IBOutlet EAGLView * m_glView;
@property (nonatomic, retain) IBOutlet UIView * m_connectingView;

@property (nonatomic, assign) BOOL m_bSpeakerRoute;

- (IBAction)backButtonClicked:(id)sender;

- (void)handleResignActive;
- (void)handleBecomeActive;

- (void)startWithSongXmlDom;
- (void)pauseSong;
- (void)interFrameDelayExpired;
- (void)disableInput;
- (void)enableInput;

- (void)correctHitFret:(GtarFret)fret andString:(GtarString)str andVelocity:(GtarPluckVelocity)velocity;
- (void)incorrectHitFret:(GtarFret)fret andString:(GtarString)str andVelocity:(GtarPluckVelocity)velocity;
- (void)handleDirectionChange:(GtarString)str;
- (void)handleDelayedChord;

- (void)turnOnFrame:(NSNoteFrame*)frame;
- (void)turnOnFrameWhite:(NSNoteFrame*)frame;
- (void)turnOffFrame:(NSNoteFrame*)frame;
- (void)turnOnString:(GtarString)str andFret:(GtarFret)fret;
- (void)turnOnWhiteString:(GtarString)str andFret:(GtarFret)fret;
- (void)turnOffString:(GtarString)str andFret:(GtarFret)fret;

- (void)pluckString:(GtarString)str andFret:(GtarFret)fret andVelocity:(GtarPluckVelocity)velocity;

- (void)requestUploadUserSongSessionCallback:(UserResponse*)userResponse;

- (void)updateAudioState;

- (void)toggleMetronome;
- (void)playMetronomeTick;


@end
