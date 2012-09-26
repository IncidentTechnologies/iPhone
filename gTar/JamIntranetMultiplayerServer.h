//
//  JamIntranetMultiplayerServer.h
//  gTar
//
//  Created by Marty Greenia on 2/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JamIntranetMultiplayerShared.h"
#import "IntranetMultiplayerServer.h"

@class JamIntranetMultiplayerServer;

@protocol JamIntranetMultiplayerServerDelegate
- (void)serverBeginRecording:(JamIntranetMultiplayerServer*)server;
- (void)server:(JamIntranetMultiplayerServer*)server mergedXmpCompleted:(NSString*)xmpBlob;
@end

@interface JamIntranetMultiplayerServer : IntranetMultiplayerServer
{
	id<JamIntranetMultiplayerServerDelegate> jamDelegate;
	
	NSMutableString * m_partialTransfer;
}

@property (nonatomic, retain) id<JamIntranetMultiplayerServerDelegate> jamDelegate;

- (void)beginJamSession;
- (void)endJamSession;
- (void)allClientsStartRecording;
- (void)allClientsStopRecording;

- (bool)sendBeginSessionToPeerId:(NSString*)peerId;
- (bool)sendEndSessionToPeerId:(NSString*)peerId;
- (bool)sendStartRecordingRequestToPeerId:(NSString*)peerId;
- (bool)sendStopRecordingToPeerId:(NSString*)peerId;

@end
