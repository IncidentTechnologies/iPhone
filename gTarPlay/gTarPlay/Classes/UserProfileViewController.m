//
//  UserProfileViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/13/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserProfileNavigationController.h"

#import "UserProfileFriendCell.h"
#import "UserProfileSessionCell.h"
#import "CustomSegmentedControl.h"

#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserController.h>

extern FileController * g_fileController;
extern UserController * g_userController;

@implementation UserProfileViewController

@synthesize m_nameLabel;
@synthesize m_statusLabel;
@synthesize m_profileTextView;
@synthesize m_profileImageView;
@synthesize m_controlsView;
@synthesize m_tableView;
@synthesize m_feedSegmentedButton;
//@synthesize m_activityIndicatorView;
@synthesize m_addFriendButton;
@synthesize m_removeFriendButton;
@synthesize m_logoutButton;
@synthesize m_changePicButton;
@synthesize m_displayedUserProfile;
@synthesize m_userProfile;
@synthesize m_userFriendList;
//@synthesize m_userEntry;
//@synthesize m_userEntryDisplayed;
//@synthesize m_userEntryToDisplay;
@synthesize m_displayedSessionsArray;
@synthesize m_displayedFollowsArray;
@synthesize m_displayedFollowedArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
//        m_updatingSessions = YES;
//        m_updatingFollows = YES;
//        m_updatingFollowers = YES;
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_nameLabel release];
    [m_statusLabel release];
    [m_profileTextView release];
    [m_profileImageView release];
    [m_controlsView release];
    [m_tableView release];
    [m_feedSegmentedButton release];
//    [m_activityIndicatorView release];
    [m_addFriendButton release];
    [m_removeFriendButton release];
    [m_logoutButton release];
    [m_changePicButton release];
    [m_userProfile release];
    [m_displayedUserProfile release];
    [m_userFriendList release];
//    [m_userEntry release];
//    [m_userEntryDisplayed release];
//    [m_userEntryToDisplay release];
    [m_displayedFollowedArray release];
    [m_displayedFollowsArray release];
    [m_displayedSessionsArray release];
    
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
    
    [m_feedSegmentedButton changeTitles:[NSArray arrayWithObjects:@"Sessions", @"Following", @"Followers", nil]];
    
//    [m_activityIndicatorView startAnimating];
    
    [self refreshRelationship];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_nameLabel = nil;
    self.m_statusLabel = nil;
    self.m_profileTextView = nil;
    self.m_profileImageView = nil;
    self.m_controlsView = nil;
    self.m_tableView = nil;
    self.m_feedSegmentedButton = nil;
//    self.m_activityIndicatorView = nil;
    self.m_addFriendButton = nil;
    self.m_removeFriendButton = nil;
    self.m_logoutButton = nil;
    self.m_changePicButton = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
//    [self refreshTable];
    [self refreshRelationship];
    
    [m_tableView reloadData];
    
    [super viewWillAppear:animated];
    
}

#pragma mark - Misc

- (IBAction)feedSelectionChanged:(id)sender
{
    [m_tableView reloadData];
}

- (IBAction)addFriendButtonClicked:(id)sender
{
    [self addUserFollows:m_displayedUserProfile];
}

- (IBAction)removeFriendButtonClicked:(id)sender
{
    [self removeUserFollows:m_displayedUserProfile];
}

- (IBAction)logoutButtonClicked:(id)sender
{
    [(UserProfileNavigationController*)m_navigationController logoutUser];
}

- (IBAction)changePicButtonClicked:(id)sender
{
    [(UserProfileNavigationController*)m_navigationController changeProfilePicturePopup];
}

- (void)clearTable
{
    
    [m_feedSegmentedButton setSelectedIndex:0];
    
    self.m_displayedSessionsArray = nil;
    self.m_displayedFollowsArray = nil;
    self.m_displayedFollowedArray = nil;
    
    // this just empties out the table with the nil data
    [m_tableView reloadData];
    [m_tableView stopAnimating];
    
}

- (void)refreshTable
{
    
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 0 )
    {
        if ( m_updatingSessions == YES )
        {
            [m_tableView startAnimating];
        }
        else
        {
            [m_tableView stopAnimating];
        }
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 1 )
    {
        if ( m_updatingFollowing == YES )
        {
            [m_tableView startAnimating];
        }
        else
        {
            [m_tableView stopAnimating];
        }
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 2 )
    {
        if ( m_updatingFollowers == YES )
        {
            [m_tableView startAnimating];
        }
        else
        {
            [m_tableView stopAnimating];
        }
    }
    
    [m_tableView reloadData];
    
}

