//
//  SongDisplayController.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DisplayController.h>
#import <EAGLView.h>

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
    
}

- (id)initWithSong:(NSSongModel*)song andView:(EAGLView*)glView;
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

- (double)convertTimeToCoordSpace:(double)dealta;
- (double)convertBeatToCoordSpace:(double)beat;
- (double)convertCoordSpaceToBeat:(double)coord;
- (double)convertStringToCoordSpace:(NSInteger)str;
- (double)calculateMaxShiftCoordSpace;

@end
