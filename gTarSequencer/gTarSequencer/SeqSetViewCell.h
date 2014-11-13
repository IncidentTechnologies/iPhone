//
//  InstrumentTableCell.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "NSSequence.h"
#import "MeasureView.h"
#import "UIKnob.h"
#import <QuartzCore/QuartzCore.h>

#define SEGMENTS 5
#define MUTE_SEGMENT_INDEX 4

@class SeqSetViewController;

@interface SeqSetViewCell : UITableViewCell <UIScrollViewDelegate,UIKnobDelegate>
{
    
    BOOL deleteMode;
    
    NSMutableArray * patternButtons;
    UIButton * selectedPatternButton;
    UIButton * previousPatternButton;
    UIButton * queuedPatternButton;
    
    UIView * volumeBg;
    UIKnob * tempVolumeKnob;
    UITapGestureRecognizer * offButtonDoubleTap;
    BOOL isTracking;
    
    int loopModCount;

}

- (IBAction)userDidTapInstrumentIcon:(id)sender;
- (IBAction)userDidSelectNewPattern:(id)sender;
- (IBAction)userDidSelectNewMeasure:(id)sender;
- (IBAction)removeMeasures:(id)sender;
- (IBAction)addMeasures:(id)sender;

- (void)initMeasureViews;
- (void)notifyQueuedPattern:(int)loopCount;
- (void)resetQueuedPatternButton;
- (void)enqueuePatternButton:(int)index;
- (BOOL)hasQueuedPatternButton;
- (void)update;
- (void)deselect;

- (void)showCustomIndicator;
- (void)hideCustomIndicator;

- (void)resetVolume;

- (void)enableKnobIfDisabled;
- (void)disableKnobIfEnabled;

@property (weak, nonatomic) SeqSetViewController * parent;

@property (weak, nonatomic) NSTrack * track;
@property (retain, nonatomic) NSString * instrumentName;
@property (retain, nonatomic) UIImage * instrumentIcon;

@property (retain, nonatomic) UIScrollView * editingScrollView;

@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isMute;
@property (weak, nonatomic) NSPattern * patternToDisplay;
@property (retain, nonatomic) NSMutableArray * measureViews;
@property (retain, nonatomic) NSMutableArray * measureBorders;
@property (weak, nonatomic) IBOutlet UIView * borderContainer;

// Slide to delete
@property (weak, nonatomic) IBOutlet UIView * patternContainer;
@property (nonatomic, strong) UIPanGestureRecognizer * panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * rightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * leftConstraint;

@property (weak, nonatomic) IBOutlet UIButton * deleteButton;

- (IBAction)userDidSelectDeleteButton:(id)sender;


// cell elements
@property (weak, nonatomic) IBOutlet UIImageView * instrumentIconView;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconBorder;
@property (weak, nonatomic) IBOutlet UIView * customIndicator;

@property (weak, nonatomic) IBOutlet UIButton * patternA;
@property (weak, nonatomic) IBOutlet UIButton * patternB;
@property (weak, nonatomic) IBOutlet UIButton * patternC;
@property (weak, nonatomic) IBOutlet UIButton * patternD;
@property (weak, nonatomic) IBOutlet UIButton * offButton;
@property (retain, nonatomic) UIKnob * volumeKnob;
@property (weak, nonatomic) UIView * patternABorder;
@property (weak, nonatomic) UIView * patternDBorder;

@property (weak, nonatomic) IBOutlet UIButton * addMeasuresButton;
@property (weak, nonatomic) IBOutlet UIButton * removeMeasuresButton;

@property (weak, nonatomic) IBOutlet MeasureView * measureOne;
@property (weak, nonatomic) IBOutlet MeasureView * measureTwo;
@property (weak, nonatomic) IBOutlet MeasureView * measureThree;
@property (weak, nonatomic) IBOutlet MeasureView * measureFour;

@property (weak, nonatomic) IBOutlet UIView * measureOneBorder;
@property (weak, nonatomic) IBOutlet UIView * measureTwoBorder;
@property (weak, nonatomic) IBOutlet UIView * measureThreeBorder;
@property (weak, nonatomic) IBOutlet UIView * measureFourBorder;

@property (weak, nonatomic) IBOutlet UIView * rightSliderPin;
@property (weak, nonatomic) IBOutlet UIView * offMask;


@end
