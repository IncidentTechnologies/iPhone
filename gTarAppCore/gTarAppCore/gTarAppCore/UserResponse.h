//
//  UserResponse.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/6/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserRequest.h"

typedef enum
{
    UserResponseStatusUnknown = 0,
    UserResponseStatusSuccess = 1,
    UserResponseStatusFailure = 2
} UserResponseStatus;

@interface UserResponse : NSObject
{
    
    UserRequest * m_userRequest;
    
    UserResponseStatus m_status;
    
    NSString * m_statusText;
    
    NSArray * m_searchResults;
    
    BOOL m_loggedIn;
    
}

@property (nonatomic, readonly) UserRequest * m_userRequest;
@property (nonatomic, assign) UserResponseStatus m_status;
@property (nonatomic, retain) NSString * m_statusText;
@property (nonatomic, retain) NSArray * m_searchResults;
@property (nonatomic, assign) BOOL m_loggedIn;

- (id)initWithUserRequest:(UserRequest*)userRequest;

@end
