//
//  SelectListViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/21/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SelectListViewController.h"
#import "SelectUserSongCell.h"

#import "SelectNavigationViewController.h"

#import <gTarAppCore/UserSong.h>
#import <gTarAppCore/UserController.h>

extern UserController * g_userController;

@implementation SelectListViewController

@synthesize m_userSongArray;
@synthesize m_tableView;
@synthesize m_statusLabel;
@synthesize m_titleSort;
@synthesize m_artistSort;
@synthesize m_difficultySort;
@synthesize m_scoreSort;

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
    [m_userSongArray release];
    [m_tableView release];
    [m_statusLabel release];
    
    [m_titleSort release];
    [m_artistSort release];
    [m_difficultySort release];
    [m_scoreSort release];
    
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
    
    m_titleSort.image = nil;
    m_artistSort.image = nil;
    m_difficultySort.image = nil;
    m_scoreSort.image = nil;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_tableView = nil;
    self.m_statusLabel = nil;
    self.m_titleSort = nil;
    self.m_artistSort = nil;
    self.m_difficultySort = nil;
    self.m_scoreSort = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [self refreshDisplay];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return [m_userSongArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"SelectUserSongCell";
	
	SelectUserSongCell * cell = (SelectUserSongCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		
		cell = [[[SelectUserSongCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"SelectUserSongCell" owner:cell options:nil];
        
        cell.m_parent = self;
        
	}
	
	// Clear these in case this cell was previously selected
	cell.highlighted = NO;
	cell.selected = NO;
	
	NSInteger row = [indexPath row];
    
	UserSong * userSong = [m_userSongArray objectAtIndex:row];
    
    userSong.m_playStars = [g_userController getMaxStarsForSong:userSong.m_songId];
    userSong.m_playScore = [g_userController getMaxScoreForSong:userSong.m_songId];
    
    cell.m_userSong = userSong;
    
    [cell updateCell];
    
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SelectUserSongCell cellHeight] + 1;
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
	NSInteger row = [indexPath row];

	// display the song detail screen
    UserSong * userSong = [m_userSongArray objectAtIndex:row];
    
    [(SelectNavigationViewController*)m_navigationController showSongOptions:userSong];
    
}

#pragma mark - Misc

- (void)refreshDisplay
{
    
    if ( [m_userSongArray count] > 0 )
    {
        [m_statusLabel setHidden:YES];
//        [m_tableView setHidden:NO];
        
        [m_tableView reloadData];
    } 
    else if ( m_userSongArray != nil )
    {
        // empty songs array
        [m_statusLabel setHidden:NO];
//        [m_tableView setHidden:YES];
    }
    else
    {
        // no songs array
        [m_statusLabel setHidden:NO];
//        [m_tableView setHidden:YES];
    }
    
}

- (void)showSongDetails:(UserSong*)userSong
{
    
    [(SelectNavigationViewController*)m_navigationController showSongDetails:userSong];
    
}

#pragma PullToUpdateDelegate

- (void)update
{
    
    [(SelectNavigationViewController*)m_navigationController refreshSongList];
    
}

#pragma mark - Sorting


- (IBAction)titleSorting:(id)sender
{
    
    NSArray * sortedArray;
    
    if ( m_sortColumnImage == m_titleSort )
    {
        // Already sorted, just reverse them.
        m_sortAccending = !m_sortAccending;
        sortedArray = [[m_userSongArray reverseObjectEnumerator] allObjects];
    }
    else
    {
        m_sortColumnImage.image = nil;
        m_sortColumnImage = m_titleSort;
        
        m_sortAccending = YES;
        
        NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_title" ascending:m_sortAccending] autorelease];
        
        NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        sortedArray = [m_userSongArray sortedArrayUsingDescriptors:sortDescriptors];

    }
    
    [m_userSongArray release];
    
    m_userSongArray = [sortedArray retain];
    
    [self refreshSortedList];

}

- (IBAction)artistSorting:(id)sender
{
    
    NSArray * sortedArray;
    
    if ( m_sortColumnImage == m_artistSort )
    {
        // Already sorted, just reverse them.
        m_sortAccending = !m_sortAccending;
        sortedArray = [[m_userSongArray reverseObjectEnumerator] allObjects];
    }
    else
    {
        m_sortColumnImage.image = nil;
        m_sortColumnImage = m_artistSort;
        
        m_sortAccending = YES;
        
        NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_author" ascending:m_sortAccending] autorelease];
        
        NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        sortedArray = [m_userSongArray sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    [m_userSongArray release];
    
    m_userSongArray = [sortedArray retain];
    
    [self refreshSortedList];

}

- (IBAction)difficultSorting:(id)sender
{
 
    NSArray * sortedArray;
    
    if ( m_sortColumnImage == m_difficultySort )
    {
        // Already sorted, just reverse them.
        m_sortAccending = !m_sortAccending;
        sortedArray = [[m_userSongArray reverseObjectEnumerator] allObjects];
    }
    else
    {
        m_sortColumnImage.image = nil;
        m_sortColumnImage = m_difficultySort;
        
        m_sortAccending = YES;
        
        sortedArray = [m_userSongArray sortedArrayUsingSelector:@selector(compareDifficulty:)];
        
//        NSSortDescriptor * sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"m_difficulty" ascending:m_sortAccending] autorelease];
//        
//        NSArray * sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//        
//        sortedArray = [m_userSongArray sortedArrayUsingDescriptors:sortDescriptors];
        
    }
    
    [m_userSongArray release];
    
    m_userSongArray = [sortedArray retain];
    
    [self refreshSortedList];

}

- (IBAction)scoreSorting:(id)sender
{
    
    NSArray * sortedArray;
    
    if ( m_sortColumnImage == m_scoreSort )
    {
        // Already sorted, just reverse them.
        m_sortAccending = !m_sortAccending;
        sortedArray = [[m_userSongArray reverseObjectEnumerator] allObjects];
    }
    else
    {
        m_sortColumnImage.image = nil;
        m_sortColumnImage = m_scoreSort;
        
        m_sortAccending = NO;
        
        sortedArray = [m_userSongArray sortedArrayUsingSelector:@selector(comparePlayScore:)];
    }
    
    [m_userSongArray release];
    
    m_userSongArray = [sortedArray retain];
    
    [self refreshSortedList];

}

- (void)refreshSortedList
{
    
    if ( m_sortAccending == NO )
    {
        m_sortColumnImage.image = [UIImage imageNamed:@"WhiteBackArrow_UP.png"];
    }
    else
    {
        m_sortColumnImage.image = [UIImage imageNamed:@"WhiteBackArrow_DOWN.png"];
    }
    
    [m_tableView reloadData];

}

@end
