//
//  NSScoreTracker.m
//  gTarAppCore
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "NSScoreTracker.h"
#import "NSNoteFrame.h"
#import "NSNote.h"

#define SCORE_TRACKER_HITS_PER_MULTIPLIER 4
#define SCORE_TRACKER_MULTIPLIER_MAX 4
#define STANDALONE_SONG_BEATS_PER_SCREEN 3.0
#define NOTE_MAX_POINTS 100.0

@implementation NSScoreTracker

@synthesize m_baseScore;
@synthesize m_score;
@synthesize m_totalScore;
@synthesize m_hitsAttempted;
@synthesize m_hitsCorrect;
@synthesize m_hitsIncorrect;
@synthesize m_multiplier;
@synthesize m_streak;
@synthesize m_stars;

- (id)initWithBaseScore:(UInt32)baseScore isPracticeMode:(BOOL)practiceMode numLoops:(int)loops
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
        
        isPracticeMode = practiceMode;
        m_loops = loops;
        m_loopScores = [[NSMutableArray alloc] init];
        m_totalScore = 0;
        
        // Init loops to score of 0
        for(int l = 0; l <= m_loops; l++){
            [m_loopScores addObject:[NSNumber numberWithInt:0]];
        }
        

    }
    
    return self;
    
}


// Called on exit frame for normal, or anytime during Standalone
- (double)scoreFrame:(NSNoteFrame*)frame onBeat:(double)beat withComplexity:(int)complexity endStreak:(BOOL)endStreak isStandalone:(BOOL)isStandalone forLoop:(int)loop
{
    
    int frameMissedHits = (int)[frame.m_notesPending count];
    int frameCorrectHits = (int)[frame.m_notesHit count];
    int frameIncorrectHits = (int)frame.m_notesWrong;
    
    double percentAccuracy = 0;
    double complexMultiplier = 1;
    double noteScore = 0;
    m_multiplier = 1;
    
    if(isStandalone){
        
        // End streak logic
        if(endStreak){
            m_streak = 0;
        }
        
        //
        // Accuracy
        //
        
        // Compare note start to beat hit
        percentAccuracy = (STANDALONE_SONG_BEATS_PER_SCREEN-frame.m_absoluteBeatStart+beat)/STANDALONE_SONG_BEATS_PER_SCREEN;
        
    }else{
        
        // End streak logic
        if ( frameMissedHits > 0 || frameIncorrectHits > 0 || (isPracticeMode && [[m_loopScores objectAtIndex:loop] intValue] == 0))
        {
            m_multiplier = 1;
            m_streak = 0;
        }
        
        //
        // Accuracy
        //
        
        // Compare how many notes were hit in the frame
        percentAccuracy = (double)frameCorrectHits / (double)(frameCorrectHits + frameIncorrectHits + frameMissedHits);
        
        //
        // Complexity
        //
        // Count the # of different frets down
        int fretson[KeysMaxKeyPosition];
        complexity = 0;
        
        for(int i = 0; i < KeysMaxKeyPosition; i++) fretson[i] = 0;
        for(NSNote * nn in frame.m_notesHit) fretson[nn.m_key] = 1;
        for(int i = 0; i < KeysMaxKeyPosition; i++) complexity += fretson[i];
        
        complexity -= 1;
    }
    
    //
    // Accuracy
    //
    // Stash to get avg
    [m_frameTimings addObject:[NSNumber numberWithDouble:percentAccuracy]];
    
    noteScore += NOTE_MAX_POINTS * percentAccuracy;
    
    //
    // Streak
    //
    
    m_streak++;
    
    if(m_streak >= 4 && m_streak < 8){
        m_multiplier = 2;
    }else if(m_streak >= 8 && m_streak < 16){
        m_multiplier = 4;
    }else if(m_streak >= 16 && m_streak < 32){
        m_multiplier = 6;
    }else if(m_streak >= 32){
        m_multiplier = 8;
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
    
    NSLog(@"Score is %f * %i * %f",noteScore,(int)m_multiplier,complexMultiplier);
    NSLog(@"Current loops is %i",loop);
    
    int subscore = noteScore * m_multiplier * complexMultiplier;
    
    // Add to loop score for practice
    
    // Add to total
    m_totalScore += subscore;
    if(isPracticeMode){
        
        if(loop > [m_loopScores count]){
            
            NSLog(@"Trying to access the next loop");
            return percentAccuracy;
            
        }else{
        
            int loopScore = [[m_loopScores objectAtIndex:loop] intValue];
            int newScore = loopScore + subscore;
            
            [m_loopScores setObject:[NSNumber numberWithInt:newScore] atIndexedSubscript:loop];
            m_score = newScore;
        }
        
    }else{
        m_score += subscore;
    }
    
    return percentAccuracy;
    
}

// Aggregate data for final display
// Called only on exit frame
- (void)scoreEndOfFrame:(NSNoteFrame*)frame
{
    int frameMissedHits = (int)[frame.m_notesPending count];
    int frameCorrectHits = (int)[frame.m_notesHit count];
    int frameIncorrectHits = (int)frame.m_notesWrong;
    
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
    
    
    [self scoreFramePerfectly:frame];
    
    //[self starRateScore];
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
    
    if(numFrames == 0){
        avgTiming = 0;
    }else{
        avgTiming = totalTiming/numFrames;
    }
    
    int bestscore = 0;
    if(isPracticeMode){
        int scoresubtotal = 0;
        for(int l = 0; l < [m_loopScores count]; l++){
            bestscore = MAX(bestscore,[[m_loopScores objectAtIndex:l] intValue]);
            scoresubtotal += [[m_loopScores objectAtIndex:l] intValue];
        }
        scoresubtotal /= [m_loopScores count];
        m_score = scoresubtotal;
    }
    
    // return data for display
    NSDictionary * data = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSNumber numberWithDouble:m_score],@"Score",
                           [NSNumber numberWithDouble:bestscore],@"BestScore",
                           [NSNumber numberWithDouble:m_totalScore],@"TotalScore",
                           [NSNumber numberWithDouble:percentNotesHit],@"PercentNotesHit",
                           [NSNumber numberWithDouble:avgTiming],@"AverageTiming",
                           [NSNumber numberWithDouble:m_streakMax],@"MaxStreak",nil];
    
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
