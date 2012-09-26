//
//  JamIntranetMultiplayerShared.h
//  gTar
//
//  Created by Marty Greenia on 2/8/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiplayerController.h"

enum JamIntranetMultiplayerPacketType
{
	// we don't want the packet enum to collide with the parent's
	JamPacketTypeUnknown = PacketTypeMaxUnused,
	JamPacketTypeBeginSession,
	JamPacketTypeEndSession,
	JamPacketTypeStartRecordingRequest,
	JamPacketTypeStartRecordingResponse,
	JamPacketTypeStopRecording,
	JamPacketTypeMaxUnused
};

typedef struct
{
	// nothing
} JamPacketBeginSession;

typedef struct
{
	// nothing
} JamPacketEndSession;

typedef struct
{
	double m_delta;
} JamPacketStartRecordingRequest;

typedef struct
{
	// nothing
} JamPacketStartRecordingResponse;

typedef struct
{
	unsigned int m_transferId;
} JamPacketStopRecording;
