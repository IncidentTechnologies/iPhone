//
//  SongPreviewScrubberView.m
//  gTarPlay
//
//  Created by Marty Greenia on 10/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongPreviewScrubberView.h"
#import "SongPreviewView.h"

#import <gTarAppCore/NSSongModel.h>

@implementation SongPreviewScrubberView

@synthesize m_delegate;

- (id)initWithFrame:(CGRect)frame andSongModel:(NSSongModel*)songModel
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        m_seekBarHeight = 25;
        
        m_dragging = NO;
        
        m_songModel = [songModel retain];
        
        self.clipsToBounds = YES;
        
        //make the subview
        CGRect fr = CGRectMake( 0, 0, frame.size.width, frame.size.height - m_seekBarHeight );
        
        m_songPreviewView = [[SongPreviewView alloc] initWithFrame:fr andSongModel:m_songModel];
        
        [self addSubview:m_songPreviewView];
        
        
        //
        // Setup the progress bars for the bottom
        //
        CGFloat blueColors[8] =
        { 
            0.3, 0.75, 1.0, 1.0,
            0.1, 0.25, 0.35, 1.0
        };
        
        CGFloat whiteColors[8] =
        { 
            0.7, 0.7, 0.7, 1.0,
            0.25, 0.25, 0.25, 1.0
        };

        UIImage * barImage;
        
        barImage = [UIImage imageNamed:@"PreviewPlayerScrubGREY.png"];
        if ( barImage == nil )
        {
            barImage = [self drawBarImage:whiteColors];
        }
        
        m_rightBarImageView = [[UIImageView alloc] initWithImage:barImage];
        [m_rightBarImageView setFrame:CGRectMake(0, frame.size.height - m_seekBarHeight, frame.size.width, m_seekBarHeight)];
        
        [self addSubview:m_rightBarImageView];
        
        // add the color bar on top of the other one
        barImage = [UIImage imageNamed:@"PreviewPlayerScrubBLUE.png"];
        if ( barImage == nil )
        {
            barImage = [self drawBarImage:blueColors];
        }
        
        m_leftBarImageView = [[UIImageView alloc] initWithImage:barImage];
        [m_leftBarImageView setFrame:CGRectMake(-frame.size.width, frame.size.height - m_seekBarHeight, frame.size.width, m_seekBarHeight)];
        
        [self addSubview:m_leftBarImageView];
        
        //
        // Create the knob
        //
        UIImage * knobImage = [UIImage imageNamed:@"ScrubKnob.png"];
        if ( knobImage == nil )
        {
            knobImage = [self drawKnobImage];
        }
        
        m_knobImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-m_seekBarHeight/4, frame.size.height - m_seekBarHeight, m_seekBarHeight/2, m_seekBarHeight)];
        
        [m_knobImageView setImage:knobImage];
        
        [self addSubview:m_knobImageView];

    }
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{

    [m_songPreviewView removeFromSuperview];
    [m_songPreviewView release];
    
    [m_knobImageView release];
    
    [m_songModel release];
    
    [super dealloc];
    
}

- (UIImage*)drawKnobImage
{

    CGFloat knobColors[12] =
    { 
        0.75, 0.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0
    };

    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents( baseSpace, knobColors, NULL, 2 );
    CGColorSpaceRelease( baseSpace );
    
    CGSize knobSize = CGSizeMake( m_seekBarHeight, m_seekBarHeight);
    
    UIGraphicsBeginImageContext(knobSize);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
    CGContextMoveToPoint(contextRef, 0, 0);
    
    // Draw the square itself and close the path
    CGContextBeginPath( contextRef );
    CGContextAddEllipseInRect( contextRef, CGRectMake( 0, 0, m_seekBarHeight, m_seekBarHeight ));
    CGContextClosePath( contextRef );
    
    // Draw the gradient inside the clipped context    
    CGPoint centerPoint = CGPointMake( m_seekBarHeight/2, m_seekBarHeight/2 );
    
    CGContextDrawRadialGradient( contextRef, gradient, centerPoint, 0, centerPoint, m_seekBarHeight/2, 0);
    CGGradientRelease( gradient );
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;

}

- (UIImage*)drawBarImage:(CGFloat*)colors
{
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents( baseSpace, colors, NULL, 2 );
    CGColorSpaceRelease( baseSpace );
    
    CGSize barSize = CGSizeMake( 1, m_seekBarHeight);
    
    UIGraphicsBeginImageContext(barSize);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
    CGContextMoveToPoint(contextRef, 0, 0);

    // Draw the square itself and close the path
    CGContextBeginPath( contextRef );
    CGContextAddRect( contextRef, CGRectMake( 0, 0, m_seekBarHeight, m_seekBarHeight ));
    CGContextClosePath( contextRef );
    
    // Draw the gradient inside the clipped context    
    CGPoint startPoint = CGPointMake( 0, 0 );
    CGPoint endPoint = CGPointMake( 0, barSize.height );
    
    CGContextDrawLinearGradient( contextRef, gradient, startPoint, endPoint, 0 );
    CGGradientRelease( gradient );
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)updateView
{
    
    CGFloat percentageComplete = m_songModel.m_percentageComplete;
    
    //
    // Move the knob over
    //
    CGFloat knobShift = percentageComplete * self.frame.size.width;
    
    m_knobImageView.transform = CGAffineTransformMakeTranslation( knobShift, 0 );
    
    //
    // Shift the fill on the progress bar
    //
    CGFloat progressShift = percentageComplete * self.frame.size.width;
    
    m_leftBarImageView.transform = CGAffineTransformMakeTranslation( progressShift, 0 );
    
    [m_songPreviewView updateView];
    
}

#pragma mark - Dragging callbacks

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
	CGPoint point = [touch locationInView:self];
	
    if ( CGRectContainsPoint( m_leftBarImageView.frame, point) == YES || 
         CGRectContainsPoint( m_rightBarImageView.frame, point) == YES )
    {
        
        m_dragging = YES;
        
        [m_delegate pauseSong];
        
        [self updateKnobWithPoint:point];
        
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if ( m_dragging == YES )
    {
        
        UITouch * touch = [[touches allObjects] objectAtIndex:0];
        
        CGPoint currentPoint = [touch locationInView:self];
        
        [self updateKnobWithPoint:currentPoint];
        
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	m_dragging = NO;
}

- (void)updateKnobWithPoint:(CGPoint)point
{
    
    CGFloat percentage = (point.x - m_seekBarHeight/2) / (self.frame.size.width - m_seekBarHeight);
    
    if ( percentage < 0.0 )
    {
        percentage = 0.0;
    }
    if ( percentage > 1.0 )
    {
        percentage = 1.0;
    }
    
    [m_songModel changePercentageComplete:percentage];

}

@end
