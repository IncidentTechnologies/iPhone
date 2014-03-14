//
//  VolumeDisplay.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "VolumeDisplay.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

#define ANIMATION_DURATION 0.2f

@implementation VolumeDisplay

@synthesize delegate;
@synthesize sliderCircle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    self.userInteractionEnabled = YES;
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = x;
    
    outline = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:outline];
    
    filling = [[UIImageView alloc] initWithFrame:frame];
    filling.clearsContextBeforeDrawing = NO;
    [self addSubview:filling];
    
    [self createOutline];
    [self addGestures];
    
    // Get dimensions for filling
    CGSize fullScreen = CGSizeMake(x, 320);
    UIGraphicsBeginImageContextWithOptions(fullScreen, NO, 0);
    
    // Prepare for touches
    zeroPosition.x = self.frame.size.width / 2;
    zeroPosition.y = self.frame.size.height / 4;
}

- (void)setVolume:(double)value
{
    NSLog(@"Set volume to %f",value);
    
    currentValue = value;
    
    //[self setVolumeGainTo:value];
    [self fillToPercent:[self percentFull:value]];
}

#pragma mark Filling

- (double)percentFull:(double)value
{
    double percentFull = (value-MIN_VOLUME)/(MAX_VOLUME-MIN_VOLUME);
    
    //NSLog(@" *** fill to %f percent ", percentFull);
    
    return percentFull;
}

- (void)fillToPercent:(double)percent
{
    double y = sliderCircleMinY - (sliderCircleMinY - sliderCircleMaxY)*percent;
    
    //NSLog(@"y is %f",y);
    
    CGRect newFrame = CGRectMake(sliderCircle.frame.origin.x, y, sliderCircle.frame.size.width, sliderCircle.frame.size.height);
    
    [UIView animateWithDuration:0.1 animations:^(void){[sliderCircle setFrame:newFrame];}];

}


#pragma mark Outline

- (void)createOutline
{
    // NSLog(@"outline frame is %f %f %f %f",outline.frame.origin.x,outline.frame.origin.y,outline.frame.size.width,outline.frame.size.height);
    
    // Draw black background:
    [outline setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    
    // Draw right sidebar
    float sidebarWidth = 130;
    CGRect sidebarFrame = CGRectMake(outline.frame.size.width - sidebarWidth, -1, sidebarWidth+1, outline.frame.size.height+2);
    
    UIView * sidebar = [[UIView alloc] initWithFrame:sidebarFrame];
    sidebar.backgroundColor = [UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0];
    sidebar.layer.borderColor = [UIColor whiteColor].CGColor;
    sidebar.layer.borderWidth = 1.0;
    
    [outline addSubview:sidebar];
    
    // Draw sidebar slider
    float sliderWidth = 45;
    float sliderHeight = 190;
    CGRect sliderFrame = CGRectMake((sidebar.frame.size.width-sliderWidth)/2, (sidebar.frame.size.height-sliderHeight)/2, sliderWidth, sliderHeight);
    
    UIView * slider = [[UIView alloc] initWithFrame:sliderFrame];
    slider.layer.borderColor = [UIColor whiteColor].CGColor;
    slider.layer.borderWidth = 3.0f;
    slider.layer.cornerRadius = sliderWidth/2;
    
    [sidebar addSubview:slider];
    
    // Draw sidebar slider circle
    float baseX = slider.frame.origin.x+sidebar.frame.origin.x;
    float baseY = slider.frame.origin.y;
    float indent = 5;
    float circleWidth = sliderWidth-2*indent;
    sliderCircleMaxY = indent+baseY-1;
    sliderCircleMinY = slider.frame.size.height - circleWidth - indent - 1 + baseY;

    CGRect sliderCircleFrame = CGRectMake(baseX+indent, sliderCircleMinY, circleWidth, circleWidth);
    
    sliderCircle = [[UIButton alloc] initWithFrame:sliderCircleFrame];
    sliderCircle.backgroundColor = [UIColor colorWithRed:141/255.0 green:112/255.0 blue:166/255.0 alpha:1.0];
    sliderCircle.layer.cornerRadius = sliderWidth/2-indent;
    
    [self addSubview:sliderCircle];
    
}

- (void)addGestures
{
    [sliderCircle setUserInteractionEnabled:YES];
    
    UIPanGestureRecognizer * sliderPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panVolume:)];
    
    [sliderCircle addGestureRecognizer:sliderPan];
    
}

#pragma mark - Expand Contract
- (void)expand
{
    // Animate...
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = VISIBLE;
                     }
                     completion:nil];
}

- (void)contract
{
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = NOT_VISIBLE;
                     }
                     completion:nil];
    
}

#pragma mark - Drag slider
- (void)panVolume:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:self];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        volumeFirstY = sliderCircle.frame.origin.y;
    }
    
    float newY = newPoint.y + volumeFirstY;
    
    // Wrap to boundary
    if(newY <= sliderCircleMaxY*1.2){
        newY = sliderCircleMaxY;
    }else if(newY >= sliderCircleMinY*1.2){
        newY = sliderCircleMinY;
    }
    
    float height = 1-(newY - sliderCircleMaxY)/(sliderCircleMinY - sliderCircleMaxY);
    float volume = MAX(height*MAX_VOLUME,MIN_VOLUME);
    
    
    if(newY <= sliderCircleMinY && newY >= sliderCircleMaxY){
        [self setVolume:volume];
    }
    
    // Set the volume
    BOOL save = NO;
    if([sender state] == UIGestureRecognizerStateEnded){
        save = YES;
    }
    
    [delegate volumeButtonValueDidChange:currentValue withSave:save];
    
}

#pragma mark - Audio Controller
/*
-(void)setVolumeGainTo:(double)value
{
    
    NSLog(@" **** Set channel gain to %f *** ",value);
    
    AudioController * audioController = [AudioController sharedAudioController];
    AudioNode * root = [[audioController GetNodeNetwork] GetRootNode];
    
    root->SetChannelGain(value, CONN_OUT);
    
}
*/


@end
