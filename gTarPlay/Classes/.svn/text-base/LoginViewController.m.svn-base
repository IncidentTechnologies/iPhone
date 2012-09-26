//
//  LoginViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/16/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "LoginViewController.h"

#import <MarqueeExpandingRoundedRectangleView.h>
#import <RoundedRectangleView.h>
#import <RoundedRectangleButton.h>

#import <CloudController.h>
#import <CloudResponse.h>

#import "PlaySettingsController.h"
#import "UserSettingsController.h"

#import "LegacySignupViewController.h"

#if 0 

extern CloudController * g_cloudController;
extern PlaySettingsController * g_settings;
extern UserSettingsController * g_userSettings;

@implementation LoginViewController

@synthesize m_delegate;

@synthesize m_loginActiveAreaView;
@synthesize m_loginLargeView;
@synthesize m_loginSmallView;
@synthesize m_loginMarqueeView;
@synthesize m_loginOptionsButtons;

@synthesize m_loginButton;
@synthesize m_logoutButton;
@synthesize m_facebookLoginButton;

@synthesize m_loginStatus;
@synthesize m_loginError;

@synthesize m_loginUsernameField;
@synthesize m_loginPasswordField;

@synthesize m_loginActivityIndicator;

@synthesize m_screenButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        m_signupViewController = [[LegacySignupViewController alloc] initWithNibName:nil bundle:nil];
        
        m_signupViewController.m_delegate = self;
        
        
    }
    
    return self;
    
}

