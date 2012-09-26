//
//  CheckBox.m
//  gTarSequencer
//
//  Created by Ilan Gray on 6/21/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    [self setUserInteractionEnabled:YES];
    
    checked = NO;
    
    self.layer.borderWidth = 2.0;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    
    checkmark = [UIImage imageNamed:@"checkmark1.png"];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGRect checkmarkFrame = CGRectMake(width/4, -height/4, width, height);
    checkmarkView = [[UIImageView alloc] initWithFrame:checkmarkFrame];
    checkmarkView.image = checkmark;
    [checkmarkView setUserInteractionEnabled:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ( checked )
    {
        [self uncheck];
    }
    else 
    {
        [self check];
    }
}

- (void)uncheck
{
    checked = NO;
    [checkmarkView removeFromSuperview];
    
    [delegate stateDidChange:OFF];
}

- (void)check
{
    checked = YES;
    [self addSubview:checkmarkView];
    
    [delegate stateDidChange:ON];
}

- (void)setToState:(BOOL)turnOn
{
    if ( turnOn )
    {
        if ( !checked )
        {
            [self check];
        }
    }
    else 
    {
        if ( checked )
        {
            [self uncheck];
        }
    }
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
