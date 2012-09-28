//
//  CoreMidiInterface.m
//  GtarController
//
//  Created by Joel Greenia on 9/26/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "CoreMidiInterface.h"

#include "GtarControllerInternal.h"

@implementation CoreMidiInterface

@synthesize m_gtarController;
@synthesize m_connected;

- (id)init
{
    
    self = [super init];
    
    if ( self ) 
    {
        
        [m_gtarController logMessage:[NSString stringWithFormat:@"CoreMidiInterface initializing"]
                          atLogLevel:GtarControllerLogLevelInfo];
        
        // Create arrays
        m_pSources = [[NSMutableArray alloc] init];
        m_pDestinations = [[NSMutableArray alloc] init];
        m_pSendQueue = [[NSMutableArray alloc] init];
        
        // Create the midi client
        OSStatus oss = MIDIClientCreate(CFSTR("AE Midi Client"), MIDIStateChangedHandler, self, &m_pMidiClient);
        
        if( oss != 0 )
        {
            [m_gtarController logMessage:[NSString stringWithFormat:@"Failed to create AE Midi Client: Error %ld", oss]
                              atLogLevel:GtarControllerLogLevelError];

        }
        
        // Set up the Input Port
        oss = MIDIInputPortCreate(m_pMidiClient, (CFStringRef)@"Midi Client Input Port", MIDIReadHandler, self, &m_pMidiInputPort);
        
        if( oss != 0 )
        {
            [m_gtarController logMessage:[NSString stringWithFormat:@"Failed to create input port: Error %ld", oss]
                              atLogLevel:GtarControllerLogLevelError];
        }
        
        // Set up the Output Port
        oss = MIDIOutputPortCreate(m_pMidiClient, (CFStringRef)@"MidiClient Output Port", &m_pMidiOutputPort);
        
        if( oss != 0 )
        {
            [m_gtarController logMessage:[NSString stringWithFormat:@"Failed to create output port: Error %ld", oss]
                              atLogLevel:GtarControllerLogLevelError];
        }
        
        [self updateEndpoints];

    }
    
    return self;
}

- (void)dealloc
{
    
    if ( m_pMidiClient != NULL )
    {
        OSStatus oss = MIDIClientDispose(m_pMidiClient);
        
        if ( oss != 0 )
        {
            [m_gtarController logMessage:[NSString stringWithFormat:@"Failed to dispose client: Error code %ld", oss]
                              atLogLevel:GtarControllerLogLevelError];
        }
        
        m_pMidiClient = NULL;
    }
    
    [m_pSources release];
    
    [m_pDestinations release];
    
    // We have to nullify the requests that have already been sent out.
    @synchronized( m_pSendQueue )
    {
        for ( NSValue * sendPtr in m_pSendQueue )
        {
            MIDISysexSendRequest * pSendReq = (MIDISysexSendRequest*)[sendPtr pointerValue];
            
            pSendReq->completionRefCon = NULL;
        }
    }
    
    [m_pSendQueue release];
    
    [super dealloc];
}

#pragma mark - Send Queue Management
- (void)processSendQueue
{
    
    @synchronized( m_pSendQueue )
    {
        
        NSValue * ptr = [m_pSendQueue objectAtIndex:0];
        
        // We are done with this pointer
        MIDISysexSendRequest * pSendReq = (MIDISysexSendRequest *)[ptr pointerValue];
        
        free(pSendReq);
        
        [m_pSendQueue removeObject:ptr];
        
        // See if we have anything else queued up
        if ( [m_pSendQueue count] > 0 )
        {
            pSendReq = (MIDISysexSendRequest*)[[m_pSendQueue objectAtIndex:0] pointerValue];
            
            OSStatus oss = MIDISendSysex(pSendReq);
            
            if ( oss == -1 )
            {
                [m_gtarController logMessage:[NSString stringWithFormat:@"SendSysExBuffer: MIDISend failed with status 0x%x", oss]
                                                    atLogLevel:GtarControllerLogLevelError];
            }
        }
        
    }

}

#pragma mark - Endpoint management

