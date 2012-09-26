//
//  gTarRootViewController.m
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

//#import "PlayController.h"
#import "gTarRootViewController.h"
#import "gTarPlayViewController.h"
#import "gTarSaysViewController.h"
#import "gTarLearnViewController.h"
#import "gTarJamViewController.h"
#import "EAGLView.h"
#import "SongModel.h"
#import "DisplayController.h"
#import "CloudController.h"
#import "gTarAccountViewController.h"
#import "SongMerger.h"

NSString * g_username;
NSString * g_password;

@implementation gTarRootViewController

@synthesize versionDate, versionTime;
@synthesize glView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	// Display the current version information
	[versionDate setText:[NSString stringWithFormat:@"%s", __DATE__]];
	[versionTime setText:[NSString stringWithFormat:@"%s", __TIME__]];

	// turn off autolocking
	UIApplication *thisApp = [UIApplication sharedApplication];
	
	thisApp.idleTimerDisabled = YES;

}


/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/


 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark -
#pragma mark Navigation management

- (IBAction)learnButtonClicked:(id)sender
{
	
	gTarLearnViewController * learnVc = [[gTarLearnViewController alloc] initWithNibName:@"gTarLearnViewController" bundle:nil];
	
	[self.navigationController pushViewController:learnVc animated:YES];
	
	[learnVc release];
	
}

- (IBAction)jamButtonClicked:(id)sender
{

	gTarJamViewController * jamVc = [[gTarJamViewController alloc] initWithNibName:nil bundle:nil];
	
	[self.navigationController pushViewController:jamVc animated:YES];
	
	[jamVc release];

}

- (IBAction)playButtonClicked:(id)sender
{
	
	gTarPlayViewController * playVc = [[gTarPlayViewController alloc] initWithNibName:@"gTarPlayViewController" bundle:nil];
	
	[playVc.m_songSelectionTable reloadData];
	
	[self.navigationController pushViewController:playVc animated:YES];
	
	[playVc release];
	
}

- (IBAction)saysButtonClicked:(id)sender
{
	
	gTarSaysViewController * saysVc = [[gTarSaysViewController alloc] initWithNibName:@"gTarPlayViewController" bundle:nil];
	
	[saysVc.m_songSelectionTable reloadData];
	
	[self.navigationController pushViewController:saysVc animated:YES];
	
	[saysVc release];
	
}

- (IBAction)accountButtonClicked:(id)sender
{

	gTarAccountViewController * acctVc = [[gTarAccountViewController alloc] initWithNibName:@"gTarAccountViewController" bundle:nil];
	
	[self.navigationController pushViewController:acctVc animated:YES];
	
	[acctVc release];
	
}

bool ledsOn;
- (IBAction)testButtonClicked:(id)sender
{
	/*
	//SongModel * model = new SongModel("Tears_in_Heaven_Eric_Clapton");
	//DisplayController * stuff = new DisplayController( glView, 6, model->GetNoteArray(), model->GetMeasureArray() );
	PlayController * playController = [[PlayController alloc] initWithNibName:@"PlayController" bundle:nil];

	playController.m_xmpName = @"Tears_in_Heaven_Eric_Clapton";
	playController.m_tempo = 0; // medium
	playController.m_accuracy = AccuracyExactNote; // hard
	
	[self.navigationController pushViewController:playController animated:YES];

	[playController release];
	 */
	/*
	if ( m_ledMarquee == NULL )
	{		
		m_ledMarquee = new LedMarquee();
	}
	
	if ( ledsOn == false )
	{
		ledsOn = true;
		m_ledMarquee->DisplayGtar();
	}
	else
	{
		ledsOn = false;
		m_ledMarquee->DisplayGtar();
	}		
	*/
	/*
	CloudController * cloud = [[CloudController alloc] initWithUsername:@"idan" andPassword:@"idan"];
	
	[cloud authenticate];
*/

	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName1 = @"24.xmp";
	NSString * xmpPath1 = [documentsDirectory stringByAppendingPathComponent:fileName1];
	NSString * xmpBlob1 = [NSString stringWithContentsOfFile:xmpPath1];
	
	NSString * fileName2 = @"24.xmp";
	NSString * xmpPath2 = [documentsDirectory stringByAppendingPathComponent:fileName2];
	NSString * xmpBlob2 = [NSString stringWithContentsOfFile:xmpPath2];
	
	NSString * finalXmpBlob = [SongMerger xmpBlobWithXmpBlob:xmpBlob1 andXmpBlob:xmpBlob2];
	
	NSLog(finalXmpBlob);
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

