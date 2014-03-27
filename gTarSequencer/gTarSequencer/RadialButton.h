//
//  RadialButton.h
//  RadialButton
//
//  Created by Kate Schnippering on 12/26/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import <QuartzCore/CALayer.h>
#import "RadialDisplay.h"

@protocol RadialButtonDelegate <NSObject>

- (void) radialButtonValueDidChange:(int)newValue withSave:(BOOL)save;
- (BOOL) allowTempoDisplayToOpen;
- (void) tempoDisplayDidOpen;
- (void) tempoDisplayDidClose;

@end

#define STARTING_FONT_SIZE 14
#define NUMBER_OF_WEDGES 8
#define ANGLE_OK -1
#define MIN_TEMPO 60.0
#define MAX_TEMPO 180.0

@interface RadialButton : UIButton
{
    RadialDisplay * radialDisplay;
    
    int startingValue;
    
    int currentValue;
    int currentDisplayedValue;
    int previousValue;
    
    CGPoint currentPosition;
    CGPoint zeroPosition;
    
    double sensitivityLeft; // px/unit (int)conversion
    double sensitivityRight;
    
    CGRect normalFrame;
    CGRect zoomedFrame;
    
    BOOL displayOpen;
}

- (void)setToValue:(int)newValue;

@property (weak, nonatomic) id <RadialButtonDelegate> delegate;
@property (retain, nonatomic) UILabel * valueDisplay;
@property (retain, nonatomic) UILabel * scrollTitle;
@property (nonatomic, readonly) int currentValue;
@property (nonatomic, assign) int pixelsToIntConversion;

@end
