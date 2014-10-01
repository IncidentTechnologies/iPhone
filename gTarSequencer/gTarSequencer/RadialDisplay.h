//
//  RadialDisplay.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/26/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <QuartzCore/QuartzCore.h>

#define NUMBER_OF_WEDGES 8
#define ANGLE_OK -1
#define UPPER 1
#define LOWER 0

// RadialDisplay serves as the visual for the tempo slider.
// The wedge formation is defined in terms of a center point,
// and inner and outer radii. RadialDisplay's one public function
// allows the controller to give it a % to fill to, and the RD will
// handle everything after that.
@interface RadialDisplay : UIView
{
    UIImageView * outline;
    UIImageView * filling;
    
    /*UILabel * bottomLabel;
    UILabel * middleLabel;
    UILabel * topLabel;*/
    UILabel * tempoLabel;
    
    double innerRadius;
    double outerRadius;
    
    double angles[NUMBER_OF_WEDGES*2];
    
    double currentAngle;
    
    UIColor * fillColor;
}

- (void)fillToPercent:(double)percent;
- (void)setTempo:(NSString *)value;

- (void)beginContext;
- (void)endContext;

@property (nonatomic) CGPoint center;

@end