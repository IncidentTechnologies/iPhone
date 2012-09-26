//
//  GtarController.m
//  GtarController
//
//  Created by Marty Greenia on 5/24/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import "GtarControllerInternal.h"

#import "CoreMidiInterface.h"
#import "NetSockConn.h"

@implementation GtarController

@synthesize m_delegate;
@synthesize m_currentGuitarEffect;
@synthesize m_pNetSockConn;

- (id)init
{
    
    self = [super init];
    
    if ( self ) 
    {
        
        m_spoofed = NO;
        m_connected = NO;
        
        // set a default color mapping
        char stringColorMap[6][3] = 
        {
            {3, 0, 0},
            {2, 1, 0},
            {3, 3, 0},
            {0, 3, 0},
            {0, 0, 3},
            {2, 0, 2}
        };
        
        for ( GtarString str = 0; str < GTAR_CONTROLLER_STRING_COUNT; str++ )
        {
            [self setStringColorMapping:str toRed:stringColorMap[str][0] andGreen:stringColorMap[str][1] andBlue:stringColorMap[str][2]];
        }
        
        for ( GtarString str = 0; str < GTAR_CONTROLLER_STRING_COUNT; str++ )
        {
            for ( GtarFret fret = 0; fret < GTAR_CONTROLLER_FRET_COUNT; fret++ )
            {
                m_previousPluckTime[str][fret] = 0;
            }
        }
        
        m_coreMidiInterface = new CoreMidiInterface( CoreMidiCallback, CoreMidiConnectionChangeCallback, CoreMidiLog, self );
        m_coreMidiInterface->init();
        
        m_observerList = [[NSMutableArray alloc] init];
        
        m_pNetSockConn = [[NetSockConn alloc] init];
        m_pNetSockConn->m_pGuitarController = self;
        
        if ( !m_coreMidiInterface->IsValid() )
        {
            [self logMessage:@"CoreMidi interface has been initialized, but is invalid"
                  atLogLevel:GtarControllerLogLevelError];

            m_connected = NO;
        }
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    delete m_coreMidiInterface;
    
    [m_observerList release];
    
    [m_pNetSockConn release];
    
    [m_eventLoopTimer invalidate];
    
    [super dealloc];
    
}

#pragma mark - Net Sock Conn functionality 

- (BOOL)IsNetSockConnConnected
{
    return [m_pNetSockConn m_fSockConnected];
}

- (RESULT)DisconnectNetSockConn
{
    return [m_pNetSockConn disconnect];
}

- (RESULT)InitNetSockConn:(NSString *)pstrHost atPort:(UInt32)portNumber
{
    return [m_pNetSockConn initNetworkCommunication:pstrHost atPort:portNumber];
}

#pragma mark - Event loop

// This is a C callback to the midi stack
void CoreMidiCallback(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext)
{
    // pContext is a pointer to the objective c object, 'to bridge the gap'.
    GtarController * guitarController = (GtarController*)pContext;
    
    unsigned char msgType = (data1 & 0xF0) >> 4;
    unsigned char str = (data1 & 0xF);
    
    double currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    if ( guitarController.m_pNetSockConn != NULL && guitarController.m_pNetSockConn->m_fSockConnected )
    {
        
        NSString * pstrTemp = [[NSString alloc] initWithFormat:@"Rx midi data1:%d data2:%d data3:%d data4:%d", data1, data2, data3, data4];
        
        if ( [guitarController->m_pNetSockConn SendNSString:pstrTemp] != R_NO_ISSUE )
        {
            [guitarController logMessage:@"CoreMidi failed to send message on socket"
                              atLogLevel:GtarControllerLogLevelError];
        }
    }
    
    switch ( msgType )
    {
        // This is the Note Off event.
        case 0x8:
        {
            
            unsigned char fret = GetFretForMidiNote(data2, str - 1);
            
            [guitarController notifyObserversGuitarNotesOffFret:fret andString:str];
            
        } break;
            
        // This is the Note On event.
        case 0x9:
        {
            
            unsigned char fret = GetFretForMidiNote(data2, str - 1);
            
            [guitarController checkNoteInterarrivalTime:currentTime forFret:fret andString:str];
            
        } break;
            
        // Control Channel Message
        case 0xB:
        {
            
            unsigned char gTarMsgType = data2;                    
            
            switch ( gTarMsgType )
            {
                case RX_FRET_UP:
                {
                    // Fret Up
                    [guitarController notifyObserversGuitarFretUp:data3 andString:str];
                } break;
                    
                case RX_FRET_DOWN:
                {
                    // Fret Down
                    [guitarController notifyObserversGuitarFretDown:data3 andString:str];
                } break;
                    
                case RX_FW_VERSION:
                {
                    // Current Version Number
                    unsigned char majorVersion = (data3 & 0xF0) >> 4;
                    unsigned char minorVersion = (data3 & 0x0F);
                    
                    [guitarController.m_delegate ReceivedFWVersion:(int)majorVersion andMinorVersion:(int)minorVersion];
                    
                } break;
                    
                case RX_FW_UPDATE_ACK:
                {
                    // Firmware Ack
                    unsigned char status = data3;
                    
                    [guitarController.m_delegate RxFWUpdateACK:status];
                    
                } break;
            }
            
        } break;
            
        default:
        {
            
            [guitarController logMessage:[NSString stringWithFormat:@"Unhandled midi msg of type 0x%x", msgType]
                              atLogLevel:GtarControllerLogLevelError];
            
        } break;
    }
    
}

// This is a C callback to the midi stack
void CoreMidiConnectionChangeCallback(BOOL fConnected, void *pContext)
{
    
    // pContext is a pointer to the objective c object, 'to bridge the gap'.
    GtarController * guitarController = (GtarController*)pContext;
    
    // update the delegate as to what has happened
    if ( fConnected == true )
    {
        [guitarController guitarConnected];
    }
    else
    {
        [guitarController guitarDisconnected];
    }
    
}

void CoreMidiLog(NSString *msg, unsigned char logLevel, void *pContext)
{
    
    [(GtarController*)pContext logMessage:msg atLogLevel:(GtarControllerLogLevel)logLevel];
    
}

#pragma mark - External functions

- (BOOL)isConnected
{
    return m_connected;
}

- (void)setLogLevel:(GtarControllerLogLevel)level
{
    
    m_logLevel = level;
    
}

- (void)debugSpoofConnected
{
    // Pretend we are connected for debug purposes
    m_connected = YES;
    m_spoofed = YES;
    
    [self notifyObserversGuitarConnected];
    
    [self logMessage:@"Spoofing device connected"
          atLogLevel:GtarControllerLogLevelInfo];
    
}

- (void)debugSpoofDisconnected
{
    // Pretend we are connected for debug purposes
    m_connected = NO;
    m_spoofed = NO;
    
    [self notifyObserversGuitarDisconnected];
    
    [self logMessage:@"Spoofing device disconnected"
          atLogLevel:GtarControllerLogLevelInfo];
    
}

#pragma mark - Observer management

- (void)guitarConnected
{
    m_connected = YES;
    m_spoofed = NO;
    
    [self notifyObserversGuitarConnected];
    
    [self logMessage:@"CoreMidi device connected"
          atLogLevel:GtarControllerLogLevelInfo];

}

- (void)guitarDisconnected
{
    m_connected = NO;
    m_spoofed = NO;
    
    [self notifyObserversGuitarDisconnected];
    
    [self logMessage:@"CoreMidi device disconnected"
          atLogLevel:GtarControllerLogLevelInfo];
    
}

- (void)checkNoteInterarrivalTime:(double)time forString:(GtarFret)fret andFret:(GtarString)str
{
    
    if ( (time - m_previousPluckTime[str][fret]) >= m_minimumInterarrivalTime )
    {
        
        m_previousPluckTime[str][fret] = time;
        
        [self notifyObserversGuitarNotesOnFret:fret andString:str];
        
    }
    else
    {
        [self logMessage:[NSString stringWithFormat:@"Dropping double-triggered note: %f secs", (time - m_previousPluckTime[str][fret])]
              atLogLevel:GtarControllerLogLevelInfo];
    }
    
}

// Observers should ultimately replace the delegate paradigm we have going.
// I didn't want to rip out the delegate functionality since we use it all
// over the place, but new stuff will need to use the observer model.
- (void)addObserver:(id<GtarControllerObserver>)observer
{
    
    // We don't want the observers to be retained to prevent circular dependendcies.
    // We need to make sure we dont retain the object.
    NSValue * nonretainedObserver = [NSValue valueWithNonretainedObject:observer];
    
    if ( observer == nil )
    {
        [self logMessage:@"Added observer is nil"
              atLogLevel:GtarControllerLogLevelWarn];

        return;
    }
    
    //
    // We don't want to add the same observer twice.
    //
    if ( [m_observerList containsObject:nonretainedObserver] == NO )
    {
        [m_observerList addObject:nonretainedObserver];
        
        // If the guitar is already connected, we should let this new guy know.
        if ( m_connected == YES && [observer respondsToSelector:@selector(guitarConnected)] == YES )
        {
            [observer gtarConnected];
        }
    }
    
}

- (void)removeObserver:(id<GtarControllerObserver>)observer
{
    
    // We don't want the observers to be retained to prevent circular dependendcies.
    // We need to make sure we dont retain the object.
    NSValue * nonretainedObserver = [NSValue valueWithNonretainedObject:observer];
    
    if ( nonretainedObserver == nil )
    {
        [self logMessage:@"Removed observer is nil"
              atLogLevel:GtarControllerLogLevelWarn];
        return;
    }
    
    [m_observerList removeObject:nonretainedObserver];
    
}

#pragma Internal Functions

// Logging
- (void)logMessage:(NSString*)str atLogLevel:(GtarControllerLogLevel)level
{
    
    if ( level >= m_logLevel )
    {
        // Formatting it this way vs. NSLog(str) removes the warning and is
        // technically more secure.
        switch (level)
        {
            case GtarControllerLogLevelError:
            {
                NSLog(@"GtarController: Error: %@", str );
            } break;
                
            case GtarControllerLogLevelWarn:
            {
                NSLog(@"GtarController: Warning: %@", str );
            } break;
                
            case GtarControllerLogLevelInfo:
            {
                NSLog(@"GtarController: Info: %@", str );
            } break;
                
            default:
            {
                NSLog(@"GtarController: %@", str );
            } break;
                
        }
    }
    
}

// Notifying observers
- (void)notifyObserversGuitarFretDown:(GtarFret)fret andString:(GtarString)str
{

    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarFretDown:andString:)] == YES )
        {
            [observer gtarFretDown:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarFretUp:(GtarFret)fret andString:(GtarString)str
{

    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarFretUp:andString:)] == YES )
        {
            [observer gtarFretUp:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarNotesOnFret:(GtarFret)fret andString:(GtarString)str
{
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarNotesOnFret:andString:)] == YES )
        {
            [observer gtarNoteOnFret:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarNotesOffFret:(GtarFret)fret andString:(GtarString)str
{
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarNotesOffFret:andString:)] == YES )
        {
            [observer gtarNoteOffFret:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarConnected
{

    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarConnected)] == YES )
        {
            [observer gtarConnected];
        }
    }
}

