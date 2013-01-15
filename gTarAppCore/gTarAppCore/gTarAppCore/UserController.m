    
//
//  UserController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 9/14/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "UserController.h"

#import "CloudController.h"
#import "CloudResponse.h"
#import "CloudRequest.h"
#import "UserSongSessions.h"
#import "UserProfiles.h"
#import "UserProfile.h"
#import "UserEntry.h"
#import "UserRequest.h"
#import "UserResponse.h"

@implementation UserController

@synthesize m_loggedInUsername;
@synthesize m_loggedInUserProfile;
@synthesize m_loggedInFacebookToken;

//- (id)init
//{
//    
//    self = [super init];
//    
//    if ( self )
//    {
//        
//        m_userCache = [[NSMutableDictionary alloc] init];
//        m_cloudToUserRequest = [[NSMutableDictionary alloc] init];
//        
//    }
//    
//    return self;
//
//}

- (id)initWithCloudController:(CloudController*)cloudController
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_cloudController = [cloudController retain];
        
        m_cloudToUserRequest = [[NSMutableDictionary alloc] init];
        
        // Create a little place to store our content stuff
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * pathsDirectory = [paths objectAtIndex:0];
        NSString * userPath = [pathsDirectory stringByAppendingPathComponent:@"User"];
        
        m_userFilePath = [userPath retain];
        
        if ( [[NSFileManager defaultManager] fileExistsAtPath:m_userFilePath] == NO )
        {
            
            NSError * error = nil;
            
            // Create the content folder
            [[NSFileManager defaultManager] createDirectoryAtPath:m_userFilePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if ( error != nil )
            {
                NSLog(@"Error: '%@' creating User path: '%@'", [error localizedDescription], m_userFilePath);
                
                [self release];
                
                return nil;
            }
            
        }
        
        // Try to load from cache
        [self loadCache];
        
        // Login with the cached credentials. Try Facebook first.
//        if ( m_loggedInFacebookToken )
//        {
//            [self requestLoginUserFacebookToken:m_loggedInFacebookToken andCallbackObj:nil andCallbackSel:nil];
//        }
//        else if ( m_loggedInUsername && m_loggedInPassword )
//        {
//            [self requestLoginUserCachedCallbackObj:nil andCallbackSel:nil];
//        }
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_loggedInUsername release];
    [m_loggedInPassword release];
    [m_loggedInUserProfile release];
    [m_loggedInFacebookToken release];
    
    [m_cloudController release];
    
    [m_userCache release];
    
    [m_cloudToUserRequest release];
    
    [m_pendingUserSongSessionUploads release];
    
    [super dealloc];
    
}

