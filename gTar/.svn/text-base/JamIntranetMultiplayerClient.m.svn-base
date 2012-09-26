//
//  JamIntranetMultiplayerClient.m
//  gTar
//
//  Created by Marty Greenia on 2/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "JamIntranetMultiplayerClient.h"

@implementation JamIntranetMultiplayerClient

@synthesize jamDelegate;

- (void)dealloc
{
	
	self.jamDelegate = nil;
	
	[super dealloc];
	
}

#pragma mark -
#pragma mark Send handlers

- (bool)sendStartRecordingResponseToPeerId:(NSString*)peerId
{
	PacketGeneric packet;
	PacketHeader * header = (PacketHeader*)&packet.m_header;
	
	unsigned int dataSize = sizeof(JamPacketTypeStartRecordingResponse);
	unsigned int packetSize = sizeof(PacketHeader) + dataSize;
	
	header->m_packetType = (IntranetMultiplayerPacketType)JamPacketTypeStartRecordingResponse;
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

- (bool)sendXmpBlobToServer:(NSString*)xmpBlob
{
	NSString * peerId = [self connectedServerPeerId];
	
	return [self transferDataToPeerId:peerId
							 withData:xmpBlob
						andTransferId:m_transferId];
}

#pragma mark -
#pragma mark Receive handler

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
		case JamPacketTypeBeginSession:
		{
			[jamDelegate clientBeginSession:self];
			
		} break;
			
		case JamPacketTypeEndSession:
		{
			[jamDelegate clientEndSession:self];
			
		} break;
			
		case JamPacketTypeStartRecordingRequest:
		{
			JamPacketStartRecordingRequest * start = (JamPacketStartRecordingRequest*)(packet->m_data);
			
			double delta = start->m_delta;
			
			[self sendStartRecordingResponseToPeerId:peerId];
			
			[jamDelegate client:self startRecordingInTimeDelta:delta];
			
		} break;
			
		case JamPacketTypeStopRecording:
		{
			JamPacketStopRecording * stop = (JamPacketStopRecording*)(packet->m_data);

			m_transferId = stop->m_transferId;
			
			[jamDelegate clientStopRecordingSendXmp:self];

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

@end
