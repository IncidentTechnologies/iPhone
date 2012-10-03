//
//  CloudRequest3.h
//  gTarAppCore
//
//  Created by Marty Greenia on 4/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

@class CloudResponse;
@class UserSong;
@class UserSongSession;
@class UIImage;

typedef enum
{
	CloudRequestStatusUnknown = 0,
    CloudRequestStatusSent,
    CloudRequestStatusReceivingData,
    CloudRequestStatusCompleted,
    CloudRequestStatusConnectionError
} CloudRequestStatus;

typedef enum
{
    CloudRequestTypeUnknown = 0,
    
    CloudRequestTypeGetFile,
    
    CloudRequestTypeRegister,
    CloudRequestTypeLoginFacebook,
    CloudRequestTypeLogin,
    CloudRequestTypeLoginCookie,
    CloudRequestTypeLogout,
    
    CloudRequestTypeGetUserProfile,
    CloudRequestTypeEditUserProfile,
    CloudRequestTypeSearchUserProfile,
    CloudRequestTypeSearchUserProfileFacebook,
    CloudRequestTypeGetUserCredits,
    CloudRequestTypePurchaseSong,
    CloudRequestTypeVerifyItunesReceipt,
    
    CloudRequestTypeGetAllSongPids,
    CloudRequestTypeGetAllSongsList,
    CloudRequestTypeGetUserSongList,
    CloudRequestTypeGetStoreSongList,
    CloudRequestTypeGetStoreFeaturesSongList,
    
    CloudRequestTypePutUserSongSession,
    CloudRequestTypeGetUserSongSessions,
    
    CloudRequestTypeAddUserFollows,
    CloudRequestTypeRemoveUserFollows,
    CloudRequestTypeGetUserFollowsList,
    CloudRequestTypeGetUserFollowedList,
    CloudRequestTypeGetUserFollowsSongSessions,
    CloudRequestTypeGetUserGlobalSongSessions,
    
    CloudRequestTypeRedeemCreditCode,
    
    CloudRequestTypePutLog
    
} CloudRequestType;

@interface CloudRequest : NSObject
{
    
    CloudResponse * m_cloudResponse;
    
    // Async callbacks 
	id m_callbackObject;
	SEL m_callbackSelector;
    
    CloudRequestType m_type;
	CloudRequestStatus m_status;
    
    BOOL m_isSynchronous;
    
    //
    // Request specific parameters
    //
    
    // CloudRequestTypeLoginFacebook
    NSString * m_facebookAccessToken;
    
    // CloudRequestTypeLogin, CloudRequestTypeRegister
    NSString * m_username;
    NSString * m_password;
    NSString * m_email;
    NSHTTPCookie * m_cookie;
    
    // CloudRequestTypeGetFile
    NSInteger m_fileId;
    
    // CloudRequestTypeGetUserProfile, CloudRequestTypeGetUserSongSessions,
    // CloudRequestTypeAddUserFollows, CloudRequestTypeRemoveUserFollows,
    // CloudRequestTypeGetUserFollowedList, CloudRequestTypeGetUserFollowsSongSessions,
    NSInteger m_userId;
    
    // CloudRequestTypeSearchUserProfile
    NSString * m_searchString;
    
    // CloudRequestTypeRedeemCreditCode
    NSString * m_creditCode;
    
    // CloudRequestTypePurchaseSong
    UserSong * m_userSong;
    
    // CloudRequestTypePutUserSongSession
    UserSongSession * m_userSongSession;
    
    // CloudRequestTypeVerifyItunesReceipt
    NSData * m_itunesReceipt;
    
    // CloudRequestTypeEditUserProfile 
    UIImage * m_profileImage;
    
    // CloudRequestTypePutLog
    NSString * m_logEntries;
    NSString * m_versionString;
    NSString * m_deviceString;
    NSString * m_appString;
    
}

@property (nonatomic, assign) CloudResponse * m_cloudResponse;

@property (nonatomic, readonly) id m_callbackObject;
@property (nonatomic, readonly) SEL m_callbackSelector;

@property (nonatomic, readonly) CloudRequestType m_type;
@property (nonatomic, assign) CloudRequestStatus m_status;
@property (nonatomic, readonly) BOOL m_isSynchronous;

@property (nonatomic, retain) NSString * m_facebookAccessToken;
@property (nonatomic, retain) NSString * m_username;
@property (nonatomic, retain) NSString * m_password;
@property (nonatomic, retain) NSString * m_email;
@property (nonatomic, retain) NSHTTPCookie * m_cookie;
@property (nonatomic, assign) NSInteger m_fileId;
@property (nonatomic, assign) NSInteger m_userId;
@property (nonatomic, retain) NSString * m_searchString;
@property (nonatomic, retain) NSString * m_creditCode;
@property (nonatomic, retain) UserSong * m_userSong;
@property (nonatomic, retain) UserSongSession * m_userSongSession;
@property (nonatomic, retain) NSData * m_itunesReceipt;
@property (nonatomic, retain) UIImage * m_profileImage;
@property (nonatomic, retain) NSString * m_logEntries;
@property (nonatomic, retain) NSString * m_versionString;
@property (nonatomic, retain) NSString * m_deviceString;
@property (nonatomic, retain) NSString * m_appString;

- (id)initWithType:(CloudRequestType)type;
- (id)initWithType:(CloudRequestType)type andCallbackObject:(id)obj andCallbackSelector:(SEL)sel;


@end
