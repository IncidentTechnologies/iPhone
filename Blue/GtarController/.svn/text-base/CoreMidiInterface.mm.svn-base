//
//  CoreMidiInterface.mm
//  gTarGuitarInterface
//
//  Created by idanbeck on 9/1/11.
//  Modified by Marty on 9/21/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#include <stdio.h>

#include "CoreMidiInterface.h"
#include "EHM.h"
#include <string.h>
#include "GtarController.h"

CoreMidiInterface::CoreMidiInterface(MidiCallback fnCallback, MidiConnectionChangeCallback fnConnectionChangeCallback, MidiLog fnMidiLog, void *pContext) :
    m_pMidiClient(NULL),
    m_pSources(nil),
    m_pDestinations(nil),
//    m_pMonitorView(NULL),
    m_fnMidiCallback(fnCallback),
    m_fnMidiConnectionChangeCallback(fnConnectionChangeCallback),
    m_fnMidiLog(fnMidiLog),
    m_pContext(pContext)
//    m_fnStringOut(NULL)
{
    m_pSources = [[NSMutableArray alloc] init];
    m_pDestinations = [[NSMutableArray alloc] init];
    m_pSendQueue = [[NSMutableArray alloc] init];
    
    m_fnMidiLog(@"CoreMidiInterface initializing", GtarControllerLogLevelInfo, m_pContext);
}

CoreMidiInterface::~CoreMidiInterface()
{
    // Tear down of the MIDI needs to go first
    if(m_pMidiClient != NULL)
    {
        OSStatus oss = MIDIClientDispose(m_pMidiClient);
        
        if( oss != 0 )
        {
            m_fnMidiLog([NSString stringWithFormat:@"Failed to dispose client: Error code %ld", oss],
                        GtarControllerLogLevelError,
                        m_pContext);
        }
        
        m_pMidiClient = NULL;
    }
    
    [m_pSources release];
    m_pSources = nil;
    
    [m_pDestinations release];
    m_pDestinations = nil;
    
    // TODO handle locking
    // We have to nullify the requests that have already been sent out.
    for(NSValue *sendPtr in m_pSendQueue)
    {
        MIDISysexSendRequest *pSendReq = (MIDISysexSendRequest *)[sendPtr pointerValue];
        
        pSendReq->completionRefCon = NULL;
    }
    
    [m_pSendQueue release];
    m_pSendQueue = nil;
    
}

void CoreMidiInterface::UpdateEndpoints()
{
    
    bool connected = IsGtarConnected();
    
    int src_n = UpdateSources();
    int dest_n = UpdateDestinations();
    
    m_fnMidiLog([NSString stringWithFormat:@"Found %d sources and %d destinations", src_n, dest_n],
                GtarControllerLogLevelInfo,
                m_pContext);

    Evaluate();
    
    // See if the connection status changed
    if(connected == true)
    {
        if(IsGtarConnected() == false)
        {
            m_fnMidiConnectionChangeCallback(false, m_pContext);
            m_fnMidiLog([NSString stringWithFormat:@"gTar Disconnected"],
                        GtarControllerLogLevelInfo,
                        m_pContext);
        }
    }
    else
    {
        if(IsGtarConnected() == true)
        {
            m_fnMidiConnectionChangeCallback(true, m_pContext);
            m_fnMidiLog([NSString stringWithFormat:@"gTar Connected"],
                        GtarControllerLogLevelInfo,
                        m_pContext);
        }
    }

}

ItemCount CoreMidiInterface::UpdateSources()
{
    ItemCount Sources_n = MIDIGetNumberOfSources();
    
    [m_pSources removeAllObjects];
    
    for(ItemCount i = 0; i < Sources_n; i++)
    {
        
        MIDIEndpointRef pSourceEndpoint = MIDIGetSource(i);

        if(pSourceEndpoint != NULL)
        {
            
            CFStringRef name = nil;
            
            if(MIDIObjectGetStringProperty(pSourceEndpoint, kMIDIPropertyDisplayName, &name) == noErr)
            {
                m_fnMidiLog([NSString stringWithFormat:@"Found Source: %@", (NSString*)name],
                            GtarControllerLogLevelInfo,
                            m_pContext);
                
                // Only connect the 'gTar' device for now
                if([((NSString*)name) isEqualToString:@"gTar"] == YES)
                {
                    
                    // connect source
                    OSStatus oss = MIDIPortConnectSource(m_pMidiInputPort, pSourceEndpoint, this);
                    
                    if( oss != 0 )
                    {
                        m_fnMidiLog([NSString stringWithFormat:@"Failed to connect gTar source: Error code %ld", oss],
                                    GtarControllerLogLevelError,
                                    m_pContext);
                    }
                    else
                    {
                        [m_pSources addObject:[NSValue valueWithPointer:pSourceEndpoint]];
                        
                        m_fnMidiLog([NSString stringWithFormat:@"gTar source connected"],
                                    GtarControllerLogLevelInfo,
                                    m_pContext);
                    }                    
                }
            }
        }
    }
    
    // Source changes may invalidate the CoreMidi object
    Evaluate();
    
    return Sources_n;
}

