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
    int tutorialStep;
    int tutorialTotalSteps;
    NSString * tutorialName;
    
    UIView * tutorialScreen;
    UIView * tutorialBottomBar;
    UIButton * tutorialNext;

    BOOL isScreenLarge;
}

- (id)initWithFrame:(CGRect)frame andTutorial:(NSString *)tutorial;
- (void)launch;
- (void)end;
- (void)fadeOutTutorialSubviews:(BOOL)removeAll;

@property (weak, nonatomic) id<TutorialDelegate> delegate;

@end
