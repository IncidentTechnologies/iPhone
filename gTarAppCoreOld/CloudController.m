//
//  CloudController.m
//  gTarAppCore
//
//  Created by Marty Greenia on 4/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "CloudController.h"

#import "CloudResponse.h"
#import "CloudRequest.h"
#import "UserProfile.h"
#import "UserProfiles.h"
#import "UserSong.h"
#import "UserSongs.h"
#import "UserSongSession.h"
#import "UserSongSessions.h"
#import "NewsTicker.h"
#import "StoreFeatureCollection.h"
#import "FeaturedSong.h"

#import "XmlDictionary.h"
#import "XmlDom.h"

//class StatusCode
//{
//    const Ok = 0;
//    const Unknown = 1;
//    const ServerError = 2;
//    const InvalidUrl = 3;
//    const InvalidParameter = 4;
//    const Unauthorized = 5;
//    
//    static $StatusText = array( StatusCode::Ok => "Ok",
//                               StatusCode::Unknown => "Unknown", 
//                               StatusCode::ServerError => "ServerError",
//                               StatusCode::InvalidUrl => "InvalidUrl",
//                               StatusCode::InvalidParameter => "InvalidParameter",
//                               StatusCode::Unauthorized => "Unauthorized" );
//    
//}

//#define SERVER_NAME @"http://mcbookpro.local:8888"
//#define SERVER_ROOT @"http://mcbookpro.local:8888/app_iphone"
#define SERVER_NAME_DEFAULT @"http://www.strumhub.com/v0.53"
#define SERVER_ROOT_DEFAULT @"http://www.strumhub.com/v0.53/app_iphone"
#define SERVER_NAME m_serverName
#define SERVER_ROOT m_serverRoot

#define GET_SERVER_STATUS @"Main/ServerStatus"
#define GET_ITUNES_STATUS @"Main/ItunesStatus"

// old stuff, don't delete yet

//#define USER_REGISTER @"Users/Register"
//#define USER_LOGIN @"Users/Login"
//#define USER_LOGIN_FACEBOOK @"Users/LoginWithFacebookAccessToken"
//#define USER_LOGOUT @"Users/Logout"
//#define USER_GET_USER_PROFILE @"Users/GetUserProfile"
//#define USER_FIND_USER_PROFILE @"Users/FindUserProfile"
//#define USER_FIND_FACEBOOK_FRIENDS_USER_PROFILE @"Users/FindFacebookFriendsUserProfile"
//#define USER_GET_USER_CREDITS @"Users/GetUserCredits"
//#define USER_VERIFY_ITUNES_PURCHASE @"Users/VerifyItunesPurchase"
//#define USER_REDEEM_CREDIT_CODE @"Users/RedeemCreditCode"
//
//#define USER_PURCHASE_SONG @"UserSongs/PurchaseSong"
//#define USER_SONGS_GET_USER_SONGS_LIST @"UserSongs/GetUserSongsList"
//#define USER_SONGS_GET_FEATURED_NEW_POPULAR_SONGS_LIST @"UserSongs/GetFeaturedNewAndPopularSongsList"
//#define USER_SONGS_GET_ALL_SONGS_LIST @"UserSongs/GetAllSongsList"
//#define USER_SONGS_GET_SONG_IMAGE @"UserSongs/GetSongImage"
//#define USER_SONGS_GET_SONG_XMP @"UserSongs/GetSongXmp"
////#define get song xmp
//
//#define USER_SONG_SESSIONS_GET_USER_SONG_SESSIONS @"UserSongSessions/GetUserSongSessions"
//#define USER_SONG_SESSIONS_UPLOAD_SESSION @"UserSongSessions/UploadSession"
//#define USER_SONG_SESSIONS_UPLOAD_SESSION_TO_FACEBOOK @"UserSongSessions/UploadSessionToFacebook"
//#define USER_SONG_SESSIONS_GET_SESSION_XMP @"UserSongSessions/GetSessionXmp"
//
//#define USER_FOLLOWS_GET_FOLLOWS_LIST @"UserFollows/GetFollowsList"
//#define USER_FOLLOWS_ADD_FOLLOWS @"UserFollows/AddFollows"
//#define USER_FOLLOWS_REMOVE_FOLLOWS @"UserFollows/RemoveFollows"
//#define USER_FOLLOWS_GET_FOLLOWED_BY_LIST @"UserFollows/GetFollowedByList"
//#define USER_FOLLOWS_GET_FOLLOWS_SESSIONS @"UserFollows/GetFollowsSessions"
//
//#define USER_FILES_GET_FILE @"UserFiles/GetFile"

// NEW STUFF
#define CloudRequestTypeGetFileUrl @"UserFiles/GetFile"
#define CloudRequestTypeRegisterUrl @"Users/Register"
#define CloudRequestTypeLoginFacebookUrl @"Users/LoginWithFacebookAccessToken"
#define CloudRequestTypeLoginUrl @"Users/Login"
#define CloudRequestTypeLoginCookieUrl @"Users/LoginWithCookie"
#define CloudRequestTypeLogoutUrl @"Users/Logout"
#define CloudRequestTypeGetUserProfileUrl @"Users/GetUserProfile"
#define CloudRequestTypeSearchUserProfileUrl @"Users/FindUserProfile"
#define CloudRequestTypeEditUserProfileUrl @"Users/EditUserProfile"
#define CloudRequestTypeSearchUserProfileFacebookUrl @"Users/FindFacebookFriendsUserProfile"
#define CloudRequestTypeGetUserCreditsUrl @"Users/GetUserCredits"
#define CloudRequestTypePurchaseSongUrl @"UserSongs/PurchaseSong"
#define CloudRequestTypeVerifyItunesReceiptUrl @"Users/VerifyItunesPurchase"
#define CloudRequestTypeGetAllSongsListUrl @"UserSongs/GetAllSongsList"
#define CloudRequestTypeGetAllSongPidsUrl @"UserSongs/GetAllSongPids"
#define CloudRequestTypeGetUserSongListUrl @"UserSongs/GetUserSongsList"
#define CloudRequestTypeGetStoreSongListUrl @"UserSongs/GetAllSongsList"
#define CloudRequestTypeGetStoreFeaturesSongListUrl @"UserSongs/GetFeaturedNewAndPopularSongsList"
#define CloudRequestTypePutUserSongSessionUrl @"UserSongSessions/UploadSession"
#define CloudRequestTypeGetUserSongSessionsUrl @"UserSongSessions/GetUserSongSessions"
#define CloudRequestTypeGetUserGlobalSongSessionsUrl @"UserSongSessions/GetGlobalUserSongSessions"
#define CloudRequestTypeAddUserFollowsUrl @"UserFollows/AddFollows"
#define CloudRequestTypeRemoveUserFollowsUrl @"UserFollows/RemoveFollows"
#define CloudRequestTypeGetUserFollowsListUrl @"UserFollows/GetFollowsList"
#define CloudRequestTypeGetUserFollowedListUrl @"UserFollows/GetFollowedByList"
#define CloudRequestTypeGetUserFollowsSongSessionsUrl @"UserFollows/GetFollowsSessions"
#define CloudRequestTypeRedeemCreditCodeUrl @"Users/RedeemCreditCode"
#define CloudRequestTypePutLogUrl @"Telemetry/UploadLog"


