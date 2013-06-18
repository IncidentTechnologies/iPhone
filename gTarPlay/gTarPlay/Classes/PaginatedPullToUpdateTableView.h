//
//  PaginatedPullToUpdateTableView.h
//  gTarPlay
//
//  Created by Marty Greenia on 6/3/13.
//
//

#import "PullToUpdateTableView.h"

@protocol PaginatedPullToUpdateTableViewDelegate <PullToUpdateTableViewDelegate>
@optional
- (void)nextPage;
@end

@interface PaginatedPullToUpdateTableView : PullToUpdateTableView
{
    UILabel * m_footerLabel;
    UIActivityIndicatorView * m_activityView;
    BOOL m_triggerReady;
    BOOL m_enabled;
}

@property (nonatomic, assign) IBOutlet id<PaginatedPullToUpdateTableViewDelegate> delegate;
@property (nonatomic, readonly) BOOL m_enabled;

- (void)resetUpdateTrigger;

- (void)disablePagination;
- (void)enablePagination;

@end