- (void)dealloc
{
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
    
	// fit this to where it belongs    
    [m_loginMarqueeView resizeViewWithFrame:m_loginSmallView.frame overTimeInterval:0];
    [self.view insertSubview:m_loginMarqueeView belowSubview:m_loginActiveAreaView];
    
    m_loginButton.center = m_loginActiveAreaView.center;
    m_logoutButton.center = m_loginActiveAreaView.center;
    m_loginActivityIndicator.center = m_loginActiveAreaView.center;
    
    [self.view addSubview:m_loginButton];
    [self.view addSubview:m_logoutButton];
    [self.view addSubview:m_loginActivityIndicator];
    
    //
    // Misc visual tweaks
    //
    
//    m_loginButton.m_backgroundView.m_lineWidth = 1;
//	m_logoutButton.m_backgroundView.m_lineWidth = 1;
    
    m_loginMarqueeView.m_lineWidth = 0;
    
    // This resets the style back to the 'normal' style that IB won't let us do
	m_loginUsernameField.borderStyle = UITextBorderStyleRoundedRect;
	m_loginPasswordField.borderStyle = UITextBorderStyleRoundedRect;
    
    // hide stuff we don't want to see initially
	[self hideView:m_loginError];
	[self hideView:m_loginStatus];
	[self hideView:m_logoutButton];

	m_newsTickerView.alpha = 0.0f;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [m_screenButton removeFromSuperview];
    
    self.m_screenButton = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Misc Helpers

- (void)attemptLoginWithUsername:(NSString*)username andPassword:(NSString*)password
{
    
    [m_loginUsernameField setText:username];
    [m_loginPasswordField setText:password];
    
    [self attemptLogin];
    
}

- (void)attemptLogin
{
	
    g_settings.m_username = m_loginUsernameField.text;
    g_settings.m_password = m_loginPasswordField.text;
    
    if ( g_settings.m_username != nil && [g_settings.m_username length] > 0 &&
         g_settings.m_password != nil && [g_settings.m_password length] > 0 )
	{
		
		[self authenticatingMode];
		
		[g_cloudController requestLoginUsername:g_settings.m_username
									andPassword:g_settings.m_password
								 andCallbackObj:self andCallbackSel:@selector(requestLoginCallback:)];
		
	}
	else 
	{
		[self offlineMode];
	}
	
}

- (void)attemptCachedLogin
{

    [m_loginUsernameField setText:g_settings.m_username];
    [m_loginPasswordField setText:g_settings.m_password];

    [self attemptLogin];
    
}

#pragma mark - View state changes

- (IBAction)loginButtonClicked:(id)sender
{
    
    [self attemptLogin];
    
}

- (IBAction)logoutButtonClicked:(id)sender
{

    [g_cloudController requestLogoutCallbackObj:self
                                 andCallbackSel:@selector(requestLogoutCallback:)];
    
//	[g_cloudController requestLogoutUsername:g_settings.m_username
//								 andPassword:g_settings.m_password
//							  andCallbackObj:self
//							  andCallbackSel:@selector(requestLogoutCallback:)];
    	
}

- (IBAction)screenButtonClicked:(id)sender
{
    
    [m_loginUsernameField resignFirstResponder];
    [m_loginPasswordField resignFirstResponder];
    
    [m_screenButton removeFromSuperview];
    
}

- (IBAction)facebookLoginButtonClicked:(id)sender
{
    
    [m_delegate loginFacebookLogin];
    
}

- (IBAction)signupButtonClicked:(id)sender
{
    
    UIView * superView = [self.view superview];
    
    [m_signupViewController attachToSuperView:superView];
    
}

- (IBAction)profileButtonClicked:(id)sender
{
    [m_delegate loginShowProfile];    
}

#pragma mark - View state changes

- (void)authenticatingMode
{
    
	// hide the error (if shown) and display the spinner
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
    
	[self hideView:m_loginButton];
	[self hideView:m_logoutButton];	
	[self hideView:m_loginError];
	
	[self showView:m_loginActivityIndicator];
    
	[m_loginActivityIndicator startAnimating];
    
	[UIView commitAnimations];
    
}

- (void)offlineMode
{
    
    g_settings.m_username = nil;
    g_settings.m_password = nil;
    
    [g_settings saveArchive];
    
    [self stopNewsTicker];
    
	// hide all buttons, show the button we want
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	
	[self hideView:m_loginActivityIndicator];
	[self hideView:m_logoutButton];
	
	[self showView:m_loginButton];
    
    m_loginOptionsButtons.alpha = 1.0f;
	
	[m_loginActivityIndicator stopAnimating];
	
	[UIView commitAnimations];
	
	// this has to be outside the expansion animation otherwise we get some clipping
	[self hideView:m_loginStatus];

	m_newsTickerView.alpha = 0.0f;
    
	[m_loginMarqueeView resizeViewWithFrame:m_loginSmallView.frame overTimeInterval:0.3f];
    
}

- (void)authenticatedMode
{
	
    // save the credentials for next time
    [g_settings saveArchive];
	
	NSString * status = [NSString stringWithFormat:@"hello, %@.", g_settings.m_username];
	
//	[m_loginStatus setText:status];
    [m_loginStatus setTitle:status forState:UIControlStateNormal];
    
    if ( m_newsStories == nil )
    {
        [self getNewsHeadlines];
    }
    else 
    {
        [self startNewsTicker];
    }
    
	// hide the spinner and the text fields (if shown)
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	
	[self hideView:m_loginError];
	[self hideView:m_loginActivityIndicator];
    
	[self showView:m_loginStatus];
	[self showView:m_logoutButton];
	
	[m_loginActivityIndicator stopAnimating];
    
    m_loginOptionsButtons.alpha = 0.0f;
    
	[UIView commitAnimations];
	
	[m_loginMarqueeView resizeViewWithFrame:m_loginLargeView.frame overTimeInterval:0.3f];
    
    [m_delegate loginSucceeded];
    
}

- (void)authenticationFailedMode
{

	NSString * status = [NSString stringWithFormat:@"incorrect"];
	
	[m_loginError setText:status];
    
	// hide the status and show the error
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
    
	[self hideView:m_loginActivityIndicator];
	
	[self showView:m_loginError];
	[self showView:m_loginButton];
	
	[m_loginActivityIndicator stopAnimating];
	
	[UIView commitAnimations];
	
    [m_delegate loginFailed];
	
}

- (void)connectionFailedMode
{
	
	NSString * status = [NSString stringWithFormat:@"Connection error."];
	
	[m_loginError setText:status];
    
	// hide all buttons, show the button we want
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	
	[self hideView:m_loginActivityIndicator];
	
	[self showView:m_loginError];
	[self showView:m_loginButton];	
	
	[m_loginActivityIndicator stopAnimating];
	
	[UIView commitAnimations];
	
}

#pragma mark - CloudController Callbacks

- (void)requestLoginCallback:(CloudResponse*)cloudResponse
{
	
	if ( cloudResponse.m_status == CloudResponseStatusSuccess )
	{
		
		// Login successful, get the users settings
		NSString * userSettingsString = [NSString stringWithFormat:@"UserSettings.%@", g_settings.m_username];
		
		g_userSettings = [[UserSettingsController settingsWithName:userSettingsString] retain];
        
		// how many times has this user run the program?
		g_userSettings.m_timesLoggedin++;
		
		[g_userSettings saveArchive];
		
		[self authenticatedMode];
		
	}
	else if ( cloudResponse.m_status == CloudResponseStatusConnectionError )
	{
        
		[self connectionFailedMode];
        
        
		
	}
	else
	{
		
		[self authenticationFailedMode];
        
	}
    
}

- (void)requestLogoutCallback:(CloudResponse*)cloudResponse
{
	
	[self offlineMode];
	
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
     if ( textField == m_loginUsernameField )
     {
     
         [m_loginPasswordField becomeFirstResponder];
     
     }
     else if ( textField == m_loginPasswordField )
     {
     
         [textField resignFirstResponder];
     
         [self loginButtonClicked:textField];
     
         [m_screenButton removeFromSuperview];
     
     }
         
    return NO;

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    UIView * superView = [self.view superview];
    
    m_screenButton.frame = superView.frame;
    
    [superView insertSubview:m_screenButton belowSubview:self.view];
    //[superView addSubview:m_screenButton];
    
}

#pragma mark - Signup delegate 

- (void)legacySignupSucceeded
{
    
    // attempt login with new username password
    m_loginUsernameField.text = m_signupViewController.m_signupUsernameField.text;
    m_loginPasswordField.text = m_signupViewController.m_signupPassword1Field.text;
    
    [self attemptLogin];
    
}

- (void)legacySignupFailed
{
    
    // nothing worth doing here
    
}

#pragma mark - View helpers

- (void)hideView:(UIView*)v
{
	v.alpha = 0.0f;
	v.transform = CGAffineTransformMakeScale( 0.1f, 0.1f );
}

- (void)showView:(UIView*)v
{
	v.alpha = 1.0f;
	v.transform = CGAffineTransformIdentity;
}

@end

#endif
