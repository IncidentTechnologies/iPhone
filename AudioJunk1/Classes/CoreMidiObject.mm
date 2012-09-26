//
//  CoreMidiClass.cpp
//  AudioJunk1
//
//  Created by idanbeck on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include "CoreMidiObject.h"
#import "MidiMonitorView.h"
#import "AudioController.h"

#include <list.h>

CoreMidiObject::CoreMidiObject(MidiCallback fnCallback, void *pContext) :
    m_pMidiClient(NULL),
    m_pSources(NULL),
    m_pDestinations(NULL),
    m_pMonitorView(NULL),
    m_fnMidiCallback(fnCallback),
    m_pContext(pContext),
    m_fnStringOut(NULL)
{
    m_pSources = new std::list<MIDIObjectRef>();
    m_pDestinations = new std::list<MIDIObjectRef>();
}

CoreMidiObject::~CoreMidiObject()
{
    if(m_pSources != NULL)
    {
        delete m_pSources;
        m_pSources = NULL;
    }
    
    if(m_pDestinations != NULL)
    {
        delete m_pDestinations;
        m_pDestinations = NULL;
    }
    
    if(m_pMidiClient != NULL)
    {
        OSStatus oss = MIDIClientDispose(m_pMidiClient);
        m_pMidiClient = NULL;
    }
}

ItemCount CoreMidiObject::UpdateSources()
{
    ItemCount Sources_n = MIDIGetNumberOfSources();
    m_pSources->clear();
    
    for(ItemCount i = 0; i < Sources_n; i++)
    {
        MIDIEndpointRef pSourceEndpoint = MIDIGetSource(i);
        m_pSources->push_back(pSourceEndpoint);
        OSStatus oss = MIDIPortConnectSource(m_pMidiInputPort, pSourceEndpoint, this);    // maybe provide other info in srcConRef        
        if(pSourceEndpoint != NULL)
        {
            CFStringRef name = nil;
            if(MIDIObjectGetStringProperty(pSourceEndpoint, kMIDIPropertyDisplayName, &name) == noErr)
            {
                CFStringRef cfstr = CFStringCreateWithFormat(NULL, NULL, CFSTR("Connected source: %@"), (NSString*)name);
                WriteString(cfstr);    
                //NSLog(@"Found Source: %@", (NSString*)name);
            }
        }
    }
    return Sources_n;
}

ItemCount CoreMidiObject::UpdateDestinations()
{
    ItemCount Destinations_n = MIDIGetNumberOfDestinations();
    m_pDestinations->clear();
    
    for(ItemCount i = 0; i < Destinations_n; i++)
    {
        MIDIEndpointRef pDestinationEndpoint = MIDIGetDestination(i);
        m_pDestinations->push_back(pDestinationEndpoint);
        if(pDestinationEndpoint != NULL)
        {
            CFStringRef name = nil;
            if(MIDIObjectGetStringProperty(pDestinationEndpoint, kMIDIPropertyDisplayName, &name) == noErr)
            {
                //NSLog(@"Found Destination: %@", (NSString*)name);
                CFStringRef cfstr = CFStringCreateWithFormat(NULL, NULL, CFSTR("Found destination: %@"), (NSString*)name);
                WriteString(cfstr);
            }
        }
    }
    return Destinations_n;
}

void CoreMidiObject::init()
{
    // Create the midi client
    OSStatus oss = MIDIClientCreate(CFSTR("AE Midi Client"), MIDIStateChangedHandler, this, &m_pMidiClient);
    
    // Set up the Input Port
    oss = MIDIInputPortCreate(m_pMidiClient, (CFStringRef)@"Midi Client Input Port", MIDIReadHandler, this, &m_pMidiInputPort);
    
    // Set up the Output Port
    oss = MIDIOutputPortCreate(m_pMidiClient, (CFStringRef)@"MidiClient Output Port", &m_pMidiOutputPort);
    
    int src_n = UpdateSources();
    int dest_n = UpdateDestinations();
    //NSLog(@"Found %d sources and %d destinations", src_n, dest_n);
    
    CFStringRef cfstr = CFStringCreateWithFormat(NULL, NULL, CFSTR("Found %d sources and %d destinations\n"), src_n, dest_n);
    WriteString(cfstr);  
    delete cfstr;
}

