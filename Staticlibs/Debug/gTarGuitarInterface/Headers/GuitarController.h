//
//  GuitarController.h
//  gTarGuitarInterface
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EHM.h"

#define GUITAR_CONTROLLER_STRING_COUNT 6
#define GUITAR_CONTROLLER_FRET_COUNT 16
#define GUITAR_CONTROLLER_LED_COUNT (GUITAR_CONTROLLER_STRING_COUNT * GUITAR_CONTROLLER_FRET_COUNT)

#define GUITAR_CONTROLLER_NOTE_OFF -1
#define GUITAR_CONTROLLER_FRET_UP -1

typedef SInt32 MIDINotificationMessageID;

typedef unsigned char GuitarString;
typedef unsigned char GuitarFret;

class CoreMidiInterface;
@class NetSockConn;

@protocol GuitarControllerObserver <NSObject>
- (void)guitarFretDown:(GuitarFret)fret andString:(GuitarString)str;
- (void)guitarFretUp:(GuitarFret)fret andString:(GuitarString)str;
- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)guitarConnected;
- (void)guitarDisconnected;
@end 

@protocol GuitarControllerDelegate <NSObject>
- (void)guitarFretDown:(GuitarFret)fret atString:(GuitarString)str;
- (void)guitarFretUp:(GuitarFret)fret atString:(GuitarString)str;
- (void)guitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)guitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)guitarConnected;
- (void)guitarDisconnected;

- (void)ReceivedFWVersion:(int)MajorVersion andMinorVersion:(int)MinorVersion;
- (void)RxFWUpdateACK:(unsigned char)status;
- (void)RxBatteryStatus:(BOOL)charging;
- (void)RxBatteryCharge:(unsigned char)percentage;

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
    RX_FW_UPDATE_ACK = 0x35,
    RX_BATTERY_STATUS = 0x36,
    RX_BATTERY_CHARGE = 0x37
} gTarRxMsgType;

typedef enum GUITAR_CONTROLLER_EFFECT
{
	GuitarControllerEffectNone = 0,
	GuitarControllerEffectFretFollow,
	GuitarControllerEffectNoteActive,
	GuitarControllerEffectFretFollowNoteActive,
	GuitarControllerEffectLightningMode
} GuitarControllerEffect;

// This class is an Objective C class that users sends a delegate update when events happen.
// The original serial code still required a poll for input before events could be sent, but the 
// core midi makes this entirely event driven.
@interface GuitarController : NSObject
{
    
    CoreMidiInterface * m_coreMidiInterface;    
    
    GuitarControllerEffect m_currentGuitarEffect;
    
    NSMutableArray * m_observerList;
     
    NSTimer * m_eventLoopTimer;
    
    char m_stringColorMapping[6][3];

    char m_effectColorFF[3];
    char m_effectColorNA[3];
    char m_effectColorLM[3]; 
    
    BOOL m_connected;
    BOOL m_spoofed;
    
    double m_minimumInterarrivalTime;
    
@public
    NetSockConn *m_pNetSockConn;
    id<GuitarControllerDelegate> m_delegate;    
    double m_previousPluckTime[GUITAR_CONTROLLER_STRING_COUNT][GUITAR_CONTROLLER_FRET_COUNT];
}

@property (nonatomic, assign) id<GuitarControllerDelegate> m_delegate;
@property (nonatomic, readonly) GuitarControllerEffect m_currentGuitarEffect;
@property (nonatomic, assign) BOOL m_connected;

int CoreMidiCallback(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext);
//void CoreMidiStateChangeCallback(MIDINotificationMessageID state, void *pContext);
void CoreMidiConnectionChangeCallback(BOOL fConnected, void *pContext);

- (void)debugSpoofConnected;
- (void)debugSpoofDisconnected;

- (RESULT)addObserver:(id<GuitarControllerObserver>)observer;
- (RESULT)removeObserver:(id<GuitarControllerObserver>)observer;

- (void)notifyObserversGuitarFretDown:(GuitarFret)fret andString:(GuitarString)str;
- (void)notifyObserversGuitarFretUp:(GuitarFret)fret andString:(GuitarString)str;
- (void)notifyObserversGuitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)notifyObserversGuitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str;
- (void)notifyObserversGuitarConnected;
- (void)notifyObserversGuitarDisconnected;


- (RESULT)turnOffAllLeds;
- (RESULT)turnOffLedAtString:(GuitarString)str andFret:(GuitarFret)fret;
- (RESULT)turnOnLedAtString:(GuitarString)str andFret:(GuitarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (RESULT)turnOnLedWithColorMappingAtString:(GuitarString)str andFret:(GuitarFret)fret;

// CC style set LED messages (not async)
- (RESULT)ccTurnOffAllLeds;
- (RESULT)ccTurnOffLedAtString:(GuitarString)str andFret:(GuitarFret)fret;
- (RESULT)ccTurnOnLedAtString:(GuitarString)str andFret:(GuitarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (RESULT)ccTurnOnLedWithColorMappingAtString:(GuitarString)str andFret:(GuitarFret)fret;

// Requests
- (RESULT) SendRequestBatteryStatus;
- (RESULT) SendEnableDebug;
- (RESULT) SendDisableDebug;
- (RESULT) SendRequestFirmwareVersion;
- (RESULT) SendFirmwarePackagePage:(void *)pBuffer bufferSize:(int)pBuffer_n fwSize:(int)fwSize fwPages:(int)fwPages curPage:(int)curPage withCheckSum:(unsigned char)checkSum;

- (RESULT)sendNoteMsg:(unsigned char)midiVal channel:(unsigned char)channel withVelocity:(unsigned char)midiVel andType:(const char *)pszOnOff;

- (void)setStringsColorMapping:(char**)colorMap;
- (void)setStringColorMapping:(GuitarString)str toRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (void)setMinimumInterarrivalTime:(double)time;

- (RESULT)turnOffAllEffects;
- (RESULT)setEffectColor:(GuitarControllerEffect)effect toRed:(char)red andGreen:(char)green andBlue:(char)blue;

// Net Sock Conn
- (BOOL) IsNetSockConnConnected;
- (RESULT) InitNetSockConn:(NSString *)pstrHost atPort:(UInt32)portNumber;
- (RESULT) DisconnectNetSockConn;

/*
- (RESULT)setEffectColor:(GuitarControllerEffect)effect toRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (RESULT)setEffectColorRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (RESULT)setGuitarControllerEffect:(GuitarControllerEffect)effect;
 */

@end
