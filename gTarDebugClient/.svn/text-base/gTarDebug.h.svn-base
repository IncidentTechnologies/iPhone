//
//  gTarDebug.h
//  gTarDebugFramework
//
//  Created by wuda on 10/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef struct
{
	char ledsOn[78];
	char notesOn[78];
	char notesOff[78];
	char fretDown[78];
} GuitarInfo;

typedef enum
{
	kServer,
	kClient
} DebugPeerStatus;

@protocol gTarDebugClient
-(void)clientRecvGuitarInfo:(GuitarInfo*)ginfo;
-(void)clientEndpointDisconnected;
@end

@protocol gTarDebugServer
-(void)serverRecvGuitarInfo:(GuitarInfo*)ginfo;
-(void)serverEndpointDisconnected;
@end

#define kSessionID @"gtardebug"

#define kMaxPacketSize 1024

@interface gTarDebug : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>
{
	
	id<gTarDebugClient> m_clientDelegate;
	id<gTarDebugServer> m_serverDelegate;
	
	//NSInteger	gameState;
	NSInteger	m_peerStatus;
	
	// networking
	GKSession		*m_gameSession;
	int				m_gameUniqueID;
	int				m_gamePacketNumber;
	NSString		*m_gamePeerId;
	NSDate			*m_lastHeartbeatDate;
	
}

@property(nonatomic) NSInteger		m_gameState;
@property(nonatomic) NSInteger		m_peerStatus;

@property(nonatomic, retain) GKSession	 *m_gameSession;
@property(nonatomic, copy)	 NSString	 *m_gamePeerId;
@property(nonatomic, retain) NSDate		 *m_lastHeartbeatDate;

-(gTarDebug*)initServer;
-(gTarDebug*)initClient;

- (void)startServerSession:(id<gTarDebugServer>)delegate;
- (void)startClientSession:(id<gTarDebugClient>)delegate;

- (void)serverSendGuitarInfo:(GuitarInfo*)ginfo;
- (void)clientSendGuitarInfo:(GuitarInfo*)ginfo;
- (void)invalidateSession:(GKSession *)session;

- (void)sendNetworkPacket:(GKSession *)session withData:(void *)data ofLength:(int)length;

@end
