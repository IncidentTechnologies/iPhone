//
//  IntranetMultiplayerRemoteState.h
//  gTar
//
//  Created by Marty Greenia on 2/4/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IntranetMultiplayerRemoteState : NSObject
{
	NSString * m_remotePeerId;
	NSString * m_remoteName;
	NSDate * m_remoteLastHeartbeatDate;
	int m_remotePacketNumber;
	
	double m_remoteLastRtt;
	double m_remoteLastPingSentTime;
	
	double m_beepRequestSent;
	double m_recordRequestSent;

}

@property (nonatomic, copy) NSString * m_remotePeerId;
@property (nonatomic, copy) NSString * m_remoteName;
@property (nonatomic, retain) NSDate * m_remoteLastHeartbeatDate;
@property (nonatomic, assign) int m_remotePacketNumber;
@property (nonatomic, assign) double m_remoteLastRtt;
@property (nonatomic, assign) double m_remoteLastPingSentTime;
@property (nonatomic, assign) double m_beepRequestSent;
@property (nonatomic, assign) double m_recordRequestSent;

@end
