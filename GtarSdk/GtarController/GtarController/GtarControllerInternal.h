//
//  GtarControllerInternal.h
//  GtarController
//
//  Created by Marty Greenia on 5/24/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GtarController.h"

typedef SInt32 MIDINotificationMessageID;

@class CoreMidiInterface;

// The delegate is only used for internal use. Normal communications (fret on, fret off, ..)
// only goes to the public observers
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
    
//    GtarControllerEffect m_currentGuitarEffect;
    
    NSMutableArray * m_observerList;
    
    NSTimer * m_eventLoopTimer;
    
    char m_stringColorMapping[GtarStringCount][3];
    
    double m_previousPluckTime[GtarStringCount][GtarFretCount];
    
}

- (BOOL)checkNoteInterarrivalTime:(double)time forFret:(GtarFret)fret andString:(GtarString)str;

- (void)logMessage:(NSString*)str atLogLevel:(GtarControllerLogLevel)level;

- (void)midiConnectionHandler:(BOOL)connected;
- (void)midiCallbackHandler:(char*)data;

- (void)midiCallbackDispatch:(NSDictionary*)dictionary;
- (void)midiCallbackWorkerThread:(NSDictionary*)dictionary;

- (void)notifyObserversGtarFretDown:(NSDictionary*)dictionary;
- (void)notifyObserversGtarFretUp:(NSDictionary*)dictionary;
- (void)notifyObserversGtarNoteOn:(NSDictionary*)dictionary;
- (void)notifyObserversGtarNoteOff:(NSDictionary*)dictionary;
- (void)notifyObserversGtarConnectedM:(NSDictionary*)dictionary;
- (void)notifyObserversGtarDisconnected:(NSDictionary*)dictionary;


// CC style set LED messages (not async)
//- (RESULT)ccTurnOffAllLeds;
//- (RESULT)ccTurnOffLedAtString:(GtarString)str andFret:(GtarFret)fret;
//- (RESULT)ccTurnOnLedAtString:(GtarString)str andFret:(GtarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue;
//- (RESULT)ccTurnOnLedWithColorMappingAtString:(GtarString)str andFret:(GtarFret)fret;

// Requests
- (BOOL)sendRequestFirmwareVersion;
- (BOOL)sendFirmwarePackagePage:(void*)pBuffer bufferSize:(int)pBuffer_n fwSize:(int)fwSize fwPages:(int)fwPages curPage:(int)curPage withCheckSum:(unsigned char)checkSum;

- (BOOL)sendNoteMessage:(unsigned char)midiVal channel:(unsigned char)channel withVelocity:(unsigned char)midiVel andType:(const char*)type;

@property (nonatomic, assign) id<GtarControllerDelegate> m_delegate;
//@property (nonatomic, readonly) GtarControllerEffect m_currentGuitarEffect;

@end