- (void)clearCache
{
    
    NSLog(@"Clearing the User cache!");
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * pathsDirectory = [paths objectAtIndex:0];
    NSString * userPath = [pathsDirectory stringByAppendingPathComponent:@"User"];
    
    NSError * error = nil;
    
    BOOL result;
    
    // Delete the old cache folder
    result = [[NSFileManager defaultManager] removeItemAtPath:userPath error:&error];
    
    if ( result == NO || error != nil )
    {
        NSLog(@"Failed to delete User cache");
        
        return;
    }
    
    // Now that all the files are deleted, clear the mapping to them.
    [m_loggedInUsername release];
    [m_loggedInPassword release];
    [m_loggedInUserProfile release];
    [m_loggedInFacebookToken release];
    
    [m_userCache release];
    [m_pendingUserSongSessionUploads release];
    
    m_loggedInUsername = nil;
    m_loggedInPassword = nil;
    m_loggedInUserProfile = nil;
    m_loggedInFacebookToken = nil;
    m_pendingUserSongSessionUploads = [[NSMutableArray alloc] init];
    m_userCache = [[NSMutableDictionary alloc] init];
    
    // Create a new cache folder
    result = [[NSFileManager defaultManager] createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if ( result == NO || error != nil )
    {
        NSLog(@"Error creating Cache path: %@", m_userFilePath);
        
        return;
    }
    
    // Note that we don't delete the star/score caches.
    // This will re-save them to disk
    [self saveCache];
}

- (void)loadCache
{
    
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    NSString * userProfilePath = [m_userFilePath stringByAppendingPathComponent:@"UserProfile"];
    NSString * facebookTokenPath = [m_userFilePath stringByAppendingPathComponent:@"FacebookToken"];
    NSString * pendingUploadPath = [m_userFilePath stringByAppendingPathComponent:@"PendingUploads"];
    NSString * userCachePath = [m_userFilePath stringByAppendingPathComponent:@"UserCache"];
    NSString * starCachePath = [m_userFilePath stringByAppendingPathComponent:@"StarCache"];
    NSString * scoreCachePath = [m_userFilePath stringByAppendingPathComponent:@"ScoreCache"];
    
    m_loggedInUsername = [[NSKeyedUnarchiver unarchiveObjectWithFile:usernamePath] retain];
    m_loggedInPassword = [[NSKeyedUnarchiver unarchiveObjectWithFile:passwordPath] retain];
    
//    NSArray * arr = [NSKeyedUnarchiver unarchiveObjectWithFile:userProfilePath];
//    m_loggedInUserProfile = [[arr lastObject] retain];
    m_loggedInUserProfile = [[NSKeyedUnarchiver unarchiveObjectWithFile:userProfilePath] retain];
    
    m_loggedInFacebookToken = [[NSKeyedUnarchiver unarchiveObjectWithFile:facebookTokenPath] retain];
    m_pendingUserSongSessionUploads = [[NSKeyedUnarchiver unarchiveObjectWithFile:pendingUploadPath] retain];
    m_userCache = [[NSKeyedUnarchiver unarchiveObjectWithFile:userCachePath] retain];
    m_starCache = [[NSKeyedUnarchiver unarchiveObjectWithFile:starCachePath] retain];
    m_scoreCache = [[NSKeyedUnarchiver unarchiveObjectWithFile:scoreCachePath] retain];
    
    if ( m_pendingUserSongSessionUploads == nil )
    {
        m_pendingUserSongSessionUploads = [[NSMutableArray alloc] init];
    }
    
    if ( m_userCache == nil )
    {
        m_userCache = [[NSMutableDictionary alloc] init];
    }
    
    if ( m_userCache == nil )
    {
        m_userCache = [[NSMutableDictionary alloc] init];
    }
    
    if ( m_starCache == nil )
    {
        m_starCache = [[NSMutableDictionary alloc] init];
    }
    
    if ( m_scoreCache == nil )
    {
        m_scoreCache = [[NSMutableDictionary alloc] init];
    }
    
}

- (void)saveCache
{
    
    NSString * usernamePath = [m_userFilePath stringByAppendingPathComponent:@"Username"];
    NSString * passwordPath = [m_userFilePath stringByAppendingPathComponent:@"Password"];
    NSString * userProfilePath = [m_userFilePath stringByAppendingPathComponent:@"UserProfile"];
    NSString * facebookTokenPath = [m_userFilePath stringByAppendingPathComponent:@"FacebookToken"];
    NSString * pendingUploadPath = [m_userFilePath stringByAppendingPathComponent:@"PendingUploads"];
    NSString * userCachePath = [m_userFilePath stringByAppendingPathComponent:@"UserCache"];
    NSString * starCachePath = [m_userFilePath stringByAppendingPathComponent:@"StarCache"];
    NSString * scoreCachePath = [m_userFilePath stringByAppendingPathComponent:@"ScoreCache"];
    
    [NSKeyedArchiver archiveRootObject:m_loggedInUsername toFile:usernamePath];
    [NSKeyedArchiver archiveRootObject:m_loggedInPassword toFile:passwordPath];
    
//    [NSKeyedArchiver archiveRootObject:[NSArray arrayWithObject:m_loggedInUserProfile] toFile:userProfilePath];
    [NSKeyedArchiver archiveRootObject:m_loggedInUserProfile toFile:userProfilePath];
    
    [NSKeyedArchiver archiveRootObject:m_loggedInFacebookToken toFile:facebookTokenPath];
    [NSKeyedArchiver archiveRootObject:m_pendingUserSongSessionUploads toFile:pendingUploadPath];
    [NSKeyedArchiver archiveRootObject:m_userCache toFile:userCachePath];
    [NSKeyedArchiver archiveRootObject:m_starCache toFile:starCachePath];
    [NSKeyedArchiver archiveRootObject:m_scoreCache toFile:scoreCachePath];
    
}

- (void)saveCookie:(NSHTTPCookie*)cookie
{
    
    if ( cookie == nil )
    {
        return;
    }
    
    NSDictionary * dict = cookie.properties;
    
    NSString * cookiePath = [m_userFilePath stringByAppendingPathComponent:@"Cookie"];
    
    [NSKeyedArchiver archiveRootObject:dict toFile:cookiePath];
    
}

- (NSHTTPCookie*)loadCookie
{
    
    NSString * cookiePath = [m_userFilePath stringByAppendingPathComponent:@"Cookie"];
    
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithFile:cookiePath];
    
    if ( dict == nil )
    {
        return nil;
    }
    
    NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:dict];
    
    return cookie;
    
}

