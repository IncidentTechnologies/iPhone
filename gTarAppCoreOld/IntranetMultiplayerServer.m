//
//  IntranetMultiplayerServer.m
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "IntranetMultiplayerServer.h"


@implementation IntranetMultiplayerServer

//@synthesize m_connectedClientsCount;
@synthesize delegate;


- (id)init
{
	if ( self = [super init] ) 
	{
		m_connectingClientsPeerIds = [[NSMutableArray alloc] init];
		
		m_pingTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)1.0 //(1.0 / 60.0)
													   target:self
													 selector:@selector(pingAllClients)
													 userInfo:nil
													  repeats:TRUE];
	}
	
	return self;
}

- (void)pingAllClients
{

	NSArray * peerIds = [self connectedClientsPeerIds];
	
	for ( unsigned int i = 0; i < [peerIds count]; i++ )
	{
		NSString * peerId = [peerIds objectAtIndex:i];
		
		[self sendPingToPeerId:peerId];
	}
	
}

- (void)dealloc
{
	[m_connectingClientsPeerIds release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark State Change Handlers

- (void)availablePeerId:(NSString*)peerId
{
	// client only 
}

- (void)unavailablePeerId:(NSString*)peerId
{
	// client only 
}

- (void)connectedPeerId:(NSString*)peerId
{
	
	[m_connectingClientsPeerIds removeObject:peerId];

	if ( delegate != nil )
	{
		[delegate connectingClientsChanged:self];
		[delegate connectedClientsChanged:self];
	}

}

- (void)disconnectedPeerId:(NSString*)peerId
{
	
	if ( delegate != nil )
	{
		[delegate connectedClientsChanged:self];
	}
	
}

- (void)connectingPeerId:(NSString*)peerId
{
	
	[m_connectingClientsPeerIds addObject:peerId];
	
	if ( delegate != nil )
	{
		[delegate connectingClientsChanged:self];
	}

}


#pragma mark -
#pragma mark Packet recv handlers

- (void)receivedErrorFromPeerId:(NSString*)peerId
{
	// do stuff - pure virtual
}

bool beepTestStarted = FALSE;

- (void)receivedPongFromPeerId:(NSString*)peerId
{

	[delegate connectedClientsStateChanged:self];
	
	double latency = [self latencyForConnectedPeerId:peerId];
	
	// wait till latency drops below 100ms .. 
	// in production this should be less but good for now
	if ( latency < 0.1 )
	{
		if ( beepTestStarted == FALSE )
		{
			beepTestStarted = TRUE;
			[self beepSyncronizationBeginPeerId:peerId];
		}
	}
	
}

- (void)receivedTimeSyncResponseFromPeerId:(NSString*)peerId 
						   withReceiveTime:(double)receiveTime
							   andSendTime:(double)sendTime
{
	// do stuff - pure virtual**
}

- (void)receivedDataTransferStartFromPeerId:(NSString*)peerId 
							 withTransferId:(unsigned int)transferId
							   transferSize:(unsigned int)transferSize
									andData:(char *)data
									 isLast:(bool)isLast
{
	// do stuff - pure virtual**
}


#pragma mark -
#pragma mark Helpers

- (NSArray*)connectedClientsNames
{
	NSArray * clientStates = [m_remoteConnectionsByPeerId allValues];
	NSMutableArray * clientNames = [[NSMutableArray alloc] init];
	
	for ( unsigned int index = 0; index < [clientStates count]; index++ )
	{
		IntranetMultiplayerRemoteState * clientState = [clientStates objectAtIndex:index];

		NSString * peerId = clientState.m_remotePeerId;
		
		NSString * clientName = [m_remoteSession displayNameForPeer:peerId];
		
		[clientNames insertObject:clientName atIndex:index];
	}

	[clientNames autorelease];
	
	return clientNames;
}

- (NSArray*)connectedClientsPeerIds
{
	return [m_remoteConnectionsByPeerId allKeys];
}

- (NSInteger)connectedClientsCount
{
	return [m_remoteConnectionsByPeerId count];
}

- (NSArray*)connectedClientsRtt
{
	NSArray * clientStates = [m_remoteConnectionsByPeerId allValues];
	NSMutableArray * clientRtts = [[NSMutableArray alloc] init];
	
	for ( unsigned int index = 0; index < [clientStates count]; index++ )
	{
		IntranetMultiplayerRemoteState * clientState = [clientStates objectAtIndex:index];

		double clientRtt = clientState.m_remoteLastRtt;
		
		[clientRtts insertObject:[NSNumber numberWithDouble:clientRtt] atIndex:index];
	}
	
	[clientRtts autorelease];
	
	return clientRtts;
}

- (NSArray*)connectingClientsNames
{

	NSMutableArray * clientNames = [[NSMutableArray alloc] init];

	for ( unsigned int index = 0; index < [m_connectingClientsPeerIds count]; index++ )
	{
		NSString * peerId = [m_connectingClientsPeerIds objectAtIndex:index];
		
		NSString * clientName = [m_remoteSession displayNameForPeer:peerId];
		
		[clientNames insertObject:clientName atIndex:index];
	}
	
	[clientNames autorelease];
	
	return clientNames;
}

- (NSArray*)connectingClientsPeerIds
{
	return m_connectingClientsPeerIds;
}

- (NSInteger)connectingClientsCount
{
	return [m_connectingClientsPeerIds count];
}

@end
