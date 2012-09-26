//
//  CoreMidiClass.h
//  AudioJunk1
//
//  Created by idanbeck on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <CoreMIDI/CoreMIDI.h>
#include <CoreMIDI/MIDINetworkSession.h>

@class MidiMonitorView;
@class AudioController;

#include <list>

void MIDIStateChangedHandler(const MIDINotification *message, void *refCon);
void MIDIReadHandler(const MIDIPacketList *pPacketList, void *pReadProcCon, void *pSrcConnCon);

typedef void (*TextOutFnPtr)(NSString*);
typedef int (*MidiCallback)(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext);

class CoreMidiObject
{
public:
    CoreMidiObject(MidiCallback fnCallback, void *pContext);
    ~CoreMidiObject();
    
    void init();    
    void WriteString(CFStringRef pstrString);
                    
    ItemCount UpdateSources();                  // This will scan through the sources and connect them as needed    
    ItemCount UpdateDestinations();         // This will scan through the sources and connect them as needed
    
public:
    MidiCallback m_fnMidiCallback; 
    void *m_pContext;
    
    TextOutFnPtr m_fnStringOut;    
    
    MidiMonitorView *m_pMonitorView;
    
private:
    MIDIClientRef m_pMidiClient;
    MIDIPortRef m_pMidiInputPort;
    MIDIPortRef m_pMidiOutputPort;
    
    std::list<MIDIObjectRef>*m_pSources;
    std::list<MIDIObjectRef>*m_pDestinations;
};