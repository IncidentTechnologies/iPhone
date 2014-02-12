//
//  MeasureView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/3/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "Measure.h"
#import <QuartzCore/QuartzCore.h>

// MeasureView (MV) is the graphical represenation of a measure. It implements a pull-based update system,
//      where once update is called externally, the MV will pull necessary data from its Measure ptr
//      and update as necessary. When not in use, the MV should be told to draw a simple border.
@interface MeasureView : UIButton
{
    UIImageView * imageView;
    
    CGFloat colors[STRINGS_ON_GTAR][4];
    
    UIView * playbandView;
    
    CGFloat noteFrameWidth;
    
    UIColor * defaultBackgroundColor;
    UIColor * highlightBackgroundColor;
    
    BOOL isBlankMeasure;
}

@property (retain, nonatomic) Measure * measure;

- (void)update;
- (void)drawMeasure:(BOOL)isBlank;
- (void)selectMeasure;
- (void)deselectMeasure;

@end
