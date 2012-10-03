//
//  TrackCell.h
//  gTarSequencer
//
//  Created by Ilan Gray on 7/9/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "MeasureView.h"
#import <QuartzCore/QuartzCore.h>
#import "TouchCatcher.h"

#define SEGMENTS 5
#define MUTE_SEGMENT_INDEX 4
#define MAX_MEASURES_IN_UI 4

@class gTarSequencerViewController;

extern UIColor * backgroundColor;
extern TouchCatcher * touchCatcher;

// The InstrumentCell's is to collect and relay user input to the controller, as well as govern the updating of
//      its subviews (four MeasureViews).
@interface InstrumentCell : UITableViewCell <TouchCatcherDelegate>
{
    BOOL deleteMode;
    
    NSMutableArray * patternButtons;
    
    UIColor * minimapBorderColor;
    
    CGRect instrumentIconFrame;
    UIImage * trashcanIcon;
    CGRect trashcanFrame;
    
    UIButton * selectedPatternButton;
    UIButton * previouslySelectedPatternButton;
}

//- (IBAction)userDidTouchDownOnPattern:(id)sender;
- (IBAction)userDidSelectNewPattern:(id)sender;
- (IBAction)userDidSelectNewMeasure:(id)sender;
- (IBAction)userDidTapInstrumentIcon:(id)sender;
- (IBAction)removeMeasures:(id)sender;
- (IBAction)addMeasures:(id)sender;

- (void)initMeasureViews;
- (void)update;
- (void)deselect;

@property (weak, nonatomic) Instrument * instrument;
@property (weak, nonatomic) Pattern * patternToDisplay;
@property (nonatomic) BOOL isSelected;
@property (retain, nonatomic) NSMutableArray * measureViews;
@property (retain, nonatomic) NSString * instrumentName;
@property (retain, nonatomic) UIImage * instrumentIcon;

@property (weak, nonatomic) gTarSequencerViewController * parent;

@property (weak, nonatomic) IBOutlet UIImageView * instrumentIconView;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconViewBorder;
@property (weak, nonatomic) IBOutlet UIView * minimapBorder;
@property (weak, nonatomic) IBOutlet UIButton * addMeasureButton;
@property (weak, nonatomic) IBOutlet UIButton * removeMeasureButton;

@property (weak, nonatomic) IBOutlet MeasureView * measureOne;
@property (weak, nonatomic) IBOutlet MeasureView * measureTwo;
@property (weak, nonatomic) IBOutlet MeasureView * measureThree;
@property (weak, nonatomic) IBOutlet MeasureView * measureFour;

@property (weak, nonatomic) IBOutlet UIButton * patternA;
@property (weak, nonatomic) IBOutlet UIButton * patternB;
@property (weak, nonatomic) IBOutlet UIButton * patternC;
@property (weak, nonatomic) IBOutlet UIButton * patternD;
@property (weak, nonatomic) IBOutlet UIButton * offButton;

@end
