//
//  CloudCacheEntry.h
//  gTar
//
//  Created by Marty Greenia on 11/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSong.h"


@interface CloudCacheEntry : NSObject <NSCoding>
{

//	NSInteger m_songId;
//	NSString * m_title;
//	NSString * m_description;
//	NSString * m_xmpPath;
	//	NSInteger m_timeModified;

	UserSong * m_userSong;

	// Meta data about the user song
	NSTimeInterval m_lastUpdate;
	
	bool m_current;
	
}

//@property (nonatomic) NSInteger m_songId;
//@property (nonatomic, retain) NSString * m_title;
//@property (nonatomic, retain) NSString * m_description;
//@property (nonatomic, retain) NSString * m_xmpPath;
//@property (nonatomic) NSInteger m_timeModified;
@property (nonatomic, retain) UserSong * m_userSong;
@property (nonatomic) NSTimeInterval m_lastUpdate;
@property (nonatomic) bool m_current;


@end
