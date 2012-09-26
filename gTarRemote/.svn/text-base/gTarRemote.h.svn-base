//
//  gTarRemote.h
//  gTarRemote
//
//  Created by Marty Greenia on 11/15/10.
//  Copyright 2010 Incident Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef struct
{
	char notesOn[78];
	char fretDown[78];
} DeviceOutput;

typedef struct
{
	char ledsOn[78];
} DeviceInput;

typedef enum
{
	DevicePeer,
	HostPeer
} RemotePeerStatus;

@protocol gTarRemoteDevice
-(void)deviceRecvDeviceInput:(DeviceInput*)dinput;
-(void)deviceEndpointDisconnected;
-(void)deviceEndpointConnected;
@end

@protocol gTarRemoteHost
-(void)hostRecvDeviceOutput:(DeviceOutput*)doutput;
-(void)hostEndpointDisconnected;
-(void)hostEndpointConnected;
@end

#define SessionID @"gtarremote"

#define MaxPacketSize 1024

@interface gTarRemote : NSObject <GKSessionDelegate, GKPeerPickerControllerDelegate>
{
	
	id<gTarRemoteDevice> m_deviceDelegate;
	id<gTarRemoteHost> m_hostDelegate;
	
	NSInteger m_peerStatus;
	
	// networking
	GKSession * m_remoteSession;
//	int m_remoteUniqueID;
	int	m_remotePacketNumber;
	
	NSString * m_remotePeerId;
	NSDate * m_lastHeartbeatDate;
	
	DeviceInput m_dinput;
	DeviceOutput m_doutput;
	
}

@property(nonatomic) NSInteger m_peerStatus;

@property(nonatomic, retain) GKSession * m_remoteSession;
@property(nonatomic, copy) NSString * m_remotePeerId;
@property(nonatomic, retain) NSDate	* m_lastHeartbeatDate;

- (gTarRemote*)initHost;
- (gTarRemote*)initDevice;
- (void)sharedInit;

-(void)hostTransferControl:(id<gTarRemoteHost>)newDelegate;
-(void)deviceTransferControl:(id<gTarRemoteDevice>)newDelegate;

- (void)startHostSession:(id<gTarRemoteHost>)delegate;
- (void)startDeviceSession:(id<gTarRemoteDevice>)delegate;

- (void)hostSendDeviceInput:(DeviceInput*)dinput;
- (void)deviceSendDeviceOutput:(DeviceOutput*)doutput;

- (void)invalidateSession:(GKSession*)session;
- (void)sendNetworkPacket:(GKSession*)session withData:(void*)data ofLength:(int)length;

- (void)flushState;

- (void)ledOnString:(char)str andFret:(char)fret;
- (void)ledOffString:(char)str andFret:(char)fret;

- (void)fretDownString:(char)str andFret:(char)fret;
- (void)fretUpString:(char)str andFret:(char)fret;
- (void)noteOnString:(char)str andFret:(char)fret;
- (void)noteOffString:(char)str andFret:(char)fret;

@end
