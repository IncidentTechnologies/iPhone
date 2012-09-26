//
//  StoreBuyCreditsPopupViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 2/8/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "StoreBuyCreditsPopupViewController.h"
#import "StoreNavigationViewController.h"

@implementation StoreBuyCreditsPopupViewController

@synthesize m_navigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        
        self.m_closeButtonImage = [UIImage imageNamed:@"XButton.png"];
        
        self.m_popupTitle = @"Incident Points";
        
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
    [m_fullScreenActivityView removeFromSuperview];
    [m_fullScreenActivityView release];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button Clicked Handlers

- (void)startPurchaseAnimation
{
    
    if ( m_fullScreenActivityView == nil )
    {
        UIView * superView = [self.view superview];
        m_fullScreenActivityView = [[UIView alloc] initWithFrame:superView.frame];
        
        m_fullScreenActivityView.alpha = 0.5f;
        m_fullScreenActivityView.backgroundColor = [UIColor blackColor];
        
        UIActivityIndicatorView * activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        [activity startAnimating];
        
        [superView addSubview:m_fullScreenActivityView];
        
        activity.center = m_fullScreenActivityView.center;
        
        [m_fullScreenActivityView addSubview:activity];
        
        [activity release];

    }
    
}

- (void)purchaseSuccessful
{
    
    [m_fullScreenActivityView removeFromSuperview];
    
    [m_fullScreenActivityView release];
    
    m_fullScreenActivityView = nil;
    
    [self detachFromSuperView];
    
}

- (void)purchaseFailed:(NSString*)reason
{
    
    [m_fullScreenActivityView removeFromSuperview];
    
    [m_fullScreenActivityView release];
    
    m_fullScreenActivityView = nil;

}

#pragma mark - Button Clicked Handlers

- (IBAction)buyCreditsAClicked:(id)sender
{
    [m_navigationController buyCreditsA];
}

- (IBAction)buyCreditsBClicked:(id)sender
{
    [m_navigationController buyCreditsB];
}

- (IBAction)buyCreditsCClicked:(id)sender
{
    [m_navigationController buyCreditsC];
}

@end
