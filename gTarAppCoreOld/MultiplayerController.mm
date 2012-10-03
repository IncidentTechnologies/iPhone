//
//  MultiplayerController.m
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "MultiplayerController.h"


@implementation MultiplayerController

#pragma mark -
#pragma mark Setup + Teardown

- (id)init
{
    
    self = [super init];
    
	if ( self )
	{
		m_packetNumber = 0;
		
		m_audioController = [[AudioController alloc] initWithAudioSource:SamplerSource AndInstrument:nil];
		
		// TODO: dynamic Attenuation and Freq
		[m_audioController SetAttentuation:0.985f];
        [m_audioController initializeAUGraph];
		[m_audioController startAUGraph];
		
	}
	
	return self;
	
}

- (void)dealloc
{
	[self teardownSession];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Session Helpers

- (void)teardownSession
{
	if ( m_remoteSession != nil )
	{
		[m_remoteSession disconnectFromAllPeers]; 
		
		m_remoteSession.available = NO; 
		
		[m_remoteSession setDataReceiveHandler:nil withContext:NULL]; 
		
		m_remoteSession.delegate = nil; 
		
		[m_remoteSession release];
		
		m_remoteSession = nil;
	}
	
	if ( m_remoteConnectionsByPeerId != nil )
	{
		[m_remoteConnectionsByPeerId release];
		
		m_remoteConnectionsByPeerId = nil;
	}
}

- (void)startSessionWithType:(GKSessionMode)mode
{

	// clear out any exisiting connection data
	[self teardownSession];

	// create a dict to store peer information
	m_remoteConnectionsByPeerId = [[NSMutableDictionary alloc] init];
	
	// TODO
	// just get a UID for now
	UIDevice * device = [UIDevice currentDevice];
	//NSString * uniqueIdentifier = [device uniqueIdentifier];
	NSString * deviceName = [device name];
	
	// TODO
	// There seems to be a crash when the client object is destroyed
	// and the server is then created -- the (dealoc'd) client gets an
	// update that a new server has been detected, and then crashes. 
	// There seems to be some delay shortly after destrcution where
	// the client session is still active.. Add a delay here for now.
	// .. or maybe i'm just dumb .. the object wasn't being released x.x
	//[NSThread sleepForTimeInterval:1.0];
	
	// setup our connection
	m_remoteSession = [[GKSession alloc] initWithSessionID:SESSION_ID
											   displayName:deviceName
											   sessionMode:mode];
	
	m_remoteSession.delegate = self;
	
	[m_remoteSession setDataReceiveHandler:self withContext:NULL];
	
	m_remoteSession.available = YES;
	
}

- (void)startServerSessionAndWaitForClients
{
	[self startSessionWithType:GKSessionModeServer];
}

- (void)startClientSessionAndLookForServers
{
	[self startSessionWithType:GKSessionModeClient];
}

- (void)connectToPeerId:(NSString*)peerId
{
	[m_remoteSession connectToPeer:peerId withTimeout:10];
}

- (void)acceptConnectionFromPeerId:(NSString*)peerId
{
	[m_remoteSession acceptConnectionFromPeer:peerId error:nil];
}

- (void)denyConnectionFromPeerId:(NSString*)peerId
{
	// realistically its probably not ever worth 
	// explicitly denying someone, but good to have.
	[m_remoteSession denyConnectionFromPeer:peerId];
	
}

- (void)disconnectFromPeerId:(NSString*)peerId
{

	[m_remoteSession disconnectPeerFromAllPeers:peerId];
	
	[m_remoteConnectionsByPeerId removeObjectForKey:peerId];

}

- (void)disconnectFromAllPeers
{
	
	[m_remoteSession disconnectFromAllPeers];
	
	[m_remoteConnectionsByPeerId removeAllObjects];
	
}

#pragma mark -
#pragma mark Packet send handlers

- (bool)sendErrorToPeerId:(NSString*)peerId 
		   withPacketType:(IntranetMultiplayerPacketType)packetType
			  andPacketNumber:(unsigned int)packetNumber
{
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(PacketError); // o
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = PacketTypeError;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize;
	
	PacketError * packetData = (PacketError*)(&packet.m_data);
	packetData->m_errorPacketType = packetType;
	packetData->m_errorPacketNumber = packetNumber;
	
	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
	
	NSArray * peers = [NSArray arrayWithObject:peerId];
	
	NSError * error = nil;
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];
	
	if ( error != nil )
	{
		return NO;
	}
	
	return YES;
	
}

