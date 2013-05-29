//
//  NSScoreTracker.h
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSNoteFrame;

@interface NSScoreTracker : NSObject
{

    // base score
    UInt32 m_baseScore;
    
    // scoring
	UInt32 m_score;

	UInt32 m_hitsAttempted;
    UInt32 m_hitsCorrect;
	UInt32 m_hitsIncorrect;
    
    UInt32 m_multiplier;
    UInt32 m_streak;
    
    // perfect scoring
    UInt32 m_scorePerfect;

    UInt32 m_multiplierPerfect;
    UInt32 m_streakPerfect;
    
    // stars
    UInt32 m_stars;

    // frame
//    UInt32 m_currentFrameStringsCorrect;
//    UInt32 m_currentFrameNotesCorrect;
//    UInt32 m_currentFrameStringsIncorrect;
//    UInt32 m_currentFrameNotesIncorrect;

}

@property (nonatomic, assign) UInt32 m_baseScore;
@property (nonatomic, readonly) UInt32 m_score;
@property (nonatomic, readonly) UInt32 m_hitsAttempted;
@property (nonatomic, readonly) UInt32 m_hitsCorrect;
@property (nonatomic, readonly) UInt32 m_hitsIncorrect;
@property (nonatomic, readonly) UInt32 m_multiplier;
@property (nonatomic, readonly) UInt32 m_streak;
@property (nonatomic, readonly) UInt32 m_stars;

- (id)initWithBaseScore:(UInt32)baseScore;

- (void)scoreFrame:(NSNoteFrame*)frame;
- (void)scoreFramePerfectly:(NSNoteFrame*)frame;
- (void)starRateScore;

@end
