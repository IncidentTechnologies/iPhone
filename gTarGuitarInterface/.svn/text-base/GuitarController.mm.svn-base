//
//  GuitarController.m
//  gTarGuitarInterface
//
//  Created by Marty Greenia on 8/3/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "GuitarController.h"

#import "CoreMidiInterface.h"
#import "NetSockConn.h"

#define EVENT_LOOPS_PER_SECOND 30.0
#define SECONDS_PER_EVENT_LOOP (1.0 / EVENT_LOOPS_PER_SECOND)

@implementation GuitarController

@synthesize m_delegate;
@synthesize m_currentGuitarEffect;
@synthesize m_connected;

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
        
        for ( GuitarString str = 0; str < GUITAR_CONTROLLER_STRING_COUNT; str++ )
        {
            [self setStringColorMapping:str toRed:stringColorMap[str][0] andGreen:stringColorMap[str][1] andBlue:stringColorMap[str][2]];
        }
        
        for ( GuitarString str = 0; str < GUITAR_CONTROLLER_STRING_COUNT; str++ )
        {
            for ( GuitarFret fret = 0; fret < GUITAR_CONTROLLER_FRET_COUNT; fret++ )
            {
                m_previousPluckTime[str][fret] = 0;
            }
        }
        
        
//        [self setEffectColor:GuitarControllerEffectFretFollow toRed:3 andGreen:3 andBlue:3];
//        [self setEffectColor:GuitarControllerEffectNoteActive toRed:3 andGreen:3 andBlue:3];
//        [self setEffectColor:GuitarControllerEffectLightningMode toRed:3 andGreen:3 andBlue:3];
        
        m_coreMidiInterface = new CoreMidiInterface( CoreMidiCallback, CoreMidiConnectionChangeCallback, self );
        m_coreMidiInterface->init();
        
        m_observerList = [[NSMutableArray alloc] init];
        
        m_pNetSockConn = [[NetSockConn alloc] init];
        m_pNetSockConn->m_pGuitarController = self;
        
        if(!m_coreMidiInterface->IsValid())
        {
            NSLog(@"Warning: CoreMidiInterface has been initialized, but is invalid");
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

- (BOOL) IsNetSockConnConnected {
    return [m_pNetSockConn m_fSockConnected];
}

- (RESULT) DisconnectNetSockConn {
    return [m_pNetSockConn disconnect];
}

- (RESULT) InitNetSockConn:(NSString *)pstrHost atPort:(UInt32)portNumber {
    return [m_pNetSockConn initNetworkCommunication:pstrHost atPort:portNumber];
}

#pragma mark - Event loop

// data1 encodes the message type in the first 4 bits, and the string in the second 4 bits
// data2 is the Midi note number
// data3 is the velocity value
// data4 is currently not used
int CoreMidiCallback(unsigned char data1, unsigned char data2, unsigned char data3, unsigned char data4, void *pContext)
{
    // pContext is a pointer to the objective c object, 'to bridge the gap'.
    GuitarController *guitarController = (GuitarController*)pContext;
    
    unsigned char MsgType = (data1 & 0xF0) >> 4;
    unsigned char str = (data1 & 0xF);
    
    double currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    if(guitarController->m_pNetSockConn != NULL && guitarController->m_pNetSockConn->m_fSockConnected) {    
        NSString *pstrTemp = [[NSString alloc] initWithFormat:@"Rx midi data1:%d data2:%d data3:%d data4:%d", data1, data2, data3, data4];
        
        if([guitarController->m_pNetSockConn SendNSString:pstrTemp] != R_NO_ISSUE)
            NSLog(@"CoreMidiCallback: Failed to send message on socket");
    }
    
    switch( MsgType )
    {
        // This is the Note Off event.
        case 0x8:
        {
            unsigned char fret = GetFretForMidiNote(data2, str - 1);
            
            [guitarController.m_delegate guitarNotesOffFret:fret andString:str];
            [guitarController notifyObserversGuitarNotesOffFret:fret andString:str];
            
        } break;
            
        // This is the Note On event.
        case 0x9:
        {
            unsigned char fret = GetFretForMidiNote(data2, str - 1);
            
            if ( (currentTime - guitarController->m_previousPluckTime[str][fret]) >= guitarController->m_minimumInterarrivalTime )
            {
                guitarController->m_previousPluckTime[str][fret] = currentTime;
                
                [guitarController.m_delegate guitarNotesOnFret:fret andString:str withVelocity:data3];
                [guitarController notifyObserversGuitarNotesOnFret:fret andString:str withVelocity:data3];

            }
            else
            {
                NSLog(@"Dropping double-triggered note: %f secs", (currentTime - guitarController->m_previousPluckTime[str][fret]));
            }
            
        } break;
            
        // Control Channel Message
        case 0xB:
        {            
            unsigned char gTarMsgType = data2;                    
            
            switch (gTarMsgType)
            {
                case RX_FRET_UP: {
                    // Fret Up
                    [guitarController.m_delegate guitarFretUp:data3 atString:str];
                    [guitarController notifyObserversGuitarFretUp:data3 andString:str];
                } break;
                
                case RX_FRET_DOWN: {
                    // Fret Down
                    [guitarController.m_delegate guitarFretDown:data3 atString:str];
                    [guitarController notifyObserversGuitarFretDown:data3 andString:str];
                } break;
                    
                case RX_FW_VERSION: {
                    // Current Version Number
                    unsigned char majorVersion = (data3 & 0xF0) >> 4;
                    unsigned char minorVersion = (data3 & 0x0F);
                    [guitarController.m_delegate ReceivedFWVersion:(int)majorVersion andMinorVersion:(int)minorVersion];
                } break;
                    
                case RX_FW_UPDATE_ACK: {
                    // Firmware Ack
                    unsigned char status = data3;
                    [guitarController.m_delegate RxFWUpdateACK:status];
                } break;
                
                case RX_BATTERY_STATUS: {
                    // Battery status Ack
                    unsigned char battery = data3;
                    [guitarController.m_delegate RxBatteryStatus:(BOOL)battery];
                } break;
                    
                case RX_BATTERY_CHARGE: {
                    // Battery charge Ack
                    unsigned char percentage = data3;
                    [guitarController.m_delegate RxBatteryCharge:percentage];
                } break;
            }
        
            
        } break;
            
        default:
        {
            NSLog(@"Unhandled midi msg of type 0x%x", MsgType);
            return -1;
        } break;
    }
    
    return 0;
}

void CoreMidiConnectionChangeCallback(BOOL fConnected, void *pContext)
{

    // pContext is a pointer to the objective c object, 'to bridge the gap'.
    GuitarController *guitarController = (GuitarController*)pContext;
    
    // update the delegate as to what has happened
    if ( fConnected == true )
    {
        guitarController.m_connected = YES;
        [guitarController.m_delegate guitarConnected];
        [guitarController notifyObserversGuitarConnected];
        NSLog(@"GuitarController: CoreMidiInterface connected!");
    }
    else
    {
        guitarController.m_connected = NO;
        [guitarController.m_delegate guitarDisconnected];
        [guitarController notifyObserversGuitarDisconnected];
        NSLog(@"GuitarController: CoreMidiInterface disconnected!");
    }
    
}

#pragma mark - Observer management

- (void)debugSpoofConnected
{
    // Pretend we are connected for debug purposes
    m_connected = YES;
    m_spoofed = YES;
    
    [m_delegate guitarConnected];
    
    [self notifyObserversGuitarConnected];
    
}

- (void)debugSpoofDisconnected
{
    // Pretend we are connected for debug purposes
    m_connected = NO;
    m_spoofed = NO;
    
    [m_delegate guitarDisconnected];
    
    [self notifyObserversGuitarDisconnected];
    
}

// Observers should ultimately replace the delegate paradigm we have going.
// I didn't want to rip out the delegate functionality since we use it all
// over the place, but new stuff will need to use the observer model.
- (RESULT)addObserver:(id<GuitarControllerObserver>)observer
{
    RESULT r = R_NO_ISSUE;
    
    // We don't want the observers to be retained to prevent circular dependendcies.
    // We need to make sure we dont retain the object.
    NSValue * nonretainedObserver = [NSValue valueWithNonretainedObject:observer];
    
    CNRM_NA(observer, @"addObserver: Observer is nil");
    
    //
    // We don't want to add the same observer twice.
    //
    if ( [m_observerList containsObject:nonretainedObserver] == NO )
    {
        [m_observerList addObject:nonretainedObserver];
        
        // If the guitar is already connected, we should let this new guy know.
        if ( m_connected == YES && [observer respondsToSelector:@selector(guitarConnected)] == YES )
        {
            [observer guitarConnected];
        }
    }
    
Error:
    return r;
}

- (RESULT)removeObserver:(id<GuitarControllerObserver>)observer
{
    RESULT r = R_NO_ISSUE;
    
    // We don't want the observers to be retained to prevent circular dependendcies.
    // We need to make sure we dont retain the object.
    NSValue * nonretainedObserver = [NSValue valueWithNonretainedObject:observer];
    
    CNRM_NA(observer, @"removeObserver: Observer is nil");
    
    [m_observerList removeObject:nonretainedObserver];
    
Error:
    return r;
}

// Notifying observers
- (void)notifyObserversGuitarFretDown:(GuitarFret)fret andString:(GuitarString)str
{
//    for ( id<GuitarControllerObserver> observer in m_observerList )
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarFretDown:andString:)] == YES )
        {
            [observer guitarFretDown:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarFretUp:(GuitarFret)fret andString:(GuitarString)str
{
//    for ( id<GuitarControllerObserver> observer in m_observerList )
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarFretUp:andString:)] == YES )
        {
            [observer guitarFretUp:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarNotesOnFret:(GuitarFret)fret andString:(GuitarString)str withVelocity:(int)velocity
{
//    for ( id<GuitarControllerObserver> observer in m_observerList )
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarNotesOnFret:andString:withVelocity:)] == YES )
        {
            [observer guitarNotesOnFret:fret andString:str withVelocity:velocity];
        }
    }
}

