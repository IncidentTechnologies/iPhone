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
    
    defaultBackgroundColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.6];
    highlightBackgroundColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.2];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:imageView];
    
    noteFrameWidth = self.frame.size.width / FRETS_ON_GTAR;
    
    CGRect playbandFrame = CGRectMake(10, 0, noteFrameWidth, self.frame.size.height);
    
    playbandView = [[UIView alloc] initWithFrame:playbandFrame];
    [playbandView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
    [playbandView setHidden:YES];
    
    [self addSubview:playbandView];
    
    [self initColors];
}

- (void)initColors
{
    /*CGFloat initColors[STRINGS_ON_GTAR][4] = {
        {170/255.0, 114/255.0, 233/255.0, 1},
        {30/255.0, 108/255.0, 213/255.0, 1},
        {5/255.0, 195/255.0, 77/255.0, 1},
        {204/255.0, 234/255.0, 0/255.0, 1},
        {234/255.0, 154/255.0, 0/255.0, 1},
        {238/255.0, 28/255.0, 36/255.0, 1}
    };*/
    
    CGFloat initColors[STRINGS_ON_GTAR][4] = {
        {148/255.0, 102/255.0, 177/255.0, 1},
        {0/255.0, 141/255.0, 218/255.0, 1},
        {43/255.0, 198/255.0, 34/255.0, 1},
        {204/255.0, 234/255.0, 0/255.0, 1},
        {234/255.0, 154/255.0, 41/255.0, 1},
        {239/255.0, 92/255.0, 53/255.0, 1}
    };
    
    memcpy(colors, initColors, sizeof(initColors));
}

- (void)setMeasure:(Measure *)newMeasure
{
    measure = newMeasure;
}

- (void)update
{
    if(TESTMODE) DLog(@"Measure View update");
    
    if (measure == nil)
        return;
    
    // Check if notes need to be redrawn:
    if ([measure shouldUpdateNotesOnMinimap]){
        [self createImage];
        //[self performSelectorInBackground:@selector(createImage) withObject:nil];
        [measure setUpdateNotesOnMinimap:NO];
    }
    
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
    
    if(TESTMODE)DLog(@"Move playband");
    
    if (measure.playband >= 0 && !isBlankMeasure) {
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
    self.backgroundColor = highlightBackgroundColor;
}

- (void)deselectMeasure {
    self.backgroundColor = defaultBackgroundColor;
}

- (void)drawMeasure:(BOOL)isBlank
{
    isBlankMeasure = isBlank;
    
    if (isBlank){
        [playbandView setHidden:YES];
    }
    
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int borderWidth = 0;
    CGRect wholeFrame = CGRectMake(borderWidth, borderWidth, self.frame.size.width-(2*borderWidth), self.frame.size.height-(2*borderWidth));
    CGContextAddRect(context, wholeFrame);
    
    // fill whole thing with background color:
    if (isBlank){
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1].CGColor);
    }else{
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    }
    
    CGContextFillPath(context);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    if(image != nil && imageView != nil){
        imageView.image = image;
    }
    
    UIGraphicsEndImageContext();
}

- (void)createImage {
    
    CGSize size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    double lineWidth = 0.2;
    
    CGFloat noteFrameHeight = self.frame.size.height / STRINGS_ON_GTAR;
    CGRect noteFrame = CGRectMake(0, 0, noteFrameWidth, noteFrameHeight);
    
    // Set line width:
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Update all the notes:
    int f, s;
    for (f = 0; f < FRETS_ON_GTAR; f++)
    {
        CGContextMoveToPoint(context, f*noteFrameWidth, 0);
        CGContextAddLineToPoint(context, f*noteFrameWidth, s*noteFrameHeight);
        CGContextStrokePath(context);
        
        for (s = 0; s < STRINGS_ON_GTAR; s++)
        {
            if(f == 0){
                CGContextMoveToPoint(context, 0, s*noteFrameHeight);
                CGContextAddLineToPoint(context, FRETS_ON_GTAR*noteFrameWidth, s*noteFrameHeight);
                CGContextStrokePath(context);
            }
            
            if ([measure isNoteOnAtString:[self invertString:s] andFret:f]){
                
                // Adjust frame:
                noteFrame.origin.x = f*noteFrameWidth;
                noteFrame.origin.y = s*noteFrameHeight;
                
                CGContextAddRect(context, noteFrame);
                
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:colors[s][0] green:colors[s][1] blue:colors[s][2] alpha:colors[s][3]].CGColor);  // Get color for that string and fill
                
                CGContextFillRect(context, noteFrame);
            }
        }
    }
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = newImage;
    UIGraphicsEndImageContext();
    
    [measure setUpdateNotesOnMinimap:NO];
    
}

- (int)invertString:(int)string
{
    return (STRINGS_ON_GTAR - 1 - string);
}


@end
