//
//  TitleNavigationController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "CloudController.h"
#import "FileController.h"
#import <gTarAppCore/UserController.h>
#import <gTarAppCore/UserResponse.h>
#import <gTarAppCore/UserEntry.h>
#import "UserSongSession.h"
#import "UserSong.h"
#import "UserSongSessions.h"
#import "UserProfile.h"
#import "CloudResponse.h"
//#import <gTarAppCore/Facebook.h>

#import "TitleNavigationController.h"
#import "SongSelectionViewController.h"
#import "SocialViewController.h"
#import "VolumeViewController.h"
#import "SlidingInstrumentViewController.h"
#import "UIView+Keys.h"
#import "Mixpanel.h"

#import "ActivityFeedCell.h"
#import "UserCommentCell.h"
#import "SelectorControl.h"
#import "CyclingTextField.h"
#import "SessionModalViewController.h"
#import "FirmwareModalViewController.h"
#import "PlayerViewController.h"
#import "FreePlayController.h"
#import "StoreViewController.h"

extern CloudController * g_cloudController;
extern OphoCloudController * g_ophoCloudController;
extern FileController * g_fileController;
extern KeysController * g_keysController;
extern UserController * g_userController;
//extern Facebook * g_facebook;
//extern TelemetryController * g_telemetryController;

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
    SettingsViewController *_settingsViewController;
    
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
    
    UIButton *_fullScreenButton;
    
    NSTimer *_textFieldSliderTimer;
    
    MPMoviePlayerController *_moviePlayer;
    
    NSArray *_globalFeed;
    NSArray *_friendFeed;
    
    CGFloat _globalFeedOffset;
    CGFloat _friendFeedOffset;
    
    NSInteger _globalFeedCurrentPage;
    NSInteger _friendFeedCurrentPage;
    
    NSInteger _outstandingImageDownloads;
    
    BOOL _refreshingGlobalFeed;
    BOOL _refreshingFriendFeed;
    
    BOOL _displayingCell;
    BOOL _waitingForFacebook;
    BOOL _pendingFirmwareUpdate;
    
    NSInteger _firmwareFileId;
}
@end

@implementation TitleNavigationController

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _globalFeed = [[NSArray alloc] init];
    _friendFeed = [[NSArray alloc] init];
    
    _globalFeedCurrentPage = 1;
    _friendFeedCurrentPage = 1;
    
    //g_facebook = [[Facebook alloc] initWithAppId:FACEBOOK_CLIENT_ID andDelegate:self];
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // draw profile label button
    _profileLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 1, 151, 45)];
    [_profileLabel setTextColor:[UIColor whiteColor]];
    [_profileLabel setFont:[UIFont fontWithName:@"Avenir Next" size:17.0]];
    [_profileButton addSubview:_profileLabel];
    
    [self localizeView];
    
    // See if there are any cached credentials
    if ( [settings objectForKey:@"FBAccessTokenKey"] && [settings objectForKey:@"FBExpirationDateKey"] )
    {
        //g_facebook.accessToken = [settings objectForKey:@"FBAccessTokenKey"];
        //g_facebook.expirationDate = [settings objectForKey:@"FBExpirationDateKey"];
    }
    
    // Add shadows
    [_topBarView addShadow];
    
    [_gtarLogoImage addShadow];
    //[_loggedoutSigninButton addShadow];
    //[_loggedoutSignupButton addShadow];
    //[_gatekeeperVideoButton addShadow];
    //[_gatekeeperSigninButton addShadow];
    //[_menuPlayButton addShadow];
    //[_menuFreePlayButton addShadow];
    //[_menuStoreButton addShadow];
    
    // Hide anything that needs hiding
    [_menuSettingsButton setHidden:YES];
    [_profileButton setHidden:YES];
    [_profileButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:NSLocalizedString(@"FRIENDS", NULL), NSLocalizedString(@"GLOBAL", NULL), nil]];
    
    // Setup the feed's initial state
    UserEntry * entry = [g_userController getUserEntry:0];
    
    if ( [entry.m_followsSessionsList count] > 0 )
    {
        
        _friendFeed = entry.m_followsSessionsList;
        
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
    [g_keysController addObserver:self];
}

- (void)initSoundMaster
{
    g_soundMaster = [[SoundMaster alloc] init];
    //[_menuPlayButton startActivityIndicator];
    [_menuFreePlayButton startActivityIndicator];
    [g_soundMaster setCurrentInstrument:0 withSelector:@selector(instrumentLoaded:) andOwner:self];
}

- (void)releaseSoundMaster
{
    [g_soundMaster releaseCompletely];
    g_soundMaster = nil;
}

