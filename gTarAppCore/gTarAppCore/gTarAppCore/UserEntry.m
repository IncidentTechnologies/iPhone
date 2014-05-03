//
//  UserEntry.m
//  gTarAppCore
//
//  Created by Marty Greenia on 11/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "UserEntry.h"


@implementation UserEntry

@synthesize m_userProfile;
@synthesize m_followsList;
@synthesize m_followedByList;
@synthesize m_sessionsList;
@synthesize m_followsSessionsList;
@synthesize m_facebookFriendsList;
@synthesize m_sessionsListCurrentPage;

// Encode an object to an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
    
    [coder encodeObject:m_userProfile forKey:@"UserProfile"];
    [coder encodeObject:m_followsList forKey:@"FollowsList"];
    [coder encodeObject:m_followedByList forKey:@"FollowedByList"];
    [coder encodeObject:m_sessionsList forKey:@"SessionList"];
    [coder encodeObject:m_followsSessionsList forKey:@"FollowsSessionsList"];
    [coder encodeObject:m_facebookFriendsList forKey:@"FacebookFriendsList"];
    [coder encodeInteger:m_sessionsListCurrentPage forKey:@"SessionListCurrentPage"];
    
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
    
    self = [super init];
    
    if ( self != nil )
    {
        self.m_userProfile = [coder decodeObjectForKey:@"UserProfile"];
        self.m_followsList = [coder decodeObjectForKey:@"FollowsList"];
        self.m_followedByList = [coder decodeObjectForKey:@"FollowedByList"];
        self.m_sessionsList = [coder decodeObjectForKey:@"SessionList"];
        self.m_followsSessionsList = [coder decodeObjectForKey:@"FollowsSessionsList"];
        self.m_facebookFriendsList = [coder decodeObjectForKey:@"FacebookFriendsList"];
        self.m_sessionsListCurrentPage = [coder decodeIntegerForKey:@"SessionListCurrentPage"];
    }
    
    return self;
    
}


@end
