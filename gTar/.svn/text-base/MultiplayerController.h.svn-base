//
//  MultiplayerController.h
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <QuartzCore/QuartzCore.h> // for CACurrentMediaTime()

#import "AudioController.h"
#import "IntranetMultiplayerRemoteState.h"

// Minus the server = number of remote connections
#define MAX_PLAYERS 4
#define MAX_CLIENTS (MAX_PLAYERS-1) 

#define SESSION_ID @"gTarJam"
//#define DISPLAY_NAME @"gTar Jam Session"

#define MAX_PACKET_SIZE 1024

// syncronization
#define SECONDS_PER_BEEP_LOOP 2.0

enum IntranetMultiplayerPacketType
{
	PacketTypeUnknown = 0,
	PacketTypeError,
	PacketTypePing,
	PacketTypePong,
	PacketTypeTimeSyncRequest,
	PacketTypeTimeSyncResponse,
	PacketTypeDataTransferStart,
	PacketTypeDataTransferContinuation,
	PacketTypeBeepSyncronizationRequest,
	PacketTypeBeepSyncronizationResponse,
	PacketTypeMaxUnused
};

// packet definitions
struct PacketHeader
{
	IntranetMultiplayerPacketType m_packetType;
	unsigned int m_packetNumber;
	unsigned int m_dataSize;
};

#define MAX_PACKET_DATA_SIZE (MAX_PACKET_SIZE - sizeof(PacketHeader))

typedef struct 
{
	PacketHeader m_header;
	char m_data[MAX_PACKET_DATA_SIZE];
} PacketGeneric;

typedef struct
{
	IntranetMultiplayerPacketType m_errorPacketType;
	unsigned int m_errorPacketNumber;
} PacketError;

typedef struct
{
	// nothing in a ping!
} PacketPing;

typedef struct
{
	// nothing in a pong!
} PacketPong;

typedef struct 
{
	// nothing in a sync req!
} PacketTimeSyncRequest;

typedef struct
{
	double m_requestReceivedTime;
	double m_responseSentTime;
} PacketTimeSyncResponse;

#define MAX_TRANSFER_PACKET_DATA_SIZE (MAX_PACKET_DATA_SIZE - sizeof(PacketDataTransferStart))

typedef struct
{
	unsigned int m_transferId;
	unsigned int m_transferSize;
	unsigned int m_transferLast;
	char m_transferStart[0];
} PacketDataTransferStart;

typedef struct
{
	unsigned int m_transferId;
	unsigned int m_transferSize;
	unsigned int m_transferLast;
	char m_transferContinuation[0];
} PacketDataTransferContinuation;

typedef struct
{
	double m_delta;
} PacketBeepSyncronizationRequest;

typedef struct 
{
	// nothing!
} PacketBeepSyncronizationResponse;

@interface MultiplayerController : NSObject <GKSessionDelegate>
{
	GKSession * m_remoteSession;
	
	NSMutableDictionary * m_remoteConnectionsByPeerId;
	
	unsigned int m_packetNumber;
	
	// AudioController
	AudioController * m_audioController;
	NSInteger m_beepLoopsRemaining;
	NSTimer * m_beepTimer;
	
	//

}

// Session helpers
- (void)teardownSession;
- (void)startSessionWithType:(GKSessionMode)mode;
- (void)startServerSessionAndWaitForClients;
- (void)startClientSessionAndLookForServers;
- (void)connectToPeerId:(NSString*)peerId;
- (void)acceptConnectionFromPeerId:(NSString*)peerId;
- (void)denyConnectionFromPeerId:(NSString*)peerId;
- (void)disconnectFromPeerId:(NSString*)peerId;
- (void)disconnectFromAllPeers;

// Send handlers
- (bool)sendErrorToPeerId:(NSString*)peerId withPacketType:(IntranetMultiplayerPacketType)packetType andPacketNumber:(unsigned int)packetNumber;
- (bool)sendPingToPeerId:(NSString*)peerId;
- (bool)sendPongToPeerId:(NSString*)peerId;
- (bool)sendTimeSyncRequestToPeerId:(NSString*)peerId;
- (bool)sendTimeSyncResponseToPeerId:(NSString*)peerId withRequestReceivedTime:(double)receivedTime;
- (bool)transferDataToPeerId:(NSString*)peerId withData:(NSString*)data andTransferId:(unsigned int)transferId;
- (bool)sendBeepSyncronizationRequestToPeerId:(NSString*)peerId withTimeDelta:(double)delta;
- (bool)sendBeepSyncronizationResponseToPeerId:(NSString*)peerId;

// Recv handlers (virtual)
- (void)receivedErrorFromPeerId:(NSString*)peerId;
- (void)receivedPongFromPeerId:(NSString*)peerId;
- (void)receivedTimeSyncResponseFromPeerId:(NSString*)peerId withReceiveTime:(double)receiveTime andSendTime:(double)sendTime;
- (void)receivedDataTransferStartFromPeerId:(NSString*)peerId withTransferId:(unsigned int)transferId transferSize:(unsigned int)transferSize andData:(char *)data isLast:(bool)isLast;
- (void)receivedDataTransferContinuationFromPeerId:(NSString*)peerId withTransferId:(unsigned int)transferId transferSize:(unsigned int)transferSize andData:(char *)data isLast:(bool)isLast;
- (void)receivedBeepSyncronizationRequestFromPeerId:(NSString*)peerId withTime:(double)time;
- (void)receivedBeepSyncronizationResponseFromPeerId:(NSString*)peerId;

// GKSession delegate
- (void)session:(GKSession *)session peer:(NSString *)peerId didChangeState:(GKPeerConnectionState)state;
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerId;
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerId withError:(NSError *)error;
- (void)session:(GKSession *)session didFailWithError:(NSError *)error;

// state change handlers -- virtual
- (void)availablePeerId:(NSString*)peerId;
- (void)unavailablePeerId:(NSString*)peerId;
- (void)connectedPeerId:(NSString*)peerId;
- (void)disconnectedPeerId:(NSString*)peerId;
- (void)connectingPeerId:(NSString*)peerId;

// External helpers
- (double)latencyForConnectedPeerId:(NSString*)peerId;
- (NSString*)nameForPeerId:(NSString*)peerId;

// Syncronization test
- (void)beepSyncronizationBegin;
- (void)beepSyncronizationBeginPeerId:(NSString*)peerId;
- (void)beepSyncronizationStartAtTime:(double)time;
- (void)beepSyncronizationLoop;

@end
