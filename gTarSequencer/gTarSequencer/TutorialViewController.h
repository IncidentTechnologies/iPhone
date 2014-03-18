//
//  TutorialViewController.h
//  Sequence
//
//  Created by Kate Schnippering on 3/13/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import <AppData.h>

@protocol TutorialDelegate <NSObject>

- (void) notifyTutorialEnded;

@end

@interface TutorialViewController : UIView
{
    
    float screenX;
    float screenY;
    
    int tutorialStep;
    int tutorialTotalSteps;
    NSString * tutorialName;
    
    UIView * tutorialScreen;
    UIView * tutorialBottomBar;
    UIButton * tutorialNext;
    
    UISwipeGestureRecognizer * swipeLeft;
    UISwipeGestureRecognizer * swipeRight;
    
    BOOL isScreenLarge;
    
    int conditionalScreen;
    BOOL showConditionalScreen;
}

- (id)initWithFrame:(CGRect)frame andTutorial:(NSString *)tutorial;
- (void)launch;
- (void)end;
- (void)clear;
- (void)fadeOutTutorialSubviews:(BOOL)removeAll isReverseDirection:(BOOL)reverse;

@property (weak, nonatomic) id<TutorialDelegate> delegate;

@end
