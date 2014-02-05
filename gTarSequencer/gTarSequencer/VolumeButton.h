//
//  VolumeButton.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <QuartzCore/CALayer.h>
#import "VolumeDisplay.h"

@protocol VolumeButtonDelegate <NSObject>

- (void) volumeButtonValueDidChange:(double)newValue;

@end

#define VISIBLE 1.0f
#define NOT_VISIBLE 0.0f

@interface VolumeButton : UIButton
{
    VolumeDisplay * volumeDisplay;
    
    double startingValue;
    double currentValue;
    double previousValue;
    double currentDisplayedValue;
    
    CGPoint currentPosition;
    CGPoint zeroPosition;
    
    double sensitivityTop; // px/unit (int)conversion
    double sensitivityBottom;
    
}

- (void)setToValue:(double)newValue;

@property (weak, nonatomic) id <VolumeButtonDelegate> delegate;

@end
