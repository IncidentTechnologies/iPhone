//
//  TutorialViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 3/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <AppData.h>
#import "UIKnob.h"

#define NUM_SEQUENCE_NOTES 8

@protocol TutorialDelegate <NSObject>

- (void) notifyTutorialEnded;
@optional
- (void) notifyTutorialTapToPlayScreen;
- (void) forceToPlay;
- (void) closeLeftNavigator;
- (void) presentGatekeeper:(BOOL)animate;

@end

@interface TutorialViewController : UIView
{
    
    float screenX;
    float screenY;
    
    int tutorialStep;
    int tutorialTotalSteps;
    NSString * tutorialName;
    
    UIView * tutorialScreen;
    UIButton * tutorialBottomBar;
    UIButton * tutorialNext;
    
    UISwipeGestureRecognizer * swipeLeft;
    UISwipeGestureRecognizer * swipeRight;
    
    BOOL isScreenLarge;
    
    int conditionalScreen;
    BOOL showConditionalScreen;
    
    NSMutableArray * sequenceNotes;
    BOOL sequenceNoteActive[NUM_SEQUENCE_NOTES];
    NSTimer * sequenceLoopTimer;
    int sequenceLoopCounter;
    
    UIColor * colors[STRINGS_ON_GTAR];

}

- (id)initWithFrame:(CGRect)frame andTutorial:(NSString *)tutorial;
- (void)launch;
- (void)end;
- (void)clear;
- (void)fadeOutTutorialSubviews:(BOOL)removeAll isReverseDirection:(BOOL)reverse;

@property (weak, nonatomic) id<TutorialDelegate> delegate;

@end
