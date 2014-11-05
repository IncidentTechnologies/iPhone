//
//  OphoController.h
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OphoCloudController.h"
#import "UserSession.h"

@class CloudResponse;

@protocol OphoLoginDelegate <NSObject>
    - (void) OnLoggedIn;
    - (void) OnLoginFail: (NSString *)error;
@end

@interface OphoController : NSObject {
    OphoCloudController *m_ophoCloudController;
    UserSession *m_userSession;
}

@property (weak, nonatomic) id <OphoLoginDelegate> loginDelegate;

- (void)loginWithUsername:(NSString *)username password:(NSString *)password;
- (void)loginCallback:(CloudResponse *)cloudResponse;

- (OphoCloudController *) GetCloudController;

@end
