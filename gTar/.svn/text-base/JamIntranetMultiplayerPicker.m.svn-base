//
//  JamIntranetMultiplayerPicker.m
//  gTar
//
//  Created by Marty Greenia on 2/9/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "JamIntranetMultiplayerPicker.h"


@implementation JamIntranetMultiplayerPicker

//@synthesize m_jamController;

#pragma mark -
#pragma mark External access methods

- (void)lookForServers
{
	[self clearServerClientState];
	
	m_multiplayerClient = [[JamIntranetMultiplayerClient alloc] init];
	m_multiplayerClient.delegate = self;
	
	[m_multiplayerClient startClientSessionAndLookForServers];	
}

- (void)waitForClients
{
	[self clearServerClientState];
	
	m_multiplayerServer = [[JamIntranetMultiplayerServer alloc] init];
	m_multiplayerServer.delegate = self;
	
	[m_multiplayerServer startServerSessionAndWaitForClients];
}

- (void)beginJamSession
{

//	[m_jamController.m_returnToController.navigationController pushViewController:m_jamController animated:YES];

	[m_multiplayerServer beginJamSession];
	
	/*
	if ( m_multiplayerClient != nil )
	{
		
	}
	
	if ( m_multiplayerServer != nil )
	{
		
	}
*/	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}
@end
