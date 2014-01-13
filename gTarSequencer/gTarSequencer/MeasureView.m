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
    [playbandView setBackgroundColor:[UIColor colorWithRed:247/255.0 green:148/255.0 blue:29/255.0 alpha:1]];
    [playbandView setHidden:YES];
    
    [self addSubview:playbandView];
    
    CGFloat initColors[STRINGS_ON_GTAR][4] = {
        {1, 0, 1, 1},
        {0, 1, 1, 1},
        {1, 1, 0, 1},
        {0, 0, 1, 1},
        {0, 1, 0, 1},
        {1, 0, 0, 1}
    };
    
    memcpy(colors, initColors, sizeof(initColors));
}

- (void)setMeasure:(Measure *)newMeasure
{
    measure = newMeasure;
}

- (void)update
{
    if ( measure == nil )
        return;
    
    // Check if notes need to be redrawn:
    if ( [measure shouldUpdateNotesOnMinimap] )
    {
        //[self createImage];
        [measure setUpdateNotesOnMinimap:NO];
    }
    
    // Update playband:
    if ( [measure shouldUpdatePlaybandOnMinimap] )
    {
        [self movePlayband];
        [measure setUpdatePlaybandOnMinimap:NO];
    }
}

#pragma mark Laying Out Subviews

- (void)setNeedsLayout {
    [self movePlayband];
}

- (void)movePlayband {
    if ( measure.playband >= 0 )
    {
        CGRect newFrame = playbandView.frame;
        newFrame.origin.x = measure.playband * noteFrameWidth;
        
        playbandView.frame = newFrame;
        if (playbandView.hidden)
        {
            [playbandView setHidden:NO];
        }
    }
    else {
        [playbandView setHidden:YES];
    }
}

#pragma mark Quartz Drawing

- (void)selectMeasure {
    //self.backgroundColor = [UIColor colorWithRed:247/255.0 green:148/255.0 blue:29/255.0 alpha:1];
    self.backgroundColor = [UIColor colorWithRed:100/255.0 green:20/255.0 blue:80/255.0 alpha:0.3];
}

- (void)deselectMeasure {
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawBorder
{
    [playbandView setHidden:YES];
    
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill whole thing with background color:
    CGRect wholeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextAddRect(context, wholeFrame);
    
    //CGContextSetFillColorWithColor(context, [UIColor colorWithRed:110/255.0 green:110/255.0 blue:114/255.0 alpha:1].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:110/255.0 green:110/255.0 blue:114/255.0 alpha:0.5].CGColor);

    CGContextFillPath(context);
    
    // stroke the border:
    int borderWidth = 2;
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = image;
    
    UIGraphicsEndImageContext();
}

- (void)createImage {
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double lineWidth = 0.5;
    
    CGFloat noteFrameHeight = self.frame.size.height / STRINGS_ON_GTAR;
    CGRect noteFrame = CGRectMake(0, 0, noteFrameWidth, noteFrameHeight);
    
    // Set line width:
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Update all the notes:
    for (int f = 0; f < FRETS_ON_GTAR; f++) {
        for (int s = 0; s < STRINGS_ON_GTAR; s++) {
            // Adjust frame:
            noteFrame.origin.x = f*noteFrameWidth;
            noteFrame.origin.y = s*noteFrameHeight;
            
            // Add rect:
            CGContextAddRect(context, noteFrame);
            CGContextStrokePath(context);
            
            if ( [measure isNoteOnAtString:[self invertString:s] andFret:f] )
                CGContextSetFillColor(context, colors[s]);  // Get color for that string and fill:
            else
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:175.0/255.0 blue:236.0/255.0 alpha:1].CGColor); // Fill with normal background color:
            
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


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
