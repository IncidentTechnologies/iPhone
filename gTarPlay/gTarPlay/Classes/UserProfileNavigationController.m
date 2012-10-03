//
//  UserProfileNavigationController.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/13/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "UserProfileNavigationController.h"
#import "UserProfileViewController.h"
#import "UserProfileSearchViewController.h"
#import "SongPlayerViewController.h"
#import "CustomSegmentedControl.h"
#import "UserProfileSelectPictureViewController.h"

#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/CloudResponse.h>
#import <gTarAppCore/UserEntry.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserResponse.h>
#import <gTarAppCore/FullScreenActivityView.h>

extern CloudController * g_cloudController;
extern FileController * g_fileController;
extern UserController * g_userController;

@implementation UserProfileNavigationController

@synthesize m_delegate;
@synthesize m_shortcutUserProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {

        self.m_title = @"Profile";
        
        // UserProfile VC
        m_userProfileViewController = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
        m_userProfileSearchViewController = [[UserProfileSearchViewController alloc] initWithNibName:@"UserProfileSearchViewController" bundle:nil];
        
        // Change Pic VC
        m_changePicturePopupViewController = [[UserProfileSelectPictureViewController alloc] initWithNibName:nil bundle:nil];
        m_changePicturePopupViewController.m_navigationController = self;
        m_changePicturePopupViewController.m_closeButtonImage = [UIImage imageNamed:@"XButton.png"];
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_spinnerView removeFromSuperview];
    
    [m_userProfileViewController release];
    [m_userProfileSearchViewController release];
    
    [m_fetchingProfileToDisplay release];
    [m_songPlaybackViewController release];
//    [m_facebookActivityIndicator release];
    
    [m_shortcutUserProfile release];
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [m_notifyButton setImage:[UIImage imageNamed:@"FacebookIcon.png"] forState:UIControlStateNormal];
    [m_notifyButton setImageEdgeInsets:UIEdgeInsetsMake(7.0, 13.0, 7.0, 13.0)];
    
    [m_homeButton setHidden:NO];
    [m_homeButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    m_homeButton.adjustsImageWhenHighlighted = NO;
//    [m_homeButton setContentMode:UIViewContentModeScaleAspectFit];
    
    if ( g_userController.m_loggedInFacebookToken == nil )
    {
        [m_notifyButton setHidden:YES];
    }
    else
    {
        [m_notifyButton setHidden:NO];
    }
    
    [self clearViewController];
    
    // ---
    
    [self startSpinner];
    
    // Let's see if there is already some user profile data to display
    UserEntry * userEntry = [g_userController getUserEntry:0];
    
    // We don't want to show the current user if there is another user we are looking for.
    if ( userEntry != nil && m_shortcutUserProfile == nil)
    {
        [self displayUserProfile:userEntry.m_userProfile];

        UIImage * pic = [g_fileController getFileOrDownloadSync:userEntry.m_userProfile.m_imgFileId];
        
        if ( pic != nil )
        {
            [m_homeButton setImage:pic forState:UIControlStateNormal];
//            [m_homeButton setImage:pic forState:UIControlStateHighlighted];
//            [m_homeButton setImage:pic forState:UIControlStateSelected];
//            [m_homeButton setBackgroundImage:pic forState:UIControlStateNormal];
        }
    }
    
    [m_userProfileViewController updatingEverything];
    
    // update everything anyways
    [g_userController requestUserProfile:0 andCallbackObj:self andCallbackSel:@selector(userProfileCallback:)];
    [g_userController requestUserSessions:0 andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];
    [g_userController requestUserFollows:0 andCallbackObj:self andCallbackSel:@selector(userFollowingCallback:)];
    [g_userController requestUserFollowedBy:0 andCallbackObj:self andCallbackSel:@selector(userFollowersCallback:)];
    
    if ( m_shortcutUserProfile != nil )
    {
        
        m_displayCurrentUserProfile = NO;
        
        [self getAndDisplayUserProfile:m_shortcutUserProfile];
        
        self.m_shortcutUserProfile = nil;
        
    }
    else
    {
        m_displayCurrentUserProfile = YES;
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
//    [self clearViewController];
//    
////    [m_customActivityView setHidden:NO];
//    [self startSpinner];
//    
//    // Let's see if there is already some user profile data to display
//    UserEntry * userEntry = [g_userController getUserEntry:0];
//    
//    // We don't want to show the current user if there is another user we are looking for.
//    if ( userEntry != nil && m_shortcutUserProfile == nil)
//    {
//        [self displayUserProfile:userEntry.m_userProfile];
//    }
//    
//    // update everything anyways
//    [g_userController requestUserProfile:0 andCallbackObj:self andCallbackSel:@selector(userProfileCallback:)];
//    [g_userController requestUserSessions:0 andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];
//    [g_userController requestUserFollows:0 andCallbackObj:self andCallbackSel:@selector(userFollowingCallback:)];
//    [g_userController requestUserFollowedBy:0 andCallbackObj:self andCallbackSel:@selector(userFollowersCallback:)];
//    
//    if ( m_shortcutUserProfile != nil )
//    {
//        
//        m_displayCurrentUserProfile = NO;
//        
//        [self getAndDisplayUserProfile:m_shortcutUserProfile];
//        
//        self.m_shortcutUserProfile = nil;
//        
//    }
//    else
//    {
//        m_displayCurrentUserProfile = YES;
//    }
//    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{

    // We move this here because the sampler takes a while to load.
    if ( m_songPlaybackViewController == nil )
    {
        // Song playback VC
        m_songPlaybackViewController = [[SongPlayerViewController alloc] initWithNibName:nil bundle:nil];
        m_songPlaybackViewController.m_delegate = self;
    }
    
    [super viewDidAppear:animated];
}

- (void)startSpinner
{
    
    [m_customActivityView setHidden:NO];
    
//    m_spinnerView = [[UIView alloc] initWithFrame:self.view.frame];
//    m_spinnerView.backgroundColor = [UIColor blackColor];
//    m_spinnerView.alpha = 0.2;
//    
//    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    
//    spinner.center = m_spinnerView.center;
//    spinner.color = [UIColor blackColor];
//    
//    [m_spinnerView addSubview:spinner];
//    [self.view addSubview:m_spinnerView];
//    
//    [spinner startAnimating];
//    
//    [spinner release];
//    [m_spinnerView release];
    
}

- (void)endSpinner
{
        
    [m_customActivityView setHidden:YES];
    
//    [m_spinnerView removeFromSuperview];
//    
//    m_spinnerView = nil;
    
}

#pragma mark - Update content

- (void)updateSessions
{
    
//    [self startSpinner];
    
    [g_userController requestUserSessions:m_userProfileViewController.m_displayedUserProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];

}

- (void)updateUserFollowers
{
    
//    [self startSpinner];
    
    [g_userController requestUserFollowedBy:m_userProfileViewController.m_displayedUserProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userFollowersCallback:)];
    
}

