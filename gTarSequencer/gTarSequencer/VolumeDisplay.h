//
//  VolumeDisplay.h
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <QuartzCore/QuartzCore.h>

@interface VolumeDisplay : UIView
{
    
    UIImageView * outline;
    UIImageView * filling;
    
    UILabel * volumeLabel;
    UIColor * fillColor;
    
}

- (void)fillToPercent:(double)percent;
- (void)setVolume:(NSString *)value;


@end
