//
//  TitleNavigationController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import <gTarAppCore/CloudController.h>
#import <gTarAppCore/FileController.h>
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>
#import <gTarAppCore/UserEntry.h>
#import <gTarAppCore/TelemetryController.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserSongSessions.h>
#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/CloudResponse.h>

#import "TitleNavigationController.h"
#import "SongSelectionViewController.h"
#import "SocialViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"
#import "UIView+Gtar.h"

#import "ActivityFeedCell.h"
#import "UserCommentCell.h"
#import "SelectorControl.h"
#import "CyclingTextField.h"
#import "SessionModalViewController.h"
#import "FirmwareModalViewController.h"
#import "PlayerViewController.h"
#import "FreePlayController.h"

extern CloudController * g_cloudController;
extern FileController * g_fileController;
extern GtarController * g_gtarController;
extern UserController * g_userController;
extern Facebook * g_facebook;
extern TelemetryController * g_telemetryController;

#define NOTIFICATION_GATEKEEPER_SIGNIN @"Please connect your gTar to sign up for an account."
#define SIGNUP_USERNAME_INVALID @"Invalid Username"
#define SIGNUP_USERNAME_INVALID_FIRSTLETTER @"Username must begin with a letter"
#define SIGNUP_PASSWORD_INVALID @"Invalid Password"
#define SIGNUP_PASSWORD_INVALID_LENGTH @"Password must be at least 8 letters"
#define SIGNUP_EMAIL_INVALID @"Invalid Email"
#define SIGNIN_USERNAME_INVALID @"Invalid Username"
#define SIGNIN_PASSWORD_INVALID @"Invalid Password"
#define FACEBOOK_INVALID @"Facebook failed to login"

#define FACEBOOK_CLIENT_ID @"285410511522607"
#define FACEBOOK_PERMISSIONS [NSArray arrayWithObjects:@"email", nil]

@interface TitleNavigationController ()
{
    SessionModalViewController *_sessionViewController;
    FirmwareModalViewController *_firmwareViewController;
    
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
    
    UIButton *_fullScreenButton;
    
    NSTimer *_textFieldSliderTimer;
    
    MPMoviePlayerController *_moviePlayer;
    
    NSArray *_globalFeed;
    NSArray *_friendFeed;
    
    NSInteger _outstandingImageDownloads;
    
    BOOL _refreshingGlobalFeed;
    BOOL _refreshingFriendFeed;
    
    BOOL _displayingCell;
    BOOL _waitingForFacebook;
    
    NSInteger _firmwareFileId;
}
@end

