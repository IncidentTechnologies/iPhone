//
//  RootViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "RootViewController.h"

//#import "StoreNavigationViewController.h"
#import "SelectNavigationViewController.h"
#import "UserProfileNavigationController.h"
#import "FreePlayController.h"

//#import "MenuNavigationViewController.h"

#import <gTarAppCore/TelemetryController.h>
#import <gTarAppCore/UserSongSession.h>
#import <gTarAppCore/UserProfile.h>
#import <gTarAppCore/CloudResponse.h>

#define FACEBOOK_CLIENT_ID @"285410511522607"
#define FACEBOOK_PERMISSIONS [NSArray arrayWithObjects:@"email", nil]

extern CloudController *g_cloudController;
extern FileController *g_fileController;
extern GtarController *g_gtarController;
extern UserController *g_userController;
extern Facebook *g_facebook;
extern TelemetryController *g_telemetryController;

@implementation RootViewController

//@synthesize m_disconnectedDeviceView;

@synthesize m_delayLoadView;
@synthesize m_buttonView;
@synthesize m_button1;
@synthesize m_button2;
@synthesize m_button3;

@synthesize m_accountContainerView;

@synthesize m_pleaseLoginPopup;
@synthesize m_disconnectedDevicePopup;
@synthesize m_tutorialIndexPopup;
@synthesize m_creditsPopup;
@synthesize m_infoPopup;
@synthesize m_firmwareCurrentVersion;
@synthesize m_firmwareAvailableVersion;
@synthesize m_firmwareUpdateButton;
@synthesize m_gtarLogoRed;
@synthesize m_waitingForFacebook;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if ( self )
    {
        
        // Keep this init brief so we don't slow down app loading
        
        m_titleGatekeeperViewController = [[TitleGatekeeperViewController alloc] initWithNibName:nil bundle:nil];
        m_titleWelcomeViewController = [[TitleWelcomeViewController alloc] initWithNibName:nil bundle:nil];
        m_titleLoginViewController = [[TitleLoginViewController alloc] initWithNibName:nil bundle:nil];
        m_titleSignupViewController = [[TitleSignupViewController alloc] initWithNibName:nil bundle:nil];
        m_titleTutorialViewController = [[TitleTutorialViewController alloc] initWithNibName:nil bundle:nil];
        m_titleFacebookViewController = [[TitleFacebookViewController alloc] initWithNibName:nil bundle:nil];
        m_titleFirmwareViewController = [[TitleFirmwareViewController alloc] initWithNibName:nil bundle:nil];
        
        g_facebook = [[Facebook alloc] initWithAppId:FACEBOOK_CLIENT_ID andDelegate:self];
        
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        // See if there are any cached credentials
        if ( [settings objectForKey:@"FBAccessTokenKey"] && [settings objectForKey:@"FBExpirationDateKey"] )
        {
            g_facebook.accessToken = [settings objectForKey:@"FBAccessTokenKey"];
            g_facebook.expirationDate = [settings objectForKey:@"FBExpirationDateKey"];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];

    [g_facebook release];
    
    g_facebook = nil;
    
    [m_delayLoadView release];
    [m_buttonView release];
    [m_button1 release];
    [m_button2 release];
    [m_button3 release];
    [m_accountContainerView release];
    [m_pleaseLoginPopup release];
    [m_disconnectedDevicePopup release];
    [m_creditsPopup release];
    [m_tutorialIndexPopup release];
    [m_infoPopup release];
    
    [m_firmwareCurrentVersion release];
    [m_firmwareAvailableVersion release];
    [m_firmwareUpdateButton release];
    
    [m_gtarLogoRed release];
    
    [m_tutorialViewController release];
    
    [m_accountViewController release];
    
    [m_displayUserSong release];

    [m_titleGatekeeperViewController release];
    [m_titleWelcomeViewController release];
    [m_titleLoginViewController release];
    [m_titleSignupViewController release];
    [m_titleTutorialViewController release];
    
    [m_songPlaybackViewController detachFromSuperView];
    [m_songPlaybackViewController release];
    
    [super dealloc];
    
}