- (void)notifyObserversGuitarNotesOffFret:(GuitarFret)fret andString:(GuitarString)str
{
//    for ( id<GuitarControllerObserver> observer in m_observerList )
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarNotesOffFret:andString:)] == YES )
        {
            [observer guitarNotesOffFret:fret andString:str];
        }
    }
}

- (void)notifyObserversGuitarConnected
{
//    for ( id<GuitarControllerObserver> observer in m_observerList )
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarConnected)] == YES )
        {
            [observer guitarConnected];
        }
    }
}

- (void)notifyObserversGuitarDisconnected
{
//    for ( id<GuitarControllerObserver> observer in m_observerList )
    for ( NSValue * nonretainedObserver in m_observerList )
    {
        id observer = [nonretainedObserver nonretainedObjectValue];
        
        if ( [observer respondsToSelector:@selector(guitarDisconnected)] == YES )
        {
            [observer guitarDisconnected];
        }
    }
}

#pragma mark - LED manipulation

- (RESULT)turnOffAllLeds
{
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"turnOffAllLeds: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendSetLEDState(0,0,0,0,0,0), @"turnOffAllLeds: SendSetLEDState failed");
    }
    
Error:
    return r;
}

- (RESULT) turnOffLedAtString:(GuitarString)str andFret:(GuitarFret)fret
{
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"turnOffLedAtStr: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendSetLEDState(fret, str,0,0,0,0), @"turnOffLedAtStr: SendSetLEDState failed");
    }
    
