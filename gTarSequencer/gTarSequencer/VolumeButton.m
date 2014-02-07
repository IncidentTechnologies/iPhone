//
//  VolumeButton.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "VolumeButton.h"

#define ANIMATION_DURATION 0.2f

#define DEFAULT_VOLUME 1.0
#define MIN_VOLUME 0.02
#define MAX_VOLUME 3.0

#define XBASE 480
#define YBASE 320

@implementation VolumeButton

@synthesize delegate;
//@synthesize startingValue;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

#pragma mark Init

- (void)commonInit
{
    startingValue = DEFAULT_VOLUME;
    
    // calculate the zero position (middle of the button)
    zeroPosition.x = self.frame.size.width / 2;
    zeroPosition.y = self.frame.size.height / 2;
    
    // draw subviews
    [self initSubviews];
    
    // compute sensitivities:
    [self computeSensitivities];
    
}

- (void)initSubviews
{
    // Set up volume display:
    CGRect wholeScreen = CGRectMake(0, 0, XBASE, YBASE-1);
    
    volumeDisplay = [[VolumeDisplay alloc] initWithFrame:wholeScreen];
    volumeDisplay.userInteractionEnabled = NO;
    volumeDisplay.alpha = NOT_VISIBLE;
    
    // overlay by adding to the main view
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:volumeDisplay];
    
}

// Sensitivities adjusted so user reaches min/max a few px before edge of screen
- (void)computeSensitivities
{
    double origin = self.frame.origin.x;
    
    double distanceTop = YBASE - ( origin + zeroPosition.y);
    double distanceBottom = zeroPosition.y + self.frame.origin.y;
    
    int rangeOfValuesUp = MAX_VOLUME - startingValue;
    int rangeOfValuesDown = startingValue - MAX_VOLUME;
    
    sensitivityTop = 1.1 * ( rangeOfValuesUp / distanceTop );
    
    sensitivityBottom = 1.5 * ( rangeOfValuesDown / distanceBottom );
    
}

#pragma mark Setters

- (void)setToValue:(double)newValue
{
    currentValue = newValue;
    currentDisplayedValue = newValue;
    
    [volumeDisplay setVolume:[NSString stringWithFormat:@"%f", currentValue]];
    [volumeDisplay fillToPercent:[self percentFull:newValue]];
}


#pragma mark - Touches
- (double)percentFull:(int)value
{
    return (value-MIN_VOLUME)/(MAX_VOLUME-MIN_VOLUME);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [[touches allObjects] objectAtIndex:0];
    CGPoint touchSpot = [touch locationInView:self];
    
    currentPosition = touchSpot;
    
    // calculate difference from zero position
    double deltaY = currentPosition.y - zeroPosition.y;
    
    // use delta Y and the sensitivity to calculate the new value:
    double valueDifference;
    
    if(deltaY > 0){ // UP
        valueDifference = (deltaY * sensitivityTop);
    }
    else{ // DOWN
        valueDifference = (deltaY * sensitivityBottom);
    }
    
    if ( valueDifference == 0 ){
        return;
    }
    
    double newCurrentValue = currentValue + valueDifference;
    
    if (newCurrentValue < MIN_VOLUME){
        newCurrentValue = MIN_VOLUME;
    }else if(newCurrentValue > MAX_VOLUME){
        newCurrentValue = MAX_VOLUME;
    }
    
    // for some reason calling the other function doesn't do this granularly
    
    // Display new value in text field:
    currentDisplayedValue = newCurrentValue;
    [volumeDisplay setVolume:[NSString stringWithFormat:@"%f", currentDisplayedValue]];
    
    // Fill radial display to corresponding %:
    [volumeDisplay fillToPercent:[self percentFull:newCurrentValue]];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([delegate allowVolumeDisplayToOpen]){
        
        [delegate volumeDisplayDidOpen];
        
        [self expand];
        
        // update center:
        //CGPoint touchDown = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        
        //zeroPosition = touchDown;
        
        previousValue = currentValue;
        currentDisplayedValue = currentValue;
        
        displayOpen = true;
        
    }else{
        
        displayOpen = false;
    
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(displayOpen){
        
        [delegate volumeDisplayDidClose];
        
        [self contract];
        
        if ( previousValue != currentDisplayedValue )
        {
            currentValue = currentDisplayedValue;
            [self setToValue:currentValue];
            [delegate volumeButtonValueDidChange:currentValue];
        }
        
        displayOpen = false;
    }
}

#pragma mark Zoom

- (void)expand
{
    
    // Animate...
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         volumeDisplay.alpha = VISIBLE;
                     }
                     completion:nil];
}

- (void)contract
{
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         volumeDisplay.alpha = NOT_VISIBLE;
                     }
                     completion:nil];
    
}

@end