// maybe append a clock() or tick() to this thing
#define POST_BOUNDARY @"------gTarPlayFormBoundary0123456789"

@implementation CloudController

@synthesize m_loggedIn;
@synthesize m_username;
@synthesize m_facebookAccessToken;

- (id)init
{
	
    self = [super init];
    
	if ( self )
	{
		
        m_loggedIn = NO;
        
		m_requestResponseDictionary = [[NSMutableDictionary alloc] init];
        m_connectionResponseDictionary = [[NSMutableDictionary alloc] init];
        m_requestQueue = [[NSMutableArray alloc] init];
        
        m_serverName = [[NSString alloc]  initWithFormat:SERVER_NAME_DEFAULT];
        m_serverRoot = [[NSString alloc]  initWithFormat:SERVER_ROOT_DEFAULT];
        
        // Set the cookie storage appropriately
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
		
	}
	
	return self;
	
}

- (id)initWithServer:(NSString*)serverName
{
    
    // Note this is 'self' not 'super'
    self = [self init];
    
    if ( self ) 
    {
        m_serverName = [serverName retain];
        m_serverRoot = [[NSString alloc] initWithFormat:@"%@/app_iphone", serverName];
                
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_requestResponseDictionary release];
    [m_connectionResponseDictionary release];
    [m_requestQueue release];
    
    [m_username release];
    [m_facebookAccessToken release];
    [m_serverName release];
    [m_serverRoot release];
    
    [super dealloc];
    
}

#pragma mark -
#pragma mark Misc

- (NSHTTPCookie*)getCakePhpCookie
{
    
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:m_serverRoot]];
//    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"mcbookpro.local"]];
    
    for ( NSHTTPCookie * cookie in cookies )
    {
        if ( [cookie.name isEqualToString:@"CAKEPHP"] )
        { 
            return cookie;
        }
    }
    
    return nil;
    
}

- (void)setCakePhpCookie:(NSHTTPCookie*)cookie
{
    
    if ( cookie == nil )
    {
        // No cookies
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:[NSArray array] forURL:[NSURL URLWithString:m_serverName] mainDocumentURL:nil];
    }
    else
    {
        NSArray  * cookieArray = [NSArray arrayWithObject:cookie];
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookieArray forURL:[NSURL URLWithString:m_serverName] mainDocumentURL:nil];
    }
    
}

#pragma mark -
#pragma mark Syncronous convenience

- (BOOL)requestServerStatus
{
    
    NSString * urlString = [NSString stringWithFormat:@"%@/%@", SERVER_ROOT, GET_SERVER_STATUS];
    
    XmlDom * dom = [[XmlDom alloc] initWithXmlData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    
    NSString * response = [dom getTextFromChildWithName:@"StatusText"];
    
    BOOL status = NO;
    
    // The request succeeded, the server is there
    if ( [response isEqualToString:@"Ok"] )
    {
        status = YES;
    }
    else 
    {
        status = NO;
    }
    
    [dom release];
    
    return status;
    
}


- (BOOL)requestItunesServerStatus
{
    
    NSString * urlString = [NSString stringWithFormat:@"%@/%@", SERVER_ROOT, GET_ITUNES_STATUS];
    
    XmlDom * dom = [[XmlDom alloc] initWithXmlData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    
    NSString * response = [dom getTextFromChildWithName:@"StatusText"];
    
    BOOL status = NO;
    
    // The request succeeded, the server is there
    if ( [response isEqualToString:@"Ok"] )
    {
        status = YES;
    }
    else 
    {
        status = NO;
    }
    
    [dom release];
    
    return status;
    
}

- (NSNumber*)requestUserCredits
{
    
    // Create sync request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserCredits];
    
    CloudResponse * cloudResponse = [self cloudSendRequest:cloudRequest];
    
    NSNumber * credits = nil;
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        credits = cloudResponse.m_responseUserCredits;
    }
    
    return credits;
    
}


#pragma mark - Server requests

#pragma mark File

- (CloudRequest*)requestFile:(NSInteger)fileId andCallbackObj:(id)obj andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetFile andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_fileId = fileId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudResponse*)requestFileSync:(NSInteger)fileId
{

    // Create sync request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetFile];
    
    cloudRequest.m_fileId = fileId;
    
    CloudResponse * cloudResponse = [self cloudSendRequest:cloudRequest];
        
    return cloudResponse;
        
}

#pragma mark User

- (CloudRequest*)requestRegisterUsername:(NSString*)username
                             andPassword:(NSString*)password
                                andEmail:(NSString*)email
                          andCallbackObj:(id)obj
                          andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeRegister andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_username = username;
    cloudRequest.m_password = password;
    cloudRequest.m_email = email;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestLoginUsername:(NSString*)username
                          andPassword:(NSString*)password
                       andCallbackObj:(id)obj
                       andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeLogin andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_username = username;
    cloudRequest.m_password = password;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
	
}

- (CloudRequest*)requestFacebookLoginWithToken:(NSString*)accessToken
                                andCallbackObj:(id)obj
                                andCallbackSel:(SEL)sel
{
	
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeLoginFacebook andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_facebookAccessToken = accessToken;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestLoginWithCookie:(NSHTTPCookie*)cookie 
                         andCallbackObj:(id)obj
                         andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeLoginCookie andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_cookie = cookie;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestLogoutCallbackObj:(id)obj
                           andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeLogout andCallbackObject:obj andCallbackSelector:sel];
    
    // Also Delete local cookies for good measure
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:SERVER_NAME]];
    
	for ( unsigned int index = 0; index < [cookies count]; index++ )
	{
		
		NSHTTPCookie * cookie = [cookies objectAtIndex:index];
		
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
		
	}
    
    m_loggedIn = NO;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
	
}

