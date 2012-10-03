//
//  TransparentAreaView.m
//  gTarPlay
//
//  Created by Franco Cedano on 12/13/11.
//  Copyright (c) 2011 Incident. All rights reserved.
//

#import "TransparentAreaView.h"

@implementation Bounds

@end

@implementation TransparentAreaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_tranparentAreas = [[NSMutableArray alloc] init]; 
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        m_tranparentAreas = [[NSMutableArray alloc] init]; 
    }
    return self;
}


// Check if the point touched falls inside one of the transparent windows
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // UIView will be "transparent" for touch events if we return NO

    // first filter touches outside the bounds of the frame
    if (point.x > self.frame.size.width || point.y > self.frame.size.height)
    {
        return NO;
    }
    
    // check if touch point lies inside one of the transparen zones
    for (Bounds *b in m_tranparentAreas) 
    {
        if (point.x > b->xMin && point.x < b->xMax && point.y > b->yMin && point.y < b->yMax)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void) addTransparentAreaWithXmin:(float)xMin xMax:(float)xMax yMin:(float)yMin yMax:(float)yMax
{
    Bounds *b = [[Bounds alloc] init];
    b->xMin = xMin;
    b->xMax = xMax;
    b->yMin = yMin;
    b->yMax = yMax;
    
    [m_tranparentAreas addObject:b];
    [b autorelease];
}

- (void) dealloc
{
    [m_tranparentAreas release];
}

@end
