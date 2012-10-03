//
//  UserResponse.m
//  gTarAppCore
//
//  Created by Joel Greenia on 3/6/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import "UserResponse.h"

@class UserRequest;

@implementation UserResponse

@synthesize m_userRequest;
@synthesize m_status;
@synthesize m_statusText;
@synthesize m_searchResults;
@synthesize m_loggedIn;

- (id)initWithUserRequest:(UserRequest*)userRequest
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_userRequest = [userRequest retain];
    
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_userRequest release];
    [m_statusText release];
    [m_searchResults release];
    
    [super dealloc];
    
}

@end