- (void)viewDidLoad
{
    
	[super viewDidLoad];
    
    // Add a loading screen. This gets removed by the AppDelegate when it is done with its delayed loading
    [self.view addSubview:m_delayLoadView];
    m_delayLoadView.center = self.view.center;
    
	// 
	// Setup UI
	//
    m_pleaseLoginPopup.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
    m_tutorialIndexPopup.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
    m_tutorialIndexPopup.m_popupTitle = @"Tutorials";
    m_creditsPopup.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
    m_creditsPopup.m_popupTitle = @"Incident Technologies";
    m_infoPopup.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
    m_disconnectedDevicePopup.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
    
    //
    // Setup the tutorial view
    //
    m_tutorialViewController = [[TransitionRectangleViewController alloc] initWithNibName:nil bundle:nil];
    m_tutorialViewController.m_closeButtonImage = [UIImage imageNamed:@"XButton.png"];
    m_tutorialViewController.m_popupDelegate = self;
    
    //
    // Setup the account view
    //
    m_accountViewController = [[AccountViewController alloc] initWithNibName:nil bundle:nil];
    m_accountViewController.m_rootViewController = self;
    
    [m_accountViewController.view setFrame:m_accountContainerView.frame];
    [self.view insertSubview:m_accountViewController.view belowSubview:m_delayLoadView];
    
    //
    // Observe the device
    //
    
    [g_gtarController addObserver:self];
    
	//
	// Credentials and such
	//
	m_requireLogin = NO;
    
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    
//    self.m_disconnectedDeviceView = nil;
    self.m_buttonView = nil;
    self.m_button1 = nil;
    self.m_button2 = nil;
    self.m_button3 = nil;
    self.m_pleaseLoginPopup = nil;
    self.m_disconnectedDevicePopup = nil;
    self.m_tutorialIndexPopup = nil;
    self.m_creditsPopup = nil;
    self.m_infoPopup = nil;
    self.m_accountContainerView = nil;
    
    self.m_firmwareCurrentVersion = nil;
    self.m_firmwareAvailableVersion = nil;
    self.m_firmwareUpdateButton = nil;
    self.m_gtarLogoRed = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{

	[super viewWillAppear:animated];
    
    // silly but this needs to be called manually when using addSubview
    [m_accountViewController viewWillAppear:NO];
    
    //
    // Rotate the buttons
    // For some reason this doesn't work in viewDidLoad..
    //
    double angle = 23.3;
    
    [self.view addSubview:m_buttonView];
    [self.view sendSubviewToBack:m_buttonView];
    
    m_buttonView.transform = CGAffineTransformMakeRotation( -angle * M_PI / 180 );
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    BOOL runBefore = [settings boolForKey:@"RunBefore"];
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    //
    // First log in, show the welcome screens
    //
	if ( runBefore == NO )
	{
        [settings setBool:YES forKey:@"RunBefore"];
        [settings setBool:YES forKey:@"RouteToSpeaker"];
        
        [settings synchronize];
	}
    
    if ( guitarConnectedBefore == NO )
    {
        // 
        // Create a gatekeeping view 
        //
        [self attachFullScreenDialog:m_titleGatekeeperViewController];
        
    }
    else
    {
        // See if the user is logged in
        [self checkUserLoggedIn];
    }
    
    if ( m_displayUserSong != nil )
    {
        [self accountViewDisplayUserSong:m_displayUserSong];
        
        [m_displayUserSong release];
        
        m_displayUserSong = nil;
    }
    
    if ( g_cloudController.m_loggedIn == YES )
    {
        [g_telemetryController uploadLogMessages];
        [m_accountViewController updateFeeds];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
	[super viewDidDisappear:animated];
	
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    // silly but this needs to be called manually when using addSubview
    [m_accountViewController viewDidAppear:animated];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (void)handleBecomeActive
{
    
    if ( m_waitingForFacebook == YES )
    {
        [self displayWelcomeDialog];
    }
    
}

#pragma mark -
#pragma mark Button click handling

- (IBAction)playButtonClicked:(id)sender
{
    
//    if ( g_cloudController.m_loggedIn == NO )
//    {
//        [self displayLoggedOutPopup];
//        return;
//    }
    
#ifndef Debug_BUILD
    if ( g_gtarController.connected == NO )
    {
        [m_disconnectedDevicePopup attachToSuperView:self.view];
        return;
    }
#endif
    
    m_requireLogin = YES;
    
    SelectNavigationViewController * select = [[SelectNavigationViewController alloc] initWithNibName:@"CustomNavigationViewController" bundle:nil];
    
    [self.navigationController pushViewController:select animated:YES];
    
    [select release];
    
}

- (IBAction)freePlayButtonClicked:(id)sender
{

//    if ( g_cloudController.m_loggedIn == NO )
//    {
//        [self displayLoggedOutPopup];
//        return;
//    }

#ifndef Debug_BUILD
    if ( g_gtarController.connected == NO )
    {
        [m_disconnectedDevicePopup attachToSuperView:self.view];
        return;
    }
#endif
    
    m_requireLogin = NO;
    
	FreePlayController * fpc = [[FreePlayController alloc] initWithNibName:nil bundle:nil];
	
	[self.navigationController pushViewController:fpc animated:YES];
	
	[fpc release];
    
}

- (IBAction)storeButtonClicked:(id)sender
{
#if 0
//    if ( g_cloudController.m_loggedIn == NO )
//    {
//        [self displayLoggedOutPopup];
//        return;
//    }
//
//    m_requireLogin = YES;
//    
//    StoreNavigationViewController * sfvc = [[StoreNavigationViewController alloc] initWithNibName:@"CustomNavigationViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:sfvc animated:YES];
//    
//    [sfvc release];

#else
    
//    MenuNavigationViewController * menu = [[MenuNavigationViewController alloc] initWithNibName:@"CustomNavigationViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:menu animated:YES];
//    
//    [menu release];
    
//    [m_infoPopup attachToSuperViewWithBlackBackground:self.view];
    
    [self accountViewDisplayUserProfile:nil];
    
#endif
    
}

- (IBAction)tutorialButtonClicked:(id)sender
{
    [self displayTutorialIndexPopup];
}

- (IBAction)infoButtonClicked:(id)sender
{
    
    if ( g_gtarController.connected == NO )
    {
        [m_disconnectedDevicePopup attachToSuperView:self.view];
        return;
    }
    
//    [m_firmwareUpdateButton setEnabled:NO];
//    
//    [m_infoPopup attachToSuperView:self.view];
//    [self checkCurrentFirmwareVersion];
//    [self checkAvailableFirmwareVersion];
    
//    [m_titleFirmwareViewController attachToSuperview:self.view];
    [m_titleFirmwareViewController softUpdate:self.view];
    
}

- (IBAction)logoutButtonClicked:(id)sender
{
    
    // Detach any popups that are up
    [m_pleaseLoginPopup detachFromSuperView]; // This one might be dead?
    [m_infoPopup detachFromSuperView];
    
    // Log out of everything
    [g_userController requestLogoutUserCallbackObj:nil andCallbackSel:nil];
    
    [self attachFullScreenDialog:m_titleWelcomeViewController];
    
    [g_facebook logout];
    
}

- (IBAction)retryButtonClicked:(id)sender
{
    
    // Figure out how they are (were) logged in and display
    // the appropriate dialog to help them log back in.
    
    if ( [g_facebook isSessionValid] == YES )
    {
        [self attachFullScreenDialog:m_titleFacebookViewController];
        
        [m_titleFacebookViewController doneButtonClicked:nil];
    }
    else if ( g_userController.m_loggedInUsername != nil )
    {
        [self attachFullScreenDialog:m_titleLoginViewController];
        
        [m_titleLoginViewController cachedLogin];
    }
    else
    {
        [self displayWelcomeDialog];
    }
    
}

- (IBAction)welcomeTutorialButtonClicked:(id)sender
{
    [m_tutorialIndexPopup closeButtonClicked:sender];
    [self displayWelcomeTutorialPopup];
}

- (IBAction)freePlayTutorialButtonClicked:(id)sender
{
    [m_tutorialIndexPopup closeButtonClicked:sender];
    [self displayFreePlayTutorialPopup];
}

- (IBAction)playTutorialButtonClicked:(id)sender
{
    [m_tutorialIndexPopup closeButtonClicked:sender];
    [self displayPlayTutorialPopup];
}

- (IBAction)storeTutorialButtonClicked:(id)sender
{
    [m_tutorialIndexPopup closeButtonClicked:sender];
    [self displayStoreTutorialPopup];
}

- (IBAction)creditsButtonClicked:(id)sender
{
    [m_tutorialIndexPopup closeButtonClicked:sender];
    [self displayCreditsPopup];
}

#pragma mark - Misc

- (void)playStartupLightSequence
{
    
    m_sequenceFret = 16;
    
    [NSTimer scheduledTimerWithTimeInterval:0.2
                                     target:self
                                   selector:@selector(sequenceIteration)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void)sequenceIteration
{
    
    if ( m_sequenceFret == 0 )
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0) 
                                    withColor:GtarLedColorMake(3, 3, 3)];
    }
    else
    {
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(m_sequenceFret, 0) 
                                    withColor:GtarLedColorMake(0, 0, 3)];
    }
    
    m_sequenceFret--;
    
    if ( m_sequenceFret >= 8 )
    {
        // Do it one more time
        [NSTimer scheduledTimerWithTimeInterval:0.12f target:self selector:@selector(sequenceIteration) userInfo:nil repeats:NO];
    }
    else if ( m_sequenceFret >= 0 )
    {
        // Do it one more time
        [NSTimer scheduledTimerWithTimeInterval:(0.012f*m_sequenceFret) target:self selector:@selector(sequenceIteration) userInfo:nil repeats:NO];
    }
    else
    {
        // We are done, turn the leds off after a pause
        [NSTimer scheduledTimerWithTimeInterval:0.4f target:g_gtarController selector:@selector(turnOffAllLeds) userInfo:nil repeats:NO];
    }
    
}

