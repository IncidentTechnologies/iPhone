//
//  StoreListViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 6/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreListViewController.h"
#import "StoreNavigationViewController.h"
#import "StoreCategoryCell.h"
#import "StoreListCell.h"

#import <gTarAppCore/UserSong.h>

@implementation StoreListViewController

@synthesize m_table;
@synthesize m_genreLabel;
@synthesize m_genreName;
@synthesize m_userSongList;

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
    [m_table release];
    [m_genreLabel release];
    [m_genreName release];
    [m_userSongList release];
    
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
    
    m_genreLabel.shadowColor = [UIColor darkGrayColor];
    m_genreLabel.shadowOffset = CGSizeMake(1, 1);

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.m_table = nil;
    self.m_genreLabel = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [m_genreLabel setText:m_genreName];
    [m_table reloadData];
    
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
    
    return [m_userSongList count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSInteger row = [indexPath row];
//	
//    if ( m_categoryArray == nil )
//    {
//        static NSString * CellIdentifier = @"StoreCategoryCell";
//        
//        StoreCategoryCell * cell = (StoreCategoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil)
//        {
//            cell = [[[StoreCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//            
//            [[NSBundle mainBundle] loadNibNamed:@"StoreCategoryCell" owner:cell options:nil];
//            
//            [cell.m_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        
//        [cell.m_backButton setHidden:YES];
//        
//        NSArray * allKeys = [m_categoryDictionary allKeys];
//    
//        cell.m_categoryName = [allKeys objectAtIndex:row];
//        cell.m_userSong = nil;
//
//        [cell updateCell];
//        
//        return cell;
//        
//    }
//    else
//    {
//        if ( row == 0 )
//        {
//            
//            static NSString * CellIdentifier = @"StoreCategoryCell";
//            
//            StoreCategoryCell * cell = (StoreCategoryCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            
//            if (cell == nil)
//            {
//                cell = [[[StoreCategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//                
//                [[NSBundle mainBundle] loadNibNamed:@"StoreCategoryCell" owner:cell options:nil];
//                
//                [cell.m_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            }
//
//            [cell.m_backButton setHidden:NO];
//
//            NSArray * allKeys = [m_categoryDictionary allKeys];
//            
//            cell.m_categoryName = m_selectedCategory;
//            cell.m_userSong = nil;
//            
//            [cell updateCell];
//            
//            return cell;
//            
//        }
//        else

    static NSString * CellIdentifier = @"StoreListCell";
    
    StoreListCell * cell = (StoreListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        
        cell = [[[StoreListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        [[NSBundle mainBundle] loadNibNamed:@"StoreListCell" owner:cell options:nil];
        
    }
    
    cell.m_userSong = [m_userSongList objectAtIndex:row];
    
    [cell updateCell];
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if ( m_categoryArray == nil )
//    {
//        return [StoreCategoryCell cellHeight];
//    }
//    else

    return [StoreListCell cellHeight];
        
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
	NSInteger row = [indexPath row];
    
//    if ( m_categoryArray == nil )
//    {
//        NSArray * allKeys = [m_categoryDictionary allKeys];
//    
//        [m_selectedCategory release];
//        m_selectedCategory = [[allKeys objectAtIndex:row] retain];
//    
//        m_categoryArray = [m_categoryDictionary objectForKey:m_selectedCategory];
//        
//        [m_table reloadData];
//    }
//    else

    UserSong * userSong = [m_userSongList objectAtIndex:row];
    
    [m_navigationController showUserSongDetail:userSong];

}

#pragma -
#pragma Button clicked handlers


@end
