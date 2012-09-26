//
//  NSScoreTracker.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "NSScoreTracker.h"
#import "NSNoteFrame.h"

#define SCORE_TRACKER_HITS_PER_MULTIPLIER 4
#define SCORE_TRACKER_MULTIPLIER_MAX 4

@implementation NSScoreTracker

@synthesize m_baseScore;
@synthesize m_score;
@synthesize m_hitsAttempted;
@synthesize m_hitsCorrect;
@synthesize m_hitsIncorrect;
@synthesize m_multiplier;
@synthesize m_streak;
@synthesize m_stars;

- (id)initWithBaseScore:(UInt32)baseScore
{
    self = [super init];
    
    if ( self ) 
    {

        m_baseScore = baseScore;
        
        // scoring
        m_score = 0;
        
        m_hitsAttempted = 0;
        m_hitsCorrect = 0;
        m_hitsIncorrect = 0;
        
        m_multiplier = 1;
        m_streak = 0;
        
        m_multiplierPerfect = 0;
        m_streakPerfect = 0;
        
        m_stars = 0;


    }
    
    return self;
    
}

- (void)scoreFrame:(NSNoteFrame*)frame
{
    
    UInt32 frameMissedHits = [frame.m_notesPending count];
    UInt32 frameCorrectHits = [frame.m_notesHit count];
    UInt32 frameIncorrectHits = frame.m_notesWrong;

    // If they mess up (wrong notes or expird notes), reset the streak and multiplier
    if ( frameMissedHits > 0 || frameIncorrectHits > 0 )
    {
        m_multiplier = 1;
        m_streak = 0;
    }
    
    m_streak += frameCorrectHits;
    
    // At least 1, no more than MAX
    m_multiplier = MIN( SCORE_TRACKER_MULTIPLIER_MAX, (m_streak/SCORE_TRACKER_HITS_PER_MULTIPLIER)+1);
    
    // Multiply the base score and add it in
    m_score += ((frameCorrectHits * m_baseScore) * m_multiplier);
    
    // Account how many hits where made
    m_hitsAttempted += (frameCorrectHits + frameIncorrectHits);
    m_hitsCorrect += frameCorrectHits;
    m_hitsIncorrect += frameIncorrectHits;
    
    [self scoreFramePerfectly:frame];
    
    [self starRateScore];

}

- (void)scoreFramePerfectly:(NSNoteFrame*)frame
{

    // Assume the player hit everything perfectly
    UInt32 frameCorrectHits = [frame.m_notes count];

    m_streakPerfect += frameCorrectHits;
    
    // At least 1, no more than MAX
    m_multiplierPerfect = MIN( SCORE_TRACKER_MULTIPLIER_MAX, MAX( m_streakPerfect / SCORE_TRACKER_HITS_PER_MULTIPLIER, 1) );
    
    // Multiply the base score and add it in
    m_scorePerfect += ((frameCorrectHits * m_baseScore) * m_multiplierPerfect);

}

- (void)starRateScore
{
    
    double score = m_score;
    double scorePerfect = m_scorePerfect;
    
    //double ratio = score / scorePerfect;
    double ratio = (double)m_hitsCorrect / (double)m_hitsAttempted;

    if ( ratio < 0.20 )
    {
        m_stars = 1;
    }
    else if ( ratio < 0.40 )
    {
        m_stars = 2;
    }
    else if ( ratio < 0.60 )
    {
        m_stars = 3;
    }
    else if ( ratio < 0.90 )
    {
        m_stars = 4;
    }
    else
    {
        m_stars = 5;
    }
    
}

@end
