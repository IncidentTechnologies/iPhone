//
//  IntranetClientState.h
//  gTar
//
//  Created by Marty Greenia on 2/2/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@interface IntranetClientState : NSObject
{
//	GKSession * m_clientSession;
	NSString * m_clientPeerId;
	NSString * m_clientName;
	NSDate * m_clientLastHeartbeatDate;
	int m_clientPacketNumber;
}


//@property (nonatomic, retain) GKSession * m_clientSession;
@property (nonatomic, copy) NSString * m_clientPeerId;
@property (nonatomic, copy) NSString * m_clientName;
@property (nonatomic, retain) NSDate * m_clientLastHeartbeatDate;
@property (nonatomic, assign) int m_clientPacketNumber;

@end
