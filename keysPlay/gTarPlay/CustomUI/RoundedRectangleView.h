//
//  RoundedRectangleView.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/19/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// This class should fundamentally be updated to use the view.layer.cornerRadius
// property instead of drawing the rounding ourselves. Animation and gradients can
// also be simplified. It might be worth adding drop shadows too.

@interface RoundedRectangleView : UIView
{
	NSUInteger m_lineWidth;
	CGFloat m_cornerRadius;
    
    CGFloat m_fillColor[4];
    CGFloat m_gradColor[4];
    CGFloat m_strokeColor[4];
}

@property (nonatomic, assign) NSUInteger m_lineWidth;
@property (nonatomic, assign) CGFloat m_cornerRadius;
//@property (nonatomic, assign) CGFloat m_fillColor[4];
//@property (nonatomic, assign) CGFloat m_strokeColor[4];


- (void)sharedInit;
- (void)changeFillColor:(CGFloat*)fillColor;
- (void)changeGradColor:(CGFloat*)gradColor;
- (void)changeStrokeColor:(CGFloat*)strokeColor;

void CGContextAddRoundedRect( CGContextRef context, CGRect rect, int cornerRadius, int lineWidth );

@end