- (CloudRequest*)requestUserProfile:(NSInteger)userId
                     andCallbackObj:(id)obj
                     andCallbackSel:(SEL)sel
{
	
    // Note that you must already be logged in in order for this to succeed
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserProfile andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestUserProfileEdit:(NSString*)name andEmail:(NSString*)email andImage:(UIImage*)profPic andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeEditUserProfile andCallbackObject:obj andCallbackSelector:sel];
    
    // Add some other stuff here?
    cloudRequest.m_email = email;
    cloudRequest.m_profileImage = profPic;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;

}

- (CloudRequest*)requestUserProfileSearch:(NSString*)search
                           andCallbackObj:(id)obj
                           andCallbackSel:(SEL)sel
{
	
	// Note that you must already be logged in in order for this to succeed
	
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeSearchUserProfile andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_searchString = search;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestUserProfileFacebookSearch:(NSString*)accessToken
                                   andCallbackObj:(id)obj
                                   andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeSearchUserProfileFacebook andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_facebookAccessToken = accessToken;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestUserCreditsCallbackObj:(id)obj
                                andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserCredits andCallbackObject:obj andCallbackSelector:sel];
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestPurchaseSong:(UserSong*)userSong
                      andCallbackObj:(id)obj
                      andCallbackSel:(SEL)sel
{
    

    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypePurchaseSong andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userSong = userSong;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}


- (CloudRequest*)requestVerifyReceipt:(NSData*)receipt
                       andCallbackObj:(id)obj
                       andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypePurchaseSong andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_itunesReceipt = receipt;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

#pragma mark UserSongs

- (CloudRequest*)requestSongListCallbackObj:(id)obj
                             andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserSongList andCallbackObject:obj andCallbackSelector:sel];
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestFeaturedSongListCallbackObj:(id)obj
                                     andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetStoreFeaturesSongList andCallbackObject:obj andCallbackSelector:sel];
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestSongStoreListCallbackObj:(id)obj
                                  andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetStoreSongList andCallbackObject:obj andCallbackSelector:sel];
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestRedeemCreditCode:(NSString*)creditCode
                          andCallbackObj:(id)obj
                          andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeRedeemCreditCode andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_creditCode = creditCode;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

#pragma mark UserSongSessions

- (CloudRequest*)requestUploadUserSongSession:(UserSongSession*)songSession
                               andCallbackObj:(id)obj
                               andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypePutUserSongSession andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userSongSession = songSession;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

#pragma mark UserFollows

- (CloudRequest*)requestUserSessions:(NSInteger)userId
                      andCallbackObj:(id)obj
                      andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserSongSessions andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestAddFollowUser:(NSInteger)userId
                       andCallbackObj:(id)obj
                       andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeAddUserFollows andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestRemoveFollowUser:(NSInteger)userId
                          andCallbackObj:(id)obj
                          andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeRemoveUserFollows andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestFollowsList:(NSInteger)userId
                     andCallbackObj:(id)obj
                     andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserFollowsList andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestFollowedByList:(NSInteger)userId
                        andCallbackObj:(id)obj
                        andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserFollowedList andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestFollowsSessions:(NSInteger)userId
                         andCallbackObj:(id)obj
                         andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserFollowsSongSessions andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_userId = userId;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestGlobalSessionsCallbackObj:(id)obj
                                   andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypeGetUserGlobalSongSessions andCallbackObject:obj andCallbackSelector:sel];
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;
    
}

- (CloudRequest*)requestLogUpload:(NSString*)log
                       andVersion:(NSString*)version
                        andDevice:(NSString*)device
                           andApp:(NSString*)app
                   andCallbackObj:(id)obj
                   andCallbackSel:(SEL)sel
{
    
    // Create async request
    CloudRequest * cloudRequest = [[CloudRequest alloc] initWithType:CloudRequestTypePutLog andCallbackObject:obj andCallbackSelector:sel];
    
    cloudRequest.m_logEntries = log;
    cloudRequest.m_versionString = version;
    cloudRequest.m_appString = app;
    cloudRequest.m_deviceString = device;
    
    [self cloudSendRequest:cloudRequest];
    
    return cloudRequest;

}


#pragma mark -
#pragma mark Connection registration

- (void)registerConnection:(NSURLConnection*)connection toResponse:(CloudResponse*)cloudResponse
{
    
	// need to make the object a NSValue in order to use it as a key 
	NSValue * key = [NSValue valueWithNonretainedObject:connection];
	
    [cloudResponse retain];
    
	[m_connectionResponseDictionary setObject:cloudResponse forKey:key];
	
}

- (CloudResponse*)getReponseForConnection:(NSURLConnection*)connection
{

    // need to make the object a NSValue in order to use it as a key 
    NSValue * key = [NSValue valueWithNonretainedObject:connection];
    
	CloudResponse * cloudResponse = [m_connectionResponseDictionary objectForKey:key];
	
    return cloudResponse;

}

- (CloudResponse*)deregisterConnection:(NSURLConnection*)connection
{
    
	// need to make the object a NSValue in order to use it as a key 
    NSValue * key = [NSValue valueWithNonretainedObject:connection];
    
	CloudResponse * cloudResponse = [m_connectionResponseDictionary objectForKey:key];
	
	[m_connectionResponseDictionary removeObjectForKey:key];
    
    [cloudResponse autorelease];
    
    return cloudResponse;
    
}

#pragma mark -
#pragma mark Cloud functions

- (CloudResponse*)cloudSendRequest:(CloudRequest*)cloudRequest
{
    
    // If queue send requests
    if ( cloudRequest.m_isSynchronous == YES )
    {
        // Sync requests just go 
        return [self cloudProcessRequest:cloudRequest];
        
    }
    else
    {
        // Async requests go in the queue
        @synchronized(m_requestQueue)
        {
            
            [m_requestQueue addObject:cloudRequest];
            
            if ( [m_requestQueue count] == 1 )
            {
                // If this is the only thing in the queue, send it
                [self cloudProcessRequest:cloudRequest];
            }
            
        }
        
        return nil;
        
    }
    
}