- (void)localizeView {
    // Gate keeper
    [_gatekeeperSigninButton setTitle:NSLocalizedString(@"SIGN IN", NULL) forState:UIControlStateNormal];
    [_gatekeeperSignupButton setTitle:NSLocalizedString(@"SIGN UP", NULL) forState:UIControlStateNormal];
    [_gatekeeperWebsiteButton setTitle:NSLocalizedString(@"INCIDENTKEYS.COM", NULL) forState:UIControlStateNormal];
    
    [_signinButton setTitle:NSLocalizedString(@"SIGN IN", NULL) forState:UIControlStateNormal];
    [_signupButton setTitle:NSLocalizedString(@"SIGN UP", NULL) forState:UIControlStateNormal];
    //_signUpOrLabel.text = NSLocalizedString(@"OR", NULL);
    //_signInOrLabel.text = NSLocalizedString(@"OR", NULL);
    
    _signInLoginLabel.text = NSLocalizedString(@"Sign In with Facebook", NULL);
    _signUpLoginLabel.text = NSLocalizedString(@"Sign In with Facebook", NULL);
    
    
    [_menuPlayButton setTitle:NSLocalizedString(@"PLAY", NULL) forState:UIControlStateNormal];
    [_menuFreePlayButton setTitle:NSLocalizedString(@"FREE PLAY", NULL) forState:UIControlStateNormal];
    [_menuStoreButton setTitle:NSLocalizedString(@"STORE", NULL) forState:UIControlStateNormal];
    
    [_loggedoutSigninButton setTitle:NSLocalizedString(@"SIGN IN", NULL) forState:UIControlStateNormal];
    [_loggedoutSignupButton setTitle:NSLocalizedString(@"SIGN UP", NULL) forState:UIControlStateNormal];
    
    [_signinUsernameText setPlaceholder:NSLocalizedString(@"Username", NULL)];
    [_signinPasswordText setPlaceholder:NSLocalizedString(@"Password", NULL)];
    
    [_signupUsernameText setPlaceholder:NSLocalizedString(@"Username", NULL)];
    [_signupPasswordText setPlaceholder:NSLocalizedString(@"Password", NULL)];
    [_signupEmailText setPlaceholder:NSLocalizedString(@"Email", NULL)];
    
    //_pleaseConnectLabel.text = NSLocalizedString(@"Please Connect Your gTar", NULL);
}

