//
//  gTarPlayViewController.m
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "gTarPlayViewController.h"
#import "gTarPlayTabsViewController.h"
#import "gTarPlayDetailViewController.h"
#import "PlayCell.h"
#import "PlayScoreController.h"

#import "gTarAccountViewController.h"



@implementation gTarPlayViewController

//@synthesize debugLabel;
@synthesize m_songSelectionTable;
//@synthesize m_difficultyButton;
//@synthesize m_spinner;
@synthesize m_activityIndicator;
//@synthesize m_cloudCache;
//@synthesize m_debugStatus;
//@synthesize m_cloneStatus;
//@synthesize selectedSong;
//@synthesize songs;
//@synthesize songSortKey;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	[self turnOffActivityIndicator];
/*	
	m_difficulty = @"Easy";
	[m_difficultyButton setTitle:m_difficulty forState:nil];
*/
	m_songSortKey = @"Name";
	[self populateSongSelectionTable];
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
//	[debugLabel setText:documentsDirectory];
}

- (void)viewWillAppear:(BOOL)animated
{
	[m_songSelectionTable reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -
#pragma mark Button click handling

- (IBAction)backButtonClicked:(id)sender
{
	[self.navigationController popViewControllerAnimated: YES];
}

/*
- (IBAction)sortButtonClicked:(id)sender
{
	// Change the sort key based on what was clicked
	UISegmentedControl * button = sender;
	
	switch (button.selectedSegmentIndex) {
		case 1:
		{
			songSortKey = @"Genre";
		} break;
		case 2:
		{
			songSortKey = @"Progress";
		} break;
		case 0:
		default:
		{
			songSortKey = @"Name";
		} break;
	}

	// Resort and redisplay the table
	[self sortSongSelectionTable];
}
*/

- (IBAction)sortAlphaButtonClicked:(id)sender
{
	m_songSortKey = @"Name";
	[self sortSongSelectionTable];
}

- (IBAction)sortGenreButtonClicked:(id)sender
{
	m_songSortKey = @"Genre";
	[self sortSongSelectionTable];
}

- (IBAction)sortProgressButtonClicked:(id)sender
{
	m_songSortKey = @"Progress";
	[self sortSongSelectionTable];
}

- (IBAction)difficultyButtonClicked:(id)sender
{
/*
	if ( m_difficulty == @"Easy" )
	{
		m_difficulty = @"Medium";
	}
	else if ( m_difficulty == @"Medium" )
	{
		m_difficulty = @"Hard";
	}
	else if ( m_difficulty == @"Hard" )
	{
		m_difficulty = @"Real";
	}
	else
	{
		m_difficulty = @"Easy";
	}

	[m_difficultyButton setTitle:m_difficulty forState:nil];
*/
}

-(IBAction)debugButtonClicked:(id)sender
{
	
	m_debugger = [[gTarDebug alloc] init];
	
	[m_debugger startServerSession:self];
		
}
-(IBAction)cloneButtonClicked:(id)sender
{
	
	m_clone = [[gTarDebug alloc] init];
	
	[m_clone startClientSession:self];
	
}


#pragma mark -
#pragma mark Debugger delegate stubs

// There is nothing for us to do until the play controller is ready,
// but we still need the debug connection open.
// We just ignore any input that comes.
-(void)serverRecvGuitarOutput:(GuitarOutput*)goutput
{
	//empty
}

-(void)serverEndpointDisconnected
{
	//empty
}

-(void)serverEndpointConnected
{

	// provide some kind of confirmation.
	
}

-(void)clientRecvGuitarInput:(GuitarInput*)ginput
{
	
}

-(void)clientEndpointDisconnected
{
	
}

-(void)clientEndpointConnected
{
	
}

#pragma mark -
#pragma mark Song data management

extern EAGLViewDisplayMode g_eaglDisplayMode;

- (void)playWithXmpBlob:(NSString*)xmpBlob
{
	
	if ( xmpBlob == nil )
	{
		return;
	}
	
#if 1
	// this line crashes on jailbroken (4.2.1 limera1n) phones/
	// probably because the filepaths are all screwed up.
	//gTarPlayDetailViewController * detailsVc = [[gTarPlayDetailViewController alloc] initWithNibName:@"gtarPlayDetailViewController" bundle:nil];

	// not sure why this works .. but it does for now!
	gTarPlayDetailViewController * detailsVc = [[gTarPlayDetailViewController alloc] init];

	detailsVc.m_xmpBlob = xmpBlob;
	detailsVc.m_userSong = m_selectedCacheEntry.m_userSong;
	
	[self.navigationController pushViewController:detailsVc animated:YES];
	
	[detailsVc release];
#endif 

#if 0
	gTarAccountViewController * acctVc = [[gTarAccountViewController alloc] initWithNibName:@"gTarAccountViewController" bundle:nil];
	
	[self.navigationController pushViewController:acctVc animated:YES];
	
	[acctVc release];
#endif 

#if 0
	gTarPlayDetailViewController * detailsVc = [[gTarPlayDetailViewController alloc] init];

	[self.navigationController pushViewController:detailsVc animated:YES];
	
	[detailsVc release];
#endif 
	/*
	PlayController * playController = [[PlayController alloc] initWithNibName:@"PlayController" bundle:nil];

	playController.m_xmpBlob = xmpBlob;
	g_eaglDisplayMode = DisplayModeES;
	
	if ( m_debugger != nil )
	{
		playController.m_debugger = m_debugger;
	}
	if ( m_clone != nil )
	{
		playController.m_clone = m_clone;
	}
	
	if ( m_difficulty == @"Easy" )
	{
		playController.m_tempo = 0;
		playController.m_accuracy = AccuracyStringOnly;
	}
	else if ( m_difficulty == @"Medium" )
	{
		playController.m_tempo = 0; 
		playController.m_accuracy = AccuracyExactNote;	
	}
	else if ( m_difficulty == @"Hard" )
	{
		playController.m_tempo = 4; 
		playController.m_accuracy = AccuracyExactNote;	
	}
	else 
	{
		playController.m_tempo = 1;
		playController.m_accuracy = AccuracyExactNote;
	}
	
	playController.m_returnToController = self;
	
	// Score controller
	PlayScoreController * playSc = [[PlayScoreController alloc] init];
//	playSc.m_nibName = @"PlayScoreController";
	playSc.m_returnToController = self;
	
	playController.m_scoreController = playSc;
	
	[playController changeDisplayMode:PlayControllerModePlay];
	
	// Navigate
	[self.navigationController pushViewController:playController animated:YES];
	
	// All done, release.
	[playController release];
	 
	 */
	
}

- (void)authenticationSuccess
{
	[m_cloudController getSongsXml];
}

- (void)authenticationFailure
{
//	[m_spinner stopAnimating];
	[self turnOffActivityIndicator];
}

- (void)receivedSongsXml:(UserSongs*)userSongs
{
//	UserSongs * userSongs = userSongs;
	
//	[m_spinner stopAnimating];
	[self turnOffActivityIndicator];
	
	[m_cloudCache populateCache:userSongs];
	
	// Save any input we've gotten so far.
	[m_cloudCache saveArchive];
	
	[m_songSelectionTable reloadData];
}

- (void)receivedSongXmp:(NSString*)xmpBlob
{

//	[m_spinner stopAnimating];
	[self turnOffActivityIndicator];

	[xmpBlob retain];
	
	// Add it to the cache
	[m_cloudCache setXmp:xmpBlob forUserSong:m_selectedCacheEntry.m_userSong];

	// Save any input we've gotten so far.
	[m_cloudCache saveArchive];

	[m_songSelectionTable reloadData];

	[self playWithXmpBlob:xmpBlob];
	
	m_selectedCacheEntry = nil;

	[xmpBlob release];
	
}

// Fetch the data from the server
- (void)fetchSongData
{
	
//	[m_spinner startAnimating];
	[self turnOnActivityIndicator];

	m_cloudController = [[CloudController alloc] initWithUsername:g_username andPassword:g_password andDelegate:self];
	
	[m_cloudController authenticate];
	
	/*
	 // For now, we just make up some data.
	 m_songs = [[NSMutableArray alloc] init];
	 
	 
	 // Add some dummy songs for now	
	 [m_songs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tears in Heaven", @"Name", @"Rock", @"Genre", [NSNumber numberWithFloat:0.6], @"Progress", @"Tears_in_Heaven_Eric_Clapton", @"XMB",
	 [NSNumber numberWithUnsignedInt:6], @"NotesCorrect", [NSNumber numberWithUnsignedInt:10], @"NotesTotal", nil]];
	 [m_songs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Z-Song", @"Name", @"Classical", @"Genre", [NSNumber numberWithFloat:0], @"Progress", @"Tears_in_Heaven_Eric_Clapton", @"XMB",
	 [NSNumber numberWithUnsignedInt:0], @"NotesCorrect", [NSNumber numberWithUnsignedInt:56], @"NotesTotal", nil]];
	 [m_songs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"A-Song", @"Name", @"A-Genre", @"Genre", [NSNumber numberWithFloat:0.56], @"Progress", @"Tears_in_Heaven_Eric_Clapton", @"XMB",
	 [NSNumber numberWithUnsignedInt:56], @"NotesCorrect", [NSNumber numberWithUnsignedInt:100], @"NotesTotal", nil]];
	 
	 // Sort.
	 [self sortSongArray];
*/	 
	
}

#pragma mark -
#pragma mark Table view helpers

// Populate the song selection table
- (void)sortSongArray
{
	[m_songs sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:m_songSortKey ascending:YES] autorelease]]];	
}

