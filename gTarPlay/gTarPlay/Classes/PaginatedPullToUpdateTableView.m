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
    
    UIView * footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, FOOTER_HEIGHT)] autorelease];
    
    m_footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, 0, self.frame.size.width - LEFT_MARGIN, FOOTER_HEIGHT)];
    [m_footerLabel setText:@"Updating..."];
    [m_footerLabel setTextColor:[UIColor grayColor]];
    
    m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [m_activityView setFrame:CGRectMake(0, 0, LEFT_MARGIN, FOOTER_HEIGHT)];
    [m_activityView startAnimating];
    
    [footer addSubview:m_activityView];
    [footer addSubview:m_footerLabel];
    
    self.tableFooterView = footer;
    
}

- (void)dealloc
{
    [m_footerLabel release];
    [m_activityView release];
    [super dealloc];
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
    
    if ( m_triggerReady == NO )
    {
        return;
    }
    
    if ( (contentOffset.y + self.frame.size.height + FOOTER_HEIGHT) > self.contentSize.height )
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
    [m_footerLabel setHidden:YES];
}

- (void)enablePagination
{
    m_enabled = YES;
    [m_footerLabel setHidden:NO];
}

@end