ItemCount CoreMidiInterface::UpdateDestinations()
{
    ItemCount Destinations_n = MIDIGetNumberOfDestinations();
    [m_pDestinations removeAllObjects];
    
    for(ItemCount i = 0; i < Destinations_n; i++)
    {
        MIDIEndpointRef pDestinationEndpoint = MIDIGetDestination(i);
        
        if(pDestinationEndpoint != NULL)
        {
            
            CFStringRef name = nil;
            
            if(MIDIObjectGetStringProperty(pDestinationEndpoint, kMIDIPropertyDisplayName, &name) == noErr)
            {
                m_fnMidiLog([NSString stringWithFormat:@"Found Destination: %@", (NSString*)name],
                            GtarControllerLogLevelInfo,
                            m_pContext);
                
                // Only connect the 'gTar' destination for now
                if([((NSString*)name) isEqualToString:@"gTar"] == YES)
                {
                    [m_pDestinations addObject:[NSValue valueWithPointer:pDestinationEndpoint]];
                    
                    m_fnMidiLog([NSString stringWithFormat:@"gTar destination connected"],
                                GtarControllerLogLevelInfo,
                                m_pContext);
                    
                }
            }
        }
    }
    
    // Destination changes may invalidate the CoreMidi object
    Evaluate();
    
    return Destinations_n;
}

void CoreMidiInterface::init()
{
    // Create the midi client
    OSStatus oss = MIDIClientCreate(CFSTR("AE Midi Client"), MIDIStateChangedHandler, this, &m_pMidiClient);
    
    if( oss != 0 )
    {
        m_fnMidiLog([NSString stringWithFormat:@"Failed to create AE Midi Client: Error %ld", oss],
                    GtarControllerLogLevelError,
                    m_pContext);
    }

    // Set up the Input Port
    oss = MIDIInputPortCreate(m_pMidiClient, (CFStringRef)@"Midi Client Input Port", MIDIReadHandler, this, &m_pMidiInputPort);
    
    if( oss != 0 )
    {
        m_fnMidiLog([NSString stringWithFormat:@"Failed to create input port: Error %ld", oss],
                    GtarControllerLogLevelError,
                    m_pContext);
    }

    // Set up the Output Port
    oss = MIDIOutputPortCreate(m_pMidiClient, (CFStringRef)@"MidiClient Output Port", &m_pMidiOutputPort);
    
    if( oss != 0 )
    {
        m_fnMidiLog([NSString stringWithFormat:@"Failed to create output port: Error %ld", oss],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    UpdateEndpoints();
    
    Evaluate();
    
}

bool CoreMidiInterface::Evaluate()
{
    int src_n = [m_pSources count];
    int dest_n = [m_pDestinations count];
    
    if(src_n > 0 && dest_n > 0)
        return Validate();
    else
        return Invalidate();
}

bool CoreMidiInterface::IsGtarConnected()
{
    // We are only connecting the 'gTar' device so this is valid
    int src_n = [m_pSources count];
    int dest_n = [m_pDestinations count];
    
    return (src_n > 0 && dest_n > 0);
}

void MIDIStateChangedHandler(const MIDINotification *message, void *refCon)
{
    CoreMidiInterface *pMidiObj = reinterpret_cast<CoreMidiInterface*>(refCon);    

    MIDINotificationMessageID mid = message->messageID;
//    UInt32 messageSize = message->messageSize;
    
    switch(mid)
    {
        case kMIDIMsgSetupChanged:
        {
            pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Setup Changed"],
                                  GtarControllerLogLevelInfo,
                                  pMidiObj->m_pContext);
            
            pMidiObj->UpdateEndpoints();
        } break;
            
        case kMIDIMsgObjectAdded:
        {
            MIDIObjectAddRemoveNotification *pMidAdd = (MIDIObjectAddRemoveNotification*)(message);
            
            if(pMidAdd->childType == kMIDIObjectType_Source)
            {
                pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Source Object Added"],
                                      GtarControllerLogLevelInfo,
                                      pMidiObj->m_pContext);
            }
            else if(pMidAdd->childType == kMIDIObjectType_Destination)
            {
                pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Destination Object Added"],
                                      GtarControllerLogLevelInfo,
                                      pMidiObj->m_pContext);
            }
            
        } break;
            
        case kMIDIMsgObjectRemoved:
        {
            MIDIObjectAddRemoveNotification *pMidRemoved = (MIDIObjectAddRemoveNotification*)(message);
            
            if(pMidRemoved->childType == kMIDIObjectType_Source)
            {
                pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Source Object Removed"],
                                      GtarControllerLogLevelInfo,
                                      pMidiObj->m_pContext);
            }
            else if(pMidRemoved->childType == kMIDIObjectType_Destination)
            {
                pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Destination Object Removed"],
                                      GtarControllerLogLevelInfo,
                                      pMidiObj->m_pContext);
            }
            
        } break;
            
        case kMIDIMsgPropertyChanged:
        {
            pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Property Changed"],
                                  GtarControllerLogLevelInfo,
                                  pMidiObj->m_pContext);

            //MIDIObjectPropertyChangeNotification *pMidProp = (MIDIObjectPropertyChangeNotification*)(message);
            
        } break;
            
        case kMIDIMsgThruConnectionsChanged:
        {
            pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Thru Connections Changed"],
                                  GtarControllerLogLevelInfo,
                                  pMidiObj->m_pContext);
            
        } break;
            
        case kMIDIMsgSerialPortOwnerChanged:
        {
            pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Serial Port Owner Changed"],
                                  GtarControllerLogLevelInfo,
                                  pMidiObj->m_pContext);
            
        } break;
            
        case kMIDIMsgIOError:
        {
            pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"IO Error"],
                                  GtarControllerLogLevelError,
                                  pMidiObj->m_pContext);
            
            //MIDIIOErrorNotification *pMidError = (MIDIIOErrorNotification*)(message);
            
        } break;
    }
}

