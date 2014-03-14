//
//  RadialButton.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/26/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "RadialButton.h"

#define ANIMATION_DURATION 0.2f
#define DEFAULT_TEMPO 120

#define ZOOMFACTOR 2
#define ZOOM_FONT 40
#define NORMAL_FONT 17
#define LARGE_FONT 30

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@implementation RadialButton

@synthesize currentValue;
@synthesize delegate;
@synthesize pixelsToIntConversion;
@synthesize valueDisplay;
@synthesize scrollTitle;

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
    startingValue = DEFAULT_TEMPO;
    
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
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    BOOL isScreenLarge = (screenBounds.size.height == XBASE_LG) ? YES : NO;
    
    // Set up radial display:
    CGRect wholeScreen;
    if(isScreenLarge){
        wholeScreen = CGRectMake(0, 0, XBASE_LG, YBASE-1);
    }else{
        wholeScreen = CGRectMake(0, 0, XBASE_SM, YBASE-1);
    }
    
    radialDisplay = [[RadialDisplay alloc] initWithFrame:wholeScreen];
    radialDisplay.userInteractionEnabled = NO;
    radialDisplay.alpha = NOT_VISIBLE;
    
    // overlay by adding to the main view
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:radialDisplay];
    
    // tempo label
    double titleWidth = 80;
    double tempoWidth = 60;
    CGRect titleframe = CGRectMake(self.frame.size.width/2-titleWidth/2-tempoWidth/2,13,80,30);
    scrollTitle = [[UILabel alloc] initWithFrame:titleframe];
    [scrollTitle setText:@"TEMPO"];
    scrollTitle.font = [UIFont fontWithName:FONT_DEFAULT size:NORMAL_FONT];
    scrollTitle.textColor = [UIColor whiteColor];
    
    [self addSubview:scrollTitle];
    
    // tempo value
    normalFrame = CGRectMake(self.frame.size.width/2+10,13,tempoWidth,30);
    
    if(isScreenLarge){
        zoomedFrame = CGRectMake(95, -90, ZOOMFACTOR*tempoWidth, ZOOMFACTOR*30);
    }else{
        zoomedFrame = CGRectMake(52, -90, ZOOMFACTOR*tempoWidth, ZOOMFACTOR*30);
    }
    
    valueDisplay = [[UILabel alloc] initWithFrame:normalFrame];
    valueDisplay.contentMode = UIViewContentModeScaleAspectFit;
    valueDisplay.font = [UIFont fontWithName:FONT_BOLD size:LARGE_FONT];
    valueDisplay.textColor = [UIColor whiteColor];
    
    [self addSubview:valueDisplay];
    
}

// Sensitivities adjusted so user reaches min/max a few px before edge of screen
- (void)computeSensitivities
{
    double origin = self.frame.origin.x;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int screensize = screenBounds.size.height;
    
    double distanceRight = screensize - ( origin + zeroPosition.x);
    double distanceLeft = zeroPosition.x + self.frame.origin.x;
    
    int rangeOfValuesUp = MAX_TEMPO - startingValue;
    int rangeOfValuesDown = startingValue - MIN_TEMPO;
    
    sensitivityRight = 1.3 * ( rangeOfValuesUp / distanceRight );
    
    sensitivityLeft = 1.1 * ( rangeOfValuesDown / distanceLeft );

}

#pragma mark Setters

- (void)setToValue:(int)newValue
{
    currentValue = newValue;
    currentDisplayedValue = currentValue;
    [valueDisplay setText:[NSString stringWithFormat:@"%i", currentValue]];
    
    [radialDisplay setTempo:[NSString stringWithFormat:@"%i", currentValue]];
    [radialDisplay fillToPercent:[self percentFull:newValue]];
}


#pragma mark Touches

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(displayOpen){
        UITouch * touch = [[touches allObjects] objectAtIndex:0];
        CGPoint touchSpot = [touch locationInView:self];
        
        currentPosition = touchSpot;
        
        // calculate difference from zero position
        double deltaX = currentPosition.x - zeroPosition.x;
        
        // use delta Y and the sensitivity to calculate the new value:
        int valueDifference;
        
        if(deltaX > 0){ // R
            valueDifference = (deltaX * sensitivityRight);
        }
        else{ // L
            valueDifference = (deltaX * sensitivityLeft);
        }
        
        if ( valueDifference == 0 ){
            return;
        }
        
        int newCurrentValue = currentValue + valueDifference;
        
        if (newCurrentValue < MIN_TEMPO){
            newCurrentValue = MIN_TEMPO;
        }else if(newCurrentValue > MAX_TEMPO){
            newCurrentValue = MAX_TEMPO;
        }
        
        // for some reason calling the other function doesn't do this granularly
        
        // Display new value in text field:
        currentDisplayedValue = newCurrentValue;
        [valueDisplay setText:[NSString stringWithFormat:@"%i", currentDisplayedValue]];
        [radialDisplay setTempo:[NSString stringWithFormat:@"%i", currentDisplayedValue]];

        // Fill radial display to corresponding %:
        [radialDisplay fillToPercent:[self percentFull:newCurrentValue]];
        
        if(ABS(valueDifference) > 5){
            //[delegate radialButtonValueDidChange:newCurrentValue withSave:NO];
        }
    }
}

- (double)percentFull:(int)value
{
    return (value-MIN_TEMPO)/(MAX_TEMPO-MIN_TEMPO);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([delegate allowTempoDisplayToOpen]){
        
        [delegate tempoDisplayDidOpen];
        
        [self expand];
        
        // update center:
        CGPoint touchDown = [[[touches allObjects] objectAtIndex:0] locationInView:self];
        
        zeroPosition = touchDown;
        
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
        
        [delegate tempoDisplayDidClose];
            
        [self contract];
        
        if ( previousValue != currentDisplayedValue )
        {
            currentValue = currentDisplayedValue;
            [self setToValue:currentValue];
            [delegate radialButtonValueDidChange:currentValue withSave:YES];
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
                         radialDisplay.alpha = VISIBLE;
                         valueDisplay.frame = zoomedFrame;
                         valueDisplay.textAlignment = NSTextAlignmentCenter;
                         valueDisplay.font = [[self.valueDisplay font] fontWithSize:ZOOM_FONT];
                         
                     }
                     completion:nil];
}

- (void)contract
{
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         radialDisplay.alpha = NOT_VISIBLE;
                         valueDisplay.frame = normalFrame;
                         valueDisplay.textAlignment = NSTextAlignmentLeft;
                         valueDisplay.font = [[self.valueDisplay font] fontWithSize:LARGE_FONT];
                     }
                     completion:nil];
    
}


@end
