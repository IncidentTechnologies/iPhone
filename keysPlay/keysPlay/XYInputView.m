//
//  XYInputView.m
//  keys
//
//  Created by Marty Greenia on 1/31/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "XYInputView.h"


@implementation XYInputView

@synthesize m_delegate;
@synthesize m_slider;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc
{
    // release this delegate so ref counts match
	self.m_delegate = nil;
    
}

#pragma mark  -
#pragma mark Helpers

- (void)clearSliderFromPosition:(CGPoint)position
{
	// nothing
}

- (void)setCurrentPosition:(CGPoint)point
{
	
	// bound it by the size of the rectange
	NSInteger wBorder = m_slider.frame.size.width/2;
	NSInteger hBorder = m_slider.frame.size.height/2;

	NSInteger width = self.frame.size.width;
	NSInteger height = self.frame.size.height;
	
	// snap it to our border
	if ( point.x < wBorder )
	{
		point.x = wBorder;
	}
	if ( point.x > (width - wBorder) )
	{
		point.x = (width - wBorder);
	}
	
	if ( point.y < hBorder )
	{
		point.y = hBorder;
	}
	if ( point.y > (height - hBorder) )
	{
		point.y = (height - hBorder);
	}	
	
	[self clearSliderFromPosition:m_currentPosition];

	m_currentPosition = point;

	[self moveSliderToPosition:m_currentPosition];

}

// Set the current position, point must be normalized to [0,1]
- (void)setNormalizedPosition:(CGPoint)point
{
    // convert normalized point to point inside our border
    float x = point.x * self.frame.size.width;
    float y = point.y * self.frame.size.height;
    [self setCurrentPosition:CGPointMake(x, y)];
}

- (void)moveSliderToPosition:(CGPoint)position
{
	NSInteger wBorder = m_slider.frame.size.width/2;
	NSInteger hBorder = m_slider.frame.size.height/2;
	
	m_slider.frame = CGRectMake(m_currentPosition.x-wBorder, m_currentPosition.y-hBorder, 
								m_slider.frame.size.width, m_slider.frame.size.height);
}

#pragma mark  -
#pragma mark Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"Touches began JamPad");
    
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	CGPoint point = [touch locationInView:self];
	
	[self setCurrentPosition:point];
    [self sendNewPosition:m_currentPosition];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	CGPoint point = [touch locationInView:self];
	
	[self setCurrentPosition:point];
    [self sendNewPosition:m_currentPosition];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self sendNewPosition:m_currentPosition];
}

// sends the position to the m_delegate that implements the XYInputViewDelegate
- (void)sendNewPosition:(CGPoint)position
{
    if ( m_delegate != nil )
	{
        // Send normalized continuous position
        CGPoint p = CGPointMake(position.x/self.frame.size.width, position.y/self.frame.size.height);
		[m_delegate positionChanged:p forView:self];
	}
}

@end
