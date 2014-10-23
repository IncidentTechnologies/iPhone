//
//  PullToUpdateTableView.h
//  gTarPlay
//
//  Created by Marty Greenia on 4/26/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITriangleView.h"

@protocol PullToUpdateTableViewDelegate <UITableViewDelegate>
@optional
- (void)updateTable;
@end

@interface PullToUpdateTableView : UITableView
{
    UILabel * m_instructionsLabel;
    UILabel * m_lastUpdateLabel;
    UIActivityIndicatorView * m_updatingIndicatorView;
    
    UITriangleView *m_arrowTriangleView;
    
    BOOL m_aboveThreshold;
    BOOL m_animating;
}

@property (nonatomic, weak) IBOutlet id<PullToUpdateTableViewDelegate> delegate;

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
-(void)setArrowColor:(UIColor*)color;
-(void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;

@end
