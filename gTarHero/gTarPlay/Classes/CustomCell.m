//
//  CustomCell.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/22/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "CustomCell.h"

#import <QuartzCore/QuartzCore.h>

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)dealloc
//{
//    [super dealloc];
//}

+ (CGFloat)cellHeight
{
    // default
    return 44.0f;
}

- (void)updateCell
{
    // We are removing the gradient for now
    // add a nice gradient
    if ( m_initialized == NO )
    {
        m_initialized = YES;
//        self.accessoryView.backgroundColor = [UIColor whiteColor];
        
        // blue background highlight
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:149.0/255.0
                                                                      green:183.0/255.0
                                                                       blue:216.0/255.0 
                                                                      alpha:1.0];

    }
    
    if ( NO )
    {
        
        m_initialized = YES;
        
        UIView * gradientView;
        CAGradientLayer * gradient;
        
        // the background needs a subtle up-down gradient
        gradientView = self.backgroundView;
        
        gradient = [CAGradientLayer layer];
        gradient.frame = gradientView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[gradientView.backgroundColor CGColor], (id)[[UIColor lightGrayColor] CGColor], nil];
        [gradientView.layer insertSublayer:gradient atIndex:0];
        
        // the selected view needs a strong left-right gradient
        gradientView = self.selectedBackgroundView;
        
        CGFloat blackFloat = 8.0 / gradientView.frame.size.width;
        CGFloat clearFloat = 120.0 / gradientView.frame.size.width;
        
        gradient = [CAGradientLayer layer];
        gradient.frame = gradientView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
        gradient.locations = [NSArray arrayWithObjects:(id)[NSNumber numberWithFloat:blackFloat], (id)[NSNumber numberWithFloat:clearFloat], (id)[NSNumber numberWithFloat:1.0], nil];
        gradient.startPoint = CGPointMake(0.0, 0.5);
        gradient.endPoint = CGPointMake(1.0, 0.5);
        [gradientView.layer insertSublayer:gradient atIndex:0];
        
    }
    
}

@end