@implementation TitleNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    g_facebook = [[Facebook alloc] initWithAppId:FACEBOOK_CLIENT_ID andDelegate:self];
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // See if there are any cached credentials
    if ( [settings objectForKey:@"FBAccessTokenKey"] && [settings objectForKey:@"FBExpirationDateKey"] )
    {
        g_facebook.accessToken = [settings objectForKey:@"FBAccessTokenKey"];
        g_facebook.expirationDate = [settings objectForKey:@"FBExpirationDateKey"];
    }
    
    // Add shadows
    [_topBarView addShadow];
    [_gtarLogoImage addShadow];
    [_loggedoutSigninButton addShadow];
    [_loggedoutSignupButton addShadow];
    [_gatekeeperVideoButton addShadow];
    [_gatekeeperSigninButton addShadow];
    [_menuPlayButton addShadow];
    [_menuFreePlayButton addShadow];
    [_menuStoreButton addShadow];
    
    // Hide anything that needs hiding
    [[_profileButton superview] setHidden:YES];
    [_profileButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    // Set up the modals
    _sessionViewController = [[SessionModalViewController alloc] initWithNibName:nil bundle:nil];
    _firmwareViewController = [[FirmwareModalViewController alloc] initWithNibName:nil bundle:nil];
    
    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:@"FRIENDS", @"GLOBAL", nil]];
    
    // Setup the feed's initial state
    UserEntry * entry = [g_userController getUserEntry:0];
    
    if ( [entry.m_followsSessionsList count] > 0 )
    {
        [_friendFeed release];
        
        _friendFeed = [entry.m_followsSessionsList retain];
        
        // If the newest session is greater that 1 week ago, show the global feed
        UserSongSession * recentSession = [_friendFeed objectAtIndex:0];
        
        NSTimeInterval recentSessionTime = recentSession.m_created;
        
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        
        // 1 week of seconds = 7days 24h 60min 60sec
        if ( (now - recentSessionTime) > (7*24*60*60) )
        {
            [_feedSelectorControl setSelectedIndex:1];
        }
    }
    else
    {
        // Default to the global feed when there is no personal content
        [_feedSelectorControl setSelectedIndex:1];
    }
    
    [self hideNotification];

    // Assume we are logged in at first, since this will be the common case
    [self swapLeftPanel:_menuLeftPanel];
    [self swapRightPanel:_feedRightPanel];
    
    // Now connect to the device
    [g_gtarController addObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    _displayingCell = NO;
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    if ( g_cloudController.m_loggedIn == NO &&
        (g_userController.m_loggedInFacebookToken != nil ||
         g_userController.m_loggedInUsername != nil) )
    {
        // If we are not logged in, but we have cached creds, login.
        [g_userController requestLoginUserCachedCallbackObj:self andCallbackSel:@selector(signinCallback:)];
        
        // Assume for now that we are actually logged in for now. The callback can revert this if needed
        [self loggedinScreen];
        
    }
    else if ( guitarConnectedBefore == NO )
    {
        // We aren't logged in, and never plugged in a guitar. Display the gatekeeping view.
        [self gatekeeperScreen];
    }
    else if ( g_cloudController.m_loggedIn == NO )
    {
        // We aren't logged out
        [self loggedoutScreen];
    }
    else
    {
        if ( g_gtarController.connected == NO )
        {
            [self swapLeftPanel:_disconnectedGtarLeftPanel];
        }
        
        // We are logged in
        [g_userController sendPendingUploads];
        
        [self updateGlobalFeed];
        [self updateFriendFeed];
        
        [_feedTable startAnimatingOffscreen];
    }
    
    UserEntry *loggedInEntry = [g_userController getUserEntry:0];
    UIImage *image = [g_fileController getFileOrReturnNil:loggedInEntry.m_userProfile.m_imgFileId];
    
    if ( image != nil )
    {
        [_profileButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_currentLeftPanel setFrame:_leftPanel.bounds];
    [_currentRightPanel setFrame:_rightPanel.bounds];

}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_currentLeftPanel removeFromSuperview];
    [_currentRightPanel removeFromSuperview];
    [_fullScreenButton removeFromSuperview];
    
    [_globalFeed release];
    [_friendFeed release];
    
    [_rightPanel release];
    [_leftPanel release];
    [_loggedoutLeftPanel release];
    [_signupRightPanel release];

    [_loggedoutSignupButton release];
    [_loggedoutSigninButton release];
    [_signinRightPanel release];
    [_gtarLogoImage release];
    
    [_topBarView release];
    [_gatekeeperVideoButton release];
    [_gatekeeperSigninButton release];

    [_gatekeeperLeftPanel release];
    [_videoRightPanel release];
    
    [_menuPlayButton release];
    [_menuFreePlayButton release];
    [_menuStoreButton release];
    [_menuLeftPanel release];
    [_feedRightPanel release];
    [_feedTable release];
    [_feedSelectorControl release];
    
    [_gatekeeperWebsiteButton release];
    [_notificationLabel release];
    
    [_loadingRightPanel release];
    [_signinUsernameText release];
    [_signinPasswordText release];
    [_signupUsernameText release];
    [_signupPasswordText release];
    [_signupEmailText release];
    [_delayLoadingView release];
    [_disconnectedGtarLeftPanel release];
    [_videoPreviewImage release];
    [_sessionViewController release];
    [_profileButton release];
    
    [g_facebook release];
    
    g_facebook = nil;

    [super dealloc];
}

#pragma mark - Notification management

// This changes the top bar notification
- (void)displayNotification:(NSString *)notification turnRed:(BOOL)red
{
    [_notificationLabel setText:notification];
    [_notificationLabel.superview setHidden:NO];
    
    if ( red )
    {
        _topBarView.backgroundColor = [UIColor redColor];
    }
    else
    {
        _topBarView.backgroundColor = [UIColor colorWithRed:2.0/256.0 green:160.0/256.0 blue:220.0/256.0 alpha:1.0];
    }
}

- (void)hideNotification
{
    [_notificationLabel.superview setHidden:YES];
    
    _topBarView.backgroundColor = [UIColor colorWithRed:2.0/256.0 green:160.0/256.0 blue:220.0/256.0 alpha:1.0];
}

#pragma mark - Button management

- (void)enableButton:(UIButton *)button
{
    button.backgroundColor = [UIColor colorWithRed:2.0/256.0 green:160.0/256.0 blue:220.0/256.0 alpha:1.0];
    
    [button setEnabled:YES];
}

- (void)disableButton:(UIButton *)button
{
    button.backgroundColor = [UIColor colorWithRed:2.0/256.0/2.0 green:160.0/256.0/2.0 blue:220.0/256.0/2.0 alpha:1.0];
    
    [button setEnabled:NO];
}

#pragma mark - Panel collections

