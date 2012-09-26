//
//  CloudController.h
//  gTar
//
//  Created by wuda on 11/10/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserSongs.h"

@protocol CloudControllerDelegate

- (void)authenticationSuccess;
- (void)authenticationFailure;
- (void)receivedSongsXml:(UserSongs*)userSongs;
- (void)receivedSongXmp:(NSString*)xmpBlob;

@end


enum CloudControllerRequestType
{
	RequestTypeNone = 0,
	RequestTypeAuthentication,
	RequestTypeGetSongXmp,
	RequestTypeGetSongsXml
};

@interface CloudController : NSObject
{
	id<CloudControllerDelegate> m_delegate;
	
	NSString * m_username;
	NSString * m_password;
	NSString * m_servername;

	NSMutableData * m_receivedData;
	
	CloudControllerRequestType m_currentRequestType;
	
	NSString * m_songsXml;
	
	UserSongs * m_userSongs;
	
	Boolean m_authenticated;
	
}

@property (nonatomic, readonly) CloudControllerRequestType m_currentRequestType;
@property (nonatomic, readonly) UserSongs * m_userSongs;
@property (nonatomic, readonly) Boolean m_authenticated;

- (CloudController*)initWithUsername:(NSString*)username andPassword:(NSString*)password andDelegate:(id<CloudControllerDelegate>)delegate;
- (void)authenticate;
- (void)getSongsXml;
- (void)getSongXmp:(UserSong*)userSong;
- (void)getSongXmpWithSongId:(NSInteger)songId;
- (void)invalidateDelegate;

@end
