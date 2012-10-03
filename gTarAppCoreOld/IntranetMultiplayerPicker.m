//
//  IntranetMultiplayerPicker.m
//  gTar
//
//  Created by Marty Greenia on 2/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "IntranetMultiplayerPicker.h"


@implementation IntranetMultiplayerPicker

@synthesize m_multiplayerTable;
@synthesize m_multiplayerServer, m_multiplayerClient;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	if ( m_multiplayerTableConnectedClientPeerIds != nil )
	{
		[m_multiplayerTableConnectedClientPeerIds release];
		m_multiplayerTableConnectedClientPeerIds = nil;
	}
	if ( m_multiplayerTableConnectingClientPeerIds != nil )
	{
		[m_multiplayerTableConnectingClientPeerIds release];
		m_multiplayerTableConnectingClientPeerIds = nil;
	}
	
    [super dealloc];
}

#pragma mark -
#pragma mark External access methods

- (void)lookForServers
{
	[self clearServerClientState];
	
	m_multiplayerClient = [[IntranetMultiplayerClient alloc] init];
	m_multiplayerClient.delegate = self;
	
	[m_multiplayerClient startClientSessionAndLookForServers];	
}

- (void)waitForClients
{
	[self clearServerClientState];
	
	m_multiplayerServer = [[IntranetMultiplayerServer alloc] init];
	m_multiplayerServer.delegate = self;
	
	[m_multiplayerServer startServerSessionAndWaitForClients];
	
}

