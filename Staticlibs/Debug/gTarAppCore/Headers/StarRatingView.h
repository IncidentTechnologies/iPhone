//
//  StarRatingView.h
//  gTarAppCore
//
//  Created by Marty Greenia on 7/15/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StarRatingView : UIView
{
    // out of 5.0
    CGFloat m_starRating;
    CGRect m_originalBounds;
    CGFloat m_originalWidth;
    
    CGColorRef m_fillColor;
    CGColorRef m_strokeColor;
    
}

//@property (nonatomic, assign) CGFloat m_starRating;

//@property (nonatomic, retain) CGColor * m_fillColor;
//@property (nonatomic, retain) CGColor * m_strokeColor;

- (void)updateStarRating:(CGFloat)rating;
- (void)setStrokeColor:(CGColorRef)strokeColor andFillColor:(CGColorRef)fillColor;

void DrawStar( CGContextRef context, CGFloat starSize );

@end
