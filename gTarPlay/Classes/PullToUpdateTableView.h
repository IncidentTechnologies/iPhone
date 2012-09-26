//
//  PullToUpdateTableView.h
//  gTarPlay
//
//  Created by Joel Greenia on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PullToUpdateTableViewDelegate <UITableViewDelegate>

- (void)update;

@end

@interface PullToUpdateTableView : UITableView
{
    
    UILabel * m_instructionsLabel;
    UILabel * m_lastUpdateLabel;
    UIActivityIndicatorView * m_updatingIndicatorView;
    
    UIImageView * m_arrowImageView;
    
    BOOL m_aboveThreshold;
    BOOL m_animating;
    
}

@property (nonatomic, assign) id<PullToUpdateTableViewDelegate> delegate;

- (void)sharedInit;

- (void)startAnimating;
- (void)stopAnimating;
- (void)showHeader;
- (void)hideHeader;
- (void)aboveThreshold;
- (void)belowThreshold;
- (void)changeUpdateDate;
- (void)update;


@end