- (void)updateEndpoints
{
    
    BOOL previousConnected = m_connected;
    
    int sourceCount = [self updateSources];
    int destinationCount = [self updateDestinations];
    
    [m_gtarController logMessage:[NSString stringWithFormat:@"Found %d sources and %d destinations", sourceCount, destinationCount]
                      atLogLevel:GtarControllerLogLevelInfo];
    
    // See if the connection status changed from connected to !connected or vice versa
    if ( previousConnected == YES )
    {
        if ( m_connected == NO)
        {
            [m_gtarController midiConnectionHandler:NO];
            
            [m_gtarController logMessage:[NSString stringWithFormat:@"gTar Disconnected"]
                              atLogLevel:GtarControllerLogLevelInfo];
        }
    }
    else
    {
        if ( previousConnected == YES )
        {
            [m_gtarController midiConnectionHandler:YES];
            
            [m_gtarController logMessage:[NSString stringWithFormat:@"gTar Connected"]
                              atLogLevel:GtarControllerLogLevelInfo];
        }
    }
    
    // Are we connected to something
    m_connected = (sourceCount > 0 && destinationCount > 0);
    
}

- (int)updateSources
{
    
    int sourceCount = MIDIGetNumberOfSources();
    
    [m_pSources removeAllObjects];
    
    for ( int i = 0; i < sourceCount; i++)
    {
        
        MIDIEndpointRef sourceEndpoint = MIDIGetSource(i);
        
        if ( sourceEndpoint != NULL )
        {
            
            CFStringRef sourceName = nil;
            
            if ( MIDIObjectGetStringProperty( sourceEndpoint, kMIDIPropertyDisplayName, &sourceName) == noErr )
            {
                [m_gtarController logMessage:[NSString stringWithFormat:@"Found Source: %@", (NSString*)sourceName]
                                  atLogLevel:GtarControllerLogLevelInfo];
                
                // Only connect the 'gTar' device for now
                if ( [((NSString*)sourceName) isEqualToString:@"gTar"] == YES )
                {
                    
                    // connect source
                    OSStatus oss = MIDIPortConnectSource(m_pMidiInputPort, sourceEndpoint, self);
                    
                    if ( oss != 0 )
                    {
                        [m_gtarController logMessage:[NSString stringWithFormat:@"Failed to connect gTar source: Error code %ld", oss]
                                          atLogLevel:GtarControllerLogLevelError];
                    }
                    else
                    {
                        [m_pSources addObject:[NSValue valueWithPointer:sourceEndpoint]];
                        
                        [m_gtarController logMessage:[NSString stringWithFormat:@"gTar source connected"]
                                          atLogLevel:GtarControllerLogLevelInfo];
                    }                    
                }
            }
        }
    }
    
    return sourceCount;
}

- (int)updateDestinations
{
    
    int destinationCount = MIDIGetNumberOfDestinations();
    
    [m_pDestinations removeAllObjects];
    
    for ( int i = 0; i < destinationCount; i++)
    {
        
        MIDIEndpointRef destinationEndpoint = MIDIGetDestination(i);
        
        if ( destinationEndpoint != NULL )
        {
            
            CFStringRef destinationName = nil;
            
            if ( MIDIObjectGetStringProperty(destinationEndpoint, kMIDIPropertyDisplayName, &destinationName) == noErr )
            {
                [m_gtarController logMessage:[NSString stringWithFormat:@"Found Destination: %@", (NSString*)destinationName]
                                  atLogLevel:GtarControllerLogLevelInfo];
                
                // Only connect the 'gTar' destination for now
                if ( [((NSString*)destinationName) isEqualToString:@"gTar"] == YES )
                {
                    [m_pDestinations addObject:[NSValue valueWithPointer:destinationEndpoint]];
                    
                    [m_gtarController logMessage:[NSString stringWithFormat:@"gTar destination connected"]
                                      atLogLevel:GtarControllerLogLevelInfo];
                }
            }
        }
    }
    
    return destinationCount;
}

#pragma mark - C-style callbacks

