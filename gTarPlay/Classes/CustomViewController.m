//
//  CustomViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "CustomViewController.h"

#import "CustomNavigationViewController.h"

@implementation CustomViewController

@synthesize m_navigationController;
@synthesize m_previousViewController;

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // kinda hacky but can't figure out any better way
    self.view.frame = CGRectMake( 0, 0, 480, 276 );

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_navigationController = nil;
    self.m_previousViewController = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Common methods

- (IBAction)returnButtonClicked:(id)sender
{
    [m_navigationController returnToPreviousViewController:self];
}

@end
