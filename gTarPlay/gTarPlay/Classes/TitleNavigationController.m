//
//  TitleNavigationController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/11/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TitleNavigationController.h"
#import "ActivityFeedCell.h"
#import "SelectorControl.h"
#import "CyclingTextField.h"
#import "SlidingModalViewController.h"

#define NOTIFICATION_GATEKEEPER_SIGNIN @"Please connect your gTar to sign up for an account."

@interface TitleNavigationController ()
{
    UIView *_currentLeftPanel;
    UIView *_currentRightPanel;
    
    UIButton *_fullScreenButton;
    
    MPMoviePlayerController *_moviePlayer;
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
    
    [_feedSelectorControl setTitles:[NSArray arrayWithObjects:@"HISTORY", @"GLOBAL", @"NEWS",nil]];
    
    [self hideNotification];
    
    // Apparently the view doesn't get resized to iPhone 5 dimensions until after viewDidLoad
    [self performSelectorOnMainThread:@selector(swapLeftPanel:) withObject:_gatekeeperLeftPanel waitUntilDone:NO];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    BOOL guitarConnectedBefore = [settings boolForKey:@"GuitarConnectedBefore"];
    
    if ( guitarConnectedBefore == NO )
    {
        //
        // Display a gatekeeping view
        //
        [self swapLeftPanel:_gatekeeperLeftPanel];
        [self swapRightPanel:_videoRightPanel];
        
        [_gatekeeperVideoButton setEnabled:NO];
    }
    else
    {
        // See if the user is logged in
//        [self checkUserLoggedIn];
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
}

- (void)hideNotification
{
    [_notificationLabel.superview setHidden:YES];
    
    _topBarView.backgroundColor = [UIColor colorWithRed:2.0/256.0 green:160.0/256.0 blue:220.0/256.0 alpha:1.0];
}

#pragma mark - Panel management

- (void)swapRightPanel:(UIView *)rightPanel
{
    
    [_currentRightPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [rightPanel setFrame:CGRectMake(0, 0, _rightPanel.frame.size.width, _rightPanel.frame.size.height )];;
    
    [_rightPanel addSubview:rightPanel];
    
    _currentRightPanel = rightPanel;
    
}

- (void)swapLeftPanel:(UIView *)leftPanel
{
    
    [_currentLeftPanel removeFromSuperview];
    
    // Resize the subview as appropriate
    [leftPanel setFrame:CGRectMake(0, 0, _leftPanel.frame.size.width, _leftPanel.frame.size.height )];;
    
    [_leftPanel addSubview:leftPanel];
    
    _currentLeftPanel = leftPanel;
    
}

- (IBAction)loggedoutSigninButtonClicked:(id)sender
{
    [_loggedoutSignupButton setEnabled:YES];
    [_loggedoutSigninButton setEnabled:NO];
    
}

- (IBAction)loggedoutSignupButtonClicked:(id)sender
{
    [_loggedoutSigninButton setEnabled:YES];
    [_loggedoutSignupButton setEnabled:NO];
    
}

- (IBAction)gatekeeperVideoButtonClicked:(id)sender
{
    [_gatekeeperSigninButton setEnabled:YES];
    [_gatekeeperVideoButton setEnabled:NO];
    
    [self hideNotification];
    
    [self swapRightPanel:_videoRightPanel];
}

- (IBAction)gatekeeperSigninButtonClicked:(id)sender
{
    [_gatekeeperVideoButton setEnabled:YES];
    [_gatekeeperSigninButton setEnabled:NO];
    
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
    [self swapRightPanel:_feedRightPanel];
}

- (IBAction)menuFreePlayButtonClicked:(id)sender
{
    // Start free play mode
    [self presentViewController:_activityFeedModal animated:NO completion:NULL];
    
}

- (IBAction)menuStoreButtonClicked:(id)sender
{
    // Start store mode
    
}

- (IBAction)feedSelectorChanged:(id)sender
{
    
}

- (IBAction)signupButtonClicked:(id)sender {
}

- (IBAction)signupFacebookButtonClicked:(id)sender {
}

- (IBAction)signinButtonClicked:(id)sender {
}

- (IBAction)signinFacebookButtonClicked:(id)sender {
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
	// Return the number of rows in the section.
//    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
//    {
//        // Friends
//        return [m_friendFeed count];
//    }
//    
//    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
//    {
//        // Global
//        return [m_globalFeed count];
//    }
    
    // Should never happen
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString *CellIdentifier = @"ActivityFeedCell";

	ActivityFeedCell *cell = (ActivityFeedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
	{
		
		cell = [[[ActivityFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"ActivityFeedCell" owner:cell options:nil];
        
        [cell setFrame:CGRectMake(0, 0, _feedTable.frame.size.width*2, _feedTable.rowHeight)];
        [cell.accessoryView setFrame:CGRectMake(0, 0, _feedTable.frame.size.width*2, _feedTable.rowHeight)];
	}

//	// Clear these in case this cell was previously selected
//	cell.highlighted = NO;
//	cell.selected = NO;
//	
//    NSInteger row = [indexPath row];
//    
//    UserSongSession * session = nil;
//    
//    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
//    {
//        if ( row < [m_friendFeed count] )
//        {
//            session = [m_friendFeed objectAtIndex:row];
//        }
//    }
//    
//    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
//    {
//        if ( row < [m_globalFeed count] )
//        {
//            session = [m_globalFeed objectAtIndex:row];
//        }
//    }
//    
//    cell.m_userSongSession = session;
//    
//    [cell updateCell];
//    
	return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 41;
//}

- (void)update
{
    
}

#pragma mark - Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    // We only want one cell to be clicked on at a time
//    m_displayingCell = YES;
//    
//    // Cause the row to spin until the session has started
//    AccountViewCell * cell = (AccountViewCell*)[m_tableView cellForRowAtIndexPath:indexPath];
//    
//    [cell.m_timeLabel setHidden:YES];
//    [cell.m_activityView startAnimating];
//    
//    [self performSelector:@selector(playCell:) withObject:cell afterDelay:0.05];
    
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

@end