- (void)displayTutorialIndexPopup
{
    [m_tutorialIndexPopup attachToSuperView:self.view];
}

- (void)displayLoggedOutPopup
{
    [m_pleaseLoginPopup attachToSuperView:self.view];
}

- (void)displayWelcomeTutorialPopup
{
    
	NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"plist"];
    NSDictionary * tutorialsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary * tutorialDictionary = [tutorialsDictionary objectForKey:@"Welcome"];
    
    NSArray * imagesArray = [tutorialDictionary objectForKey:@"Images"];
    NSArray * textArray = [tutorialDictionary objectForKey:@"Text"];
    
    m_tutorialViewController.m_title = @"Welcome!";
    m_tutorialViewController.m_imageArray = imagesArray;
    m_tutorialViewController.m_textArray = textArray;
    [m_tutorialViewController attachToSuperViewWithBlackBackground:self.view];
     
}

- (void)displayFreePlayTutorialPopup
{

	NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"plist"];
    NSDictionary * tutorialsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary * tutorialDictionary = [tutorialsDictionary objectForKey:@"FreePlay"];
    
    NSArray * imagesArray = [tutorialDictionary objectForKey:@"Images"];
    NSArray * textArray = [tutorialDictionary objectForKey:@"Text"];
    
    m_tutorialViewController.m_title = @"FreePlay";
    m_tutorialViewController.m_imageArray = imagesArray;
    m_tutorialViewController.m_textArray = textArray;
    [m_tutorialViewController attachToSuperViewWithBlackBackground:self.view];
    
}

