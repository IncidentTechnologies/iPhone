//
//  JamIntranetMultiplayerServer.m
//  gTar
//
//  Created by Marty Greenia on 2/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "JamIntranetMultiplayerServer.h"


@implementation JamIntranetMultiplayerServer

@synthesize jamDelegate;

#pragma mark -
#pragma mark External methods

- (void)dealloc
{

	self.jamDelegate = nil;
	
	[super dealloc];
	
}

- (void)beginJamSession
{
	NSArray * peerIds =  [self connectedClientsPeerIds];
	
	for ( unsigned int index = 0; index < [peerIds count]; index++ )
	{
		NSString * peerId = [peerIds objectAtIndex:index];
		
		[self sendBeginSessionToPeerId:peerId];
	}
	
}

- (void)endJamSession
{
	NSArray * peerIds =  [self connectedClientsPeerIds];
	
	for ( unsigned int index = 0; index < [peerIds count]; index++ )
	{
		NSString * peerId = [peerIds objectAtIndex:index];
		
		[self sendEndSessionToPeerId:peerId];
	}
	
}

- (void)startRecording
{
	NSArray * peerIds =  [self connectedClientsPeerIds];
	
	for ( unsigned int index = 0; index < [peerIds count]; index++ )
	{
		NSString * peerId = [peerIds objectAtIndex:index];
		
		[self sendStartRecordingRequestToPeerId:peerId];
	}
	
}

- (void)stopRecording
{
	NSArray * peerIds =  [self connectedClientsPeerIds];
	
	for ( unsigned int index = 0; index < [peerIds count]; index++ )
	{
		NSString * peerId = [peerIds objectAtIndex:index];
		
		[self sendStopRecordingToPeerId:peerId];
	}
	
}

#pragma mark -
#pragma mark Send Handler

- (bool)sendBeginSessionToPeerId:(NSString*)peerId
{
	
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(JamPacketBeginSession);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = (IntranetMultiplayerPacketType)JamPacketTypeBeginSession;
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
- (bool)sendEndSessionToPeerId:(NSString*)peerId
{
	
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(JamPacketEndSession);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = (IntranetMultiplayerPacketType)JamPacketTypeEndSession;
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

- (bool)sendStartRecordingRequestToPeerId:(NSString*)peerId
{
	
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(JamPacketStartRecordingRequest);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = (IntranetMultiplayerPacketType)JamPacketTypeStartRecordingRequest;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 
	
	JamPacketStartRecordingRequest * request = (JamPacketStartRecordingRequest*)(&packet.m_data);
	request->m_delta = 2.0; //2.0;
	
	IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];
	remoteState.m_recordRequestSent = CACurrentMediaTime();
	
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

- (bool)sendStopRecordingToPeerId:(NSString*)peerId
{
	
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(JamPacketStopRecording);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = (IntranetMultiplayerPacketType)JamPacketTypeStopRecording;
	header->m_packetNumber = m_packetNumber++;
	header->m_dataSize = dataSize; 
	
	JamPacketStopRecording * stop = (JamPacketStopRecording*)(&packet.m_data);
	stop->m_transferId = 7;
	
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
#pragma mark Receive Handler

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
		case JamPacketTypeStartRecordingRequest:
		{
			// client only
		} break;
			
		case JamPacketTypeStartRecordingResponse:
		{

			// TODO hack
			IntranetMultiplayerRemoteState * remoteState = [m_remoteConnectionsByPeerId objectForKey:peerId];
			
			double rtt = receivedTime - remoteState.m_recordRequestSent;
			double latency = rtt / 2.0;
			
			[NSThread sleepForTimeInterval:(2.0 - latency)];
			
			[jamDelegate serverBeginRecording:self];
			
		} break;
			
		case JamPacketTypeStopRecording:
		{
			// client only
		} break;
			
		case JamPacketTypeUnknown:
		default:
		{
			// when theres nothing left to do, call the super
			[super receiveData:(NSData*)data 
					  fromPeer:(NSString*)peerId
					 inSession:(GKSession*)session
					   context:(void*)context];
		}
	}
	
}
		

- (void)receivedDataTransferStartFromPeerId:(NSString*)peerId 
							 withTransferId:(unsigned int)transferId
							   transferSize:(unsigned int)transferSize
									andData:(char *)data
									 isLast:(bool)isLast
{
	m_partialTransfer = [[NSMutableString alloc] init];
	
	[m_partialTransfer appendString:[NSString stringWithCString:data length:transferSize]];
	 
	 if ( isLast == TRUE )
	 {
		 [jamDelegate server:self mergedXmpCompleted:m_partialTransfer];
	 }
	 
}

- (void)receivedDataTransferContinuationFromPeerId:(NSString*)peerId 
									withTransferId:(unsigned int)transferId
									  transferSize:(unsigned int)transferSize
										   andData:(char *)data
											isLast:(bool)isLast
{
	
	[m_partialTransfer appendString:[NSString stringWithCString:data length:transferSize]];
	 
	 if ( isLast == TRUE )
	 {
		 [jamDelegate server:self mergedXmpCompleted:m_partialTransfer];
	 }
	 
}
@end
