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

@synthesize info = m_info;
@synthesize connected = m_connected;
@synthesize spoofed = m_spoofed;
@synthesize responseThread = m_responseThread;
@synthesize logLevel = m_logLevel;
@synthesize minimumInterarrivalTime = m_minimumInterarrivalTime;
@synthesize colorMap = m_colorMap;

@synthesize m_delegate;
@synthesize m_currentGuitarEffect;
@synthesize m_pNetSockConn;

- (id)init
{
    
    self = [super init];
    
    if ( self ) 
    {
        
        m_info = @"GtarController v1";
        
        m_spoofed = NO;
        m_connected = NO;
        
        m_logLevel = GtarControllerLogLevelError;
        
        m_responseThread = GtarControllerThreadMain;
        
        // set a default color mapping
//        char stringColorMap[6][3] = 
//        {
//            {3, 0, 0},
//            {2, 1, 0},
//            {3, 3, 0},
//            {0, 3, 0},
//            {0, 0, 3},
//            {2, 0, 2}
//        };
//        
//        for ( GtarString str = 0; str < GtarControllerStringCount; str++ )
//        {
//            [self setStringColorMapping:str toRed:stringColorMap[str][0] andGreen:stringColorMap[str][1] andBlue:stringColorMap[str][2]];
//        }
        
        // Set a default color map
        GtarLedColorMap colorMap;
        
        colorMap.stringColor[0].red = 3;
        colorMap.stringColor[0].green = 0;
        colorMap.stringColor[0].blue = 0;
        
        colorMap.stringColor[1].red = 2;
        colorMap.stringColor[1].green = 1;
        colorMap.stringColor[1].blue = 0;
        
        colorMap.stringColor[2].red = 3;
        colorMap.stringColor[2].green = 3;
        colorMap.stringColor[2].blue = 0;
        
        colorMap.stringColor[3].red = 0;
        colorMap.stringColor[3].green = 3;
        colorMap.stringColor[3].blue = 0;
        
        colorMap.stringColor[4].red = 0;
        colorMap.stringColor[4].green = 0;
        colorMap.stringColor[4].blue = 3;
        
        colorMap.stringColor[5].red = 2;
        colorMap.stringColor[5].green = 0;
        colorMap.stringColor[5].blue = 2;
        
        self.colorMap = colorMap;
        
        // Initialize the previous pluck times to zero
        for ( GtarString str = 0; str < GtarStringCount; str++ )
        {
            for ( GtarFret fret = 0; fret < GtarFretCount; fret++ )
            {
                m_previousPluckTime[str][fret] = 0;
            }
        }
        
        // Create the midi interface
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
    GtarController * gtarController = (GtarController*)pContext;
    
    char data[4];
    data[0] = data1;
    data[1] = data2;
    data[2] = data3;
    
    [gtarController midiCallbackHandler:data];
    
}

// This is a C callback to the midi stack
void CoreMidiConnectionChangeCallback(BOOL fConnected, void *pContext)
{
    
    // pContext is a pointer to the objective c object, 'to bridge the gap'.
    GtarController * gtarController = (GtarController*)pContext;
    
    [gtarController midiConnectionHandler:fConnected];
    
}

void CoreMidiLog(NSString *msg, unsigned char logLevel, void *pContext)
{
    
    [(GtarController*)pContext logMessage:msg atLogLevel:(GtarControllerLogLevel)logLevel];
    
}

#pragma mark - External functions

- (GtarControllerStatus)debugSpoofConnected
{
    
    // Pretend we are connected for debug purposes
    
    [self logMessage:@"Spoofing device connected"
          atLogLevel:GtarControllerLogLevelInfo];
    
    m_connected = YES;
    m_spoofed = YES;
    
    NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
    
    [responseDictionary setValue:@"notifyObserversGtarDisconnected" forKey:@"Selector"];
    
    [self midiCallbackDispatch:responseDictionary];
    
    [responseDictionary release];
    
    return GtarControllerStatusOk;
    
}

- (GtarControllerStatus)debugSpoofDisconnected
{
    // Pretend we are connected for debug purposes
    
    [self logMessage:@"Spoofing device disconnected"
          atLogLevel:GtarControllerLogLevelInfo];
    
    m_connected = NO;
    m_spoofed = NO;
    
    NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
    
    [responseDictionary setValue:@"notifyObserversGtarDisconnected" forKey:@"Selector"];
    
    [self midiCallbackDispatch:responseDictionary];
    
    [responseDictionary release];
    
    return GtarControllerStatusOk;
    
}

#pragma mark - Internal Functions

- (void)midiConnectionHandler:(BOOL)connected
{
    
    NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
    
    // update the delegate as to what has happened
    if ( connected == true )
    {
        [self logMessage:@"Gtar Midi device connected"
              atLogLevel:GtarControllerLogLevelInfo];
        
        m_connected = YES;
        m_spoofed = NO;
        
        [responseDictionary setValue:@"notifyObserversGtarConnectedM" forKey:@"Selector"];
    }
    else
    {
        [self logMessage:@"Gtar Midi device disconnected"
              atLogLevel:GtarControllerLogLevelInfo];
        
        m_connected = NO;
        m_spoofed = NO;
        
        [responseDictionary setValue:@"notifyObserversGtarDisconnected" forKey:@"Selector"];
    }
    
    [self midiCallbackDispatch:responseDictionary];
    
    [responseDictionary release];
}

- (void)midiCallbackHandler:(char*)data
{
    
    unsigned char msgType = (data[0] & 0xF0) >> 4;
    unsigned char str = (data[0] & 0xF);
    
    double currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    if ( m_pNetSockConn != NULL && m_pNetSockConn->m_fSockConnected )
    {
        
        NSString * pstrTemp = [[NSString alloc] initWithFormat:@"Rx midi data1:%d data2:%d data3:%d data4:%d",
                               data[0],
                               data[1],
                               data[2],
                               data[3]];
        
        if ( [m_pNetSockConn SendNSString:pstrTemp] != R_NO_ISSUE )
        {
            [self logMessage:@"CoreMidi failed to send message on socket"
                  atLogLevel:GtarControllerLogLevelError];
        }
    }
    
    switch ( msgType )
    {
            // This is the Note Off event.
        case 0x8:
        {
            
            unsigned char fret = GetFretForMidiNote(data[1], str - 1);
            
            NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
            
            [responseDictionary setValue:@"notifyObserversGtarNoteOff" forKey:@"Selector"];
            [responseDictionary setValue:[[NSNumber alloc] initWithChar:fret] forKey:@"Fret"];
            [responseDictionary setValue:[[NSNumber alloc] initWithChar:str] forKey:@"String"];
            
            [self midiCallbackDispatch:responseDictionary];
            
            [responseDictionary release];
            
        } break;
            
            // This is the Note On event.
        case 0x9:
        {
            
            unsigned char fret = GetFretForMidiNote(data[1], str - 1);
            
            if ( [self checkNoteInterarrivalTime:currentTime forFret:fret andString:str] == YES )
            {
                NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
                
                [responseDictionary setValue:@"notifyObserversGtarNoteOn" forKey:@"Selector"];
                [responseDictionary setValue:[[NSNumber alloc] initWithChar:fret] forKey:@"Fret"];
                [responseDictionary setValue:[[NSNumber alloc] initWithChar:str] forKey:@"String"];
                
                [self midiCallbackDispatch:responseDictionary];
                
                [responseDictionary release];
            }
            
        } break;
            
            // Control Channel Message
        case 0xB:
        {
            
            unsigned char gTarMsgType = data[1];                    
            
            switch ( gTarMsgType )
            {
                case RX_FRET_UP:
                {
                    // Fret Up
                    unsigned char fret = data[2];
                    
                    NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
                    
                    [responseDictionary setValue:@"notifyObserversGtarFretUp:" forKey:@"Selector"];
                    [responseDictionary setValue:[[NSNumber alloc] initWithChar:fret] forKey:@"Fret"];
                    [responseDictionary setValue:[[NSNumber alloc] initWithChar:str] forKey:@"String"];
                    
                    [self midiCallbackDispatch:responseDictionary];
                    
                    [responseDictionary release];
                    
                } break;
                    
                case RX_FRET_DOWN:
                {
                    // Fret Down
                    unsigned char fret = data[2];
                    
                    NSMutableDictionary * responseDictionary = [[NSMutableDictionary alloc] init];
                    
                    [responseDictionary setValue:@"notifyObserversGtarFretDown:" forKey:@"Selector"];
                    [responseDictionary setValue:[NSNumber numberWithChar:fret] forKey:@"Fret"];
                    [responseDictionary setValue:[NSNumber numberWithChar:str] forKey:@"String"];
                    
                    [self midiCallbackDispatch:responseDictionary];
                    
                    [responseDictionary release];
                    
                } break;
                    
                case RX_FW_VERSION:
                {
                    // Current Version Number
                    unsigned char majorVersion = (data[2] & 0xF0) >> 4;
                    unsigned char minorVersion = (data[2] & 0x0F);
                    
                    [m_delegate ReceivedFWVersion:(int)majorVersion andMinorVersion:(int)minorVersion];
                    
                } break;
                    
                case RX_FW_UPDATE_ACK:
                {
                    // Firmware Ack
                    unsigned char status = data[2];
                    
                    [m_delegate RxFWUpdateACK:status];
                    
                } break;
            }
            
        } break;
            
        default:
        {
            
            [self logMessage:[NSString stringWithFormat:@"Unhandled midi msg of type 0x%x", msgType]
                  atLogLevel:GtarControllerLogLevelError];
            
        } break;
    }
    
}

- (void)midiCallbackDispatch:(NSDictionary*)dictionary
{
    if ( m_responseThread == GtarControllerThreadMain )
    {
        // This queues up request asynchronously
        [self performSelectorOnMainThread:@selector(midiCallbackWorkerThread:) withObject:dictionary waitUntilDone:NO];
    }
    else
    {
        [self performSelector:@selector(midiCallbackWorkerThread:) withObject:dictionary];
    }
}

- (void)midiCallbackWorkerThread:(NSDictionary*)dictionary
{
    
    NSString * selectorString = [dictionary objectForKey:@"Selector"];
    
    SEL selector = NSSelectorFromString(selectorString);
    
    [self performSelector:selector withObject:dictionary];
    
}

- (void)logMessage:(NSString*)str atLogLevel:(GtarControllerLogLevel)level
{
    
    if ( level <= m_logLevel )
    {
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
- (void)notifyObserversGtarFretDown:(NSDictionary*)dictionary
{
    
    NSNumber * fretNumber = [dictionary objectForKey:@"Fret"];
    NSNumber * stringNumber = [dictionary objectForKey:@"String"];
    
    GtarPosition gtarPosition;
    
    gtarPosition.fret = [fretNumber integerValue];
    gtarPosition.string = [stringNumber integerValue];
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(gtarFretDown:)] == YES )
        {
            [observer gtarFretDown:gtarPosition];
        }
    }
}

