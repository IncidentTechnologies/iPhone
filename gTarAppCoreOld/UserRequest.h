//
//  UserRequest.h
//  gTarAppCore
//
//  Created by Joel Greenia on 3/6/12.
//  Copyright (c) 2012 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

enum UserRequestType
{
    UserRequestTypeUnknown = 0,
    UserRequestTypeSignup,
    UserRequestTypeLogin,
    UserRequestTypeLoginFacebookToken,
    UserRequestTypeLoginCookie,
    UserRequestTypeLogout,
    UserRequestTypeUserProfile,
    UserRequestTypeUserProfileEdit,
    UserRequestTypeUserProfileSearch,
    UserRequestTypeUserSessions,
    UserRequestTypeUserGlobalSessions,
    UserRequestTypeAddUserFollow,
    UserRequestTypeRemoveUserFollow,
    UserRequestTypeUserFollowsSessions,
    UserRequestTypeUserFollows,
    UserRequestTypeUserFollowed,
    UserRequestTypeUserFacebookFriends,
    UserRequestTypeUserSongSessionUpload
};

@interface UserRequest : NSObject
{
    
    id m_callbackObject;
    SEL m_callbackSelector;
    
    UserRequestType m_type;
    
}

@property (nonatomic, readonly) id m_callbackObject;
@property (nonatomic, readonly) SEL m_callbackSelector;

- (id)initWithType:(UserRequestType)type;
- (id)initWithType:(UserRequestType)type andCallbackObject:(id)obj andCallbackSelector:(SEL)sel;

@end