int GetFretForMidiNote(int midiNote, int str)
{
    if(str < 0 || str > 5)
        return -1;
    
    int fret = midiNote - (40 + 5 * str);
    if(str > 3)
        fret += 1;
    
    return fret;
}

void MIDIReadHandler(const MIDIPacketList *pPacketList, void *pReadProcCon, void *pSrcConnCon)
{
    
    CoreMidiInterface *pMidiObj = reinterpret_cast<CoreMidiInterface*>(pSrcConnCon);
    
    if(pMidiObj->m_fnMidiCallback == NULL)
        return;
    
    for(int i = 0; i < pPacketList->numPackets; i++)
    {
        MIDIPacket pkt = pPacketList->packet[i];
        
        /*
        NSLog(@"** rx pkt **");
        for(int j = 0; j < pkt.length; j++)
            NSLog(@"0x%02x", pkt.data[j]);
        NSLog(@"************");
        */
            
        if(pkt.length == 3)
        {
            pMidiObj->m_fnMidiCallback(pkt.data[0], pkt.data[1], pkt.data[2], 0x00, pMidiObj->m_pContext);
        }
        else if(pkt.length == 4)
        {
            pMidiObj->m_fnMidiCallback(pkt.data[0], pkt.data[1], pkt.data[2], pkt.data[3], pMidiObj->m_pContext);
        }
        else
        {
            pMidiObj->m_fnMidiLog([NSString stringWithFormat:@"Invalid Midi packet size: %u", pkt.length],
                                  GtarControllerLogLevelError,
                                  pMidiObj->m_pContext);
        }
    }
}

// This sends a buffer with MIDI Send
RESULT CoreMidiInterface::SendBuffer(unsigned char *pBuffer, int pBuffer_n)
{
    RESULT r = R_NO_ISSUE;
    
    // Create the packet 
    MIDIPacket packet;
    packet.timeStamp = 0;
    packet.length = pBuffer_n;
    for(int i = 0; i < pBuffer_n; i++)
        packet.data[i] = pBuffer[i];
    
    // Create the packet list
    MIDIPacketList PacketList;
    PacketList.numPackets = 1;
    PacketList.packet[0] = packet;
        
    // Broadcast it on all endpoints for now
    for(NSValue *destPtr in m_pDestinations)
    {
        MIDIEndpointRef ep = (MIDIEndpointRef)[destPtr pointerValue];
        OSStatus oss = MIDISend(m_pMidiOutputPort, ep, &PacketList);
        
        if(oss == -1)
        {
            m_fnMidiLog([NSString stringWithFormat:@"SendBuffer: MIDISend failed with status 0x%x", oss],
                                  GtarControllerLogLevelError,
                                  m_pContext);
            r = R_ERROR;
            break;
        }

    }
    
    return r;
}

