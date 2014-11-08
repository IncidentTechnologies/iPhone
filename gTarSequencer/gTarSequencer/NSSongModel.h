//
//  NSSongModel.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "AppData.h"
#import "SoundMaker.h"

@class NSScoreTracker;
@class NSSong;
@class NSNoteFrame;

@protocol NSSongModelDelegate <NSObject>

- (void)songModelEnterFrame:(NSNoteFrame*)frame;
- (void)songModelExitFrame:(NSNoteFrame*)frame;
- (void)songModelNextFrame:(NSNoteFrame*)frame;
- (void)songModelEndOfSong;

@end

@interface NSSongModel : NSObject
{
    
    id<NSSongModelDelegate> m_delegate;
    
    NSSong * m_song;
    
    double m_beatsPerSecond;
    
    double m_currentBeat;
    
    double m_percentageComplete;
    
    double m_lengthBeats;
    double m_lengthSeconds;
    
    int m_loops;
    
    double widthGap;
    double firstNoteGap;
    
    NSArray * m_instruments;
    
}

@property (nonatomic, readonly) NSSong * m_song;
@property (nonatomic, readonly) double m_beatsPerSecond;
@property (nonatomic, readonly) double m_currentBeat;
@property (nonatomic, readonly) double m_percentageComplete;
@property (nonatomic, readonly) double m_lengthBeats;
@property (nonatomic, readonly) double m_lengthSeconds;
@property (nonatomic, assign) double m_frameWidthBeats;
@property (nonatomic, readonly) double m_endBeat;
@property (nonatomic, readonly) double m_startBeat;

- (id)initWithSong:(NSSong*)song andInstruments:(NSArray *)instruments;

- (void)startWithDelegate:(id)delegate;
- (void)startWithDelegate:(id)delegate andBeatOffset:(double)beats fastForward:(BOOL)ffwd isScrolling:(BOOL)scolling withTempoPercent:(double)tempoPercent fromStart:(double)start toEnd:(double)end withLoops:(int)loops;

//- (void)incrementBeatSerialAccess:(double)delta;
- (double)incrementTimeSerialAccess:(double)delta;
- (void)changeBeatRandomAccess:(double)beat;
- (void)changePercentageComplete:(double)percentage;

- (void)checkFrames;
//- (void)exitCurrentFrame;
//- (void)enterCurrentFrame;
//- (double)getFirstAudibleBeat:(NSArray *)notesArray;

- (void)setStartBeat:(double)start;
- (void)setEndBeat:(double)end;

@end