- (void)requestLoginUserCachedCallbackObj:(id)obj
                           andCallbackSel:(SEL)sel
{
    
    if ( m_loggedInFacebookToken != nil )
    {
        // This variable gets released later on, and we don't want it
        // to disappear before the call returns.
        [m_loggedInFacebookToken retain];
        
        [self requestLoginUserFacebookToken:m_loggedInFacebookToken
                             andCallbackObj:obj
                             andCallbackSel:sel];
        
        [m_loggedInFacebookToken release];
    }
    else
    {
        [self requestLoginUser:m_loggedInUsername
                   andPassword:m_loggedInPassword
                andCallbackObj:obj
                andCallbackSel:sel];
    }
    
}

#pragma mark - Account mgmt

- (void)requestSignupUser:(NSString*)username
              andPassword:(NSString*)password
                 andEmail:(NSString*)email
           andCallbackObj:(id)obj
           andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeSignup
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestRegisterUsername:username
                                                                 andPassword:password
                                                                    andEmail:email
                                                              andCallbackObj:self
                                                              andCallbackSel:@selector(requestSignupUserCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestSignupUserCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        userResponse.m_status = UserResponseStatusSuccess;
        
        [m_loggedInUsername release];
        [m_loggedInPassword release];
        [m_loggedInUserProfile release];
        
        m_loggedInUsername = [cloudResponse.m_cloudRequest.m_username retain];
        m_loggedInPassword = [cloudResponse.m_cloudRequest.m_password retain];
        m_loggedInUserProfile = [cloudResponse.m_responseUserProfile retain];
        
        [self setUserProfileForUserId:0
                            toProfile:m_loggedInUserProfile];
        
        if ( m_loggedInUsername && m_loggedInPassword )
        {
            [self saveCache];
        }

    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestLoginUser:(NSString*)username
             andPassword:(NSString*)password
          andCallbackObj:(id)obj
          andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeLogin
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestLoginUsername:username
                                                              andPassword:password
                                                           andCallbackObj:self
                                                           andCallbackSel:@selector(requestLoginUserCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestLoginUserCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        userResponse.m_status = UserResponseStatusSuccess;
        
        [m_loggedInUsername release];
        [m_loggedInPassword release];
        [m_loggedInUserProfile release];
        
        m_loggedInUsername = [cloudResponse.m_cloudRequest.m_username retain];
        m_loggedInPassword = [cloudResponse.m_cloudRequest.m_password retain];
        m_loggedInUserProfile = [cloudResponse.m_responseUserProfile retain];
        
        [self setUserProfileForUserId:0
                            toProfile:m_loggedInUserProfile];
        
        if ( m_loggedInUsername && m_loggedInPassword )
        {
            [self saveCache];
        }
        
        // Save the cookie before we return
//        NSHTTPCookie * cookie = [m_cloudController getCakePhpCookie];
//        
//        if ( cookie )
//        {
//            [self saveCookie:cookie];
//        }
        
        [self sendPendingUploads];
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestLoginUserFacebookToken:(NSString*)facebookToken andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeLoginFacebookToken
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    [m_loggedInFacebookToken release];
    
    m_loggedInFacebookToken = nil;
    
    CloudRequest * cloudRequest = [m_cloudController requestFacebookLoginWithToken:facebookToken
                                                                    andCallbackObj:self
                                                                    andCallbackSel:@selector(requestLoginUserFacebookTokenCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestLoginUserFacebookTokenCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        userResponse.m_status = UserResponseStatusSuccess;
        
//        [m_loggedInUsername release];
        [m_loggedInUserProfile release];
        [m_loggedInFacebookToken release];
        
//        m_loggedInUsername = [cloudResponse.m_cloudRequest.m_username retain];
        m_loggedInUserProfile = [cloudResponse.m_responseUserProfile retain];
        m_loggedInFacebookToken = [cloudResponse.m_cloudRequest.m_facebookAccessToken retain];
        
        [self setUserProfileForUserId:0
                            toProfile:m_loggedInUserProfile];
        
        if ( m_loggedInUsername )
        {
            [self saveCache];
        }
        
        [self sendPendingUploads];
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];

}

- (void)requestLoginUserCookieCallbackObj:(id)obj
                           andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeLoginCookie
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    // Load the cookie before we begin
    NSHTTPCookie * cookie = [self loadCookie];
    
    CloudRequest * cloudRequest = [m_cloudController requestLoginWithCookie:cookie
                                                             andCallbackObj:self
                                                             andCallbackSel:@selector(requestLoginUserCookieCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestLoginUserCookieCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        userResponse.m_status = UserResponseStatusSuccess;
        
        [m_loggedInUsername release];
        
        m_loggedInUsername = [m_cloudController.m_username retain];
        
        [self setUserProfileForUserId:0
                            toProfile:m_loggedInUserProfile];
        
        if ( m_loggedInUsername )
        {
            [self saveCache];
        }
        
        // Save the cookie before we return
//        NSHTTPCookie * cookie = [m_cloudController getCakePhpCookie];
//        
//        if ( cookie )
//        {
//            [self saveCookie:cookie];
//        }

    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestLogoutUserCallbackObj:(id)obj
                      andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeLogout
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    // Clear everything relating to the current user
    [self clearCache];
    
    CloudRequest * cloudRequest = [m_cloudController requestLogoutCallbackObj:self
                                                               andCallbackSel:@selector(requestLogoutUserCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestLogoutUserCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = NO;
    
    userResponse.m_status = UserResponseStatusSuccess;
    
    // Clear all the cached user controller info
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

#pragma mark - Cloud

- (void)requestUserProfile:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserProfile
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    // a userid of 0 indicates the current user
    CloudRequest * cloudRequest = [m_cloudController requestUserProfile:userId
                                                         andCallbackObj:self
                                                         andCallbackSel:@selector(requestUserProfileCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserProfileCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];

    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setUserProfileForUserId:cloudResponse.m_responseUserId
                            toProfile:cloudResponse.m_responseUserProfile];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }         
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestUserProfileChangePicture:(UIImage*)image andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserProfileEdit
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestUserProfileEdit:nil
                                                                   andEmail:nil
                                                                   andImage:image 
                                                             andCallbackObj:self 
                                                             andCallbackSel:@selector(requestUserProfileChangePictureCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];

}

- (void)requestUserProfileChangePictureCallback:(CloudResponse *)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setUserProfileForUserId:cloudResponse.m_responseUserId
                            toProfile:cloudResponse.m_responseUserProfile];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }         
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestUserProfileSearch:(NSString*)search
                  andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserProfileSearch
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestUserProfileSearch:search
                                                               andCallbackObj:self
                                                               andCallbackSel:@selector(requestUserProfileSearchCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserProfileSearchCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        NSArray * list = cloudResponse.m_responseUserProfiles.m_profilesArray;
                
        userResponse.m_status = UserResponseStatusSuccess;
        
        userResponse.m_searchResults = list;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestUserSessions:(NSInteger)userId
             andCallbackObj:(id)obj
             andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserSessions
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestUserSessions:userId
                                                          andCallbackObj:self
                                                          andCallbackSel:@selector(requestUserSessionsCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserSessionsCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setSessionsForUserId:cloudResponse.m_responseUserId
                            toList:cloudResponse.m_responseUserSongSessions.m_sessionsArray];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestAddUserFollow:(NSInteger)friendUserId
              andCallbackObj:(id)obj
              andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeAddUserFollow
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestAddFollowUser:friendUserId
                                                           andCallbackObj:self
                                                           andCallbackSel:@selector(requestAddUserFollowCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestAddUserFollowCallback:(CloudResponse*)cloudResponse;
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // update the sessions now that we have removed someone
        [self setFollowsSessionsForUserId:0
                                   toList:cloudResponse.m_responseUserSongSessions.m_sessionsArray];

        // update the follows list for the current user
        [self setFollowsForUserId:0
                           toList:cloudResponse.m_responseUserProfilesFollows.m_profilesArray];
        
        // and for the previously followed user
        [self setFollowedByForUserId:cloudResponse.m_responseUserId
                              toList:cloudResponse.m_responseUserProfilesFollowedBy.m_profilesArray];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestRemoveUserFollow:(NSInteger)friendUserId
                 andCallbackObj:(id)obj
                 andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeRemoveUserFollow
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestRemoveFollowUser:friendUserId
                                                              andCallbackObj:self
                                                              andCallbackSel:@selector(requestRemoveUserFollowCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestRemoveUserFollowCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // update the sessions now that we have removed someone
        [self setFollowsSessionsForUserId:0
                                   toList:cloudResponse.m_responseUserSongSessions.m_sessionsArray];
        
        // update the follows list for the current user
        [self setFollowsForUserId:0
                           toList:cloudResponse.m_responseUserProfilesFollows.m_profilesArray];
        
        // and for the previously followed user
        [self setFollowedByForUserId:cloudResponse.m_responseUserId
                              toList:cloudResponse.m_responseUserProfilesFollowedBy.m_profilesArray];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];

}

- (void)requestUserFollowsSessions:(NSInteger)userId
                    andCallbackObj:(id)obj
                    andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserFollowsSessions
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestFollowsSessions:userId
                                                             andCallbackObj:self
                                                             andCallbackSel:@selector(requestUserFollowsSessionsCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserFollowsSessionsCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setFollowsSessionsForUserId:cloudResponse.m_responseUserId
                                   toList:cloudResponse.m_responseUserSongSessions.m_sessionsArray];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

//- (void)requestUserGlobalSessionsCallbackObj:(id)obj
//                              andCallbackSel:(SEL)sel
//{
//    
//    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserGlobalSessions
//                                                andCallbackObject:obj
//                                              andCallbackSelector:sel];
//    
//    CloudRequest * cloudRequest = [m_cloudController requestGlobalSessionsCallbackObj:self
//                                                                       andCallbackSel:@selector(requestUserFollowsSessionsCallback:)];
//    
//    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
//    
//}
//
//- (void)requestUserGlobalSessionsCallback:(CloudResponse*)cloudResponse
//{
//    
//    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
//    
//    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
//    
//    // Create response
//    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
//    
//    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
//    
//    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
//    {
//        
//        [self setFollowsSessionsForUserId:cloudResponse.m_responseUserId
//                                   toList:cloudResponse.m_responseUserSongSessions.m_sessionsArray];
//        
//        userResponse.m_status = UserResponseStatusSuccess;
//        
//    }
//    else
//    {
//        userResponse.m_status = UserResponseStatusFailure;
//        userResponse.m_statusText = cloudResponse.m_statusText;
//    }
//    
//    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
//    
//}

- (void)requestUserFollows:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserFollows
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestFollowsList:userId
                                                         andCallbackObj:self
                                                         andCallbackSel:@selector(requestUserFollowsCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}
    
- (void)requestUserFollowsCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setFollowsForUserId:cloudResponse.m_responseUserId
                           toList:cloudResponse.m_responseUserProfiles.m_profilesArray];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestUserFollowedBy:(NSInteger)userId
               andCallbackObj:(id)obj
               andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserFollowed
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestFollowedByList:userId
                                                            andCallbackObj:self
                                                            andCallbackSel:@selector(requestUserFollowedByCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserFollowedByCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setFollowedByForUserId:cloudResponse.m_responseUserId
                              toList:cloudResponse.m_responseUserProfiles.m_profilesArray];
                
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];

}

