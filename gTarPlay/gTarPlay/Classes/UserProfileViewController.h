//
//  UserProfileViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/13/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomViewController.h"
#import "PullToUpdateTableView.h"

@class UserProfile;
@class CustomSegmentedControl;
@class UserEntry;
@class UserProfileSelectPictureViewController;

@interface UserProfileViewController : CustomViewController <PullToUpdateTableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    
    IBOutlet UILabel * m_nameLabel;
    IBOutlet UILabel * m_statusLabel;
    IBOutlet UITextView * m_profileTextView;
    IBOutlet UIImageView * m_profileImageView;
    IBOutlet UIView * m_controlsView;
    IBOutlet PullToUpdateTableView * m_tableView;
    IBOutlet CustomSegmentedControl * m_feedSegmentedButton;
//    IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
    IBOutlet UIButton * m_addFriendButton;
    IBOutlet UIButton * m_removeFriendButton;
    IBOutlet UIButton * m_logoutButton;
    IBOutlet UIView * m_changePicButton;
    
//    UserEntry * m_userEntry;
//    UserEntry * m_userEntryDisplayed;
//    UserEntry * m_userEntryToDisplay;
    
    UserProfile * m_displayedUserProfile;
    NSArray * m_displayedSessionsArray;
    NSArray * m_displayedFollowsArray;
    NSArray * m_displayedFollowedArray;

//    NSArray * m_displayedSessionsPrevious;
//    NSArray * m_displayedFollowsPrevious;
//    NSArray * m_displayedFollowedPrevious;

    UserProfile * m_userProfile;
    NSArray * m_userFriendList;
    
    BOOL m_updatingSessions;
    BOOL m_updatingFollowing;
    BOOL m_updatingFollowers;
    
}

@property (nonatomic, retain) IBOutlet UILabel * m_nameLabel;
@property (nonatomic, retain) IBOutlet UILabel * m_statusLabel;
@property (nonatomic, retain) IBOutlet UITextView * m_profileTextView;
@property (nonatomic, retain) IBOutlet UIImageView * m_profileImageView;
@property (nonatomic, retain) IBOutlet UIView * m_controlsView;
@property (nonatomic, retain) IBOutlet PullToUpdateTableView * m_tableView;
@property (nonatomic, retain) IBOutlet CustomSegmentedControl * m_feedSegmentedButton;
//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIButton * m_addFriendButton;
@property (nonatomic, retain) IBOutlet UIButton * m_removeFriendButton;
@property (nonatomic, retain) IBOutlet UIButton * m_logoutButton;
@property (nonatomic, retain) IBOutlet UIView * m_changePicButton;

//@property (nonatomic, retain) UserEntry * m_userEntry;
//@property (nonatomic, retain) UserEntry * m_userEntryDisplayed;
//@property (nonatomic, retain) UserEntry * m_userEntryToDisplay;

@property (nonatomic, retain) UserProfile * m_displayedUserProfile;
@property (nonatomic, retain) NSArray * m_displayedSessionsArray;
@property (nonatomic, retain) NSArray * m_displayedFollowsArray;
@property (nonatomic, retain) NSArray * m_displayedFollowedArray;

@property (nonatomic, retain) UserProfile * m_userProfile;
@property (nonatomic, retain) NSArray * m_userFriendList;

- (IBAction)feedSelectionChanged:(id)sender;
- (IBAction)addFriendButtonClicked:(id)sender;
- (IBAction)removeFriendButtonClicked:(id)sender;
- (IBAction)logoutButtonClicked:(id)sender;
- (IBAction)changePicButtonClicked:(id)sender;

- (void)clearTable;
- (void)refreshTable;
- (void)refreshRelationship;
- (void)refreshSessions;
- (void)refreshFollowing;
- (void)refreshFollowers;

- (void)addUserFollows:(UserProfile*)userProfile;
- (void)removeUserFollows:(UserProfile*)userProfile;

- (void)updatingEverything;

// prof pic 
- (void)displayImagePicker;
- (UIImage*)captureView:(UIView*)view;
@end
