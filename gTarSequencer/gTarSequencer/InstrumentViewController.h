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

@end

@interface InstrumentViewController : UIViewController
{
    // View data
    int activePattern;
    int activeMeasure;
    
    UIView * measureSet[NUM_PATTERNS][NUM_MEASURES];
    NSMutableArray * noteButtons[NUM_PATTERNS][NUM_MEASURES];
    NSString * patternTitles[NUM_PATTERNS];
    
    // Local instrument data
    Instrument * currentInst;
    //char * notes[NUM_PATTERNS][NUM_MEASURES];
    int measureCounts[NUM_PATTERNS];
    int declaredActiveMeasures[NUM_PATTERNS];
    
    // Timer
    NSTimer * freezeMeasureChange;
    
}

-(void)reopenView;

-(void)setActiveInstrument:(Instrument *)inst;

-(IBAction)changePattern:(id)sender;

@property (weak, nonatomic) id<InstrumentDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView * scrollView;
@property (weak, nonatomic) IBOutlet UIButton * patternButton;
@property (weak, nonatomic) IBOutlet UILabel * instrumentTitle;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconButton;
@property (weak, nonatomic) IBOutlet UIImageView * instrumentIcon;

@end