- (void)displayPlayTutorialPopup
{
    
	NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"plist"];
    NSDictionary * tutorialsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary * tutorialDictionary = [tutorialsDictionary objectForKey:@"Play"];
    
    NSArray * imagesArray = [tutorialDictionary objectForKey:@"Images"];
    NSArray * textArray = [tutorialDictionary objectForKey:@"Text"];
    
    m_tutorialViewController.m_title = @"Play";
    m_tutorialViewController.m_imageArray = imagesArray;
    m_tutorialViewController.m_textArray = textArray;
    [m_tutorialViewController attachToSuperViewWithBlackBackground:self.view];

}

- (void)displayStoreTutorialPopup
{
    
	NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"plist"];
    NSDictionary * tutorialsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary * tutorialDictionary = [tutorialsDictionary objectForKey:@"Store"];
    
    NSArray * imagesArray = [tutorialDictionary objectForKey:@"Images"];
    NSArray * textArray = [tutorialDictionary objectForKey:@"Text"];
    
    m_tutorialViewController.m_title = @"Store";
    m_tutorialViewController.m_imageArray = imagesArray;
    m_tutorialViewController.m_textArray = textArray;
    [m_tutorialViewController attachToSuperViewWithBlackBackground:self.view];

}

- (void)displayCreditsPopup
{
    [m_creditsPopup attachToSuperViewWithBlackBackground:self.view];
}

