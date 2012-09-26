//
//  GtarControllerInternal.h
//  GtarController
//
//  Created by Marty Greenia on 5/24/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#ifndef GtarController_GtarControllerInternal_h
#define GtarController_GtarControllerInternal_h

#import <Foundation/Foundation.h>

#import "GtarController.h"

#import "EHM.h"

typedef SInt32 MIDINotificationMessageID;

class CoreMidiInterface;
@class NetSockConn;

@protocol GtarControllerDelegate <NSObject>
- (void)ReceivedFWVersion:(int)MajorVersion andMinorVersion:(int)MinorVersion;
- (void)RxFWUpdateACK:(unsigned char)status;

- (void)SocketRxBytes:(NSString *)pstrRx;
- (void)SocketConnected;
- (void)SocketConnectionError;
- (void)SocketDisconnected;
@end

typedef enum GTAR_RX_MSG_TYPE
{
    RX_FRET_UP = 0x30,
    RX_FRET_DOWN = 0x31,
    RX_FW_VERSION = 0x32,
    RX_FW_UPDATE_ACK = 0x35
} gTarRxMsgType;

// This class is an Objective C class that users sends a delegate update when events happen.
// The original serial code still required a poll for input before events could be sent, but the 
// core midi makes this entirely event driven.
@interface GtarController ()
{
    
    id<GtarControllerDelegate> m_delegate;
    
    CoreMidiInterface * m_coreMidiInterface;    
    
    GtarControllerEffect m_currentGuitarEffect;
    
    NetSockConn * m_pNetSockConn;
    
    NSMutableArray * m_observerList;
    
    NSTimer * m_eventLoopTimer;
    
    char m_stringColorMapping[GTAR_CONTROLLER_STRING_COUNT][3];
    
    BOOL m_connected;
    BOOL m_spoofed;
    
    GtarControllerLogLevel m_logLevel;
    
    double m_minimumInterarrivalTime;
    
    double m_previousPluckTime[GTAR_CONTROLLER_STRING_COUNT][GTAR_CONTROLLER_FRET_COUNT];
    
}

void CoreMidiCallback(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext);
void CoreMidiConnectionChangeCallback(BOOL fConnected, void *pContext);

- (void)guitarConnected;
- (void)guitarDisconnected;

- (void)checkNoteInterarrivalTime:(double)time forFret:(GtarFret)fret andString:(GtarString)str;

- (void)logMessage:(NSString*)str atLogLevel:(GtarControllerLogLevel)level;

- (void)notifyObserversGuitarFretDown:(GtarFret)fret andString:(GtarString)str;
- (void)notifyObserversGuitarFretUp:(GtarFret)fret andString:(GtarString)str;
- (void)notifyObserversGuitarNotesOnFret:(GtarFret)fret andString:(GtarString)str;
- (void)notifyObserversGuitarNotesOffFret:(GtarFret)fret andString:(GtarString)str;
- (void)notifyObserversGuitarConnected;
- (void)notifyObserversGuitarDisconnected;

// CC style set LED messages (not async)
- (RESULT)ccTurnOffAllLeds;
- (RESULT)ccTurnOffLedAtString:(GtarString)str andFret:(GtarFret)fret;
- (RESULT)ccTurnOnLedAtString:(GtarString)str andFret:(GtarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (RESULT)ccTurnOnLedWithColorMappingAtString:(GtarString)str andFret:(GtarFret)fret;

// Requests
- (RESULT)SendRequestFirmwareVersion;
- (RESULT)SendFirmwarePackagePage:(void *)pBuffer bufferSize:(int)pBuffer_n fwSize:(int)fwSize fwPages:(int)fwPages curPage:(int)curPage withCheckSum:(unsigned char)checkSum;

- (RESULT)sendNoteMsg:(unsigned char)midiVal channel:(unsigned char)channel withVelocity:(unsigned char)midiVel andType:(const char *)pszOnOff;

// Net Sock Conn
- (BOOL)IsNetSockConnConnected;
- (RESULT)InitNetSockConn:(NSString *)pstrHost atPort:(UInt32)portNumber;
- (RESULT)DisconnectNetSockConn;


@property (nonatomic, assign) id<GtarControllerDelegate> m_delegate;
@property (nonatomic, readonly) GtarControllerEffect m_currentGuitarEffect;
@property (nonatomic, readonly) NetSockConn * m_pNetSockConn;

@end



#endif
