//
//  FacebookLoginViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/17/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "FacebookLoginViewController.h"

#import <MarqueeExpandingRoundedRectangleView.h>
#import "PlaySettingsController.h"

#if 0 

extern PlaySettingsController * g_settings;

@implementation FacebookLoginViewController

@synthesize m_delegate;

@synthesize m_facebookLoginMarqueeView;
@synthesize m_facebookLoginBackgroundView;
@synthesize m_facebookLoginMidgroundView;
@synthesize m_facebookLoginLargeView;
@synthesize m_facebookLoginButton;
@synthesize m_facebookLogoutButton;
@synthesize m_facebookLoginActivityIndicator;
@synthesize m_facebookWelcomeLabel;
@synthesize m_facebookLoginLabel;
@synthesize m_facebookLogoutLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        
        // init some subcontrollers
        m_facebookController = [[FacebookController alloc] initWithNibName:nil bundle:nil];
        m_facebookController.m_delegate = self;    
        
        m_facebookSignupViewController = [[FacebookSignupViewController alloc] initWithNibName:nil bundle:nil];    
        m_facebookSignupViewController.m_delegate = self;        

    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_facebookLoginMarqueeView release];
    [m_facebookLoginBackgroundView release];
    [m_facebookLoginMidgroundView release];
    [m_facebookLoginLargeView release];
    [m_facebookLoginButton release];
    [m_facebookLogoutButton release];
    [m_facebookLoginActivityIndicator release];
    [m_facebookWelcomeLabel release];
    [m_facebookLoginLabel release];
    [m_facebookLogoutLabel release];
    
    [m_facebookController release];

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
    
    CGFloat midgroundColor[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
    CGFloat backgroundColor[4] = { 0.1f, 0.1f, 0.1f, 0.5f };
    
    m_facebookLoginMidgroundView.m_lineWidth = 0;
    m_facebookLoginMidgroundView.m_cornerRadius = 7;
//    [m_facebookLoginMidgroundView changeFillColor:midgroundColor];
    
    m_facebookLoginBackgroundView.m_lineWidth = 0;
    m_facebookLoginBackgroundView.m_cornerRadius = 7;
    [m_facebookLoginBackgroundView changeFillColor:backgroundColor];

    
    // Make a slightly smaller frame so we don't see the white pixels poking out.
    // Two pixels shorter should be more than enough.
    CGRect slightlySmallerFrame = CGRectMake( m_facebookLoginMidgroundView.frame.origin.x,
                                             m_facebookLoginMidgroundView.frame.origin.y,
                                             m_facebookLoginMidgroundView.frame.size.width,
                                             m_facebookLoginMidgroundView.frame.size.height - 2);
    
//    [m_facebookLoginMarqueeView resizeViewWithFrame:m_facebookLoginMidgroundView.frame overTimeInterval:0];
    [m_facebookLoginMarqueeView resizeViewWithFrame:slightlySmallerFrame overTimeInterval:0];

    m_facebookLoginMarqueeView.m_lineWidth = 0;
    m_facebookLoginMarqueeView.m_cornerRadius = 7;

    [self.view insertSubview:m_facebookLoginMarqueeView belowSubview:m_facebookLoginMidgroundView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.m_facebookLoginMarqueeView = nil;
    self.m_facebookLoginBackgroundView = nil;
    self.m_facebookLoginMidgroundView = nil;
    self.m_facebookLoginLargeView = nil;
    self.m_facebookLoginButton = nil;
    self.m_facebookLogoutButton = nil;
    self.m_facebookLoginActivityIndicator = nil;
    self.m_facebookWelcomeLabel = nil;
    self.m_facebookLoginLabel = nil;
    self.m_facebookLogoutLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma -
#pragma Misc helpers

- (void)attemptCachedLogin
{
    
    NSString * accessToken = g_settings.m_facebookAccessToken;
    
    if ( accessToken != nil )
    {
        [m_facebookLoginButton setHidden:YES];
        [m_facebookLoginActivityIndicator startAnimating];
        
        // attempt to login with what we have
        [m_facebookController loginWithFacebookToken:accessToken];
    }
    
}

#pragma -
#pragma Button clicked handlers

- (IBAction)facebookLoginButtonClicked:(id)sender
{

    [m_facebookLoginLabel setTextColor:[UIColor whiteColor]];

    // Force the user to log out before logging in.
    // This gives the user a panic button e.g. if their cookies get all screwy
    [m_facebookController logout];
    
    m_facebookController.m_closeButtonImage = [UIImage imageNamed:@"XButton.png"];
    
    [m_facebookController attachToSuperView:[self.view superview]];
    
    [m_facebookLoginActivityIndicator startAnimating];
    [m_facebookLoginButton setHidden:YES];
    
}

- (IBAction)facebookLogoutButtonClicked:(id)sender
{
    
    [m_facebookLogoutLabel setTextColor:[UIColor whiteColor]];

    [self facebookLoggedOutAnimation];
    
    [self stopNewsTicker];
    
    // clear out the access token so we don't log in next time
    g_settings.m_facebookAccessToken = nil;
    
    [g_settings saveArchive];

    // delete any cookies so we cant login
    [m_facebookController logout];
    
}

- (IBAction)facebookNoAccountButtonClicked:(id)sender
{
    
    [m_delegate facebookLegacyLogin];
    
}

- (IBAction)facebookLoginButtonTouchDown:(id)sender
{
    [m_facebookLoginLabel setTextColor:[UIColor blackColor]];
}

- (IBAction)facebookLogoutButtonTouchDown:(id)sender
{
    [m_facebookLogoutLabel setTextColor:[UIColor blackColor]];
}

- (IBAction)facebookLoginButtonTouchUpOutside:(id)sender
{
    [m_facebookLoginLabel setTextColor:[UIColor whiteColor]];
}

- (IBAction)facebookLogoutButtonTouchUpOutside:(id)sender
{
    [m_facebookLogoutLabel setTextColor:[UIColor whiteColor]];
}

- (IBAction)facebookProfileButtonClicked:(id)sender
{
    [m_delegate facebookShowProfile];
}

#pragma -
#pragma Facebook controller delegate

- (void)facebookLoginSucceeded
{
    
    [m_facebookLoginActivityIndicator stopAnimating];
    [m_facebookLoginButton setHidden:NO];
    
    [m_delegate facebookLoginSucceeded];

    g_settings.m_facebookAccessToken = m_facebookController.m_accessToken;

    [g_settings saveArchive];

    [self facebookLoggedInAnimation];
    
    [self getNewsHeadlines];
    
}

- (void)facebookLoginUserDoesntExist
{
    
    // start the signup process.
    [m_facebookController detachFromSuperView];
    
    // popup the signup view
    m_facebookSignupViewController.m_accessToken = m_facebookController.m_accessToken;
    
    [m_facebookSignupViewController attachToSuperView:[self.view superview]];
    
}

- (void)facebookLoginFailed
{
    
    [m_facebookLoginActivityIndicator stopAnimating];
    [m_facebookLoginButton setHidden:NO];

    // don't do anything, asside from notifying the delegate.
    // in this context, fail basically equals 'canceled' because
    // the fb web UI provides feedback re: inavlid un/pw.
//    [m_delegate facebookLoginSucceeded];
    
}

- (void)facebookSignupSucceeded
{
    
    // log us in
    [m_facebookSignupViewController detachFromSuperView];
    NSLog(@"token: %@",m_facebookController.m_accessToken);
    [m_facebookController loginWithFacebookToken];
    
}

- (void)facebookSignupFailed
{
    
    // do nothing, they can try again if they want.
    [m_facebookLoginActivityIndicator stopAnimating];
    [m_facebookLoginButton setHidden:NO];
    
}

#pragma -
#pragma Animation helpers

- (void)facebookLoggedInAnimation
{
    // set the welcome msg before animation
    
    NSString * message = [NSString stringWithFormat:@"Hi, %@.", m_facebookController.m_firstname];
    
//    [m_facebookWelcomeLabel setText:message];
    [m_facebookWelcomeLabel setTitle:message forState:UIControlStateNormal];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
    
    m_facebookLoginMidgroundView.alpha = 0.0f;
    
	[UIView commitAnimations];
    
//    CGRect newRect = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height );
    [m_facebookLoginMarqueeView resizeViewWithFrame:m_facebookLoginLargeView.frame overTimeInterval:0.3f];

}

- (void)facebookLoggedOutAnimation
{
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
    
    m_facebookLoginMidgroundView.alpha = 1.0f;
    
	[UIView commitAnimations];
    
    // Make a slightly smaller frame so we don't see the white pixels poking out.
    // Two pixels shorter should be more than enough.
    CGRect slightlySmallerFrame = CGRectMake( m_facebookLoginMidgroundView.frame.origin.x,
                                              m_facebookLoginMidgroundView.frame.origin.y,
                                              m_facebookLoginMidgroundView.frame.size.width,
                                              m_facebookLoginMidgroundView.frame.size.height - 2);
    
//    [m_facebookLoginMarqueeView resizeViewWithFrame:m_facebookLoginMidgroundView.frame overTimeInterval:0.3f];
    [m_facebookLoginMarqueeView resizeViewWithFrame:slightlySmallerFrame overTimeInterval:0.3f];

}

@end

#endif 