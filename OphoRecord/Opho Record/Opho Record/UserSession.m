//
//  UserSession.m
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "UserSession.h"
#import "CloudResponse.h"
#import "CloudRequest.h"
#import "UserProfile.h"

@implementation UserSession {
    NSString * m_userFilePath;
}

- (id)initWithCloudResponse:(CloudResponse*)cloudResponse {
    self = [super init];
    
    if(self) {
        // Set up vars from cloudResponse
        m_userId = cloudResponse.m_responseUserId;
        m_username = cloudResponse.m_cloudRequest.m_username;
        m_password = cloudResponse.m_cloudRequest.m_password;
        m_email = cloudResponse.m_cloudRequest.m_email;
        m_userProfile = cloudResponse.m_responseUserProfile;
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * pathsDirectory = [paths objectAtIndex:0];
        m_userFilePath = [pathsDirectory stringByAppendingPathComponent:@"User"];
        
        // Ensure the directory exists
        NSError * err = NULL;
        [[NSFileManager defaultManager] createDirectoryAtPath:m_userFilePath withIntermediateDirectories:YES attributes:nil error:&err];
        
        [self uncache];
    }
    
    return self;
}

- (void)cache {
    [self performSelectorInBackground:@selector(saveCache) withObject:nil];
}

- (void)saveCache {
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    [NSKeyedArchiver archiveRootObject:m_username toFile:usernamePath];
    [NSKeyedArchiver archiveRootObject:m_password toFile:passwordPath];
}

- (void)uncache {
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    m_username = [NSKeyedUnarchiver unarchiveObjectWithFile:usernamePath];
    m_password = [NSKeyedUnarchiver unarchiveObjectWithFile:passwordPath];
}

- (void)clear {
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    
    // Clear the cached items
    NSError * err = NULL;
    [[NSFileManager defaultManager] removeItemAtPath:usernamePath error:&err];
    [[NSFileManager defaultManager] removeItemAtPath:passwordPath error:&err];
    
    m_username = nil;
    m_password = nil;
    m_email = nil;
    m_userId = 0;
    //m_userProfile = nil;
}

@end