- (void)populateSongSelectionTable
{

	m_cloudCache = [CloudCache loadArchive];	

	[m_cloudCache retain];
	
	if ( m_cloudCache == nil )
	{
		m_cloudCache = [[CloudCache alloc] init];
	}
	
	// Display what we have so far.
	[m_songSelectionTable reloadData];
	 
	[self fetchSongData];
	
}

// This is called to change sort the table data (by name, genre, etc.)
- (void)sortSongSelectionTable
{
	// Sort.
	[self sortSongArray];
	
	// Reload data with the resorted array
	[m_songSelectionTable reloadData];
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
	
	// One row for each song in our array.
	/*
	if ( m_songs != nil && [m_songs count] > 0 )
	{
		return [m_songs count];
	}
	*/
	
	if ( m_cloudCache != nil )
	{
		return [m_cloudCache getCacheSize];
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
	static NSString *CellIdentifier = @"PlayCell";
 
	PlayCell * cell = (PlayCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
	{
		cell = [[[PlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[[NSBundle mainBundle] loadNibNamed:@"PlayCell" owner:cell options:nil];
	}
 
	cell.highlighted = NO;
	cell.selected = NO;
	
	// Configure the cell...
	
	// Get the element from the pre-sorted dictionary that corresponds to this row. 
	//UserSong * userSong = [m_userSongs.m_songsArray objectAtIndex:[indexPath row]];
	CloudCacheEntry * entry = [m_cloudCache getCacheEntryAtIndex:[indexPath row]];
	
	UserSong * userSong = entry.m_userSong;
	
	[cell.songName setText:userSong.m_title];

	[cell.songAuthor setText:userSong.m_author];

	if ( userSong.m_genre == nil )
	{
		[cell.songGenre setText:@"No genre"];
	}
	else 
	{
		[cell.songGenre setText:userSong.m_genre];
	}
	
	/*
	if ( userSong.m_timeModified > 0 )
	{

		//NSDate * lastUpdate = [NSDate dateWithTimeIntervalSinceReferenceDate:userSong.m_timeModified];
		NSDate * lastUpdate = [NSDate dateWithTimeIntervalSince1970:userSong.m_timeModified];
		
		NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd:HH:mm"];
	 
		//Optionally for time zone converstions
		//[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
	 
		NSString * stringFromDate = [formatter stringFromDate:lastUpdate];
	
		[cell.songLastUpdate setText:stringFromDate];
	
		[formatter release];
	}
	else 
	{
		[cell.songLastUpdate setText:@"Unknown"];	
	}
	*/
	
//	CGFloat percentProgress = 0.0f;
//	[cell.songProgress setProgress:percentProgress];
		
	return cell;
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the specified item to be editable.
return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

if (editingStyle == UITableViewCellEditingStyleDelete) {
// Delete the row from the data source
[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}   
else if (editingStyle == UITableViewCellEditingStyleInsert) {
// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
}   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the item to be re-orderable.
return YES;
}
*/
 
 
#pragma mark -
#pragma mark Table view delegate
	 
// This function catches any selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if ( m_selectedCacheEntry != nil )
	{
		return;
	}
	
	// Get the selected song and kick off an xmp request.
	// m_selectedSong = [m_userSongs.m_songsArray objectAtIndex:[indexPath row]];
	m_selectedCacheEntry = [m_cloudCache getCacheEntryAtIndex:[indexPath row]];

	if ( m_selectedCacheEntry != nil )
	{

		// Check to see if our local copy is current.
		if ( m_selectedCacheEntry.m_current == YES )
		{
			NSString * xmpBlob = [m_cloudCache getXmpForUserSong:m_selectedCacheEntry.m_userSong];
		
			if ( xmpBlob != nil )
			{
				[self playWithXmpBlob:xmpBlob];
			
				m_selectedCacheEntry = nil;
			}
			else 
			{
//				[m_spinner startAnimating];
				[self turnOnActivityIndicator];

				[m_cloudController getSongXmp:m_selectedCacheEntry.m_userSong];
			}
		}
		else 
		{
//			[m_spinner startAnimating];
			[self turnOnActivityIndicator];
			
			[m_cloudController getSongXmp:m_selectedCacheEntry.m_userSong];
		}			
	}
	else 
	{
		// shouldn't happen, nothing to do
	}
	
}
	 
#pragma mark -
#pragma mark VC teardown
	 
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
	
	if ( m_cloudController != nil )
	{
		[m_cloudController invalidateDelegate];
		[m_cloudController release];
	}
}

#pragma mark -
#pragma mark Misc Helpers

- (void)turnOffActivityIndicator
{

	if ( m_activityIndicatorTimer != nil )
	{
		[m_activityIndicatorTimer invalidate];
		m_activityIndicatorTimer = nil;
	}

	m_ledOn = NO;
	
	[m_activityIndicator setHidden:YES];
	
}

- (void)turnOnActivityIndicator
{
	[m_activityIndicator setHidden:YES];

	m_ledOn = NO;
	
	m_activityIndicatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(flickerActivityIndicator) userInfo:nil repeats:YES];
}

- (void)flickerActivityIndicator
{

	if ( m_ledOn == YES )
	{
		m_ledOn = NO;
		[m_activityIndicator setHidden:YES];
	}
	else 
	{
		m_ledOn = YES;
		[m_activityIndicator setHidden:NO];
	}
}

@end
