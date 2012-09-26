//
//  IntranetMultiplayerServer.h
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "MultiplayerController.h"
#import "IntranetClientState.h"

@class IntranetMultiplayerServer;


@protocol IntranetMultiplayerServerDelegate
- (void)connectingClientsChanged:(IntranetMultiplayerServer*)server;
- (void)connectedClientsChanged:(IntranetMultiplayerServer*)server;
- (void)connectedClientsStateChanged:(IntranetMultiplayerServer*)server;
@end

@interface IntranetMultiplayerServer : MultiplayerController
{

	// server side stuff
//	GKSession * m_serverSession; // togo
	id<IntranetMultiplayerServerDelegate> delegate;
	
	NSMutableArray * m_connectingClientsPeerIds;
	//NSMutableDictionary * m_connectedClientStateByPeerId;  // togo
	
	NSTimer * m_pingTimer;

}

//@property (nonatomic, readonly) unsigned int m_connectedClientsCount;
@property (nonatomic, retain) id<IntranetMultiplayerServerDelegate> delegate;

/*
- (void)startServerSessionAndWaitForClients;
- (void)acceptConnectionFromClientPeerId:(NSString*)peerId;
- (void)denyConnectionFromClientPeerId:(NSString*)peerId;
- (void)disconnectFromClientPeerId:(NSString*)peerId;
- (void)disconnectFromAllClients;
*/
- (void)pingAllClients;

- (NSArray*)connectedClientsNames;
- (NSArray*)connectedClientsPeerIds;
- (NSInteger)connectedClientsCount;
- (NSArray*)connectedClientsRtt;

- (NSArray*)connectingClientsNames;
- (NSArray*)connectingClientsPeerIds;
- (NSInteger)connectingClientsCount;

@end
