//
//  LegacySignupViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/23/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "LegacySignupViewController.h"
#import "RoundedRectangleView.h"
#import "RoundedRectangleButton.h"

#import <CloudController.h>
#import <CloudResponse.h>

extern CloudController * g_cloudController;

@implementation LegacySignupViewController

@synthesize m_delegate;
@synthesize m_signupUsernameField;
@synthesize m_signupEmailField;
@synthesize m_signupPassword1Field;
@synthesize m_signupPassword2Field;

@synthesize m_signupDoneButton;

@synthesize m_signupStatus;

@synthesize m_signupActivityIndicator;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    // force linking
    [RoundedRectangleButton class];
    
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
    [m_signupPassword1Field release];
    [m_signupPassword2Field release];
    
	[m_signupDoneButton release];
    
	[m_signupStatus release];
    
    [m_signupActivityIndicator release];

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
    self.m_signupPassword1Field = nil;
    self.m_signupPassword2Field = nil;
    
	self.m_signupDoneButton = nil;
    
	self.m_signupStatus = nil;
    
    self.m_signupActivityIndicator = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // do stuff
    
    m_signupUsernameField.text = @"";
    m_signupEmailField.text = @"";
    m_signupPassword1Field.text = @"";
    m_signupPassword2Field.text = @"";
    
    [m_signupUsernameField becomeFirstResponder];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma Clicked button handlers

/*
- (IBAction)closeButtonClicked:(id)sender
{
 
    
    [super closeButtonClicked:sender];
    
}
*/

- (IBAction)doneButtonClicked:(id)sender
{
    
    [m_signupStatus setHidden:YES];

    if ( m_signupUsernameField.text == nil || [m_signupUsernameField.text isEqualToString:@""] )
    {
        [m_signupStatus setHidden:NO];
        [m_signupStatus setText:@"Username invalid"];
        return;
    }

    if ( m_signupEmailField.text == nil || [m_signupEmailField.text isEqualToString:@""] )
    {
        [m_signupStatus setHidden:NO];
        [m_signupStatus setText:@"Email invalid"];
        return;
    }

    if ( m_signupPassword1Field.text == nil || [m_signupPassword1Field.text isEqualToString:@""] ||
         [m_signupPassword1Field.text isEqualToString:m_signupPassword2Field.text] == NO )
    {
        [m_signupStatus setHidden:NO];
        [m_signupStatus setText:@"Password invalid"];
        return;
    }

    [m_signupActivityIndicator startAnimating];
    [m_signupDoneButton setHidden:YES];
    
    // register the user
    
    [g_cloudController requestRegisterUsername:m_signupUsernameField.text
								   andPassword:m_signupPassword1Field.text
									  andEmail:m_signupEmailField.text
								andCallbackObj:self
								andCallbackSel:@selector(requestRegisterCallback:) ];
}
/*
- (IBAction)screenButtonClicked:(id)sender
{
    [m_signupUsernameField resignFirstResponder];
    [m_signupEmailField resignFirstResponder];
    [m_signupPassword1Field resignFirstResponder];
    [m_signupPassword2Field resignFirstResponder];

}
*/

#pragma -
#pragma mark UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ( textField == m_signupUsernameField )
    {
        [m_signupEmailField becomeFirstResponder];
    }
    
    if ( textField == m_signupEmailField )
    {
        [m_signupPassword1Field becomeFirstResponder];
    }

    if ( textField == m_signupPassword1Field )
    {
        [m_signupPassword2Field becomeFirstResponder];
    }

    if ( textField == m_signupPassword2Field )
    {

//        [m_signupPassword2Field resignFirstResponder];
        [self doneButtonClicked:nil];

    }

	return NO;
    
}

#pragma -
#pragma CloudController callbacks

- (void)requestRegisterCallback:(CloudResponse*)cloudResponse
{
    
     // need to check success or fail
     if ( cloudResponse.m_status == CloudResponseStatusSuccess )
     {

         [m_delegate legacySignupSucceeded];
         
         [self closeButtonClicked:nil];

     }
     else 
     {
     
         [m_signupStatus setHidden:NO];
         [m_signupStatus setText:cloudResponse.m_statusText];
     
         NSLog( cloudResponse.m_receivedDataString );
 
         [m_delegate legacySignupFailed];
     
     }

    [m_signupActivityIndicator stopAnimating];
    [m_signupDoneButton setHidden:NO];
    
}



@end
