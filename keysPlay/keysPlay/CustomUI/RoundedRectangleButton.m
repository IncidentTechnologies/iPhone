//
//  RoundedRectangleButton.m
//  gTarAppCore
//
//  Created by Marty Greenia on 7/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "RoundedRectangleButton.h"
#import "RoundedRectangleView.h"

@implementation RoundedRectangleButton

@synthesize m_backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        CGRect backgroundFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        m_backgroundView = [[RoundedRectangleView alloc] initWithFrame:backgroundFrame];
        m_backgroundView.m_lineWidth = 1;
        
        // Add the background view
        [m_backgroundView setUserInteractionEnabled:NO];
        
        [self addSubview:m_backgroundView];
        [self sendSubviewToBack:m_backgroundView];

        // Make the text white
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    
    return self;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if ( self )
    {

        // Initialization code
        CGRect backgroundFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        
        m_backgroundView = [[RoundedRectangleView alloc] initWithFrame:backgroundFrame];
        m_backgroundView.m_lineWidth = 1;
        
        // Add the background view
        [m_backgroundView setUserInteractionEnabled:NO];
        
        [self addSubview:m_backgroundView];
        [self sendSubviewToBack:m_backgroundView];
        
        // Make the text white
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    
    return self;

}

//- (void)setFrame:(CGRect)frame
//{
//    DLog(@"%f %f", frame.origin.x,frame.origin.y);
//    [m_backgroundView release];
//    
//    CGRect backgroundFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//    DLog(@"%f %f", backgroundFrame.origin.x, backgroundFrame.origin.y);
//    
//    m_backgroundView = [[RoundedRectangleView alloc] initWithFrame:backgroundFrame];
//    m_backgroundView.m_lineWidth = 1;
//    
//    // Add the background view
//    [m_backgroundView setUserInteractionEnabled:NO];
//    
//    [self addSubview:m_backgroundView];
//    [self sendSubviewToBack:m_backgroundView];
//    
//    // Make the text white
//    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//    
//    [self setBackgroundColor:[UIColor clearColor]];
//
//    
//}
//

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
