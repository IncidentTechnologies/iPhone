//
//  UserProfileSearchViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/26/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"

@class UserProfile;

@interface UserProfileSearchViewController : CustomViewController  <UITableViewDelegate, UITableViewDataSource>
{

    IBOutlet UIActivityIndicatorView * m_activityIndicator;
    IBOutlet UITableView * m_tableView;
    IBOutlet UILabel * m_statusLabel;
    IBOutlet UILabel * m_searchStringLabel;
    IBOutlet UIView * m_searchFacebookView;
    
    NSString * m_searchString;
    NSArray * m_resultsArray;
    
    UserProfile * m_userProfile;
    NSArray * m_userFriendList;
    
    BOOL m_waitingForFacebookSearch;
    
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicator;
@property (nonatomic, retain) IBOutlet UITableView * m_tableView;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_searchStringLabel;
@property (nonatomic, retain) IBOutlet UIView * m_searchFacebookView;
@property (nonatomic, retain) NSString * m_searchString;
@property (nonatomic, retain) NSArray * m_resultsArray;
@property (nonatomic, retain) UserProfile * m_userProfile;
@property (nonatomic, retain) NSArray * m_userFriendList;
@property (nonatomic, assign) BOOL m_waitingForFacebookSearch;

- (void)refreshTable;
- (void)displayResults:(NSArray*)userProfilesArray;
- (void)displayUserProfile:(UserProfile*)userProfile;
- (void)addFriend:(UserProfile*)userProfile;
- (void)removeFriend:(UserProfile*)userProfile;

@end
