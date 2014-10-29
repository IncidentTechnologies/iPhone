//
//  SongDisplayController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <gTarAppCore/DisplayController.h>
#import <gTarAppCore/EAGLView.h>
#import "AppCore.h"

#import "SongES1Renderer.h"

#import <gTarAppCore/NoteAnimation.h>
#import "NoteModel.h"
#import "LineModel.h"
#import "KeyPathModel.h"
#import "NumberModel.h"

#import "NSNote.h"
#import "NSSong.h"
#import "NSMeasure.h"
#import "NSSongModel.h"
#import "NSNoteFrame.h"

#import "keysColors.h"

#import "PlayViewController.h"

@class NSSong;
@class NSNote;
@class NSSongModel;
@class NSNoteFrame;
@class EAGLView;
@class SongES1Renderer;
@class Texture2D;
@class NumberModel;

@interface SongDisplayController : DisplayController
{
    
    NSSongModel * m_songModel;
    
	EAGLView * m_glView;
    
    SongES1Renderer * m_renderer;
    
    // NSNote -> NoteAnimation
    NSMutableDictionary * m_noteModelDictionary;
    NSMutableDictionary * m_noteModelUniversalDictionary;
    NSMutableArray * m_allFrames;
    NSMutableArray * m_undisplayedFrames;
    NSMutableArray * m_numberModels;
    
    double m_viewShift;
    
    double m_beatsToPreloadSync;
    double m_beatsToPreloadAsync;
    
    NSInteger m_framesDisplayed;
    
    NSTimer * m_preloadTimer;
    
    Texture2D * m_noteTexture;
    
    NumberModel * m_mutedTexture;
    
    BOOL isStandalone;
    
    PlayViewControllerDifficulty difficulty;
    
    int m_loops;
    
}

- (id)initWithSong:(NSSongModel*)song andView:(EAGLView*)glView isStandalone:(BOOL)standalone setDifficulty:(PlayViewControllerDifficulty)useDifficulty andLoops:(int)numLoops;
- (void)updateDifficulty:(PlayViewControllerDifficulty)useDifficulty;
- (void)cancelPreloading;
- (void)createLineModels;
- (void)createNumberModels;
- (void)createNoteTexture;
- (void)createBackgroundTexture;

- (void)renderImage;
- (void)updateDisplayedFrames;
- (void)preloadFramesTimer;
- (void)preloadFrames:(NSInteger)count;
- (void)displayFrame:(NSNoteFrame*)frame;
- (void)activateNoteAnimation:(NSNote*)note;
- (void)shiftView:(double)shift;
- (void)shiftViewDelta:(double)shift;

- (int)getStandaloneKeyFromKey:(int)key;
- (double)convertTimeToCoordSpace:(double)delta;
- (double)convertBeatToCoordSpace:(double)beat;
- (double)convertCoordSpaceToBeat:(double)coord;
- (double)convertKeyToCoordSpace:(NSInteger)key;
- (double)calculateMaxShiftCoordSpace:(BOOL)standalone;

- (double)getNoteHit:(NSNote*)note;
- (void)hitNote:(NSNote *)note withAccuracy:(double)accuracy;
- (void)missNote:(NSNote*)note;
- (void)attemptFrame:(NSNoteFrame *)frame;
- (void)setNoteHit:(NSNote*)note toValue:(double)hit;

// Standalone
- (int)getMappedKeyFromKey:(int)key;
- (NSMutableDictionary*)getKeyPressFromTap:(NSMutableArray *)touchPoints;

@end
