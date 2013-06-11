//
//  UserController.h
//  gTarAppCore
//
//  Created by Marty Greenia on 9/14/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CloudResponse;
@class CloudController;
@class UserProfile;
@class UserEntry;
@class UserSongSession;

@interface UserController : NSObject
{
    
    // This doesn't log out untill the user actively logs out
    NSString * m_loggedInUsername;
    NSString * m_loggedInPassword;
    NSString * m_loggedInFacebookToken;
    UserProfile * m_loggedInUserProfile;
    
    NSString * m_userFilePath;
    
    CloudController * m_cloudController;
    
    NSMutableDictionary * m_userCache;
    NSMutableDictionary * m_starCache;
    NSMutableDictionary * m_scoreCache;
    
    NSMutableArray * m_pendingUserSongSessionUploads;
    
    NSMutableDictionary * m_cloudToUserRequest;
    
}

@property (nonatomic, readonly) NSString * m_loggedInUsername;
@property (nonatomic, readonly) UserProfile * m_loggedInUserProfile;
@property (nonatomic, readonly) NSString * m_loggedInFacebookToken;

- (id)initWithCloudController:(CloudController*)cloudController;

- (void)clearCache;
- (void)loadCache;
- (void)saveCache;
- (void)saveCacheAsync;
//- (void)saveCookie:(NSHTTPCookie*)cookie;
//- (NSHTTPCookie*)loadCookie;
- (void)requestLoginUserCachedCallbackObj:(id)obj andCallbackSel:(SEL)sel;

// account
- (void)requestSignupUser:(NSString*)username andPassword:(NSString*)password andEmail:(NSString*)email andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestSignupUserCallback:(CloudResponse*)cloudResponse;

- (void)requestLoginUser:(NSString*)username andPassword:(NSString*)password andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestLoginUserCallback:(CloudResponse*)cloudResponse;

- (void)requestLoginUserFacebookToken:(NSString*)facebookToken andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestLoginUserFacebookTokenCallback:(CloudResponse*)cloudResponse;

//- (void)requestLoginUserCookieCallbackObj:(id)obj andCallbackSel:(SEL)sel;
//- (void)requestLoginUserCookieCallback:(CloudResponse*)cloudResponse;

- (void)requestLogoutUserCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestLogoutUserCallback:(CloudResponse*)cloudResponse;

// profile info
- (void)requestUserProfile:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserProfileCallback:(CloudResponse*)cloudResponse;

- (void)requestUserProfileChangePicture:(UIImage*)image andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserProfileChangePictureCallback:(CloudResponse *)cloudResponse;

- (void)requestUserProfileSearch:(NSString*)search andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserProfileSearchCallback:(CloudResponse*)cloudResponse;

- (void)requestUserSessions:(NSInteger)userId andPage:(NSInteger)page andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserSessionsCallback:(CloudResponse*)cloudResponse;

- (void)requestAddUserFollow:(NSInteger)friendUserId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestAddUserFollowCallback:(CloudResponse*)cloudResponse;

- (void)requestRemoveUserFollow:(NSInteger)friendUserId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestRemoveUserFollowCallback:(CloudResponse*)cloudResponse;

- (void)requestUserFollowsSessions:(NSInteger)userId andPage:(NSInteger)page andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserFollowsSessionsCallback:(CloudResponse*)cloudResponse;

//- (void)requestUserGlobalSessionsCallbackObj:(id)obj andCallbackSel:(SEL)sel;
//- (void)requestUserGlobalSessionsCallback:(CloudResponse*)cloudResponse;

- (void)requestUserFollows:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserFollowsCallback:(CloudResponse*)cloudResponse;

- (void)requestUserFollowedBy:(NSInteger)userId andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserFollowedByCallback:(CloudResponse*)cloudResponse;

- (void)requestUserFacebookFriends:(NSString*)accessToken andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserFacebookFriendsCallback:(CloudResponse*)cloudResponse;

- (void)requestUserSongSessionUpload:(UserSongSession*)songSession andCallbackObj:(id)obj andCallbackSel:(SEL)sel;
- (void)requestUserSongSessionUploadCallback:(CloudResponse*)cloudResponse;

// Accesors
- (UserEntry*)getUserEntry:(NSInteger)userId;
- (void)setUserProfileForUserId:(NSInteger)userId toProfile:(UserProfile*)profile;
- (void)setSessionsForUserId:(NSInteger)userId toList:(NSArray*)list forPage:(NSInteger)page;
- (void)setFollowsForUserId:(NSInteger)userId toList:(NSArray*)list;
- (void)setFollowedByForUserId:(NSInteger)userId toList:(NSArray*)list;
- (void)setFacebookFriendsForUserId:(NSInteger)userId toList:(NSArray*)list;
- (void)setFollowsSessionsForUserId:(NSInteger)userId toList:(NSArray*)list;

// Uploading
- (BOOL)isUserSongSessionQueueFull;
- (void)queueUserSongSession:(UserSongSession*)songSession;
//- (void)queueAndSendUserSongSession:(UserSongSession*)songSession;
- (void)finishedUploadingSession:(UserSongSession*)songSession;
- (void)sendPendingUploads;

// Scores
- (void)addStars:(NSInteger)stars forSong:(NSInteger)songId;
- (NSInteger)getMaxStarsForSong:(NSInteger)songId;
- (void)addScore:(NSInteger)score forSong:(NSInteger)songId;
- (NSInteger)getMaxScoreForSong:(NSInteger)songId;

// Misc
- (BOOL)checkLoggedInUserFollows:(UserProfile *)userProfile;
- (BOOL)checkLoggedInUserFollowedBy:(UserProfile *)userProfile;

@end