- (void)updateUserFollowing
{
    
//    [self startSpinner];
    
    [g_userController requestUserFollows:m_userProfileViewController.m_displayedUserProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userFollowingCallback:)];

}


#pragma mark - Update content calbacks

- (void)userProfileCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UserEntry * userEntry = [g_userController getUserEntry:0];
    
    // first time we load up, we need to display the users profile
    if ( userEntry.m_userProfile != nil && m_displayCurrentUserProfile == YES)
    {
        m_displayCurrentUserProfile = NO;
        [m_fetchingProfileToDisplay release];
        m_fetchingProfileToDisplay = [userEntry.m_userProfile retain];
    }
    
    UIImage * pic = [g_fileController getFileOrDownloadSync:userEntry.m_userProfile.m_imgFileId];
    
    if ( pic != nil )
    {
        [m_homeButton setImage:pic forState:UIControlStateNormal];
//        [m_homeButton setImage:pic forState:UIControlStateHighlighted];
//        [m_homeButton setImage:pic forState:UIControlStateSelected];
//        [m_homeButton setBackgroundImage:pic forState:UIControlStateNormal];
    }

    //
    // Update the logged in user's lists
    //
    m_userProfileViewController.m_userProfile = userEntry.m_userProfile;
    
    m_userProfileSearchViewController.m_userProfile = userEntry.m_userProfile;
    
    [g_fileController precacheFile:userEntry.m_userProfile.m_imgFileId];
    
    // update any new info for the displayed profile
    [self updateDisplayedInfo];
    
    // update the user profile button in the top bar
//    if ( userEntry.m_userProfile.m_profilePic != nil )
//    {
//        m_homeButton.imageView.image = userEntry.m_userProfile.m_profilePic;
//    }
    
    // refresh everything with the new status
