//
//  RootViewController.m
//  EtarLearn
//
//  Created by Marty Greenia on 9/30/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "RootViewController.h"
#import "EtarLearnPlayViewController.h"


@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
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
	
}

- (IBAction)playButtonClicked:(id)sender
{
	EtarLearnPlayViewController * playVc = [[EtarLearnPlayViewController alloc] initWithNibName:@"EtarLearnPlayViewController" bundle:nil];
	[playVc.songSelectionTable reloadData];
	[self.navigationController pushViewController:playVc animated:YES];
	[playVc release];

}

- (IBAction)accountButtonClicked:(id)sender
{
	
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