- (void)notifyObserversGtarFretUp:(NSDictionary*)dictionary
{
    
    NSNumber * fretNumber = [dictionary objectForKey:@"Fret"];
    NSNumber * stringNumber = [dictionary objectForKey:@"String"];
    
    GtarPosition gtarPosition;
    
    gtarPosition.fret = [fretNumber integerValue];
    gtarPosition.string = [stringNumber integerValue];
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(gtarFretUp:)] == YES )
        {
            [observer gtarFretUp:gtarPosition];
        }
    }
}

- (void)notifyObserversGtarNoteOn:(NSDictionary*)dictionary
{
    
    NSNumber * fretNumber = [dictionary objectForKey:@"Fret"];
    NSNumber * stringNumber = [dictionary objectForKey:@"String"];
    
    GtarPosition gtarPosition;
    
    gtarPosition.fret = [fretNumber integerValue];
    gtarPosition.string = [stringNumber integerValue];
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(gtarNoteOn:)] == YES )
        {
            [observer gtarNoteOn:gtarPosition];
        }
    }
}

- (void)notifyObserversGtarNoteOff:(NSDictionary*)dictionary
{
    
    NSNumber * fretNumber = [dictionary objectForKey:@"Fret"];
    NSNumber * stringNumber = [dictionary objectForKey:@"String"];
    
    GtarPosition gtarPosition;
    
    gtarPosition.fret = [fretNumber integerValue];
    gtarPosition.string = [stringNumber integerValue];
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(gtarNoteOff:)] == YES )
        {
            [observer gtarNoteOff:gtarPosition];
        }
    }
}

