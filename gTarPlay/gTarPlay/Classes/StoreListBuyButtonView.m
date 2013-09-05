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
            
        case BUY_BUTTON_CONFIRM: {
            // draw a more different circle
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:(124.0f/255.0f) green:(178.0f/255.0f) blue:(102.0f/255.0f) alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(context, CGRectInset(rect, 3, 3));
            
            CGRect textRect = CGRectInset(rect, 4, 4);
            textRect.origin.x += 4;
            textRect.origin.y += 10;
            
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            NSString *text = @"BUY";
            [text drawInRect:textRect withFont:[UIFont systemFontOfSize:17.0f]];
        } break;
            
        case BUY_BUTTON_PROCESSING: {
            float xVal = 0.0f;
            float yVal = 0.0f;
            float xDelta = 0.025f;
            float xLastVal, yLastVal;
            
            // draw cool animation
            [[UIColor whiteColor] setStroke];
            UIBezierPath *aPath = [UIBezierPath bezierPath];
            aPath.lineWidth = 1.5f;
            
            [aPath moveToPoint:CGPointMake(0.0f, rect.size.height/2.0f)];
            for(xVal = 0.0f; (xVal / rect.size.width) < m_Complete; xVal += xDelta)
            {
                // Piece-wise envelope
                float multValue = 0.0f;
                float effX = (xVal / rect.size.width);
                float freq = 10.5f;
                multValue = sin(effX * M_PI);
                
                /*
                if(effX < .10) {
                    multValue = effX;
                    divFactor = 25.0f;
                }
                else if(effX >= .10 && effX < 0.25f) {
                    multValue = 0.10f + (effX - 0.10f) * 6;
                    divFactor = 50.f;
                }
                else if(effX >= 0.25f && effX < 0.75f) {
                    multValue = 1.0f - (effX - 0.25f) * 1.6;
                    divFactor = 35.f;
                }
                else if(effX >= 0.75f) {
                    multValue = 0.2f;
                    divFactor = 35.0f;
                }*/
                
                float eqVal = multValue * sin((xVal / rect.size.width) * M_PI * freq);
                
                yVal = rect.size.height/2.0f + (rect.size.height/2.0f) * eqVal;
                CGPoint newPoint = CGPointMake(xVal, yVal);
                CGPoint ctrlPoint = CGPointMake(xLastVal + (xVal - xLastVal) / 2.0f, yLastVal + (yVal - yLastVal) / 2.0f);
                
                [aPath addQuadCurveToPoint:newPoint controlPoint:ctrlPoint];
                
                xLastVal = xVal;
                yLastVal = yVal;
            }

            [aPath stroke];
            
            if(m_Complete < 1.0f)
                m_Complete += 0.01f;
            else
                m_Complete = 0.0f;
            
            [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(cbDrawRect:) userInfo:nil repeats:NO];
            
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