- (void)notifyObserversGuitarDisconnected
{

    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarDisconnected)] == YES )
        {
            [observer gtarDisconnected];
        }
    }
}

#pragma mark - LED manipulation

- (void)turnOffAllLeds
{
    
    if ( m_spoofed == YES )
    {
        NSLog(@"turnOffAllLeds: Connection spoofed, no-op");
        return;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"turnOffAllLeds: Not connected");
        return;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"turnOffAllLeds: CoreMidiInterface is invalid");
        return;
    }
    
    RESULT result = m_coreMidiInterface->SendSetLEDState(0,0,0,0,0,0);
    
    if ( CHECK_ERR(result) )
    {
        NSLog(@"turnOffAllLeds: SendSetLEDState failed");
    }
}
        
- (void)turnOffLedAtFret:(GtarFret)fret andString:(GtarString)str
{
    
    if ( m_spoofed == YES )
    {
        NSLog(@"turnOffLedAtString: Connection spoofed, no-op");
        return;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"turnOffLedAtString: Not connected");
        return;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"turnOffLedAtString: CoreMidiInterface is invalid");
        return;
    }

    RESULT result = m_coreMidiInterface->SendSetLEDState(fret, str, 0, 0, 0, 0);
    
    if ( CHECK_ERR(result) )
    {
        NSLog(@"turnOffLedAtString: SendSetLEDState failed");
    }
}