- (CloudResponse*)cloudProcessRequest:(CloudRequest*)cloudRequest
{
    
    // Create a response object
    CloudResponse * cloudResponse = [[[CloudResponse alloc] initWithCloudRequest:cloudRequest] autorelease];
    
    // Parse out the request parameters
    NSURLRequest * urlRequest = [self createPostForRequest:cloudRequest];
    
    // Is this a async or sync request?
    if ( cloudRequest.m_isSynchronous == YES )
    {
        
        NSURLResponse * urlResponse = nil;
        
        NSError * error = nil;
        
        NSData * responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                      returningResponse:&urlResponse
                                                                  error:&error];
        
        // See if our connection failed
        if ( error != nil )
        {
            
            NSLog( @"Sync connection error: %@", [error localizedDescription] );
            
            cloudRequest.m_status = CloudRequestStatusConnectionError;
            
            cloudResponse.m_status = CloudResponseStatusConnectionError;
            
            cloudResponse.m_statusText = [error localizedDescription];
            
        }
        else
        {
            
            cloudResponse.m_receivedData = [[responseData mutableCopy] autorelease];
            
            cloudResponse.m_receivedDataString = [NSString stringWithCString:(char*)[responseData bytes] encoding:NSASCIIStringEncoding];
            
            // Extract http response info
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)urlResponse;
            
            cloudResponse.m_mimeType = [httpResponse MIMEType];
            
            cloudResponse.m_statusCode = [httpResponse statusCode];
            
            cloudResponse.m_cloudRequest.m_status = CloudRequestStatusCompleted;
            
            // Parse the results
            [self parseResultsForResponse:cloudResponse];
            
        }
        
        return cloudResponse;
        
    }
    else
    {
        
        // Create a connection
        NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
        
        if ( connection == nil )
        {
            
            NSLog( @"Async connection error" );
            
            cloudRequest.m_status = CloudRequestStatusConnectionError;
            cloudResponse.m_status = CloudResponseStatusConnectionError;
            cloudResponse.m_statusText = @"Connection error";
            
            // Return the request to sender
            [self cloudReturnResponse:cloudResponse];
            
        }
        else
        {
            
            // The request has been sent
            cloudRequest.m_status = CloudRequestStatusSent;
            
            // Register this connection so we can access it later.
            [self registerConnection:connection toResponse:cloudResponse];
            
        }
        
        // Schedule it on the main thread, otherwise it won't work.
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        
        [connection start];
        
        [connection release];
        
        // The response is returned asynchronously
        return nil;
        
    }
    
}

- (void)cloudReceiveResponse:(CloudResponse*)cloudResponse
{
    
    // Parse the results
    [self parseResultsForResponse:cloudResponse];
    
    // Update our logged in status, based on what just came in.
    cloudResponse.m_loggedIn = self.m_loggedIn;
    
    // Return to sender
    [self cloudReturnResponse:cloudResponse];
    
}

- (void)cloudReturnResponse:(CloudResponse*)cloudResponse
{
    
    CloudRequest * cloudRequest = cloudResponse.m_cloudRequest;
    
    id callbackObject = cloudRequest.m_callbackObject;
    SEL callbackSelector = cloudRequest.m_callbackSelector;
    
    if ( [callbackObject respondsToSelector:callbackSelector] == YES )
    {
        // Send this back to the original caller
//        [callbackObject performSelector:callbackSelector withObject:cloudResponse];
        [callbackObject performSelectorOnMainThread:callbackSelector withObject:cloudResponse waitUntilDone:YES];
    }
    
    // Now that this request is done, we can issue another one
    @synchronized(m_requestQueue)
    {
        // Remove the object we just finished.
        [m_requestQueue removeObjectAtIndex:0];
        
        // If there is anything else, send one off.
        if ( [m_requestQueue count] > 0 )
        {
            // Pull off the first object from the queue
            CloudRequest * cloudRequest = [m_requestQueue objectAtIndex:0];
            
            [self cloudProcessRequest:cloudRequest];
            
        }
    }
        
}

#pragma mark -
#pragma mark Cloud helpers

