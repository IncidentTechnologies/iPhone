//
//  IntranetMultiplayerPicker.h
//  gTar
//
//  Created by Marty Greenia on 2/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntranetMultiplayerClient.h"
#import "IntranetMultiplayerServer.h"


@interface IntranetMultiplayerPicker : UIViewController <IntranetMultiplayerClientDelegate, IntranetMultiplayerServerDelegate>
{
	IBOutlet UITableView * m_multiplayerTable;

	IntranetMultiplayerServer * m_multiplayerServer;
	IntranetMultiplayerClient * m_multiplayerClient;

	NSArray * m_multiplayerTableServerPeerIds;
	NSArray * m_multiplayerTableConnectingClientPeerIds;
	NSArray * m_multiplayerTableConnectedClientPeerIds;
}

@property (nonatomic, retain) UITableView * m_multiplayerTable;
@property (nonatomic, retain) IntranetMultiplayerServer * m_multiplayerServer;
@property (nonatomic, retain) IntranetMultiplayerClient * m_multiplayerClient;
	
- (void)lookForServers;
- (void)waitForClients;

- (void)clearServerClientState;

@end
