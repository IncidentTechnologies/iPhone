//
//  StoreFeaturedGenreViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/7/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreFeaturedGenreViewController.h"
#import "StoreNavigationViewController.h"

#import "StoreFeatureCollection.h"
#import "StoreGenreCollection.h"
#import "StoreFeaturedCell.h"
#import "CustomSegmentedControl.h"

#import <QuartzCore/QuartzCore.h>

@implementation StoreFeaturedGenreViewController

@synthesize m_genreLabel;
@synthesize m_genreView;
@synthesize m_genreName;
@synthesize m_featuredGenreCollection;

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
    
    [m_genreLabel release];
    [m_genreView release];
    [m_genreName release];
    [m_featuredGenreCollection release];
    
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
    
    [m_feedSelectorButton changeTitles:[NSArray arrayWithObjects:@"New", @"Popular", @"All", nil]];
    
    m_genreLabel.shadowColor = [UIColor darkGrayColor];
    m_genreLabel.shadowOffset = CGSizeMake(1, 1);

}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_genreLabel = nil;
    self.m_genreView = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{

    [m_genreLabel setText:m_featuredGenreCollection.m_genreName];
    
    // reset the ui
    NSInteger selectedIndex = m_feedSelectorButton.m_selectedSegmentIndex;
    
    if ( selectedIndex != 0 || selectedIndex != 1 )
    {
        [m_feedSelectorButton setSelectedIndex:0];
    }

    // this lets us reuse the parents functionality while extending our own here.
    m_featureCollection = m_featuredGenreCollection;
    
    [super viewWillAppear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (IBAction)segmentedButtonClicked:(id)sender
{
    // if its the 3rd segment, we want to popup the full genre view.
    // otherwise we do the same as the super class would do.
    
    CustomSegmentedControl * segmentedControl = (CustomSegmentedControl*)sender;
    
    if ( segmentedControl.m_selectedSegmentIndex == 2 )
    {
        // redirect it to the full genre view
        [m_navigationController showFullList:m_featureCollection];
    }
    else
    {
        // else bump it up to the super
        [super segmentedButtonClicked:sender];
    }
    
}

@end
