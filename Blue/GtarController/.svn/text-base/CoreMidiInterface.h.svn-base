//
//  CoreMidiInterface.h
//  gTarGuitarInterface
//
//  Created by idanbeck on 9/1/11.
//  Modified by Marty on 9/21/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

//#import <Foundation/Foundation.h>

#include <CoreMIDI/CoreMIDI.h>
#include <CoreMIDI/MIDINetworkSession.h>

#include "RESULT.h"
#include "valid.h"

#define GTAR_DEVICE_ID 0x77

typedef enum GTAR_MSG_TYPE
{
    GTAR_MSG_SET_LED = 0x00,
    GTAR_MSG_SET_NOTE_ACTIVE = 0x01,
    GTAR_MSG_SET_FRET_FOLLOW = 0x02,
    GTAR_MSG_REQ_CERT_DOWNLOAD = 0x03,
    GTAR_MSG_REQ_FW_VERSION = 0x04,
    GTAR_MSG_DWLD_FW_PAGE = 0x05,
    GTAR_MSG_INVALID
} gTarMsgType;

void MIDIStateChangedHandler(const MIDINotification *message, void *refCon);
static void MIDICompletionHander(MIDISysexSendRequest  *request);
void MIDIReadHandler(const MIDIPacketList *pPacketList, void *pReadProcCon, void *pSrcConnCon);

typedef void (*MidiCallback)(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext);
typedef void (*MidiConnectionChangeCallback)(BOOL fConnected, void *pContext);
typedef void (*MidiLog)(NSString *msg, unsigned char logLevel, void *pContext);

class CoreMidiInterface :
    public valid
{
public:
    CoreMidiInterface(MidiCallback fnCallback, MidiConnectionChangeCallback fnConnectionChangeCallback, MidiLog fnLog, void *pContext);
    ~CoreMidiInterface();
    
    void init();   
    
    RESULT SendBuffer(unsigned char *pBuffer, int pBuffer_n);
    RESULT SendSysExBuffer(unsigned char *pBuffer, int pBuffer_n);
    
    RESULT SendSetLEDState(unsigned char fret, unsigned char str, unsigned char R, unsigned char G, unsigned char B, unsigned char M);
    RESULT SendCCSetLEDState(unsigned char fret, unsigned char str, unsigned char R, unsigned char G, unsigned char B, unsigned char M);
    
    RESULT SendSetNoteActive(unsigned char R, unsigned char G, unsigned char B);
    RESULT SendSetFretFollow(unsigned char R, unsigned char G, unsigned B);
    
    RESULT SendNoteMsg(unsigned char channel, unsigned char midiVal, unsigned char velocity, const char* pszOnOff);
    
    RESULT SendFirmwarePackagePage(unsigned char *pBuffer, int pBuffeR_n, int totSize, int totPages, int curPage, unsigned char checkSum);
    RESULT SendRequestFirmwareVersion();
    RESULT SendRequestCertDownload();
    
    void UpdateEndpoints();
    ItemCount UpdateSources();                  // This will scan through the sources and connect them as needed    
    ItemCount UpdateDestinations();         // This will scan through the sources and connect them as needed
    
    bool Evaluate();
    
    bool IsGtarConnected();
    
public:
    MidiCallback m_fnMidiCallback;
    MidiConnectionChangeCallback m_fnMidiConnectionChangeCallback;
    MidiLog m_fnMidiLog;
    
    void *m_pContext;
    
    NSMutableArray *m_pSendQueue;
    
private:
    MIDIClientRef m_pMidiClient;
    MIDIPortRef m_pMidiInputPort;
    MIDIPortRef m_pMidiOutputPort;
    
    NSMutableArray *m_pSources;
    NSMutableArray *m_pDestinations;
};

// Helper function
int GetFretForMidiNote(int midiNote, int str);
unsigned char CreateRGBMValue(unsigned char R, unsigned char G, unsigned char B, unsigned char M);