//- (bool)sendPingToPeerId:(NSString*)peerId inSession:(GKSession*)session
- (bool)sendPingToPeerId:(NSString*)peerId
{
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;

	unsigned int dataSize = sizeof(PacketPing); // o
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;

	header->m_packetType = PacketTypePing;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 

	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];

	NSArray * peers = [NSArray arrayWithObject:peerId];

	NSError * error = nil;
	
	// save this ping time so we can calc the latency
	IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];
	
	remoteState.m_remoteLastPingSentTime = CACurrentMediaTime();
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];
	
	if ( error != nil )
	{
		return NO;
	}
	
	return YES;
}

//- (bool)sendPongToPeerId:(NSString*)peerId inSession:(GKSession*)session
- (bool)sendPongToPeerId:(NSString*)peerId
{
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(PacketPong); // o
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = PacketTypePong;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 
	
	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
	
	NSArray * peers = [NSArray arrayWithObject:peerId];
	
	NSError * error = nil;
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];
	
	if ( error != nil )
	{
		return NO;
	}
	
	return YES;
}

//- (bool)sendTimeSyncRequestToPeerId:(NSString*)peerId inSession:(GKSession*)session
- (bool)sendTimeSyncRequestToPeerId:(NSString*)peerId
{
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(PacketTimeSyncRequest);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = PacketTypeTimeSyncRequest;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 
	
	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
	
	NSArray * peers = [NSArray arrayWithObject:peerId];
	
	NSError * error = nil;
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];
	
	if ( error != nil )
	{
		return NO;
	}
	
	return YES;
	
}

//- (bool)sendTimeSyncResponseToPeerId:(NSString*)peerId inSession:(GKSession*)session
//			 withRequestReceivedTime:(double)rrt andResponseSentTime:(double)rst
//- (bool)sendTimeSyncResponseToPeerId:(NSString*)peerId inSession:(GKSession*)session
//			 withRequestReceivedTime:(double)receivedTime
- (bool)sendTimeSyncResponseToPeerId:(NSString*)peerId
			 withRequestReceivedTime:(double)receivedTime

{
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(PacketTimeSyncRequest);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = PacketTypeTimeSyncRequest;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize;
	
	NSArray * peers = [NSArray arrayWithObject:peerId];
	
	NSError * error = nil;

	// put this right before we send so our timing is as close as possible
	PacketTimeSyncResponse * packetData = (PacketTimeSyncResponse*)(&packet.m_data);
	packetData->m_requestReceivedTime = receivedTime;
	packetData->m_responseSentTime = CACurrentMediaTime();
	
	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];

	if ( error != nil )
	{
		return NO;
	}

	return YES;
	
}

