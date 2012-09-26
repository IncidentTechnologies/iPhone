//
//  FacebookSignupViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/20/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "FacebookSignupViewController.h"
#import <CloudController.h>
#import <CloudResponse.h>

extern CloudController * g_cloudController;

@implementation FacebookSignupViewController

@synthesize m_delegate;
@synthesize m_signupUsernameField;
@synthesize m_signupEmailField;
@synthesize m_screenButton;
@synthesize m_errorLabel;
@synthesize m_doneButton;
@synthesize m_activityIndicatorView;

@synthesize m_accessToken;

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
    
    [m_signupUsernameField release];
    [m_signupEmailField release];
    [m_activityIndicatorView release];
    [m_doneButton release];
//    [m_screenButton release];
    [m_accessToken release];
    
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
    
    self.m_closeButtonImage = [UIImage imageNamed:@"XButton.png"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_signupUsernameField = nil;
    self.m_signupEmailField = nil;
    self.m_doneButton = nil;
    self.m_activityIndicatorView = nil;
//    self.m_screenButton = nil;
    self.m_accessToken = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    
//    UIView * superView = [self.view superview];
    
//    m_screenButton.frame = superView.frame;

//    [m_screenButton setHidden:YES];

//    [superView addSubview:m_screenButton ];

    [m_signupUsernameField becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
//    [m_screenButton removeFromSuperview];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma Button clicked handlers

- (IBAction)signupButtonClicked:(id)sender
{
    
    // attempt signup
    [self signup];
    
}

- (IBAction)closeButtonClicked:(id)sender
{
    
    [m_delegate facebookSignupFailed];
    
    [super closeButtonClicked:sender];
    
}


#pragma -
#pragma Misc helpers

- (void)signup
{
    
    [m_errorLabel setHidden:YES];
    
    if ( m_accessToken == nil )
    {
        [m_errorLabel setHidden:NO];
        [m_errorLabel setText:@"Invalid access token"];

        [m_delegate facebookSignupFailed];
        
        return;
    }

    if ( m_signupUsernameField.text == nil || [m_signupUsernameField.text isEqualToString:@""])
    {
        [m_errorLabel setHidden:NO];
        [m_errorLabel setText:@"Invalid username"];
        
        return;
    }
    
    if ( m_signupEmailField.text == nil || [m_signupEmailField.text isEqualToString:@""])
    {
        [m_errorLabel setHidden:NO];
        [m_errorLabel setText:@"Invalid email"];
        
        return;
    }

    [m_doneButton setHidden:YES];
    [m_activityIndicatorView startAnimating];

    [g_cloudController requestRegisterUsername:m_signupUsernameField.text
                        andFacebookAccessToken:m_accessToken
                                      andEmail:m_signupEmailField.text
                                andCallbackObj:self
                                andCallbackSel:@selector(signupCallback:)];
    
}

- (void)signupCallback:(CloudResponse*)cloudResponse
{
    
    [m_doneButton setHidden:NO];
    [m_activityIndicatorView stopAnimating];

    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [m_errorLabel setHidden:NO];
        [m_errorLabel setText:@"Registration succeeded"];
        
        [m_delegate facebookSignupSucceeded];
        
    }
    else
    {
        
        [m_errorLabel setHidden:NO];
        [m_errorLabel setText:@"Registration failed"];
        
        [m_delegate facebookSignupFailed];

    }

}

#pragma -
#pragma Text field delegate


- (IBAction)textFieldSelected:(id)sender
{
    
//    [m_screenButton setHidden:NO];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	
	if ( textField == m_signupUsernameField )
	{
		
		[m_signupEmailField becomeFirstResponder];
		
	}
	else if ( textField == m_signupEmailField )
	{
		
        [m_signupEmailField resignFirstResponder];
        
//        [m_screenButton setHidden:YES];
        
        [self signup];
		
	}
	
	return NO;
}

@end
