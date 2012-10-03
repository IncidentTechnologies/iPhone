//
//  TitleFacebookViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "TitleFacebookViewController.h"

#import "RootViewController.h"

@implementation TitleFacebookViewController

@synthesize m_userController;
@synthesize m_statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_fullScreenSpinnerView removeFromSuperview];
    
    [m_userController release];
    [m_statusLabel release];
    
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_statusLabel = nil;
    
}

- (void)startSpinner
{
    
    m_fullScreenSpinnerView = [[UIView alloc] initWithFrame:self.view.frame];
    m_fullScreenSpinnerView.backgroundColor = [UIColor blackColor];
    m_fullScreenSpinnerView.alpha = 0.2;
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    spinner.center = m_fullScreenSpinnerView.center;
    
    [m_fullScreenSpinnerView addSubview:spinner];
    [self.view addSubview:m_fullScreenSpinnerView];

    [spinner startAnimating];
    
    [spinner release];
    [m_fullScreenSpinnerView release];
    
}

- (void)endSpinner
{
    
    [m_fullScreenSpinnerView removeFromSuperview];
    
    m_fullScreenSpinnerView = nil;
    
}

- (void)loginFailed
{
    
//    [self endSpinner];
    
//    [m_rootViewController displayWelcomeDialog];
    
    [m_statusLabel setText:@"Facebook login failed"];
    [m_statusLabel setHidden:NO];
    
    // Let them see the error msg before backing up
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:m_rootViewController selector:@selector(displayWelcomeDialog) userInfo:nil repeats:NO];

}

- (void)attachToSuperview:(UIView *)view
{
    
    [m_statusLabel setHidden:YES];
    
    [super attachToSuperview:view];
    
}

#pragma mark - Button clicked handlers


- (IBAction)backButtonClicked:(id)sender
{
    
    [m_rootViewController returnToPreviousFullScreenDialog];
    
    // The user is giving up on facebook, log us out
    [g_facebook logout];
    
}

- (IBAction)doneButtonClicked:(id)sender
{
    
    [m_statusLabel setHidden:YES];
    
    [self startSpinner];

    // Log in with facebook
    [m_userController requestLoginUserFacebookToken:g_facebook.accessToken
                                     andCallbackObj:self
                                     andCallbackSel:@selector(loginCallback:)];
    
}

- (void)loginCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        [m_statusLabel setText:userResponse.m_statusText];
        [m_statusLabel setHidden:NO];
        return;
    }
    
    // otherwise it is successful
    [m_rootViewController userLoggedIn];
    
    [self detachFromSuperview];
    
}

@end
