//
//  CustomNavigationViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "CustomNavigationViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CustomViewController.h"

#import <gTarAppCore/FullScreenActivityView.h>

@implementation CustomNavigationViewController

@synthesize m_title;

@synthesize m_titleLabel;

@synthesize m_bodyView;
@synthesize m_topbarView;

@synthesize m_backButton;
@synthesize m_homeButton;
@synthesize m_notifyButton;
@synthesize m_fullScreenButton;

@synthesize m_activityIndicatorView;

@synthesize m_searchBar;
@synthesize m_searchContracted;
@synthesize m_searchExpanded;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // Custom initialization
        [FullScreenActivityView class];
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_title release];
    
    [m_titleLabel release];
    
    [m_bodyView release];
    [m_topbarView release];
    
    [m_backButton release];
    [m_homeButton release];
    [m_notifyButton release];
    [m_fullScreenButton release];
    
    [m_activityIndicatorView release];
    [m_customActivityView release];
    
    [m_currentSearchString release];
    [m_searchBar release];
    [m_searchContracted release];
    [m_searchExpanded release];
    
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [super viewDidLoad];

    //
    // Set the title
    //
    [m_titleLabel setText:m_title];
    
    m_titleLabel.shadowColor = [UIColor grayColor];
    m_titleLabel.shadowOffset = CGSizeMake(1, 1);
    
    //
    // Hide some buttons
    //
    [m_homeButton setHidden:YES];
    [m_notifyButton setHidden:YES];
    [m_fullScreenButton setHidden:YES];
    
    //
    // Setup up a nice gradiant on the top bar
    //
    UIView * gradientView;
    CAGradientLayer * gradient;
    
    gradientView = m_topbarView;
    
    UIColor * color1 = [UIColor colorWithRed:0.0f/255.0f green:174.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
    UIColor * color2 = [UIColor colorWithRed:0.0f/255.0f green:137.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    UIColor * color3 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
    UIColor * color4 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:183.0f/255.0f alpha:1.0f];
    
    gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[color1 CGColor],
                       (id)[color2 CGColor],
                       (id)[color3 CGColor],
                       (id)[color4 CGColor], nil];
    gradient.locations = [NSArray arrayWithObjects:
                          (id)[NSNumber numberWithFloat:0.0f],
                          (id)[NSNumber numberWithFloat:0.2f],
                          (id)[NSNumber numberWithFloat:0.3f],
                          (id)[NSNumber numberWithFloat:1.0f], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];

  
    // Old gradient stuff, prob should be 
    // peacock blue from maly
//    UIColor * peacockBlue = [UIColor colorWithRed:0.2f green:0.5f blue:0.7 alpha:1.0f];
//    UIColor * peacockBlueDark = [UIColor colorWithRed:0.1f green:0.25f blue:0.35 alpha:1.0f];
    
//    gradient = [CAGradientLayer layer];
//    gradient.frame = gradientView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[peacockBlue CGColor], (id)[peacockBlue CGColor], nil];
//    gradient.startPoint = CGPointMake(0.5, 0.0);
//    gradient.endPoint = CGPointMake(0.5, 1.0);
//    [gradientView.layer insertSublayer:gradient atIndex:0];
    
