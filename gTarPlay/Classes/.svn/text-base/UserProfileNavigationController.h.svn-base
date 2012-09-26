//
//  UserProfileNavigationController.h
//  gTarPlay
//
//  Created by Marty Greenia on 9/13/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomNavigationViewController.h"
#import "UserController.h"
#import "SongPlayerViewController.h"

@class UserProfile;
@class UserSongSession;
@class UserProfileViewController;
@class UserProfileSearchViewController;
@class SongPlayerViewController;
@class CloudResponse;
@class UserResponse;
@class UserProfileSelectPictureViewController;

@protocol UserProfileNavControllerDelegate <NSObject>

- (void)userProfileNavControllerDisplaySong:(UserSong*)userSong;
- (void)userProfileNavControllerLogout;

@end

@interface UserProfileNavigationController : CustomNavigationViewController <SongPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
    id<UserProfileNavControllerDelegate> m_delegate;
    
    UserProfileViewController * m_userProfileViewController;
    UserProfileSearchViewController * m_userProfileSearchViewController;
        
    BOOL m_displayCurrentUserProfile;
    UserProfile * m_fetchingProfileToDisplay;
    
    SongPlayerViewController * m_songPlaybackViewController;
    
    UserProfileSelectPictureViewController * m_changePicturePopupViewController;
    
//    UIActivityIndicatorView * m_facebookActivityIndicator;
    
    UserProfile * m_shortcutUserProfile;
    
    UIView * m_spinnerView;
    
}
@property (nonatomic, assign) id<UserProfileNavControllerDelegate> m_delegate;
@property (nonatomic, retain) UserProfile * m_shortcutUserProfile;

- (void)startSpinner;
- (void)endSpinner;

- (void)updateSessions;
- (void)updateUserFollowers;
- (void)updateUserFollowing;

- (void)userProfileCallback:(UserResponse*)userResponse;
- (void)userSessionsCallback:(UserResponse*)userResponse;
- (void)userFollowersCallback:(UserResponse*)userResponse;
- (void)userFollowingCallback:(UserResponse*)userResponse;
- (void)changeFollowingCallback:(UserResponse*)userResponse;

- (void)userControllerCallback:(UserResponse*)userResponse;
- (void)userProfileSearchCallback:(UserResponse*)userResponse;
- (void)userFacebookFriendsSearchCallback:(UserResponse*)userResponse;

- (void)getAndDisplayUserProfile:(UserProfile*)userProfile;
- (void)displayUserProfile:(UserProfile*)userProfile;
- (void)updateDisplayedInfo;
- (void)changeProfilePicturePopup;
- (void)updateProfilePicture:(UIImage*)image;
- (void)playUserSongSession:(UserSongSession*)userSongSession;
- (void)addUserFollows:(UserProfile*)userProfile;
- (void)removeUserFollows:(UserProfile*)userProfile;
- (void)logoutUser;

- (void)displayImagePicker;

@end
