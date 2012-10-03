//
//  IntranetMultiplayerClient.h
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "MultiplayerController.h"

@protocol IntranetMultiplayerClientDelegate
- (void)availableServersChanged;
- (void)connectedServerChanged;
- (void)connectedServerStateChanged;
@end

@interface IntranetMultiplayerClient : MultiplayerController
{
//	GKSession * m_clientSession; // togo

	id<IntranetMultiplayerClientDelegate> delegate;
	
	NSMutableArray * m_availableServers;
	
	NSTimer * m_pingTimer;

//	NSString * m_serverPeerId;  // togo
//	NSString * m_serverName;  // togo
//	NSDate * m_serverLastHeartbeatDate;  // togo
//	int m_serverPacketNumber;  // togo
}

//@property (nonatomic, readonly) NSArray * m_availableServers;
@property (nonatomic, retain) id<IntranetMultiplayerClientDelegate> delegate;

//- (void)startClientSessionAndLookForServers;

- (NSArray*)availableServersNames;
- (NSArray*)availableServersPeerIds;
- (NSInteger)availableServersCount;

- (NSString*)connectedServerName;
- (NSString*)connectedServerPeerId;
- (bool)connectedToServer;
- (NSNumber*)connectedServerRtt;

@end