// facebook
- (void)requestUserFacebookFriends:(NSString*)accessToken
                    andCallbackObj:(id)obj
                    andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserFacebookFriends
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    CloudRequest * cloudRequest = [m_cloudController requestUserProfileFacebookSearch:accessToken
                                                                       andCallbackObj:self
                                                                       andCallbackSel:@selector(requestUserFacebookFriendsCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserFacebookFriendsCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [self setFacebookFriendsForUserId:cloudResponse.m_responseUserProfile.m_userId
                                   toList:cloudResponse.m_responseUserProfiles.m_profilesArray];
                
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

- (void)requestUserSongSessionUpload:(UserSongSession*)songSession andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    UserRequest * userRequest = [[UserRequest alloc] initWithType:UserRequestTypeUserSongSessionUpload
                                                andCallbackObject:obj
                                              andCallbackSelector:sel];
    
    [self queueUserSongSession:songSession];
    
    CloudRequest * cloudRequest = [m_cloudController requestUploadUserSongSession:songSession
                                                                   andCallbackObj:self
                                                                   andCallbackSel:@selector(requestUserSongSessionUploadCallback:)];
    
    [m_cloudToUserRequest setObject:userRequest forKey:[NSValue valueWithNonretainedObject:cloudRequest]];
    
}

- (void)requestUserSongSessionUploadCallback:(CloudResponse*)cloudResponse
{
    
    UserRequest * userRequest = [[m_cloudToUserRequest objectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]] autorelease];
    
    [m_cloudToUserRequest removeObjectForKey:[NSValue valueWithNonretainedObject:cloudResponse.m_cloudRequest]];
    
    // Create response
    UserResponse * userResponse = [[[UserResponse alloc] initWithUserRequest:userRequest] autorelease];
    
    userResponse.m_loggedIn = m_cloudController.m_loggedIn;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        UserSongSession * songSession = cloudResponse.m_responseUserSongSession;
        
        [self finishedUploadingSession:songSession];
        
        userResponse.m_status = UserResponseStatusSuccess;
        
    }
    else
    {
        userResponse.m_status = UserResponseStatusFailure;
        userResponse.m_statusText = cloudResponse.m_statusText;
    }
    
    [userRequest.m_callbackObject performSelector:userRequest.m_callbackSelector withObject:userResponse];
    
}

