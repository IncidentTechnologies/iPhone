//
//  InstrumentViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSSequence.h"
#import "TutorialViewController.h"
#import "UIKnob.h"
#import "VolumeKnobView.h"

@protocol InstrumentDelegate <NSObject>

- (void) saveStateToDiskWithForce:(BOOL)force;
- (BOOL) checkIsPlaying;
- (void) enqueuePattern:(NSMutableDictionary *)pattern forTrack:(NSTrack *)track;
- (void) dequeueAllPatternsForTrack:(NSTrack *)track;
- (int) getQueuedPatternIndexForTrack:(NSTrack *)track;
- (void) viewSeqSetWithAnimation:(BOOL)animate;

- (BOOL) isLeftNavOpen;
- (void) openLeftNavigator;
- (void) closeLeftNavigator;

- (void) setMeasureAndUpdate:(NSMeasure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

@end

@interface InstrumentViewController : UIViewController <UIScrollViewDelegate,TutorialDelegate,UIKnobDelegate,VolumeKnobViewDelegate>
{
    // View data
    int activePattern;
    int activeMeasure;
    
    UIView * activeMeasureSet[NUM_MEASURES];
    UIView * inactiveMeasureSet[NUM_MEASURES];
    UIButton * noteButtons[NUM_MEASURES][MAX_NOTES];
    
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
    NSTrack * currentTrack;
    
    int measureCounts[NUM_PATTERNS];
    int declaredActiveMeasures[NUM_PATTERNS];
    
    CGPoint lastContentOffset;
    int targetMeasure;
    int measureToDelete;
    
    // Pages
    UIColor * pageOnColor;
    UIColor * pageOffColor;
    
    UIView * volumeBg;
    UIKnob * tempVolumeKnob;
    BOOL isTracking;
    UITapGestureRecognizer * offButtonDoubleTap;
    
}

-(void)leftNavWillOpen;
-(void)leftNavDidClose;

-(void)reopenView;

-(void)setPlaybandForMeasure:(int)measureIndex toPlayband:(int)p;
-(void)commitPatternChange:(int)patternIndex;

-(void)notifyQueuedPatternAndResetCount:(BOOL)resetCount;

-(void)setActiveTrack:(NSTrack *)track;

-(void)updateActiveMeasure;

-(void)resetVolume;

//-(IBAction)changePattern:(id)sender;
//-(IBAction)stopChangePattern:(id)sender;
-(IBAction)userDidSelectNewPattern:(id)sender;
-(IBAction)userDidSelectNewMeasure:(id)sender;
-(IBAction)viewSeqSet:(id)sender;

-(void)enableKnobIfDisabled;
-(void)disableKnobIfEnabled;

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
@property (retain, nonatomic) UIKnob * volumeKnob;
@property (weak, nonatomic) IBOutlet VolumeKnobView * volumeKnobView;
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
