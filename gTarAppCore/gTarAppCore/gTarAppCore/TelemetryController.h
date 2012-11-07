//
//  TelemetryController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 7/5/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CloudController;
@class CloudResponse;

typedef enum
{
    TelemetryControllerMessageTypeUnknown = 0,
    TelemetryControllerMessageTypeError,
    TelemetryControllerMessageTypeWarning,
    TelemetryControllerMessageTypeInfo
} TelemetryControllerMessageType;

@interface TelemetryController : NSObject
{
    CloudController * m_cloudController;
    
    NSString * m_compileDate;
    NSString * m_appName;
    NSString * m_appVersion;
    NSString * m_deviceId;
    
    NSString * m_telemetryFilePath;
    
    NSMutableArray * m_messageQueue;
    
    NSString * m_pendingUpload;
    
    NSInteger m_droppedMessages;
}

@property (nonatomic, retain) NSString * m_compileDate;
@property (nonatomic, retain) NSString * m_appName;
@property (nonatomic, retain) NSString * m_appVersion;
@property (nonatomic, retain) NSString * m_deviceId;


- (id)initWithCloudController:(CloudController*)cloudController;

- (void)logMessage:(NSString*)message withType:(TelemetryControllerMessageType)type;

- (void)addMessageToQueue:(NSString*)message;

- (void)uploadLogMessages;
- (void)resumeUploadLogMessages;
- (void)uploadLogMessagesComplete:(CloudResponse*)cloudResponse;
- (void)synchronize;

@end
