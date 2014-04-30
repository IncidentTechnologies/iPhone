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
#define STANDALONE_SONG_BEATS_PER_SCREEN 3.0
#define NOTE_MAX_POINTS 100.0

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
        m_hitsMissed = 0;
        
        m_multiplier = 1;
        m_streak = 0;
        
        m_multiplierPerfect = 0;
        m_streakPerfect = 0;
        m_streakMax = 0;
        
        m_frameHits = [[NSMutableArray alloc] init];
        m_frameTimings = [[NSMutableArray alloc] init];
        
        m_stars = 0;


    }
    
    return self;
    
}

- (void)dealloc
{
    [m_frameHits release];
    [m_frameTimings release];
    
    [super dealloc];
}

// Called on exit frame for normal, or anytime during Standalone
- (void)scoreFrame:(NSNoteFrame*)frame onBeat:(double)beat withComplexity:(int)complexity endStreak:(BOOL)endStreak isStandalone:(BOOL)isStandalone
{
    
    UInt32 frameMissedHits = [frame.m_notesPending count];
    UInt32 frameCorrectHits = [frame.m_notesHit count];
    UInt32 frameIncorrectHits = frame.m_notesWrong;

    if(isStandalone){
        
        double streakMultiplier = 1;
        double complexMultiplier = 1;
        double noteScore = 0;
        
        if(endStreak){
            m_streak = 0;
        }
        
        // Get note start and compare to beat hit for accuracy
        double percentAccuracy = (STANDALONE_SONG_BEATS_PER_SCREEN-frame.m_absoluteBeatStart+beat)/STANDALONE_SONG_BEATS_PER_SCREEN;
        
        noteScore += NOTE_MAX_POINTS * percentAccuracy;
        
        NSLog(@"Adding note score %f (%f per frame)",noteScore,noteScore/frameCorrectHits);
        
        // Stash to build heat map later and get avg
        [m_frameTimings addObject:[NSNumber numberWithDouble:percentAccuracy]];
        
        //
        // Streak
        //
        
        // TODO: make sure there's nothing in between
        m_streak++;
        
        if(m_streak > 4 && m_streak < 8){
            streakMultiplier = 2;
        }else if(m_streak < 16){
            streakMultiplier = 4;
        }else{
            streakMultiplier = 8;
        }
        
        // Calculate ** max streak **
        m_streakMax = MAX(m_streakMax,m_streak);
        
        //
        // Complexity
        //
        // Counts the # of frets down
        complexMultiplier += 0.1*complexity + 0.1*(frameCorrectHits - 1);
        
        //
        // Score
        //
        
        m_score += noteScore * streakMultiplier * complexMultiplier;
        
    }else{
        
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
        
        
    }
    
}

// Aggregate data for final display
// Called only on exit frame
- (void)scoreEndOfFrame:(NSNoteFrame*)frame
{
    UInt32 frameMissedHits = [frame.m_notesPending count];
    UInt32 frameCorrectHits = [frame.m_notesHit count];
    UInt32 frameIncorrectHits = frame.m_notesWrong;
    
    m_hitsAttempted += (frameCorrectHits + frameIncorrectHits);
    m_hitsCorrect += frameCorrectHits;
    m_hitsIncorrect += frameIncorrectHits;
    m_hitsMissed += frameMissedHits;
    
    // Stash to get % hits
    NSDictionary * hitDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithDouble:m_hitsAttempted],@"Attempted",
                              [NSNumber numberWithDouble:m_hitsCorrect],@"Correct",
                              [NSNumber numberWithDouble:m_hitsIncorrect],@"Incorrect",
                              [NSNumber numberWithDouble:m_hitsMissed],@"Missed",nil];
    
    [m_frameHits addObject:hitDict];
    
    [hitDict release];
    
    [self scoreFramePerfectly:frame];
    
    [self starRateScore];
}

- (NSDictionary *)aggregateScoreEndOfSong
{
    // % notes hit
    double percentNotesHit = 0;
    double totalNotes = 0;
    double totalHits = 0;
    
    for(NSDictionary * hitDict in m_frameHits){
        totalNotes += [[hitDict objectForKey:@"Missed"] doubleValue];
        totalNotes += [[hitDict objectForKey:@"Correct"] doubleValue];
        
        totalHits += [[hitDict objectForKey:@"Correct"] doubleValue];
    }
    
    percentNotesHit = totalHits/totalNotes;
    
    // calculate+return avg timing
    double avgTiming = 0;
    double numFrames = [m_frameTimings count];
    double totalTiming = 0;
    
    for(NSNumber * timing in m_frameTimings){
        totalTiming += [timing doubleValue];
    }
    
    avgTiming = totalTiming/numFrames;
    
    
    // return data for display
    NSDictionary * data = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSNumber numberWithDouble:percentNotesHit],@"PercentNotesHit",
                           [NSNumber numberWithDouble:avgTiming],@"AverageTiming",
                           [NSNumber numberWithDouble:m_streakMax],@"MaxStreak",
                           m_frameTimings,@"HeatMapData",nil];
    
    return data;
    
    
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
    
//    double score = m_score;
//    double scorePerfect = m_scorePerfect;
    
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