#pragma mark - Full screen dialogs

- (void)attachFullScreenDialog:(FullScreenDialogViewController*)dialog
{
    
    if ( m_currentFullScreenDialog == dialog )
    {
        // Nothing to do
        return;
    }
    
    dialog.m_rootViewController = self;
    
    // Attach the new one first
    [dialog attachToSuperview:self.view];
    
    if ( m_currentFullScreenDialog != nil )
    {
        // Remove the old one. Bring it to the front first so we can see it
        [self.view bringSubviewToFront:m_currentFullScreenDialog.view];
        
        [m_currentFullScreenDialog detachFromSuperview];
    }
    
    // Add the current to the history
    dialog.m_previousDialog = m_currentFullScreenDialog;
    
    // Set the new current
    m_currentFullScreenDialog = dialog;
    
    // If the loading screen is still present, make sure that remains on top
    if ( [m_delayLoadView superview] != nil )
    {
        [self.view bringSubviewToFront:m_delayLoadView];
    }
    
}

- (void)returnToPreviousFullScreenDialog
{
    
    // Attach the previous dialog
    [m_currentFullScreenDialog.m_previousDialog attachToSuperview:self.view];
    
    // Detach the current
    [m_currentFullScreenDialog detachFromSuperview];
    
    // Set the new current
    m_currentFullScreenDialog = m_currentFullScreenDialog.m_previousDialog;
    
}

- (void)displayWelcomeDialog
{
    [self attachFullScreenDialog:m_titleWelcomeViewController];
}

- (void)displayLoginDialog
{
    [self attachFullScreenDialog:m_titleLoginViewController];
}

- (void)displaySignupDialog
{
    [self attachFullScreenDialog:m_titleSignupViewController];
}

- (void)displayFacebookDialog
{
    [self attachFullScreenDialog:m_titleFacebookViewController];
    
    [m_titleFacebookViewController startSpinner];

    // This actually looks a bit better to the user vs. popup 2 things at once
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(loginToFacebook) userInfo:nil repeats:NO];
//    [self loginToFacebook];
}

- (void)checkUserLoggedIn
{
    
    // If we dont have an active log in, do so now
    if ( g_cloudController.m_loggedIn == NO )
    {
        [g_userController requestLoginUserCachedCallbackObj:self andCallbackSel:@selector(loginCallback:)];
    }
    
    // Display any cached information
    [m_accountViewController updateDisplay];
    
    // Regardless, make it look like we are logged in while we wait
    if ( [g_facebook isSessionValid] == YES )
    {
//        [m_accountViewController updateDisplay];
//        [m_accountViewController updateFeeds];
    }
    else if ( g_userController.m_loggedInUsername != nil )
    {
//        [m_accountViewController updateDisplay];
//        [m_accountViewController updateFeeds];
    }
    else
    {
        // Popup the welcome screen if they are not logged in
        [self attachFullScreenDialog:m_titleWelcomeViewController];
    }
    
    if ( g_cloudController.m_loggedIn == YES )
    {
        [g_userController sendPendingUploads];
    }
    
}

