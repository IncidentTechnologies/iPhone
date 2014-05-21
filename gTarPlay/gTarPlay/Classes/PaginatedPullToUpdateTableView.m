//
//  PaginatedPullToUpdateTableView.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/3/13.
//
//

#define LEFT_MARGIN 35
#define FOOTER_HEIGHT 35
#import "PaginatedPullToUpdateTableView.h"

@implementation PaginatedPullToUpdateTableView

@synthesize m_enabled;

- (void)sharedInit
{
    [super sharedInit];
    
    UIView * footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, FOOTER_HEIGHT)];
    
    m_footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.frame.size.width - LEFT_MARGIN, FOOTER_HEIGHT)];
    [m_footerLabel setText:NSLocalizedString(@"Updating...", NULL)];
    [m_footerLabel setTextColor:[UIColor grayColor]];
    [m_footerLabel setFont:[UIFont fontWithName:@"Avenir Next" size:15.0]];
    
    m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [m_activityView setFrame:CGRectMake(0, 0, LEFT_MARGIN, FOOTER_HEIGHT)];
    [m_activityView startAnimating];
    
    [footer addSubview:m_activityView];
    [footer addSubview:m_footerLabel];
    
    self.tableFooterView = footer;
    
    [self disablePagination];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    
    if ( m_enabled && m_triggerReady && (contentOffset.y + self.frame.size.height + FOOTER_HEIGHT) > self.contentSize.height )
    {
        if ( [self.delegate respondsToSelector:@selector(nextPage)] == YES )
        {
            [self.delegate nextPage];
        }
        
        m_triggerReady = NO;
    }
}

- (void)resetUpdateTrigger
{
    m_triggerReady = YES;
}

- (void)reloadData
{
    [super reloadData];
    [self resetUpdateTrigger];
}

- (void)disablePagination
{
    m_enabled = NO;
    [self.tableFooterView setHidden:YES];
}

- (void)enablePagination
{
    m_enabled = YES;
    [self.tableFooterView setHidden:NO];
}

@end
