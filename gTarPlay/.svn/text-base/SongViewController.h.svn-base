//
//  SongViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/4/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

#import <GuitarController.h>
#import <MainEventController.h>

#import <NSSongModel.h>

#import "SongProgressViewController.h"
#import "AmpViewController.h"
#import "AudioController.h";

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

@interface SongViewController : MainEventController <GuitarControllerObserver, NSSongModelDelegate, AmpViewDelegate, AudioControllerDelegate>
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
    
    double m_previousChordPluckTime;
    GuitarString m_previousChordPluckString;
    NSInteger m_previousChordPluckDirection;
    
    NSInteger m_delayedChordsCount;
    GuitarFret m_delayedChords[GTAR_GUITAR_STRING_COUNT];
    
}

@property (nonatomic, assign) SongViewControllerDifficulty m_difficulty;
@property (nonatomic, assign) double m_tempoModifier;
@property (nonatomic, assign) BOOL m_muffleWrongNotes;
@property (nonatomic, retain) UserSong * m_userSong;

@property (nonatomic, retain) IBOutlet EAGLView * m_glView;
@property (nonatomic, retain) IBOutlet UIView * m_connectingView;

@property (nonatomic, assign) BOOL m_bSpeakerRoute;

- (IBAction)backButtonClicked:(id)sender;

- (void)startWithSongXmlDom;
- (void)pauseSong;
- (void)interFrameDelayExpired;
- (void)disableInput;
- (void)enableInput;

- (void)guitarInputHandling:(NSDictionary*)dict;
- (void)correctHitFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)incorrectHitFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)handleDirectionChange:(GuitarString)str;
- (void)handleDelayedChord;

- (void)turnOnFrame:(NSNoteFrame*)frame;
- (void)turnOnFrameWhite:(NSNoteFrame*)frame;
- (void)turnOffFrame:(NSNoteFrame*)frame;
- (void)turnOnString:(GuitarString)str andFret:(GuitarFret)fret;
- (void)turnOnWhiteString:(GuitarString)str andFret:(GuitarFret)fret;
- (void)turnOffString:(GuitarString)str andFret:(GuitarFret)fret;

- (void)pluckString:(GuitarString)str andFret:(GuitarFret)fret;

- (void)requestUploadUserSongSessionCallback:(UserResponse*)userResponse;

- (void)playMetronomeTick;

@end
