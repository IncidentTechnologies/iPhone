//
//  MeasureView.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/3/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "MeasureView.h"

@implementation MeasureView

@synthesize measure;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    measure = nil;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:imageView];
    
    noteFrameWidth = self.frame.size.width / FRETS_ON_GTAR;
    
    CGRect playbandFrame = CGRectMake(10, 0, noteFrameWidth, self.frame.size.height);
    
    playbandView = [[UIView alloc] initWithFrame:playbandFrame];
    [playbandView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [playbandView setHidden:YES];
    
    [self addSubview:playbandView];
    
    [self initColors];
}

- (void)initColors
{
    CGFloat initColors[STRINGS_ON_GTAR][4] = {
        {150/255.0, 12/255.0, 238/255.0, 1},
        {9/255.0, 109/255.0, 245/255.0, 1},
        {19/255.0, 133/255.0, 4/255.0, 1},
        {245/255.0, 214/255.0, 9/255.0, 1},
        {238/255.0, 129/255.0, 13/255.0, 1},
        {216/255.0, 64/255.0, 64/255.0, 1}
    };
    
    memcpy(colors, initColors, sizeof(initColors));
}

- (void)setMeasure:(Measure *)newMeasure
{
    measure = newMeasure;
}

- (void)update
{
    if (measure == nil)
        return;
    
    // Check if notes need to be redrawn:
    // TODO: maybe add this back?
    //if ([measure shouldUpdateNotesOnMinimap]){
        [self createImage];
        [measure setUpdateNotesOnMinimap:NO];
    //}
    
    // Update playband:
    if ([measure shouldUpdatePlaybandOnMinimap]){
        [self movePlayband];
        [measure setUpdatePlaybandOnMinimap:NO];
    }
}

#pragma mark Laying Out Subviews

- (void)setNeedsLayout {
    [self movePlayband];
}

- (void)movePlayband {
    if (measure.playband >= 0) {
        CGRect newFrame = playbandView.frame;
        newFrame.origin.x = measure.playband * noteFrameWidth;
        
        playbandView.frame = newFrame;
        if (playbandView.hidden){
            [playbandView setHidden:NO];
        }
    } else {
        [playbandView setHidden:YES];
    }
}

#pragma mark Quartz Drawing

- (void)selectMeasure {
    
    self.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];

}

- (void)deselectMeasure {
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawMeasure:(BOOL)withColor
{
    if (withColor) [playbandView setHidden:YES];
    
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill whole thing with background color:
    int borderWidth = 2;
    CGRect wholeFrame = CGRectMake(borderWidth, borderWidth, self.frame.size.width-(2*borderWidth), self.frame.size.height-(2*borderWidth));
    CGContextAddRect(context, wholeFrame);
    
    if (withColor)
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1].CGColor);
    else
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);

    
    CGContextFillPath(context);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = image;
    
    UIGraphicsEndImageContext();
}

- (void)createImage {
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double lineWidth = 0.1;
    
    CGFloat noteFrameHeight = self.frame.size.height / STRINGS_ON_GTAR;
    CGRect noteFrame = CGRectMake(0, 0, noteFrameWidth, noteFrameHeight);
    
    // Set line width:
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Update all the notes:
    for (int f = 0; f < FRETS_ON_GTAR; f++)
    {
        for (int s = 0; s < STRINGS_ON_GTAR; s++)
        {
            // Adjust frame:
            noteFrame.origin.x = f*noteFrameWidth;
            noteFrame.origin.y = s*noteFrameHeight;
            
            // Add rect:
            CGContextAddRect(context, noteFrame);
            CGContextStrokePath(context);
            
            if ([measure isNoteOnAtString:[self invertString:s] andFret:f]){
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:colors[s][0] green:colors[s][1] blue:colors[s][2] alpha:colors[s][3]].CGColor);  // Get color for that string and fill:
            }else{
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            }
            
            CGContextFillRect(context, noteFrame);
        }
    }
    [measure setUpdateNotesOnMinimap:NO];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    imageView.image = newImage;
    
    UIGraphicsEndImageContext();
}

- (int)invertString:(int)string
{
    return (STRINGS_ON_GTAR - 1 - string);
}


@end