- (void)gatekeeperScreen
{
    [self swapLeftPanel:_gatekeeperLeftPanel];
    [self swapRightPanel:_videoRightPanel];
    
    [self disableButton:_gatekeeperVideoButton];
    [self enableButton:_gatekeeperSigninButton];
    [self enableButton:_gatekeeperWebsiteButton];
    [self hideNotification];
    
    // Open the video so we can grab a still image.
    if ( _videoPreviewImage.image == nil )
    {
        NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"MeetChrisVideo" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        MPMoviePlayerController *mpc = [[[MPMoviePlayerController alloc] initWithContentURL:movieURL] autorelease];
        
        mpc.scalingMode = MPMovieScalingModeAspectFit;
        mpc.shouldAutoplay = NO;
        
        UIImage *thumbNail = [mpc thumbnailImageAtTime:21 timeOption:MPMovieTimeOptionExact];
        
        _videoPreviewImage.contentMode = UIViewContentModeScaleAspectFit;
        _videoPreviewImage.image = thumbNail;
    }
}

- (void)loggedoutScreen
{
    [self swapLeftPanel:_loggedoutLeftPanel];
    [self swapRightPanel:_signinRightPanel];
    
    [self disableButton:_loggedoutSigninButton];
    [self enableButton:_loggedoutSignupButton];
    [self hideNotification];
    
    [[_profileButton superview] setHidden:YES];
}

- (void)loggedinScreen
{
    if ( g_gtarController.connected == NO )
    {
        [self swapLeftPanel:_disconnectedGtarLeftPanel];
    }
    else
    {
        [self swapLeftPanel:_menuLeftPanel];
    }
    [self swapRightPanel:_feedRightPanel];
    
    [self enableButton:_menuPlayButton];
    [self enableButton:_menuFreePlayButton];
//    [self enableButton:_menuStoreButton];
    
    [self hideNotification];
    
    [[_profileButton superview] setHidden:NO];
    
    UserEntry *loggedInEntry = [g_userController getUserEntry:0];
    
    UIImage *image = [g_fileController getFileOrReturnNil:loggedInEntry.m_userProfile.m_imgFileId];
    
    if ( image != nil )
    {
        [_profileButton setImage:image forState:UIControlStateNormal];
    }
    else
    {
        [g_fileController getFileOrDownloadAsync:loggedInEntry.m_userProfile.m_imgFileId callbackObject:self callbackSelector:@selector(profilePicDownloaded:)];
    }
    
    // If we've logged in, regardles of whether the gtar was ever connected, we can act as if it was.
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    // First log in, show the welcome screens
	if ( guitarConnectedBefore == NO )
	{
        [settings setBool:YES forKey:@"GuitarConnectedBefore"];
        [settings synchronize];
    }

}

