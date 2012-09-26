//
//  StorePurchaseViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/1/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StorePurchaseViewController.h"

#import "StoreNavigationViewController.h"
#import "UserSong.h"

@implementation StorePurchaseViewController

@synthesize m_currentAction;
@synthesize m_statusLabel;
@synthesize m_activityIndicator;
@synthesize m_actionButton;
@synthesize m_cancelButton;

@synthesize m_userSong;

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
    
    [m_currentAction release];
    [m_statusLabel release];
    [m_activityIndicator release];
    [m_actionButton release];
    [m_cancelButton release];

    [m_userSong release];
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_currentAction = nil;
    self.m_activityIndicator = nil;
    self.m_actionButton = nil;
    self.m_statusLabel = nil;
    self.m_cancelButton = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
    [self startPurchasing];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)startPurchasing
{
    
    [m_statusLabel setHidden:YES];
    [m_actionButton setHidden:YES];
    [m_cancelButton setHidden:YES];
    [m_backButton setHidden:YES];

    if ( m_userSong != nil )
    {
        
        NSString * action = [NSString stringWithFormat:@"Purchasing '%@'...", m_userSong.m_title];
        [m_currentAction setText:action];

    }
    else
    {

        NSString * action = [NSString stringWithFormat:@"Completing credit purchase..."];
        [m_currentAction setText:action];

    }
    
    
    [m_activityIndicator startAnimating];

}

- (void)purchaseSuccessful
{
    
    NSString * action = [NSString stringWithFormat:@"Purchased '%@'!", m_userSong.m_title];
    
    [m_currentAction setText:action];
    [m_activityIndicator stopAnimating];
    
    [m_statusLabel setHidden:YES];
    
    [m_actionButton setHidden:YES];
    [m_cancelButton setHidden:YES];
    
    [m_backButton setHidden:NO];

}

- (void)purchaseFailed:(NSString*)error
{
    
    NSString * action = [NSString stringWithFormat:@"Error purchasing '%@'!", m_userSong.m_title];
    
    [m_currentAction setText:action];
    [m_activityIndicator stopAnimating];
    
    [m_statusLabel setText:error];
    [m_statusLabel setHidden:NO];

    [m_backButton setHidden:NO];

    [m_actionButton setHidden:YES];
    [m_cancelButton setHidden:YES];
    
}

- (void)purchasePending:(NSString*)error
{
    
    NSString * action = [NSString stringWithFormat:@"Purchase pending '%@'", m_userSong.m_title];
    
    [m_currentAction setText:action];
    [m_activityIndicator stopAnimating];
    
    [m_statusLabel setText:error];
    [m_statusLabel setHidden:NO];
    
    [m_actionButton setTitle:@"Retry" forState:UIControlStateNormal];
    [m_actionButton setHidden:NO];
    [m_cancelButton setHidden:NO];
    
}

- (IBAction)actionButtonClicked:(id)sender
{
    [m_navigationController retryPurchase];

    [self startPurchasing];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [m_navigationController cancelPurchase];    
}

@end
