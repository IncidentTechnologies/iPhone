//
//  RoundedRectangleView.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/19/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "RoundedRectangleView.h"


@implementation RoundedRectangleView

@synthesize m_lineWidth;
@synthesize m_cornerRadius;

- (id)initWithCoder:(NSCoder *)aDecoder
{

    self = [super initWithCoder:aDecoder];
    
	if ( self )
	{
        [self sharedInit];

	}
	
	return self;
	
}


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
	if ( self )
	{
        [self sharedInit];
    }
	
    return self;
	
}

- (void)sharedInit
{
    self.layer.cornerRadius = 5;
    m_lineWidth = 3;
    m_cornerRadius = 5;

    // defaults (blue with white border)
    m_fillColor[0] = 0.2f;
    m_fillColor[1] = 0.5f;
    m_fillColor[2] = 0.7f;
    m_fillColor[3] = 1.0f;

    // also a darker gradient color
    m_gradColor[0] = 0.1f;
    m_gradColor[1] = 0.25f;
    m_gradColor[2] = 0.35f;
    m_gradColor[3] = 1.0f;

    // gtar (peacock) blue 4/66/115
    // consider trying the lighter, 7/124/216 version
//    m_fillColor[0] = 7.0/256.0;
//    m_fillColor[1] = 124.0/256.0;
//    m_fillColor[2] = 216.0/256.0;
//    m_fillColor[3] = 1.0f;

    m_strokeColor[0] = 1.0f;
    m_strokeColor[1] = 1.0f;
    m_strokeColor[2] = 1.0f;
    m_strokeColor[3] = 1.0f;
    
    self.backgroundColor = [UIColor clearColor];

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    // Drawing code.
    
    // Create a gradient
    CGFloat colors[8] =
    { 
        m_fillColor[0], m_fillColor[1], m_fillColor[2], m_fillColor[3],
        m_gradColor[0], m_gradColor[1], m_gradColor[2], m_gradColor[3]
    };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents( baseSpace, colors, NULL, 2 );
    CGColorSpaceRelease( baseSpace );
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Push into a sub context
    CGContextSaveGState( context );

    // Draw the square itself and clip the context
	CGContextAddRoundedRect( context, rect, m_cornerRadius, m_lineWidth );
    CGContextClip( context );
    

    // Draw the gradient inside the clipped context
    CGPoint startPoint = CGPointMake( CGRectGetMidX( rect ), CGRectGetMinY( rect ) );
    CGPoint endPoint = CGPointMake( CGRectGetMidX( rect ), CGRectGetMaxY( rect ) );
    
    CGContextDrawLinearGradient( context, gradient, startPoint, endPoint, 0 );
    CGGradientRelease( gradient ), gradient = NULL;

    // Pop the context
    CGContextRestoreGState( context );

    // Draw the outline around the square
	CGContextSetLineWidth( context, m_lineWidth );
	CGContextSetRGBStrokeColor( context, m_strokeColor[0], m_strokeColor[1], m_strokeColor[2], m_strokeColor[3] );
	CGContextAddRoundedRect( context, rect, m_cornerRadius, m_lineWidth );
	CGContextStrokePath( context );

    // Old no gradient drawing code
//	
//    
//	// Draw the square itself
//	CGContextSetRGBFillColor( context, m_fillColor[0], m_fillColor[1], m_fillColor[2], m_fillColor[3] );  
//	CGContextAddRoundedRect( context, rect, m_cornerRadius, m_lineWidth );
//	CGContextFillPath( context );  
//	
//	// Draw the outline around the square
//	CGContextSetLineWidth( context, m_lineWidth );
//	CGContextSetRGBStrokeColor( context, m_strokeColor[0], m_strokeColor[1], m_strokeColor[2], m_strokeColor[3] );
//	CGContextAddRoundedRect( context, rect, m_cornerRadius, m_lineWidth );
//	CGContextStrokePath( context );

}


