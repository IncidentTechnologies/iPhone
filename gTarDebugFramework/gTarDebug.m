//
//  gTarDebug.m
//  gTarDebugFramework
//
//  Created by wuda on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "gTarDebug.h"


@implementation gTarDebug

@synthesize m_peerStatus, m_gameState, m_gameSession, m_gamePeerId, m_lastHeartbeatDate;

-(gTarDebug*)init
{
	if ( self = [super init] )
	{
		m_gamePacketNumber = 0;
		m_gameSession = nil;
		m_gamePeerId = nil;
		m_lastHeartbeatDate = nil;
		
		NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
		
		//levelBlocks = 0;
		m_gameUniqueID = [uid hash];
	}

	return self;
}

-(gTarDebug*)initServer
{
	if ( self = [super init] )
	{
		m_peerStatus = kServer;
	}

	return self;
}

-(gTarDebug*)initClient
{
	if ( self = [super init] )
	{
		m_peerStatus = kClient;
	}
	
	[self invalidateSession:m_gameSession];

	self.m_gameSession = nil;
	self.m_gamePeerId = nil;
	
	return self;
}


-(void)dealloc
{ 
	m_lastHeartbeatDate = nil;
	
	[self invalidateSession:m_gameSession];
	m_gameSession = nil;
	m_gamePeerId = nil;
	
	[super dealloc];
	
}


#pragma mark -
#pragma mark Peer Picker Related Methods

-(void)startPicker
{
	GKPeerPickerController* picker;
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}


#pragma mark GKPeerPickerControllerDelegate Methods

-(void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{ 

	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if(m_gameSession != nil)
	{
		[self invalidateSession:m_gameSession];
		m_gameSession = nil;
	}
	
} 

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
-(GKSession*)peerPickerController:(GKPeerPickerController*)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{ 
	GKSession * session = [[GKSession alloc] initWithSessionID:kSessionID displayName:nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

-(void)peerPickerController:(GKPeerPickerController*)picker didConnectPeer:(NSString*)peerID toSession:(GKSession*)session
{ 
	// Remember the current peer.
	m_gamePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	m_gameSession = session; // retain
	[m_gameSession retain];
	m_gameSession.delegate = self; 
	[m_gameSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
} 


#pragma mark -
#pragma mark Session Related Methods

-(void)startServerSession:(id<gTarDebugServer>)delegate
{
	
	m_serverDelegate = delegate;
	m_peerStatus = kServer;
	[self startPicker];
	
}

-(void)startClientSession:(id<gTarDebugClient>)delegate
{
	
	m_clientDelegate = delegate;
	m_peerStatus = kClient;
	[self startPicker];
	
}

-(void)clientTransferControl:(id<gTarDebugClient>)newDelegate
{
	m_clientDelegate = newDelegate;
}

-(void)serverTransferControl:(id<gTarDebugServer>)newDelegate
{
	m_serverDelegate = newDelegate;
}

-(void)serverSendGuitarInput:(GuitarInput*)ginput
{
	
	[self sendNetworkPacket:m_gameSession withData:ginput ofLength:sizeof(GuitarInput)];
	
}

-(void)clientSendGuitarOutput:(GuitarOutput*)goutput
{
	
	[self sendNetworkPacket:m_gameSession withData:goutput ofLength:sizeof(GuitarOutput)];
	
}

-(void)invalidateSession:(GKSession*)session
{
	if(session != nil)
	{
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}


#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession. 
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
-(void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{ 

	static int lastPacketTime = -1;
	unsigned char *incomingPacket = (unsigned char *)[data bytes];
	int *pIntData = (int *)&incomingPacket[0];

	// developer  check the network time and make sure packers are in order
	int packetTime = pIntData[0];
	
	if(packetTime < lastPacketTime)
	{
		return;	
	}
	
	lastPacketTime = packetTime;
	
	if ( m_peerStatus == kServer )
	{
		GuitarOutput * goutput = (GuitarOutput*) (&incomingPacket[4]);
		memcpy( &m_goutput, goutput, sizeof( GuitarOutput ) );
		[m_serverDelegate serverRecvGuitarOutput:goutput];
	}
	else if ( m_peerStatus == kClient )
	{
		GuitarInput * ginput = (GuitarInput*) (&incomingPacket[4]);
		memcpy( &m_ginput, ginput, sizeof( GuitarInput ) );
		[m_clientDelegate clientRecvGuitarInput:ginput];
	}
}

-(void)sendNetworkPacket:(GKSession*)session withData:(void*)data ofLength:(int)length
{

	static unsigned char networkPacket[kMaxPacketSize];

	const unsigned int packetHeaderSize = sizeof(int); // we have one "ints" for our header
	

	int *pIntData = (int *)&networkPacket[0];
	
	pIntData[0] = m_gamePacketNumber++;
	
	memcpy( &networkPacket[packetHeaderSize], data, length ); 
	
	NSData *packet = [NSData dataWithBytes:networkPacket length:(length+4)];
	
	NSArray * peers = [NSArray arrayWithObject:m_gamePeerId];

	[session sendData:packet toPeers:peers withDataMode:GKSendDataReliable error:nil];
	//[session sendDataToAllPeers:packet withDataMode:GKSendDataUnreliable error:nil];

}


#pragma mark GKSessionDelegate Methods

-(void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state
{ 

	if(state == GKPeerStateDisconnected)
	{

		if ( m_peerStatus == kServer )
		{
			[m_serverDelegate serverEndpointDisconnected];
		}
		else if ( m_peerStatus == kClient )
		{
			[m_clientDelegate clientEndpointDisconnected];
		}
	} 
	
	if(state == GKPeerStateConnected)
	{
		
		if ( m_peerStatus == kServer )
		{
			[m_serverDelegate serverEndpointConnected];
		}
		else if ( m_peerStatus == kClient )
		{
			[m_clientDelegate clientEndpointConnected];
		}
	} 
	
} 

#pragma mark State management

- (int)indexFromString:(int)str andFret:(int)fret
{	
	return str * 13 + fret;
}

- (void)flushState
{
	if ( m_peerStatus == kClient )
	{
		[self clientSendGuitarOutput:&m_goutput];
	}
	else if ( m_peerStatus == kServer )
	{
		[self serverSendGuitarInput:&m_ginput];
	}
}

- (void)ledOnString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_ginput.ledsOn[ index ] = 1;
}

- (void)ledOffString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_ginput.ledsOn[ index ] = 0;
}

- (void)fretDownString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_goutput.fretDown[ index ] = 1;
}

- (void)fretUpString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_goutput.fretDown[ index ] = 0;
}

- (void)noteOnString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_goutput.notesOn[ index ] = 1;
}

- (void)noteOffString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_goutput.notesOn[ index ] = 0;
}


	
@end
