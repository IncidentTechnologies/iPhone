//
//  TitleSignupViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "TitleSignupViewController.h"

#import "RootViewController.h"

@implementation TitleSignupViewController

@synthesize m_userController;
@synthesize m_usernameTextField;
@synthesize m_passwordTextField;
@synthesize m_emailTextField;
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
    
    [m_userController release];
    [m_usernameTextField release];
    [m_passwordTextField release];
    [m_emailTextField release];
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
    self.m_emailTextField = nil;
    self.m_statusLabel = nil;
    
}

- (void)startSpinner
{
    
    m_fullScreenSpinnerView = [[UIView alloc] initWithFrame:self.view.frame];
    m_fullScreenSpinnerView.backgroundColor = [UIColor blackColor];
    m_fullScreenSpinnerView.alpha = 0.2;
    
    UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    spinner.center = m_fullScreenSpinnerView.center;
    
    // Bias it down from center
    spinner.transform = CGAffineTransformMakeTranslation(0, 95);
    
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
        [self.view bringSubviewToFront:m_emailTextField];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.view.transform = CGAffineTransformMakeTranslation( 0, -23 );
    
    [UIView commitAnimations];
    
}

- (void)retractKeyboard
{
    
    [m_fullScreenButton removeFromSuperview];
    
    m_fullScreenButton = nil;
    
    [m_usernameTextField resignFirstResponder];
    [m_passwordTextField resignFirstResponder];
    [m_emailTextField resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    self.view.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
    
}

#pragma mark - Button clicked handlers

- (IBAction)fullScreenButtonClicked:(id)sender
{
    
    [self retractKeyboard];
    
}

- (IBAction)loginButtonClicked:(id)sender
{
    
//    [m_rootViewController displayLoginDialog];
    [m_rootViewController returnToPreviousFullScreenDialog];
    
}

- (IBAction)signupButtonClicked:(id)sender
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
    
    [m_userController requestSignupUser:m_usernameTextField.text
                            andPassword:m_passwordTextField.text
                               andEmail:m_emailTextField.text
                         andCallbackObj:self
                         andCallbackSel:@selector(signupCallback:)];
    
}

- (void)signupCallback:(UserResponse*)userResponse
{
    
    [self endSpinner];
    
    if ( userResponse.m_status != UserResponseStatusSuccess )
    {
        [m_statusLabel setText:userResponse.m_statusText];
        [m_statusLabel setHidden:NO];
        return;
    }
    
    // it succeeded
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
        [m_emailTextField becomeFirstResponder];
    }
    
    if ( textField == m_emailTextField )
    {
        // Try to login with these creds
        [self signupButtonClicked:nil];
    }
    
	return NO;
    
}

@end