//- (bool)transferDataToPeerId:(NSString*)peerId inSession:(GKSession*)session 
//					withData:(NSString*)data
- (bool)transferDataToPeerId:(NSString*)peerId withData:(NSString*)data andTransferId:(unsigned int)transferId
{
	
	const char * bytesToSend = [data cStringUsingEncoding:NSASCIIStringEncoding];
	unsigned int bytesLeft = [data cStringLength];
	bool firstSend = YES;
	
	while ( bytesLeft > 0 )
	{
		PacketGeneric packet;
		PacketHeader * header = (PacketHeader*)&packet.m_header;
		
		// how much data can we fit in this packet
		unsigned int thisPacketTransferSize = bytesLeft;
		
		if ( thisPacketTransferSize > MAX_TRANSFER_PACKET_DATA_SIZE )
		{
			thisPacketTransferSize = MAX_TRANSFER_PACKET_DATA_SIZE;
		}
		
		bytesLeft -= thisPacketTransferSize;

		// change the packet type based on if this is first or n'th
		if ( firstSend == YES )
		{
			firstSend = NO;
			
			header->m_packetType = PacketTypeDataTransferStart;
			header->m_packetNumber = m_packetNumber++;
			
			PacketDataTransferStart * packetData = (PacketDataTransferStart*)packet.m_data;
			packetData->m_transferId = transferId;
			packetData->m_transferSize = thisPacketTransferSize;
			
			if ( bytesLeft > 0 )
			{
				packetData->m_transferLast = false;
			}
			else 
			{
				packetData->m_transferLast = true;
			}

			memcpy( packetData->m_transferStart, bytesToSend, thisPacketTransferSize );

			header->m_dataSize = sizeof(PacketDataTransferStart) + thisPacketTransferSize;
			
		}
		else
		{
			header->m_packetType = PacketTypeDataTransferContinuation;
			header->m_packetNumber = m_packetNumber++;

			PacketDataTransferContinuation * packetData = (PacketDataTransferContinuation*)packet.m_data;
			packetData->m_transferId = transferId;
			packetData->m_transferSize = thisPacketTransferSize;
			
			if ( bytesLeft > 0 )
			{
				packetData->m_transferLast = false;
			}
			else 
			{
				packetData->m_transferLast = true;
			}
			
			memcpy( packetData->m_transferContinuation, bytesToSend, thisPacketTransferSize );

			header->m_dataSize = sizeof(PacketDataTransferContinuation) + thisPacketTransferSize;
		}

		unsigned int packetSize = sizeof(PacketHeader) + header->m_dataSize;
		
		NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
		
		NSArray * peers = [NSArray arrayWithObject:peerId];
		
		NSError * error = nil;
		
		[m_remoteSession sendData:data
						  toPeers:peers
					 withDataMode:GKSendDataReliable
							error:&error];
		
		if ( error != nil )
		{
			return NO;
		}
		
		// increment the pointer for the next iteration
		bytesToSend += thisPacketTransferSize;
		
	}
	
	return YES;
}

- (bool)sendBeepSyncronizationRequestToPeerId:(NSString*)peerId withTimeDelta:(double)delta
{
	
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(PacketBeepSyncronizationRequest);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = PacketTypeBeepSyncronizationRequest;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 
	
	PacketBeepSyncronizationRequest * request = (PacketBeepSyncronizationRequest*)(&packet.m_data);
	request->m_delta = delta;
	
	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
	
	NSArray * peers = [NSArray arrayWithObject:peerId];
	
	NSError * error = nil;
	
	IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];

	remoteState.m_beepRequestSent = CACurrentMediaTime();
	//remoteState.m_beepRequestSent = delta;
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];


	if ( error != nil )
	{
		return NO;
	}
	
	return YES;
	
}

- (bool)sendBeepSyncronizationResponseToPeerId:(NSString*)peerId
{
	
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(PacketBeepSyncronizationResponse);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = 	PacketTypeBeepSyncronizationResponse;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 
	
	NSData * data = [NSData dataWithBytes:((char*)&packet) length:packetSize];
	
	NSArray * peers = [NSArray arrayWithObject:peerId];
	
	NSError * error = nil;
	
	[m_remoteSession sendData:data
					  toPeers:peers
				 withDataMode:GKSendDataReliable
						error:&error];
	
	if ( error != nil )
	{
		return NO;
	}
	
	return YES;
	
}

#pragma mark -
#pragma mark Packet recv handlers

- (void)receivedErrorFromPeerId:(NSString*)peerId
{
	// do stuff - pure virtual
}