- (void)turnOnLedAtFret:(GtarFret)fret andString:(GtarString)str withRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    
    if ( m_spoofed == YES )
    {
        NSLog(@"turnOnLedAtStr: Connection spoofed, no-op");
        return;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"turnOnLedAtStr: Not connected");
        return;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"turnOnLedAtStr: CoreMidiInterface is invalid");
        return;
    }
    
    RESULT result = m_coreMidiInterface->SendSetLEDState(fret, str, red, green, blue, 0);
    
    if ( CHECK_ERR(result) )
    {
        NSLog(@"turnOnLedAtStr: SendSetLEDState failed");
    }
}

- (void)turnOnLedWithColorMappingAtFret:(GtarFret)fret andString:(GtarString)str
{

    if ( m_spoofed == YES )
    {
        NSLog(@"turnOnLedWithColorMappingAtString:andFret: Connection spoofed, no-op");
        return;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"turnOnLedWithColorMappingAtString:andFret: Not connected");
        return;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"turnOnLedWithColorMappingAtString:andFret: CoreMidiInterface is invalid");
        return;
    }

    RESULT result;
    
    if( str == 0 )
    {
        
        // turn on all strings using their specified color mapping
        
        for( int s = 0; s < GTAR_CONTROLLER_STRING_COUNT; s++ )
        {
            result = m_coreMidiInterface->SendSetLEDState(fret, (s+1), 
                                                          m_stringColorMapping[s][0], 
                                                          m_stringColorMapping[s][1],
                                                          m_stringColorMapping[s][2],
                                                          0);
            if ( CHECK_ERR( result ) )
            {
                NSLog(@"turnOnLedWithColorMappingAtString: SendSetLEDState failed");
            }
        }
    }
    else
    {
        // subtract one to zero-base the string
        result = m_coreMidiInterface->SendSetLEDState(fret, str, m_stringColorMapping[str-1][0], 
                                                      m_stringColorMapping[str-1][1],
                                                      m_stringColorMapping[str-1][2],
                                                      0);
        if ( CHECK_ERR( result ) )
        {
            NSLog(@"turnOnLedWithColorMappingAtString: SendSetLEDState failed");
        }
    }
    
}

