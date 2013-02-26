//
//  AccountViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 11/2/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>
#import <gTarAppCore/UserEntry.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/PopupViewController.h>

#import "PullToUpdateTableView.h"
#import "RootViewController.h"
#import "Facebook.h"

@class AccountView;
@class UserSong;
@class UserSongSession;
@class RootViewController;
@class CustomSegmentedControl;
@class AccountViewCell;

extern FileController * g_fileController;

@interface AccountViewController : UIViewController <PullToUpdateTableViewDelegate, UITableViewDataSource>
{

    RootViewController * m_rootViewController;
    
    IBOutlet UIView * m_headerView;
    IBOutlet CustomSegmentedControl * m_feedSelector;
    IBOutlet PullToUpdateTableView * m_tableView;
    IBOutlet UIView * m_footerView;
    
    IBOutlet UILabel * m_welcomeLabel;
    IBOutlet UIButton * m_profileButton;
        
    NSArray * m_friendFeed;
    NSArray * m_globalFeed;
    
    BOOL m_refreshingFriendFeed;
    BOOL m_refreshingGlobalFeed;
    BOOL m_displayingCell;
    
    NSInteger m_outStandingImageDownloads;
    
}

@property (nonatomic, assign) RootViewController * m_rootViewController;

@property (nonatomic, retain) IBOutlet UIView * m_headerView;
@property (nonatomic, retain) IBOutlet CustomSegmentedControl * m_feedSelector;
@property (nonatomic, retain) IBOutlet PullToUpdateTableView * m_tableView;
@property (nonatomic, retain) IBOutlet UIView * m_footerView;
@property (nonatomic, retain) IBOutlet UILabel * m_welcomeLabel;
@property (nonatomic, retain) IBOutlet UIButton * m_profileButton;

- (void)showFooter;
- (void)hideFooter;

- (void)updateFeeds;
- (void)updateGlobalFeed;
- (void)updateFriendFeed;
- (void)updateDisplay;
- (void)updateFeedDisplay;

- (void)fileDownloadFinished:(id)file;
- (void)playUserSongSession:(UserSongSession*)session;
- (void)playCell:(AccountViewCell*)cell;
- (void)stopCell:(AccountViewCell*)cell;

- (void)globalUpdateSucceeded:(CloudResponse*)cloudResponse;
- (void)userUpdateSucceeded:(UserResponse*)userResponse;
//- (void)loginWithFacebookToken:(NSString*)accessToken;
//- (void)loginWithFacebookTokenCallback:(CloudResponse*)cloudResponse;
//- (void)requestUploadUserSongSessionCallback:(CloudResponse*)cloudResponse;
//- (void)requestLogoutCallback:(CloudResponse*)cloudResponse;
//- (void)authorizeFacebook;

- (IBAction)profileButtonClicked:(id)sender;
- (IBAction)feedSelectorChanged:(id)sender;

@end
