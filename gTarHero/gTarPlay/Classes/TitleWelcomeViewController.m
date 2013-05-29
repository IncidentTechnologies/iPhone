//
//  TitleWelcomeViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/1/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "TitleWelcomeViewController.h"

#import "RootViewController.h"

@implementation TitleWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
    }
    
    return self;
    
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
}

#pragma mark - Button clicked handlers

- (IBAction)signupButtonClicked:(id)sender
{
    
    [m_rootViewController displaySignupDialog];
    
}

- (IBAction)loginButtonClicked:(id)sender
{
    
    [m_rootViewController displayLoginDialog];
    
}

- (IBAction)facebookButtonClicked:(id)sender
{
    
    [m_rootViewController displayFacebookDialog];
    
    // force us to be removed before the app looses focus
    [self.view removeFromSuperview];
    
    self.view.alpha = 0.0f;

    
}

@end
