//
//  AccountViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 11/2/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountViewCell.h"
#import "AccountView.h"

#import <QuartzCore/QuartzCore.h>

#import "UserSongSession.h"
#import "UserSongSessions.h"
#import "UserSong.h"

#import "CloudController.h"
#import "CloudResponse.h"

#import "RootViewController.h"
#import "UserProfile.h"
#import "CustomSegmentedControl.h"

extern CloudController * g_cloudController;
extern UserController * g_userController;

@implementation AccountViewController

@synthesize m_rootViewController;
@synthesize m_headerView;
@synthesize m_feedSelector;
@synthesize m_tableView;
@synthesize m_footerView;
@synthesize m_welcomeLabel;
@synthesize m_profileButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        
        //
        // Set the background layer propertiees
        //
        self.view.layer.cornerRadius = 5;
        self.view.layer.borderWidth = 1;
        self.view.layer.borderColor = [[UIColor grayColor] CGColor];
        self.view.clipsToBounds = YES;
        self.view.backgroundColor = [UIColor whiteColor];
        
        //
        // Give the header a blue gradient
        //
        UIColor * color1 = [UIColor colorWithRed:0.0f/255.0f green:174.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        UIColor * color2 = [UIColor colorWithRed:0.0f/255.0f green:137.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
        UIColor * color3 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
        UIColor * color4 = [UIColor colorWithRed:0.0f/255.0f green:130.0f/255.0f blue:183.0f/255.0f alpha:1.0f];
        UIColor * color5 = [UIColor colorWithRed:0.0f/255.0f green:65.0f/255.0f blue:92.0f/255.0f alpha:1.0f];
        
        CAGradientLayer * gradient = [CAGradientLayer layer];
        gradient.frame = m_headerView.bounds;
        
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
        
        [m_headerView.layer insertSublayer:gradient atIndex:0];
        
        // 
        // Init the feed selector.
        //
        [m_feedSelector changeTitles:[NSArray arrayWithObjects:@"Friends", @"Global", nil]];
        [m_feedSelector setFontSize:15];
        
        //
        // Give the footer a gradient
        //
        gradient = [CAGradientLayer layer];
        gradient.frame = m_footerView.bounds;
        
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[color2 CGColor],
                           (id)[color3 CGColor],
                           (id)[color4 CGColor],
                           (id)[color5 CGColor], nil];
        
        gradient.locations = [NSArray arrayWithObjects:
                              (id)[NSNumber numberWithFloat:0.0f],
                              (id)[NSNumber numberWithFloat:0.3f],
                              (id)[NSNumber numberWithFloat:0.7f],
                              (id)[NSNumber numberWithFloat:1.0f], nil];
        
        [m_footerView.layer insertSublayer:gradient atIndex:0];
        
    }
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super init];
    
    if ( self )
    {
                
    }
    
    return self;
    
}

- (void)dealloc
{
        
    [m_friendFeed release];
    [m_globalFeed release];

    [m_headerView release];
    [m_feedSelector release];
    [m_tableView release];
    [m_footerView release];
    [m_welcomeLabel release];
    [m_profileButton release];
    
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

    m_footerView.transform = CGAffineTransformMakeTranslation(0, m_footerView.frame.size.height);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.m_headerView = nil;
    self.m_feedSelector = nil;
    self.m_tableView = nil;
    self.m_footerView = nil;
    self.m_welcomeLabel = nil;
    self.m_profileButton = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
        
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
//    [self updateDisplay];
    
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
    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
    {
        // Friends
        return [m_friendFeed count];        
    }
    
    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
    {
        // Global
        return [m_globalFeed count];
    }    
    
    // Should never happen
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"AccountViewCell";
	
	AccountViewCell * cell = (AccountViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		
		cell = [[[AccountViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"AccountViewCell" owner:cell options:nil];
                
	}
	
	// Clear these in case this cell was previously selected
	cell.highlighted = NO;
	cell.selected = NO;
	
    NSInteger row = [indexPath row];
    
    UserSongSession * session = nil;
    
    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
    {
        session = [m_friendFeed objectAtIndex:row];
    }
    
    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
    {
        session = [m_globalFeed objectAtIndex:row];
    }
    
    cell.m_userSongSession = session;
    
    [cell updateCell];
    
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 41;
}

#pragma mark -
#pragma mark Table view delegate

// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    
    NSInteger row = [indexPath row];
    
    UserSongSession * session = nil;
    
    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
    {
        session = [m_friendFeed objectAtIndex:row];
    }
    
    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
    {
        session = [m_globalFeed objectAtIndex:row];
    }
    
    [self playUserSongSession:session];
    
}

#pragma mark - Animations

- (void)showFooter
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    m_footerView.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];

}

- (void)hideFooter
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    m_footerView.transform = CGAffineTransformMakeTranslation(0, m_footerView.frame.size.height);
    
    [UIView commitAnimations];
    
}

#pragma mark - Feed 

- (void)updateFeeds
{
    
    [self update];
    
}

- (void)updateGlobalFeed
{
    m_refreshingGlobalFeed = YES;
    
    [g_cloudController requestGlobalSessionsCallbackObj:self andCallbackSel:@selector(globalUpdateSucceeded:)];
}

- (void)updateFriendFeed
{
    m_refreshingFriendFeed = YES;
    
    [g_userController requestUserFollowsSessions:0 andCallbackObj:self andCallbackSel:@selector(userUpdateSucceeded:)];
}

