//
//  InstrumentViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "TutorialViewController.h"

@protocol InstrumentDelegate <NSObject>

- (void) saveContext:(NSString *)filepath;
- (BOOL) checkIsPlaying;
- (void) enqueuePattern:(NSMutableDictionary *)pattern;
- (void) dequeueAllPatternsForInstrument:(Instrument *)inst;
- (int) getQueuedPatternIndexForInstrument:(Instrument *)inst;
- (void) viewSeqSetWithAnimation:(BOOL)animate;

- (BOOL) isLeftNavOpen;
- (void) openLeftNavigator;
- (void) closeLeftNavigator;

- (void) setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

@end

@interface InstrumentViewController : UIViewController <UIScrollViewDelegate,TutorialDelegate>
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
    
    // Pages
    UIColor * pageOnColor;
    UIColor * pageOffColor;
    
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
-(IBAction)userDidSelectNewMeasure:(id)sender;
-(IBAction)viewSeqSet:(id)sender;

@property (retain, nonatomic) TutorialViewController * tutorialViewController;

@property (nonatomic) BOOL isFirstLaunch;

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
@property (weak, nonatomic) IBOutlet UIView * iconOverlap;
@property (weak, nonatomic) IBOutlet UIView * customIndicator;

@property (weak, nonatomic) IBOutlet UIButton * pageOne;
@property (weak, nonatomic) IBOutlet UIButton * pageTwo;
@property (weak, nonatomic) IBOutlet UIButton * pageThree;
@property (weak, nonatomic) IBOutlet UIButton * pageFour;

@property (weak, nonatomic) IBOutlet UIView * offMask;

@end