- (void)changeFillColor:(CGFloat*)fillColor
{
    m_fillColor[0] = fillColor[0];
    m_fillColor[1] = fillColor[1];
    m_fillColor[2] = fillColor[2];
    m_fillColor[3] = fillColor[3];
}

- (void)changeGradColor:(CGFloat*)gradColor
{
    m_gradColor[0] = gradColor[0];
    m_gradColor[1] = gradColor[1];
    m_gradColor[2] = gradColor[2];
    m_gradColor[3] = gradColor[3];
}

- (void)changeStrokeColor:(CGFloat *)strokeColor
{
    m_strokeColor[0] = strokeColor[0];
    m_strokeColor[1] = strokeColor[1];
    m_strokeColor[2] = strokeColor[2];
    m_strokeColor[3] = strokeColor[3];
}
 
void CGContextAddRoundedRect( CGContextRef context, CGRect rect, int cornerRadius, int lineWidth )
{  
#if 1
	// Give ourselves a little bit of space for the line thickness
	int lineBuffer = (lineWidth + 1) / 2;
	int xLeft = rect.origin.x + lineBuffer;
    int xLeftCenter = rect.origin.x + cornerRadius + lineBuffer;
    int xRightCenter = rect.origin.x + rect.size.width - cornerRadius - lineBuffer;
	int xRight = rect.origin.x + rect.size.width - lineBuffer;
	int yTop = rect.origin.y + lineBuffer;
    int yTopCenter = rect.origin.y + cornerRadius + lineBuffer;
    int yBottomCenter = rect.origin.y + rect.size.height - cornerRadius - lineBuffer;
	int yBottom = rect.origin.y + rect.size.height - lineBuffer;
#endif
	
#if 0
	 int xLeft = rect.origin.x + cornerRadius;
	 int xLeftCenter = rect.origin.x + cornerRadius * 2;
	 int xRightCenter = rect.origin.x + rect.size.width - cornerRadius * 2;
	 int xRight = rect.origin.x + rect.size.width - cornerRadius;
	 int yTop = rect.origin.y + cornerRadius;
	 int yTopCenter = rect.origin.y + cornerRadius * 2;
	 int yBottomCenter = rect.origin.y + rect.size.height - cornerRadius * 2;
	 int yBottom = rect.origin.y + rect.size.height - cornerRadius;
#endif
	
#if 0
	int xLeft = rect.origin.x;
    int xLeftCenter = rect.origin.x + cornerRadius;
    int xRightCenter = rect.origin.x + rect.size.width - cornerRadius;
	int xRight = rect.origin.x + rect.size.width;
	int yTop = rect.origin.y;
    int yTopCenter = rect.origin.y + cornerRadius;
    int yBottomCenter = rect.origin.y + rect.size.height - cornerRadius;
	int yBottom = rect.origin.y + rect.size.height;
#endif
	
    // Start the path in the upper left corner
    CGContextBeginPath(context );
    CGContextMoveToPoint(context, xLeft, yTopCenter);  
	
    // First corner, upper left, then go to the right
    CGContextAddArcToPoint( context, xLeft, yTop, xLeftCenter, yTop, cornerRadius );
    CGContextAddLineToPoint( context, xRightCenter, yTop );  
	
	// Second corner, upper right, then go down
    CGContextAddArcToPoint( context, xRight, yTop, xRight, yTopCenter, cornerRadius );
    CGContextAddLineToPoint( context, xRight, yBottomCenter);
	
    // Third corner, lower right, then go left
    CGContextAddArcToPoint( context, xRight, yBottom, xRightCenter, yBottom, cornerRadius );
    CGContextAddLineToPoint( context, xLeftCenter, yBottom );  
	
	// Fourth corner, lower left, then go up
    CGContextAddArcToPoint( context, xLeft, yBottom, xLeft, yBottomCenter, cornerRadius );
    CGContextAddLineToPoint( context, xLeft, yTopCenter );
	
	// End
    CGContextClosePath( context );
	
}  


@end
