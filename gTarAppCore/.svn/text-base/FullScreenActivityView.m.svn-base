//
//  FullScreenActivityView.m
//  gTarAppCore
//
//  Created by Joel Greenia on 4/17/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import "FullScreenActivityView.h"

#import <QuartzCore/QuartzCore.h>

@implementation FullScreenActivityView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIView * grayView = [[UIView alloc] initWithFrame:frame];
        
        grayView.backgroundColor = [UIColor blackColor];
        grayView.alpha = 0.5;
        
        UIView * blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        blackView.alpha = 0.7;
        
        blackView.backgroundColor = [UIColor blackColor];
//        blackView.layer.borderColor = [[UIColor grayColor] CGColor];
        blackView.layer.cornerRadius = 7;
//        blackView.layer.borderWidth = 2;
        
        UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activity startAnimating];
        
        blackView.center = self.center;
        grayView.center = self.center;
        activity.center = self.center;
        
        [self addSubview:grayView];
        [self addSubview:blackView];
        [self addSubview:activity];
        
        [blackView release];
        [grayView release];
        [activity release];
        
    }
    
    return self;
    
}

@end
