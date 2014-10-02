//
//  HorizontalAdjustor.m
//  Sequence
//
//  Created by Kate Schnippering on 9/17/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "HorizontalAdjustor.h"

#define FADE_OUT_ALPHA 0.3
#define ADJUSTOR_MAX_SIZE 50.0

@implementation HorizontalAdjustor

@synthesize leftAdjustor;
@synthesize rightAdjustor;
@synthesize delegate;

- (id)initWithContainer:(UIView *)container background:(UIView *)background bar:(UIView *)bar
{
    self = [super init];
    if (self) {
        
        m_container = container;
        m_background = background;
        m_bar = bar;
        
        if(m_bar.frame.size.height > 0){
            adjustorSize = MIN(m_bar.frame.size.height,ADJUSTOR_MAX_SIZE);
        }else{
            adjustorSize = ADJUSTOR_MAX_SIZE;
        }
        
        [self initAdjustors];
        
    }
    return self;
}

- (void)initAdjustors
{
    leftAdjustor = [[UIButton alloc] initWithFrame:CGRectMake(-1*adjustorSize/2,m_container.frame.size.height/2-adjustorSize/2,adjustorSize-1,adjustorSize)];
    
    rightAdjustor = [[UIButton alloc] initWithFrame:CGRectMake(50,m_container.frame.size.height/2-adjustorSize/2,adjustorSize-1,adjustorSize)];
    
    leftAdjustor.backgroundColor = [UIColor whiteColor];
    rightAdjustor.backgroundColor = [UIColor whiteColor];
    
    leftAdjustor.layer.cornerRadius = leftAdjustor.frame.size.width/2.0;
    rightAdjustor.layer.cornerRadius = rightAdjustor.frame.size.width/2.0;
    
    [leftAdjustor setAlpha:FADE_OUT_ALPHA];
    [rightAdjustor setAlpha:FADE_OUT_ALPHA];
    
    [m_container addSubview:leftAdjustor];
    [m_container addSubview:rightAdjustor];
    
    [self initGestures];
}

- (void)initGestures
{
    // Add gesture recognizers
    leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeft:)];
    rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRight:)];
    
    [leftAdjustor addGestureRecognizer:leftPan];
    [rightAdjustor addGestureRecognizer:rightPan];
}

- (void)setBarDefaultWidth:(float)width minWidth:(float)minWidth
{
    barDefaultWidth = width;
    barMinWidth = minWidth;
}

- (void)showControlsRelativeToView:(UIView *)view
{
    // progressBar
    
    CGRect newLeftFrame = CGRectMake(view.frame.origin.x-adjustorSize/2,view.frame.origin.y+view.frame.size.height/2-adjustorSize/2,adjustorSize,adjustorSize);
    
    CGRect newRightFrame = CGRectMake(view.frame.origin.x+view.frame.size.width-adjustorSize/2,view.frame.origin.y+view.frame.size.height/2-adjustorSize/2,adjustorSize,adjustorSize);
    
    [leftAdjustor setFrame:newLeftFrame];
    [rightAdjustor setFrame:newRightFrame];
    
    [leftAdjustor setHidden:NO];
    [rightAdjustor setHidden:NO];
    
    [leftAdjustor addGestureRecognizer:leftPan];
    [rightAdjustor addGestureRecognizer:rightPan];
}

- (void)hideControls
{
    [leftAdjustor setHidden:YES];
    [rightAdjustor setHidden:YES];
    
    [leftAdjustor removeGestureRecognizer:leftPan];
    [rightAdjustor removeGestureRecognizer:rightPan];
}

- (void)panLeft:(UIPanGestureRecognizer *)sender
{
    
    CGPoint newPoint = [sender translationInView:m_background];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        leftFirstX = leftAdjustor.frame.origin.x;
        [leftAdjustor setAlpha:0.8];
    }
    
    float minX = 0 - adjustorSize/2;
    float maxX = rightAdjustor.frame.origin.x - 0.5*barMinWidth;
    float newX = newPoint.x + leftFirstX;
    
    // wrap to boundary
    if(newX < minX || newX < minX+0.2*adjustorSize/2){
        newX=minX;
    }
    
    if(newX >= minX && newX <= maxX){
        CGRect newLeftFrame = CGRectMake(newX,m_bar.frame.origin.y+m_bar.frame.size.height/2-adjustorSize/2,adjustorSize,adjustorSize);
        
        [leftAdjustor setFrame:newLeftFrame];
        
        CGRect newProgressBarFrame = CGRectMake(newX+adjustorSize/2, m_bar.frame.origin.y, rightAdjustor.frame.origin.x-leftAdjustor.frame.origin.x, m_bar.frame.size.height);
        
        [m_bar setFrame:newProgressBarFrame];
        
        [delegate panLeft:newX-leftFirstX];
        
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        [leftAdjustor setAlpha:FADE_OUT_ALPHA];
        
        [delegate endPanLeft];
    }
    
}

- (void)panRight:(UIPanGestureRecognizer *)sender
{
    CGPoint newPoint = [sender translationInView:m_background];
    
    if([sender state] == UIGestureRecognizerStateBegan){
        rightFirstX = rightAdjustor.frame.origin.x;
        [rightAdjustor setAlpha:0.8];
    }
    
    float minX = leftAdjustor.frame.origin.x + 0.5*barMinWidth;
    float maxX = barDefaultWidth - adjustorSize/2;
    float newX = newPoint.x + rightFirstX;
    
    // Ensure if the bar gets stopped the slider stops too
    /*if(newX - adjustorSize/2 > m_bar.frame.size.width && newX >= rightAdjustor.frame.origin.x){
        maxX = m_bar.frame.size.width - adjustorSize/2;
    }*/
    
    // wrap to boundary
    if(newX > maxX || newX > maxX-0.2*adjustorSize/2){
        newX=maxX;
    }
    
    if(newX >= minX && newX <= maxX){
        CGRect newRightFrame = CGRectMake(newX,m_bar.frame.origin.y+m_bar.frame.size.height/2-adjustorSize/2,adjustorSize,adjustorSize);
        
        [rightAdjustor setFrame:newRightFrame];
        
        CGRect newProgressBarFrame = CGRectMake(m_bar.frame.origin.x, m_bar.frame.origin.y, rightAdjustor.frame.origin.x-leftAdjustor.frame.origin.x, m_bar.frame.size.height);
        
        [m_bar setFrame:newProgressBarFrame];
        
        [delegate panRight:newX-rightFirstX];
        
    }
    
    if([sender state] == UIGestureRecognizerStateEnded){
        
        [rightAdjustor setAlpha:FADE_OUT_ALPHA];
        
        [delegate endPanRight];
        
    }
    
}

@end
