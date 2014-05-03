//
//  UserEntry.h
//  gTarAppCore
//
//  Created by Marty Greenia on 11/3/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserProfile;

@interface UserEntry : NSObject <NSCoding>
{
    UserProfile * m_userProfile;
    NSArray * m_followsList;
    NSArray * m_followedByList;
    NSArray * m_sessionsList;
    NSArray * m_followsSessionsList;
    NSArray * m_facebookFriendsList;
    NSInteger m_sessionsListCurrentPage;
}

@property (nonatomic, strong) UserProfile * m_userProfile;
@property (nonatomic, strong) NSArray * m_followsList;
@property (nonatomic, strong) NSArray * m_followedByList;
@property (nonatomic, strong) NSArray * m_sessionsList;
@property (nonatomic, strong) NSArray * m_followsSessionsList;
@property (nonatomic, strong) NSArray * m_facebookFriendsList;
@property (nonatomic, assign) NSInteger m_sessionsListCurrentPage;
@end
