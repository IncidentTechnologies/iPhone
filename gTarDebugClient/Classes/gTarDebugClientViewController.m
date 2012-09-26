//
//  gTarDebugClientViewController.m
//  gTarDebugClient
//
//  Created by wuda on 10/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "gTarDebugClientViewController.h"

@implementation gTarDebugClientViewController

@synthesize m_connectionAlert;
@synthesize m_debugger;
@synthesize m_gView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	[m_gView setNeedsDisplay];

}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{ 
	
	if( m_connectionAlert.visible )
	{
		[m_connectionAlert dismissWithClickedButtonIndex:-1 animated:NO];
	}
	
	m_connectionAlert = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Event Handling Methods

- (IBAction)startServerButtonClicked
{
	m_debugger = [[gTarDebug alloc] init];
	
	m_gView.m_debugger = m_debugger;
	
	[m_debugger startServerSession:m_gView];
}

- (IBAction)startClientButtonClicked
{
	m_debugger = [[gTarDebug alloc] init];
	
	m_gView.m_debugger = m_debugger;
	
	[m_debugger startClientSession:m_gView];
}


@end