//    [m_userProfileViewController refreshTable];
    [m_userProfileViewController refreshRelationship];
    [m_userProfileSearchViewController refreshTable];
    
    //
    // If the profile we want is ready, show it
    //
    if ( m_fetchingProfileToDisplay != nil )
    {
        
        UserEntry * displayedEntry = [g_userController getUserEntry:m_fetchingProfileToDisplay.m_userId];
        
        if ( displayedEntry != nil )
        {
            
            [m_fetchingProfileToDisplay release];
            
            m_fetchingProfileToDisplay = nil;
            
            [g_fileController precacheFile:displayedEntry.m_userProfile.m_imgFileId];
            
            [self displayUserProfile:displayedEntry.m_userProfile];
            
            return;
        }
    }

}

- (void)userSessionsCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //UserEntry * userEntry = [g_userController getUserEntry:0];
    
    //
    // Update the logged in user's lists
    //
    //m_userProfileViewController.m_displayedSessionsArray = userEntry.m_sessionsList;
    
    [self updateDisplayedInfo];
    
    // refresh everything with the new status
    [m_userProfileViewController refreshSessions];
    
}

- (void)userFollowersCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //UserEntry * userEntry = [g_userController getUserEntry:0];
    
    //
    // Update the logged in user's lists
    //
    //m_userProfileViewController.m_displayedFollowedArray = userEntry.m_followedByList;
    
    [self updateDisplayedInfo];
    
    // refresh everything with the new status
    [m_userProfileViewController refreshFollowers];
    
}

- (void)userFollowingCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UserEntry * userEntry = [g_userController getUserEntry:0];
    
    //
    // Update the logged in user's lists
    //
    m_userProfileViewController.m_userFriendList = userEntry.m_followsList;
    //m_userProfileViewController.m_displayedFollowsArray = userEntry.m_followsList;
    
    m_userProfileSearchViewController.m_userFriendList = userEntry.m_followsList;
    
    [self updateDisplayedInfo];
    
    // refresh everything with the new status
    [m_userProfileViewController refreshFollowing];
    [m_userProfileViewController refreshRelationship];
    [m_userProfileSearchViewController refreshTable];
    
}

- (void)changeFollowingCallback:(UserResponse *)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UserEntry * userEntry = [g_userController getUserEntry:0];
    
    //
    // Update the logged in user's lists
    //
    m_userProfileViewController.m_userFriendList = userEntry.m_followsList;
    
    m_userProfileSearchViewController.m_userFriendList = userEntry.m_followsList;
    
    [self updateDisplayedInfo];
    
    [m_userProfileViewController refreshRelationship];
    [m_userProfileViewController refreshTable];
    [m_userProfileViewController refreshSessions];
    [m_userProfileViewController refreshFollowers];
    [m_userProfileViewController refreshFollowing];
    
    [m_userProfileSearchViewController refreshTable];
        
}

#pragma derp?

- (void)userControllerCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UserEntry * userEntry = [g_userController getUserEntry:0];
    
    // first time we load up, we need to display the users profile
    if ( userEntry.m_userProfile != nil && m_displayCurrentUserProfile == YES)
    {
        m_displayCurrentUserProfile = NO;
        [m_fetchingProfileToDisplay release];
        m_fetchingProfileToDisplay = [userEntry.m_userProfile retain];
    }
    
    //
    // Update the logged in user's lists
    //
    m_userProfileViewController.m_userProfile = userEntry.m_userProfile;
    m_userProfileViewController.m_userFriendList = userEntry.m_followsList;
    
    m_userProfileSearchViewController.m_userProfile = userEntry.m_userProfile;
    m_userProfileSearchViewController.m_userFriendList = userEntry.m_followsList;
//    m_userProfileSearchViewController.m_resultsArray = userEntry.m_facebookFriendsList;
    
    [g_fileController precacheFile:userEntry.m_userProfile.m_imgFileId];
    
    // update any new info for the displayed profile
    [self updateDisplayedInfo];
    
    // refresh everything with the new status
//    [m_userProfileViewController refreshTable];
    [m_userProfileViewController refreshRelationship];
    [m_userProfileSearchViewController refreshTable];
    
    //
    // If the profile we want is ready, show it
    //
    if ( m_fetchingProfileToDisplay != nil )
    {
        
        UserEntry * displayedEntry = [g_userController getUserEntry:m_fetchingProfileToDisplay.m_userId];
        
        if ( displayedEntry != nil )
        {
            
            [m_fetchingProfileToDisplay release];
            
            m_fetchingProfileToDisplay = nil;
            
            [g_fileController precacheFile:displayedEntry.m_userProfile.m_imgFileId];
            
            [self displayUserProfile:displayedEntry.m_userProfile];
            
            return;
        }
    }

}

