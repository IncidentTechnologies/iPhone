//
//  StarRatingView.m
//  gTarAppCore
//
//  Created by Marty Greenia on 7/15/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "StarRatingView.h"


@implementation StarRatingView

//@synthesize m_starRating;
//@synthesize m_fillColor;
//@synthesize m_strokeColor;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        
        m_originalBounds = frame;
        
    }
    
    return self;
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    if ( m_fillColor == nil )
    {
        m_fillColor = [[UIColor blackColor] CGColor];
    }

    if ( m_strokeColor == nil )
    {
        m_strokeColor = [[UIColor blackColor] CGColor];
    }
    
    if ( m_originalWidth == 0 )
    {
        m_originalWidth = self.frame.size.width;
    }
    
    // Draw some stars
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat height = self.frame.size.height;
    CGFloat width = m_originalWidth;

    CGFloat starSize = MIN( width / 5.0, height );
    
    // Change the color
    CGContextSetFillColorWithColor( context, m_fillColor );
    CGContextSetStrokeColorWithColor( context, m_strokeColor );
    
    // Set position of first star
    CGContextTranslateCTM( context, starSize/2, starSize/2 );

    for ( NSInteger i = 0; i < 5; i++ )
    {
        
        DrawStar( context, starSize );

        CGContextTranslateCTM( context, starSize, 0 );
    
    }
    
}

void DrawStar( CGContextRef context, CGFloat starSize )
{

    CGFloat pi = 3.14159265;
    
    CGFloat radius;
    CGFloat theta;
    
    radius = 0.8 * starSize / 2;
    theta = 2 * pi * (2.0 / 5.0); // 144 degrees
    
    
    CGContextMoveToPoint(context, 0, -radius);
    
    for ( NSInteger i = 1; i < 5; i++)
    {
        CGContextAddLineToPoint (context, -radius * sin(i * theta), -radius * cos(i * theta));
    }
    
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
}



- (void)updateStarRating:(CGFloat)rating
{
    
    if ( m_originalWidth == 0 )
    {
        m_originalWidth = self.frame.size.width;
    }

    m_starRating = rating;
    
    if ( m_starRating > 5.0 )
    {
        m_starRating = 5.0;
    }
    
    if ( m_starRating < 0.0 )
    {
        m_starRating = 0.0;
    }
    
    // resize the bounds
    CGRect newFrame = CGRectMake( self.frame.origin.x, 
                                  self.frame.origin.y,
                                  m_originalWidth * (m_starRating/5.0), 
                                  self.frame.size.height );

    self.frame = newFrame;
    
    [self setNeedsDisplay];
    
}

- (void)setStrokeColor:(CGColorRef)strokeColor andFillColor:(CGColorRef)fillColor
{
    
    // CGColors are not objc objects, so normal 'retain' doesn't work on them.
    CGColorRelease(m_fillColor);
    CGColorRelease(m_strokeColor);

    CGColorRetain(strokeColor);
    CGColorRetain(fillColor);
    
    m_fillColor = fillColor;
    m_strokeColor = strokeColor;
    
}

@end
