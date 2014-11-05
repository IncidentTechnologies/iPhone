//
//  OphoController.m
//  Opho Record
//
//  Created by Idan Beck on 11/3/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import "OphoController.h"

#import "CloudRequest.h"
#import "CloudResponse.h"

@implementation OphoController {
    
}

@synthesize loginDelegate;

- (id)init {
    self = [super init];
    if ( self ) {
        m_ophoCloudController = [[OphoCloudController alloc] initWithServer:kServerAddress];
    }
    return self;
}

- (OphoCloudController *) GetCloudController {
    return m_ophoCloudController;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    [m_ophoCloudController requestLoginUsername:username andPassword:password andCallbackObj:self andCallbackSel:@selector(loginCallback:)];
}

- (void)loginCallback:(CloudResponse *)cloudResponse {
    if(cloudResponse.m_status == CloudResponseStatusSuccess){
        m_userSession = [[UserSession alloc] initWithCloudResponse:cloudResponse];
        [loginDelegate OnLoggedIn];
    }
    else{    
        [loginDelegate OnLoginFail:cloudResponse.m_statusText];
        
    }
}


@end