- (void)loginCallback:(UserResponse*)userResponse
{
    
    [m_accountViewController updateDisplay];
    [m_accountViewController updateFeeds];
    
    if ( userResponse.m_status == UserResponseStatusSuccess )
    {
        // we are logged in
        [g_userController sendPendingUploads];
        
        [g_telemetryController logEvent:GtarPlayAppLogin
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@",  g_cloudController.m_username], @"Username",
                                         nil]];
        
        [g_telemetryController uploadLogMessages];
        
    }
    else
    {
//        [self logoutButtonClicked:nil];
        [m_pleaseLoginPopup detachFromSuperView]; // This one might be dead?
        [m_infoPopup detachFromSuperView];
        
        [self attachFullScreenDialog:m_titleWelcomeViewController];
    }
    
}

- (void)doneWith:(CloudResponse*)cloudResponse
{
    NSLog(@"done");
}

- (void)userLoggedIn
{
    
    m_currentFullScreenDialog = nil;
    
    [m_accountViewController updateDisplay];
    [m_accountViewController updateFeeds];
    
    // Clear out the fields for next time
    m_titleLoginViewController.m_usernameTextField.text = @"";
    m_titleLoginViewController.m_passwordTextField.text = @"";
    m_titleLoginViewController.m_previousDialog = nil;
    
    m_titleSignupViewController.m_usernameTextField.text = @"";
    m_titleSignupViewController.m_passwordTextField.text = @"";
    m_titleSignupViewController.m_emailTextField.text = @"";
    m_titleSignupViewController.m_previousDialog = nil;
    
    if ( g_cloudController.m_loggedIn == YES )
    {
        [g_userController sendPendingUploads];
        
        [g_telemetryController logEvent:GtarPlayAppLogin
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@",  g_cloudController.m_username], @"Username",
                                         nil]];

        [g_telemetryController uploadLogMessages];
    }
    
    // If we've logged in, we can assume they've plugged in the guitar before
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
	if ( guitarConnectedBefore == NO )
	{
        
        [settings setBool:YES forKey:@"GuitarConnectedBefore"];
        
        [settings synchronize];
        
    }


}

- (void)loginToFacebook
{
    
    m_waitingForFacebook = YES;
    
//    [g_facebook authorizeLocal:FACEBOOK_PERMISSIONS];
    [g_facebook authorize:FACEBOOK_PERMISSIONS];
    
}

#pragma mark - Firmware handlers.

- (void)checkCurrentFirmwareVersion
{
    
    NSLog(@"Checking gtar firmware version");
    
    g_gtarController.m_delegate = self;
    
    if ( [g_gtarController sendRequestFirmwareVersion] == NO )
    {
        
        NSLog(@"Firmware failed to update");
        
        m_titleFirmwareViewController.m_firmwareCurrentMajorVersion = 0;
        m_titleFirmwareViewController.m_firmwareCurrentMinorVersion = 0;
        
    }
    
}

- (void)checkAvailableFirmwareVersion
{
    // Query the server
    NSLog(@"Checking available gtar firmware version");
    
    [g_cloudController requestCurrentFirmwareVersionCallbackObj:self andCallbackSel:@selector(receivedAvailableFirmwareVersion:)];
    
}