- (void)beginJamSession
{

	// ?
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	if ( m_multiplayerClient != nil )
	{
		NSInteger availableServers = [m_multiplayerClient availableServersCount];
	
		if ( [m_multiplayerClient connectedToServer] == YES )
		{
			availableServers++;
		}
		
		return availableServers;
	}
	
	if ( m_multiplayerServer != nil ) 
	{
		NSInteger connectingClients = [m_multiplayerServer connectingClientsCount];
		NSInteger connectedClients = [m_multiplayerServer connectedClientsCount];
		
		return connectingClients + connectedClients;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	static NSString * CellIdentifier = @"Cell";
	
	UITableViewCell * cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	if ( m_multiplayerClient != nil )
	{
		m_multiplayerTableServerPeerIds = [m_multiplayerClient availableServersPeerIds];
		
		NSArray * availableServers = [m_multiplayerClient availableServersNames];
		
		NSInteger row = [indexPath row];
		
		// make space for the connected server up top
		if ( [m_multiplayerClient connectedToServer] == YES )
		{
			if ( row == 0 )
			{
				NSString * connectedServerName = [m_multiplayerClient connectedServerName];
				NSNumber * serverRtt = [m_multiplayerClient connectedServerRtt];
				
				[cell.textLabel setText:[NSString stringWithFormat:@"+%f %@", 1000.0 * [serverRtt doubleValue], connectedServerName]];
			}
			else 
			{
				row--;

				NSString * serverName = [availableServers objectAtIndex:row];
			
				[cell.textLabel setText:[NSString stringWithFormat:@"? %@", serverName]];
			}
			
		}
		else
		{
			NSString * serverName = [availableServers objectAtIndex:row];

			[cell.textLabel setText:[NSString stringWithFormat:@"? %@", serverName]];
		}
	}
	
	if ( m_multiplayerServer != nil ) 
	{
		if ( m_multiplayerTableConnectedClientPeerIds != nil )
		{
			[m_multiplayerTableConnectedClientPeerIds release];
			m_multiplayerTableConnectedClientPeerIds = nil;
		}
		if ( m_multiplayerTableConnectingClientPeerIds != nil )
		{
			[m_multiplayerTableConnectingClientPeerIds release];
			m_multiplayerTableConnectingClientPeerIds = nil;
		}

		m_multiplayerTableConnectedClientPeerIds = [m_multiplayerServer connectedClientsPeerIds];
		[m_multiplayerTableConnectedClientPeerIds retain];
		
		m_multiplayerTableConnectingClientPeerIds = [m_multiplayerServer connectingClientsPeerIds];
		[m_multiplayerTableConnectingClientPeerIds retain];
		
		NSArray * connectedClients = [m_multiplayerServer connectedClientsNames];
		NSArray * connectedClientsRtt = [m_multiplayerServer connectedClientsRtt];
		NSArray * connectingClients = [m_multiplayerServer connectingClientsNames];
		
		// connected clients, then connecting clients
		NSInteger row = [indexPath row];
		
		if ( row < [connectedClients count] )
		{
			NSString * clientName = [connectedClients objectAtIndex:row];
			NSNumber * clientRtt = [connectedClientsRtt objectAtIndex:row];
			
			[cell.textLabel setText:[NSString stringWithFormat:@"+%f %@", 1000.0 * [clientRtt doubleValue], clientName]];
		}
		else
		{
			// offset the row by the number of clients we just filled
			row -= [connectedClients count];
			
			NSString * clientName = [connectingClients objectAtIndex:row];
			
			[cell.textLabel setText:[NSString stringWithFormat:@"? %@", clientName]];
		}	
		
	}
	
	return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	// connect to that server or client
	if ( m_multiplayerClient != nil )
	{
		NSString * peerId = [m_multiplayerTableServerPeerIds objectAtIndex:[indexPath row]];
	
		[m_multiplayerClient connectToPeerId:peerId];
	}
	
	if ( m_multiplayerServer != nil )
	{
		// connected clients, then connecting clients
		NSInteger row = [indexPath row];
		
		if ( row < [m_multiplayerTableConnectedClientPeerIds count] )
		{
			NSString * peerId = [m_multiplayerTableConnectedClientPeerIds objectAtIndex:row];

			[m_multiplayerServer disconnectFromPeerId:peerId];
		}
		else
		{
			// offset the row by the number of clients we just filled
			row -= [m_multiplayerTableConnectedClientPeerIds count];
			
			NSString * peerId = [m_multiplayerTableConnectingClientPeerIds objectAtIndex:row];
			
			[m_multiplayerServer acceptConnectionFromPeerId:peerId];
		}

	}

}

#pragma mark -
#pragma mark Server/Client Delegates

- (void)connectingClientsChanged:(IntranetMultiplayerServer*)server
{
	[m_multiplayerTable reloadData];
}

- (void)connectedClientsChanged:(IntranetMultiplayerServer*)server
{
	[m_multiplayerTable reloadData];

	// start pinging
	NSString * peerId = [m_multiplayerClient connectedServerPeerId];
	
	[m_multiplayerClient sendPingToPeerId:peerId];
}

- (void)connectedClientsStateChanged:(IntranetMultiplayerServer*)server
{
	[m_multiplayerTable reloadData];
}

- (void)availableServersChanged
{
	[m_multiplayerTable reloadData];
}

- (void)connectedServerChanged
{
	[m_multiplayerTable reloadData];
}

- (void)connectedServerStateChanged
{
	[m_multiplayerTable reloadData];
}

		
#pragma mark -
#pragma mark Helpers

- (void)clearServerClientState
{
	// clear out any state so we have a clean slate
	
	if ( m_multiplayerClient != nil )
	{
		[m_multiplayerClient release];
		m_multiplayerClient = nil;
	}
	if ( m_multiplayerTableConnectingClientPeerIds != nil )
	{
		[m_multiplayerTableConnectingClientPeerIds release];
		m_multiplayerTableConnectingClientPeerIds = nil;
	}
	if ( m_multiplayerTableConnectedClientPeerIds != nil )
	{
		[m_multiplayerTableConnectedClientPeerIds release];
		m_multiplayerTableConnectedClientPeerIds = nil;
	}
	
	if ( m_multiplayerServer != nil )
	{
		[m_multiplayerServer release];
		m_multiplayerServer = nil;
	}		
	if ( m_multiplayerTableServerPeerIds != nil )
	{
		[m_multiplayerTableServerPeerIds release];
		m_multiplayerTableServerPeerIds = nil;
	}
	
}


@end