#pragma mark - Accessor functions

- (UserEntry*)getUserEntry:(NSInteger)userId
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    return entry;
    
}

- (void)setUserProfileForUserId:(NSInteger)userId toProfile:(UserProfile*)profile
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    if ( entry == nil )
    {
        entry = [[[UserEntry alloc] init] autorelease];
    }
    
    entry.m_userProfile = profile;
    
    [m_userCache setObject:entry forKey:key];
    
    // create an alias for the 0 id (ie the current user)
    if ( userId == 0 )
    {
        [m_userCache setObject:entry forKey:[NSNumber numberWithInteger:m_loggedInUserProfile.m_userId]];
        
        [m_loggedInUserProfile release];
        m_loggedInUserProfile = [profile retain];        
    }
    
    [self saveCache];
    
}

- (void)setSessionsForUserId:(NSInteger)userId toList:(NSArray*)list
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    if ( entry == nil )
    {
        entry = [[[UserEntry alloc] init] autorelease];
    }
    
    entry.m_sessionsList = list;
    
    [m_userCache setObject:entry forKey:key];
    
    // create an alias for the 0 id (ie the current user)
    if ( userId == 0 )
    {
        [m_userCache setObject:entry forKey:[NSNumber numberWithInteger:m_loggedInUserProfile.m_userId]];
    }
    
    [self saveCache];

}

