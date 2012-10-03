//
//  FullScreenDialogViewController.m
//  gTarPlay
//
//  Created by Joel Greenia on 3/2/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "FullScreenDialogViewController.h"

@implementation FullScreenDialogViewController

@synthesize m_previousDialog;
@synthesize m_rootViewController;

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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


#pragma mark - View mgmt

- (void)attachToSuperview:(UIView*)superview
{    
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.view.alpha = 1.0f;
    
    [self.view setFrame:superview.frame];
    
    [superview addSubview:self.view];
    
}

- (void)detachFromSuperview;
{
    
    // Animate the fade out then remove the view
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationDelegate:self.view];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    
    self.view.alpha = 0.0f;
    
    [UIView commitAnimations];
    
}


@end
