//
//  MenuSignupViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 2/29/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "MenuSignupViewController.h"
#import "MenuNavigationViewController.h"

@implementation MenuSignupViewController

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
    
    // kinda hacky but can't figure out any better way
    self.view.frame = CGRectMake( 0, 0, 480, 320 );

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button click handlers

- (IBAction)logoutButtonClicked:(id)sender
{
    
    [(MenuNavigationViewController*)m_navigationController displayLoginViewController];
    
}

@end