void MIDIStateChangedHandler(const MIDINotification *message, void *refCon)
{
    
    CoreMidiInterface * coreMidiInterface = refCon;
    
    switch ( message->messageID )
    {
        case kMIDIMsgSetupChanged:
        {
            [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Setup Changed"]
                                                atLogLevel:GtarControllerLogLevelInfo];
            
            [coreMidiInterface updateEndpoints];
        } break;
            
        case kMIDIMsgObjectAdded:
        {
            MIDIObjectAddRemoveNotification * messageAdd = (MIDIObjectAddRemoveNotification*)(message);
            
            if ( messageAdd->childType == kMIDIObjectType_Source )
            {
                [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Source Object Added"]
                                                    atLogLevel:GtarControllerLogLevelInfo];
            }
            else if ( messageAdd->childType == kMIDIObjectType_Destination )
            {
                [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Destination Object Added"]
                                                    atLogLevel:GtarControllerLogLevelInfo];
            }
            
        } break;
            
        case kMIDIMsgObjectRemoved:
        {
            MIDIObjectAddRemoveNotification * messageRemove = (MIDIObjectAddRemoveNotification*)(message);
            
            if ( messageRemove->childType == kMIDIObjectType_Source )
            {
                [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Source Object Removed"]
                                                    atLogLevel:GtarControllerLogLevelInfo];
            }
            else if( messageRemove->childType == kMIDIObjectType_Destination )
            {
                [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Destination Object Removed"]
                                                    atLogLevel:GtarControllerLogLevelInfo];
            }
            
        } break;
            
        case kMIDIMsgPropertyChanged:
        {
            [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Property Changed"]
                                                atLogLevel:GtarControllerLogLevelInfo];
        } break;
            
        case kMIDIMsgThruConnectionsChanged:
        {
            [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Thru Connections Changed"]
                                                atLogLevel:GtarControllerLogLevelInfo];
        } break;
            
        case kMIDIMsgSerialPortOwnerChanged:
        {
            [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Serial Port Owner Changed"]
                                                atLogLevel:GtarControllerLogLevelInfo];
        } break;
            
        case kMIDIMsgIOError:
        {
            [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"IO Error"]
                                                atLogLevel:GtarControllerLogLevelError];
        } break;
    }
}

void MIDIReadHandler(const MIDIPacketList *pPacketList, void *pReadProcCon, void *pSrcConnCon)
{
    
    CoreMidiInterface * coreMidiInterface = pSrcConnCon;
    
    for ( int i = 0; i < pPacketList->numPackets; i++ )
    {
        
        MIDIPacket packet = pPacketList->packet[i];
        
        if ( packet.length == 3 || packet.length == 4 )
        {
            [coreMidiInterface.m_gtarController midiCallbackHandler:(char*)packet.data];
        }
        else
        {
            [coreMidiInterface.m_gtarController logMessage:[NSString stringWithFormat:@"Invalid Midi packet size: %u", packet.length]
                                                atLogLevel:GtarControllerLogLevelError];
        }
    }
}

void MIDICompletionHander(MIDISysexSendRequest *request)
{
    
    // If the interface gets torn down below us, this is set to null
    if(request->completionRefCon == NULL)
    {
        return;
    }
    
    CoreMidiInterface * coreMidiInterface = request->completionRefCon;
    
    // Send any pending packets
    [coreMidiInterface processSendQueue];
    
}

#pragma mark - Send Primitives