Error:
    return r;
}

- (RESULT)turnOnLedAtString:(GuitarString)str andFret:(GuitarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"turnOnLedAtStr: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendSetLEDState(fret, str, red, green, blue, 0), @"turnOnLedAtStr: SendSetLEDState failed");
    }
    
Error:
    return r;
}

- (RESULT)turnOnLedWithColorMappingAtString:(GuitarString)str andFret:(GuitarFret)fret
{
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        if( str == 0 )
        {
            // turn on all strings using their specified color mapping
            CVPM_NA(m_coreMidiInterface, @"turnOnLedWithColorMappingAtString: CoreMidiInterface is invalid");

            for( int s = 0; s < GUITAR_CONTROLLER_STRING_COUNT; s++ )
            {
                CRM_NA(m_coreMidiInterface->SendSetLEDState(fret, (s+1), 
                                                            m_stringColorMapping[s][0], 
                                                            m_stringColorMapping[s][1],
                                                            m_stringColorMapping[s][2],
                                                            0), 
                       @"turnOnLedWithColorMappingAtString: SendSetLEDState failed");
            }
        }
        else
        {
            // subtract one to zero-base the string
            CVPM_NA(m_coreMidiInterface, @"turnOnLedWithColorMappingAtString: CoreMidiInterface is invalid");
            CRM_NA(m_coreMidiInterface->SendSetLEDState(fret, str, m_stringColorMapping[str-1][0], 
                                                                   m_stringColorMapping[str-1][1],
                                                                   m_stringColorMapping[str-1][2],
                                                                   0), 
                        @"turnOnLedWithColorMappingAtString: SendSetLEDState failed");
        }
    }
    
