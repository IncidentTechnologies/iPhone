//
//  UIButton+Keys.m
//  keysPlay
//
//  Created by Marty Greenia on 5/10/13.
//
//

#import "UIButton+Keys.h"

@implementation UIButton (Keys)

- (void)startActivityIndicator
{
    [self setEnabled:NO];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [indicator startAnimating];
    
    indicator.center = CGPointMake( self.bounds.size.width/2.0, self.bounds.size.height/2.0 );
    
    [self.titleLabel removeFromSuperview];
    
    [self addSubview:indicator];
}

- (void)stopActivityIndicator
{
    [self setEnabled:YES];
    
    [self addSubview:self.titleLabel];
    
    for ( UIView *subview in [self subviews] )
    {
        if ( [subview isKindOfClass:[UIActivityIndicatorView class]] == YES )
        {
            [subview removeFromSuperview];
        }
    }
}

@end