- (void)userProfileSearchCallback:(UserResponse*)userResponse
{
    
    [m_userProfileSearchViewController.m_activityIndicator stopAnimating];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSArray * foundUserProfiles = userResponse.m_searchResults;
    
    // pull down all the images
    for ( UserProfile * userProfile in foundUserProfiles )
    {
        [g_fileController precacheFile:userProfile.m_imgFileId];
    }
    
    [m_userProfileSearchViewController displayResults:foundUserProfiles];
    
}

- (void)userFacebookFriendsSearchCallback:(UserResponse*)userResponse
{

    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        // Something failed, we are probably offline
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UserEntry * userEntry = [g_userController getUserEntry:0];

    if ( userEntry.m_facebookFriendsList != nil &&
         m_userProfileSearchViewController.m_waitingForFacebookSearch == YES)
    {
                
        // pull down all the images
        for ( UserProfile * userProfile in userEntry.m_facebookFriendsList )
        {
            [g_fileController precacheFile:userProfile.m_imgFileId];
        }
        
        [m_userProfileSearchViewController.m_activityIndicator stopAnimating];
        
        [m_userProfileSearchViewController displayResults:userEntry.m_facebookFriendsList];
        
    }
    
}

#pragma mark - Animation helpers

- (void)getAndDisplayUserProfile:(UserProfile*)userProfile
{
    
    [self startSpinner];
    
//    if ( m_userProfileViewController == m_currentViewController )
    {
        // clear the VC so we get the animation in
        [self clearViewController];
    }
    
    [m_userProfileViewController clearTable];
    [m_userProfileViewController refreshTable];
    
    [self contractSearchBar];
    
    m_userProfileViewController.m_displayedUserProfile = userProfile;
    
    [m_userProfileViewController updatingEverything];
    
    [g_userController requestUserProfile:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userProfileCallback:)];
    [g_userController requestUserSessions:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];
    [g_userController requestUserFollows:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userFollowingCallback:)];
    [g_userController requestUserFollowedBy:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(userFollowersCallback:)];
    
    
    [m_fetchingProfileToDisplay release];
    
    m_fetchingProfileToDisplay = [userProfile retain];
    
}

- (void)displayUserProfile:(UserProfile*)userProfile
{
    
    [self endSpinner];
    
    m_userProfileViewController.m_displayedUserProfile = userProfile;
    
    // Fetch updated data
    [self updateDisplayedInfo];
    
    // Update the views
//    [m_userProfileViewController refreshTable];
    [m_userProfileViewController refreshRelationship];
    
    [self switchInViewController:m_userProfileViewController];
    
}

- (void)updateDisplayedInfo
{
    
    //
    // Update the displayed user's state
    // 
    UserEntry * displayedEntry = [g_userController getUserEntry:m_userProfileViewController.m_displayedUserProfile.m_userId];
    
    // its ok if these are nil
    m_userProfileViewController.m_displayedUserProfile = displayedEntry.m_userProfile;
    m_userProfileViewController.m_displayedSessionsArray = displayedEntry.m_sessionsList;
    m_userProfileViewController.m_displayedFollowsArray = displayedEntry.m_followsList;
    m_userProfileViewController.m_displayedFollowedArray = displayedEntry.m_followedByList;
    
    // get profile images if we need them
    [g_fileController precacheFile:displayedEntry.m_userProfile.m_imgFileId];
    
    for ( UserProfile * userProfile in displayedEntry.m_followsList )
    {
        [g_fileController precacheFile:userProfile.m_imgFileId];
    }
    
    for ( UserProfile * userProfile in displayedEntry.m_followedByList )
    {
        [g_fileController precacheFile:userProfile.m_imgFileId];
    }

}

- (void)changeProfilePicturePopup
{
    
//    [m_changePicturePopupViewController attachToSuperViewWithBlackBackground:self.view];
    [self displayImagePicker];
    
}

- (void)updateProfilePicture:(UIImage*)image
{
    
    [self startSpinner];
    
    [g_userController requestUserProfileChangePicture:image andCallbackObj:self andCallbackSel:@selector(userProfileCallback:)];
    
}

- (void)playUserSongSession:(UserSongSession*)userSongSession
{
    
    NSString * xmpBlob = [g_fileController getFileOrDownloadSync:userSongSession.m_xmpFileId];
    
    userSongSession.m_xmpBlob = xmpBlob;
    
    [m_songPlaybackViewController attachToSuperView:self.view andPlaySongSession:userSongSession];
    
}

