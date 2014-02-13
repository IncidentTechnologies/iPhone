//
//  VolumeDisplay.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "VolumeDisplay.h"

@implementation VolumeDisplay

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
    
    self.userInteractionEnabled = NO;
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = x;
    
    fillColor = [UIColor colorWithRed:106/255.0 green:159/255.0 blue:172/255.0 alpha:1];
    
    outline = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:outline];
    
    filling = [[UIImageView alloc] initWithFrame:frame];
    filling.clearsContextBeforeDrawing = NO;
    [self addSubview:filling];
    
    [self createOutline];
    
    // Get dimensions for filling
    CGSize fullScreen = CGSizeMake(x, 320);
    UIGraphicsBeginImageContextWithOptions(fullScreen, NO, 0);
}

- (void)setVolume:(NSString *)value
{
    //[volumeLabel setText:value];
}

#pragma mark Filling

- (void)fillToPercent:(double)percent
{
    double y = sliderCircleMinY - (sliderCircleMinY - sliderCircleMaxY)*percent;
    
    CGRect newFrame = CGRectMake(sliderCircle.frame.origin.x, y, sliderCircle.frame.size.width, sliderCircle.frame.size.height);
    
    [UIView animateWithDuration:0.1 animations:^(void){[sliderCircle setFrame:newFrame];}];

}


#pragma mark Outline

- (void)createOutline
{
    // Draw the outline:
    CGSize size = outline.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw black background:
    int bottomBarHeight = 55;
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor);
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height - bottomBarHeight));
    CGContextFillPath(context);
    
    // Draw right sidebar
    float sidebarWidth = 130;
    CGRect sidebarFrame = CGRectMake(outline.frame.size.width - sidebarWidth, -1, sidebarWidth+1, outline.frame.size.height - bottomBarHeight+2);
    
    UIView * sidebar = [[UIView alloc] initWithFrame:sidebarFrame];
    sidebar.backgroundColor = [UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0];
    sidebar.layer.borderColor = [UIColor whiteColor].CGColor;
    sidebar.layer.borderWidth = 1.0;
    
    [outline addSubview:sidebar];
    
    // Draw sidebar slider
    float sliderWidth = 45;
    float sliderHeight = 180;
    CGRect sliderFrame = CGRectMake((sidebar.frame.size.width-sliderWidth)/2, (sidebar.frame.size.height-sliderHeight)/2, sliderWidth, sliderHeight);
    
    UIView * slider = [[UIView alloc] initWithFrame:sliderFrame];
    slider.layer.borderColor = [UIColor whiteColor].CGColor;
    slider.layer.borderWidth = 3.0f;
    slider.layer.cornerRadius = sliderWidth/2;
    
    [sidebar addSubview:slider];
    
    // Draw sidebar slider circle
    float indent = 5;
    float circleWidth = sliderWidth-2*indent;
    sliderCircleMaxY = indent;
    sliderCircleMinY = slider.frame.size.height - circleWidth - indent;

    CGRect sliderCircleFrame = CGRectMake(indent, sliderCircleMinY, circleWidth, circleWidth);
    
    sliderCircle = [[UIView alloc] initWithFrame:sliderCircleFrame];
    sliderCircle.backgroundColor = [UIColor colorWithRed:166/255.0 green:204/255.0 blue:111/255.0 alpha:1.0];
    sliderCircle.layer.cornerRadius = sliderWidth/2-indent;
    
    [slider addSubview:sliderCircle];
    
    // Volume number to show in white
    /*CGRect newFrame = CGRectMake(outline.frame.size.width - 200, outline.frame.size.height - 100, 200, 50);
    volumeLabel = [[UILabel alloc] initWithFrame:newFrame];
    volumeLabel.font = [UIFont boldSystemFontOfSize:40];
    volumeLabel.textColor = [UIColor whiteColor];
    volumeLabel.backgroundColor = [UIColor clearColor];
    volumeLabel.textAlignment = NSTextAlignmentCenter;
    [outline addSubview:volumeLabel];*/
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    outline.image = image;
    
    UIGraphicsEndImageContext();
    
}



@end
