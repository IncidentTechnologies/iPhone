//
//  DialButton.h
//  DialButton
//
//  Created by Ilan Gray on 7/20/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define NUMBER_OF_WEDGES 8
#define ANGLE_OK -1
#define UPPER 1
#define LOWER 0

// RadialDisplay serves as the visual for the tempo slider. The wedge formation is defined in terms of a center point,
//      and inner and outer radii. RadialDisplay's one public function allows the controller to give it a % to fill to,
//      and the RD will handle everything after that. The three labels are exposed to allow the controller to set fonts.
@interface RadialDisplay : UIView
{
    UIImageView * outline;
    UIImageView * filling;
    
    double innerRadius;
    double outerRadius;
    
    double angles[NUMBER_OF_WEDGES*2];
    
    double currentAngle;
    
    UIColor * fillColor;
}

- (void)fillToPercent:(double)percent;

@property (nonatomic) CGPoint center;
@property (retain, nonatomic) UILabel * bottomLabel;
@property (retain, nonatomic) UILabel * middleLabel;
@property (retain, nonatomic) UILabel * topLabel;

@end