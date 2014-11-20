//
//  NSSongModel.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "AppCore.h"
#import "KeysMath.h"

@class NSScoreTracker;
@class NSSong;
@class NSNoteFrame;

@protocol NSSongModelDelegate <NSObject>

- (void)songModelEnterFrame:(NSNoteFrame*)frame;
- (void)songModelExitFrame:(NSNoteFrame*)frame;
- (void)songModelNextFrame:(NSNoteFrame*)frame;
- (void)songModelFrameExpired:(NSNoteFrame*)frame;
- (void)songModelEndOfSong;

@end

extern KeysMath *g_keysMath;

@interface NSSongModel : NSObject
{
    
    id<NSSongModelDelegate> m_delegate;
    
    NSSong * m_song;
    
    NSMutableArray * m_noteFrames;
    NSMutableArray * m_noteFramesRemaining;
    NSMutableArray * m_noteFramesPlayed;
    
    NSNoteFrame * __weak m_currentFrame;
    NSNoteFrame * __weak m_nextFrame;
    NSInteger m_currentFrameIndex;
    
    double m_beatsPerSecond;
    
    double m_currentBeat;
    
    double m_percentageComplete;

    NSTimer * m_frameTimer;
    
    double m_lengthBeats;
    double m_lengthSeconds;
    
    double m_frameWidthBeats;
    
    int m_loops;
    
    double widthGap;
    double firstNoteGap;
    
}

@property (nonatomic, readonly) NSSong * m_song;
@property (weak, nonatomic, readonly) NSNoteFrame * m_currentFrame;
@property (weak, nonatomic, readonly) NSNoteFrame * m_nextFrame;
@property (nonatomic, readonly) double m_beatsPerSecond;
@property (nonatomic, readonly) double m_currentBeat;
@property (nonatomic, readonly) double m_percentageComplete;
@property (nonatomic, readonly) NSArray * m_noteFrames;
@property (nonatomic, readonly) double m_lengthBeats;
@property (nonatomic, readonly) double m_lengthSeconds;
@property (nonatomic, assign) double m_frameWidthBeats;
@property (nonatomic, readonly) double m_endBeat;
@property (nonatomic, readonly) double m_startBeat;

//- (id)initWithSongXmp:(NSString*)xmpBlob;
- (id)initWithSong:(NSSong*)song;

- (void)startWithDelegate:(id)delegate;
//- (void)startWithDelegate:(id)delegate andBeatOffset:(double)beats fastForward:(BOOL)ffwd isStandalone:(BOOL)standalone;
- (void)startWithDelegate:(id)delegate andBeatOffset:(double)beats fastForward:(BOOL)ffwd isScrolling:(BOOL)scolling withTempoPercent:(double)tempoPercent fromStart:(double)start toEnd:(double)end withLoops:(int)loops;
- (void)skipToNextFrame;
//- (void)incrementBeat:(double)delta;
//- (void)incrementTime:(double)delta;
- (void)incrementBeatSerialAccess:(double)delta isRestrictFrame:(BOOL)restrictFrame;
- (double)incrementTimeSerialAccess:(double)delta isRestrictFrame:(BOOL)restrictFrame;
- (void)changeBeatRandomAccess:(double)beat;
- (void)changePercentageComplete:(double)percentage;
//- (void)changeBeat:(double)beat;
- (void)checkFrames:(BOOL)restrictFrame;
- (void)exitCurrentFrame;
- (void)enterCurrentFrame;
- (void)beginFrameTimer:(double)delta;
- (void)frameExpired;
- (double)getFirstAudibleBeat;

- (void)setSongLoops:(int)loops;
- (void)setStartBeat:(double)start;
- (void)setEndBeat:(double)end;
- (int)getCurrentLoop;
- (int)getLoopForBeat:(double)beat;

- (NSDictionary *)getMinAndMaxNotesForUpcomingFrames:(int)numFrames;

@end
