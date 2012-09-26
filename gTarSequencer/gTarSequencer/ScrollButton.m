//
//  ScrollButton.m
//  SliderButton
//
//  Created by Ilan Gray on 6/19/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "ScrollButton.h"

#define ANIMATION_DURATION 0.2f

@implementation ScrollButton

@synthesize currentValue;
@synthesize delegate;
@synthesize pixelsToIntConversion;
@synthesize valueDisplay;

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

#pragma mark Init'ers

- (void)commonInit
{
    startingValue = 120;
    [self setBackgroundColor:[UIColor clearColor]];
    
    // calculate the zero position (middle of the button)
    zeroPosition.x = self.frame.size.width / 2;
    zeroPosition.y = self.frame.size.height / 2;
    
    // Set up radial display:
    CGPoint currentOrigin = self.frame.origin;
    CGRect wholeScreen = CGRectMake(-1 * currentOrigin.x, -1 * currentOrigin.y, 480, 320);
    radialDisplay = [[RadialDisplay alloc] initWithFrame:wholeScreen];
    radialDisplay.userInteractionEnabled = NO;
    [self addSubview:radialDisplay];
    radialDisplay.alpha = NOT_VISIBLE;
    
    // compute sensitivities:
    [self computeSensitivities];
}

- (void)layoutSubviews
{
    // set up frames:
    normalFrame = valueDisplay.frame;
    
    CGFloat zoomedWidth = 120;
    CGFloat zoomedHeight = 50;
    
    zoomedFrame = CGRectMake(radialDisplay.center.x - zoomedWidth/2, radialDisplay.center.y - zoomedHeight*1.4, zoomedWidth, zoomedHeight);
    
    // set up fonts:
    normalFont = [self.valueDisplay font];
    mediumFont = [[self.valueDisplay font] fontWithSize:40];
    largeFont = [[self.valueDisplay font] fontWithSize:60];
    
    UIFont * smallFont = [[self.valueDisplay font] fontWithSize:15];
    radialDisplay.bottomLabel.font = smallFont;
    radialDisplay.middleLabel.font = smallFont;
    radialDisplay.topLabel.font = smallFont;
}

- (void)computeSensitivities
{
    double origin = self.frame.origin.x;
    
    double distanceRight = 480 - ( origin + zeroPosition.x);
    double distanceLeft = zeroPosition.x + self.frame.origin.x;
    
    int rangeOfValuesUp = MAX_TEMPO - startingValue;
    int rangeOfValuesDown = startingValue - MIN_TEMPO;

    sensitivityRight = 0.9 * ( rangeOfValuesUp / distanceRight );
    
    sensitivityLeft = 0.9 * ( rangeOfValuesDown / distanceLeft );
    
    /* The sensistivities get adjusted a bit so that the user will 
     reach the min/max value a few pixels from the edge of the screen */
}

#pragma mark Setters

- (void)setToValue:(int)newValue
{
    currentValue = newValue;
    currentDisplayedValue = currentValue;
    valueDisplay.text = [NSString stringWithFormat:@"%i", currentValue];
    
    [radialDisplay fillToPercent:[self percentFull:newValue]];
}

#pragma mark Touches
 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [[touches allObjects] objectAtIndex:0];
    CGPoint touchSpot = [touch locationInView:self];
    
    currentPosition = touchSpot;
    
    // calculate difference from zero position
    double deltaX = currentPosition.x - zeroPosition.x;
    
    // use delta Y and the sensitivity to calculate the new value:
    int valueDifference;

    if ( deltaX > 0 )       // RIGHT
    {
        valueDifference = (deltaX * sensitivityRight);
    }
    else                    // LEFT
    {
        valueDifference = (deltaX * sensitivityLeft);
    }
    
    if ( valueDifference == 0 )
    {
        return;
    }

    int newCurrentValue = currentValue + valueDifference;
    
    if ( newCurrentValue < MIN_TEMPO )
    {
        newCurrentValue = MIN_TEMPO;
    }
    else if ( newCurrentValue > MAX_TEMPO )
    {
        newCurrentValue = MAX_TEMPO;
    }
    
    // Display new value in text field:
    currentDisplayedValue = newCurrentValue;
    NSString * newText = [NSString stringWithFormat:@"%i", currentDisplayedValue];
    valueDisplay.text = newText;
    
    // Fill radial display to corresponding %:
    [radialDisplay fillToPercent:[self percentFull:newCurrentValue]];
}

- (double)percentFull:(int)value
{
    return (value-MIN_TEMPO)/(MAX_TEMPO-MIN_TEMPO);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self expand];
    
    // update center:
    CGPoint touchDown = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    
    zeroPosition = touchDown;
    
    previousValue = currentValue;
    currentDisplayedValue = currentValue;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self contract];
    
    if ( previousValue != currentDisplayedValue )
    {
        currentValue = currentDisplayedValue;
        [self setToValue:currentValue];
        [delegate scrollButtonValueDidChange:currentValue];
    }
}

#pragma mark Zooming

- (void)expand
{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{ 
                         radialDisplay.alpha = VISIBLE; 
                         valueDisplay.frame = zoomedFrame;
                         valueDisplay.font = largeFont; 
                
                                 } 
                     completion:nil];
}

- (void)contract
{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut 
                     animations:^{
                         radialDisplay.alpha = NOT_VISIBLE; 
                         valueDisplay.frame = normalFrame; 
                         valueDisplay.font = normalFont;
                                 } 
                     completion:nil];
}


@end