Error:
    return r;
    
}

- (RESULT)sendNoteMsg:(unsigned char)midiVal channel:(unsigned char)channel withVelocity:(unsigned char)midiVel andType:(const char *)pszOnOff
{
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"sendNoteMsg: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendNoteMsg(channel, midiVal, midiVel, pszOnOff), @"sendNoteMsg: SendNoteMsg failed!");
    }
    
Error:
    return r;
}

#pragma mark - CC Style LED Manipulation

- (RESULT)ccTurnOffAllLeds {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"ccTurnOffAllLeds: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendCCSetLEDState(0,0,0,0,0,0), @"ccTurnOffAllLeds: SendSetLEDState failed");
    }
    
Error:
    return r;
}

- (RESULT)ccTurnOffLedAtString:(GuitarString)str andFret:(GuitarFret)fret {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"ccTurnOffLedAtStr: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendCCSetLEDState(fret, str,0,0,0,0), @"ccTurnOffLedAtStr: SendSetLEDState failed");
    }
    
Error:
    return r;
}

- (RESULT)ccTurnOnLedAtString:(GuitarString)str andFret:(GuitarFret)fret withRed:(char)red andGreen:(char)green andBlue:(char)blue {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"ccTurnOnLedAtStr: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendCCSetLEDState(fret, str, red, green, blue, 0), @"ccTurnOnLedAtStr: SendSetLEDState failed");
    }
    
Error:
    return r;
}

- (RESULT)ccTurnOnLedWithColorMappingAtString:(GuitarString)str andFret:(GuitarFret)fret {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"ccTurnOnLedAtStr: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendCCSetLEDState(fret, str,
                                                      m_stringColorMapping[str-1][0],
                                                      m_stringColorMapping[str-1][1],
                                                      m_stringColorMapping[str-1][2],
                                                      0), @"ccTurnOnLedAtStr: SendSetLEDState failed");
    }
    
Error:
    return r;
}

#pragma mark - Requests 
- (RESULT) SendRequestBatteryStatus {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"SendRequestBatteryStatus: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendRequestBatteryStatus(), @"SendRequestBatteryStatus: SendRequestBatteryStatus failed");
    }
    
Error:
    return r;
}

- (RESULT) SendEnableDebug {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"SendEnableDebug: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendEnableDebug(), @"SendEnableDebug: SendEnableDebug failed");
    }
    
Error:
    return r;
}

- (RESULT) SendDisableDebug {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"SendDisableDebug: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendDisableDebug(), @"SendDisableDebug: SendDisableDebug failed");
    }
    
Error:
    return r;
}

- (RESULT) SendRequestFirmwareVersion {
    RESULT r = R_NO_ISSUE;
    
    if ( m_spoofed == NO )
    {
        CVPM_NA(m_coreMidiInterface, @"SendRequestFirmwareVersion: CoreMidiInterface is invalid");
        CRM_NA(m_coreMidiInterface->SendRequestFirmwareVersion(), @"SendRequestFirmwareVersion: SendRequestFirmwareVersion failed");
    }
    
Error:
    return r;
}

- (RESULT) SendFirmwarePackagePage:(void *)pBuffer bufferSize:(int)pBuffer_n fwSize:(int)fwSize 
                           fwPages:(int)fwPages curPage:(int)curPage withCheckSum:(unsigned char)checkSum
{
    RESULT r = R_NO_ISSUE;
    
    //CVPM_NA(m_coreMidiInterface, @"SendFirmwarePackagePage: CoreMidiInterface is invalid");
    
    r = m_coreMidiInterface->SendFirmwarePackagePage((unsigned char *)pBuffer, pBuffer_n, fwSize, fwPages, curPage, checkSum);
    CRM_NA(r, @"SendFirmwarePackagePage: Failed to send firmware package page");
    
Error:
    return r = R_NO_ISSUE;
}

#pragma mark - Color mapping manipulation

- (void)setStringsColorMapping:(char**)colorMap
{
    
    for ( GuitarString str = 0; str < GUITAR_CONTROLLER_STRING_COUNT; str++ )
    {
        [self setStringColorMapping:str toRed:colorMap[str][0] andGreen:colorMap[str][1] andBlue:colorMap[str][2]];
    }
    
}

