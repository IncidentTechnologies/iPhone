//
//  MenuViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 2/29/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController

@synthesize m_loginView;
@synthesize m_signupView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        [self.view addSubview:nil];
    }
    
    return self;
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    
    [m_loginView release];
    [m_signupView release];
    
    [super dealloc];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - View management

- (IBAction)attachLoginView
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    
    [self.view addSubview:m_loginView];
    
    [UIView commitAnimations];
    
}

- (IBAction)removeLoginView
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
    
    [m_loginView removeFromSuperview];
    
    [UIView commitAnimations];
    
}

- (void)attachSignupView
{
    
    
}

- (void)removeSignupView
{
    
    
}


@end
