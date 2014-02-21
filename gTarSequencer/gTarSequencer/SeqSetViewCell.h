//
//  InstrumentTableCell.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "Instrument.h"
#import "MeasureView.h"
#import <QuartzCore/QuartzCore.h>

#define SEGMENTS 5
#define MUTE_SEGMENT_INDEX 4
#define MAX_MEASURES_IN_UI 4

@class SeqSetViewController;

@interface SeqSetViewCell : UITableViewCell <UIScrollViewDelegate>
{
    
    BOOL deleteMode;
    
    NSMutableArray * patternButtons;
    UIButton * selectedPatternButton;
    UIButton * previousPatternButton;
    UIButton * queuedPatternButton;
    
    int loopModCount;

}

- (IBAction)userDidTapInstrumentIcon:(id)sender;
- (IBAction)userDidSelectNewPattern:(id)sender;
- (IBAction)userDidSelectNewMeasure:(id)sender;
- (IBAction)removeMeasures:(id)sender;
- (IBAction)addMeasures:(id)sender;

- (void)initMeasureViews;
- (void)notifyQueuedPatterns:(BOOL)reset;
- (void)resetQueuedPatternButton;
- (void)enqueuePatternButton:(int)index;
- (BOOL)hasQueuedPatternButton;
- (void)update;
- (void)deselect;

@property (weak, nonatomic) SeqSetViewController * parent;

@property (weak, nonatomic) Instrument * instrument;
@property (retain, nonatomic) NSString * instrumentName;
@property (retain, nonatomic) UIImage * instrumentIcon;

@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isMute;
@property (weak, nonatomic) Pattern * patternToDisplay;
@property (retain, nonatomic) NSMutableArray * measureViews;
@property (retain, nonatomic) NSMutableArray * measureBorders;

@property (weak, nonatomic) IBOutlet UIView * patternContainer;
@property (weak, nonatomic) IBOutlet UIView * borderContainer;

// cell elements
@property (weak, nonatomic) IBOutlet UIImageView * instrumentIconView;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconBorder;

@property (weak, nonatomic) IBOutlet UIButton * patternA;
@property (weak, nonatomic) IBOutlet UIButton * patternB;
@property (weak, nonatomic) IBOutlet UIButton * patternC;
@property (weak, nonatomic) IBOutlet UIButton * patternD;
@property (weak, nonatomic) IBOutlet UIButton * offButton;
@property (weak, nonatomic) UIView * patternABorder;
@property (weak, nonatomic) UIView * patternDBorder;

@property (weak, nonatomic) IBOutlet UIButton * addMeasuresButton;
@property (weak, nonatomic) IBOutlet UIButton * removeMeasuresButton;
@property (weak, nonatomic) IBOutlet UIButton * deleteButton;

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