- (void)refreshRelationship
{
    
    // make the image view taller if need be
    UIImage * pic = [g_fileController getFileOrDownloadSync:m_displayedUserProfile.m_imgFileId];
    
    if ( pic != nil )
    {
        
//        CGRect fr = m_profileImageView.frame;
//        
//        fr.size.height = pic.size.height / pic.size.width * fr.size.width;
//        
//        if ( fr.size.height > 200 )
//        {
//            // need to cap it at something
//            fr.size.height = 200;
//        }
//        
//        [m_profileImageView setFrame:fr];
//        [m_changePicButton setFrame:fr];
//        
//        CGRect fr2 = m_controlsView.frame;
//        fr2.origin.y = fr.origin.y + fr.size.height + 4;
//        [m_controlsView setFrame:fr2];
        
        UIImage * image = [g_fileController getFileOrDownloadSync:m_displayedUserProfile.m_imgFileId];
        
        [m_nameLabel setText:m_displayedUserProfile.m_name];
        [m_profileTextView setText:m_displayedUserProfile.m_profileText];
        [m_profileImageView setImage:image];
        
    }
    
    // don't use this for now
    [m_statusLabel setHidden:YES];
    
    if ( m_displayedUserProfile.m_userId == m_userProfile.m_userId )
    {
        //
        // This is the user
        //
        [m_addFriendButton setHidden:YES];
        [m_removeFriendButton setHidden:YES];
        [m_logoutButton setHidden:NO];
//        [m_statusLabel setHidden:NO];
        
        // Only let them change prof pic if not facebook
        if ( g_userController.m_loggedInFacebookToken == nil )
        {
            [m_changePicButton setHidden:NO];
        }
    }
    else if ( [m_userFriendList containsObject:m_displayedUserProfile] == YES )
    {
        //
        // This is the user's friend
        //
        [m_addFriendButton setHidden:YES];
        [m_removeFriendButton setHidden:NO];
        [m_logoutButton setHidden:YES];
        [m_statusLabel setHidden:YES];
        [m_changePicButton setHidden:YES];
    }
    else if ( m_userFriendList != nil )
    {
        //
        // They are not friends
        //
        [m_addFriendButton setHidden:NO];
        [m_removeFriendButton setHidden:YES];
        [m_logoutButton setHidden:YES];
        [m_statusLabel setHidden:YES];
        [m_changePicButton setHidden:YES];
    }
    else
    {
        //
        // Who is this guy?
        // When in doubt, hide everything
        //
        [m_addFriendButton setHidden:YES];
        [m_removeFriendButton setHidden:YES];
        [m_logoutButton setHidden:YES];
        [m_statusLabel setHidden:YES];
        [m_changePicButton setHidden:YES];
    }
    
}

- (void)refreshSessions
{
    
    m_updatingSessions = NO;
    
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 0 )
    {
        [m_tableView stopAnimating];
        [m_tableView reloadData];
    }
    
}

- (void)refreshFollowing
{
    
    m_updatingFollowing = NO;
    
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 1 )
    {
        [m_tableView stopAnimating];
        [m_tableView reloadData];
    }
    
}

- (void)refreshFollowers
{
    
    m_updatingFollowers = NO;
    
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 2)
    {
        [m_tableView stopAnimating];
        [m_tableView reloadData];
    }
    
}

- (void)addUserFollows:(UserProfile*)userProfile
{
    [(UserProfileViewController*)m_navigationController addUserFollows:userProfile];
}

