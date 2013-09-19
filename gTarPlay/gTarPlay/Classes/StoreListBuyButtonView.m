//
//  StoreListBuyButtonView.m
//  gTarPlay
//
//  Created by Idan Beck on 8/31/13.
//


#import "StoreListBuyButtonView.h"
#import <QuartzCore/QuartzCore.h>

static inline double radians (double degrees) {
    return degrees * M_PI/180;
}

@interface StoreListBuyButtonView () {
    BUY_BUTTON_STATE m_state;
    float m_Complete;
    NSString *m_strText;
}
@end

@implementation StoreListBuyButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // init code
        m_Complete = 0.0f;
        m_strText = [[NSString alloc] initWithString:@"99¢"];
    }
    return self;
}

-(void)updateBuyButtonState:(BUY_BUTTON_STATE)state {
    m_state = state;
    //[self drawRect:self.layer.frame];
    [self setNeedsDisplay];
    return;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    
    // Drawing code
    switch (m_state) {
        case BUY_BUTTON_PRICE: {
            // draw circle
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(100.0f/255.0f) green:(108.0f/255.0f) blue:(113.0f/255.0f) alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, CGRectInset(rect, 4, 4));
            
            CGRect textRect = CGRectInset(rect, 4, 4);
            textRect.origin.x += 6;
            textRect.origin.y += 9;
            
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            NSString *text = @"99¢";
            [text drawInRect:textRect withFont:[UIFont systemFontOfSize:19.0f]];
            
        } break;
            
        case BUY_BUTTON_FREE: {
            // draw circle
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(4.0f/255.0f) green:(161.0f/255.0f) blue:(222.0f/255.0f) alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, CGRectInset(rect, 4, 4));
            
            CGRect textRect = CGRectInset(rect, 4, 4);
            textRect.origin.x += 4.0f;
            textRect.origin.y += 13.0f;
            
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            NSString *text = @"FREE";
            [text drawInRect:textRect withFont:[UIFont systemFontOfSize:13.0f]];
            
        } break;
            
        case BUY_BUTTON_CONFIRM: {
            // draw a more different circle
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(124.0f/255.0f) green:(178.0f/255.0f) blue:(102.0f/255.0f) alpha:1.0f].CGColor);

            CGContextFillEllipseInRect(context, CGRectInset(rect, 3, 3));
            
            CGRect textRect = CGRectInset(rect, 4, 4);
            textRect.origin.x += 6;
            textRect.origin.y += 12;
            
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            NSString *text = @"BUY";
            [text drawInRect:textRect withFont:[UIFont systemFontOfSize:15.0f]];
        } break;
            
        case BUY_BUTTON_PROCESSING: {            
            float outerAlpha = (m_Complete > 0.25f && m_Complete < 0.5f) ? (m_Complete - 0.25f) / 0.25f : (m_Complete > 0.5f && m_Complete < 0.75f) ? (0.75f - m_Complete) / 0.25f : 0.0f;
            float innerAlpha = (m_Complete < 0.25f) ? m_Complete / 0.25f : (m_Complete > 0.75f) ? (1.0f - m_Complete) / 0.25f : 1.0f;

            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(84.0f/255.0f) green:(159.0f/255.0f) blue:(215.0f/255.0f) alpha:outerAlpha].CGColor);
            CGContextAddEllipseInRect(context, CGRectInset(rect, 3, 3));
            CGContextAddEllipseInRect(context, CGRectInset(rect, 8, 8));
            CGContextEOFillPath(context);
            
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(84.0f/255.0f) green:(159.0f/255.0f) blue:(215.0f/255.0f) alpha:innerAlpha].CGColor);
            CGContextAddEllipseInRect(context, CGRectInset(rect, 14, 14));
            CGContextAddEllipseInRect(context, CGRectInset(rect, 16.5, 16.5));
            CGContextEOFillPath(context);
            
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(cbDrawRect:) userInfo:nil repeats:NO];
            
            if(m_Complete < 1.0f)
                m_Complete += 0.01f;
            else
                m_Complete = 0.0f;
        } break;
            
        case BUY_BUTTON_PURCHASED: {
            // draw circle
            CGRect insetRect = CGRectInset(rect, 16, 15);
            insetRect.origin.x += 2;
            insetRect.origin.y += 0;
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(100.0f/255.0f) green:(108.0f/255.0f) blue:(113.0f/255.0f) alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, CGRectInset(rect, 4, 4));
    
            // Draw triangle
            CGContextBeginPath(context);
            CGContextMoveToPoint   (context, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect));  // top left
            CGContextAddLineToPoint(context, CGRectGetMaxX(insetRect), CGRectGetMidY(insetRect));  // mid right
            CGContextAddLineToPoint(context, CGRectGetMinX(insetRect), CGRectGetMaxY(insetRect));  // bottom left
            CGContextClosePath(context);
            
            CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
            CGContextFillPath(context);
        } break;
    }
}

- (void) cbDrawRect:(NSTimer *) timer {
    [self setNeedsDisplay];
}


@end
