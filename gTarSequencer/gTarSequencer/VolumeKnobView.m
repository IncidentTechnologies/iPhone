//
//  VolumeKnobView.m
//  Sequence
//
//  Created by Kate Schnippering on 3/19/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "VolumeKnobView.h"

@implementation VolumeKnobView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * hitView = [super hitTest:point withEvent:event];
    
    if(hitView == self){
        [delegate knobRegionHit];
    }
    
    return hitView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