- (NSURLRequest*)createPostForRequest:(CloudRequest*)cloudRequest
{
    
    NSString * urlString = nil;
    NSArray * paramsArray = nil;
    NSArray * filesArray = nil;
    
    // Get the arguments ready based on the request type
    [self marshalArgumentsForRequest:cloudRequest withUrl:&urlString andParameters:&paramsArray andFiles:&filesArray];
    
    NSString * rootedUrlString = [NSString stringWithFormat:@"%@/%@", SERVER_ROOT, urlString];
    
    // Create a POST request object 
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
	
    [request setURL:[NSURL URLWithString:rootedUrlString]];
    
	[request setHTTPMethod:@"POST"];
	
    // Set the ContentType to multipart/form-data. This is what CakePHP expects
    NSString * boundary = POST_BOUNDARY;
    
	NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//
	// Create the post body
	//
//	NSMutableString * postBody = [NSMutableString string];
    NSMutableData * postBodyData = [NSMutableData data];
    
    [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
    
	// Add all the fields
	
	// Method = post
//    [postBody appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"_method\"\r\n\r\nPOST"]];
//    [postBody appendString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
    [postBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"_method\"\r\n\r\nPOST"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Add all the parameters to the post body
    for ( NSDictionary * paramDict in paramsArray )
    {
        
        NSString * name = [paramDict objectForKey:@"Name"];
        NSString * value = [paramDict objectForKey:@"Value"];
        
        // Some params might be optional
        if ( name != nil && value != nil )
        {
//            [postBody appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name]];
//            [postBody appendString:[NSString stringWithFormat:@"%@", value]];
//            [postBody appendString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
            [postBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBodyData appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    // Add all the files to the post body
    for ( NSDictionary * fileDict in filesArray )
    {
        
        NSString * name = [fileDict objectForKey:@"Name"];
        NSString * filename = [fileDict objectForKey:@"Filename"];
        NSString * contentType = nil;
        
        id fileData = [fileDict objectForKey:@"Data"];
        
        NSData * data = nil;
        
        if ( [fileData isKindOfClass:[UIImage class]] == YES )
        {
            data = UIImagePNGRepresentation( (UIImage*)fileData );
            contentType = @"image/png";
        }
        
        if ( [fileData isKindOfClass:[NSString class]] == YES )
        {
            data = [(NSString*)fileData dataUsingEncoding:NSUTF8StringEncoding];
            contentType = @"application/octet-stream";
        }
            
        // Some params might be optional
        if ( name != nil && filename != nil && data != nil )
        {
//            [postBody appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename]];
//            [postBody appendString:[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"]];
//            [postBody appendString:data];
//            [postBody appendString:[NSString stringWithFormat:@"\r\n--%@\r\n", boundary]];
            [postBodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBodyData appendData:data];
            [postBodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        }
        
    }
    
    // Convert the POST body to data bytes
//    NSData * postBodyData = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSString * postString = [[[NSString alloc] initWithData:postBodyData encoding:NSASCIIStringEncoding] autorelease];
//    NSLog(postString);
    
    // Stick the post body (now as encoded bytes) into the request
	[request setHTTPBody:postBodyData];
	
	// Update content length in the header. CakePHP will barf without this field, 
    // and the iphone doesn't appear to be adding it automatically.
	[request addValue:[NSString stringWithFormat:@"%u", [postBodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    return [request autorelease];
    
}

- (void)marshalArgumentsForRequest:(CloudRequest*)cloudRequest withUrl:(NSString**)urlString andParameters:(NSArray**)paramsArray andFiles:(NSArray**)filesArray
{
    
    NSString * url = nil;
    NSArray * params = nil;
    NSArray * files = nil;
    
    switch ( cloudRequest.m_type )
    {
            
        case CloudRequestTypeGetFile:
        {
            
            url = CloudRequestTypeGetFileUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserFiles][id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_fileId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeRegister:
        {
            
            url = CloudRequestTypeRegisterUrl;
            
            NSDictionary * param1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[User][username]", @"Name",
                                     cloudRequest.m_username, @"Value", nil];
            
            NSDictionary * param2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[User][password]", @"Name",
                                     cloudRequest.m_password, @"Value", nil];
            
            NSDictionary * param3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[User][password_verification]", @"Name",
                                     cloudRequest.m_password, @"Value", nil];
            
            NSDictionary * param4 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[User][email]", @"Name",
                                     cloudRequest.m_email, @"Value", nil];
            
            params = [NSArray arrayWithObjects:param1, param2, param3, param4, nil];
            
        } break;
            
        case CloudRequestTypeLoginFacebook:
        {
            
            url = CloudRequestTypeLoginFacebookUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[Users][access_token]", @"Name",
                                    cloudRequest.m_facebookAccessToken, @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeLogin:
        {
            
            url = CloudRequestTypeLoginUrl;
            
            NSDictionary * param1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[User][username]", @"Name",
                                     cloudRequest.m_username, @"Value", nil];
            
            NSDictionary * param2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[User][password]", @"Name",
                                     cloudRequest.m_password, @"Value", nil];
            
            params = [NSArray arrayWithObjects:param1, param2, nil];
            
        } break;
            
        case CloudRequestTypeLoginCookie:
        {
            
            url = CloudRequestTypeLoginCookieUrl;
            
            // Update the cookies
            [self setCakePhpCookie:cloudRequest.m_cookie];
            
        } break;
            
        case CloudRequestTypeLogout:
        {
            
            url = CloudRequestTypeLogoutUrl;
            
        } break;
            
        case CloudRequestTypeGetUserProfile:
        {
            
            url = CloudRequestTypeGetUserProfileUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[User][id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeEditUserProfile:
        {
            
            url = CloudRequestTypeEditUserProfileUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserProfile][email]", @"Name",
                                    cloudRequest.m_email, @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
            NSDictionary * fileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"data[UserProfile][fileProfilePic]", @"Name",
                                       @"profilePic.png", @"Filename",
                                       cloudRequest.m_profileImage, @"Data", nil];
            
            files = [NSArray arrayWithObject:fileDict];
            
        } break;
            
        case CloudRequestTypeSearchUserProfile:
        {
            
            url = CloudRequestTypeSearchUserProfileUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserProfile][search]", @"Name",
                                    cloudRequest.m_searchString, @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeSearchUserProfileFacebook:
        {
            
            url = CloudRequestTypeSearchUserProfileFacebookUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[User][access_token]", @"Name",
                                    cloudRequest.m_facebookAccessToken, @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeGetUserCredits:
        {
            
            url = CloudRequestTypeGetUserCreditsUrl;
            
        } break;
            
        case CloudRequestTypePurchaseSong:
        {
            
            url = CloudRequestTypePurchaseSongUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserSongs][songIdToPurchase]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userSong.m_songId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeVerifyItunesReceipt:
        {
            
            url = CloudRequestTypeVerifyItunesReceiptUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[Users][receipt]", @"Name",
                                    cloudRequest.m_itunesReceipt, @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeGetAllSongPids:
        {
            
            url = CloudRequestTypeGetAllSongPidsUrl;
            
        } break;
            
        case CloudRequestTypeGetAllSongsList:
        {
            
            url = CloudRequestTypeGetAllSongsListUrl;
            
        } break;
            
        case CloudRequestTypeGetUserSongList:
        {
            
            url = CloudRequestTypeGetUserSongListUrl;
            
        } break;
            
        case CloudRequestTypeGetStoreSongList:
        {
            
            url = CloudRequestTypeGetStoreSongListUrl;
            
        } break;
            
        case CloudRequestTypeGetStoreFeaturesSongList:
        {
            
            url = CloudRequestTypeGetStoreFeaturesSongListUrl;
            
        } break;
            
        case CloudRequestTypePutUserSongSession:
        {
            
            url = CloudRequestTypePutUserSongSessionUrl;
            
            NSDictionary * param1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[UserSongSession][user_song_id]", @"Name",
                                     [NSNumber numberWithInteger:cloudRequest.m_userSongSession.m_userSong.m_songId], @"Value", nil];
            
            NSDictionary * param2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[UserSongSession][score]", @"Name",
                                     [NSNumber numberWithInteger:cloudRequest.m_userSongSession.m_score], @"Value", nil];
            
            NSDictionary * param3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[UserSongSession][maxscore]", @"Name", 
                                     [NSNumber numberWithInteger:cloudRequest.m_userSongSession.m_scoreMax], @"Value", nil];
            
            NSDictionary * param4 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[UserSongSession][topstreak]", @"Name",
                                     [NSNumber numberWithInteger:cloudRequest.m_userSongSession.m_combo], @"Value", nil];
            
            NSDictionary * param5 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[UserSongSession][notes]", @"Name",
                                     cloudRequest.m_userSongSession.m_notes, @"Value", nil];
            
            params = [NSArray arrayWithObjects:param1, param2, param3, param4, param5, nil];
            
            NSDictionary * fileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"data[UserSongSession][fileSession]", @"Name",
                                       @"session.xmp", @"Filename",
                                       cloudRequest.m_userSongSession.m_xmpBlob, @"Data", nil];
            
            files = [NSArray arrayWithObject:fileDict];
            
        } break;
            
        case CloudRequestTypeGetUserSongSessions:
        {
            
            url = CloudRequestTypeGetUserSongSessionsUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserSongSession][user_id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
            
        } break;
            
        case CloudRequestTypeAddUserFollows:
        {
            
            url = CloudRequestTypeAddUserFollowsUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserFollow][user_follow_id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeRemoveUserFollows:
        {
            
            url = CloudRequestTypeRemoveUserFollowsUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserFollow][user_follow_id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeGetUserFollowsList:
        {
            
            url = CloudRequestTypeGetUserFollowsListUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserFollow][user_id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeGetUserFollowedList:
        {
            
            url = CloudRequestTypeGetUserFollowedListUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserFollow][user_follow_id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeGetUserFollowsSongSessions:
        {
            
            url = CloudRequestTypeGetUserFollowsSongSessionsUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserFollow][user_id]", @"Name",
                                    [NSNumber numberWithInteger:cloudRequest.m_userId], @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypeGetUserGlobalSongSessions:
        {
            
            url = CloudRequestTypeGetUserGlobalSongSessionsUrl;
                        
        } break;
            
        case CloudRequestTypeRedeemCreditCode:
        {
            
            url = CloudRequestTypeRedeemCreditCodeUrl;
            
            NSDictionary * param = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"data[UserCodeRedemptions][code]", @"Name",
                                    cloudRequest.m_creditCode, @"Value", nil];
            
            params = [NSArray arrayWithObject:param];
            
        } break;
            
        case CloudRequestTypePutLog:
        {
            
            url = CloudRequestTypePutLogUrl;
            
            NSDictionary * param1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[Telemetry][app_id]", @"Name",
                                     cloudRequest.m_appString, @"Value", nil];
            
            NSDictionary * param2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[Telemetry][version_id]", @"Name",
                                     cloudRequest.m_versionString, @"Value", nil];
            
            NSDictionary * param3 = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"data[Telemetry][device_id]", @"Name",
                                     cloudRequest.m_deviceString, @"Value", nil];
            
            params = [NSArray arrayWithObjects:param1, param2, param3, nil];
            
            NSDictionary * fileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"data[Telemetry][fileLog]", @"Name",
                                       @"telemetry.log", @"Filename",
                                       cloudRequest.m_logEntries, @"Data", nil];
            
            files = [NSArray arrayWithObject:fileDict];
            
        } break;
            
        default:
        {
            
            // nothing
            
        } break;
    }
    
    (*urlString) = url;
    (*paramsArray) = params;
    (*filesArray) = files;
    
}