- (void)profilePicDownloaded:(UIImage *)image
{
    [_profileButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - Panel management

- (void)swapRightPanel:(UIView *)rightPanel
{
    
    [_currentRightPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [rightPanel setFrame:CGRectMake(0, 0, _rightPanel.frame.size.width, _rightPanel.frame.size.height )];
    
    [_rightPanel addSubview:rightPanel];
    
    _currentRightPanel = rightPanel;
    
}

- (void)swapLeftPanel:(UIView *)leftPanel
{
    
    [_currentLeftPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [leftPanel setFrame:CGRectMake(0, 0, _leftPanel.frame.size.width, _leftPanel.frame.size.height )];
    
    [_leftPanel addSubview:leftPanel];
    
    _currentLeftPanel = leftPanel;
    
}

#pragma mark - Button handling

- (IBAction)loggedoutSigninButtonClicked:(id)sender
{
    [self enableButton:_loggedoutSignupButton];
    [self disableButton:_loggedoutSigninButton];
    
    [self hideNotification];
    
    [self swapRightPanel:_signinRightPanel];
}

- (IBAction)loggedoutSignupButtonClicked:(id)sender
{
    [self enableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    
    [self hideNotification];
    
    [self swapRightPanel:_signupRightPanel];
}

- (IBAction)gatekeeperVideoButtonClicked:(id)sender
{
    [self disableButton:_gatekeeperVideoButton];
    [self enableButton:_gatekeeperSigninButton];
    [self enableButton:_gatekeeperWebsiteButton];
    
    [self hideNotification];
    
    [self swapRightPanel:_videoRightPanel];
}

- (IBAction)gatekeeperSigninButtonClicked:(id)sender
{
    [self enableButton:_gatekeeperVideoButton];
    [self disableButton:_gatekeeperSigninButton];
    [self enableButton:_gatekeeperWebsiteButton];
    
    [_moviePlayer stop];
    
    [self displayNotification:NOTIFICATION_GATEKEEPER_SIGNIN turnRed:NO];
    
    [self swapRightPanel:_signinRightPanel];
}

- (IBAction)gatekeeperWebsiteButtonClicked:(id)sender
{
    // Show them where they can buy a gtar!
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.incidentgtar.com/"]];
}

- (IBAction)menuPlayButtonClicked:(id)sender
{
    // Start play mode
    SongSelectionViewController *vc = [[SongSelectionViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc release];
}

- (IBAction)menuFreePlayButtonClicked:(id)sender
{
    // Start free play mode
    FreePlayController * fpc = [[FreePlayController alloc] initWithNibName:nil bundle:nil];
	
	[self.navigationController pushViewController:fpc animated:YES];
	
	[fpc release];
    
}

- (IBAction)menuStoreButtonClicked:(id)sender
{
    // Start store mode
    
}

- (IBAction)feedSelectorChanged:(id)sender
{
    if ( _feedSelectorControl.selectedIndex == 0 && _refreshingFriendFeed == YES )
    {
        [_feedTable startAnimatingOffscreen];
    }
    else if ( _feedSelectorControl.selectedIndex == 1 && _refreshingGlobalFeed == YES )
    {
        [_feedTable startAnimatingOffscreen];
    }
    else
    {
        [_feedTable stopAnimating];
    }
    
    // Return the table to the top and reload its data
    [_feedTable setContentOffset:CGPointMake(0, 0)];
    [_feedTable reloadData];
}

- (IBAction)signupButtonClicked:(id)sender
{
    if ( _signupUsernameText.text == nil || [_signupUsernameText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNUP_USERNAME_INVALID turnRed:YES];
        
        return;
    }
    
    if ( _signupPasswordText.text == nil || [_signupPasswordText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNUP_PASSWORD_INVALID turnRed:YES];
        
        return;
    }
    
//    NSCharacterSet * alphaNumChars = [NSCharacterSet alphanumericCharacterSet];
    NSCharacterSet * alphaChars = [NSCharacterSet letterCharacterSet];
    
    NSString * firstChar = [_signupUsernameText.text substringToIndex:1];
    
    // The first char of the username must be a letter
    if ( [firstChar rangeOfCharacterFromSet:alphaChars].location == NSNotFound )
    {
        [self displayNotification:SIGNUP_USERNAME_INVALID_FIRSTLETTER turnRed:YES];
        
        return;
    }
    
    if ( [_signupPasswordText.text length] < 8 )
    {
        [self displayNotification:SIGNUP_PASSWORD_INVALID_LENGTH turnRed:YES];
        
        return;
    }
    
    [self hideNotification];
    
    [self swapRightPanel:_loadingRightPanel];
    
    [self disableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    
    [g_userController requestSignupUser:_signupUsernameText.text
                            andPassword:_signupPasswordText.text
                               andEmail:_signupEmailText.text
                         andCallbackObj:self
                         andCallbackSel:@selector(signupCallback:)];

}

- (IBAction)signupFacebookButtonClicked:(id)sender
{
    // Passthrough for now
    [self signinFacebookButtonClicked:sender];
}

- (IBAction)signinButtonClicked:(id)sender
{
    if ( _signinUsernameText.text == nil || [_signinUsernameText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNIN_USERNAME_INVALID turnRed:YES];
        
        return;
    }
    
    if ( _signinPasswordText.text == nil || [_signinPasswordText.text isEqualToString:@""] == YES )
    {
        [self displayNotification:SIGNIN_PASSWORD_INVALID turnRed:YES];
        
        return;
    }
    
    [self hideNotification];
    
    [self swapRightPanel:_loadingRightPanel];
    
    [self disableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
    [self disableButton:_gatekeeperVideoButton];
    [self disableButton:_gatekeeperSigninButton];
    [self disableButton:_gatekeeperWebsiteButton];
    
    [g_userController requestLoginUser:_signinUsernameText.text
                           andPassword:_signinPasswordText.text
                        andCallbackObj:self
                        andCallbackSel:@selector(signinCallback:)];
    
}

- (IBAction)signinFacebookButtonClicked:(id)sender
{
    if ( _waitingForFacebook == YES )
    {
        return;
    }
    
    _waitingForFacebook = YES;
    
    [g_facebook authorize:FACEBOOK_PERMISSIONS];
    
    [self swapRightPanel:_loadingRightPanel];
}

- (IBAction)videoButtonClicked:(id)sender
{
    if ( _moviePlayer )
    {
        // Only one at a time
        return;
    }
    
    // Get the Movie
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"MeetChrisVideo" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    _moviePlayer.shouldAutoplay = NO;
    
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerWillEnterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [_moviePlayer.view setFrame:_videoRightPanel.frame ];
    
    [_videoRightPanel addSubview:_moviePlayer.view];
    [_videoRightPanel bringSubviewToFront:_moviePlayer.view];
    
    [_moviePlayer setFullscreen:YES animated:YES];
    
    [_moviePlayer play];
}

- (IBAction)profileButtonClicked:(id)sender
{
    SocialViewController *svc = [[SocialViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:svc animated:YES];
    
    [svc release];
}

#pragma mark - Movie Playback

- (void)moviePlayBackDidFinish:(NSNotification *)notification
{
    
    [_moviePlayer setFullscreen:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    
    [_moviePlayer.view removeFromSuperview];
    [_moviePlayer release];
    
    _moviePlayer = nil;
    
}

- (void)moviePlayerPlaybackStateChanged:(NSNotification *)notification
{
    MPMoviePlaybackState playbackState = _moviePlayer.playbackState;

    if ( playbackState == MPMoviePlaybackStateInterrupted )
    {
        [_moviePlayer setFullscreen:NO];
    }
}

- (void)moviePlayerWillEnterBackground
{
    // If we don't do this, our screen is messed up when we return.
    [_moviePlayer setFullscreen:NO];
    [_moviePlayer pause];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Friends
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        return [_friendFeed count];
    }
    
    // Global
    if ( _feedSelectorControl.selectedIndex == 1 )
    {
        return [_globalFeed count];
    }
    
    // News
    if ( _feedSelectorControl.selectedIndex == 2 )
    {
        // derp
    }
    
    // Should never happen
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    static NSString *ActivityCellIdentifier = @"ActivityFeedCell";
    
    ActivityFeedCell *cell = (ActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:ActivityCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[ActivityFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActivityCellIdentifier] autorelease];
        
        [[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:cell options:nil];
        
        [cell setFrame:CGRectMake(0, 0, _feedTable.frame.size.width, _feedTable.rowHeight-1)];
        [cell.accessoryView setFrame:CGRectMake(0, 0, _feedTable.frame.size.width, _feedTable.rowHeight-1)];
    }
    
    // Clear these in case this cell was previously selected
    cell.highlighted = NO;
    cell.selected = NO;
    
    NSInteger row = [indexPath row];
    
    UserSongSession * session = nil;
    
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        if ( row < [_friendFeed count] )
        {
            session = [_friendFeed objectAtIndex:row];
        }
    }
    
    if ( _feedSelectorControl.selectedIndex == 1 )
    {
        if ( row < [_globalFeed count] )
        {
            session = [_globalFeed objectAtIndex:row];
        }
    }
    
    cell.userSongSession = session;
    
    [cell updateCell];
    
    return cell;

//    if ( tableView == _commentTable )
//    {
//        static NSString *CommentCellIdentifier = @"UserCommentCell";
//        
//        UserCommentCell *cell = (UserCommentCell *)[tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier];
//        
//        if (cell == nil)
//        {
//            cell = [[[UserCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentCellIdentifier] autorelease];
//            
//            [[NSBundle mainBundle] loadNibNamed:@"UserCommentCell" owner:cell options:nil];
//            
//            [cell setFrame:CGRectMake(0, 0, _commentTable.frame.size.width, _feedTable.rowHeight-1)];
//            [cell.accessoryView setFrame:CGRectMake(0, 0, _commentTable.frame.size.width, _commentTable.rowHeight-1)];
//        }
//        
//        // Clear these in case this cell was previously selected
//        cell.highlighted = NO;
//        cell.selected = NO;
//        
//        NSInteger row = [indexPath row];
//        
//        // get stuff
//        
//        [cell updateCell];
//        
//        return cell;
//    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 41;
//}

- (void)update
{
    [_feedTable startAnimating];
    
    [self updateFriendFeed];
    [self updateGlobalFeed];
}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( _displayingCell == YES )
    {
        return;
    }
    
    _displayingCell = YES;
    
    // Cause the row to spin until the session has started
    ActivityFeedCell *cell = (ActivityFeedCell*)[_feedTable cellForRowAtIndexPath:indexPath];
    
    [cell.activityView startAnimating];
    
    UserSongSession *session = cell.userSongSession;
    
    NSString * xmpBlob = [g_fileController getFileOrDownloadSync:session.m_xmpFileId];
    
    if ( xmpBlob == nil )
    {
        [cell.activityView stopAnimating];
        return;
    }
    
    session.m_xmpBlob = xmpBlob;
    
    _sessionViewController.userSongSession = session;
    
    [self presentViewController:_sessionViewController animated:YES completion:^{ [cell.activityView stopAnimating]; }];
    
}

#pragma mark - UITextFieldDelegate

- (IBAction)textFieldSelected:(id)sender
{
    // Invalidate this, if its already running
    [_textFieldSliderTimer invalidate];
    
    _textFieldSliderTimer = nil;
    
    CyclingTextField *cyclingTextField = (CyclingTextField *)sender;
    
    UIView *parent = cyclingTextField.superview;
    
    // Shift the superview up enough so that the textfield is
    // centered in the remaining visble space once the keyboard displays.
    // I kinda just tweaked this value till it looked right.
    CGFloat delta = cyclingTextField.frame.origin.y - 35;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    //    parent.transform = CGAffineTransformMakeTranslation( 0, -delta );
    parent.layer.transform = CATransform3DMakeTranslation( 0, -delta, 0 );
    [UIView commitAnimations];
    
    if ( _fullScreenButton == nil )
    {
        // Not retained
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = self.view.frame;
        
        [self.view addSubview:_fullScreenButton];
    }
    else
    {
        // Remove all actions for the button
        [_fullScreenButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
    
    // Resign first responder on the text field when this button is pressed
    [_fullScreenButton addTarget:cyclingTextField action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _textFieldSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(delayedTextFieldSlider:) userInfo:textField repeats:NO];

    return YES;
}

- (void)delayedTextFieldSlider:(NSTimer *)timer
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)[timer userInfo];
    
    [_textFieldSliderTimer invalidate];
    
    _textFieldSliderTimer = nil;
    
    UIView *parent = cyclingTextField.superview;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    //    parent.transform = CGAffineTransformIdentity;
    parent.layer.transform = CATransform3DIdentity;
    [UIView commitAnimations];
    
    // FYI We never retained this
    [_fullScreenButton removeFromSuperview];
    
    _fullScreenButton = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)textField;
    
    if ( cyclingTextField.nextTextField != nil )
    {
        [cyclingTextField.nextTextField becomeFirstResponder];
    }
    else if ( cyclingTextField.submitButton != nil )
    {
        [cyclingTextField.submitButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        [cyclingTextField resignFirstResponder];
    }
    
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
//    NSCharacterSet * usernameSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
//    NSCharacterSet * passwordSet =[[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789!@#$%^&*+-/=?^_`|~.[]{}()"] invertedSet];
//    
//    // Backspace character
//    if ( [string length] == 0 )
//    {
//        return YES;
//    }
//    
//    // The username needs alpha num only
//    if ( textField == m_usernameTextField &&
//        [string rangeOfCharacterFromSet:usernameSet].location != NSNotFound )
//    {
//        [m_statusLabel setText:@"Invalid character"];
//        [m_statusLabel setHidden:NO];
//        return NO;
//    }
//    
//    if ( textField == m_passwordTextField &&
//        [string rangeOfCharacterFromSet:passwordSet].location != NSNotFound )
//    {
//        [m_statusLabel setText:@"Invalid character"];
//        [m_statusLabel setHidden:NO];
//        return NO;
//    }
//    
//    [m_statusLabel setHidden:YES];
    
    return YES;
}

#pragma mark - GtarControllerObserver

- (void)gtarConnected
{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    // First log in, show the welcome screens
	if ( guitarConnectedBefore == NO )
	{
        [settings setBool:YES forKey:@"GuitarConnectedBefore"];
        [settings synchronize];
    }
    
    [g_gtarController turnOffAllEffects];
    [g_gtarController turnOffAllLeds];
    [g_gtarController sendDisableDebug];
    
//    if ( g_cloudController.m_loggedIn == YES )
    if ( YES )
    {
        [self loggedinScreen];
    }
    else
    {
        [self loggedoutScreen];
    }
    
    g_gtarController.m_delegate = self;
    
    [g_gtarController sendRequestFirmwareVersion];
    
//    [self playStartupLightSequence];
//    
//    [self checkCurrentFirmwareVersion];
    
}

- (void)gtarDisconnected
{
    if ( g_cloudController.m_loggedIn == YES )
    {
        [self swapLeftPanel:_disconnectedGtarLeftPanel];
    }
    
    // Pull down the firmare view controller after disconnection
    if ( self.presentedViewController == _firmwareViewController )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - GtarControllerDelegate

- (void)receivedFirmwareMajorVersion:(int)majorVersion andMinorVersion:(int)minorVersion
{
    NSLog(@"Fetching firmware version: %d.%d", majorVersion, minorVersion);
    
    [g_cloudController requestCurrentFirmwareVersionCallbackObj:self andCallbackSel:@selector(receivedAvailableFirmwareVersion:)];
}

- (void)receivedFirmwareUpdateStatusSucceeded
{
    NSString * msg = @"Firmware update succeeded";
    
    NSLog(@"%@", msg);
    
    [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     msg, @"Status",
                                     [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                     nil]];
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusSucceededMain) withObject:nil waitUntilDone:YES];
}

- (void)receivedFirmwareUpdateStatusSucceededMain
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Success"
                                                     message:@"Update Succeeded"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)receivedFirmwareUpdateStatusFailed
{
    NSString * msg = @"Firmware update failed";
    
    NSLog(@"%@", msg);
    
    [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     msg, @"Status",
                                     [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                     nil]];
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusFailedMain) withObject:nil waitUntilDone:YES];
}

- (void)receivedFirmwareUpdateStatusFailedMain
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@"Update Failed -- Restart the gTar"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)receivedFirmwareUpdateProgress:(unsigned char)percentage
{
    _firmwareViewController.updateProgress = percentage;
}

#pragma mark - UserController callbacks

- (void)facebookSigninCallback:(UserResponse*)userResponse
{
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        // we are logged in
        [g_telemetryController logEvent:GtarPlayAppLogin
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@",  g_cloudController.m_username], @"Username",
                                         nil]];
        
        [g_userController sendPendingUploads];
        
        [g_telemetryController uploadLogMessages];
        
        [self hideNotification];
        
        [self loggedinScreen];
        
        [self updateGlobalFeed];
        [self updateFriendFeed];
        
        [_feedTable startAnimating];
    }
    else
    {
        // There was an error
        [self displayNotification:userResponse.m_statusText turnRed:YES];
        
        // If the menu is showing, we need to back out
        if ( _currentLeftPanel == _menuLeftPanel )
        {
            [self loggedoutScreen];
        }
        else
        {
            [self swapRightPanel:_signinRightPanel];
            
            // Renable buttons
            [self enableButton:_gatekeeperVideoButton];
            [self enableButton:_gatekeeperWebsiteButton];
            [self enableButton:_loggedoutSignupButton];
        }
    }
}

- (void)signinCallback:(UserResponse *)userResponse
{
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        // we are logged in
        [g_telemetryController logEvent:GtarPlayAppLogin
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@",  g_cloudController.m_username], @"Username",
                                         nil]];
        
        [g_userController sendPendingUploads];
        
        [g_telemetryController uploadLogMessages];
        
        [self hideNotification];
        
        [self loggedinScreen];
        
        [self updateGlobalFeed];
        [self updateFriendFeed];
        
        [_feedTable startAnimating];
    }
    else
    {
        // There was an error
        [self displayNotification:userResponse.m_statusText turnRed:YES];
        
        // If the menu is showing, we need to back out
        if ( _currentLeftPanel == _menuLeftPanel )
        {
            [self loggedoutScreen];
        }
        else
        {
            [self swapRightPanel:_signinRightPanel];
        
            // Renable buttons
            [self enableButton:_gatekeeperVideoButton];
            [self enableButton:_gatekeeperWebsiteButton];
            [self enableButton:_loggedoutSignupButton];
        }
    }
}