void CoreMidiObject::WriteString(CFStringRef pstrString)
{        
    if(m_pMonitorView != NULL && m_fnStringOut != NULL)
        m_fnStringOut((NSString *)pstrString);
}

void MIDIStateChangedHandler(const MIDINotification *message, void* refCon)
{
    CoreMidiObject *pMidiObj = reinterpret_cast<CoreMidiObject*>(refCon);    

    MIDINotificationMessageID mid = message->messageID;
    UInt32 messageSize = message->messageSize;
    
    switch(mid)
    {
        case kMIDIMsgSetupChanged:
        {
            pMidiObj->WriteString(CFSTR("Setup Changed"));  
            pMidiObj->UpdateDestinations();
            pMidiObj->UpdateSources();
        } break;
            
        case kMIDIMsgObjectAdded:
        {
            MIDIObjectAddRemoveNotification *pMidAdd = (MIDIObjectAddRemoveNotification*)(message);
            if(pMidAdd->childType == kMIDIObjectType_Source)            
                pMidiObj->WriteString(CFSTR("Source Object Added"));
            else if(pMidAdd->childType == kMIDIObjectType_Destination)
                pMidiObj->WriteString(CFSTR("Destination Object Added"));
            
        } break;
            
        case kMIDIMsgObjectRemoved:
        {
            MIDIObjectAddRemoveNotification *pMidRemoved = (MIDIObjectAddRemoveNotification*)(message);
            if(pMidRemoved->childType == kMIDIObjectType_Source)            
                pMidiObj->WriteString(CFSTR("Source Object Removed"));
            else if(pMidRemoved->childType == kMIDIObjectType_Destination)
                pMidiObj->WriteString(CFSTR("Destination Object Removed"));
            
        } break;
            
        case kMIDIMsgPropertyChanged:
        {
            pMidiObj->WriteString(CFSTR("Property Changed"));  
            MIDIObjectPropertyChangeNotification *pMidProp = (MIDIObjectPropertyChangeNotification*)(message);
        } break;
            
        case kMIDIMsgThruConnectionsChanged:
        {
            pMidiObj->WriteString(CFSTR("Thru Connections Changed"));  
        } break;
            
        case kMIDIMsgSerialPortOwnerChanged:
        {
            pMidiObj->WriteString(CFSTR("Serial Port Owner Changed"));  
        } break;
            
        case kMIDIMsgIOError:
        {
            pMidiObj->WriteString(CFSTR("IO Error"));
            MIDIIOErrorNotification *pMidAdd = (MIDIIOErrorNotification*)(message);
            
        } break;
    }
}

int GetFretForMidiNote(int midiNote, int str)
{
    if(str < 0 || str > 5)
        return -1;
    
    int fret = midiNote - (40 + 5 * str);
    if(str > 3)
        fret -= 1;
    
    return fret;
}

void MIDIReadHandler(const MIDIPacketList *pPacketList, void *pReadProcCon, void *pSrcConnCon)
{
    CoreMidiObject *pMidiObj = reinterpret_cast<CoreMidiObject*>(pSrcConnCon);  
    
    for(int i = 0; i < pPacketList->numPackets; i++)
    {
        MIDIPacket pkt = pPacketList->packet[i];
        if(pMidiObj->m_fnMidiCallback != NULL)
            if(pkt.length == 3)
                pMidiObj->m_fnMidiCallback(pkt.data[0], pkt.data[1], pkt.data[2], 0x00, pMidiObj->m_pContext);
            else if(pkt.length == 4)
                pMidiObj->m_fnMidiCallback(pkt.data[0], pkt.data[1], pkt.data[2], pkt.data[3], pMidiObj->m_pContext);    
    }
}







