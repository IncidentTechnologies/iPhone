//
//  CustomBeveledView.m
//  gTarPlay
//
//  Created by Marty Greenia on 12/1/11.
//  Copyright (c) 2011 Incident Technologies. All rights reserved.
//

#import "CustomBeveledView.h"

#import <QuartzCore/QuartzCore.h>

@implementation CustomBeveledView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOffset = CGSizeMake(0, -1);
        self.clipsToBounds = NO;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat value;
    
    value = 215.0f/255.0f;
    UIColor * color1 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 160.0f/255.0f;
    UIColor * color2 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 180.0f/255.0f;
    UIColor * color3 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 150.0f/255.0f;
    UIColor * color4 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];
    
    value = 100.0f/255.0f;
    UIColor * color5 = [UIColor colorWithRed:value green:value blue:value alpha:1.0f];

    // Create gradient.
    CGColorRef colorRefs[5] =
    {
        [color1 CGColor],
        [color2 CGColor],
        [color3 CGColor],
        [color4 CGColor],
        [color5 CGColor]
    };
    
    CGFloat locations[5] =
    {
        0.02f,
        0.05f,
        0.85f,
        0.95f,
        1.0f
    };
    
    CFArrayRef colors = CFArrayCreate( NULL, (const void **)colorRefs, 5, NULL );
    CGGradientRef gradient = CGGradientCreateWithColors( NULL, colors, locations );
    
    // Create image.
    CGContextDrawLinearGradient( context, gradient, CGPointMake(0, 0), CGPointMake(0, self.frame.size.height), 0 );
    
    // Clean up.
    CFRelease(colors);
    CGGradientRelease(gradient);
    
}

@end