- (RESULT)sendNoteMsg:(unsigned char)midiVal channel:(unsigned char)channel withVelocity:(unsigned char)midiVel andType:(const char *)pszOnOff
{
    
    if ( m_spoofed == YES )
    {
        NSLog(@"sendNoteMsg: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"sendNoteMsg: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"sendNoteMsg: CoreMidiInterface is invalid");
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendNoteMsg(channel, midiVal, midiVel, pszOnOff);
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"sendNoteMsg: SendNoteMsg failed!");
    }
    
    return result;
}

#pragma mark - CC Style LED Manipulation

- (RESULT)ccTurnOffAllLeds
{

    if ( m_spoofed == YES )
    {
        NSLog(@"ccTurnOffAllLeds: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"ccTurnOffAllLeds: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"ccTurnOffAllLeds: CoreMidiInterface is invalid");
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(0,0,0,0,0,0);
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"ccTurnOffAllLeds: SendSetLEDState failed");
    }
    
    return result;
}

- (RESULT)ccTurnOffLedAtString:(GtarString)str andFret:(GtarFret)fret
{

    if ( m_spoofed == YES )
    {
        NSLog(@"ccTurnOffLedAtStr: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"ccTurnOffLedAtStr: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"ccTurnOffLedAtStr: CoreMidiInterface is invalid");
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(fret, str,0,0,0,0);
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"ccTurnOffLedAtStr: SendSetLEDState failed");
    }
    
    return result;
}

- (RESULT)ccTurnOnLedAtString:(GtarString)str andFret:(GtarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue
{

    if ( m_spoofed == YES )
    {
        NSLog(@"ccTurnOnLedAtStr: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"ccTurnOnLedAtStr: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"ccTurnOnLedAtStr: CoreMidiInterface is invalid");
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(fret, str, red, green, blue, 0);
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"ccTurnOnLedAtStr: SendSetLEDState failed");
    }
    
    return result;
}

- (RESULT)ccTurnOnLedWithColorMappingAtString:(GtarString)str andFret:(GtarFret)fret
{

    if ( m_spoofed == YES )
    {
        NSLog(@"ccTurnOnLedWithColorMappingAtString: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"ccTurnOnLedWithColorMappingAtString: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"ccTurnOnLedWithColorMappingAtString: CoreMidiInterface is invalid");
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(fret, str,
                                                           m_stringColorMapping[str-1][0],
                                                           m_stringColorMapping[str-1][1],
                                                           m_stringColorMapping[str-1][2],
                                                           0);
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"ccTurnOnLedAtStr: SendSetLEDState failed");
    }
    
    return result;
}

