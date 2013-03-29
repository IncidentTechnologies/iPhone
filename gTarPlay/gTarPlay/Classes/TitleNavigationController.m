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

#import "ActivityFeedCell.h"
#import "SelectorControl.h"
#import "CyclingTextField.h"
#import "SlidingModalViewController.h"
#import "SongPlayerViewController.h"

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
#define SIGNUP_EMAIL_INVALID @"Invalid Email"
#define SIGNIN_USERNAME_INVALID @"Invalid Username"
#define SIGNIN_PASSWORD_INVALID @"Invalid Password"


@interface TitleNavigationController ()
{
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
    
    UIButton *_fullScreenButton;
    
    MPMoviePlayerController *_moviePlayer;
    
    NSArray *_globalFeed;
    NSArray *_friendFeed;
    
    NSInteger _outstandingImageDownloads;
    
    BOOL _refreshingGlobalFeed;
    BOOL _refreshingFriendFeed;
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
    
    // Do any additional setup after loading the view from its nib.
    
    UIView *viewsNeedingShadows[] =
    {
        _topBarView,
        _gtarLogoImage,
        _loggedoutSigninButton,
        _loggedoutSignupButton,
        _gatekeeperVideoButton,
        _gatekeeperSigninButton,
        _menuPlayButton,
        _menuFreePlayButton,
        _menuStoreButton
    };
    
    // Add shadows to everything in bulk
    for ( NSInteger i = 0; i < (sizeof(viewsNeedingShadows)/sizeof(UIView *)); i++)
    {
        UIView *view = viewsNeedingShadows[i];
        
        view.layer.shadowRadius = 7.0;
        view.layer.shadowColor = [[UIColor blackColor] CGColor];
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowOpacity = 0.9;
    }
    
//    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:@"HISTORY", @"GLOBAL", @"NEWS", nil]];
    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:@"HISTORY", @"GLOBAL", nil]];
    
    // Apparently the view doesn't get resized to iPhone 5 dimensions until after viewDidLoad
//    [self performSelectorOnMainThread:@selector(swapLeftPanel:) withObject:_gatekeeperLeftPanel waitUntilDone:NO];
    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    
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
//    else if ( guitarConnectedBefore == NO )
//    {
//        // We aren't logged in, and never plugged in a guitar. Display the gatekeeping view.
//        [self gatekeeperScreen];
//    }
    else if ( g_cloudController.m_loggedIn == NO )
    {
        // We aren't logged out
        [self loggedoutScreen];
    }
    else
    {
        // We are logged in
        [g_userController sendPendingUploads];
        
        [self updateGlobalFeed];
        [self updateFriendFeed];
        
        [_feedTable startAnimatingOffscreen];
    }
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
    [_activityFeedModal release];
    
    [_gatekeeperWebsiteButton release];
    [_notificationLabel release];
    
    [_loadingRightPanel release];
    [_signinUsernameText release];
    [_signinPasswordText release];
    [_signupUsernameText release];
    [_signupPasswordText release];
    [_signupEmailText release];
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
}

- (void)loggedoutScreen
{
    [self swapLeftPanel:_loggedoutLeftPanel];
    [self swapRightPanel:_signinRightPanel];
    
    [self disableButton:_loggedoutSigninButton];
    [self enableButton:_loggedoutSignupButton];
}

- (void)loggedinScreen
{
    [self swapLeftPanel:_menuLeftPanel];
    [self swapRightPanel:_feedRightPanel];
    
    [self enableButton:_menuPlayButton];
    [self enableButton:_menuFreePlayButton];
    [self enableButton:_menuStoreButton];
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
//    [self presentViewController:_activityFeedModal animated:NO completion:NULL];
    
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
//    NSCharacterSet * alphaChars = [NSCharacterSet letterCharacterSet];
//    
//    NSString * firstChar = [_signupUsernameText.text substringToIndex:1];
//    
//    // The first char of the username must be a letter
//    if ( [firstChar rangeOfCharacterFromSet:alphaChars].location == NSNotFound )
//    {
//        [self displayNotification:SIGNUP_USERNAME_INVALID_FIRSTLETTER turnRed:YES];
//        
//        return;
//    }
    
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
    
}

- (IBAction)videoButtonClicked:(id)sender
{
    if ( _moviePlayer )
    {
        // Only one at a time
        return;
    }
    
    // Get the Movie
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"gTar Teaser Final Test 480" ofType:@"m4v"];
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
                                             selector:@selector(moviePlayerWillExitFullcreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:_moviePlayer];
    
    [_moviePlayer.view setFrame:_videoRightPanel.frame ];
    
    [_videoRightPanel addSubview:_moviePlayer.view];
    
    [_moviePlayer setFullscreen:YES animated:YES];
    
    [_moviePlayer play];
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
                                                    name:MPMoviePlayerWillExitFullscreenNotification
                                                  object:_moviePlayer];
    
    [_moviePlayer.view removeFromSuperview];
    [_moviePlayer release];
    
    _moviePlayer = nil;
    
}

