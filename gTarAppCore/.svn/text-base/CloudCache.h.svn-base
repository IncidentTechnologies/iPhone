//
//  CloudCache.h
//  gTar
//
//  Created by Marty Greenia on 11/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CloudController;
@class UserSong;
@class UserSongs;
@class UserSongSession;
@class CloudResponse;

@protocol CloudCacheDelegate

- (void)cloudCacheReceivedSongList:(id)cloudCache;
- (void)cloudCache:(id)cloudCache receivedXmpBlob:(NSString*)xmpBlob forEntry:(UserSong*)userSong;
- (void)cloudCacheLoggedOut:(id)cloudCache;

@end

@interface CloudCache : NSObject <NSCoding>
{

	id<CloudCacheDelegate> m_delegate;
	
	CloudController * m_cloudController;

    NSMutableArray * m_userSongArray;

    NSMutableArray * m_updatingUserSongs;
    NSMutableArray * m_requestedUserSongs;
    
    // local caches
    NSMutableDictionary * m_highScoreCache;
	NSMutableDictionary * m_starsCache;
    
    NSMutableArray * m_updatingUserSongSessions;
    NSMutableArray * m_postingUserSongSessions;
    
}

@property (nonatomic, readonly) NSArray * m_userSongArray;

//- (void)sharedInit;
- (id)initWithCloudController:(CloudController*)cloudController andDelegate:(id)delegate;

// External
- (void)refreshSongList;
- (void)refreshSongXmpCache;
- (void)requestSongXmp:(UserSong*)userSong;

// Internal
- (void)setXmpBlob:(NSString*)xmpBlob forUserSong:(UserSong*)userSong;
- (NSString*)getXmpBlobForUserSong:(UserSong*)userSong;
- (void)deleteLocalXmp:(UserSong*)userSong;

// Cloud
- (void)uploadUserSongSession:(UserSongSession*)songSession;
- (void)facebookPostUserSongSession:(UserSongSession*)songSession;

// Archive
- (BOOL)saveArchive;

// Callbacks
- (void)requestSongListCallback:(CloudResponse*)cloudResponse;
- (void)requestUserSongXmpCallback:(CloudResponse*)cloudResponse;
- (void)requestUploadUserSongSessionCallback:(CloudResponse*)cloudResponse;
- (void)requestFacebookPostUserSongSessionCallback:(CloudResponse*)cloudResponse;


@end
