//
//  CloudController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 4/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserProfile;
@class UserSong;
@class UserSongSession;
@class CloudRequest;
@class CloudResponse;

@interface CloudController : NSObject
{
    
    BOOL m_online;
    BOOL m_loggedIn;
    
    NSString * m_username;
    NSString * m_facebookAccessToken;
    
	// Request->Response mapping
	NSMutableDictionary * m_requestResponseDictionary;
    
    // Connection->Request mapping
    NSMutableDictionary * m_connectionResponseDictionary;
    
    NSMutableArray * m_requestQueue;
    
    NSString * m_serverName;
    NSString * m_serverRoot;
    
    NSInteger m_errorsRecently;
	
}

@property (nonatomic, readonly) BOOL m_loggedIn;
@property (nonatomic, readonly) NSString * m_username;
@property (nonatomic, readonly) NSString * m_facebookAccessToken;

- (id)initWithServer:(NSString*)serverName;

// Misc

//- (NSHTTPCookie*)getCakePhpCookie;
//- (void)setCakePhpCookie:(NSHTTPCookie*)cookie;

- (void)handleError;
- (void)errorWindowFinished;
- (void)queryOnlineStatus;
- (void)receiveOnlineStatus:(CloudResponse*)cloudResponse;

//
// Syncronous convenience functions
//
- (BOOL)requestServerStatus;
- (BOOL)requestItunesServerStatus;
- (NSNumber*)requestUserCredits;

//
// external request access
//
- (CloudRequest*)requestServerStatusCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestFile:(NSInteger)fileId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;

- (CloudRequest*)requestRegisterUsername:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
//- (void)requestRegisterUsername:(NSString*)username andFacebookAccessToken:(NSString*)facebookAccessToken andEmail:(NSString*)email andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestLoginUsername:(NSString*)username andPassword:(NSString*)password andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
//- (CloudRequest*)requestLoginWithCookie:(NSHTTPCookie*)cookie andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestFacebookLoginWithToken:(NSString*)accessToken andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestLogoutCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestUserProfile:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestUserProfileEdit:(NSString*)name andEmail:(NSString*)email andImage:(UIImage*)profPic andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestUserProfileSearch:(NSString*)search andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestUserProfileFacebookSearch:(NSString*)accessToken andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestUserCreditsCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestPurchaseSong:(UserSong*)userSong andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestVerifyReceipt:(NSData*)receipt andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestRedeemCreditCode:(NSString*)creditCode andCallbackObj:(id)obj andCallbackSel:(SEL)sel;

- (CloudRequest*)requestSongListCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestFeaturedSongListCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestSongStoreListCallbackObj:(id)obj andCallbackSel:(SEL)sel;

- (CloudRequest*)requestUploadUserSongSession:(UserSongSession*)songSession andCallbackObj:(id)obj andCallbackSel:(SEL)sel;

- (CloudRequest*)requestUserSessions:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestAddFollowUser:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestRemoveFollowUser:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestFollowsList:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestFollowedByList:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestFollowsSessions:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestGlobalSessionsCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestLogUpload:(NSString*)log andVersion:(NSString*)version andDevice:(NSString*)device andApp:(NSString*)app andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (CloudRequest*)requestCurrentFirmwareVersionCallbackObj:(id)obj andCallbackSel:(SEL)sel;
// new

- (void)registerConnection:(NSURLConnection*)connection toResponse:(CloudResponse*)cloudResponse;
- (CloudResponse*)getReponseForConnection:(NSURLConnection*)connection;
- (CloudResponse*)deregisterConnection:(NSURLConnection*)connection;

- (CloudResponse*)cloudSendRequest:(CloudRequest*)cloudRequest;
- (CloudResponse*)cloudProcessRequest:(CloudRequest*)cloudRequest;
- (void)cloudReceiveResponse:(CloudResponse*)cloudResponse;
- (void)cloudReturnResponse:(CloudResponse*)cloudResponse;

- (NSURLRequest*)createPostForRequest:(CloudRequest*)cloudRequest;
- (void)marshalArgumentsForRequest:(CloudRequest*)cloudRequest withUrl:(NSString**)urlString andParameters:(NSArray**)paramsArray andFiles:(NSArray**)filesArray;
- (void)parseResultsForResponse:(CloudResponse*)cloudResponse;
- (void)preprocessResultsForResponse:(CloudResponse*)cloudResponse;

@end
