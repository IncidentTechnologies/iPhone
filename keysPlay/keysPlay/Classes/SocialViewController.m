//
//  SocialViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/12/13.
//
//

#import "SocialViewController.h"

#import "SelectorControl.h"
#import <gTarAppCore/Facebook.h>
#import "SocialSongCell.h"
#import "SocialUserCell.h"
#import "SessionModalViewController.h"
#import "PullToUpdateTableView.h"

#import "UIView+Keys.h"
#import "UIButton+Keys.h"

#import <gTarAppCore/UserController.h>
#import "UserProfile.h"
#import "UserSongSession.h"
#import "UserSong.h"
#import "CloudController.h"
#import "CloudResponse.h"
#import <gTarAppCore/UserEntry.h>
#import "FileController.h"
#import <gTarAppCore/UserResponse.h>

extern UserController *g_userController;
extern FileController *g_fileController;
extern Facebook *g_facebook;

@interface SocialViewController ()
{
    NSInteger _displayedUserId;
//    UserEntry *_loggedInUserEntry;
    UserEntry *_displayedUserEntry;
    
//    UserProfile *_loggedInUserProfile;
    
    NSArray *_userProfileSearchResults;
    
    SessionModalViewController *_sessionViewController;
    
//    BOOL displaySearch;
    NSInteger _requestsInFlight;
    
    UIAlertView *_alertView;
    
}
@end

