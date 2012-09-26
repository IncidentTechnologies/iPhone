//
//  AccountView.h
//  gTarPlay
//
//  Created by Marty Greenia on 11/1/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomSegmentedControl;

//@class RoundedRectangleView;
//@class MarqueeExpandingRoundedRectangleView;
//@class ExpandingRoundedRectangleView;

@interface AccountView : UIView
{
    
    UIView * m_smallView;
    UIView * m_largeView;
    UIView * m_largeGradient;
    
    UIButton * m_loginButton;
    UIButton * m_logoutButton;
    UIButton * m_profileButton;
    UILabel * m_welcomeLabel;
    UIActivityIndicatorView * m_activityIndicator;
    UILabel * m_headerLabel;
    UILabel * m_headerView;
    CustomSegmentedControl * m_feedSelector;
    
    UITableView * m_tableView;
    UILabel * m_noContentLabel;
    UIActivityIndicatorView * m_feedActivityIndicator;
    UIView * m_footerFeedActivityIndicatorView;

    UIActivityIndicatorView * m_cacheLoginActivityIndicator;
    UIButton * m_retryCacheLoginButton;
    
}

@property (nonatomic, readonly) UIButton * m_loginButton;
@property (nonatomic, readonly) UIButton * m_logoutButton;
@property (nonatomic, readonly) UIButton * m_profileButton;
@property (nonatomic, readonly) UITableView * m_tableView;
@property (nonatomic, readonly) UIButton * m_retryCacheLoginButton;
@property (nonatomic, readonly) CustomSegmentedControl * m_feedSelector;
@property (nonatomic, readonly) UILabel * m_noContentLabel;
@property (nonatomic, readonly) UIActivityIndicatorView * m_feedActivityIndicator;

- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)startCacheLoginActivityIndicator;
- (void)stopCacheLoginActivityIndicator;
- (void)failedCacheLoginActivityIndicator;
- (void)expandAccountView:(BOOL)animated;
- (void)contractAccountView;
- (void)setLoadingMessage;

@end
