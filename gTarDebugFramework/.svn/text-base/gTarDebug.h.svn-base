//
//  gTarDebug.h
//  gTarDebugFramework
//
//  Created by Marty Greenia on 10/28/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef struct
{
	char notesOn[78];
	char fretDown[78];
} GuitarOutput;

typedef struct
{
	char ledsOn[78];
} GuitarInput;

typedef enum
{
	kServer,
	kClient
} DebugPeerStatus;

@protocol gTarDebugClient
-(void)clientRecvGuitarInput:(GuitarInput*)ginput;
-(void)clientEndpointDisconnected;
-(void)clientEndpointConnected;
@end

@protocol gTarDebugServer
-(void)serverRecvGuitarOutput:(GuitarOutput*)goutput;
-(void)serverEndpointDisconnected;
-(void)serverEndpointConnected;
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
	
	GuitarInput m_ginput;
	GuitarOutput m_goutput;
	
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

- (void)serverSendGuitarInput:(GuitarInput*)ginput;
- (void)clientSendGuitarOutput:(GuitarOutput*)goutput;
- (void)invalidateSession:(GKSession *)session;

- (void)sendNetworkPacket:(GKSession *)session withData:(void *)data ofLength:(int)length;

- (void)flushState;

- (void)ledOnString:(char)str andFret:(char)fret;
- (void)ledOffLedString:(char)str andFret:(char)fret;

- (void)fretDownString:(char)str andFret:(char)fret;
- (void)fretUpString:(char)str andFret:(char)fret;
- (void)noteOnString:(char)str andFret:(char)fret;
- (void)noteOffString:(char)str andFret:(char)fret;
@end