- (void)viewWillAppear:(BOOL)animated
{
    //- (void)viewWillAppear:(BOOL)animated
    //{
    //if(g_soundMaster != nil){
    //    [self releaseSoundMaster];
    //}
    
    if(g_soundMaster == nil){
        [self performSelectorInBackground:@selector(initSoundMaster) withObject:nil];
    }
    //}
    
    
    // Set up the modals
    _sessionViewController = [[SessionModalViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    _firmwareViewController = [[FirmwareModalViewController alloc] initWithNibName:nil bundle:nil];
    _settingsViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    _settingsViewController.delegate = self;
    
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
    /*else if ( g_cloudController.m_loggedIn == NO && guitarConnectedBefore == NO )
    {
        // We aren't logged in, and never plugged in a guitar. Display the gatekeeping view.
        [self gatekeeperScreen];
    }*/
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
    
    //[self showHideFreePlay];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    UserEntry *loggedInEntry = [g_userController getUserEntry:0];
    UIImage *image = [g_fileController getFileOrReturnNil:loggedInEntry.m_userProfile.m_imgFileId];
    
    if(loggedInEntry != nil){
        [_profileLabel setText:loggedInEntry.m_userProfile.m_name];
    }
    
    if ( image != nil )
    {
        [_profileButton setImage:image forState:UIControlStateNormal];
    }
    
    [self showHideFreePlay];
}

-(void)instrumentLoaded:(id)sender
{
    //[_menuPlayButton stopActivityIndicator];
    [_menuFreePlayButton stopActivityIndicator];
}

- (void)showHideFreePlay
{
    
    // Show Free Play if/if not standalone
    if(g_keysController.connected){
        
        [_menuStandalonePlayButton setHidden:YES];
        [_menuStandaloneStoreButton setHidden:YES];
        
        [_menuPlayButton setHidden:NO];
        [_menuStoreButton setHidden:NO];
        [_menuFreePlayButton setHidden:NO];
        //[_menuPlayButton setBounds:CGRectMake(_menuPlayButton.bounds.origin.x,0,_menuPlayButton.bounds.size.width,_menuPlayButton.bounds.size.height)];
        //[_menuStoreButton setBounds:CGRectMake(_menuStoreButton.bounds.origin.x,0,_menuStoreButton.bounds.size.width,_menuStoreButton.bounds.size.height)];
    }else{
        
        [_menuStandalonePlayButton setHidden:NO];
        [_menuStandaloneStoreButton setHidden:NO];
        
        [_menuPlayButton setHidden:YES];
        [_menuStoreButton setHidden:YES];
        [_menuFreePlayButton setHidden:YES];
        //[_menuPlayButton setBounds:CGRectMake(_menuPlayButton.bounds.origin.x,35,_menuPlayButton.bounds.size.width,_menuPlayButton.bounds.size.height)];
        //[_menuStoreButton setBounds:CGRectMake(_menuStoreButton.bounds.origin.x,-35,_menuStoreButton.bounds.size.width,_menuStoreButton.bounds.size.height)];
        
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
    
    //[g_soundMaster releaseAfterUse];
    
    [_currentLeftPanel removeFromSuperview];
    [_currentRightPanel removeFromSuperview];
    [_fullScreenButton removeFromSuperview];
    
    //g_facebook = nil;
    
    //[super dealloc];
}

#pragma mark - Notification management

// This changes the top bar notification
- (void)displayNotification:(NSString *)notification turnRed:(BOOL)red {
    [_notificationLabel setText:NSLocalizedString(notification, NULL)];
    [_notificationLabel.superview setHidden:NO];
    
    if ( red )
        _topBarView.backgroundColor = [UIColor redColor];
    else
        _topBarView.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:160.0/255.0 blue:220.0/255.0 alpha:1.0];
}

- (void)hideNotification {
    [_notificationLabel.superview setHidden:YES];
    _topBarView.backgroundColor = [UIColor colorWithRed:2.0/255.0 green:160.0/255.0 blue:220.0/255.0 alpha:1.0];
}

#pragma mark - Button management

- (void)enableButton:(UIButton *)button {
    button.backgroundColor = [UIColor colorWithRed:2/255.0 green:160/255.0 blue:220/255.0 alpha:1.0];
    [button setEnabled:YES];
}

- (void)disableButton:(UIButton *)button {
    button.backgroundColor = [UIColor colorWithRed:1/255.0 green:120/255.0 blue:165/255.0 alpha:1.0];
    [button setEnabled:NO];
}

#pragma mark - Panel collections

- (void)gatekeeperScreen {
    
    /*
    [self swapLeftPanel:_gatekeeperLeftPanel];
    [self swapRightPanel:_videoRightPanel];
    
    [self enableButton:_gatekeeperSignupButton];
    [self enableButton:_gatekeeperSigninButton];
    [self enableButton:_gatekeeperWebsiteButton];
    [self hideNotification];
    
    // Open the video so we can grab a still image.
    if ( _videoPreviewImage.image == nil ) {
        NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"MeetChrisVideo" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        MPMoviePlayerController *mpc = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        
        mpc.scalingMode = MPMovieScalingModeAspectFit;
        mpc.shouldAutoplay = NO;
        
        UIImage *thumbNail = [mpc thumbnailImageAtTime:21 timeOption:MPMovieTimeOptionExact];
        
        _videoPreviewImage.contentMode = UIViewContentModeScaleAspectFit;
        _videoPreviewImage.image = thumbNail;
    }
     */
    
}

- (void)loggedoutScreen {
    [self swapLeftPanel:_loggedoutLeftPanel];
    
    if(_currentRightPanel != _signupRightPanel && _currentRightPanel != _signinRightPanel){
        [self swapRightPanel:_signinRightPanel];
        [self disableButton:_loggedoutSigninButton];
        [self enableButton:_loggedoutSignupButton];
    }else if(_currentRightPanel == _signupRightPanel){
        [self enableButton:_loggedoutSigninButton];
        [self disableButton:_loggedoutSignupButton];
    }
    
    [self hideNotification];
    
    [_menuSettingsButton setHidden:YES];
    [_profileButton setHidden:YES];
}

- (void)loggedinScreen {
    
    [self swapLeftPanel:_menuLeftPanel];
    
    [self swapRightPanel:_feedRightPanel];
    
    [self enableButton:_menuPlayButton];
    [self enableButton:_menuFreePlayButton];
    //    [self enableButton:_menuStoreButton];
    
    //[self showHideFreePlay];
    
    [self hideNotification];
    
    [_menuSettingsButton setHidden:NO];
    [_profileButton setHidden:NO];
    
    UserEntry *loggedInEntry = [g_userController getUserEntry:0];
    
    UIImage *image = [g_fileController getFileOrReturnNil:loggedInEntry.m_userProfile.m_imgFileId];
    
    if(loggedInEntry != nil){
        [_profileLabel setText:loggedInEntry.m_userProfile.m_name];
    }
    
    if ( image != nil ){
        [_profileButton setImage:image forState:UIControlStateNormal];
    }else{
        [g_fileController getFileOrDownloadAsync:loggedInEntry.m_userProfile.m_imgFileId callbackObject:self callbackSelector:@selector(profilePicDownloaded:)];
    }
    
    if(g_keysController.connected && g_keysController.isKeysDeviceConnected){
        [self promptKeysRegistration];
    }
    
    if(_pendingFirmwareUpdate){
        
        if(self.presentedViewController != _firmwareViewController){
            
            TFLog(@"Expecting firmware update, rerequest now | logged in %i",g_cloudController.m_loggedIn);
            
            [g_keysController sendRequestFirmwareVersion];
            
        }
        
        _pendingFirmwareUpdate = NO;
        
    }
    
}

- (void)profilePicDownloaded:(UIImage *)image {
    
    [_profileButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - Panel management

- (void)swapRightPanel:(UIView *)rightPanel {
    
    [_currentRightPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [rightPanel setFrame:CGRectMake(0, 0, _rightPanel.frame.size.width, _rightPanel.frame.size.height )];
    
    [_rightPanel addSubview:rightPanel];
    
    _currentRightPanel = rightPanel;
}

- (void)swapLeftPanel:(UIView *)leftPanel {
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

- (IBAction)gatekeeperSignupButtonClicked:(id)sender
{
    [self disableButton:_gatekeeperSignupButton];
    [self enableButton:_gatekeeperSigninButton];
    [self enableButton:_gatekeeperWebsiteButton];
    
    [_moviePlayer stop];
    
    //[self displayNotification:NOTIFICATION_GATEKEEPER_SIGNIN turnRed:NO];
    
    [self swapRightPanel:_signupRightPanel];
    [self swapLeftPanel:_loggedoutLeftPanel];
    [self enableButton:_loggedoutSigninButton];
    [self disableButton:_loggedoutSignupButton];
}

- (IBAction)gatekeeperSigninButtonClicked:(id)sender
{
    [self enableButton:_gatekeeperSignupButton];
    [self disableButton:_gatekeeperSigninButton];
    [self enableButton:_gatekeeperWebsiteButton];
    
    [_moviePlayer stop];
    
    //[self displayNotification:NOTIFICATION_GATEKEEPER_SIGNIN turnRed:NO];
    
    [self swapRightPanel:_signinRightPanel];
    [self swapLeftPanel:_loggedoutLeftPanel];
    [self disableButton:_loggedoutSigninButton];
    [self enableButton:_loggedoutSignupButton];
}

- (IBAction)gatekeeperWebsiteButtonClicked:(id)sender
{
    // Show them where they can buy a keys!
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.incidentkeys.com/"]];
}

- (IBAction)menuPlayButtonClicked:(id)sender
{
    // Start play mode
    SongSelectionViewController *vc = [[SongSelectionViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)menuFreePlayButtonClicked:(id)sender
{
    // Start free play mode
    FreePlayController * fpc = [[FreePlayController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster];
    
    [self.navigationController pushViewController:fpc animated:YES];
    
}

- (IBAction)menuSettingsButtonClicked:(id)sender
{
    [self.navigationController pushViewController:_settingsViewController animated:YES];
}

- (IBAction)menuStoreButtonClicked:(id)sender
{
    StoreViewController *svc = [[StoreViewController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster];
    
    [self.navigationController pushViewController:svc animated:YES];
    
    
}

- (IBAction)feedSelectorChanged:(id)sender
{
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        _globalFeedOffset = _feedTable.contentOffset.y;
        
        [_feedTable setContentOffset:CGPointMake(0, _friendFeedOffset)];
        
        if ( _refreshingFriendFeed == YES )
        {
            [_feedTable startAnimatingOffscreen];
        }
        else
        {
            [_feedTable stopAnimating];
        }
    }
    else if ( _feedSelectorControl.selectedIndex == 1 )
    {
        _friendFeedOffset = _feedTable.contentOffset.y;
        
        [_feedTable setContentOffset:CGPointMake(0, _globalFeedOffset)];
        
        if ( _refreshingGlobalFeed == YES )
        {
            [_feedTable startAnimatingOffscreen];
        }
        else
        {
            [_feedTable stopAnimating];
        }
    }
    
    // Reload its data
    [_feedTable disablePagination];
    [_feedTable reloadData];
    
    if ( _feedSelectorControl.selectedIndex == 0 && _friendFeedCurrentPage > 0 && [_friendFeed count] > 5)
    {
        [_feedTable enablePagination];
    }
    else if ( _feedSelectorControl.selectedIndex == 1 && _globalFeedCurrentPage > 0 && [_globalFeed count] > 5)
    {
        [_feedTable enablePagination];
    }
    
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
    [self disableButton:_gatekeeperSignupButton];
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
    
    //[g_facebook authorize:FACEBOOK_PERMISSIONS];
    
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
    SocialViewController *svc = [[SocialViewController alloc] initWithNibName:nil bundle:nil soundMaster:g_soundMaster];
    
    [self.navigationController pushViewController:svc animated:YES];
    
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
    
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    if([tableView respondsToSelector:@selector(setLayoutMargins:)]){
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    static NSString * CellIdentifier = @"ActivityFeedCell";
    ActivityFeedCell *tempCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (tempCell == NULL)
    {
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:nil options:nil];
        for (UIView *view in views)
            if([view isKindOfClass:[UITableViewCell class]])
                tempCell = (ActivityFeedCell*)view;
        
        [tempCell setFrame:CGRectMake(0, 0, _feedTable.frame.size.width, _feedTable.rowHeight-1)];
        [tempCell.accessoryView setFrame:CGRectMake(0, 0, _feedTable.frame.size.width, _feedTable.rowHeight-1)];
    }
    
    // Clear these in case this cell was previously selected
    tempCell.highlighted = NO;
    tempCell.selected = NO;
    
    if([tempCell respondsToSelector:@selector(setLayoutMargins:)]){
        tempCell.layoutMargins = UIEdgeInsetsZero;
    }
    
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
    
    tempCell.userSongSession = session;
    [tempCell updateCell];
    return tempCell;
    
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

- (void)updateTable
{
    [_feedTable startAnimating];
    
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        _friendFeedCurrentPage = 1;
        _friendFeed = [[NSArray alloc] init];
        [self updateFriendFeed];
    }
    else if ( _feedSelectorControl.selectedIndex == 1 )
    {
        _globalFeedCurrentPage = 1;
        _globalFeed = [[NSArray alloc] init];
        [self updateGlobalFeed];
    }
}

- (void)nextPage
{
    if ( _feedSelectorControl.selectedIndex == 0 )
    {
        [self updateFriendFeed];
    }
    else if ( _feedSelectorControl.selectedIndex == 1 )
    {
        [self updateGlobalFeed];
    }
}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( _displayingCell == YES )
    {
        return;
    }
    
    // Cause the row to spin until the session has started
    ActivityFeedCell *cell = (ActivityFeedCell*)[_feedTable cellForRowAtIndexPath:indexPath];
    
    if(!cell.validSongSession){
        DLog(@"Not valid song session");
        return;
    }
    
    _displayingCell = YES;
    
    
    [cell.activityView startAnimating];
    
    UserSongSession *session = cell.userSongSession;
    
    NSString * xmpBlob = [g_fileController getFileOrDownloadSync:session.m_xmpFileId];
    
    if ( xmpBlob == nil )
    {
        [cell.activityView stopAnimating];
        _displayingCell = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Cannot connect to server"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    session.m_xmpBlob = xmpBlob;
    
    _sessionViewController.userSongSession = session;
    
    [_sessionViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    
    [self presentViewController:_sessionViewController animated:NO completion:^{ [cell.activityView stopAnimating]; _displayingCell = NO; }];
    
}

#pragma mark - UITextFieldDelegate

- (IBAction)textFieldSelected:(id)sender
{
    
    
    // Invalidate this, if its already running
    [_textFieldSliderTimer invalidate];
    
    _textFieldSliderTimer = nil;
    
    CyclingTextField *cyclingTextField = (CyclingTextField *)sender;
    
    UIView *parent = cyclingTextField.superview.superview;
    
    // Shift the superview up enough so that the textfield is
    // centered in the remaining visble space once the keyboard displays.
    // I kinda just tweaked this value till it looked right.
    //CGFloat delta = cyclingTextField.frame.origin.y - 35;
    CGFloat delta = 0;
    if(cyclingTextField == _signupEmailText){
        delta = cyclingTextField.superview.frame.origin.y - 35;
    }
    
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
    
    UIView *parent = cyclingTextField.superview.superview;
    
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

#pragma mark - KeysControllerObserver
- (void)keysRangeChange:(KeysRange)range
{
    DLog(@"Title Navigation Controller | Keys Range Change: %i to %i",range.keyMin,range.keyMax);
    
}

- (void)keysConnected {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL keysConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    // First log in, show the welcome screens
    if ( keysConnectedBefore == NO ) {
        [settings setBool:YES forKey:@"GuitarConnectedBefore"];
        [settings synchronize];
    }
    
    [g_keysController turnOffAllEffects];
    [g_keysController turnOffAllLeds];
    [g_keysController sendDisableDebug];
    
    if ( g_cloudController.m_loggedIn == YES ) {
        [self loggedinScreen];
        
        if(!keysConnectedBefore && g_keysController.isKeysDeviceConnected){
            [self promptKeysRegistration];
        }
    }
    else {
        [self loggedoutScreen];
    }
    
    g_keysController.m_delegate = self;
    [g_keysController sendRequestFirmwareVersion];
    [g_keysController sendRequestKeysRange];
    
    //    [self playStartupLightSequence];
    //
    //    [self checkCurrentFirmwareVersion];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ { [NSThread sleepForTimeInterval:WAIT_INT]; }];
    [g_keysController InitiateSerialNumberRequest];
    
    [self showHideFreePlay];
    [g_soundMaster routeToDefault];
}

- (void)keysDisconnected
{
    
    [g_keysController InterruptSerialNumberRequest];
    
    // Pull down the firmare view controller after disconnection
    if ( self.presentedViewController == _firmwareViewController )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self showHideFreePlay];
}

- (void)promptKeysRegistration
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL keysRegistered = [settings boolForKey:@"KeysRegistered"];
    BOOL keysRegisterPromptShown = [settings boolForKey:@"KeysRegisterPrompt"];
    
    // First log in, show the welcome screens
    if ( keysRegistered == NO && keysRegisterPromptShown == NO )
    {
        
        [settings setBool:YES forKey:@"KeysRegisterPrompt"];
        [settings synchronize];
        
        // Prompt registration
        RegisterPromptViewController * rpvc = [[RegisterPromptViewController alloc] initWithNibName:nil bundle:nil];
        
        rpvc.delegate = self;
        
        [rpvc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
        // if anything is up, hide it, then show register prompt
        [self dismissViewControllerAnimated:NO completion:NULL];
        [self presentViewController:rpvc animated:NO completion:^(void){}];
    }
}

- (void)registerDevice
{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    BOOL keysRegistered = [settings boolForKey:@"KeysRegistered"];
    
    if(!keysRegistered){
        
        [settings setBool:YES forKey:@"KeysRegistered"];
        [settings synchronize];
        
        NSString * serialNumberUpper = [g_keysController GetSerialNumberUpper];
        NSString * serialNumberLower = [g_keysController GetSerialNumberLower];
        
        DLog(@"Register device serial number %@, %@",serialNumberLower, serialNumberLower);
        
        [g_userController requestRegisterGtarSerialUpper:serialNumberUpper SerialLower:serialNumberLower andCallbackObj:self andCallbackSel:@selector(registerDeviceCallback)];
        
    }
    
}

- (void)registerDeviceCallback
{
    DLog(@"Registered device on title view controller");
}

- (BOOL)isDeviceRegistered
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    return [settings boolForKey:@"KeysRegistered"];
    
    // TODO: cloud controller call
}

#pragma mark - KeysControllerDelegate

- (void)receivedFirmwareMajorVersion:(int)majorVersion andMinorVersion:(int)minorVersion
{
    DLog(@"Fetching firmware version: %d.%d", majorVersion, minorVersion);
    
    [g_cloudController requestCurrentFirmwareVersionCallbackObj:self andCallbackSel:@selector(receivedAvailableFirmwareVersion:)];
}

- (void)receivedFirmwareUpdateStatusSucceeded
{
    NSString * msg = @"Firmware update succeeded";
    
    DLog(@"%@", msg);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Firmware update status" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          msg, @"Status",
                                                          [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                                          nil]];
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusSucceededMain) withObject:nil waitUntilDone:YES];
}

- (void)receivedFirmwareUpdateStatusSucceededMain
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:@"Update Succeeded"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)receivedFirmwareUpdateStatusFailed
{
    NSString * msg = @"Firmware update failed";
    
    DLog(@"%@", msg);
    
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Firmware update status" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          msg, @"Status",
                                                          [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                                          nil]];
    
    [self performSelectorOnMainThread:@selector(receivedFirmwareUpdateStatusFailedMain) withObject:nil waitUntilDone:YES];
}

- (void)receivedFirmwareUpdateStatusFailedMain {
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Update Failed -- Restart Keys"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)receivedFirmwareUpdateProgress:(unsigned char)percentage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        _firmwareViewController.updateProgress = percentage;
    }];
}

- (void)receivedCTMatrixValue:(unsigned char)value row:(unsigned char)row col:(unsigned char)col {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [_settingsViewController receivedCTMatrixValue:value row:row col:col];
    }];
}