#pragma mark - Requests 
- (RESULT)SendRequestFirmwareVersion
{
    
    if ( m_spoofed == YES )
    {
        NSLog(@"SendRequestFirmwareVersion: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"SendRequestFirmwareVersion: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"SendRequestFirmwareVersion: CoreMidiInterface is invalid");
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendRequestFirmwareVersion();
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"SendRequestFirmwareVersion: SendRequestFirmwareVersion failed");
    }
    
    return result;
}

- (RESULT)SendFirmwarePackagePage:(void *)pBuffer bufferSize:(int)pBuffer_n fwSize:(int)fwSize 
                          fwPages:(int)fwPages curPage:(int)curPage withCheckSum:(unsigned char)checkSum
{

    if ( m_spoofed == YES )
    {
        NSLog(@"SendRequestFirmwareVersion: Connection spoofed, no-op");
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        NSLog(@"SendRequestFirmwareVersion: Not connected");
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        NSLog(@"SendRequestFirmwareVersion: CoreMidiInterface is invalid");
        return R_ERROR;
    }

    //CVPM_NA(m_coreMidiInterface, @"SendFirmwarePackagePage: CoreMidiInterface is invalid");
    
    RESULT result = m_coreMidiInterface->SendFirmwarePackagePage((unsigned char *)pBuffer, pBuffer_n, fwSize, fwPages, curPage, checkSum);
    
    if ( CHECK_ERR( result ) )
    {
        NSLog(@"SendFirmwarePackagePage: Failed to send firmware package page");
    }
    
    return result;
}

#pragma mark - Color mapping manipulation

- (void)setStringsColorMapping:(char**)colorMap
{
    
    for ( GtarString str = 0; str < GTAR_CONTROLLER_STRING_COUNT; str++ )
    {
        [self setStringColorMapping:str toRed:colorMap[str][0] andGreen:colorMap[str][1] andBlue:colorMap[str][2]];
    }
    
}

- (void)setStringColorMapping:(GtarString)str toRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    m_stringColorMapping[str][0] = red;
    m_stringColorMapping[str][1] = green;
    m_stringColorMapping[str][2] = blue;
}

- (void)setMinimumInterarrivalTime:(double)time
{
    // Set it equal to zero to effectively disable this
    m_minimumInterarrivalTime = time;
}

#pragma mark - Effect handling

- (void)turnOffAllEffects
{
    
    NSLog(@"Turning off all effects");
    
    RESULT result;
    
    result = m_coreMidiInterface->SendSetFretFollow( 0, 0, 0 );
    
    if ( CHECK_ERR(result) )
    {
        NSLog(@"turnOffAllEffects: SendSetFretFollow failed!");
    }
    
    result = m_coreMidiInterface->SendSetNoteActive( 0, 0, 0 );
    
    if ( CHECK_ERR(result) )
    {
        NSLog(@"turnOffAllEffects: SendSetNoteActive failed!");
    }
    
}

- (void)setEffectColor:(GtarControllerEffect)effect toRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    
    RESULT result;
    
    switch ( effect ) 
    {
            
        case GtarControllerEffectFretFollow:
        {
            // Enable FF mode
            result = m_coreMidiInterface->SendSetFretFollow( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                NSLog(@"setEffectColor: SendSetFretFollow failed!");
            }
            
        } break;
            
        case GtarControllerEffectNoteActive:
        {
            // Enable NA mode
            result = m_coreMidiInterface->SendSetNoteActive( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                NSLog(@"setEffectColor: SendSetNoteActive failed!");
            }
            
        } break;
            
        case GtarControllerEffectFretFollowNoteActive:
        {
            // Enable FF mode
            result = m_coreMidiInterface->SendSetFretFollow( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                NSLog(@"setEffectColor: SendSetFretFollow failed!");
            }
            
            // Enable NA mode
            result = m_coreMidiInterface->SendSetNoteActive( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                NSLog(@"setEffectColor: SendSetNoteActive failed!");
            }

        } break;
            
        case GtarControllerEffectNone:
        default:
        {
            
            // nothing
            
        } break;
    }
    
}

@end
