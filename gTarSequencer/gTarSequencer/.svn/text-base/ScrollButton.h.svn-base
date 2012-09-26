//
//  ScrollButton.h
//  SliderButton
//
//  Created by Ilan Gray on 6/19/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#import "RadialDisplay.h"

@protocol ScrollButtonDelegate <NSObject>

- (void)scrollButtonValueDidChange:(int)newValue;

@end

#define STARTING_FONT_SIZE 14
#define NUMBER_OF_WEDGES 8
#define ANGLE_OK -1 
#define MIN_TEMPO 60.0
#define MAX_TEMPO 180.0
#define VISIBLE 1.0f
#define NOT_VISIBLE 0.0f

@interface ScrollButton : UIImageView
{
    RadialDisplay * radialDisplay;
    
    int startingValue;

    int currentValue;
    int currentDisplayedValue;
    int previousValue;
    
    CGPoint currentPosition;
    CGPoint zeroPosition;
    
    double sensitivityLeft;         // pixels per unit of value (ints) conversion
    double sensitivityRight;
    
    UIFont * normalFont;
    UIFont * mediumFont;
    UIFont * largeFont;
    
    CGRect normalFrame;
    CGRect zoomedFrame;
}

- (void)setToValue:(int)newValue;

@property (weak, nonatomic) id <ScrollButtonDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel * valueDisplay;
@property (nonatomic, readonly) int currentValue;
@property (nonatomic, assign) int pixelsToIntConversion;

@end
