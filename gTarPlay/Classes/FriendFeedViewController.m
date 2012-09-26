//
//  FriendFeedViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 9/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "FriendFeedViewController.h"
#import <CloudController.h>
#import <FileController.h>
#import "FriendFeedCell.h"
#import "UserSongSession.h"
#import "UserSong.h"
#import "CloudResponse.h"

extern FileController * g_fileController;
extern CloudController * g_cloudController;

@implementation FriendFeedViewController

@synthesize m_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        //
        // Init friend controller
        // 
        m_userController = [[UserController alloc] initWithCloudController:g_cloudController];
        
        m_songPlaybackViewController = [[SongPlayerViewController alloc] initWithNibName:nil bundle:nil];
        
    }
    
    return self;
}

- (void)dealloc
{
    
    [m_userController release];
    [m_tableView release];
    [m_songPlaybackViewController release];
    [m_friendSessions release];
    
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
    
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
//}

- (void)updateFriendFeed
{
    [m_userController requestUserFollowsSessions:0];
}

- (void)playUserSongSession:(UserSongSession*)session
{
    
//    [g_cloudController requestUserSongSessionXmp:session andCallbackObj:self andCallbackSel:@selector(receivedSongXmp:)];
    
}

- (void)receivedSongXmp:(CloudResponse*)response
{
    
    if ( response.m_status == CloudResponseStatusSuccess )
    {
        // successfully downloaded song
        NSString * sessionXmp = response.m_receivedDataString;
        UserSongSession * userSongSession = response.m_responseUserSongSession;
        
        userSongSession.m_xmpBlob = sessionXmp;
        
        [m_songPlaybackViewController attachToSuperView:[self.view superview] andPlaySongSession:userSongSession];
                
    }
    else
    {
        // failed to download
    }
    
}

//- (void)stopUserSongSession
//{
//    
//    [m_songPlaybackViewController detachFromSuperView];
//    
//    [m_songPlaybackViewController release];
//
//    m_songPlaybackViewController = nil;
//    
//}

- (void)preloadImages
{

    for ( NSInteger i = 0; i < [m_friendSessions count]; i++ )
    {
        UserSongSession * session = [m_friendSessions objectAtIndex:i];
        
        [g_fileController precacheFile:session.m_userSong.m_imgFileId];
    }
   
}

#pragma mark UserController delegate


- (void)userLoggedOut
{
    // do nothing    
}

- (void)userProfileSucceeded:(UserProfile*)userProfile
{
    // do nothing    
}

- (void)userProfileFailed:(NSString*)reason
{
    // do nothing    
}

- (void)userFollowsSessionsSucceeded:(NSArray*)friendList
{
    
    // pre-download the first batch of pics for these sessions
    // we do this in two parts because:
    // -downloading 0 pics makes it very laggy when the user scrolls
    // -downloading all the the pics at once takes forever
    // this is a good compromise
//    for ( NSInteger i = 0; i < MIN(10, [friendList count]); i++ )
//    {
//        UserSongSession * session = [friendList objectAtIndex:i];
//        
//        [session.m_userSong getAlbumArtImageFromCloud:g_cloudController];
//    }
    
    [m_friendSessions release];
    
    m_friendSessions = [friendList retain];
//    m_friendSessions = [[friendList sortedArrayUsingSelector:@selector(compareCreatedNewestFirst:)] retain];
    
    // update the table with what we have
    // after this reload, we pull down the balance of the pics.
    [m_tableView reloadData];
    
    // I thought scheduling on a timer would put this in a non-main thread and
    // therefore not disrupt UI handling, but I was wrong.
//    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(preloadImages) userInfo:nil repeats:NO];
    
}

- (void)userFollowsSessionsFailed:(NSString*)reason
{
    // do nothing    
}

- (void)userFollowsSucceeded:(NSArray*)friendList
{
    // do nothing    
}

- (void)userFollowsFailed:(NSString*)reason
{
    // do nothing    
}

- (void)userFollowedBySucceeded:(NSArray*)friendList
{
    // do nothing    
}

- (void)userFollowedByFailed:(NSString*)reason
{
    // do nothing    
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
	return [m_friendSessions count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"FriendFeedCell";
	
	FriendFeedCell * cell = (FriendFeedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		
		cell = [[[FriendFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		[[NSBundle mainBundle] loadNibNamed:@"FriendFeedCell" owner:cell options:nil];
        
        cell.m_parent = self;
        
//        [cell.m_playPauseButton addTarget:self action:@selector(playPauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
	}
	
	// Clear these in case this cell was previously selected
	cell.highlighted = NO;
	cell.selected = NO;
	
	NSInteger row = [indexPath row];
    
    UserSongSession * session = [m_friendSessions objectAtIndex:row];
    
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
    
    UserSongSession * session = [m_friendSessions objectAtIndex:row];

    [self playUserSongSession:session];

}

@end
