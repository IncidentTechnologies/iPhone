//
//  XYInputView.m
//  gTar
//
//  Created by Marty Greenia on 1/31/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "XYInputView.h"


@implementation XYInputView

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
    [super dealloc];
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
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	CGPoint point = [touch locationInView:self];
	
	[self setCurrentPosition:point];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
	CGPoint point = [touch locationInView:self];
	
	[self setCurrentPosition:point];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}



@end
