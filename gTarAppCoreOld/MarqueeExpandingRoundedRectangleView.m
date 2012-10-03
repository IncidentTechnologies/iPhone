//
//  MarqueeExpandingRoundedRectangleView.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/20/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "MarqueeExpandingRoundedRectangleView.h"


@implementation MarqueeExpandingRoundedRectangleView

@synthesize m_marqueeHeight;
@synthesize m_topHeight;
@synthesize m_expandFromBottom;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	
    self = [super initWithCoder:aDecoder];
    
	if ( self )
	{
		m_marqueeHeight = 30;
        m_expandFromBottom = NO;
	}
	
	return self;
	
}


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
	if ( self )
	{
		m_marqueeHeight = 30;
        m_expandFromBottom = NO;
    }
	
    return self;
	
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

	[super drawRect:rect];
    
    if ( m_expandFromBottom == YES )
    {
        m_marqueeHeight = self.frame.size.height - m_topHeight;
    }
    
	if ( m_marqueeHeight > 0 )
	{
		
		CGRect marqueeRect = rect;
		
		marqueeRect.size.height = m_marqueeHeight;
		marqueeRect.origin.y = (rect.origin.y + rect.size.height - m_marqueeHeight);
		
		// Draw the little marque bit on the bottom
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSetRGBFillColor( context, 1.0f, 1.0f, 1.0f, 1.0f );  
		CGContextAddHalfRoundedRect( context, marqueeRect, m_cornerRadius, m_lineWidth );
		CGContextFillPath( context );  

	}
	
}

- (void)resizeMarqueeWithHeight:(CGFloat)marqueeHeight overTimeInterval:(CGFloat)timeInterval
{
    // i don't think I actually use this anymore
	if ( timeInterval == 0 )
	{
		m_marqueeHeight = marqueeHeight;
		[self setNeedsDisplay];
	}
	else 
	{
		
	}
	
}

- (void)dealloc
{
    [super dealloc];
}

//- (void)animate
//{
//    
//    if ( m_expandFromBottom == YES )
//    {
//        m_marqueeHeight += m_animationStep.size.height;
//    }
//    
//    [super animate];
//    
//}

void CGContextAddHalfRoundedRect( CGContextRef context, CGRect rect, int cornerRadius, int lineWidth )
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
	
    // Start the path in the upper left corner
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, xLeft, yTop );
	
    // First corner, upper left, then go to the right
    //CGContextAddArcToPoint( context, xLeft, yTop, xLeftCenter, yTop, cornerRadius );
//    CGContextAddLineToPoint( context, xRightCenter, yTop );  
	CGContextAddLineToPoint( context, xRight, yTop );  

	
	// Second corner, upper right, then go down
    //CGContextAddArcToPoint( context, xRight, yTop, xRight, yTopCenter, cornerRadius );
    CGContextAddLineToPoint( context, xRight, yBottomCenter );
	
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
