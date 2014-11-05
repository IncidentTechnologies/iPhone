//
//  UserSession.h
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CloudResponse;
@class UserProfile;

@interface UserSession : NSObject {
    NSInteger m_userId;
    NSString * m_username;
    NSString * m_password;
    NSString * m_email;
    UserProfile * m_userProfile;
}

- (id)initWithCloudResponse:(CloudResponse*)cloudResponse;

- (void)cache;
- (void)uncache;
- (void)saveCache;
- (void)clear;

@end