#pragma mark - Button click handlers

- (IBAction)homeButtonClicked:(id)sender
{
    
    UserEntry * userEntry = [g_userController getUserEntry:0];
    
    // No need to show it if it is already shown
    if ( userEntry.m_userProfile == m_userProfileViewController.m_displayedUserProfile &&
         m_currentViewController == m_userProfileViewController )
    {
        return;
    }
    
    [self clearViewController];
    
    [m_userProfileViewController clearTable];
    
    [self contractSearchBar];
    
    [self displayUserProfile:userEntry.m_userProfile];
    
}

- (IBAction)notifyButtonClicked:(id)sender
{
    
    [self contractSearchBar];
    
    [self clearViewController];
    
    [self switchInViewController:m_userProfileSearchViewController];
    
    [g_userController requestUserFacebookFriends:g_cloudController.m_facebookAccessToken andCallbackObj:self andCallbackSel:@selector(userFacebookFriendsSearchCallback:)];
    
    m_userProfileSearchViewController.m_waitingForFacebookSearch = YES;
    
    m_userProfileSearchViewController.m_resultsArray = nil;
    
    [self switchInViewController:m_userProfileSearchViewController];

    [m_userProfileSearchViewController.m_searchFacebookView setHidden:NO];
    
}

#pragma mark - Misc

- (void)addUserFollows:(UserProfile*)userProfile
{
    [self startSpinner];
    [g_userController requestAddUserFollow:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(changeFollowingCallback:)];
}

- (void)removeUserFollows:(UserProfile*)userProfile
{
    [self startSpinner];
    [g_userController requestRemoveUserFollow:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(changeFollowingCallback:)];
}

- (void)logoutUser
{
    [m_delegate userProfileNavControllerLogout];
    
    [self backButtonClicked:nil];
}

- (void)beginSearch
{
    // switch over to the search view 
    m_userProfileSearchViewController.m_previousViewController = m_currentViewController;

    [self switchInViewController:m_userProfileSearchViewController];
    
}

- (void)cancelSearch
{
    
    // return back to the previous controller
    [self switchInViewController:m_userProfileViewController];
    
}

- (void)searchForString:(NSString*)searchString
{
    
    [g_userController requestUserProfileSearch:searchString andCallbackObj:self andCallbackSel:@selector(userProfileSearchCallback:)];
    
}

#pragma mark - SongPlayerDelegate

- (void)songPlayerDisplayUserProfile:(UserProfile*)userProfile
{
    [self getAndDisplayUserProfile:userProfile];
}

- (void)songPlayerDisplayUserSong:(UserSong*)userSong
{
    [m_delegate userProfileNavControllerDisplaySong:userSong];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Image Picker

- (void)displayImagePicker
{
    
//    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO )
//    {
//        return;
//    }
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
//    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
//    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//    picker.showsCameraControls = YES;
//    
//    // 480x320 : 2592x1936
//    // 1936/320 = 6.05
//    // 2592/6.05 = 428
//    // 480-428 = 52
//    // 52/(428/2) = 0.24299
//    // => 1.24299
//    picker.cameraViewTransform = CGAffineTransformMakeScale( 2.0/3.0, 2.0/3.0 );
//    
//    UIImageView * imageView = [[UIImageView alloc] initWithImage:[self captureView:m_navigationController.view]];
//    imageView.transform = CGAffineTransformMakeScale( 2.0/3.0, 2.0/3.0 );
//    imageView.transform = CGAffineTransformRotate( imageView.transform, -M_PI_2 );
//    
//    picker.cameraOverlayView = imageView;

//    picker.cameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 100)];
//    picker.cameraOverlayView.backgroundColor = [UIColor blueColor];
    
    [self presentModalViewController:picker animated:YES];
    
    [picker release];
}

//- (UIImage*)captureView:(UIView*)view
//{
//    
////    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    
//    CGRect screenRect = view.bounds;
//    
//    UIGraphicsBeginImageContext(screenRect.size);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] set];
//    CGContextFillRect(ctx, screenRect);
//    
//    [view.layer renderInContext:ctx];
//    
//    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}

#pragma mark -
#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage * pickedImage = [[info objectForKey:UIImagePickerControllerOriginalImage] retain];
    
    [self updateProfilePicture:pickedImage];
    
    [pickedImage release];
    
    [picker dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissModalViewControllerAnimated:YES];    
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    
}

@end