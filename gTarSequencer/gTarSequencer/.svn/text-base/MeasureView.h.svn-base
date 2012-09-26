//
//  MeasureView.h
//  gTarSequencer
//
//  Created by Ilan Gray on 7/18/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Measure.h"
#import <QuartzCore/QuartzCore.h>

// MeasureView (MV) is the graphical represenation of a measure. It implements a pull-based update system,
//      where once update is called externally, the MV will pull necessary data from its Measure ptr
//      and update as necessary. When not in use, the MV should be told to draw a simple border.
@interface MeasureView : UIControl
{
    UIImageView * imageView;
    
    CGFloat colors[STRINGS_ON_GTAR][4];
    
    UIView * playbandView;
    
    CGFloat noteFrameWidth;
}

@property (retain, nonatomic) Measure * measure;

- (void)update;
- (void)drawBorder;

@end
