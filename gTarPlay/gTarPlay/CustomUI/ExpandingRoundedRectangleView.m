//
//  ExpandingRoundedRectangleView.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/19/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "ExpandingRoundedRectangleView.h"

#define ANIMATION_TIMER_INTERVAL (1.0/20.0)

@implementation ExpandingRoundedRectangleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	
	if ( self = [super initWithCoder:aDecoder] )
	{

	}
	
	return self;
	
}


- (id)initWithFrame:(CGRect)frame
{
    
	if ( self = [super initWithFrame:frame] )
	{

    }
	
    return self;
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc
{
	
	[m_animationTimer invalidate];
    m_animationTimer = nil;
    
}

- (void)resizeViewWithFrame:(CGRect)newFrame overTimeInterval:(CGFloat)timeInterval
{

	if ( timeInterval == 0 )
	{
		[self setFrame:newFrame];
		[self setNeedsDisplay];
	}
	else 
	{

		m_animationIterations = timeInterval / ANIMATION_TIMER_INTERVAL;

		m_animationStep.size.width = (newFrame.size.width - self.frame.size.width) / m_animationIterations;
		m_animationStep.size.height = (newFrame.size.height - self.frame.size.height) / m_animationIterations;
		
		m_animationStep.origin.x = (newFrame.origin.x - self.frame.origin.x) / m_animationIterations;
		m_animationStep.origin.y = (newFrame.origin.y - self.frame.origin.y) / m_animationIterations;
		
		m_currentFrame = self.frame;
		m_targetFrame = newFrame;
		
		
		[self startAnimation];
	}

}

#pragma mark -
#pragma mark Animation

- (void)startAnimation
{
	m_animationTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_TIMER_INTERVAL target:self selector:@selector(animate) userInfo:nil repeats:YES];
}

- (void)animate
{
	
	if ( m_animationIterations <= 0 )
	{
		
		[self endAnimation];

		[self setFrame:m_targetFrame];
		[self setNeedsDisplay];

	}
	else 
	{
		m_animationIterations--;
		
		m_currentFrame.size.width += m_animationStep.size.width;
		m_currentFrame.size.height += m_animationStep.size.height;
		
		m_currentFrame.origin.x += m_animationStep.origin.x;
		m_currentFrame.origin.y += m_animationStep.origin.y;
		
		[self setFrame:m_currentFrame];
		[self setNeedsDisplay];
		
	}
}

- (void)endAnimation
{
	
	[m_animationTimer invalidate];
	m_animationTimer = nil;
	
}



@end
