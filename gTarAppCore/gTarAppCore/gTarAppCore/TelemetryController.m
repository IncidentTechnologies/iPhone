//
//  TelemetryController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 7/5/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import "TelemetryController.h"

#import "CloudController.h"
#import "CloudResponse.h"

#define MAX_QUEUE_SIZE 999
#define UPLOAD_BATCH_SIZE MAX_QUEUE_SIZE

@implementation TelemetryController

@synthesize m_compileDate;
@synthesize m_appName;
@synthesize m_appVersion;
@synthesize m_deviceId;

- (id)initWithCloudController:(CloudController*)cloudController
{
    
    self = [super init];
    
    if ( self )
    {
        m_droppedMessages = 0;
        
        m_cloudController = [cloudController retain];
        
        m_compileDate = @"default";
        m_appName = @"default";
        m_appVersion = @"default";
        m_deviceId = @"default";
        
        // Create a little place to store our content stuff
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * pathsDirectory = [paths objectAtIndex:0];
        NSString * telemetryPath = [pathsDirectory stringByAppendingPathComponent:@"Telemetry"];
        
        m_telemetryFilePath = [telemetryPath retain];
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:m_telemetryFilePath] == NO )
        {
            
            NSError * error = nil;
            
            // Create the content folder
            [[NSFileManager defaultManager] createDirectoryAtPath:m_telemetryFilePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if ( error != nil )
            {
                NSLog(@"Error: '%@' creating Telemetry path: '%@'", [error localizedDescription], m_telemetryFilePath);
                
                [self release];
                
                return nil;
            }
            
        }
        
        // Try to load from cache
        [self loadCache];
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_cloudController release];
    [m_messageQueue release];
    
    [m_compileDate release];
    [m_appName release];
    [m_appVersion release];
    [m_deviceId release];

    [super dealloc];
    
}

#pragma mark - Methods

- (void)logMessage:(NSString*)message
{
    
    NSDate * date = [[NSDate alloc] init];
    NSString * logMessage = [[NSString alloc] initWithFormat:@"%@,%@\n", date, message];
    
    [self addMessageToQueue:logMessage];
    
    [logMessage release];
    [date release];
    
}

//- (void)logMessage:(NSString*)message withType:(TelemetryControllerMessageType)type
//{
//    
//    NSString * logMessage;
//    
//    switch ( type )
//    {
//        case TelemetryControllerMessageTypeError:
//        {
//            logMessage = [NSString stringWithFormat:@"Error: %@", message];
//        } break;
//            
//        case TelemetryControllerMessageTypeWarning:
//        {
//            logMessage = [NSString stringWithFormat:@"Warning: %@", message];
//        } break;
//            
//        case TelemetryControllerMessageTypeInfo:
//        {
//            logMessage = [NSString stringWithFormat:@"Info: %@", message];
//        } break;
//            
//        case TelemetryControllerMessageTypeUnknown:
//        default:
//        {
//            // Its not really a fatal error to not have a message type
//            logMessage = [NSString stringWithFormat:@"Unknown: %@", message];            
//        } break;
//    }
//    
//    [self logMessage:logMessage];
//    
//}

- (void)logEvent:(TelemetryControllerEvent)event withValue:(NSInteger)value andMessage:(NSString*)message
{
    
    NSString * logMessage = [NSString stringWithFormat:@"%@,%u,%@", event, value, message];
    
    [self logMessage:logMessage];
    
}

- (void)addMessageToQueue:(NSString*)message
{
    
    @synchronized(m_messageQueue)
    {
        
        if ( [m_messageQueue count] >= MAX_QUEUE_SIZE )
        {
            // We need to let this message drop
            m_droppedMessages++;
        }
        else
        {
            // Add this message to the end of the queue
            [m_messageQueue addObject:message];
        }
        
    }
}

