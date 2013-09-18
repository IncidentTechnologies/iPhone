//
//  UITriangleView.m
//  gTarPlay
//
//  Created by Idan Beck on 9/12/13.
//
//

#import "UITriangleView.h"
#import <QuartzCore/QuartzCore.h>

@interface UITriangleView () {
    UIColor *m_bgColor;
}
@end

@implementation UITriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        m_bgColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    }
    return self;
}

-(void)setColor:(UIColor*)color
{
    m_bgColor = [color copy];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    CGRect insetRect = CGRectInset(rect, 2, 2);
    
    // Draw triangle
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect));  
    CGContextAddLineToPoint(context, CGRectGetMidX(insetRect), CGRectGetMaxY(insetRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(insetRect), CGRectGetMinY(insetRect));
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, m_bgColor.CGColor);
    CGContextFillPath(context);
}

@end
