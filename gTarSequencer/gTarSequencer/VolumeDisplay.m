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
    [volumeLabel setText:value];
}

#pragma mark Filling

- (void)fillToPercent:(double)percent
{
    //NSLog(@"Fill to %f percent",percent);
}


#pragma mark Outline

- (void)createOutline
{
    // Draw the outline:
    CGSize size = outline.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // -- draw black background:
    int bottomBarHeight = 55;
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor);
    CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height - bottomBarHeight));
    CGContextFillPath(context);
    
    // Volume number to show in white
    CGRect newFrame = CGRectMake(outline.frame.size.width - 200, outline.frame.size.height - 100, 200, 50);
    volumeLabel = [[UILabel alloc] initWithFrame:newFrame];
    volumeLabel.font = [UIFont boldSystemFontOfSize:40];
    volumeLabel.textColor = [UIColor whiteColor];
    volumeLabel.backgroundColor = [UIColor clearColor];
    volumeLabel.textAlignment = NSTextAlignmentCenter;
    [outline addSubview:volumeLabel];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    outline.image = image;
    
    UIGraphicsEndImageContext();
    
}



@end