- (void)setFollowsForUserId:(NSInteger)userId toList:(NSArray*)list
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    if ( entry == nil )
    {
        entry = [[[UserEntry alloc] init] autorelease];
    }
    
    entry.m_followsList = list;
    
    [m_userCache setObject:entry forKey:key];
    
    // Create an alias for the 0 id (ie the current user).
    // We only technically need to do this the first time because 
    // after that it is the same entry in both locactions.
    if ( userId == 0 )
    {
        [m_userCache setObject:entry forKey:[NSNumber numberWithInteger:m_loggedInUserProfile.m_userId]];
    }
    
    [self saveCache];
    
}

- (void)setFollowedByForUserId:(NSInteger)userId toList:(NSArray*)list
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    if ( entry == nil )
    {
        entry = [[[UserEntry alloc] init] autorelease];
    }
    
    entry.m_followedByList = list;
    
    [m_userCache setObject:entry forKey:key];
    
    // Create an alias for the 0 id (ie the current user).
    // We only technically need to do this the first time because 
    // after that it is the same entry in both locactions.
    if ( userId == 0 )
    {
        [m_userCache setObject:entry forKey:[NSNumber numberWithInteger:m_loggedInUserProfile.m_userId]];
    }
    
    [self saveCache];
    
}

- (void)setFacebookFriendsForUserId:(NSInteger)userId toList:(NSArray*)list
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    if ( entry == nil )
    {
        entry = [[[UserEntry alloc] init] autorelease];
    }
    
    entry.m_facebookFriendsList = list;
    
    [m_userCache setObject:entry forKey:key];
    
    // Create an alias for the 0 id (ie the current user).
    // We only technically need to do this the first time because 
    // after that it is the same entry in both locactions.
    if ( userId == 0 )
    {
        [m_userCache setObject:entry forKey:[NSNumber numberWithInteger:m_loggedInUserProfile.m_userId]];
    }
    
    [self saveCache];
    
}

