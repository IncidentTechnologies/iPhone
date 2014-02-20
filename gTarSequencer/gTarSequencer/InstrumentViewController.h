//
//  InstrumentViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"

#define NUM_PATTERNS 4
#define NUM_MEASURES 4

#define FRETS_ON_GTAR 16
#define STRINGS_ON_GTAR 6
#define MAX_NOTES 96

@protocol InstrumentDelegate <NSObject>

- (void) saveContext:(NSString *)filepath;
- (BOOL) checkIsPlaying;
- (void) enqueuePattern:(NSMutableDictionary *)pattern;
- (void) dequeueAllPatternsForInstrument:(Instrument *)inst;
- (void) viewSeqSet;

- (BOOL) isLeftNavOpen;
- (void) openLeftNavigator;
- (void) closeLeftNavigator;

- (void) setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

@end

@interface InstrumentViewController : UIViewController <UIScrollViewDelegate>
{
    // View data
    int activePattern;
    int activeMeasure;
    
    UIView * measureSet[NUM_PATTERNS][NUM_MEASURES];
    UIButton * noteButtons[NUM_PATTERNS][NUM_MEASURES][MAX_NOTES];
    UIView * pages[NUM_MEASURES];
    
    UIColor * colors[STRINGS_ON_GTAR];
    
    NSMutableArray * patternButtons;
    UIButton * selectedPatternButton;
    UIButton * previousPatternButton;
    UIButton * queuedPatternButton;
    int loopModCount;
    
    // Playband
    UIView * playbandView[NUM_MEASURES];
    int playband[NUM_MEASURES];
    
    // Local instrument data
    Instrument * currentInst;

    int measureCounts[NUM_PATTERNS];
    int declaredActiveMeasures[NUM_PATTERNS];
    
    CGPoint lastContentOffset;
    int targetMeasure;
    
}

-(void)reopenView;

-(void)setPlaybandForMeasure:(int)measureIndex toPlayband:(int)p;
-(void)commitPatternChange:(int)patternIndex;

-(void)notifyQueuedPatternAndResetCount:(BOOL)resetCount;

-(void)setActiveInstrument:(Instrument *)inst;

-(void)updateActiveMeasure;

//-(IBAction)changePattern:(id)sender;
//-(IBAction)stopChangePattern:(id)sender;
-(IBAction)userDidSelectNewPattern:(id)sender;
-(IBAction)viewSeqSet:(id)sender;

@property (nonatomic) BOOL isMute;

@property (weak, nonatomic) id<InstrumentDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;
@property (weak, nonatomic) IBOutlet UIButton * patternA;
@property (weak, nonatomic) IBOutlet UIButton * patternB;
@property (weak, nonatomic) IBOutlet UIButton * patternC;
@property (weak, nonatomic) IBOutlet UIButton * patternD;
@property (weak, nonatomic) IBOutlet UIButton * offButton;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconButton;
@property (weak, nonatomic) IBOutlet UIImageView * instrumentIcon;

@property (weak, nonatomic) IBOutlet UIView * pageOne;
@property (weak, nonatomic) IBOutlet UIView * pageTwo;
@property (weak, nonatomic) IBOutlet UIView * pageThree;
@property (weak, nonatomic) IBOutlet UIView * pageFour;

@property (weak, nonatomic) IBOutlet UIView * offMask;

@end