@implementation SocialViewController

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil soundMaster:(SoundMaster *)soundMaster
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        g_soundMaster = soundMaster;
        [g_soundMaster start];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    [_topBar addShadow];
    
    [_searchTable setHidden:YES];
    //[_fullscreenButton setHidden:YES];
    
    [_feedTable disablePagination];
    
    [_profileButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.view bringSubviewToFront:_searchTable];
    //[self.view bringSubviewToFront:_fullscreenButton];
    
    [self displayAndUpdateUserId:0];
    
    _sessionViewController = [[SessionModalViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    
}

- (void)localizeViews {
    [_logoutButton setTitle:NSLocalizedString(@"Logout", NULL) forState:UIControlStateNormal];
    [_followButton setTitle:NSLocalizedString(@"Follow", NULL) forState:UIControlStateNormal];
    [_followingButton setTitle:NSLocalizedString(@"Following", NULL) forState:UIControlStateNormal];
    
    //_profileLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Profile", NULL)];
    //_backLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Back", NULL)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //[_fullscreenButton release];
    
    _alertView.delegate = nil;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

#pragma mark - Button click handlers

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profileButtonClicked:(id)sender
{
    [self displayAndUpdateUserId:0];
}

- (IBAction)accountButtonClicked:(id)sender
{
    [g_userController requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    //[g_facebook logout];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changePicButtonClicked:(id)sender
{
    [self displayImagePicker];
}

- (IBAction)followButtonClicked:(id)sender
{
    [_followButton startActivityIndicator];
    [self addUserFollows:_displayedUserEntry.m_userProfile];
}

- (IBAction)followingButtonClicked:(id)sender
{
    [_followingButton startActivityIndicator];
    [self removeUserFollows:_displayedUserEntry.m_userProfile];
}

- (IBAction)feedSelectorChanged:(id)sender
{
    UserEntry *entry = [g_userController getUserEntry:_displayedUserId];
    
    if ( _feedSelector.selectedIndex == 0 && entry.m_sessionsListCurrentPage > 0 && [entry.m_sessionsList count] > 5 )
    {
        [_feedTable enablePagination];
    }
    else
    {
        [_feedTable disablePagination];
    }
    
    [_feedTable reloadData];
}

- (IBAction)fullscreenButtonClicked:(id)sender
{
    
    [_searchBar minimizeKeyboard];
    //[_fullscreenButton setHidden:YES];
}

#pragma mark - Helpers

- (NSAttributedString *)createAttributedStringWithInteger:(NSInteger)num andText:(NSString *)text
{
    NSString *numString = [NSString stringWithFormat:@"%d",num];
    NSString *string = [NSString stringWithFormat:@"%@\n%@",numString,text];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    UIFont *fontSmall = [UIFont systemFontOfSize:11.0];
    UIFont *fontBig = [UIFont systemFontOfSize:17.0];
    
    [attributedString addAttribute:NSFontAttributeName value:fontBig range:NSMakeRange(0,[numString length])];
    [attributedString addAttribute:NSFontAttributeName value:fontSmall range:NSMakeRange([numString length]+1,[text length])];
    
    return attributedString;
}

- (void)displayAndUpdateUserId:(NSInteger)userId
{
    [self displayUserId:userId];
    [self requestUserId:userId];
}

- (void)displayUserId:(NSInteger)userId
{
    _displayedUserId = userId;
    
    [self refreshDisplayedUser];
}

- (void)requestUserId:(NSInteger)userId
{
    _requestsInFlight += 4;
    [_feedTable startAnimating];

    [g_userController requestUserProfile:userId andCallbackObj:self andCallbackSel:@selector(userProfileCallback:)];
    [g_userController requestUserSessions:userId andPage:1 andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];
    [g_userController requestUserFollows:userId andCallbackObj:self andCallbackSel:@selector(userFollowingCallback:)];
    [g_userController requestUserFollowedBy:userId andCallbackObj:self andCallbackSel:@selector(userFollowersCallback:)];
}

-(void)refreshDisplayedUser
{
    // Refresh the current user entry, now that we have new stuff
    UserEntry *loggedInEntry = [g_userController getUserEntry:0];
    
    _displayedUserEntry = [g_userController getUserEntry:_displayedUserId];
    
    [_userNameLabel setText:_displayedUserEntry.m_userProfile.m_name];
    
    // Ensure this is the logged in user not the user displayed
    [_profileLabel setText:loggedInEntry.m_userProfile.m_name];
    
    UIImage *image = [g_fileController getFileOrReturnNil:_displayedUserEntry.m_userProfile.m_imgFileId];
    
    // Nil is ok
    [_picImageView setImage:image];
    
    [self updateHeaders];
    
    // Is this the user
    if ( _displayedUserId == 0 || _displayedUserId == loggedInEntry.m_userProfile.m_userId )
    {
        [_followingButton setHidden:YES];
        [_followButton setHidden:YES];
        [_profileButton setImage:image forState:UIControlStateNormal];
    }
    else if ( _displayedUserEntry == nil )
    {
        [_followingButton setHidden:YES];
        [_followButton setHidden:YES];
    }
    else if ( [g_userController checkLoggedInUserFollows:_displayedUserEntry.m_userProfile] == YES )
    {
        [_followingButton setHidden:NO];
        [_followButton setHidden:YES];
    }
    else
    {
        [_followingButton setHidden:YES];
        [_followButton setHidden:NO];
    }
    
    if ( _feedSelector.selectedIndex == 0 && _displayedUserEntry.m_sessionsListCurrentPage > 0 && [_displayedUserEntry.m_sessionsList count] > 5 )
    {
        [_feedTable enablePagination];
    }
    else
    {
        [_feedTable disablePagination];
    }

    [_feedTable reloadData];
}

-(void)updateHeaders
{
    NSAttributedString *attributedString1 = [self createAttributedStringWithInteger:[_displayedUserEntry.m_sessionsList count] andText:NSLocalizedString(@"SESSIONS", NULL)];
    NSAttributedString *attributedString2 = [self createAttributedStringWithInteger:[_displayedUserEntry.m_followedByList count] andText:NSLocalizedString(@"FOLLOWERS", NULL)];
    NSAttributedString *attributedString3 = [self createAttributedStringWithInteger:[_displayedUserEntry.m_followsList count] andText:NSLocalizedString(@"FOLLOWING", NULL)];
    
    [_feedSelector setTitles:[NSArray arrayWithObjects:attributedString1, attributedString2, attributedString3, nil]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView == _searchTable )
    {
        return [_userProfileSearchResults count];
    }
	else if ( _feedSelector.selectedIndex == 0 )
    {
        return [_displayedUserEntry.m_sessionsList count];
    }
	else if ( _feedSelector.selectedIndex == 1 )
    {
        return [_displayedUserEntry.m_followedByList count];
    }
    else
    {
        return [_displayedUserEntry.m_followsList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    if([tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    NSInteger row = [indexPath row];
    
    if ( tableView == _feedTable )
    {
        return [self cellForFeedTable:row];
    }
    
    if ( tableView == _searchTable )
    {
        return [self cellForSearchTable:row];
    }
    
    return nil;
}

- (UITableViewCell *)cellForFeedTable:(NSInteger)row
{
    if ( _feedSelector.selectedIndex == 0 )
    {
        static NSString * CellIdentifier = @"SocialSongCell";
        SocialSongCell *tempCell = [_feedTable dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (tempCell == NULL)
        {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"SocialSongCell" owner:nil options:nil];
            for (UIView *view in views)
                if([view isKindOfClass:[UITableViewCell class]])
                    tempCell = (SocialSongCell*)view;
            
            CGFloat cellHeight = _feedTable.rowHeight;
            CGFloat cellRow = _feedTable.frame.size.width;
            
            // Readjust the width and height
            [tempCell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
            [tempCell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        }
        
        if ( row < [_displayedUserEntry.m_sessionsList count] )
            tempCell.userSongSession = [_displayedUserEntry.m_sessionsList objectAtIndex:row];
        else
            tempCell.userSongSession = nil;
        
        [tempCell updateCell];
        
        if([tempCell respondsToSelector:@selector(setLayoutMargins:)]){
            tempCell.layoutMargins = UIEdgeInsetsZero;
        }
        
        return tempCell;
    }
	else
    {
        SocialUserCell *cell = [self getSocialUserCell:_feedTable];
        
        if ( _feedSelector.selectedIndex == 1 )
        {
            if ( row < [_displayedUserEntry.m_followedByList count] )
            {
                cell.userProfile = [_displayedUserEntry.m_followedByList objectAtIndex:row];
            }
            else
            {
                cell.userProfile = nil;
            }
        }
        else if ( _feedSelector.selectedIndex == 2 )
        {
            if ( row < [_displayedUserEntry.m_followsList count] )
            {
                cell.userProfile = [_displayedUserEntry.m_followsList objectAtIndex:row];
            }
            else
            {
                cell.userProfile = nil;
            }
        }
        else
        {
            cell.userProfile = nil;
        }
        
        cell.following = [g_userController checkLoggedInUserFollows:cell.userProfile];
        cell.isUser = cell.userProfile.m_userId == g_userController.m_loggedInUserProfile.m_userId;
        
        [cell updateCell];
        
        if([cell respondsToSelector:@selector(setLayoutMargins:)]){
            cell.layoutMargins = UIEdgeInsetsZero;
        }
        
        return cell;
    }
}

- (UITableViewCell *)cellForSearchTable:(NSInteger)row
{
    
    SocialUserCell *cell = [self getSocialUserCell:_searchTable];
    
    if ( row < [_userProfileSearchResults count] )
    {
        cell.userProfile = [_userProfileSearchResults objectAtIndex:row];
    }
    else
    {
        cell.userProfile = nil;
    }
    
    cell.following = [g_userController checkLoggedInUserFollows:cell.userProfile];
    cell.isUser = cell.userProfile.m_userId == g_userController.m_loggedInUserProfile.m_userId;
    
    [cell updateCell];
    
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (SocialUserCell *)getSocialUserCell:(UITableView *)table
{
    static NSString * CellIdentifier = @"SocialUserCell";
	SocialUserCell *tempCell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (tempCell == NULL)
	{
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"SocialUserCell" owner:nil options:nil];
        for (UIView *view in views)
            if([view isKindOfClass:[UITableViewCell class]])
                tempCell = (SocialUserCell*)view;
        
        CGFloat cellHeight = table.rowHeight;
        CGFloat cellRow = table.frame.size.width;
        
        // Readjust the width and height
        [tempCell setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        [tempCell.accessoryView setFrame:CGRectMake(0, 0, cellRow, cellHeight)];
        
        
        // TODO: fix this
        NSMethodSignature *signature = [SocialViewController instanceMethodSignatureForSelector:@selector(socialUserFollowInvocation:)];
        
        tempCell.followInvocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [tempCell.followInvocation setTarget:self];
        [tempCell.followInvocation setSelector:@selector(socialUserFollowInvocation:)];
        [tempCell.followInvocation setArgument:&tempCell atIndex:2];

    }
    
    //[tempCell updateCell];
    
    if([tempCell respondsToSelector:@selector(setLayoutMargins:)]){
        tempCell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return tempCell;
}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	NSInteger row = [indexPath row];
    
    if ( tableView == _searchTable )
    {
        SocialUserCell *cell = (SocialUserCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [self displayAndUpdateUserId:cell.userProfile.m_userId];
        [_searchBar endSearch];
    }
    else if ( _feedSelector.selectedIndex == 0 )
    {
        // Pop up modal and play the song
        SocialSongCell *cell = (SocialSongCell *)[tableView cellForRowAtIndexPath:indexPath];
        UserSongSession *session = cell.userSongSession;
        
        _sessionViewController.userSongSession = session;
        
        
        [_sessionViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
        [self presentViewController:_sessionViewController animated:NO completion:^{
//            [cell.activityView stopAnimating];
        }];
    }
    else if ( _feedSelector.selectedIndex == 1 )
    {
        SocialUserCell *cell = (SocialUserCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [self displayAndUpdateUserId:cell.userProfile.m_userId];
    }
    else if ( _feedSelector.selectedIndex == 2 )
    {
        SocialUserCell *cell = (SocialUserCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [self displayAndUpdateUserId:cell.userProfile.m_userId];
    }
}

#pragma mark - UserController callbacks

- (void)userProfileCallback:(UserResponse*)userResponse
{
    _requestsInFlight--;
    
    if ( _requestsInFlight == 0 )
    {
        [_feedTable stopAnimating];
    }
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self refreshDisplayedUser];
        
        UserEntry *entry = [g_userController getUserEntry:_displayedUserId];
        
        if(entry.m_sessionsList == nil){
            [g_userController requestUserSessions:_displayedUserId andPage:1 andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];
        }
        
        if(entry.m_followsList == nil){
            
        }
        
        if(entry.m_followedByList == nil){
            
        }
        
        [g_fileController getFileOrDownloadAsync:entry.m_userProfile.m_imgFileId callbackObject:self callbackSelector:@selector(profilePicDownloaded:)];
    }
    else
    {
        if ( _alertView == nil )
        {
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                     message:userResponse.m_statusText
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                           otherButtonTitles:nil];
            [_alertView show];
        }
    }
    
}

- (void)userSessionsCallback:(UserResponse*)userResponse
{
    if ( _requestsInFlight > 0 )
    {
        _requestsInFlight--;
        
        if ( _requestsInFlight == 0 )
        {
            [_feedTable stopAnimating];
        }
    }
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self refreshDisplayedUser];
        
    }
    else
    {
        [_feedTable disablePagination];
        
        if ( _alertView == nil )
        {
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                     message:userResponse.m_statusText
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                           otherButtonTitles:nil];
            [_alertView show];
        }
    }
}

- (void)userFollowersCallback:(UserResponse*)userResponse
{
    _requestsInFlight--;
    
    if ( _requestsInFlight == 0 )
    {
        [_feedTable stopAnimating];
    }
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self refreshDisplayedUser];
    }
    else
    {
        if ( _alertView == nil )
        {
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                     message:userResponse.m_statusText
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                           otherButtonTitles:nil];
            [_alertView show];
        }
    }
}

- (void)userFollowingCallback:(UserResponse*)userResponse
{
    _requestsInFlight--;
    
    if ( _requestsInFlight == 0 )
    {
        [_feedTable stopAnimating];
    }
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self refreshDisplayedUser];
    }
    else
    {
        if ( _alertView == nil )
        {
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                     message:userResponse.m_statusText
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                           otherButtonTitles:nil];
            [_alertView show];
        }
    }
}

- (void)changeFollowingCallback:(UserResponse *)userResponse
{
    [_followButton stopActivityIndicator];
    [_followingButton stopActivityIndicator];
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self refreshDisplayedUser];
        
        // We need to reload the search table too if it is visible
        if ( _searchTable.hidden == NO )
        {
            [_searchTable reloadData];
        }
    }
    else
    {
        if ( _alertView == nil )
        {
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                     message:userResponse.m_statusText
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                           otherButtonTitles:nil];
            [_alertView show];
        }
    }
}