- (void)setFollowsSessionsForUserId:(NSInteger)userId toList:(NSArray*)list
{
    
    NSNumber * key = [NSNumber numberWithInteger:userId];
    
    UserEntry * entry = [m_userCache objectForKey:key];
    
    if ( entry == nil )
    {
        entry = [[[UserEntry alloc] init] autorelease];
    }
    
    entry.m_followsSessionsList = list;
    
    [m_userCache setObject:entry forKey:key];
    
    // Create an alias for the 0 id (ie the current user).
    // We only technically need to do this the first time because 
    // after that it is the same entry in both locactions.
    if ( userId == 0 )
    {
        [m_userCache setObject:entry forKey:[NSNumber numberWithInteger:m_loggedInUserProfile.m_userId]];
    }
    
    [self saveCache];
    
}

#pragma mark - Uploading

- (void)queueUserSongSession:(UserSongSession*)songSession
{
    
    @synchronized( m_pendingUserSongSessionUploads )
    {
        if ( [m_pendingUserSongSessionUploads containsObject:songSession] == NO )
        {
            [m_pendingUserSongSessionUploads addObject:songSession];
            [self saveCache];
        }
    }
    
}

- (void)finishedUploadingSession:(UserSongSession*)songSession
{
    
    @synchronized( m_pendingUserSongSessionUploads )
    {
        [m_pendingUserSongSessionUploads removeObject:songSession];
        [self saveCache];
    }
    
    [self sendPendingUploads];
    
}

- (void)sendPendingUploads
{
    
    @synchronized( m_pendingUserSongSessionUploads )
    {
        
        if ( [m_pendingUserSongSessionUploads count] > 0 )
        {
            
            UserSongSession * session = [m_pendingUserSongSessionUploads objectAtIndex:0];
            
            [self requestUserSongSessionUpload:session andCallbackObj:nil andCallbackSel:nil];
            
        }
        
    }
    
}

#pragma mark - Stars and Scores


- (void)addStars:(NSInteger)stars forSong:(NSInteger)songId
{
    
    if ( songId == 0 )
    {
        return;
    }
    
    NSNumber * key = [NSNumber numberWithInteger:songId];
    
    NSInteger oldStars = [[m_starCache objectForKey:key] integerValue];
    
    if ( stars > oldStars )
    {
        [m_starCache setObject:[NSNumber numberWithInteger:stars] forKey:key];
    }
    
    [self saveCache];
    
}

- (NSInteger)getMaxStarsForSong:(NSInteger)songId
{
    
    if ( songId == 0 )
    {
        return 0;
    }
    
    return [[m_starCache objectForKey:[NSNumber numberWithInteger:songId]] integerValue];
    
}

- (void)addScore:(NSInteger)score forSong:(NSInteger)songId;
{
    
    if ( songId == 0 )
    {
        return;
    }
    
    NSNumber * key = [NSNumber numberWithInteger:songId];
    
    NSInteger oldScore = [[m_scoreCache objectForKey:key] integerValue];
    
    if ( score > oldScore )
    {
        [m_scoreCache setObject:[NSNumber numberWithInteger:score] forKey:key];
    }
    
    [self saveCache];
    
}

- (NSInteger)getMaxScoreForSong:(NSInteger)songId;
{
    
    if ( songId == 0 )
    {
        return 0;
    }
    
    return [[m_scoreCache objectForKey:[NSNumber numberWithInteger:songId]] integerValue];
    
}

@end
