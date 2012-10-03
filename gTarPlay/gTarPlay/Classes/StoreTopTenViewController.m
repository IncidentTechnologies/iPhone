//
//  StoreTopTenViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreTopTenViewController.h"
#import "StoreNavigationViewController.h"
#import "StoreListCell.h"

@implementation StoreTopTenViewController

@synthesize m_genreSelectorControl;
@synthesize m_tableView;

@synthesize m_userSongsDictionary;

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
    [m_genreSelectorControl release];
    [m_tableView release];
    
    [m_userSongsDictionary release];
    
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


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_tableView = nil;
    self.m_genreSelectorControl = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // (re)create the segmented control to match the dictionary we have
    NSArray * allKeys = [m_userSongsDictionary allKeys];

    [m_genreSelectorControl removeAllSegments];
    
    NSInteger index = 0;
    
    for ( NSString * key in allKeys )
    {
        [m_genreSelectorControl insertSegmentWithTitle:key atIndex:index animated:NO];
        index++;
    }
    
    [m_genreSelectorControl setSelectedSegmentIndex:0];
    
    [m_tableView reloadData];
    
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
    NSInteger selectedIndex = m_genreSelectorControl.selectedSegmentIndex;
    NSString * selectedText = [m_genreSelectorControl titleForSegmentAtIndex:selectedIndex];
    NSArray * selectedArray = [m_userSongsDictionary objectForKey:selectedText];
    
	return [selectedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"StoreListCell";
	
	StoreListCell * cell = (StoreListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		
		cell = [[[StoreListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"StoreListCell" owner:cell options:nil];
        
	}
	
	NSInteger row = [indexPath row];
	
    NSInteger selectedIndex = m_genreSelectorControl.selectedSegmentIndex;
    NSString * selectedText = [m_genreSelectorControl titleForSegmentAtIndex:selectedIndex];
    NSArray * selectedArray = [m_userSongsDictionary objectForKey:selectedText];

    cell.m_userSong = [selectedArray objectAtIndex:row];
    
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
	
    NSInteger selectedIndex = m_genreSelectorControl.selectedSegmentIndex;
    NSString * selectedText = [m_genreSelectorControl titleForSegmentAtIndex:selectedIndex];
    NSArray * selectedArray = [m_userSongsDictionary objectForKey:selectedText];

    [m_navigationController showUserSongDetail:[selectedArray objectAtIndex:row]];

}

#pragma -
#pragma Button clicked handlers

- (IBAction)segmentClickedHandler:(id)sender
{
    [m_tableView reloadData];
}

@end