static void MIDICompletionHander(MIDISysexSendRequest *request)
{

    // If the interface gets torn down below us, this is set to null
    if(request->completionRefCon == NULL)
    {
        return;
    }
    
    CoreMidiInterface *pInterface = reinterpret_cast<CoreMidiInterface*>(request->completionRefCon);
    
    @synchronized(pInterface->m_pSendQueue)
    {
    
        NSValue *ptr = [pInterface->m_pSendQueue objectAtIndex:0];
        
        // We are done with this pointer
        MIDISysexSendRequest *pSendReq = (MIDISysexSendRequest *)[ptr pointerValue];
        
        delete pSendReq;
        
        [pInterface->m_pSendQueue removeObject:ptr];
        
        // see if we have anything else queued up
        if( [pInterface->m_pSendQueue count] > 0)
        {
            pSendReq = (MIDISysexSendRequest *)[[pInterface->m_pSendQueue objectAtIndex:0] pointerValue];
            
            OSStatus oss = MIDISendSysex(pSendReq);
            
            if(oss == -1)
            {
                pInterface->m_fnMidiLog([NSString stringWithFormat:@"SendSysExBuffer: MIDISend failed with status 0x%x", oss],
                                        GtarControllerLogLevelError,
                                        pInterface->m_pContext);
            }
        }
    
    }
    
}

RESULT CoreMidiInterface::SendSysExBuffer(unsigned char *pBuffer, int pBuffer_n)
{
    RESULT r = R_NO_ISSUE;
    
    @synchronized(m_pSendQueue)
    {
        
        // There is currently only a single destination in this loop
        for(NSValue *destPtr in m_pDestinations)
        {
            MIDISysexSendRequest *pSendReq = new MIDISysexSendRequest;
            
            pSendReq->destination = (MIDIEndpointRef)[destPtr pointerValue];
            pSendReq->data = pBuffer;
            pSendReq->bytesToSend = pBuffer_n;
            pSendReq->complete = false;
            
            pSendReq->completionProc = MIDICompletionHander;
            pSendReq->completionRefCon = this;
            
            NSValue *sendPtr = [NSValue valueWithPointer:pSendReq];
            
            [m_pSendQueue addObject:sendPtr];
            
            // If nothing else is on the queue, send this now
            if( [m_pSendQueue count] == 1 )
            {
                OSStatus oss = MIDISendSysex(pSendReq);
                
                if(oss == -1)
                {
                    m_fnMidiLog([NSString stringWithFormat:@"SendSysExBuffer: MIDISend failed with status 0x%x", oss],
                                GtarControllerLogLevelError,
                                m_pContext);
                    
                    r = R_ERROR;
                    break;
                }
                
            }
        }
    
    }
    
    return r;
}

unsigned char CreateRGBMValue(unsigned char R, unsigned char G, unsigned char B, unsigned char M)
{
    unsigned char retVal = 0;
    retVal += ((R & 0x3) << 6);
    retVal += ((G & 0x3) << 4);
    retVal += ((B & 0x3) << 2);
    retVal += ((M & 0x3) << 0);
    
    return retVal;
}

RESULT CoreMidiInterface::SendSetNoteActive(unsigned char R, unsigned char G, unsigned char B)
{
    RESULT r = R_NO_ISSUE;
    
    unsigned char *pSendBuffer = NULL;
    int pSendBuffer_n = 0;
    
    // Create the send buffer    
    pSendBuffer_n = 5;
    pSendBuffer = new unsigned char[pSendBuffer_n];
    
    pSendBuffer[0] = 0xF0;           // SysEx Message
    pSendBuffer[1] = GTAR_DEVICE_ID;
    pSendBuffer[2] = (unsigned char)GTAR_MSG_SET_NOTE_ACTIVE;    
    pSendBuffer[3] = CreateRGBMValue(R, G, B, 0x00);    
    pSendBuffer[4] = 0xF7;           // End SysEx Message    
    
    r = SendSysExBuffer(pSendBuffer, pSendBuffer_n);
    
    if(r != R_NO_ISSUE)
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendSetLEDState: Failed to send SysEx Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    return r;
}

