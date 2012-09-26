//
//  gTarJamViewController.m
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "gTarJamViewController.h"
#import "JamController.h"

@implementation gTarJamViewController

@synthesize m_multiplayerPicker, m_multiplayerPickerView, m_serverClientToggle;
@synthesize m_tableSlider, m_buttonSlider;
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
	
	// add the picker's view into the provided view
	CGRect fr = m_multiplayerPickerView.frame;
	fr.origin = CGPointMake(0, 0);
	m_multiplayerPicker.view.frame = fr;
	[m_multiplayerPickerView addSubview:m_multiplayerPicker.view];
	
	// init the jam controllers
	//m_jamController = [[JamController alloc] initWithNibName:nil bundle:nil];
	
	//m_jamController.m_returnToController = self;
	//m_multiplayerPicker.m_jamController = m_jamController;
	
	[self toggleButtonClicked:nil];
	
	// some fun intro animations
	m_tableSlider.transform = CGAffineTransformMakeTranslation( 0, -600 );
	m_buttonSlider.transform = CGAffineTransformMakeTranslation( 600, 0 );
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5f];
	
	m_tableSlider.transform = CGAffineTransformMakeTranslation( 0, 0 );

	[UIView commitAnimations];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75f];
	
	m_buttonSlider.transform = CGAffineTransformMakeTranslation( 0, 0 );
	
	[UIView commitAnimations];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

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
}

#pragma mark -
#pragma mark Button click handlers

- (IBAction)backButtonClicked:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleButtonClicked:(id)sender
{

	if ( m_currentToggle == @"Client" )
	{
		m_currentToggle = @"Server";
		[m_multiplayerPicker waitForClients];
		
		JamIntranetMultiplayerServer * server = (JamIntranetMultiplayerServer *)m_multiplayerPicker.m_multiplayerServer;
		
		server.jamDelegate = self;
		//server.jamDelegate = m_jamController;
		//m_jamController.m_multiplayerMode = JamControllerMultiplayerModeServer;
		//m_jamController.m_multiplayerController = server;

	}
	else // if ( m_currentToggle == @"Server Mode" )
	{
		m_currentToggle = @"Client";
		[m_multiplayerPicker lookForServers];
		
		JamIntranetMultiplayerClient * client = (JamIntranetMultiplayerClient *)m_multiplayerPicker.m_multiplayerClient;
		
		client.jamDelegate = self;
		//client.jamDelegate = m_jamController;
		//m_jamController.m_multiplayerMode = JamControllerMultiplayerModeClient;
		//m_jamController.m_multiplayerController = client;

	}	
	
	[m_serverClientToggle setTitle:m_currentToggle forState:UIControlStateNormal];
	
}

- (IBAction)startButtonClicked:(id)sender
{

	JamController * jamVc = [[JamController alloc] initWithNibName:nil bundle:nil];
	
	jamVc.m_returnToController = self;
	
	jamVc.m_multiplayerMode = JamControllerMultiplayerModeSinglePlayer;

	[self.navigationController pushViewController:jamVc animated:YES];
	
	[jamVc release];

}

- (IBAction)startMultiplayerButtonClicked:(id)sender
{

	JamController * jamVc = [[JamController alloc] initWithNibName:nil bundle:nil];
	
	jamVc.m_returnToController = self;
	
	if ( m_currentToggle == @"Server" )
	{
		//[m_multiplayerPicker beginJamSession];
		jamVc.m_multiplayerMode = JamControllerMultiplayerModeServer;
		
		JamIntranetMultiplayerServer * server = (JamIntranetMultiplayerServer *)m_multiplayerPicker.m_multiplayerServer;
		
		server.jamDelegate = jamVc;
	}
	else
	{
		jamVc.m_multiplayerMode = JamControllerMultiplayerModeClient;

		JamIntranetMultiplayerClient * client = (JamIntranetMultiplayerClient *)m_multiplayerPicker.m_multiplayerClient;
		
		client.jamDelegate = jamVc;
	}
	
	[self.navigationController pushViewController:jamVc animated:YES];
	
	[jamVc release];
	
}

#pragma mark  -
#pragma mark Delegate functions

- (void)connectingClientsChanged:(IntranetMultiplayerServer*)server 
{
	
}

- (void)connectedClientsChanged:(IntranetMultiplayerServer*)server 
{
		
}

- (void)connectedClientsStateChanged:(IntranetMultiplayerServer*)server 
{
	
}

#pragma mark -
#pragma mark Jam picker client

- (void)clientBeginSession:(JamIntranetMultiplayerClient*)client
{
	// basically a server initiated button press
	[self startMultiplayerButtonClicked:nil];
}

- (void)client:(JamIntranetMultiplayerClient*)client startRecordingInTimeDelta:(double)delta
{
	// empty
}

- (void)clientStopRecordingSendXmp:(JamIntranetMultiplayerClient*)client
{
	// empty
}

- (void)clientEndSession:(JamIntranetMultiplayerClient*)client
{
	// empty
}

@end
