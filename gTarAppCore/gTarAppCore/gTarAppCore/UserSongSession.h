//
//  UserSongSession.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/21/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class UserSong;
@class UserProfile;
@class XmlDom;

@interface UserSongSession : NSObject <NSCoding>
{

    User * m_user;
    UserProfile * m_userProfile;
    UserSong * m_userSong;
    
	NSInteger m_sessionId;
	NSInteger m_songId;
	NSInteger m_userId;
	NSInteger m_score;
	NSInteger m_scoreMax;
	NSInteger m_stars;
	NSInteger m_combo;
	NSInteger m_xmpFileId;
    NSInteger m_created;

	NSString * m_notes;
	NSString * m_xmpBlob;
	
}

@property (nonatomic, retain) User * m_user;
@property (nonatomic, retain) UserProfile * m_userProfile;
@property (nonatomic, retain) UserSong * m_userSong;

@property (nonatomic, assign) NSInteger m_sessionId;
@property (nonatomic, assign) NSInteger m_songId;
@property (nonatomic, assign) NSInteger m_userId;
@property (nonatomic, assign) NSInteger m_score;
@property (nonatomic, assign) NSInteger m_scoreMax;
@property (nonatomic, assign) NSInteger m_stars;
@property (nonatomic, assign) NSInteger m_combo;
@property (nonatomic, assign) NSInteger m_xmpFileId;
@property (nonatomic, assign) NSInteger m_created;

@property (nonatomic, retain) NSString * m_notes;
@property (nonatomic, retain) NSString * m_xmpBlob;

- (id)initWithXmlDom:(XmlDom*)xmlDom;
- (NSComparisonResult)compareCreated:(id)anObject;
- (NSComparisonResult)compareCreatedNewestFirst:(id)anObject;

@end
