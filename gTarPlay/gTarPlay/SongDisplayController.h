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
#import <gTarAppCore/AppCore.h>

#import "SongES1Renderer.h"

#import <gTarAppCore/NoteAnimation.h>
#import "NoteModel.h"
#import "LineModel.h"
#import "StringModel.h"
#import "NumberModel.h"

#import <gTarAppCore/NSNote.h>
#import <gTarAppCore/NSSong.h>
#import <gTarAppCore/NSMeasure.h>
#import <gTarAppCore/NSSongModel.h>
#import <gTarAppCore/NSNoteFrame.h>

#import "gTarColors.h"

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
    
    BOOL fretOne;
    BOOL fretTwo;
    BOOL fretThree;
    
}

- (id)initWithSong:(NSSongModel*)song andView:(EAGLView*)glView isStandalone:(BOOL)standalone setDifficulty:(PlayViewControllerDifficulty)useDifficulty;
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

- (double)convertTimeToCoordSpace:(double)dealta isStandalone:(BOOL)standalone;
- (double)convertBeatToCoordSpace:(double)beat isStandalone:(BOOL)standalone;
- (double)convertCoordSpaceToBeat:(double)coord isStandalone:(BOOL)standalone;
- (double)convertStringToCoordSpace:(NSInteger)str isStandalone:(BOOL)standalone;
- (double)calculateMaxShiftCoordSpace:(BOOL)standalone;

- (void)fretsDownOne:(BOOL)fretOneOn fretTwo:(BOOL)fretTwoOn fretThree:(BOOL)fretThreeOn;

- (void)hitNote:(NSNote*)note;
- (void)missNote:(NSNote*)note;

// Standalone
-(int)getMappedStringFromString:(int)str;
- (int)getStringPluckFromTap:(CGPoint)touchPoint;

@end
