//
//  PullToUpdateTableView.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/26/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PullToUpdateTableViewDelegate <UITableViewDelegate>
@optional
- (void)updateTable;
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

@property (nonatomic, assign) IBOutlet id<PullToUpdateTableViewDelegate> delegate;

- (void)sharedInit;

- (void)startAnimating;
- (void)stopAnimating;
- (void)startAnimatingOffscreen;
- (void)showHeader;
- (void)hideHeader;
- (void)showHeaderOffscreen;
- (void)aboveThreshold;
- (void)belowThreshold;
- (void)changeUpdateDate;

-(void)setIndicatorTextColor:(UIColor*)color;

@end
