//
//  TouchCatcher.m
//  gTarSequencer
//
//  Created by Ilan Gray on 7/30/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "TouchCatcher.h"

@implementation TouchCatcher

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        areaToIgnore = CGRectMake(0, 0, 0, 0);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark Hit Detection

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if ( ![self isTouchInAreaToIgnore:point] )
    {
        [delegate touchWasCaught:point];
    }
    
    return NO;
}

#pragma mark Area To Ignore

- (void)setAreaToIgnore:(CGRect)area inParentView:(UIView *)fromView
{
    self.areaToIgnore = [self convertRect:area fromView:fromView];
}

- (void)setAreaToIgnore:(CGRect)newArea
{
    areaToIgnore = newArea;
}

- (BOOL)isTouchInAreaToIgnore:(CGPoint)touch
{
    int xMin = areaToIgnore.origin.x;
    int xMax = xMin + areaToIgnore.size.width;
    
    int yMin = areaToIgnore.origin.y;
    int yMax = yMin + areaToIgnore.size.height;
    
    if ( touch.x > xMin && touch.x < xMax )
    {
        if ( touch.y > yMin && touch.y < yMax )
        {
            return YES;
        }
    }
    
    return NO;
}

@end
