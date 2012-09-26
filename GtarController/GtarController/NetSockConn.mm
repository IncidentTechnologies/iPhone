//
//  NetSockConn.m
//  gTarGuitarInterface
//
//  Created by Idan Beck on 12/8/11.
//  Copyright (c) 2011 IncidentTech. All rights reserved.
//

#import "NetSockConn.h"
#import "GtarControllerInternal.h"

@implementation NetSockConn

@synthesize m_pGuitarController;
@synthesize m_fSockConnected;

- (id)init
{
    self = [super init];
    
    if (self) 
    {
        m_pGuitarController = NULL;
        m_fSockConnected = false;
        m_fPendingConnection = false;
        m_pInputStream = NULL;
        m_pOutputStream = NULL;
    }
    
    return self;
    
}

- (void)dealloc
{
    if ( m_fSockConnected == true )
        [self disconnect];
    
    [super dealloc];
}

- (RESULT) disconnect 
{
    m_fSockConnected = false;
    
    [m_pInputStream close];
    [m_pInputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [m_pInputStream release];
    m_pInputStream = NULL;
    
    [m_pOutputStream close];
    [m_pOutputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [m_pOutputStream release];
    m_pOutputStream = NULL;
    
    return R_NO_ISSUE;
}

- (RESULT) initNetworkCommunication:(NSString *)pstrHost atPort:(UInt32)portNumber 
{
    RESULT r = R_NO_ISSUE;
    
    if(m_fPendingConnection)
        return R_ERROR;
    
    m_portNumber = portNumber;
    
    // Create input/output streams to host
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)pstrHost, m_portNumber, &readStream, &writeStream);
    
    if(readStream == NULL || writeStream == NULL)
        return R_ERROR;
    
    // assign to NSStream objects
    m_pInputStream = (NSInputStream *)readStream;
    m_pOutputStream = (NSOutputStream *)writeStream;
    
    [m_pInputStream setDelegate:self];
    [m_pOutputStream setDelegate:self];
    
    [m_pInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [m_pOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [m_pInputStream open];
    [m_pOutputStream open];
    
    NSStreamStatus inStat = [m_pInputStream streamStatus];
    NSStreamStatus outStat = [m_pOutputStream streamStatus];
    
    if(inStat == NSStreamStatusError || outStat == NSStreamStatusError)
        return R_ERROR;
    
    m_fPendingConnection = true;
    
Error:
    return r;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode 
{
    switch(eventCode)
    {
        case NSStreamEventNone: {
            // No event
        } break;
            
        case NSStreamEventOpenCompleted: {
            // Stream opened 
            m_fSockConnected = true;
            m_fPendingConnection = false;
            
            if(m_pGuitarController != NULL)
                [m_pGuitarController.m_delegate SocketConnected];
        } break;
            
        case NSStreamEventHasBytesAvailable: {
            if(aStream == m_pInputStream) 
            {
                while([m_pInputStream hasBytesAvailable]) 
                {
                    int pBuffer_n = 1024;
                    uint8_t *pBuffer = new uint8_t[pBuffer_n];
                    int BytesRead;

                    BytesRead = [m_pInputStream read:pBuffer maxLength:pBuffer_n];
                    if(BytesRead > 0)
                        if(m_pGuitarController != NULL)
                            [m_pGuitarController.m_delegate SocketRxBytes:[[NSString alloc] initWithBytes:pBuffer length:pBuffer_n encoding:NSASCIIStringEncoding]];
                    else
                        NSLog(@"NetSockConn: Error on read with %d bytes read", BytesRead);
                    
                    delete pBuffer;
                    pBuffer = NULL;
                }
            }
        } break;
            
        case NSStreamEventHasSpaceAvailable: {
            
        } break;
            
        case NSStreamEventErrorOccurred: {
            // Failed to connect to host
            m_fSockConnected = false;
            m_fPendingConnection = false;
            
            if(m_pGuitarController != NULL)
                [m_pGuitarController.m_delegate SocketConnectionError];
        } break;
            
        case NSStreamEventEndEncountered: {
            m_fSockConnected = false;
            m_fPendingConnection = false;
            
            if(m_pGuitarController != NULL)
                [m_pGuitarController.m_delegate SocketDisconnected];
        } break;
    }
}

- (RESULT) SendString:(char *)pszString 
{
    NSUInteger strLength = (NSUInteger)strlen(pszString);
    NSInteger bytesWritten = [m_pOutputStream write:(const unsigned char*)pszString maxLength:strLength];
    
    if(bytesWritten <= 0) 
        return R_ERROR;
    else 
        return R_NO_ISSUE;
}

- (RESULT) SendNSString:(NSString *)pstr 
{	    
    [pstr retain];
    
    if(!m_fSockConnected)
        return R_ERROR;
    
    NSData *data = [[NSData alloc] initWithData:[pstr dataUsingEncoding:NSASCIIStringEncoding]];
    [data retain];
    
    NSInteger bytesWritten = [m_pOutputStream write:(unsigned char *)[data bytes] maxLength:[data length]];
    [data release];
  
    [pstr release];
    
    if(bytesWritten <= 0) 
        return R_ERROR;
    else 
        return R_NO_ISSUE;
}



@end
