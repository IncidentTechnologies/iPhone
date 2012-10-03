//
//  MarqueeExpandingRoundedRectangleView.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/20/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "ExpandingRoundedRectangleView.h"


@interface MarqueeExpandingRoundedRectangleView : ExpandingRoundedRectangleView
{
	CGFloat m_marqueeHeight;
    CGFloat m_topHeight;
    BOOL m_expandFromBottom;
}

@property (nonatomic, assign) CGFloat m_marqueeHeight;
@property (nonatomic, assign) CGFloat m_topHeight;
@property (nonatomic, assign) BOOL m_expandFromBottom;

void CGContextAddHalfRoundedRect( CGContextRef context, CGRect rect, int cornerRadius, int lineWidth );

@end