- (void)signupCallback:(UserResponse *)userResponse
{
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [g_telemetryController logEvent:GtarPlayAppLogin
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@",  g_cloudController.m_username], @"Username",
                                         nil]];
        
        [g_userController sendPendingUploads];
        
        [g_telemetryController uploadLogMessages];
        
        [self loggedinScreen];
        
        [self updateGlobalFeed];
        [self updateFriendFeed];
        
        [_feedTable startAnimating];
    }
    else
    {
        // There was an error
        [self displayNotification:userResponse.m_statusText turnRed:YES];
        
        [self swapLeftPanel:_loggedoutLeftPanel];
        [self swapRightPanel:_signupRightPanel];
        
        // Renable buttons
        [self enableButton:_loggedoutSignupButton];
    }
}

// Technically this is CloudController callback
- (void)globalUpdateSucceeded:(CloudResponse *)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        [_globalFeed release];
        
        _globalFeed = [cloudResponse.m_responseUserSongSessions.m_sessionsArray retain];
    }
    
    // Precache any files we need
    for ( UserSongSession *session in _globalFeed )
    {
        //[g_fileController precacheFile:session.m_userSong.m_imgFileId];
        _outstandingImageDownloads++;
        [g_fileController getFileOrDownloadAsync:session.m_userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
    }
    
    _refreshingGlobalFeed = NO;
    
    if ( _feedSelectorControl.selectedIndex == 1 )
    {
        [_feedTable stopAnimating];
    }

}

