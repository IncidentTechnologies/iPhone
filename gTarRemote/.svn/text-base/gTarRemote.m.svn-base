//
//  gTarRemote.m
//  gTarRemote
//
//  Created by Marty Greenia on 11/15/10.
//  Copyright 2010 Incident Tech. All rights reserved.
//

#import "gTarRemote.h"


@implementation gTarRemote

@synthesize m_peerStatus, m_remoteSession, m_remotePeerId, m_lastHeartbeatDate;

- (gTarRemote*)init
{
	if ( self = [super init] )
	{
		[self sharedInit];
	}
	
	return self;
}

- (gTarRemote*)initHost
{
	if ( self = [super init] )
	{
		[self sharedInit];
		m_peerStatus = HostPeer;
	}
	
	return self;
}

- (gTarRemote*)initDevice
{
	if ( self = [super init] )
	{
		[self sharedInit];
		m_peerStatus = DevicePeer;

	}
	
	return self;
}

- (void)sharedInit
{
	m_remotePacketNumber = 0;
	m_remoteSession = nil;
	m_remotePeerId = nil;
	m_lastHeartbeatDate = nil;
	
//	NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
	
//	m_remoteUniqueID = [uid hash];	
}


- (void)dealloc
{ 
	m_lastHeartbeatDate = nil;
	
	[self invalidateSession:m_remoteSession];
	
	m_remoteSession = nil;
	m_remotePeerId = nil;
	
	[super dealloc];
	
}


#pragma mark -
#pragma mark Peer Picker Related Methods

- (void)startPicker
{
	GKPeerPickerController* picker;
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}


#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{ 
	
	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	if ( m_remoteSession != nil )
	{
		[self invalidateSession:m_remoteSession];
		m_remoteSession = nil;
	}
	
} 

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession*)peerPickerController:(GKPeerPickerController*)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{ 
	GKSession * session = [[GKSession alloc] initWithSessionID:SessionID displayName:nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController*)picker didConnectPeer:(NSString*)peerID toSession:(GKSession*)session
{ 
	// Remember the current peer.
	m_remotePeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	m_remoteSession = session; // retain
	[m_remoteSession retain];
	m_remoteSession.delegate = self; 
	[m_remoteSession setDataReceiveHandler:self withContext:NULL];
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
} 


#pragma mark -
#pragma mark Session Related Methods

- (void)startHostSession:(id<gTarRemoteHost>)delegate
{
	
	m_hostDelegate = delegate;
	m_peerStatus = HostPeer;
	[self startPicker];
	
}

- (void)startDeviceSession:(id<gTarRemoteDevice>)delegate
{
	
	m_deviceDelegate = delegate;
	m_peerStatus = DevicePeer;
	[self startPicker];
	
}

- (void)hostTransferControl:(id<gTarRemoteHost>)newDelegate
{
	m_hostDelegate = newDelegate;
}

- (void)deviceTransferControl:(id<gTarRemoteDevice>)newDelegate
{
	m_deviceDelegate = newDelegate;
}

- (void)hostSendDeviceInput:(DeviceInput*)dinput
{
	
	[self sendNetworkPacket:m_remoteSession withData:dinput ofLength:sizeof(DeviceInput)];
	
}

- (void)deviceSendDeviceOutput:(DeviceOutput*)doutput
{
	
	[self sendNetworkPacket:m_remoteSession withData:doutput ofLength:sizeof(DeviceOutput)];
	
}

- (void)invalidateSession:(GKSession*)session
{
	if ( session != nil )
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
- (void)receiveData:(NSData*)data fromPeer:(NSString*)peer inSession:(GKSession*)session context:(void*)context
{ 
	
	static int lastPacketTime = -1;
	unsigned char * incomingPacket = (unsigned char *)[data bytes];
	int * pIntData = (int*)&incomingPacket[0];
	
	// developer  check the network time and make sure packers are in order
	int packetTime = pIntData[0];
	
	if ( packetTime < lastPacketTime )
	{
		return;	
	}
	
	lastPacketTime = packetTime;
	
	if ( m_peerStatus == HostPeer )
	{
		DeviceOutput * doutput = (DeviceOutput*) (&incomingPacket[4]);
		memcpy( &m_doutput, doutput, sizeof( DeviceOutput ) );
		[m_hostDelegate hostRecvDeviceOutput:doutput];
	}
	else if ( m_peerStatus == DevicePeer )
	{
		DeviceInput * dinput = (DeviceInput*) (&incomingPacket[4]);
		memcpy( &m_dinput, dinput, sizeof( DeviceInput ) );
		[m_deviceDelegate deviceRecvDeviceInput:dinput];
	}
}

- (void)sendNetworkPacket:(GKSession*)session withData:(void*)data ofLength:(int)length
{
	
	static unsigned char networkPacket[MaxPacketSize];
	
	const unsigned int packetHeaderSize = sizeof(int); // we have one "ints" for our header
	
	
	int * pIntData = (int*)&networkPacket[0];
	
	pIntData[0] = m_remotePacketNumber++;
	
	memcpy( &networkPacket[packetHeaderSize], data, length ); 
	
	NSData * packet = [NSData dataWithBytes:networkPacket length:(length+4)];
	
	NSArray * peers = [NSArray arrayWithObject:m_remotePeerId];
	
	[session sendData:packet toPeers:peers withDataMode:GKSendDataReliable error:nil];
	//[session sendDataToAllPeers:packet withDataMode:GKSendDataUnreliable error:nil];
	
}


#pragma mark GKSessionDelegate Methods

-(void)session:(GKSession*)session peer:(NSString*)peerID didChangeState:(GKPeerConnectionState)state
{ 
	
	if ( state == GKPeerStateDisconnected )
	{
		
		if ( m_peerStatus == HostPeer )
		{
			[m_hostDelegate hostEndpointDisconnected];
		}
		else if ( m_peerStatus == DevicePeer )
		{
			[m_deviceDelegate deviceEndpointDisconnected];
		}
	} 
	
	if ( state == GKPeerStateConnected )
	{
		
		if ( m_peerStatus == HostPeer )
		{
			[m_hostDelegate hostEndpointConnected];
		}
		else if ( m_peerStatus == DevicePeer )
		{
			[m_deviceDelegate deviceEndpointConnected];
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
	if ( m_peerStatus == HostPeer )
	{
		[self hostSendDeviceInput:&m_dinput];
	}
	else if ( m_peerStatus == DevicePeer )
	{
		[self deviceSendDeviceOutput:&m_doutput];
	}
}

- (void)ledOnString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_dinput.ledsOn[ index ] = 1;
}

- (void)ledOffString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_dinput.ledsOn[ index ] = 0;
}

- (void)fretDownString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_doutput.fretDown[ index ] = 1;
}

- (void)fretUpString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_doutput.fretDown[ index ] = 0;
}

- (void)noteOnString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_doutput.notesOn[ index ] = 1;
}

- (void)noteOffString:(char)str andFret:(char)fret
{
	int index = [self indexFromString:str andFret:fret];
	
	m_doutput.notesOn[ index ] = 0;
}


@end