RESULT CoreMidiInterface::SendRequestCertDownload()
{
    RESULT r = R_NO_ISSUE;
    
    unsigned char *pSendBuffer = NULL;
    int pSendBuffer_n = 0;
    
    // Create the send buffer    
    pSendBuffer_n = 4;
    pSendBuffer = new unsigned char[pSendBuffer_n];
    
    pSendBuffer[0] = 0xF0;           // SysEx Message
    pSendBuffer[1] = GTAR_DEVICE_ID;
    pSendBuffer[2] = (unsigned char)GTAR_MSG_REQ_CERT_DOWNLOAD;    
    pSendBuffer[4] = 0xF7;           // End SysEx Message  
    
    r = SendSysExBuffer(pSendBuffer, pSendBuffer_n);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendRequestCertDownload: Failed to send SysEx Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }

    if(pSendBuffer != NULL)
    {
        delete [] pSendBuffer;
        pSendBuffer = NULL;
    }
    
    return r;
}

RESULT CoreMidiInterface::SendRequestFirmwareVersion()
{
    RESULT r = R_NO_ISSUE;
    
    unsigned char *pSendBuffer = NULL;
    int pSendBuffer_n = 0;
    
    // Create the send buffer    
    pSendBuffer_n = 3;
    pSendBuffer = new unsigned char[pSendBuffer_n];
    
    pSendBuffer[0] = 0xF0;           // SysEx Message
    pSendBuffer[1] = GTAR_DEVICE_ID;
    pSendBuffer[2] = (unsigned char)GTAR_MSG_REQ_FW_VERSION;    
    //pSendBuffer[4] = 0xF7;           // End SysEx Message  
    
    r = SendSysExBuffer(pSendBuffer, pSendBuffer_n);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendRequestFirmwareVersion: Failed to send SysEx Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    if(pSendBuffer != NULL)
    {
        delete [] pSendBuffer;
        pSendBuffer = NULL;
    }
    return r;
}

RESULT CoreMidiInterface::SendFirmwarePackagePage(unsigned char *pBuffer, int pBuffer_n, int totSize, int totPages, int curPage, unsigned char checkSum)
{
    RESULT r = R_NO_ISSUE;
    
        
    // all data bytes must be converted to midi data bytes which have a zero 
    // for the MSB
    int j = 0;
    unsigned char *pTempBuffer = new unsigned char[pBuffer_n * 2];
    memset(pTempBuffer, 0, pBuffer_n * 2);
    
    signed char startCounter = 1;
    signed char endCounter = 6;
    
    for(int i = 0; i < pBuffer_n; i++)
    {
        // add current fragment and begining of next 
        pTempBuffer[j] += (pBuffer[i] >> startCounter) & 0x7F;
        pTempBuffer[j + 1] = (0x7F & (pBuffer[i] << endCounter));
        
        // var upkeep
        j += 1;
        startCounter += 1;
        endCounter -= 1;
        
        // boundary check
        if(startCounter == 8 && endCounter < 0)
        {
            j++;
            startCounter = 1;
            endCounter = 6;
        }
    }
    
    j++;
    unsigned char *pSendBuffer = NULL;
    int pSendBuffer_n = j + 14;
    pSendBuffer = new unsigned char[pSendBuffer_n];
    memset(pSendBuffer, 0, pSendBuffer_n * sizeof(unsigned char));
    
    pSendBuffer[0] = 0xF0;              //SysEx
    pSendBuffer[1] = GTAR_DEVICE_ID;    
    pSendBuffer[2] = (unsigned char)GTAR_MSG_DWLD_FW_PAGE;
    pSendBuffer[3] = (totSize & 0xFF0000) >> 16;
    pSendBuffer[4] = (totSize & 0x00FF00) >> 8;
    pSendBuffer[5] = (totSize & 0x0000FF) >> 0;
    pSendBuffer[6] = (unsigned char)totPages;
    pSendBuffer[7] = (unsigned char)curPage;
    pSendBuffer[8] = 0;
    pSendBuffer[9] = (j & 0xFF00) >> 8;
    pSendBuffer[10] = (j & 0x00FF);
    pSendBuffer[11] = 0x00;
    
    memcpy(pSendBuffer + 12, pTempBuffer, j);
    
    pSendBuffer[j + 12] = checkSum;	
    pSendBuffer[j + 13] = 0xF7;
    
    r = SendSysExBuffer(pSendBuffer, pSendBuffer_n);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendFirmwarePackagePage: Failed to send SysEx Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    /*
    if(pSendBuffer != NULL) {
        delete [] pSendBuffer;
        pSendBuffer = NULL;
    }
     */
    return r;
}

