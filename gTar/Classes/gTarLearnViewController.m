//
//  gTarLearnViewController.m
//  gTar
//
//  Created by wuda on 10/24/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "gTarLearnViewController.h"

#import "PlayController.h"
#import "LearnLessonCell.h"
#import	"LearnChapterCell.h"
#import "LearnScoreController.h"

@implementation gTarLearnViewController

@synthesize m_debugStatus;
@synthesize m_lessonTableView;
@synthesize m_chapterTableView;

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
	
	m_lessons = [[NSMutableArray alloc] init];
	
	[m_lessons addObject:@"Lesson 1"];
	
}


// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark Button click handling

-(IBAction)stopButtonClicked:(id)sender
{
	[self.navigationController popViewControllerAnimated: YES];
}

-(IBAction)lessonButtonClicked:(id)sender
{
	
	if ( m_debug == YES )
	{
		m_debugger = [[gTarDebug alloc] init];
		
		[m_debugger startServerSession:self];
		
		return;
	}

	PlayController * playController = [[PlayController alloc] initWithNibName:@"PlayController" bundle:nil];	

	[playController changeDisplayMode:PlayControllerModeLearn];
		
	playController.m_returnToController = self;
	
	// Score controller
	LearnScoreController * learnSc = [[LearnScoreController alloc] init];
	learnSc.m_nibName = @"LearnScoreController";
	learnSc.m_returnToController = self;
	
	playController.m_scoreController = learnSc;
	
	
	// Navigate
	[self.navigationController pushViewController:playController animated:YES];
	
	// All done, release.
	[playController release];
	
	
}

-(IBAction)debugButtonClicked:(id)sender
{

	if ( m_debug == NO )
	{
		m_debug = YES;
		NSString * status = [[NSString alloc] initWithFormat:@"Debugger Enabled"];
		[m_debugStatus setTitle:status forState:nil];
		[status release];
	}
	else 
	{
		m_debug = NO;
		NSString * status = [[NSString alloc] initWithFormat:@"Debugger Disabled"];
		[m_debugStatus setTitle:status forState:nil];
		[status release];
	}		
	
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
	PlayController * playController = [[PlayController alloc] initWithNibName:@"PlayController" bundle:nil];
	
	playController.m_debugger = m_debugger;
	
	[playController changeDisplayMode:PlayControllerModeLearn];
	
	//playController.m_returnToController = self;
	
	// Navigate
	[self.navigationController pushViewController:playController animated:YES];
	
	// All done, release.
	[playController release];
	
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
	
	if ( tableView == m_lessonTableView )
	{
		// One row for each song in our array.
		if ( m_lessons != nil && [m_lessons count] > 0 )
		{
			return [m_lessons count];
		}
		
	}
	else if ( tableView == m_chapterTableView )
	{
		if ( m_selectedLesson != nil )
		{
			return [m_selectedLesson.m_chapters count];
		}
	}
	
	
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if ( tableView == m_lessonTableView )
	{
		
		static NSString *CellIdentifier = @"LearnLessonCell";
		
		LearnLessonCell * cell = (LearnLessonCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil)
		{
			cell = [[[LearnLessonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			[[NSBundle mainBundle] loadNibNamed:@"LearnLessonCell" owner:cell options:nil];
		}
		
		// Configure the cell...
		
		// Get the element from the pre-sorted dictionary that corresponds to this row. 
		//Lesson * lesson = [m_lessons objectAtIndex: [indexPath row]];
		NSString * lesson = [m_lessons objectAtIndex: [indexPath row]];
		
		[cell.m_lessonName setText:lesson];
		
		return cell;
		
	}
	else if ( tableView == m_chapterTableView )
	{
		
		static NSString *CellIdentifier = @"LearnChapterCell";
		
		LearnChapterCell * cell = (LearnChapterCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if (cell == nil)
		{
			cell = [[[LearnChapterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			[[NSBundle mainBundle] loadNibNamed:@"LearnLessonCell" owner:cell options:nil];
		}
		
		// Configure the cell...
		
		// Get the element from the pre-sorted dictionary that corresponds to this row. 
		//Chapter * chapter = m_selectedLesson;
		
		[cell.m_chapterName setText:@"dummy chapter name"];
		
		return cell;
		
	}	
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

	//m_selectedSong = [m_songs objectAtIndex:indexPath.row];
	
	if ( tableView == m_lessonTableView )
	{
		m_selectedLesson = [m_lessons objectAtIndex:[indexPath row]];
	}
	else if ( tableView == m_chapterTableView )
	{

	}
}

@end