- (BOOL)sendBuffer:(unsigned char*)buffer withLength:(int)bufferLength
{
    
    // Create the packet 
    MIDIPacket packet;
    
    packet.timeStamp = 0;
    packet.length = bufferLength;
    
    for ( int i = 0; i < bufferLength; i++ )
    {
        packet.data[i] = buffer[i];
    }
    
    // Create the packet list
    MIDIPacketList packetList;
    
    packetList.numPackets = 1;
    packetList.packet[0] = packet;
    
    // Broadcast it on all endpoints for now
    for ( NSValue * destPtr in m_pDestinations )
    {
        
        MIDIEndpointRef endpoint = (MIDIEndpointRef)[destPtr pointerValue];
        
        // Send the packet list
        OSStatus oss = MIDISend(m_pMidiOutputPort, endpoint, &packetList);
        
        if ( oss == -1 )
        {
            [m_gtarController logMessage:[NSString stringWithFormat:@"SendBuffer: MIDISend failed with status 0x%x", oss]
                                                atLogLevel:GtarControllerLogLevelError];
            
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)sendSysExBuffer:(unsigned char*)buffer withLength:(int)bufferLength
{
    
    @synchronized(m_pSendQueue)
    {
        
        // There is currently only a single destination in this loop
        for ( NSValue * destPtr in m_pDestinations )
        {
            
            MIDISysexSendRequest * sendRequest = (MIDISysexSendRequest*) malloc(sizeof(MIDISysexSendRequest));
            
            sendRequest->destination = (MIDIEndpointRef)[destPtr pointerValue];
            sendRequest->data = buffer;
            sendRequest->bytesToSend = bufferLength;
            sendRequest->complete = false;
            
            sendRequest->completionProc = MIDICompletionHander;
            sendRequest->completionRefCon = self;
            
            NSValue * sendPtr = [NSValue valueWithPointer:sendRequest];
            
            [m_pSendQueue addObject:sendPtr];
            
            // If nothing else is on the queue, send this now
            if ( [m_pSendQueue count] == 1 )
            {
                OSStatus oss = MIDISendSysex(sendRequest);
                
                if ( oss == -1 )
                {
                    [m_gtarController logMessage:[NSString stringWithFormat:@"SendSysExBuffer: MIDISend failed with status 0x%x", oss]
                                      atLogLevel:GtarControllerLogLevelError];
                    
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - Set Hardware Effects

// Hardware effects 
- (BOOL)sendSetNoteActiveRed:(unsigned char)red andGreen:(unsigned char) green andBlue:(unsigned char)blue
{
    
    int sendBufferLength = 5;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_SET_NOTE_ACTIVE;
    sendBuffer[3] = [self encodeValueWithRed:red andGreen:green andBlue:blue andMessage:0];
    sendBuffer[4] = 0xF7; // End SysEx Message
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    if ( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendSetNoteActive: Failed to send SysEx Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (BOOL)sendSetFretFollowRed:(unsigned char)red
                    andGreen:(unsigned char)green
                     andBlue:(unsigned char)blue
{
    
    int sendBufferLength = 5;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_SET_FRET_FOLLOW;    
    sendBuffer[3] = [self encodeValueWithRed:red andGreen:green andBlue:blue andMessage:0];
    sendBuffer[4] = 0xF7; // End SysEx Message    
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    if ( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendSetFretFollow: Failed to send SysEx Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

#pragma mark - State Requests

- (BOOL)sendRequestBatteryStatus
{
    
    int sendBufferLength = 3;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_REQ_BAT_STATUS;
    //sendBuffer[4] = 0xF7; // End SysEx Message  
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    [m_gtarController logMessage:[NSString stringWithFormat:@"SendRequestBatteryStatus: Failed to send SysEx Buffer"]
                      atLogLevel:GtarControllerLogLevelError];
    
    return result;

}

- (BOOL)sendEnableDebug
{
    
    int sendBufferLength = 3;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_DBG_ENABLE;
    //sendBuffer[4] = 0xF7; // End SysEx Message  
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    [m_gtarController logMessage:[NSString stringWithFormat:@"SendEnableDebug: Failed to send SysEx Buffer"]
                      atLogLevel:GtarControllerLogLevelError];
    
    return result;
    
}

- (BOOL)sendDisableDebug
{
    
    int sendBufferLength = 3;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_DBG_DISABLE;
    //sendBuffer[4] = 0xF7; // End SysEx Message  
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    [m_gtarController logMessage:[NSString stringWithFormat:@"SendDisableDebug: Failed to send SysEx Buffer"]
                      atLogLevel:GtarControllerLogLevelError];
    
    return result;

}

#pragma mark - Firmware and Certs

- (BOOL)sendRequestCertDownload
{

    int sendBufferLength = 4;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_REQ_CERT_DOWNLOAD;
    sendBuffer[4] = 0xF7; // End SysEx Message
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    if ( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendRequestCertDownload: Failed to send SysEx Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (BOOL)sendRequestFirmwareVersion
{
    
    int sendBufferLength = 4;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_REQ_FW_VERSION;
    //pSendBuffer[4] = 0xF7; // End SysEx Message
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    if ( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendRequestFirmwareVersion: Failed to send SysEx Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (BOOL)sendFirmwarePackagePage:(unsigned char*)buffer 
                     withLength:(int)bufferLength
                        andSize:(int)totSize
                       andPages:(int)totPages
                     andCurPage:(int)curPage
                    andCheckSum:(unsigned char)checkSum
{
    
    // All data bytes must be converted to midi data bytes which have a zero for the MSB
    int j = 0;
    unsigned char tempBuffer[bufferLength*2];
    
    memset(tempBuffer, 0, bufferLength * 2);
    
    signed char startCounter = 1;
    signed char endCounter = 6;
    
    for ( int i = 0; i < bufferLength; i++ )
    {
        // add current fragment and begining of next 
        tempBuffer[j] += (buffer[i] >> startCounter) & 0x7F;
        tempBuffer[j + 1] = (0x7F & (buffer[i] << endCounter));
        
        // var upkeep
        j += 1;
        startCounter += 1;
        endCounter -= 1;
        
        // boundary check
        if ( startCounter == 8 && endCounter < 0 )
        {
            j++;
            startCounter = 1;
            endCounter = 6;
        }
    }
    
    j++;
    
    unsigned char sendBuffer[bufferLength*2];
    
    int sendBufferLength = j + 14;
    
    memset(sendBuffer, 0, bufferLength);
    
    sendBuffer[0] = 0xF0; //SysEx
    sendBuffer[1] = GTAR_DEVICE_ID;    
    sendBuffer[2] = (unsigned char)GTAR_MSG_DWLD_FW_PAGE;
    sendBuffer[3] = (totSize & 0xFF0000) >> 16;
    sendBuffer[4] = (totSize & 0x00FF00) >> 8;
    sendBuffer[5] = (totSize & 0x0000FF) >> 0;
    sendBuffer[6] = (unsigned char)totPages;
    sendBuffer[7] = (unsigned char)curPage;
    sendBuffer[8] = 0;
    sendBuffer[9] = (j & 0xFF00) >> 8;
    sendBuffer[10] = (j & 0x00FF);
    sendBuffer[11] = 0x00;
    
    memcpy(sendBuffer + 12, tempBuffer, j);
    
    sendBuffer[j + 12] = checkSum;	
    sendBuffer[j + 13] = 0xF7;
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    if ( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendFirmwarePackagePage: Failed to send SysEx Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

#pragma mark - Set LED State

- (BOOL)sendCCSetLedStatusFret:(unsigned char)fret
                     andString:(unsigned char)str
                        andRed:(unsigned char)red
                      andGreen:(unsigned char)green
                       andBlue:(unsigned char)blue
                    andMessage:(unsigned char)message
{
    
    int sendBufferLength = 3;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xB0 + (str & 0xF);
    sendBuffer[1] = 0x33;
    sendBuffer[2] = fret;
    
    BOOL result = [self sendBuffer:sendBuffer withLength:sendBufferLength];
    
    if( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendCCSetLEDState: Failed to send Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
        
        return result;
    }
    
    sendBuffer[0] = 0xB0 + (str & 0xF);
    sendBuffer[1] = 0x34;
    sendBuffer[2] = [self encodeValueWithRed:red andGreen:green andBlue:blue andMessage:message];
    
    result = [self sendBuffer:sendBuffer withLength:sendBufferLength];
    
    if ( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendCCSetLEDState: Failed to send Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (BOOL)sendSetLedStateFret:(unsigned char)fret
                  andString:(unsigned char)str
                     andRed:(unsigned char)red
                   andGreen:(unsigned char)green
                    andBlue:(unsigned char)blue
                 andMessage:(unsigned char)message
{

    int sendBufferLength = 3;
    unsigned char sendBuffer[sendBufferLength];
    
    sendBuffer[0] = 0xF0; // SysEx Message
    sendBuffer[1] = GTAR_DEVICE_ID;
    sendBuffer[2] = (unsigned char)GTAR_MSG_SET_LED;    
    sendBuffer[3] = (unsigned char)str;
    sendBuffer[4] = (unsigned char)fret;
    sendBuffer[5] = [self encodeValueWithRed:red andGreen:green andBlue:blue andMessage:message];
    sendBuffer[6] = 0xF7; // End SysEx Message    
    
    BOOL result = [self sendSysExBuffer:sendBuffer withLength:sendBufferLength];
    
    if( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendSetLEDState: Failed to send SysEx Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (BOOL)sendNoteMessageOnChannel:(unsigned char)channel
                    andMidiValue:(unsigned char)midiVal
                     andMidiVel:(unsigned char)midiVel
                       andType:(const char*)type
{
    
    int sendBufferLength = 3;
    unsigned char sendBuffer[sendBufferLength];
    
    // Type is either "off" or "on"
    if ( strcmp( type, "on") == 0 )
    {
        sendBuffer[0] = 0x90;
    }
    else
    {
        sendBuffer[0] = 0x80;
    }
    
    sendBuffer[0] += (channel & 0xF);    
    sendBuffer[1] = midiVal;
    sendBuffer[2] = midiVel;
    
    BOOL result = [self sendBuffer:sendBuffer withLength:sendBufferLength];
    
    if( result == NO )
    {
        [m_gtarController logMessage:[NSString stringWithFormat:@"SendNoteMsg: Failed to send Buffer"]
                          atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

#pragma mark - Helpers

- (unsigned char)encodeValueWithRed:(unsigned char)red
                           andGreen:(unsigned char)green
                            andBlue:(unsigned char)blue
                         andMessage:(unsigned char)message
{
    unsigned char retVal = 0;
    
    retVal += ((red & 0x3) << 6);
    retVal += ((green & 0x3) << 4);
    retVal += ((blue & 0x3) << 2);
    retVal += ((message & 0x3) << 0);
    
    return retVal;
}

- (int)getFretFromMidiNote:(int)midiNote andString:(int)str
{
    
    if ( str < 0 || str > 5 )
    {
        return -1;
    }
    
    int fret = midiNote - (40 + 5 * str);
    
    if (str > 3 )
    {
        fret += 1;
    }
    
    return fret;
}

@end