- (void)notifyObserversGtarConnectedM:(NSDictionary*)dictionary
{
    
    // The dictionary will be nil and unused
    
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(gtarConnected)] == YES )
        {
            [observer gtarConnected];
        }
    }
}

- (void)notifyObserversGtarDisconnected:(NSDictionary*)dictionary
{
    
    // The dictionary will be nil and unused

    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(gtarDisconnected)] == YES )
        {
            [observer gtarDisconnected];
        }
    }
}

#pragma mark - Observer management

- (BOOL)checkNoteInterarrivalTime:(double)time forFret:(GtarFret)fret andString:(GtarString)str
{
    
    if ( (time - m_previousPluckTime[str][fret]) >= m_minimumInterarrivalTime )
    {
        m_previousPluckTime[str][fret] = time;
        
        return YES;
    }
    else
    {
        [self logMessage:[NSString stringWithFormat:@"Dropping double-triggered note: %f secs", (time - m_previousPluckTime[str][fret])]
              atLogLevel:GtarControllerLogLevelInfo];
        
        return NO;
    }
    
}

// Observers should ultimately replace the delegate paradigm we have going.
// I didn't want to rip out the delegate functionality since we use it all
// over the place, but new stuff will need to use the observer model.
- (GtarControllerStatus)addObserver:(id<GtarControllerObserver>)observer
{
    
    // We don't want the observers to be retained to prevent circular dependendcies.
    // We need to make sure we dont retain the object.
    NSValue * nonretainedObserver = [NSValue valueWithNonretainedObject:observer];
    
    if ( observer == nil )
    {
        [self logMessage:@"Added observer is nil"
              atLogLevel:GtarControllerLogLevelWarn];

        return GtarControllerStatusOk;
    }
    
    //
    // We don't want to add the same observer twice.
    //
    if ( [m_observerList containsObject:nonretainedObserver] == NO )
    {
        
        [self logMessage:@"Added observer"
              atLogLevel:GtarControllerLogLevelInfo];
        
        [m_observerList addObject:nonretainedObserver];
        
        // If the guitar is already connected, we should let this new guy know.
        if ( m_connected == YES && [observer respondsToSelector:@selector(gtarConnected)] == YES )
        {
            [observer gtarConnected];
        }
        
    }
    else
    {
        [self logMessage:@"Added observer is already observing"
              atLogLevel:GtarControllerLogLevelWarn];
        
    }
    
    return GtarControllerStatusOk;
    
}

