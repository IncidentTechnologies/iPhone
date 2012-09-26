//
//  NetSockConn.h
//  gTarGuitarInterface
//
//  Created by Idan Beck on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <list>
#include "RESULT.h"
#include "valid.h"

@class GuitarController;

@interface NetSockConn : NSObject <NSStreamDelegate>
{
    UInt32 m_portNumber;    
    NSInputStream *m_pInputStream;
    NSOutputStream *m_pOutputStream;
    
@public
    bool m_fSockConnected;
    bool m_fPendingConnection;
    
    GuitarController *m_pGuitarController;
}

@property (nonatomic, assign) GuitarController *m_pGuitarController;
@property (nonatomic, readwrite) bool m_fSockConnected;

- (RESULT) initNetworkCommunication:(NSString *)pstrHost atPort:(UInt32)portNumber;
- (RESULT) disconnect;

- (RESULT) SendString:(char *)pszString;
- (RESULT) SendNSString:(NSString *)pstr;

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;

@end