RESULT CoreMidiInterface::SendSetFretFollow(unsigned char R, unsigned char G, unsigned B)
{
    RESULT r = R_NO_ISSUE;
    
    unsigned char *pSendBuffer = NULL;
    int pSendBuffer_n = 0;
    
    // Create the send buffer    
    pSendBuffer_n = 5;
    pSendBuffer = new unsigned char[pSendBuffer_n];
    
    pSendBuffer[0] = 0xF0;           // SysEx Message
    pSendBuffer[1] = GTAR_DEVICE_ID;
    pSendBuffer[2] = (unsigned char)GTAR_MSG_SET_FRET_FOLLOW;    
    pSendBuffer[3] = CreateRGBMValue(R, G, B, 0x00);    
    pSendBuffer[4] = 0xF7;           // End SysEx Message    
    
    
    r = SendSysExBuffer(pSendBuffer, pSendBuffer_n);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendSetLEDState: Failed to send SysEx Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    if(pSendBuffer != NULL)
    {
        delete [] pSendBuffer;
        pSendBuffer = NULL;
    }
    return r;
}

RESULT CoreMidiInterface::SendCCSetLEDState(unsigned char fret, unsigned char str, unsigned char R, unsigned char G, unsigned char B, unsigned char M)
{
    RESULT r = R_NO_ISSUE;
    
    unsigned char sendBuffer[3];
    
    sendBuffer[0] = 0xB0 + (str & 0xF);
    sendBuffer[1] = 0x33;
    sendBuffer[2] = fret;
    
    r = SendBuffer(sendBuffer, 3);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendCCSetLEDState: Failed to send Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
        
        return r;
    }

    sendBuffer[0] = 0xB0 + (str & 0xF);
    sendBuffer[1] = 0x34;
    sendBuffer[2] = CreateRGBMValue(R, G, B, M);
    
    r = SendBuffer(sendBuffer, 3);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendCCSetLEDState: Failed to send Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    return r;
}

RESULT CoreMidiInterface::SendSetLEDState(unsigned char fret, unsigned char str, unsigned char R, unsigned char G, unsigned char B, unsigned char M)
{
    RESULT r = R_NO_ISSUE;
    
    unsigned char *pSendBuffer = NULL;
    int pSendBuffer_n = 0;
    
    // Create the send buffer    
    pSendBuffer_n = 7;
    pSendBuffer = new unsigned char[pSendBuffer_n];
    
    pSendBuffer[0] = 0xF0;           // SysEx Message
    pSendBuffer[1] = GTAR_DEVICE_ID;
    pSendBuffer[2] = (unsigned char)GTAR_MSG_SET_LED;    
    pSendBuffer[3] = (unsigned char)str;
    pSendBuffer[4] = (unsigned char)fret;
    pSendBuffer[5] = CreateRGBMValue(R, G, B, M);    
    pSendBuffer[6] = 0xF7;           // End SysEx Message    
    
    r = SendSysExBuffer(pSendBuffer, pSendBuffer_n);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendSetLEDState: Failed to send SysEx Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    return r;
}

RESULT CoreMidiInterface::SendNoteMsg(unsigned char channel, unsigned char midiVal, unsigned char velocity, const char* pszOnOff)
{
    RESULT r = R_NO_ISSUE;
    
    // Create the send buffer
    unsigned char sendBuffer[3];
    
    if(strcmp(pszOnOff, "on") == 0)
        sendBuffer[0] = 0x90;
    else
        sendBuffer[0] = 0x80;
    
    sendBuffer[0] += (channel & 0xF);    
    sendBuffer[1] = midiVal;
    sendBuffer[2] = velocity;
    
    r = SendBuffer(sendBuffer, 3);
    
    if( CHECK_ERR(r) )
    {
        m_fnMidiLog([NSString stringWithFormat:@"SendNoteMsg: Failed to send Buffer"],
                    GtarControllerLogLevelError,
                    m_pContext);
    }
    
    return r;
}