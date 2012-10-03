//
//  StoreSearchViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/30/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreSearchViewController.h"
#import "StoreListCell.h"

#import "CustomNavigationViewController.h"

@implementation StoreSearchViewController

@synthesize m_activityIndicator;
@synthesize m_tableView;
@synthesize m_userSongsArray;
@synthesize m_statusLabel;

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
    
    [m_activityIndicator release];
    [m_tableView release];
    [m_userSongsArray release];
    [m_statusLabel release];
    
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
    
    self.m_tableView = nil;
    self.m_activityIndicator = nil;
    self.m_statusLabel = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if ( [m_userSongsArray count] > 0 )
    {
        [m_tableView reloadData];
        
        [m_tableView setHidden:NO];
        
        [m_navigationController resignSearchBarFirstResponder];
    }
    else
    {
        [m_tableView setHidden:YES];
        [m_statusLabel setHidden:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
    
    return [m_userSongsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//static NSString * CellIdentifier = @"StoreFeaturedCell";
	static NSString * CellIdentifier = @"StoreListCell";
    
	StoreListCell * cell = (StoreListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		
		cell = [[[StoreListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"StoreListCell" owner:cell options:nil];
        
        //		[cell.downloadButton addTarget:self action:@selector(downloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	NSInteger row = [indexPath row];
	
    
    if ( [m_userSongsArray count] > row )
    {
        cell.m_userSong = [m_userSongsArray objectAtIndex:row];
    }

    [cell updateCell];
    
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [StoreListCell cellHeight];
    
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
	NSInteger row = [indexPath row];
	
    if ( [m_userSongsArray count] > row )
    {
        [m_navigationController resignSearchBarFirstResponder];
        
        [m_navigationController showUserSongDetail:[m_userSongsArray objectAtIndex:row]];
    }
     
}

#pragma -
#pragma Misc

- (void)startIndicator
{
    [m_activityIndicator startAnimating];
    [m_statusLabel setHidden:YES];
}

- (void)stopIndicator
{
    [m_activityIndicator stopAnimating];
}

- (void)displayResults:(NSArray*)userSongsArray
{
    
    self.m_userSongsArray = userSongsArray;
    
    if ( [m_userSongsArray count] > 0 )
    {
        [m_tableView reloadData];
        
        [m_tableView setHidden:NO];
    }
    else
    {
        [m_tableView setHidden:YES];
        
        [m_statusLabel setHidden:NO];
    }
    
//    [self stopIndicator];
    
}

@end