- (void)userProfileSearchCallback:(UserResponse*)userResponse
{
    [_searchBar stopActivityAnimation];
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        
        _userProfileSearchResults = userResponse.m_searchResults;
        
        // pull down all the images -- this takes too long
//        for ( UserProfile *userProfile in _userProfileSearchResults )
//        {
//            [g_fileController precacheFile:userProfile.m_imgFileId];
//        }
        
        [_searchTable reloadData];
    }
    else
    {
        if ( _alertView == nil )
        {
            _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", NULL)
                                                     message:userResponse.m_statusText
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                           otherButtonTitles:nil];
            [_alertView show];
        }
    }
}

#pragma mark - Image Picker

- (void)displayImagePicker
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    
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
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


#pragma mark -
#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    
    UIImage * pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
//    UIImageOrientation orientation = pickedImage.imageOrientation;
    
    CGSize newSize = pickedImage.size;
    
    // Cap the size at something reasonable -- 500x500 is a good size.
    if ( newSize.height >  500.0f )
    {
        newSize.width = (500.0f / newSize.height) * newSize.width;
        newSize.height = 500.0f;
    }
    if ( newSize.width >  500.0f )
    {
        newSize.height = (500.0f / newSize.width) * newSize.height;
        newSize.width = 500.0f;
    }
    
    UIGraphicsBeginImageContext( newSize );
    
    // Resizing the image implicitly re-orients
    
    [pickedImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage * editedImage =  UIGraphicsGetImageFromCurrentImageContext();
    
    [self uploadProfilePic:editedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Ensure the status bar is hidden
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Ensure the status bar is hidden
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

//#pragma mark - UINavigationControllerDelegate
//
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    
//    
//}
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    
//    
//}

#pragma mark - ExpandedSearchBarDelegate

- (void)searchBarDidBeginEditing:(ExpandableSearchBar *)searchBar
{
    
    // Show the table view
    [_searchTable setHidden:NO];
    //[_fullscreenButton setHidden:NO];
    
    // I appologize for this ugly hack, i.e. passing a bool as a pointer (numberWithBool != NO)
    // but it isn't worth the time doing it the proper way.
//    [_profileButton setHidden:YES];
    [_profileButton performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.2];
    [_profileLabel performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.2];
}

- (void)searchBarSearch:(ExpandableSearchBar *)searchBar
{
    // Execute a search
    [self searchForString:searchBar.searchString];
    [searchBar startActivityAnimation];
}

- (void)searchBarCancel:(ExpandableSearchBar *)searchBar
{
    // Remove the table view
    [_searchTable setHidden:YES];
    //[_fullscreenButton setHidden:YES];
    [_profileButton performSelector:@selector(setHidden:) withObject:nil afterDelay:0.1];
    [_profileLabel performSelector:@selector(setHidden:) withObject:nil afterDelay:0.1];
}

#pragma mark - PullToUpdate

- (void)updateTable
{
    [self requestUserId:_displayedUserId];
}

- (void)nextPage
{
    UserEntry *entry = [g_userController getUserEntry:_displayedUserId];

    [g_userController requestUserSessions:entry.m_userProfile.m_userId andPage:(entry.m_sessionsListCurrentPage+1) andCallbackObj:self andCallbackSel:@selector(userSessionsCallback:)];
}

#pragma mark - UIAlertViewDelegate

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _alertView = nil;
}

#pragma mark - Misc

- (void)uploadProfilePic:(UIImage*)image
{
    [g_userController requestUserProfileChangePicture:image andCallbackObj:self andCallbackSel:@selector(userProfileCallback:)];
}

- (void)profilePicDownloaded:(id)file
{
    // Now that the download is done, refresh the display and thereby show the new pic.
    [self refreshDisplayedUser];
}

- (void)searchForString:(NSString*)searchString
{
    [g_userController requestUserProfileSearch:searchString andCallbackObj:self andCallbackSel:@selector(userProfileSearchCallback:)];
}

- (void)addUserFollows:(UserProfile*)userProfile
{
    [g_userController requestAddUserFollow:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(changeFollowingCallback:)];
}

- (void)removeUserFollows:(UserProfile*)userProfile
{
    [g_userController requestRemoveUserFollow:userProfile.m_userId andCallbackObj:self andCallbackSel:@selector(changeFollowingCallback:)];
}

- (void)socialUserFollowInvocation:(SocialUserCell *)cell
{
    if ( cell.following == YES )
    {
        [self removeUserFollows:cell.userProfile];
    }
    else
    {
        [self addUserFollows:cell.userProfile];
    }
}

@end