- (void)removeUserFollows:(UserProfile*)userProfile
{
    [(UserProfileViewController*)m_navigationController removeUserFollows:userProfile];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
    
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 0 )
    {
        
        return [m_displayedSessionsArray count];
        
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 1 )
    {
        
        return [m_displayedFollowsArray count];
        
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 2 )
    {
        
        return [m_displayedFollowedArray count];
        
    }
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = [indexPath row];
    
    NSInteger selectedSegment = m_feedSegmentedButton.m_selectedSegmentIndex;
    
    if ( selectedSegment == 0 )
    {
        
        static NSString * CellIdentifier = @"UserProfileSessionCell";
        
        UserProfileSessionCell * cell = (UserProfileSessionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            cell = [[[UserProfileSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"UserProfileSessionCell" owner:cell options:nil];
            
        }
        
        cell.m_userSongSession = [m_displayedSessionsArray objectAtIndex:row];
        
        [cell updateCell];
        
        return cell;
        
    }
    else if ( selectedSegment == 1 )
    {
        
        static NSString * CellIdentifier = @"UserProfileFriendCell";
        
        UserProfileFriendCell * cell = (UserProfileFriendCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            cell = [[[UserProfileFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"UserProfileFriendCell" owner:cell options:nil];
            
            cell.m_parent = self;
            
        }
        
        cell.m_userProfile = [m_displayedFollowsArray objectAtIndex:row];
        
        if ( cell.m_userProfile.m_userId == m_userProfile.m_userId )
        {
            cell.m_isSelf = YES;
        }
        else
        {
            cell.m_isSelf = NO;
            cell.m_areFriends = [m_userFriendList containsObject:cell.m_userProfile];
        }
        
        [cell updateCell];
        
        return cell;
        
    }
    else if ( selectedSegment == 2 )
    {
        
        static NSString * CellIdentifier = @"UserProfileFriendCell";
        
        UserProfileFriendCell * cell = (UserProfileFriendCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            
            cell = [[[UserProfileFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            [[NSBundle mainBundle] loadNibNamed:@"UserProfileFriendCell" owner:cell options:nil];
            
            cell.m_parent = self;
            
        }
        
        cell.m_userProfile = [m_displayedFollowedArray objectAtIndex:row];
        
        if ( cell.m_userProfile.m_userId == m_userProfile.m_userId )
        {
            cell.m_isSelf = YES;
        }
        else
        {
            cell.m_isSelf = NO;
            cell.m_areFriends = [m_userFriendList containsObject:cell.m_userProfile];
        }
        
        [cell updateCell];
        
        return cell;
        
    }
    
    return nil;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // +1 for the separator
    NSInteger selectedSegment = m_feedSegmentedButton.m_selectedSegmentIndex;
    
    if ( selectedSegment == 0 )
    {
        return [UserProfileSessionCell cellHeight] + 1;
    }
    else if ( selectedSegment == 1 || selectedSegment == 2 )
    {
        return [UserProfileFriendCell cellHeight] + 1;
    }
    
    // there won't be any others though
    return 44.0f;
    
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
	NSInteger row = [indexPath row];
	
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 0 )
    {
        
        if ( [m_displayedSessionsArray count] > row )
        {
            
            UserSongSession * userSongSession = [m_displayedSessionsArray objectAtIndex:row];
            
            [(UserProfileNavigationController*)m_navigationController playUserSongSession:userSongSession];
            
        }
        
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 1 )
    {
        
        if ( [m_displayedFollowsArray count] > row )
        {
            
            UserProfile * userProfile = [m_displayedFollowsArray objectAtIndex:row];
            
            [(UserProfileNavigationController*)m_navigationController getAndDisplayUserProfile:userProfile];
            
        }
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 2 )
    {
        
        if ( [m_displayedFollowedArray count] > row )
        {
            
            UserProfile * userProfile = [m_displayedFollowedArray objectAtIndex:row];
            
            [(UserProfileNavigationController*)m_navigationController getAndDisplayUserProfile:userProfile];
            
        }
        
    }
    
}

- (void)updatingEverything
{
    
    [m_tableView startAnimating];
    
    m_updatingSessions = YES;
    m_updatingFollowing = YES;
    m_updatingFollowers = YES;
    
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
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
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
    
    [m_navigationController presentModalViewController:picker animated:YES];
    
    [picker release];
}

- (UIImage*)captureView:(UIView*)view
{
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect screenRect = view.bounds;
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark -
#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
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

#pragma mark - PullToUpdateTableView

- (void)update
{
    
    [m_tableView startAnimating];
    
    if ( m_feedSegmentedButton.m_selectedSegmentIndex == 0 )
    {
        [(UserProfileNavigationController*)m_navigationController updateSessions];
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 1 )
    {
        [(UserProfileNavigationController*)m_navigationController updateUserFollowing];
    }
    else if ( m_feedSegmentedButton.m_selectedSegmentIndex == 2 )
    {
        [(UserProfileNavigationController*)m_navigationController updateUserFollowers];
    }
    
}

@end