- (void)setStringColorMapping:(GuitarString)str toRed:(char)red andGreen:(char)green andBlue:(char)blue
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

- (RESULT)turnOffAllEffects
{
    
    NSLog(@"Turning off all effects");

    RESULT r = R_NO_ISSUE;
    
    CRM_NA(m_coreMidiInterface->SendSetFretFollow( 0, 0, 0 ), @"setEffectColor: SendSetFretFollow failed!");
    CRM_NA(m_coreMidiInterface->SendSetNoteActive( 0, 0, 0 ), @"setEffectColor: SendSetNoteActive failed!");
    
Error:
    return r;

}

- (RESULT)setEffectColor:(GuitarControllerEffect)effect toRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    
    RESULT r = R_NO_ISSUE;
    
    switch ( effect ) 
    {
            
        case GuitarControllerEffectFretFollow:
        {
            
            CRM_NA(m_coreMidiInterface->SendSetFretFollow( red, green, blue ), @"setEffectColor: SendSetFretFollow failed!");
            
        } break;
            
        case GuitarControllerEffectNoteActive:
        {
            
            CRM_NA(m_coreMidiInterface->SendSetNoteActive( red, green, blue ), @"setEffectColor: SendSetNoteActive failed!");
            
        } break;
        
        default:
        {
            
            // nothing
            
        } break;
    }

Error:
    return r;
    
}

#if 0

// You can independantly set FF and NA with respective enum
// or set both together with the FF+NA enum.
- (void)setEffectColor:(GuitarControllerEffect)effect toRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    
    switch ( effect ) 
    {
            
        default:
        case GuitarControllerEffectNone:
        {
            // nothing to do
            return;
        } break;
            
        case GuitarControllerEffectFretFollow:
        {
            m_effectColorFF[0] = red;
            m_effectColorFF[1] = green;
            m_effectColorFF[2] = blue;
        } break;
            
        case GuitarControllerEffectNoteActive:
        {
            m_effectColorNA[0] = red;
            m_effectColorNA[1] = green;
            m_effectColorNA[2] = blue;
        } break;
            
        case GuitarControllerEffectFretFollowNoteActive:
        {
            m_effectColorFF[0] = red;
            m_effectColorFF[1] = green;
            m_effectColorFF[2] = blue;
            
            m_effectColorNA[0] = red;
            m_effectColorNA[1] = green;
            m_effectColorNA[2] = blue;
        } break;
            
        case GuitarControllerEffectLightningMode:
        {
            m_effectColorLM[0] = red;
            m_effectColorLM[1] = green;
            m_effectColorLM[2] = blue;
        } break;
            
    }
    
    // reset the effect with the new color
    [self setGuitarControllerEffect:m_currentGuitarEffect];
    
}

- (void)setEffectColorRed:(char)red andGreen:(char)green andBlue:(char)blue
{
    [self setEffectColor:m_currentGuitarEffect toRed:red andGreen:green andBlue:blue];
}

- (void)setGuitarControllerEffect:(GuitarControllerEffect)effect
{
    // TODO
#if 0
    // clear out any existing effects
    m_guitarInterface->DisableEffects();

    switch ( effect ) 
    {
        
        default:
        case GuitarControllerEffectNone:
        {
//            m_guitarInterface->DisableEffects();
        } break;
            
        case GuitarControllerEffectFretFollow:
        {
            m_guitarInterface->ChangeFretFollowColor( m_effectColorFF[0], m_effectColorFF[1], m_effectColorFF[2] );
        } break;
            
        case GuitarControllerEffectNoteActive:
        {
            m_guitarInterface->ChangeNoteActiveColor( m_effectColorNA[0], m_effectColorNA[1], m_effectColorNA[2] );
        } break;
            
        case GuitarControllerEffectFretFollowNoteActive:
        {
            m_guitarInterface->ChangeFretFollowColor( m_effectColorFF[0], m_effectColorFF[1], m_effectColorFF[2] );
            m_guitarInterface->ChangeNoteActiveColor( m_effectColorNA[0], m_effectColorNA[1], m_effectColorNA[2] );
        } break;
            
        case GuitarControllerEffectLightningMode:
        {
            m_guitarInterface->ChangeLightningColor( m_effectColorLM[0], m_effectColorLM[1], m_effectColorLM[2] );
        } break;

    }
#endif
    m_currentGuitarEffect = effect;
    
}

#endif

@end
