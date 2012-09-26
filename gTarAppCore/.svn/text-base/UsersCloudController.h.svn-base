//
//  UsersCloudController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 4/11/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserProfile.h"

@protocol UsersCloudControllerDelegate

- (void)usersCloudControllerRequestFailed:(id)usersCloudController;
- (void)usersCloudController:(id)usersCloudController receivedUserProfile:(UserProfile*)userProfile;

@end

@interface UsersCloudController : NSObject
{

}

//- (id)initWithCloudAuthenticator:(CloudAuthenticator*)cloudAuthenticator;

- (void)requestUserProfile;

@end
