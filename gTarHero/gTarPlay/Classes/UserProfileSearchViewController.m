//
//  UserProfileSearchViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/26/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "UserProfileSearchViewController.h"
#import "UserProfileNavigationController.h"

#import "UserProfileSearchCell.h"

#import <gTarAppCore/UserProfile.h>

@implementation UserProfileSearchViewController

@synthesize m_activityIndicator;
@synthesize m_tableView;
@synthesize m_statusLabel;
@synthesize m_searchStringLabel;
@synthesize m_searchFacebookView;
@synthesize m_searchString;
@synthesize m_resultsArray;
@synthesize m_userProfile;
@synthesize m_userFriendList;
@synthesize m_waitingForFacebookSearch;

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
    [m_statusLabel release];
    [m_searchStringLabel release];
    [m_searchFacebookView release];
    [m_searchString release];
    [m_userProfile release];
    [m_userFriendList release];
    
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
    
    self.m_activityIndicator = nil;
    self.m_tableView = nil;
    self.m_statusLabel = nil;
    self.m_searchFacebookView = nil;
    self.m_searchStringLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if ( [m_resultsArray count] > 0 )
    {
        [m_tableView reloadData];
        
        [m_tableView setHidden:NO];
        
        [m_statusLabel setHidden:YES];
        
        [m_navigationController resignSearchBarFirstResponder];
    }
    else
    {
        [m_tableView setHidden:YES];
        
        [m_statusLabel setHidden:YES];
    }

    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    
    m_waitingForFacebookSearch = NO;
    
    [super viewWillDisappear:animated];
    
}

#pragma mark -
#pragma mark Misc

- (void)refreshTable
{

    if ( m_resultsArray != nil )
    {
        [m_activityIndicator stopAnimating];
    }
    
    [m_tableView reloadData];
    
}

- (void)displayResults:(NSArray*)userProfilesArray
{
    
    self.m_resultsArray = userProfilesArray;
    
    [m_searchFacebookView setHidden:YES];
    
    m_waitingForFacebookSearch = NO;
    
    if ( [m_resultsArray count] > 0 )
    {
        [m_tableView reloadData];
        
        [m_tableView setHidden:NO];
        
        [m_statusLabel setHidden:YES];
    }
    else
    {
        [m_tableView setHidden:YES];
        
        [m_statusLabel setHidden:NO];
    }
    
    //    [self stopIndicator];
    
}

- (void)displayUserProfile:(UserProfile*)userProfile
{
    // currently this function isn't user, but it will be if we choose to add multiple results per row
    [(UserProfileNavigationController*)m_navigationController getAndDisplayUserProfile:userProfile];    
}

- (void)addFriend:(UserProfile*)userProfile
{
    [(UserProfileNavigationController*)m_navigationController addUserFollows:userProfile];    
}

- (void)removeFriend:(UserProfile*)userProfile
{
    [(UserProfileNavigationController*)m_navigationController removeUserFollows:userProfile];    
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
    NSInteger count = [m_resultsArray count];
    
    // we are going to stuff two results per row
    if ( (count % 2) == 1 )
    {
        return (count / 2) + 1;
    }
        
    return count / 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    NSInteger row = [indexPath row];
    
    m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    static NSString * CellIdentifier = @"UserProfileSearchCell";
        
    UserProfileSearchCell * cell = (UserProfileSearchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (cell == nil)
    {
        
        cell = [[[UserProfileSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        [[NSBundle mainBundle] loadNibNamed:@"UserProfileSearchCell" owner:cell options:nil];
        
        cell.m_parent = self;
        
    }
    
    NSInteger index = row * 2;
    
    cell.m_userProfile1 = [m_resultsArray objectAtIndex:index];
    cell.m_isSelf1 = cell.m_userProfile1.m_userId == m_userProfile.m_userId;
    cell.m_areFriends1 = [m_userFriendList containsObject:cell.m_userProfile1];
    
    if ( [m_resultsArray count] > (index + 1) )
    {
        cell.m_userProfile2 = [m_resultsArray objectAtIndex:index + 1];
        cell.m_isSelf2 = cell.m_userProfile2.m_userId == m_userProfile.m_userId;
        cell.m_areFriends2 = [m_userFriendList containsObject:cell.m_userProfile2];
    }
    else
    {
        cell.m_userProfile2 = nil;
    }
    
    [cell updateCell];
        
    return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // +1 for the separator
    return [UserProfileSearchCell cellHeight];;
    
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
//	NSInteger row = [indexPath row];
//    
//	if ( [m_resultsArray count] > row )
//    {
//        [(UserProfileNavigationController*)m_navigationController displayUserProfile:[m_resultsArray objectAtIndex:row]];
//    }
    
}

@end
