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
}

@property (nonatomic, retain) UserProfile * m_userProfile;
@property (nonatomic, retain) NSArray * m_followsList;
@property (nonatomic, retain) NSArray * m_followedByList;
@property (nonatomic, retain) NSArray * m_sessionsList;
@property (nonatomic, retain) NSArray * m_followsSessionsList;
@property (nonatomic, retain) NSArray * m_facebookFriendsList;

@end