- (GtarControllerStatus)removeObserver:(id<GtarControllerObserver>)observer
{
    
    // We don't want the observers to be retained to prevent circular dependendcies.
    // We need to make sure we dont retain the object.
    NSValue * nonretainedObserver = [NSValue valueWithNonretainedObject:observer];
    
    if ( nonretainedObserver == nil )
    {
        [self logMessage:@"Removed observer is nil"
              atLogLevel:GtarControllerLogLevelWarn];
        
        return GtarControllerStatusOk;
    }
    
    if ( [m_observerList containsObject:nonretainedObserver] == YES )
    {
        
        [self logMessage:@"Removed observer"
              atLogLevel:GtarControllerLogLevelInfo];

        [m_observerList removeObject:nonretainedObserver];
    }
    else
    {
        [self logMessage:@"Removed observer is not observing"
              atLogLevel:GtarControllerLogLevelWarn];
    }
    
    return GtarControllerStatusOk;
    
}

#pragma mark - LED manipulation

- (GtarControllerStatus)turnOffAllLeds
{
    
    GtarControllerStatus status = GtarControllerStatusOk;
    
    if ( m_spoofed == YES )
    {
        
        [self logMessage:@"turnOffAllLeds: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        
        status = GtarControllerStatusOk;
        
    }
    else if ( m_connected == NO )
    {
        
        [self logMessage:@"turnOffAllLeds: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        
        status = GtarControllerStatusNotConnected;
        
    }
    else if ( m_coreMidiInterface == nil )
    {
        
        [self logMessage:@"turnOffAllLeds: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        
        status = GtarControllerStatusError;
        
    }
    else
    {
        
        RESULT result = m_coreMidiInterface->SendSetLEDState(0,0,0,0,0,0);
        
        if ( CHECK_ERR(result) )
        {
            [self logMessage:@"turnOffAllLeds: Setting LED state failed"
                  atLogLevel:GtarControllerLogLevelError];
            
            status = GtarControllerStatusError;
        }
        
    }
    
    return status;
    
}
        
- (GtarControllerStatus)turnOffLedAtPosition:(GtarPosition)position
{
    
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
    GtarControllerStatus status = GtarControllerStatusOk;
    
    if ( m_spoofed == YES )
    {
        
        [self logMessage:@"turnOffLedAtString: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        
        status = GtarControllerStatusOk;
        
    }
    else if ( m_connected == NO )
    {
        
        [self logMessage:@"turnOffLedAtString: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        
        status = GtarControllerStatusNotConnected;
        
    }
    else if ( m_coreMidiInterface == nil )
    {
        
        [self logMessage:@"turnOffLedAtString: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        
        status = GtarControllerStatusError;
        
    }
    else
    {
        
        RESULT result = m_coreMidiInterface->SendSetLEDState(fret, str, 0, 0, 0, 0);
        
        if ( CHECK_ERR(result) )
        {
            [self logMessage:@"turnOffLedAtString: Setting LED state failed"
                  atLogLevel:GtarControllerLogLevelError];
            
            status = GtarControllerStatusError;
        }
        
    }
    
    return status;
    
}

- (GtarControllerStatus)turnOnLedAtPosition:(GtarPosition)position withColor:(GtarLedColor)color
{
    
    GtarFret fret = position.fret;
    GtarString str = position.string;
    
    GtarLedIntensity red = color.red;
    GtarLedIntensity green = color.green;
    GtarLedIntensity blue = color.blue;
    
    GtarControllerStatus status = GtarControllerStatusOk;
    
    if ( m_spoofed == YES )
    {
        
        [self logMessage:@"turnOnLedAtStr: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        
        status = GtarControllerStatusOk;
        
    }
    else if ( m_connected == NO )
    {
        
        [self logMessage:@"turnOnLedAtStr: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        
        status = GtarControllerStatusNotConnected;
        
    }
    else if ( m_coreMidiInterface == nil )
    {
        
        [self logMessage:@"turnOnLedAtStr: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        
        status = GtarControllerStatusError;
        
    }
    else
    {
        
        RESULT result = m_coreMidiInterface->SendSetLEDState(fret, str, red, green, blue, 0);
        
        if ( CHECK_ERR(result) )
        {
            [self logMessage:@"turnOnLedAtStr: Setting LED state failed"
                  atLogLevel:GtarControllerLogLevelError];
            
            status = GtarControllerStatusError;
        }
        
    }
    
    return status;
    
}

- (GtarControllerStatus)turnOnLedAtPositionWithColorMap:(GtarPosition)position
{

    GtarFret fret = position.fret;
    GtarString str = position.string;
    
    GtarControllerStatus status = GtarControllerStatusOk;
    
    if ( m_spoofed == YES )
    {
        
        [self logMessage:@"turnOnLedWithColorMappingAtFret:andString: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        
        status = GtarControllerStatusOk;
        
    }
    else if ( m_connected == NO )
    {
        
        [self logMessage:@"turnOnLedWithColorMappingAtFret:andString: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        
        status = GtarControllerStatusNotConnected;
        
    }
    else if ( m_coreMidiInterface == nil )
    {
        
        [self logMessage:@"turnOnLedWithColorMappingAtFret:andString: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        
        status = GtarControllerStatusError;
        
    }
    else
    {
        
        RESULT result;
        
        if( str == 0 )
        {
            
            // turn on all strings using their specified color mapping
            
            for( int str = 0; str < GtarStringCount; str++ )
            {
                result = m_coreMidiInterface->SendSetLEDState(fret, (str+1), 
                                                              m_stringColorMapping[str][0], 
                                                              m_stringColorMapping[str][1],
                                                              m_stringColorMapping[str][2],
                                                              0);
                
                if ( CHECK_ERR( result ) )
                {
                    [self logMessage:@"turnOnLedWithColorMappingAtFret:andString: Setting LED state failed"
                          atLogLevel:GtarControllerLogLevelError];
                    
                    status = GtarControllerStatusError;
                    break;
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
                [self logMessage:@"turnOnLedWithColorMappingAtFret:andString: Setting LED state failed"
                      atLogLevel:GtarControllerLogLevelError];
                
                status = GtarControllerStatusError;
            }
        }
        
    }
    
    return status;
    
}

- (RESULT)sendNoteMsg:(unsigned char)midiVal channel:(unsigned char)channel withVelocity:(unsigned char)midiVel andType:(const char *)pszOnOff
{
    
    if ( m_spoofed == YES )
    {
        [self logMessage:@"sendNoteMsg: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"sendNoteMsg: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"sendNoteMsg: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendNoteMsg(channel, midiVal, midiVel, pszOnOff);
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"sendNoteMsg: SendNoteMsg failed!"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

#pragma mark - CC Style LED Manipulation

- (RESULT)ccTurnOffAllLeds
{

    if ( m_spoofed == YES )
    {
        [self logMessage:@"ccTurnOffAllLeds: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"ccTurnOffAllLeds: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"ccTurnOffAllLeds: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(0,0,0,0,0,0);
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"ccTurnOffAllLeds: SendSetLEDState failed"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (RESULT)ccTurnOffLedAtString:(GtarString)str andFret:(GtarFret)fret
{

    if ( m_spoofed == YES )
    {
        [self logMessage:@"ccTurnOffLedAtStr: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"ccTurnOffLedAtStr: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"ccTurnOffLedAtStr: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(fret, str,0,0,0,0);
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"ccTurnOffLedAtStr: SendSetLEDState failed"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (RESULT)ccTurnOnLedAtString:(GtarString)str andFret:(GtarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue
{

    if ( m_spoofed == YES )
    {
        [self logMessage:@"ccTurnOnLedAtStr: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"ccTurnOnLedAtStr: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"ccTurnOnLedAtStr: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(fret, str, red, green, blue, 0);
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"ccTurnOnLedAtStr: SendSetLEDState failed"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (RESULT)ccTurnOnLedWithColorMappingAtString:(GtarString)str andFret:(GtarFret)fret
{

    if ( m_spoofed == YES )
    {
        [self logMessage:@"ccTurnOnLedWithColorMappingAtString: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"ccTurnOnLedWithColorMappingAtString: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"ccTurnOnLedWithColorMappingAtString: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendCCSetLEDState(fret, str,
                                                           m_stringColorMapping[str-1][0],
                                                           m_stringColorMapping[str-1][1],
                                                           m_stringColorMapping[str-1][2],
                                                           0);
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"ccTurnOnLedAtStr: SendSetLEDState failed"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

#pragma mark - Requests

- (RESULT)SendRequestFirmwareVersion
{
    
    if ( m_spoofed == YES )
    {
        [self logMessage:@"SendRequestFirmwareVersion: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"SendRequestFirmwareVersion: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"SendRequestFirmwareVersion: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }
    
    RESULT result = m_coreMidiInterface->SendRequestFirmwareVersion();
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"SendRequestFirmwareVersion: SendRequestFirmwareVersion failed"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result;
}

- (RESULT)SendFirmwarePackagePage:(void *)pBuffer bufferSize:(int)pBuffer_n fwSize:(int)fwSize 
                          fwPages:(int)fwPages curPage:(int)curPage withCheckSum:(unsigned char)checkSum
{

    if ( m_spoofed == YES )
    {
        [self logMessage:@"SendRequestFirmwareVersion: Connection spoofed, no-op"
              atLogLevel:GtarControllerLogLevelInfo];
        return R_ERROR;
    }
    else if ( m_connected == NO )
    {
        [self logMessage:@"SendRequestFirmwareVersion: Not connected"
              atLogLevel:GtarControllerLogLevelWarn];
        return R_ERROR;
    }
    else if ( m_coreMidiInterface == nil )
    {
        [self logMessage:@"SendRequestFirmwareVersion: CoreMidiInterface is invalid"
              atLogLevel:GtarControllerLogLevelError];
        return R_ERROR;
    }

    //CVPM_NA(m_coreMidiInterface, @"SendFirmwarePackagePage: CoreMidiInterface is invalid");
    
    RESULT result = m_coreMidiInterface->SendFirmwarePackagePage((unsigned char *)pBuffer, pBuffer_n, fwSize, fwPages, curPage, checkSum);
    
    if ( CHECK_ERR( result ) )
    {
        [self logMessage:@"SendFirmwarePackagePage: Failed to send firmware package page"
              atLogLevel:GtarControllerLogLevelError];
    }
    
    return result; 
}

#pragma mark - Color mapping manipulation

- (GtarControllerStatus)setStringsColorMapping:(char**)colorMap
{
    
    for ( GtarString str = 0; str < GtarStringCount; str++ )
    {
        [self setStringColorMapping:str toRed:colorMap[str][0] andGreen:colorMap[str][1] andBlue:colorMap[str][2]];
    }
    
    return GtarControllerStatusOk;
    
}

- (GtarControllerStatus)setStringColorMapping:(GtarString)str toRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    // Sanity check arguments. We could chose to return 
    // a GtarControllerStatusInvalidParamter status, but its a lot
    // friendlier to just fix it.
    if ( red > 3 ) 
    {
        red = 3;
    }
    
    if ( green > 3 )
    {
        green = 3;
    }
    
    if ( blue > 3 )
    {
        blue = 3;
    }
    
    m_stringColorMapping[str][0] = red;
    m_stringColorMapping[str][1] = green;
    m_stringColorMapping[str][2] = blue;
    
    return GtarControllerStatusOk;
    
}

#pragma mark - Effect handling

- (GtarControllerStatus)turnOffAllEffects
{
    
    GtarControllerStatus status = GtarControllerStatusOk;
    
    [self logMessage:@"Turning off all effects"
          atLogLevel:GtarControllerLogLevelInfo];
    
    RESULT result;
    
    result = m_coreMidiInterface->SendSetFretFollow( 0, 0, 0 );
    
    if ( CHECK_ERR(result) )
    {
        [self logMessage:@"turnOffAllEffects: SendSetFretFollow failed!"
              atLogLevel:GtarControllerLogLevelError];
        
        status = GtarControllerStatusError;
    }
    
    result = m_coreMidiInterface->SendSetNoteActive( 0, 0, 0 );
    
    if ( CHECK_ERR(result) )
    {
        [self logMessage:@"turnOffAllEffects: SendSetNoteActive failed!"
              atLogLevel:GtarControllerLogLevelError];
        
        status = GtarControllerStatusError;
    }
    
    return status;
    
}

- (GtarControllerStatus)turnOnEffect:(GtarControllerEffect)effect withColor:(GtarLedColor)color
{
    
    char red = color.red;
    char green = color.green;
    char blue = color.blue;
    
    GtarControllerStatus status = GtarControllerStatusOk;
    
    switch ( effect ) 
    {
            
        case GtarControllerEffectFretFollow:
        {
            // Enable FF mode
            RESULT result = m_coreMidiInterface->SendSetFretFollow( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                [self logMessage:@"setEffectColor: SendSetFretFollow failed!"
                      atLogLevel:GtarControllerLogLevelError];
                
                status = GtarControllerStatusError;
            }
            
        } break;
            
        case GtarControllerEffectNoteActive:
        {
            // Enable NA mode
            RESULT result = m_coreMidiInterface->SendSetNoteActive( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                [self logMessage:@"setEffectColor: SendSetNoteActive failed!"
                      atLogLevel:GtarControllerLogLevelError];
                
                status = GtarControllerStatusError;
            }
            
        } break;
            
        case GtarControllerEffectFretFollowNoteActive:
        {
            // Enable FF mode
            RESULT result = m_coreMidiInterface->SendSetFretFollow( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                [self logMessage:@"setEffectColor: SendSetFretFollow failed!"
                      atLogLevel:GtarControllerLogLevelError];
                
                status = GtarControllerStatusError;
            }
            
            // Enable NA mode
            result = m_coreMidiInterface->SendSetNoteActive( red, green, blue );
            
            if ( CHECK_ERR(result) )
            {
                [self logMessage:@"setEffectColor: SendSetNoteActive failed!"
                      atLogLevel:GtarControllerLogLevelError];
                
                status = GtarControllerStatusError;
            }

        } break;
            
        case GtarControllerEffectNone:
        default:
        {
            
            // nothing
            
        } break;
    }
    
    return status;
    
}

@end