- (void)userUpdateSucceeded:(UserResponse *)userResponse
{
    UserEntry *entry = [g_userController getUserEntry:0];
    
    [_friendFeed release];
    
    _friendFeed = [entry.m_followsSessionsList retain];
    
    // Precache any files we need
    for ( UserSongSession *session in _friendFeed )
    {
        //[g_fileController precacheFile:session.m_userSong.m_imgFileId];
        _outstandingImageDownloads++;
        [g_fileController getFileOrDownloadAsync:session.m_userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
    }
    
    _refreshingFriendFeed = NO;
    
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        [_feedTable stopAnimating];
    }

}

- (void)userUpdateFailed:(NSString *)reason
{
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        [_feedTable stopAnimating];
    }
}

#pragma mark - FacebookDelegate

- (void)fbDidLogin
{
    _waitingForFacebook = NO;
    
    // We save the access token to the user settings
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:[g_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [settings setObject:[g_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
    
    [self hideNotification];
    
    // Log into our server
    [g_userController requestLoginUserFacebookToken:g_facebook.accessToken
                                     andCallbackObj:self
                                     andCallbackSel:@selector(facebookSigninCallback:)];
    
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    _waitingForFacebook = NO;
    
    [self swapRightPanel:_signinRightPanel];
    
    [self displayNotification:FACEBOOK_INVALID turnRed:YES];
}

- (void)fbDidLogout
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // Clear cached data
    [settings removeObjectForKey:@"FBAccessTokenKey"];
    [settings removeObjectForKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
    
    [self loggedoutScreen];
}

- (void)fbSessionInvalidated
{
    [self loggedoutScreen];
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    
}

#pragma mark - CloudController Callbacks

- (void)receivedAvailableFirmwareVersion:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // Check if available version > installed version.
        if ( (cloudResponse.m_responseFirmwareMajorVersion > g_gtarController.m_firmwareMajorVersion) ||
            ((cloudResponse.m_responseFirmwareMajorVersion == g_gtarController.m_firmwareMajorVersion) &&
             (cloudResponse.m_responseFirmwareMinorVersion > g_gtarController.m_firmwareMinorVersion)) )
        {
            _firmwareFileId = cloudResponse.m_responseFileId;
            
            [self presentViewController:_firmwareViewController animated:YES completion:nil];
            
            _firmwareViewController.currentFirmwareVersion = [NSString stringWithFormat:@"%u.%u", g_gtarController.m_firmwareMajorVersion, g_gtarController.m_firmwareMinorVersion];
            _firmwareViewController.availableFirmwareVersion = [NSString stringWithFormat:@"%u.%u", cloudResponse.m_responseFirmwareMajorVersion, cloudResponse.m_responseFirmwareMinorVersion];
            
            [g_fileController getFileOrDownloadAsync:_firmwareFileId callbackObject:self callbackSelector:@selector(firmwareDownloadFinished:)];
        }
    }
    else
    {
        // Failed to get firmware, nothing more to worry about for now
        NSLog(@"Failed to get available firmware version");
    }
}

#pragma mark - FileController Callbacks

- (void)fileDownloadFinished:(id)file
{
    _outstandingImageDownloads--;
    
    if ( _outstandingImageDownloads == 0 )
    {
        // Reload the table
        [_feedTable reloadData];
    }
}

- (void)firmwareDownloadFinished:(id)file
{
    NSLog(@"Downloaded firmware file");
    
    NSMethodSignature *signature = [TitleNavigationController instanceMethodSignatureForSelector:@selector(beginUpdatingFirmware)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    
    [invocation setTarget:self];
    [invocation setSelector:@selector(beginUpdatingFirmware)];
    
    _firmwareViewController.updateInvocation = invocation;
}

#pragma mark - User Stuff

- (IBAction)logoutButtonClicked:(id)sender
{
    // Log out of everything
    [g_userController requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    [g_facebook logout];
    
    [self swapLeftPanel:_loggedoutLeftPanel];
    [self swapRightPanel:_loggedoutSigninButton];
    
    [_loggedoutSigninButton setEnabled:NO];
}

#pragma mark - Feed management

- (void)updateGlobalFeed
{
    _refreshingGlobalFeed = YES;
    
    [g_cloudController requestGlobalSessionsCallbackObj:self andCallbackSel:@selector(globalUpdateSucceeded:)];
}

- (void)updateFriendFeed
{
    _refreshingFriendFeed = YES;
    
    [g_userController requestUserFollowsSessions:0 andCallbackObj:self andCallbackSel:@selector(userUpdateSucceeded:)];
}

#pragma mark - Misc

- (void)delayLoadingComplete
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDelegate:_delayLoadingView];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    
    _delayLoadingView.alpha = 0.0f;
    
    [UIView commitAnimations];
}

- (void)beginUpdatingFirmware
{
    // output some messages
    NSString * msg = [[[NSString alloc] initWithFormat:@"Firmware updating"] autorelease];
    
    NSLog(@"%@", msg);
    
    [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     msg, @"Status",
                                     [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                     nil]];
    
    NSData *firmware = [g_fileController getFileOrDownloadSync:_firmwareFileId];
    
    if ( firmware == nil )
    {
        
        NSString * msg = [[[NSString alloc] initWithFormat:@"Firmware is nil"] autorelease];
        
        NSLog(@"%@", msg);
        
        [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         msg, @"Status",
                                         [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                         nil]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Failed"
                                                         message:@"Failed to download firmware"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
        
        return;
    }
    
    if ( [g_gtarController sendFirmwareUpdate:firmware] == YES )
    {
        NSLog(@"Update begun");
    }
    else
    {
        
        NSString * msg = [[[NSString alloc] initWithFormat:@"Update failed to start"] autorelease];
        
        NSLog(@"%@", msg);
        
        [g_telemetryController logEvent:GtarFirmwareUpdateStatus
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         msg, @"Status",
                                         [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                         nil]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Failed"
                                                         message:@"Failed to update firmware"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
    }

}

@end