- (void)uploadLogMessages
{
    
    if ( m_pendingUpload != nil )
    {
        // upload in progress
        [self resumeUploadLogMessages];
        
        return;
    }
    
    if ( [m_messageQueue count] == 0 )
    {
        // nothing to do
        return;
    }
    
    NSMutableString * logsToUpload = [[NSMutableString alloc] init];
    
    @synchronized(m_messageQueue)
    {
        if ( m_droppedMessages > 0 )
        {
            NSDate * date = [[NSDate alloc] init];
            NSString * droppedMessage = [[NSString alloc] initWithFormat:@"%@,%@,%u,%@\n", date, DroppedTelemetryMessages, m_droppedMessages, @"Dropped telemetry messages"];
            
            [m_messageQueue addObject:droppedMessage];
            
            m_droppedMessages = 0;
        }
        
        // We'll use this to remove the log files after we've aggregated them
        NSRange range;
        
        range.location = 0;
        range.length = 0;
        
        for ( NSString * log in m_messageQueue )
        {
            // Build up one log to upload
            [logsToUpload appendString:log];
            
            range.length++;
            
            if ( range.length >= UPLOAD_BATCH_SIZE )
            {
                break;
            }
        }
        
        // Remove these logs from the queue
        [m_messageQueue removeObjectsInRange:range];
        
        m_pendingUpload = [logsToUpload retain];
        
        // Commit this
        [self saveCache];
        
    }
    
    [m_cloudController requestLogUpload:logsToUpload andVersion:m_appVersion andDevice:m_deviceId andApp:m_appName andCallbackObj:self andCallbackSel:@selector(uploadLogMessagesComplete:)];
    
    [logsToUpload release];
    
}

- (void)resumeUploadLogMessages
{
    [m_cloudController requestLogUpload:m_pendingUpload andVersion:m_appVersion andDevice:m_deviceId andApp:m_appName andCallbackObj:self andCallbackSel:@selector(uploadLogMessagesComplete:)];
}

- (void)uploadLogMessagesComplete:(CloudResponse*)cloudResponse
{
    
    @synchronized(m_messageQueue)
    {
        
        if ( cloudResponse.m_status == CloudResponseStatusSuccess )
        {
            
            [m_pendingUpload release];
            
            m_pendingUpload = nil;
            
            [self saveCache];
        }
        else
        {
            NSLog(@"Failed to transfer logs");
        }
        
    }
}

#pragma mark - Caching

- (void)loadCache
{
    
    NSString * logsPath = [m_telemetryFilePath stringByAppendingPathComponent:@"MessageQueue"];
    NSString * droppedPath = [m_telemetryFilePath stringByAppendingPathComponent:@"DroppedMessages"];
    NSString * pendingPath = [m_telemetryFilePath stringByAppendingPathComponent:@"PendingUpload"];
    
    [m_messageQueue release];
    [m_pendingUpload release];
    
    m_messageQueue = [[NSKeyedUnarchiver unarchiveObjectWithFile:logsPath] retain];
    m_droppedMessages = [[NSKeyedUnarchiver unarchiveObjectWithFile:droppedPath] integerValue];
    m_pendingUpload = [[NSKeyedUnarchiver unarchiveObjectWithFile:pendingPath] retain];
    
    if ( m_messageQueue == nil )
    {
        m_messageQueue = [[NSMutableArray alloc] init];
    }
    
}

- (void)saveCache
{
    
    NSString * logsPath = [m_telemetryFilePath stringByAppendingPathComponent:@"MessageQueue"];
    NSString * droppedPath = [m_telemetryFilePath stringByAppendingPathComponent:@"DroppedMessages"];
    NSString * pendingPath = [m_telemetryFilePath stringByAppendingPathComponent:@"PendingUpload"];
    
    [NSKeyedArchiver archiveRootObject:m_messageQueue toFile:logsPath];
    [NSKeyedArchiver archiveRootObject:[NSNumber numberWithInteger:m_droppedMessages] toFile:droppedPath];
    [NSKeyedArchiver archiveRootObject:m_pendingUpload toFile:pendingPath];
    
}

- (void)synchronize
{
    
    @synchronized(m_messageQueue)
    {
        [self saveCache];
    }
    
}

@end