- (void)parseResultsForResponse:(CloudResponse*)cloudResponse
{
    
    // If the request didn't finish or failed, status = failure
    if ( cloudResponse.m_cloudRequest.m_status != CloudRequestStatusCompleted )
    {
        // Since the request didn't complete fully, we can't really trust any data we have
        cloudResponse.m_status = CloudResponseStatusConnectionError;
        cloudResponse.m_statusText = @"Connection Error";
        cloudResponse.m_receivedData = nil;
        
        return;
        
    }
    
    // Do any pre-processing. Anything that needs special 
    // attention can be done here, and optionally return.
    switch ( cloudResponse.m_cloudRequest.m_type )
    {
            
        case CloudRequestTypeGetFile:
        {
            
            if ( cloudResponse.m_statusCode == 200 )
            {
                
                // The file is already located in m_receivedData.
                cloudResponse.m_status = CloudResponseStatusSuccess;
                cloudResponse.m_statusText = @"Success";
                cloudResponse.m_responseFileId = cloudResponse.m_cloudRequest.m_fileId;
                
            }
            else
            {
                // e.g. 404, we can't trust the data
                cloudResponse.m_status = CloudResponseStatusFailure;
                cloudResponse.m_statusText = [NSString stringWithFormat:@"HTTP Status: %u", cloudResponse.m_statusCode];
                cloudResponse.m_receivedData = nil;
                
            }
            
            // Done with this response.
            return;
            
        } break;

        default:
        {
            
            if ( cloudResponse.m_statusCode == 200 )
            {
                // Do more detailed pre-processing
                [self preprocessResultsForResponse:cloudResponse];
                
            }
            else
            {
                // e.g. 404
                cloudResponse.m_status = CloudResponseStatusFailure;
                cloudResponse.m_statusText = [NSString stringWithFormat:@"HTTP Status: %u", cloudResponse.m_statusCode];
                cloudResponse.m_receivedData = nil;
                
                // Done with this response
                return;
                
            }
            
        } break;
            
    }
    
    switch ( cloudResponse.m_cloudRequest.m_type )
    {
            
        case CloudRequestTypeGetFile:
        {
            
            // Handled above, no-op
            
            
        } break;
            
        case CloudRequestTypeRegister:
        {
            
            [m_username release];
            
            m_username = [[cloudResponse.m_responseXmlDom getTextFromChildWithName:@"Username"] retain];
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            NSString * result = [dom getTextFromChildWithName:@"StatusText"];
            
            if ( [result isEqualToString:@"Ok"] == YES )
            {
                m_loggedIn = YES;
            }
            else
            {
                m_loggedIn = NO;
            }
            
            XmlDom * profileDom = [dom getChildWithName:@"UserProfile"];
            
            UserProfile * userProfile = [[[UserProfile alloc] initWithXmlDom:profileDom] autorelease];
            
            cloudResponse.m_responseUserProfile = userProfile;

            
        } break;
            
        case CloudRequestTypeLoginFacebook:
        {
            
            [m_username release];
            
            m_username = [[cloudResponse.m_responseXmlDom getTextFromChildWithName:@"Username"] retain];
            
            m_facebookAccessToken = [cloudResponse.m_cloudRequest.m_facebookAccessToken retain];
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            NSString * result = [dom getTextFromChildWithName:@"StatusText"];
            
            if ( [result isEqualToString:@"Ok"] == YES )
            {
                m_loggedIn = YES;
            }
            else
            {
                m_loggedIn = NO;
            }
            
            XmlDom * profileDom = [dom getChildWithName:@"UserProfile"];
            
            UserProfile * userProfile = [[[UserProfile alloc] initWithXmlDom:profileDom] autorelease];
            
            cloudResponse.m_responseUserProfile = userProfile;
            
        } break;
            
        case CloudRequestTypeLogin:
        {
            
            [m_username release];
            
            m_username = [[cloudResponse.m_responseXmlDom getTextFromChildWithName:@"Username"] retain];
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            NSString * result = [dom getTextFromChildWithName:@"StatusText"];
            
            if ( [result isEqualToString:@"Ok"] == YES )
            {
                m_loggedIn = YES;
            }
            else
            {
                m_loggedIn = NO;
            }
            
            XmlDom * profileDom = [dom getChildWithName:@"UserProfile"];
            
            UserProfile * userProfile = [[[UserProfile alloc] initWithXmlDom:profileDom] autorelease];
            
            cloudResponse.m_responseUserProfile = userProfile;
            
        } break;
            
        case CloudRequestTypeLoginCookie:
        {
            
            [m_username release];
            
            m_username = [[cloudResponse.m_responseXmlDom getTextFromChildWithName:@"Username"] retain];
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            NSString * result = [dom getTextFromChildWithName:@"StatusText"];
            
            if ( [result isEqualToString:@"Ok"] == YES )
            {
                m_loggedIn = YES;
            }
            else
            {
                m_loggedIn = NO;
            }
            
            XmlDom * profileDom = [dom getChildWithName:@"UserProfile"];
            
            UserProfile * userProfile = [[[UserProfile alloc] initWithXmlDom:profileDom] autorelease];
            
            cloudResponse.m_responseUserProfile = userProfile;
            
        } break;
            
        case CloudRequestTypeLogout:
        {
            
            m_loggedIn = NO;
            
            [m_facebookAccessToken release];
            
            m_facebookAccessToken = nil;
            
        } break;
            
        case CloudRequestTypeGetUserProfile:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * profileDom = [dom getChildWithName:@"UserProfile"];
            
            UserProfile * userProfile = [[[UserProfile alloc] initWithXmlDom:profileDom] autorelease];
            
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            cloudResponse.m_responseUserProfile = userProfile;
            
        } break;
            
        case CloudRequestTypeEditUserProfile:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * profileDom = [dom getChildWithName:@"UserProfile"];
            
            UserProfile * userProfile = [[[UserProfile alloc] initWithXmlDom:profileDom] autorelease];
            
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            cloudResponse.m_responseUserProfile = userProfile;
//            cloudResponse.m_image
            
        } break;
            
        case CloudRequestTypeSearchUserProfile:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * profilesDom = [dom getChildWithName:@"UserProfiles"];
            
            UserProfiles * userProfiles = [[[UserProfiles alloc] initWithXmlDom:profilesDom] autorelease];
            
            cloudResponse.m_responseUserProfiles = userProfiles;
            
        } break;
            
        case CloudRequestTypeSearchUserProfileFacebook:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * profilesDom = [dom getChildWithName:@"UserProfiles"];
            
            UserProfiles * userProfiles = [[[UserProfiles alloc] initWithXmlDom:profilesDom] autorelease];
            
            cloudResponse.m_responseUserProfiles = userProfiles;
            
        } break;
            
        case CloudRequestTypeGetUserCredits:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            cloudResponse.m_responseUserCredits = [dom getNumberFromChildWithName:@"Credits"];
            
        } break;
            
        case CloudRequestTypePurchaseSong:
        {
            
            // Nothing else to do for this
            
        } break;
            
        case CloudRequestTypeVerifyItunesReceipt:
        {
            
            // Nothing else to do for this
            
        } break;
            
        case CloudRequestTypeGetAllSongPids:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * pidsDom = [dom getChildWithName:@"AllProductIdentifiers"];
            
            NSArray * pidDomArray = [pidsDom getChildArrayWithName:@"ProductIdentifiers"];
            
            NSMutableArray * pidArray = [[NSMutableArray alloc] init];
            
            // Each element in the array is in a DOM, which is kind of annoying.
            // Iterate through and pull them out of the DOM and put into an array.
            for ( XmlDom * pidDom in pidDomArray )
            {
                NSString * pid = [pidDom getText];
                
                [pidArray addObject:pid];
            }
            
            cloudResponse.m_responseProductIds = pidArray;
            
        } break;
            
        case CloudRequestTypeGetAllSongsList:
        {
            
            // Note that this is effectively just an allias of 
            // the CloudRequestTypeGetStoreSongList request right now.
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * songsDom = [dom getChildWithName:@"AllSongsList"];
            
            UserSongs * userSongs = [[[UserSongs alloc] initWithXmlDom:songsDom] autorelease];
            
            cloudResponse.m_responseUserSongs = userSongs;
            
        } break;
            
        case CloudRequestTypeGetUserSongList:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * songsDom = [dom getChildWithName:@"UserSongsList"];
            
            UserSongs * userSongs = [[[UserSongs alloc] initWithXmlDom:songsDom] autorelease];
            
            cloudResponse.m_responseUserSongs = userSongs;
            
        } break;
            
        case CloudRequestTypeGetStoreSongList:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            XmlDom * songsDom = [dom getChildWithName:@"AllSongsList"];
            
            UserSongs * userSongs = [[[UserSongs alloc] initWithXmlDom:songsDom] autorelease];
            
            cloudResponse.m_responseUserSongs = userSongs;
            
        } break;
            
        case CloudRequestTypeGetStoreFeaturesSongList:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            // create the collection
            cloudResponse.m_responseStoreFeatureCollection = [[[StoreFeatureCollection alloc] initWithXmlDom:responseDom] autorelease];
            
        } break;
            
        case CloudRequestTypePutUserSongSession:
        {
            
            cloudResponse.m_responseUserSongSession = cloudResponse.m_cloudRequest.m_userSongSession;
        
        } break;
            
        case CloudRequestTypeGetUserSongSessions:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            UserSongSessions * userSongSessions = [[[UserSongSessions alloc] initWithXmlDom:responseDom] autorelease];
            
            cloudResponse.m_responseUserSongSessions = userSongSessions;
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            
        } break;
            
        case CloudRequestTypeAddUserFollows:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            XmlDom * userProfilesFollowsDom = [responseDom getChildWithName:@"FollowsUsers"];
            XmlDom * userProfilesFollowedDom = [responseDom getChildWithName:@"FollowedByUsers"];
            
            UserProfiles * userProfilesFollows = [[[UserProfiles alloc] initWithXmlDom:userProfilesFollowsDom] autorelease];
            UserProfiles * userProfilesFollowedBy = [[[UserProfiles alloc] initWithXmlDom:userProfilesFollowedDom] autorelease];
            UserSongSessions * userSongSessions = [[[UserSongSessions alloc] initWithXmlDom:responseDom] autorelease];
            
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            cloudResponse.m_responseUserProfilesFollows = userProfilesFollows;
            cloudResponse.m_responseUserProfilesFollowedBy = userProfilesFollowedBy;
            cloudResponse.m_responseUserSongSessions = userSongSessions;
            
        } break;
            
        case CloudRequestTypeRemoveUserFollows:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            XmlDom * userProfilesFollowsDom = [responseDom getChildWithName:@"FollowsUsers"];
            XmlDom * userProfilesFollowedDom = [responseDom getChildWithName:@"FollowedByUsers"];
            
            UserProfiles * userProfilesFollows = [[[UserProfiles alloc] initWithXmlDom:userProfilesFollowsDom] autorelease];
            UserProfiles * userProfilesFollowedBy = [[[UserProfiles alloc] initWithXmlDom:userProfilesFollowedDom] autorelease];
            UserSongSessions * userSongSessions = [[[UserSongSessions alloc] initWithXmlDom:responseDom] autorelease];
            
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            cloudResponse.m_responseUserProfilesFollows = userProfilesFollows;
            cloudResponse.m_responseUserProfilesFollowedBy = userProfilesFollowedBy;
            cloudResponse.m_responseUserSongSessions = userSongSessions;
            
        } break;
            
        case CloudRequestTypeGetUserFollowsList:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            XmlDom * userProfilesDom = [responseDom getChildWithName:@"FollowsUsers"];
            
            UserProfiles * userProfiles = [[[UserProfiles alloc] initWithXmlDom:userProfilesDom] autorelease];
            
            cloudResponse.m_responseUserProfiles = userProfiles;
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            
        } break;
            
        case CloudRequestTypeGetUserFollowedList:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            XmlDom * userProfilesDom = [responseDom getChildWithName:@"FollowedByUsers"];
            
            UserProfiles * userProfiles = [[[UserProfiles alloc] initWithXmlDom:userProfilesDom] autorelease];
            
            cloudResponse.m_responseUserProfiles = userProfiles;
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            
        } break;
            
        case CloudRequestTypeGetUserFollowsSongSessions:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            UserSongSessions * userSongSessions = [[[UserSongSessions alloc] initWithXmlDom:responseDom] autorelease];
            
            cloudResponse.m_responseUserSongSessions = userSongSessions;
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            
        } break;
            
        case CloudRequestTypeGetUserGlobalSongSessions:
        {
            
            XmlDom * responseDom = cloudResponse.m_responseXmlDom;
            
            UserSongSessions * userSongSessions = [[[UserSongSessions alloc] initWithXmlDom:responseDom] autorelease];
            
            cloudResponse.m_responseUserSongSessions = userSongSessions;
            cloudResponse.m_responseUserId = cloudResponse.m_cloudRequest.m_userId;
            
        } break;
            
        case CloudRequestTypeRedeemCreditCode:
        {
            
            XmlDom * dom = cloudResponse.m_responseXmlDom;
            
            cloudResponse.m_responseUserCredits = [dom getNumberFromChildWithName:@"Credits"];
            
        } break;
            
        case CloudRequestTypePutLog:
        {
            
        } break;
            
        default:
        {
            
            // nothing
            
        } break;
    }

    
}

