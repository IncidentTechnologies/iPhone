//
//  EtarLearnPlayViewController.m
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "EtarLearnPlayViewController.h"
#import "EtarLearnPlayTabsViewController.h"
#import "PlayCell.h"


@implementation EtarLearnPlayViewController

@synthesize songSelectionTable;
@synthesize selectedSong;
@synthesize songs;
@synthesize songSortKey;

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
- (void)viewDidLoad {
    [super viewDidLoad];
	
	songSortKey = @"Name";
	[self populateSongSelectionTable];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -
#pragma mark Button click handling

- (IBAction)backButtonClicked:(id)sender
{
	[self.navigationController popViewControllerAnimated: YES];
}

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

- (IBAction)sortAlphaButtonClicked:(id)sender
{
	songSortKey = @"Name";
	[self sortSongSelectionTable];
}

- (IBAction)sortGenreButtonClicked:(id)sender
{
	songSortKey = @"Genre";
	[self sortSongSelectionTable];
}

- (IBAction)sortProgressButtonClicked:(id)sender
{
	songSortKey = @"Progress";
	[self sortSongSelectionTable];
}


#pragma mark -
#pragma mark Song data management

// Fetch the data from the server
- (void)fetchSongData
{
	// TODO: actually pull xmb from the server
	// For now, we just make up some data.
	songs = [[NSMutableArray alloc] init];

	
	// Add some dummy songs for now	
	[songs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Tears in Heaven", @"Name", @"Rock", @"Genre", [NSNumber numberWithFloat:0.0], @"Progress", @"Tears_in_Heaven_Eric_Clapton", @"XMB", nil]];
	[songs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Z-Song", @"Name", @"Classical", @"Genre", [NSNumber numberWithFloat:0.55], @"Progress", @"Tears_in_Heaven_Eric_Clapton", @"XMB", nil]];
	[songs addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"A-Song", @"Name", @"A-Genre", @"Genre", [NSNumber numberWithFloat:0.75], @"Progress", @"Tears_in_Heaven_Eric_Clapton", @"XMB", nil]];
	
	// Sort.
	[self sortSongArray];
	
}

- (void)updateProgressPercent:(CGFloat)progress
{
	
}

// XMP data from the server must be converted to an internal data structure.
- (NSArray*)convertXmpToArray:(NSObject*)xmpData
{
	//
	// Array : Dictionaries : Time : number
	//						: Fret : number
	//						: String : number
	//						: Duration : number
	
	// TODO: actually convert xmb to array
	NSMutableArray * array = [[NSMutableArray alloc] init];
	
	// Add some dummy notes for now	
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithUnsignedInt:2], @"Time",
					  [NSNumber numberWithUnsignedInt:5], @"String",
					  [NSNumber numberWithUnsignedInt:5], @"Fret",
					  [NSNumber numberWithUnsignedInt:1], @"Duration",
					  nil]];

	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithUnsignedInt:3], @"Time",
					  [NSNumber numberWithUnsignedInt:1], @"String",
					  [NSNumber numberWithUnsignedInt:1], @"Fret",
					  [NSNumber numberWithUnsignedInt:1], @"Duration",
					  nil]];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithUnsignedInt:1], @"Time",
					  [NSNumber numberWithUnsignedInt:2], @"String",
					  [NSNumber numberWithUnsignedInt:2], @"Fret",
					  [NSNumber numberWithUnsignedInt:1], @"Duration",
					  nil]];
	[array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					  [NSNumber numberWithUnsignedInt:1], @"Time",
					  [NSNumber numberWithUnsignedInt:3], @"String",
					  [NSNumber numberWithUnsignedInt:2], @"Fret",
					  [NSNumber numberWithUnsignedInt:1], @"Duration",
					  nil]];
	
	// Sort the array of notes by Time.
	// It doesn't matter if there are multiple notes at the same time.
	[array sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"Time" ascending:YES] autorelease]]];	

	return array;
}

#pragma mark -
#pragma mark Table view helpers

// Populate the song selection table
- (void)sortSongArray
{
	[songs sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:songSortKey ascending:YES] autorelease]]];	
}

- (void)populateSongSelectionTable
{
	[self fetchSongData];
	[self.songSelectionTable reloadData];
}

// This is called to change sort the table data (by name, genre, etc.)
- (void)sortSongSelectionTable
{
	// Sort.
	[self sortSongArray];
	
	// Reload data with the resorted array
	[self.songSelectionTable reloadData];
}

// Handle a selection within the song selection table.
- (void)selectSongFromTable
{
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	
	// One row for each song in our array.
	if ( songs != nil && [songs count] > 0 )
	{
		return [songs count];
	}
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	static NSString *CellIdentifier = @"PlayCell";
 
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	PlayCell * cell = (PlayCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		//cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell = [[[PlayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[[NSBundle mainBundle] loadNibNamed:@"PlayCell" owner:cell options:nil];
/*		
 NSArray * topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PlayCell" owner:nil options:nil];
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[PlayCell class]])
			{
				cell = (PlayCell *)currentObject;
				break;
			}
		}
 */
	}
 
	// Configure the cell...
	
	// Get the element from the pre-sorted dictionary that corresponds to this row. 
	NSDictionary * element = [songs objectAtIndex: [indexPath row]];
	
	[cell.songName setText:[element objectForKey:@"Name"]];
	//[cell.songName setTextColor:[UIColor whiteColor]];

	[cell.songGenre setText:[element objectForKey:@"Genre"]];
	//[cell.songGenre setTextColor:[UIColor whiteColor]];
	
	CGFloat percentProgress = [[element objectForKey:@"Progress"] floatValue];
	[cell.songProgress setProgress:percentProgress];
	
/*
	NSString * cellLabel = [NSString stringWithFormat:@"%@, %@, %@ %",
							[element objectForKey:@"Name"],
							[element objectForKey:@"Genre"],
							[element objectForKey:@"Progress"] ];
	
	// Set text
	[cell.textLabel setText:cellLabel];
	[cell.textLabel setTextColor:[UIColor blueColor]];
 
 */
	
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
	// Navigation logic may go here. Create and push another view controller.
	EtarLearnPlayTabsViewController * tabsVc = [[EtarLearnPlayTabsViewController alloc] initWithNibName:@"EtarLearnPlayTabsViewController" bundle:nil];

	selectedSong = [songs objectAtIndex:indexPath.row];
	NSString * songXmb = [selectedSong objectForKey:@"XMB"];
	
	[tabsVc parseXmp:songXmb];
	
	// Navigate
	[self.navigationController pushViewController:tabsVc animated:YES];
	
	// TODO: get the updated progress before we teardown this VC
	//CGFloat progress = [tabsVc getPercentCompletion];
	//[selectedSong setObject:[NSNumber numberWithFloat:progress] forKey:@"Progress"];
	
	// All done, release.
	[tabsVc release];
	
}
	 
#pragma mark -
#pragma mark VC teardown
	 
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