- (void)receivedPongFromPeerId:(NSString*)peerId
{
	// do stuff - pure virtual
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

- (void)receivedDataTransferContinuationFromPeerId:(NSString*)peerId 
									withTransferId:(unsigned int)transferId
									  transferSize:(unsigned int)transferSize
										   andData:(char *)data
											isLast:(bool)isLast
{
	// do stuff - pure virtual**
}

- (void)receivedBeepSyncronizationRequestFromPeerId:(NSString*)peerId withTime:(double)time
{
	
}

- (void)receivedBeepSyncronizationResponseFromPeerId:(NSString*)peerId
{
	
	
}


#pragma mark -
#pragma mark GKSessionDelegate -> Both Methods

// this recv callback is set at the time we created+init'd session object
- (void)receiveData:(NSData*)data 
		   fromPeer:(NSString*)peerId
		  inSession:(GKSession*)session
			context:(void*)context
{ 
	
	double receivedTime = CACurrentMediaTime();
	
	if ( [data length] > MAX_PACKET_SIZE )
	{
		// TODO error
		//return;
	}
	
	PacketGeneric * packet = (PacketGeneric*)[data bytes];
	PacketHeader * header = (PacketHeader*)(&packet->m_header);
	
	// make sure the packets are in order
	IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];
	
	if ( remoteState == nil )
	{
		// how did this peer get connected?
		// TODO error
		return;
	}
	
	// check then update the packet number for this client
	if ( remoteState.m_remotePacketNumber > header->m_packetNumber )
	{
		// TODO error
		return;
	}
	
	remoteState.m_remotePacketNumber = header->m_packetNumber;
	
	switch ( header->m_packetType )
	{
		case PacketTypePing:
		{

			[self sendPongToPeerId:peerId];
			
		} break;
			
		case PacketTypePong:
		{
			
			IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];
			
			remoteState.m_remoteLastRtt = receivedTime - remoteState.m_remoteLastPingSentTime;
			
			[self receivedPongFromPeerId:peerId];
			
		} break;
			
		case PacketTypeTimeSyncRequest:
		{
			
			[self sendTimeSyncResponseToPeerId:peerId withRequestReceivedTime:receivedTime];
			
		} break;
			
		case PacketTypeTimeSyncResponse:
		{
			PacketTimeSyncResponse * response = (PacketTimeSyncResponse*)(packet->m_data);
			
			[self receivedTimeSyncResponseFromPeerId:peerId 
									 withReceiveTime:response->m_requestReceivedTime
										 andSendTime:response->m_responseSentTime ];
		} break;
			
		case PacketTypeDataTransferStart:
		{
			PacketDataTransferStart * transfer = (PacketDataTransferStart*)(packet->m_data);
			
			[self receivedDataTransferStartFromPeerId:peerId 
									   withTransferId:transfer->m_transferId
										 transferSize:transfer->m_transferSize
											  andData:transfer->m_transferStart
											   isLast:transfer->m_transferLast];
		} break;
			
		case PacketTypeDataTransferContinuation:
		{
			PacketDataTransferContinuation * transfer = (PacketDataTransferContinuation*)(packet->m_data);
			
			[self receivedDataTransferContinuationFromPeerId:peerId 
											  withTransferId:transfer->m_transferId
												transferSize:transfer->m_transferSize
													 andData:transfer->m_transferContinuation
													  isLast:transfer->m_transferLast];
		} break;
			
		case PacketTypeBeepSyncronizationRequest:
		{
			PacketBeepSyncronizationRequest * request = (PacketBeepSyncronizationRequest*)(packet->m_data);
			
			double time = request->m_delta + receivedTime;

			[self sendBeepSyncronizationResponseToPeerId:peerId];
			
			[self beepSyncronizationStartAtTime:time];
			
		} break;

		case PacketTypeBeepSyncronizationResponse:
		{

			IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];

			double rtt = receivedTime - remoteState.m_beepRequestSent;
			
			double remoteOffset = rtt / 2.0;
			
			double time = (receivedTime - remoteOffset) + SECONDS_PER_BEEP_LOOP;
			
			[self beepSyncronizationStartAtTime:time];

		} break;
			
		case PacketTypeError:
		{
			
			[self receivedErrorFromPeerId:peerId];
			
		} break;
			
		case PacketTypeUnknown:
		default:
		{
			// durrr - send error packet
			[self sendErrorToPeerId:peerId
					 withPacketType:header->m_packetType
					andPacketNumber:header->m_packetNumber];
		}
			
	}

}

