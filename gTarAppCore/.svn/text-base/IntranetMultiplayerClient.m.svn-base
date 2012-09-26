//
//  IntranetMultiplayerClient.m
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "IntranetMultiplayerClient.h"


@implementation IntranetMultiplayerClient

@synthesize delegate;

- (id)init
{
	if ( self = [super init] )
	{
		m_availableServers = [[NSMutableArray alloc] init];
		
		m_pingTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1.0 //(1.0 / 60.0)
													   target:self
													 selector:@selector(pingServer)
													 userInfo:nil
													  repeats:TRUE];
	}
	
	return self;
}

- (void)pingServer
{
	
	NSString * peerId = [self connectedServerPeerId];

	if ( peerId != nil )
	{
		[self sendPingToPeerId:peerId];
	}
	
}

- (void)dealloc
{
	[m_availableServers release];
	
	[super dealloc];
}
/*
- (void)startClientSessionAndLookForServers
{
	
	if ( m_clientSession != nil )
	{
		[self invalidateSession:m_clientSession];
	}
	if ( m_availableServers != nil )
	{
		[m_availableServers release];
	}
	
	m_availableServers = [[NSMutableArray alloc] init];
	
	UIDevice * device = [UIDevice currentDevice];
	NSString * uniqueIdentifier = [device uniqueIdentifier];
	
	m_clientSession = [[GKSession alloc] initWithSessionID:SESSION_ID
											   displayName:uniqueIdentifier
											   sessionMode:GKSessionModeClient];
	
	m_clientSession.delegate = self;
	[m_clientSession setDataReceiveHandler:self withContext:NULL];
	m_clientSession.available = YES;
	
}


#pragma mark Session methods
- (void)connectToServerPeerId:(NSString*)peerId
{
	[m_clientSession connectToPeer:peerId withTimeout:10];
	
	if ( delegate != nil )
	{
		[delegate connectedServerChanged];
	}
	
}

- (void)disconnectFromServer
{

	[m_clientSession disconnectFromAllPeers];
	
	// no longer connected
	m_serverPeerId = nil;
	m_serverName = nil;
	
	if ( delegate != nil )
	{
		[delegate connectedServerChanged];
	}
	
}	

#pragma mark GKSessionDelegate Methods

// a client is trying to connect
// this should only be called for a server instance
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	// nothing
}


// The client found a server, or our state with the server changed.
- (void)session:(GKSession *)session
		   peer:(NSString *)peerId
 didChangeState:(GKPeerConnectionState)state
{
	
	switch ( state )
	{
		case GKPeerStateAvailable: 
		{
			// add to list of available servers
			[m_availableServers addObject:peerId];

			if ( delegate != nil )
			{
				[delegate availableServersChanged];
			}
			
		} break;
		
		case GKPeerStateUnavailable:
		{
			// remove from list of available servers
			[m_availableServers removeObject:peerId];

			if ( delegate != nil )
			{
				[delegate availableServersChanged];
			}
			
		} break;
			
		case GKPeerStateConnecting: 
		{
			// ignored per apple
			// implement -session:didReceiveConnectionRequestFromPeer:
		} break;
			
		case GKPeerStateConnected:
		{
			// remove from list of available
			[m_availableServers removeObject:peerId];

			// we are connected to a server
			m_serverPeerId = peerId;
			m_serverName = [m_clientSession displayNameForPeer:peerId];
			m_serverLastHeartbeatDate = 0;
			m_serverPacketNumber = 0;

			if ( delegate != nil )
			{
				[delegate connectedServerChanged];
				[delegate availableServersChanged];
			}
			
		} break;
			
		case GKPeerStateDisconnected:
		{
			// no longer connected
			m_serverPeerId = nil;
			m_serverName = nil;
			
			if ( delegate != nil )
			{
				[delegate connectedServerChanged];
			}
			
		} break;

		default:
		{
			// nothing; shouldn't happen
		}
	}
	
}

*/
#pragma mark -
#pragma mark State Change Handlers

- (void)availablePeerId:(NSString*)peerId
{
	// add to list of available servers
	[m_availableServers addObject:peerId];
	
	if ( delegate != nil )
	{
		[delegate availableServersChanged];
	}
}

- (void)unavailablePeerId:(NSString*)peerId
{
	// remove from list of available servers
	[m_availableServers removeObject:peerId];
	
	if ( delegate != nil )
	{
		[delegate availableServersChanged];
	}
}

- (void)connectedPeerId:(NSString*)peerId
{
	// remove from list of available
	[m_availableServers removeObject:peerId];
	
	if ( delegate != nil )
	{
		[delegate connectedServerChanged];
		[delegate availableServersChanged];
	}
}
	
- (void)disconnectedPeerId:(NSString*)peerId
{
	if ( delegate != nil )
	{
		[delegate connectedServerChanged];
	}
}

- (void)connectingPeerId:(NSString*)peerId
{
	// server only
}

#pragma mark -
#pragma mark Overloaded Recv Handlers

- (void)receivedPongFromPeerId:(NSString*)peerId
{
	// hack
	if ( delegate != nil )
	{
		[delegate connectedServerChanged];
	}
}

#pragma mark -
#pragma mark Helpers

- (NSArray*)availableServersNames
{
	NSMutableArray * serverNames = [[NSMutableArray alloc] init];
	
	for ( unsigned int index = 0; index < [m_availableServers count]; index++ )
	{
		NSString * peerId = [m_availableServers objectAtIndex:index];
		
		NSString * serverName = [m_remoteSession displayNameForPeer:peerId];
		
		[serverNames insertObject:serverName atIndex:index];
	}
	
	[serverNames autorelease];
	
	return serverNames;
	
}

- (NSArray*)availableServersPeerIds
{
	return m_availableServers;
}

- (NSInteger)availableServersCount
{
	return [m_availableServers count];
}

- (NSString*)connectedServerName
{
	
	NSArray * serverStates = [m_remoteConnectionsByPeerId allValues];

	IntranetMultiplayerRemoteState * serverState = [serverStates objectAtIndex:0];

	NSString * peerId = serverState.m_remotePeerId;
		
	NSString * serverName = [m_remoteSession displayNameForPeer:peerId];
		
	return serverName;
}

-(NSString*)connectedServerPeerId
{
	NSArray * serverStates = [m_remoteConnectionsByPeerId allValues];

	if ( [serverStates count] > 0 )
	{
		IntranetMultiplayerRemoteState * serverState = [serverStates objectAtIndex:0];
	
		NSString * peerId = serverState.m_remotePeerId;
	
		return peerId;
	}
	
	return nil;
}

- (bool)connectedToServer
{
	return ( [m_remoteConnectionsByPeerId count] > 0 );
}

- (NSNumber*)connectedServerRtt
{
	NSArray * serverStates = [m_remoteConnectionsByPeerId allValues];
	
	IntranetMultiplayerRemoteState * serverState = [serverStates objectAtIndex:0];

	return [NSNumber numberWithDouble:serverState.m_remoteLastRtt];
}
@end