- (void)receivedSensitivityValue:(unsigned char)value string:(unsigned char)str {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [_settingsViewController receivedSensitivityValue:value string:str];
    }];
}

- (void)receivedSerialNumber:(unsigned char *)number {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [_settingsViewController receivedSerialNumber:number];
    }];
}

- (void)receivedPiezoWindow:(unsigned char)value {
    // TODO: Set window
}

- (void)receivedResponse:(unsigned char)response
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Received Response" message:[NSString stringWithFormat:@"%u",response] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}

- (void)receivedCommitUserspaceAck:(unsigned char)status {
    [_settingsViewController receivedCommitUserspaceAck:status];
}

- (void)receivedResetUserspaceAck:(unsigned char)status {
    [_settingsViewController receivedResetUserspaceAck:status];
}

#pragma mark - UserController callbacks

- (void)facebookSigninCallback:(UserResponse*)userResponse
{
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        // we are logged in
        [self logLoginEvent];
        
        [g_userController sendPendingUploads];
        
        //        [g_telemetryController uploadLogMessages];
        
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
            [self enableButton:_gatekeeperSignupButton];
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
        [self logLoginEvent];
        
        [g_userController sendPendingUploads];
        
        //        [g_telemetryController uploadLogMessages];
        
        [self hideNotification];
        
        [self loggedinScreen];
        
        [self updateGlobalFeed];
        [self updateFriendFeed];
        
        [_feedTable startAnimating];
    }
    else
    {
        
        // There was an error
        
        if ( (g_userController.m_loggedInFacebookToken != nil ||
              g_userController.m_loggedInUsername != nil) )
        {
            // We didn't log in, but we have before, so we won't lock them out yet..
        }
        else if ( _currentLeftPanel == _menuLeftPanel )
        {
            // If the menu is showing, we need to back out
            [self displayNotification:userResponse.m_statusText turnRed:YES];
            [self loggedoutScreen];
        }
        else
        {
            [self displayNotification:userResponse.m_statusText turnRed:YES];
            [self swapRightPanel:_signinRightPanel];
            
            // Renable buttons
            [self enableButton:_gatekeeperSignupButton];
            [self enableButton:_gatekeeperWebsiteButton];
            [self enableButton:_loggedoutSignupButton];
        }
    }
}