- (void)preprocessResultsForResponse:(CloudResponse*)cloudResponse
{
    
    //
    // Do some generic processing of the response data
    //
    
    // Parse the received data into an XmlDom
    XmlDom * dom = [[XmlDom alloc] initWithXmlData:cloudResponse.m_receivedData];
    
    cloudResponse.m_responseXmlDom = dom;
    
    NSString * result = [dom getTextFromChildWithName:@"StatusText"];
    
    // The request connection succeeded, but did it do what we asked
    if ( [result isEqualToString:@"Ok"] )
    {
        cloudResponse.m_status = CloudResponseStatusSuccess;
    }
    else 
    {
        cloudResponse.m_status = CloudResponseStatusFailure;
    }
    
    // also see if we have been logged out as a result of this
    if ( [result isEqualToString:@"Unauthorized"] == YES )
    {
        m_loggedIn = NO;
    }
    
    NSString * detail = [dom getTextFromChildWithName:@"StatusDetail"];
    
    // Our net code is a little inconsistent on where failure reason is reported
    if ( detail != nil )
    {
        cloudResponse.m_statusText = detail;
    }
    else
    {
        cloudResponse.m_statusText = result;
    }
    
    [dom release];
    
}


             
#pragma mark -
#pragma mark NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	
    CloudResponse * cloudResponse = [self deregisterConnection:connection];
    
    cloudResponse.m_cloudRequest.m_status = CloudRequestStatusConnectionError;
    
    [self cloudReceiveResponse:cloudResponse];
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response  
{  

    CloudResponse * cloudResponse = [self getReponseForConnection:connection];
    
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    
//    cloudResponse.m_status = CloudResponseStatusReceivingData;
    
    cloudResponse.m_cloudRequest.m_status = CloudRequestStatusReceivingData;
    
    cloudResponse.m_mimeType = [httpResponse MIMEType];
    
    cloudResponse.m_statusCode = [httpResponse statusCode];
    
    cloudResponse.m_receivedData = [[[NSMutableData alloc] init] autorelease];
    cloudResponse.m_receivedData.length = 0;

}   

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  
{  
    
    CloudResponse * cloudResponse = [self getReponseForConnection:connection];
    
    [cloudResponse.m_receivedData appendData:data];
    
}  

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{  
	
    CloudResponse * cloudResponse = [self deregisterConnection:connection];
    
    cloudResponse.m_receivedDataString = [NSString stringWithCString:(char*)[cloudResponse.m_receivedData bytes] encoding:NSASCIIStringEncoding];
    
    cloudResponse.m_cloudRequest.m_status = CloudRequestStatusCompleted;

//    [self cloudReceiveResponse:cloudResponse];
    [self performSelectorInBackground:@selector(cloudReceiveResponse:) withObject:cloudResponse];
    
}

@end
