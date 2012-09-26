//
//  UserSong.h
//  gTar
//
//  Created by wuda on 11/11/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserSong : NSObject <NSCoding>
{

	NSInteger m_songId;
	NSInteger m_authorId;
	
	NSString * m_title;
	NSString * m_author;
	NSString * m_genre;
	NSString * m_description;
	NSString * m_urlPath;
	
	NSInteger m_timeCreated;
	NSInteger m_timeModified;
	
}


@property (nonatomic, assign) NSInteger m_songId;
@property (nonatomic, assign) NSInteger m_authorId;

@property (nonatomic, retain) NSString * m_title;
@property (nonatomic, retain) NSString * m_author;
@property (nonatomic, retain) NSString * m_genre;
@property (nonatomic, retain) NSString * m_description;
@property (nonatomic, retain) NSString * m_urlPath;

@property (nonatomic, assign) NSInteger m_timeCreated;
@property (nonatomic, assign) NSInteger m_timeModified;

@end
