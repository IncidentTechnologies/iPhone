//
//  TitleLoginViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "TitleLoginViewController.h"

#import "RootViewController.h"

@implementation TitleLoginViewController

@synthesize m_userController;
@synthesize m_usernameTextField;
@synthesize m_passwordTextField;
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
    [m_usernameTextField release];
    [m_passwordTextField release];
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
    self.m_usernameTextField = nil;
    self.m_passwordTextField = nil;
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

- (void)expandKeyboard
{
    
    if ( m_fullScreenButton == nil )
    {
        m_fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_fullScreenButton.frame = self.view.frame;
        
        [m_fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:m_fullScreenButton];
        [self.view bringSubviewToFront:m_usernameTextField];
        [self.view bringSubviewToFront:m_passwordTextField];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.view.transform = CGAffineTransformMakeTranslation( 0, -0 );
    
    [UIView commitAnimations];
    
}

- (void)retractKeyboard
{
    
    [m_fullScreenButton removeFromSuperview];
    
    m_fullScreenButton = nil;
    
    [m_usernameTextField resignFirstResponder];
    [m_passwordTextField resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.view.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];

}

- (void)cachedLogin
{
    
    [self retractKeyboard];
    [self startSpinner];
    
    [m_statusLabel setHidden:YES];
    
    [m_usernameTextField setText:m_userController.m_loggedInUsername];
    [m_passwordTextField setText:@"dummy password"];
    
    [m_userController requestLoginUserCachedCallbackObj:self andCallbackSel:@selector(loginCallback:)];

}

#pragma mark - Button clicked handlers

- (IBAction)fullScreenButtonClicked:(id)sender
{
    
    [self retractKeyboard];
    
}

- (IBAction)signupButtonClicked:(id)sender
{
    
    [self retractKeyboard];
    
//    [m_rootViewController displaySignupDialog];
    [m_rootViewController returnToPreviousFullScreenDialog];
    
}

- (IBAction)loginButtonClicked:(id)sender
{
    
    [self retractKeyboard];
    
    [m_statusLabel setHidden:YES];
    
    if ( m_usernameTextField.text == nil || [m_usernameTextField.text isEqualToString:@""] == YES )
    {
        [m_statusLabel setText:@"Invalid username"];
        [m_statusLabel setHidden:NO];
        return;
    }
    
    if ( m_passwordTextField.text == nil || [m_passwordTextField.text isEqualToString:@""] == YES )
    {
        [m_statusLabel setText:@"Invalid password"];
        [m_statusLabel setHidden:NO];
        return;
    }
    
    [self startSpinner];
    
    [m_userController requestLoginUser:m_usernameTextField.text
                           andPassword:m_passwordTextField.text
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
        [m_passwordTextField setText:@""];
        return;
    }
    
    // otherwise it is successful
    [m_rootViewController userLoggedIn];
    
    [self detachFromSuperview];
    
}

#pragma mark - UITextField delegate

- (IBAction)textFieldSelected:(id)sender
{
    
    [self expandKeyboard];
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
        
    if ( textField == m_usernameTextField )
    {
        [m_passwordTextField becomeFirstResponder];
    }
    
    if ( textField == m_passwordTextField )
    {
        // Try to login with these creds
        [self loginButtonClicked:nil];
    }
    
	return NO;
    
}

@end