- (void)receivedAvailableFirmwareVersion:(CloudResponse*)cloudResponse
{
    
    m_titleFirmwareViewController.m_firmwareFileId = 0;
    m_titleFirmwareViewController.m_firmwareAvailableMajorVersion = 0;
    m_titleFirmwareViewController.m_firmwareAvailableMinorVersion = 0;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        // Get the new binary
        [g_fileController precacheFile:cloudResponse.m_responseFileId];
        
        m_titleFirmwareViewController.m_firmwareFileId = cloudResponse.m_responseFileId;
        m_titleFirmwareViewController.m_firmwareAvailableMajorVersion = cloudResponse.m_responseFirmwareMajorVersion;
        m_titleFirmwareViewController.m_firmwareAvailableMinorVersion = cloudResponse.m_responseFirmwareMinorVersion;
        
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        [settings setInteger:m_titleFirmwareViewController.m_firmwareFileId forKey:@"FirmwareFileId"];
        [settings setInteger:m_titleFirmwareViewController.m_firmwareAvailableMajorVersion forKey:@"FirmwareMajorVersion"];
        [settings setInteger:m_titleFirmwareViewController.m_firmwareAvailableMinorVersion forKey:@"FirmwareMinorVersion"];
        
        [settings synchronize];
        
    }
    else
    {
        
        //
        // If we failed to get the new one, get the old one.
        //
        NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
        
        NSInteger firmwareFileId = [settings integerForKey:@"FirmwareFileId"];
        NSInteger firmwareMajorVersion = [settings integerForKey:@"FirmwareMajorVersion"];
        NSInteger firmwareMinorVersion = [settings integerForKey:@"FirmwareMinorVersion"];
        
        if ( firmwareFileId != 0 &&
             firmwareMajorVersion != 0 &&
             firmwareMinorVersion != 0 )
        {
            m_titleFirmwareViewController.m_firmwareFileId = firmwareFileId;
            m_titleFirmwareViewController.m_firmwareAvailableMajorVersion = firmwareMajorVersion;
            m_titleFirmwareViewController.m_firmwareAvailableMinorVersion = firmwareMinorVersion;
        }
        
    }
    
    [self compareVersions];
    
}

- (void)compareVersions
{
    
    if ( (m_titleFirmwareViewController.m_firmwareCurrentMajorVersion == 0) &&
         (m_titleFirmwareViewController.m_firmwareCurrentMinorVersion == 0) )
    {
        // Not available
        return;
    }
    
    if ( (m_titleFirmwareViewController.m_firmwareAvailableMajorVersion == 0) &&
         (m_titleFirmwareViewController.m_firmwareAvailableMinorVersion == 0) )
    {
        // Not available
        return;
    }
    
    if ( m_titleFirmwareViewController.m_firmwareAvailableMajorVersion >
         m_titleFirmwareViewController.m_firmwareCurrentMajorVersion )
    {
        [m_titleFirmwareViewController forceUpdate:self.view];
    }
    
    if ( (m_titleFirmwareViewController.m_firmwareAvailableMajorVersion == m_titleFirmwareViewController.m_firmwareCurrentMajorVersion) &&
         (m_titleFirmwareViewController.m_firmwareAvailableMinorVersion > m_titleFirmwareViewController.m_firmwareCurrentMinorVersion) )
    {
        [m_titleFirmwareViewController forceUpdate:self.view];
    }
    
}

#pragma mark - PopupViewControllerDelegate

- (void)popupClosed:(PopupViewController *)popup
{
    
    if ( popup == m_tutorialViewController )
    {
        [self displayTutorialIndexPopup];
    }
    
}

#pragma mark - AccountViewControllerDelegate

- (void)songPlayerDisplayUserProfile:(UserProfile*)userProfile
{
    [self accountViewDisplayUserProfile:userProfile];
}

- (void)songPlayerDisplayUserSong:(UserSong*)userSong
{
    [self accountViewDisplayUserSong:userSong];
}

#pragma mark - AccountViewControllerDelegate

- (void)accountViewDisplayUserProfile:(UserProfile*)userProfile
{
    
    if ( g_cloudController.m_loggedIn == NO )
    {
        [self displayWelcomeDialog];
        return;
    }
    
    m_requireLogin = YES;
    
    UserProfileNavigationController * navController = [[UserProfileNavigationController alloc] initWithNibName:@"CustomNavigationViewController" bundle:nil];
        
    navController.m_shortcutUserProfile = userProfile;
    navController.m_delegate = self;
    
    [self.navigationController pushViewController:navController animated:YES];
    
    [navController release];
    
}

- (void)accountViewDisplayUserSong:(UserSong*)userSong
{
    
    if ( g_cloudController.m_loggedIn == NO )
    {
        [self displayLoggedOutPopup];
        return;
    }
    
    m_requireLogin = YES;
    
//    StoreNavigationViewController * sfvc = [[StoreNavigationViewController alloc] initWithNibName:@"CustomNavigationViewController" bundle:nil];
//    
//    sfvc.m_shortcutUserSong = userSong;
//    
//    [self.navigationController pushViewController:sfvc animated:YES];
//    
//    [sfvc release];
    
}

