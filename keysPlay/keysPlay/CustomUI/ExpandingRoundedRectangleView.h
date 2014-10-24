//
//  ExpandingRoundedRectangleView.h
//  keysPlay
//
//  Created by Marty Greenia on 4/19/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "RoundedRectangleView.h"

@interface ExpandingRoundedRectangleView : RoundedRectangleView
{
	
	NSTimer * m_animationTimer;
	NSInteger m_animationIterations;

	CGRect m_animationStep;
	CGRect m_currentFrame;
	CGRect m_targetFrame;
		
}

- (void)resizeViewWithFrame:(CGRect)newFrame overTimeInterval:(CGFloat)timeInterval;

- (void)startAnimation;
- (void)animate;
- (void)endAnimation;

@end