// This is where all the session state changes come in.
// A lot of these we want to direct off to stump 
// state handlers that the subclasses can replace.
- (void)session:(GKSession *)session
		   peer:(NSString *)peerId
 didChangeState:(GKPeerConnectionState)state
{
	
	switch ( state )
	{
		case GKPeerStateAvailable: 
		{
			// a client finds a server
			[self availablePeerId:peerId];
			
		} break;
			
		case GKPeerStateUnavailable:
		{
			// a client looses a server
			[self unavailablePeerId:peerId];
			
		} break;
			
		case GKPeerStateConnecting: 
		{
			// According to apple, implement:
			// -session:didReceiveConnectionRequestFromPeer:
			// .. instead. Leave this hear for completeness for now.
			[self connectingPeerId:peerId];
			
		} break;
			
		case GKPeerStateConnected:
		{

			// remember the state associated with this connection			
			IntranetMultiplayerRemoteState * remoteState = [[IntranetMultiplayerRemoteState alloc] init];
			
			remoteState.m_remotePeerId = peerId;
			remoteState.m_remoteName = [m_remoteSession displayNameForPeer:peerId];
			remoteState.m_remotePacketNumber = 0;
			remoteState.m_remoteLastHeartbeatDate = 0;
			
			[m_remoteConnectionsByPeerId setObject:remoteState forKey:peerId];

			[self connectedPeerId:peerId];
			
		} break;
			
		case GKPeerStateDisconnected:
		{

			// gone and forgotten
			[m_remoteConnectionsByPeerId removeObjectForKey:peerId];
			
			[self disconnectedPeerId:peerId];
			
		} break;
			
		default:
		{
			// nothing; shouldn't happen
		}
	}
}

#pragma mark -
#pragma mark GKSessionDelegate -> Server Methods

// a client is trying to connect
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerId
{

//	[self connectingPeerId:peerId];
	
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerId
	  withError:(NSError *)error
{
	
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	
}


#pragma mark GKSessionDelegate -> Client Methods

// nothing!

#pragma mark -
#pragma mark 'Pure Virtual' state change handlers

// not connected to session, but available for connectToPeer:withTimeout:
- (void)availablePeerId:(NSString*)peerId
{
	// empty
}

// no longer available
- (void)unavailablePeerId:(NSString*)peerId
{
	// empty
}

// connected to the session
- (void)connectedPeerId:(NSString*)peerId
{
	// empty
}

// disconnected from the session
- (void)disconnectedPeerId:(NSString*)peerId
{
	// empty
}

// waiting for accept, or deny response   
- (void)connectingPeerId:(NSString*)peerId
{
	// empty
}

#pragma mark -
#pragma mark Misc. External Helpers

- (double)latencyForConnectedPeerId:(NSString*)peerId
{
	IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];
	
	return remoteState.m_remoteLastRtt;
}

- (NSString*)nameForPeerId:(NSString*)peerId
{
	return [m_remoteSession displayNameForPeer:peerId];
}

#pragma mark -
#pragma mark Syncronization methods

- (void)beepSyncronizationBegin
{

	NSArray * peerIds = [m_remoteConnectionsByPeerId allKeys];
	
	for ( unsigned int i = 0; i < [peerIds count]; i++ )
	{
		NSString * peerId = [peerIds objectAtIndex:i];
		
//		[self sendBeepSyncronizationRequestToPeerId:peerId withTimeDelta:SECONDS_PER_BEEP_LOOP];
		[self beepSyncronizationBeginPeerId:peerId];
	}

}

- (void)beepSyncronizationBeginPeerId:(NSString*)peerId
{
	[self sendBeepSyncronizationRequestToPeerId:peerId withTimeDelta:SECONDS_PER_BEEP_LOOP];
}

- (void)beepSyncronizationStartAtTime:(double)time
{
	double currentTime = CACurrentMediaTime();

	double delta = time - currentTime;
	
	if ( delta > 0 )
	{
		[NSThread sleepForTimeInterval:delta];
	}
	
	m_beepLoopsRemaining = 2;
	
	m_beepTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)SECONDS_PER_BEEP_LOOP
												   target:self
												 selector:@selector(beepSyncronizationLoop)
												 userInfo:nil
												  repeats:TRUE];
}

- (void)beepSyncronizationLoop
{

	// make a sound
	[m_audioController PluckString:3 atFret:3];
	
	m_beepLoopsRemaining--;

	if ( m_beepLoopsRemaining <= 0 )
	{
		[m_beepTimer invalidate];
		m_beepTimer = nil;
	}
}
	
	
@end