- (void)accountViewDisplayUserSongSession:(UserSongSession*)session
{
    
//    if ( g_cloudController.m_loggedIn == NO )
//    {
//        [self displayLoggedOutPopup];
//        return;
//    }

    // We could precache these, but adding a bit of sync latency here isn't really noticeable,
    // and we won't use most of the xmp blobs anyways.
    NSString * xmpBlob = [g_fileController getFileOrDownloadSync:session.m_xmpFileId];
    
    if ( xmpBlob == nil )
    {
        [self displayLoggedOutPopup];
        return;
    }
    
    session.m_xmpBlob = xmpBlob;
    
    // Song playback view controller, loaded lazily so as not to slow down app load
    if ( m_songPlaybackViewController == nil )
    {
        m_songPlaybackViewController = [[SongPlayerViewController alloc] initWithNibName:nil bundle:nil];
        m_songPlaybackViewController.m_closeButtonImage = [UIImage imageNamed:@"XButtonRev.png"];
        m_songPlaybackViewController.m_popupDelegate = self;
        m_songPlaybackViewController.m_delegate = self;
    }
    
    [m_songPlaybackViewController attachToSuperView:self.view andPlaySongSession:session];

}

#pragma mark - UserProfileNavControllerDelegate

- (void)userProfileNavControllerDisplaySong:(UserSong*)userSong
{
    [m_displayUserSong release];
    
    m_displayUserSong = [userSong retain];
}

- (void)userProfileNavControllerLogout
{
    [self logoutButtonClicked:nil];
}

#pragma mark - GtarControllerObserver

- (void)gtarConnected
{
    
    [m_gtarLogoRed setHidden:YES];
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    //
    // First log in, show the welcome screens
    //
	if ( guitarConnectedBefore == NO )
	{
        
        [settings setBool:YES forKey:@"GuitarConnectedBefore"];
        
        [settings synchronize];
        
        [m_titleGatekeeperViewController detachFromSuperview];
        
        [self displayWelcomeDialog];
        
    }
    
    [g_gtarController turnOffAllEffects];
    [g_gtarController turnOffAllLeds];
    [g_gtarController sendDisableDebug];
    
    [self playStartupLightSequence];
    
    [self checkCurrentFirmwareVersion];
    
}

- (void)gtarDisconnected
{
    [m_infoPopup detachFromSuperView];
    
    [m_gtarLogoRed setHidden:NO];
}

#pragma mark - GtarControllerDelegate

- (void)receivedFirmwareMajorVersion:(int)majorVersion andMinorVersion:(int)minorVersion
{
    
    NSLog(@"Receiving firmware version: %d.%d", majorVersion, minorVersion);
    
    m_titleFirmwareViewController.m_firmwareCurrentMajorVersion = majorVersion;
    m_titleFirmwareViewController.m_firmwareCurrentMinorVersion = minorVersion;
    
    [self checkAvailableFirmwareVersion];
    
}

#pragma mark - FacebookDelegate

- (void)fbDidLogin
{
    
    [m_titleFacebookViewController endSpinner];
    
    m_waitingForFacebook = NO;
    
    // We save the access token to the user settings
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setObject:[g_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [settings setObject:[g_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
    
    // Log into our server
    [m_titleFacebookViewController doneButtonClicked:nil];
    
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    m_waitingForFacebook = NO;
//    [self displayWelcomeDialog];
    [m_titleFacebookViewController loginFailed];
}

- (void)fbDidLogout
{
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    // Clear cached data
    [settings removeObjectForKey:@"FBAccessTokenKey"];
    [settings removeObjectForKey:@"FBExpirationDateKey"];
    
    [settings synchronize];
    
    [self displayWelcomeDialog];
    
}

- (void)fbSessionInvalidated
{
    [self displayWelcomeDialog];
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
    
}

@end