- (void)signupCallback:(UserResponse *)userResponse
{
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        [self logLoginEvent];
        
        [g_userController sendPendingUploads];
        
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
        if ( [cloudResponse.m_responseUserSongSessions.m_sessionsArray count] > 0 )
        {
            
            _globalFeed = [_globalFeed arrayByAddingObjectsFromArray:cloudResponse.m_responseUserSongSessions.m_sessionsArray];
            _globalFeedCurrentPage++;
        }
        else
        {
            // Zero means there is nothing left
            _globalFeedCurrentPage = 0;
            
            if ( _feedSelectorControl.selectedIndex == 1 )
            {
                [_feedTable disablePagination];
            }
        }
    }
    
    // Precache any files we need -- only the first 10 or so
    NSInteger counter = 0;
    
    for ( UserSongSession *session in _globalFeed )
    {
        //[g_fileController precacheFile:session.m_userSong.m_imgFileId];
        _outstandingImageDownloads++;
        [g_fileController getFileOrDownloadAsync:session.m_userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        if ( ++counter > 10 )
        {
            break;
        }
    }
    
    _refreshingGlobalFeed = NO;
    
    if ( _feedSelectorControl.selectedIndex == 1 )
    {
        [_feedTable stopAnimating];
    }
    
}

- (void)userUpdateSucceeded:(CloudResponse *)cloudResponse
{
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        if ( [cloudResponse.m_responseUserSongSessions.m_sessionsArray count] > 0 )
        {
            NSMutableArray *sortedIncoming = [cloudResponse.m_responseUserSongSessions.m_sessionsArray mutableCopy];
            
            [sortedIncoming sortUsingSelector:@selector(compareCreatedNewestFirst:)];
            
            NSArray *array = [_friendFeed arrayByAddingObjectsFromArray:sortedIncoming];
            
            
            _friendFeed = array;
            _friendFeedCurrentPage++;
        }
        else
        {
            // Zero means there is nothing left
            _friendFeedCurrentPage = 0;
            
            if ( _feedSelectorControl.selectedIndex == 0 )
            {
                [_feedTable disablePagination];
            }
        }
    }
    
    // Precache any files we need -- only first 10 or so
    NSInteger counter = 0;
    
    for ( UserSongSession *session in _friendFeed )
    {
        //[g_fileController precacheFile:session.m_userSong.m_imgFileId];
        _outstandingImageDownloads++;
        [g_fileController getFileOrDownloadAsync:session.m_userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        if ( ++counter > 10 )
        {
            break;
        }
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

- (void)logLoginEvent
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"App login" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSString stringWithFormat:@"%@",  g_cloudController.m_username], @"Username",
                                             nil]];
    
    mixpanel.nameTag = g_cloudController.m_username;
    
    NSMutableDictionary *dict = [[NSDictionary dictionaryWithObjectsAndKeys:
                                  g_cloudController.m_username, @"$username",
                                  nil] mutableCopy];
    
    if ( g_userController.m_loggedInUserProfile.m_firstName )
    {
        [dict setObject:g_userController.m_loggedInUserProfile.m_firstName forKey:@"$first_name"];
    }
    if ( g_userController.m_loggedInUserProfile.m_lastName )
    {
        [dict setObject:g_userController.m_loggedInUserProfile.m_lastName forKey:@"$last_name"];
    }
    if ( g_userController.m_loggedInUserProfile.m_email )
    {
        [dict setObject:g_userController.m_loggedInUserProfile.m_email forKey:@"$email"];
    }
    
    [mixpanel.people set:dict];
    
    NSString* _currentUserId = [NSString stringWithFormat:@"%d", g_userController.m_loggedInUserProfile.m_userId];
    [mixpanel identify:_currentUserId];
}