- (void)moviePlayerPlaybackStateChanged:(NSNotification *)notification
{
    MPMoviePlaybackState playbackState = _moviePlayer.playbackState;

    if ( playbackState == MPMoviePlaybackStatePaused )
    {
        [_moviePlayer setFullscreen:NO];
    }
}

- (void)moviePlayerWillExitFullcreen:(NSNotification *)notification
{
    
    if ( _moviePlayer.playbackState == MPMoviePlaybackStatePlaying )
    {
//        [_moviePlayer pause];
    }
    
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
    if ( _feedSelectorControl.selectedIndex == 1 )
    {
//        return [_globalFeed count];
    }
    
    // Should never happen
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"ActivityFeedCell";

	ActivityFeedCell *cell = (ActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
	{
		cell = [[[ActivityFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
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
    
//    // We only want one cell to be clicked on at a time
//    m_displayingCell = YES;
//    
    // Cause the row to spin until the session has started
    ActivityFeedCell *cell = (ActivityFeedCell*)[_feedTable cellForRowAtIndexPath:indexPath];
    
    [self legacyDisplayUserSongSession:cell.userSongSession];
    
//    [cell.m_timeLabel setHidden:YES];
    
    [cell.activityView startAnimating];
    
    [self performSelector:@selector(legacyDisplayUserSongSession:) withObject:cell.userSongSession afterDelay:0.05];
    
    [cell.activityView performSelector:@selector(stopAnimating) withObject:nil afterDelay:3.0];
    
}

#pragma mark - UITextFieldDelegate

- (IBAction)textFieldSelected:(id)sender
{
    CyclingTextField *cyclingTextField = (CyclingTextField *)sender;
    
    UIView *parent = cyclingTextField.superview;
    
    // Shift the superview up enough so that the textfield is
    // centered in the remaining visble space once the keyboard displays.
    // I kinda just tweaked this value till it looked right.
    CGFloat delta = cyclingTextField.frame.origin.y - 35;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    parent.transform = CGAffineTransformMakeTranslation( 0, -delta );
    
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
    CyclingTextField *cyclingTextField = (CyclingTextField *)textField;
    
    UIView *parent = cyclingTextField.superview;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    
    parent.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
    
    // FYI We never retained this
    [_fullScreenButton removeFromSuperview];
    
    _fullScreenButton = nil;
    
    return YES;
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
    
    //
    // First log in, show the welcome screens
    //
	if ( guitarConnectedBefore == NO )
	{
        [settings setBool:YES forKey:@"GuitarConnectedBefore"];
        [settings synchronize];
    }
    
    [g_gtarController turnOffAllEffects];
    [g_gtarController turnOffAllLeds];
    [g_gtarController sendDisableDebug];
    
//    [self playStartupLightSequence];
//    
//    [self checkCurrentFirmwareVersion];
    
}

- (void)gtarDisconnected
{
//    [m_infoPopup detachFromSuperView];
    
//    [m_gtarLogoRed setHidden:NO];
}

#pragma mark - GtarControllerDelegate

- (void)receivedFirmwareMajorVersion:(int)majorVersion andMinorVersion:(int)minorVersion
{
    
    NSLog(@"Receiving firmware version: %d.%d", majorVersion, minorVersion);
    
//    m_titleFirmwareViewController.m_firmwareCurrentMajorVersion = majorVersion;
//    m_titleFirmwareViewController.m_firmwareCurrentMinorVersion = minorVersion;
//    
//    [self checkAvailableFirmwareVersion];
    
}

#pragma mark - UserController callbacks

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
        if ( _leftPanel == _menuLeftPanel )
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

- (void)legacyDisplayUserSongSession:(UserSongSession*)session
{
    
    static SongPlayerViewController *songPlaybackViewController;
    
    // We could precache these, but adding a bit of sync latency here isn't really noticeable,
    // and we won't use most of the xmp blobs anyways.
    NSString * xmpBlob = [g_fileController getFileOrDownloadSync:session.m_xmpFileId];
    
    if ( xmpBlob == nil )
    {
        return;
    }
    
    session.m_xmpBlob = xmpBlob;
    
    // Song playback view controller, loaded lazily so as not to slow down app load
    if ( songPlaybackViewController == nil )
    {
        songPlaybackViewController = [[SongPlayerViewController alloc] initWithNibName:nil bundle:nil];
        songPlaybackViewController.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
//        songPlaybackViewController.m_popupDelegate = self;
//        songPlaybackViewController.m_delegate = self;
    }
    
    [songPlaybackViewController attachToSuperView:self.view andPlaySongSession:session];
    
}

@end
