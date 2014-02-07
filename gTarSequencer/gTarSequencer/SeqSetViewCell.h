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

@interface SeqSetViewCell : UITableViewCell
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
- (void)update;
- (void)deselect;

@property (weak, nonatomic) SeqSetViewController * parent;

@property (weak, nonatomic) Instrument * instrument;
@property (retain, nonatomic) NSString * instrumentName;
@property (retain, nonatomic) UIImage * instrumentIcon;

@property (nonatomic) BOOL isSelected;
@property (weak, nonatomic) Pattern * patternToDisplay;
@property (retain, nonatomic) NSMutableArray * measureViews;

@property (weak, nonatomic) IBOutlet UIView * patternContainer;
@property (weak, nonatomic) IBOutlet UIView * borderContainer;

// cell elements
@property (weak, nonatomic) IBOutlet UIImageView * instrumentIconView;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconBorder;
@property (weak, nonatomic) IBOutlet UIView * minimapBorder;

@property (weak, nonatomic) IBOutlet UIButton * patternA;
@property (weak, nonatomic) IBOutlet UIButton * patternB;
@property (weak, nonatomic) IBOutlet UIButton * patternC;
@property (weak, nonatomic) IBOutlet UIButton * patternD;
@property (weak, nonatomic) IBOutlet UIButton * offButton;

@property (weak, nonatomic) IBOutlet UIButton * addMeasureButton;
@property (weak, nonatomic) IBOutlet UIButton * removeMeasureButton;

@property (weak, nonatomic) IBOutlet MeasureView * measureOne;
@property (weak, nonatomic) IBOutlet MeasureView * measureTwo;
@property (weak, nonatomic) IBOutlet MeasureView * measureThree;
@property (weak, nonatomic) IBOutlet MeasureView * measureFour;


@end