#pragma mark - FacebookDelegate
/*
- (void)fbDidLogin
{
    _waitingForFacebook = NO;
    
    // We save the access token to the user settings
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    //[settings setObject:[g_facebook accessToken] forKey:@"FBAccessTokenKey"];
    //[settings setObject:[g_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    
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
 */

#pragma mark - CloudController Callbacks

- (void)receivedAvailableFirmwareVersion:(CloudResponse*)cloudResponse
{
    
    [_settingsViewController updateFirmwareVersion];
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // Check if available version > installed version.
        if ( (cloudResponse.m_responseFirmwareMajorVersion > g_keysController.m_firmwareMajorVersion) ||
            ((cloudResponse.m_responseFirmwareMajorVersion == g_keysController.m_firmwareMajorVersion) &&
             (cloudResponse.m_responseFirmwareMinorVersion > g_keysController.m_firmwareMinorVersion)) )
        {
            _firmwareFileId = cloudResponse.m_responseFileId;
            
            // Confirm whether logged in
            if(g_cloudController.m_loggedIn){
                
                if(self.presentedViewController != _firmwareViewController){
                    [self presentViewController:_firmwareViewController animated:YES completion:nil];
                }
                
                _pendingFirmwareUpdate = NO;
                
            }else{
                
                _pendingFirmwareUpdate = YES;
                
            }
            
            
            _firmwareViewController.currentFirmwareVersion = [NSString stringWithFormat:@"%u.%u", g_keysController.m_firmwareMajorVersion, g_keysController.m_firmwareMinorVersion];
            _firmwareViewController.availableFirmwareVersion = [NSString stringWithFormat:@"%u.%u", cloudResponse.m_responseFirmwareMajorVersion, cloudResponse.m_responseFirmwareMinorVersion];
            
            [g_fileController getFileOrDownloadAsync:_firmwareFileId callbackObject:self callbackSelector:@selector(firmwareDownloadFinished:)];
        }else{
            
            [_settingsViewController noUpdates];
            
            _pendingFirmwareUpdate = NO;
        }
    }
    else
    {
        // Failed to get firmware, nothing more to worry about for now
        DLog(@"Failed to get available firmware version");
        
        [_settingsViewController noUpdates];
        
        _pendingFirmwareUpdate = NO;
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
        
        if ( _feedSelectorControl.selectedIndex == 0 )
        {
        }
        else if ( _feedSelectorControl.selectedIndex == 1 )
        {
            // We don't want to display the paging option if we don't even have a full page of songs to show
            if ( [_globalFeed count] > 5 )
            {
                [_feedTable enablePagination];
            }
        }
        
    }
}

