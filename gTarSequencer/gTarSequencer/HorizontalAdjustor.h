//
//  HorizontalAdjustor.h
//  Sequence
//
//  Created by Kate Schnippering on 9/17/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "AppData.h"

@protocol HorizontalAdjustorDelegate <NSObject>

- (void)panRight:(float)diff;
- (void)panLeft:(float)diff;
- (void)endPanRight;
- (void)endPanLeft;

@end

@interface HorizontalAdjustor : NSObject
{
    UIView * m_container;
    UIView * m_background;
    UIView * m_bar;
    
    float leftFirstX;
    float rightFirstX;
    
    float barMinWidth;
    float barDefaultWidth;
    
    float adjustorSize;
    
    UIGestureRecognizer * leftPan;
    UIGestureRecognizer * rightPan;
}

- (id)initWithContainer:(UIView *)container background:(UIView *)background bar:(UIView *)bar;

- (void)hideControls;
- (void)showControlsRelativeToView:(UIView *)view;
- (void)setBarDefaultWidth:(float)width minWidth:(float)minWidth;

@property (nonatomic) UIButton * leftAdjustor;
@property (nonatomic) UIButton * rightAdjustor;

@property (weak, nonatomic) id<HorizontalAdjustorDelegate> delegate;



@end
