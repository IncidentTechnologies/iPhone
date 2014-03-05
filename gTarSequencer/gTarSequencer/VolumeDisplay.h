//
//  VolumeDisplay.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <QuartzCore/QuartzCore.h>

@protocol VolumeDisplayDelegate <NSObject>

- (void) volumeButtonValueDidChange:(double)newValue;
- (BOOL) allowVolumeDisplayToOpen;
- (void) volumeDisplayDidOpen;
- (void) volumeDisplayDidClose;

@end

@interface VolumeDisplay : UIView
{
    double currentValue;
    
    CGPoint currentPosition;
    CGPoint zeroPosition;
    
    double sensitivityTop; // px/unit (int)conversion
    double sensitivityBottom;
    double sensitivityLeft;
    double sensitivityRight;
    
    UIImageView * outline;
    UIImageView * filling;
    
    UILabel * volumeLabel;
    UIColor * fillColor;
    
    float sliderCircleMaxY;
    float sliderCircleMinY;
    
    float volumeFirstY;
}

- (void)fillToPercent:(double)percent;
- (void)setVolume:(double)value;
- (void)expand;
- (void)contract;

@property (weak, nonatomic) id <VolumeDisplayDelegate> delegate;
@property (retain, nonatomic) UIButton * sliderCircle;

@end