- (void)updateFeedDisplay
{
    
//    [m_tableView setHidden:NO];
    
    if ( m_feedSelector.m_selectedSegmentIndex == 0 )
    {
        if ( m_refreshingFriendFeed == YES )
        {
            // We are getting more content            
//            [self showFooter];
//            [self showHeader];
            [m_tableView startAnimating];
            
            if ( [m_friendFeed count] == 0 )
            {
                // There is nothing to show, and we are getting more
//                [m_tableView setHidden:YES];
            }
        }
        else if ( [m_friendFeed count] == 0 )
        {
            // There is no content to show and we are not getting more
//            [self hideFooter];
//            [self hideHeader];
            [m_tableView stopAnimating];
//            [m_tableView setHidden:YES];
        }
        else
        {
            // Nothing is going on right now
//            [self hideFooter];
//            [self hideHeader];
            [m_tableView stopAnimating];
        }
    }
    
    if ( m_feedSelector.m_selectedSegmentIndex == 1 )
    {
        if ( m_refreshingGlobalFeed == YES )
        {
            // We are getting more content            
//            [self showFooter];
//            [self showHeader];
            [m_tableView startAnimating];
            
            if ( [m_globalFeed count] == 0 )
            {
                // There is nothing to show, and we are getting more
//                [m_tableView setHidden:YES];
            }
        }
        else if ( [m_globalFeed count] == 0 )
        {
            // There is no content to show and we are not getting more
//            [self hideFooter];
//            [self hideHeader];
            [m_tableView stopAnimating];
//            [m_tableView setHidden:YES];
        }
        else
        {
            // Nothing is going on right now
//            [self hideFooter];
//            [self hideHeader];
            [m_tableView stopAnimating];
        }
    }
    
    [m_tableView reloadData];
    
}

- (void)updateDisplay
{
    
    // Display the cached user name
    if ( g_userController.m_loggedInUserProfile.m_firstName != nil )
    {
        [m_welcomeLabel setText:[NSString stringWithFormat:@"Hi, %@", g_userController.m_loggedInUserProfile.m_firstName]];
    }
    else if ( g_userController.m_loggedInUsername != nil )
    {
        [m_welcomeLabel setText:[NSString stringWithFormat:@"Hi, %@", g_userController.m_loggedInUsername]];
    }
    else
    {
        [m_welcomeLabel setText:[NSString stringWithFormat:@"Hi, Stranger"]];
    }
    
    // Display the cached friend feed
    UserEntry * entry = [g_userController getUserEntry:0];
    
    if ( [entry.m_followsSessionsList count] > 0 )
    {
        
        [m_friendFeed release];
        
        m_friendFeed = [entry.m_followsSessionsList retain];
        
    }
    else
    {
        // Default to the global feed when there is no personal content
        [m_feedSelector setSelectedIndex:1];
    }
    
    [self updateFeedDisplay];
    
}

- (void)fileDownloadFinished:(id)file
{
    
    m_outStandingImageDownloads--;
    
    if ( m_outStandingImageDownloads == 0 )
    {
        // Reload the table
        [m_tableView reloadData];
    }
    
}

- (void)playUserSongSession:(UserSongSession*)session
{
    
    [m_rootViewController accountViewDisplayUserSongSession:session];
    
}

#pragma mark - UserController callbacks

- (void)globalUpdateSucceeded:(CloudResponse*)cloudResponse
{
    
    m_refreshingGlobalFeed = NO;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [m_globalFeed release];
        
        m_globalFeed = [cloudResponse.m_responseUserSongSessions.m_sessionsArray retain];
        
    }
    
    // Precache any files we need
    for ( UserSongSession * session in m_globalFeed )
    {
        //[g_fileController precacheFile:session.m_userSong.m_imgFileId];
        m_outStandingImageDownloads++;
        [g_fileController getFileOrDownloadAsync:session.m_userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
        
    }
    
    [self updateFeedDisplay];
    
}

- (void)userUpdateSucceeded:(UserResponse*)userResponse
{
    
    m_refreshingFriendFeed = NO;
    
    UserEntry * entry = [g_userController getUserEntry:0];
    
    [m_friendFeed release];
    
    m_friendFeed = [entry.m_followsSessionsList retain];
    
    // Precache any files we need
    for ( UserSongSession * session in m_friendFeed )
    {
        //[g_fileController precacheFile:session.m_userSong.m_imgFileId];
        m_outStandingImageDownloads++;
        [g_fileController getFileOrDownloadAsync:session.m_userSong.m_imgFileId callbackObject:self callbackSelector:@selector(fileDownloadFinished:)];
    }
    
    [self updateFeedDisplay];
    
}

- (void)userUpdateFailed:(NSString*)reason
{
    
    m_refreshingFriendFeed = NO;

    [self updateFeedDisplay];
    
}

#pragma mark - Button clicked handlers

- (IBAction)profileButtonClicked:(id)sender
{
    [m_rootViewController accountViewDisplayUserProfile:nil];
}

- (IBAction)feedSelectorChanged:(id)sender
{
    [m_tableView setContentOffset:CGPointMake(0, 0)];
    [self updateFeedDisplay];
}

#pragma mark - SongPlayerDelegate

- (void)songPlayerDisplayUserProfile:(UserProfile*)userProfile
{
    [m_rootViewController accountViewDisplayUserProfile:userProfile];
}

- (void)songPlayerDisplayUserSong:(UserSong*)userSong
{
    [m_rootViewController accountViewDisplayUserSong:userSong];
}

#pragma PullToUpdate

- (void)update
{
    
    [self updateFriendFeed];
    
    [self updateGlobalFeed];
    
    [self updateFeedDisplay];
    
    [m_tableView startAnimating];
    
}

@end
