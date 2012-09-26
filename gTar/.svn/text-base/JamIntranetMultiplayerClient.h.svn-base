//
//  JamIntranetMultiplayerClient.h
//  gTar
//
//  Created by Marty Greenia on 2/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JamIntranetMultiplayerShared.h"
#import "IntranetMultiplayerClient.h"

@class JamIntranetMultiplayerClient;

@protocol JamIntranetMultiplayerClientDelegate
- (void)clientBeginSession:(JamIntranetMultiplayerClient*)client;
- (void)client:(JamIntranetMultiplayerClient*)client startRecordingInTimeDelta:(double)delta;
- (void)clientStopRecordingSendXmp:(JamIntranetMultiplayerClient*)client;
- (void)clientEndSession:(JamIntranetMultiplayerClient*)client;
@end

@interface JamIntranetMultiplayerClient : IntranetMultiplayerClient
{
	unsigned int m_transferId;
	id<JamIntranetMultiplayerClientDelegate>jamDelegate;
}

@property (nonatomic, retain) id<JamIntranetMultiplayerClientDelegate>jamDelegate;

- (void)sendXmpBlobToServer:(NSString*)xmpBlob;

@end