- (void)firmwareDownloadFinished:(id)file
{
    DLog(@"Downloaded firmware file");
    
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
    
    //[g_facebook logout];
    
    [self swapLeftPanel:_loggedoutLeftPanel];
    [self swapRightPanel:_loggedoutSigninButton];
    
    [_loggedoutSigninButton setEnabled:NO];
}

#pragma mark - Feed management

- (void)updateGlobalFeed
{
    _refreshingGlobalFeed = YES;
    
    [g_cloudController requestGlobalSessionsPage:_globalFeedCurrentPage andCallbackObj:self andCallbackSel:@selector(globalUpdateSucceeded:)];
}

- (void)updateFriendFeed
{
    _refreshingFriendFeed = YES;
    
    [g_cloudController requestFollowsSessions:0 andPage:_friendFeedCurrentPage andCallbackObj:self andCallbackSel:@selector(userUpdateSucceeded:)];
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
    NSString * msg = [[NSString alloc] initWithFormat:@"Firmware updating"];
    
    DLog(@"%@", msg);
    
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Firmware update status" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          msg, @"Status",
                                                          [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                                          nil]];
    
    NSData *firmware = [g_fileController getFileOrDownloadSync:_firmwareFileId];
    
    if ( firmware == nil )
    {
        
        NSString * msg = [[NSString alloc] initWithFormat:@"Firmware is nil"];
        
        DLog(@"%@", msg);
        
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Firmware update status" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              msg, @"Status",
                                                              [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                                              nil]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                        message:@"Failed to download firmware"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    TFLog(@"About to send firmware update");
    TFLog(@"Logged in? %i",g_cloudController.m_loggedIn);
    TFLog(@"Firmware data %@",firmware);
    
    // Double check it's actually passing data
    if ( ![firmware isKindOfClass:[NSString class]] && [g_keysController sendFirmwareUpdate:firmware] == YES )
    {
        DLog(@"Update begun");
    }
    else
    {
        
        NSString * msg = [[NSString alloc] initWithFormat:@"Update failed to start"];
        
        DLog(@"%@", msg);
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Firmware update status" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              msg, @"Status",
                                                              [NSNumber numberWithInteger:_firmwareFileId], @"FileId",
                                                              nil]];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed"
                                                        message:@"Failed to update firmware"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

@end