//    UIColor * peacockBlue = [UIColor colorWithRed:4.0/256.0 green:66.0/256.0 blue:115.0/256.0 alpha:1.0f];
//    gradient = [CAGradientLayer layer];
//    gradient.frame = gradientView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[peacockBlue CGColor], nil];
//    //    gradient.locations = [NSArray arrayWithObjects:(id)[NSNumber numberWithFloat:blackFloat], (id)[NSNumber numberWithFloat:clearFloat], (id)[NSNumber numberWithFloat:1.0], nil];
//    gradient.startPoint = CGPointMake(0.0, 0.5);
//    gradient.endPoint = CGPointMake(1.0, 0.5);
//    [gradientView.layer insertSublayer:gradient atIndex:0];

    //
    // Hide the view
    //
    for ( UIView * subview in m_searchBar.subviews ) 
    {
        if ( [subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] )
        {
            subview.alpha = 0.0f;
        }
        
        if ( [subview isKindOfClass:NSClassFromString(@"UISegmentedControl") ] )
        {
            subview.alpha = 0.0f;
        }
        
    } 
    
    m_customActivityView = [[FullScreenActivityView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:m_customActivityView];
    
    [m_customActivityView setHidden:YES];
    
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

    self.m_titleLabel = nil;
    
    self.m_bodyView = nil;
    self.m_topbarView = nil;
    
    self.m_backButton = nil;
    self.m_homeButton = nil;
    self.m_notifyButton = nil;
    self.m_fullScreenButton = nil;
    
    self.m_activityIndicatorView = nil;
    
    self.m_searchBar = nil;
    self.m_searchContracted = nil;
    self.m_searchExpanded = nil;
    
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Common methods
- (void)clearViewController
{

    [m_currentViewController.view removeFromSuperview];
    
    m_currentViewController = nil;

}

- (void)switchInViewController:(CustomViewController*)viewController
{
    
    if ( m_currentViewController == viewController )
    {
        //nothing to do
        return;
    }

    UIView * currentSubview = m_currentViewController.view;
    UIView * newSubview = viewController.view;
    
    viewController.m_navigationController = self;
    
    [viewController viewWillAppear:YES];
    [m_currentViewController viewWillDisappear:YES];
    
    // do the pre-animation prep
    //    subview.transform = CGAffineTransformMakeTranslation( m_bodyView.frame.size.width, 0 );
    newSubview.alpha = 0.0f;
    newSubview.transform = CGAffineTransformMakeTranslation( 0, -m_bodyView.frame.size.height );
    
    [m_bodyView addSubview:newSubview];
    
    // do the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    newSubview.alpha = 1.0f;
    newSubview.transform = CGAffineTransformIdentity;
    
    currentSubview.alpha = 0.0f;
    currentSubview.transform = CGAffineTransformMakeTranslation( 0, m_bodyView.frame.size.height );
    //    m_currentSubview.transform = CGAffineTransformMakeTranslation( -m_bodyView.frame.size.width, 0 );
    
    [UIView commitAnimations];
    
    m_currentViewController = viewController;
    
}

- (void)returnToPreviousViewController:(CustomViewController*)viewController
{
    [self switchInViewController:viewController.m_previousViewController];
}

#pragma mark - Button clicked handlers

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeButtonClicked:(id)sender
{
    // nothing in parent
}

- (IBAction)notifyButtonClicked:(id)sender
{
    // nothing in parent
}

- (IBAction)fullScreenButtonClicked:(id)sender
{
    // nothing in parent
}

#pragma mark - Search stuff


- (void)resignSearchBarFirstResponder
{
    
    // resign first responder the normal way
    [m_searchBar resignFirstResponder];
    
    // re-enable the cancel button. this is silly, but works
    for ( UIView * possibleButton in m_searchBar.subviews )
    {
        // This is a button .. the cancel button is the only button we have
        if ( [possibleButton isKindOfClass:[UIButton class]] )
        {
            // enable it, break out -- we are done
            UIButton * cancelButton = (UIButton*)possibleButton;
            
            cancelButton.enabled = YES;
            
            return;
        }
    }
    
}

- (void)contractSearchBar
{
    
    // All done searching, clear everything out
    [m_searchBar setText:@""];
    [m_searchBar resignFirstResponder];
    
    // remove the cancel button
    [m_searchBar setShowsCancelButton:NO animated:YES];
    
    // contract the search box
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    m_searchBar.frame = m_searchContracted.frame;
    
    [UIView commitAnimations];
    
}

- (void)beginSearch
{
    // switch over to the search view 
//    m_searchViewController.m_previousViewController = m_currentViewController;
//
//    [self switchInViewController:m_searchViewController];

}

- (void)cancelSearch
{
    
    // return back to the previous controller
//    [self returnToPreviousViewController:m_searchViewController];
    
}

- (void)searchForString:(NSString*)searchString
{
    
//    // inform the search controller that we have something worth searching for
//    [m_searchViewController startIndicator];
//    
//    // send the search to the cloud
//    [m_storeController requestSongListSearch:searchBar.text];
    
}

#pragma mark - Search delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
    // display cancel button
    [searchBar setShowsCancelButton:YES animated:YES];
    
    // add the search string back into the bar
    [searchBar setText:m_currentSearchString];
    
    // expand out the search box with a nice animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    searchBar.frame = m_searchExpanded.frame;
    
    [UIView commitAnimations];
    
    [self beginSearch];
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
    // nothing for now
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{    
    
    // if the search is empty, we do nothing
    if ( searchBar.text == nil || [searchBar.text isEqualToString:@""] )
    {
        // do nothing
        return;
    }
    
    [m_currentSearchString release];
    
    // hold onto the search string for later
    m_currentSearchString = [searchBar.text retain];
    
    [self resignSearchBarFirstResponder];
    
    [self searchForString:m_currentSearchString];

}

- (void)searchBarCancelButtonClicked:(UISearchBar*)searchBar
{
    
    [self contractSearchBar];
    
    [self cancelSearch];
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    
    return YES;
    
}

@end
