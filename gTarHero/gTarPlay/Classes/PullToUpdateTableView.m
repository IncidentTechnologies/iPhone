//
//  PullToUpdateTableView.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/26/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "PullToUpdateTableView.h"

#define HEADER_OFFSET 35
#define LEFT_MARGIN HEADER_OFFSET
#define PULL_TO_UPDATE_HEIGHT 20
#define LAST_UPDATE_HEIGHT 12
#define IMAGE_INSET 10

#define UPDATE_THRESHOLD HEADER_OFFSET

@implementation PullToUpdateTableView

//@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        [self sharedInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if ( self )
    {
        
        // Initialization code
        [self sharedInit];
    }
    
    return self;
}

- (void)dealloc
{
    
    [m_instructionsLabel release];
    [m_lastUpdateLabel release];
    [m_arrowImageView release];
    [m_updatingIndicatorView release];
    
    [super dealloc];
    
}

- (void)sharedInit
{
    
    m_aboveThreshold = NO;
    
    //
    // Instructions, "pull to update"
    //
    m_instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, -HEADER_OFFSET, self.frame.size.width - LEFT_MARGIN, PULL_TO_UPDATE_HEIGHT)];
    m_instructionsLabel.text = @"Pull to update";
    m_instructionsLabel.textColor = [UIColor grayColor];
//        m_instructionsLabel.shadowColor = [UIColor darkGrayColor];
//        m_instructionsLabel.shadowOffset = CGSizeMake(1, 1);
    m_instructionsLabel.font = [m_instructionsLabel.font fontWithSize:14];
    
    [self addSubview:m_instructionsLabel];
    
    //
    // Last update label
    //
    m_lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, -HEADER_OFFSET+PULL_TO_UPDATE_HEIGHT, self.frame.size.width - LEFT_MARGIN, LAST_UPDATE_HEIGHT)];
//    m_lastUpdateLabel.text = @"Last update: Never";
    m_lastUpdateLabel.text = @"";
    m_lastUpdateLabel.textColor = [UIColor lightGrayColor];
//        m_lastUpdateLabel.shadowColor = [UIColor grayColor];
//        m_lastUpdateLabel.shadowOffset = CGSizeMake(1, 1);
    m_lastUpdateLabel.font = [m_lastUpdateLabel.font fontWithSize:12];
    
    [self addSubview:m_lastUpdateLabel];
    
    // 
    // Arrow
    //
    m_arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BlackBackArrow_DOWN.png"]];
    [m_arrowImageView setFrame:CGRectMake(IMAGE_INSET, -HEADER_OFFSET+IMAGE_INSET, LEFT_MARGIN-IMAGE_INSET-IMAGE_INSET, HEADER_OFFSET-IMAGE_INSET-IMAGE_INSET)];
    
    [self addSubview:m_arrowImageView];
    
    //
    // Spinner
    //
    m_updatingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [m_updatingIndicatorView setFrame:CGRectMake(0, -HEADER_OFFSET, LEFT_MARGIN, HEADER_OFFSET)];
    m_updatingIndicatorView.hidesWhenStopped = YES;
    [m_updatingIndicatorView stopAnimating];
    
    [self addSubview:m_updatingIndicatorView];

}

#pragma Animation

- (void)startAnimating
{
    
    if ( m_animating == YES )
    {
        return;
    }
    
    m_animating = YES;
    
    [m_updatingIndicatorView startAnimating];
    [m_arrowImageView setHidden:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [self showHeader];
    
    m_instructionsLabel.text = @"Updating...";
    
    [UIView commitAnimations];
    
}

- (void)stopAnimating
{
    
    if ( m_animating == NO )
    {
        return;
    }
    
    [self changeUpdateDate];
    
    m_animating = NO;
    
    [m_updatingIndicatorView stopAnimating];
    [m_arrowImageView setHidden:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [self hideHeader];
    
    if ( m_aboveThreshold == YES )
    {
        m_instructionsLabel.text = @"Release to update";
    }
    else
    {
        m_instructionsLabel.text = @"Pull to update";
    }
    
    [UIView commitAnimations];
    
}

- (void)startAnimatingOffscreen
{
    
    if ( m_animating == YES )
    {
        return;
    }
    
    m_animating = YES;
    
    [m_updatingIndicatorView startAnimating];
    [m_arrowImageView setHidden:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [self showHeaderOffscreen];
    
    m_instructionsLabel.text = @"Updating...";
    
    [UIView commitAnimations];
    
}

- (void)showHeader
{
    self.contentInset = UIEdgeInsetsMake(HEADER_OFFSET, 0.0f, 0.0f, 0.0f);
    
    // Using this version looks better because it doesn't chop off the bottom row
    [self setContentOffset:CGPointMake(0.0f, -HEADER_OFFSET) animated:YES];
}

- (void)hideHeader
{
    
    self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    
}

- (void)showHeaderOffscreen
{
    
    self.contentInset = UIEdgeInsetsMake(HEADER_OFFSET, 0.0f, 0.0f, 0.0f);
    
    [self setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    
}

- (void)aboveThreshold
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    m_arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    
    if ( m_animating == NO )
    {
        m_instructionsLabel.text = @"Release to update";
    }
    
    [UIView commitAnimations];
    
}

- (void)belowThreshold
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    m_arrowImageView.transform = CGAffineTransformIdentity;
    
    if ( m_animating == NO )
    {
        m_instructionsLabel.text = @"Pull to update";
    }
    
    [UIView commitAnimations];
    
}

- (void)changeUpdateDate
{
    
    NSDate * now = [NSDate date];
        
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString * currentTime = [dateFormatter stringFromDate:now];
    
    m_lastUpdateLabel.text = [NSString stringWithFormat:@"Last update: %@", currentTime];
    
    [dateFormatter release];
    
}

#pragma Scroll view overrides

- (void)setContentOffset:(CGPoint)contentOffset
{
    
    CGFloat offset = -contentOffset.y;
        
    if ( m_animating == YES )
    {
        // Do nothing?
    }
    else if ( m_aboveThreshold == YES && self.dragging == NO )
    {
        // Check to see if they just released the view
        m_aboveThreshold = NO;
        
        [self belowThreshold];
        
        // Its up to the delegate to start animation
        [self.delegate update];
        
        // Don't actually set the content offset here
        return;
    }
    else if ( offset > UPDATE_THRESHOLD && m_aboveThreshold == NO )
    {
        // Went over the threshold
        m_aboveThreshold = YES;
        
        [self aboveThreshold];
    }
    else if ( offset <= UPDATE_THRESHOLD && m_aboveThreshold == YES )
    {
        // Went under the threshold 
        m_aboveThreshold = NO;
        
        [self belowThreshold];
    }
    
    [super setContentOffset:contentOffset];
}

//- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
//{
//    
//    [super setContentOffset:contentOffset animated:animated];
//}
//
@end
