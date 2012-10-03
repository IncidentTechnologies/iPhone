//
//  MenuNavigationViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 2/29/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "MenuNavigationViewController.h"

@implementation MenuNavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        self.m_title = @"Menu";
        
        m_menuIndexViewController = [[MenuIndexViewController alloc] initWithNibName:nil bundle:nil];
        m_menuLoginViewController = [[MenuLoginViewController alloc] initWithNibName:nil bundle:nil];
        m_menuSignupViewController = [[MenuSignupViewController alloc] initWithNibName:nil bundle:nil];
        m_menuTutorialViewController = [[MenuTutorialViewController alloc] initWithNibName:nil bundle:nil];
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_menuIndexViewController release];
    [m_menuLoginViewController release];
    [m_menuSignupViewController release];
    
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
    [m_homeButton setHidden:YES];
    [m_searchBar setHidden:YES];
    
    [m_bodyView addSubview:m_menuIndexViewController.view];
    
    m_menuIndexViewController.m_navigationController = self;
    m_menuSignupViewController.m_navigationController = self;
    m_menuTutorialViewController.m_navigationController = self;
    
    m_currentViewController = m_menuIndexViewController;
    
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


#pragma mark - View controllers

- (void)displaySignupViewController
{
    
//    [self switchInViewController:m_menuSignupViewController];
    
    [self.view addSubview:m_menuSignupViewController.view];
    
}

- (void)displayLoginViewController
{
    
    [m_menuSignupViewController.view removeFromSuperview];
    
    [self switchInViewController:m_menuLoginViewController];
    
}

- (void)displayTutorialViewController
{
    
    [self.view addSubview:m_menuTutorialViewController.view];
    
}

- (void)hideTutorialViewController
{
    
    [m_menuTutorialViewController.view removeFromSuperview];
    
}


@end
