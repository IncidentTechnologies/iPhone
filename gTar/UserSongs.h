//
//  UserSongs.h
//  gTar
//
//  Created by wuda on 11/11/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserSong.h"

@interface UserSongs : NSObject
{

	NSString * m_songsXml;
	
	NSMutableArray * m_songsArray;
	
	// Parsing variables
	UserSong * m_currentSong;
	
	NSMutableString * m_accumulatedText; 

}

@property (nonatomic, retain) NSString * m_songsXml;
@property (nonatomic, readonly) NSMutableArray * m_songsArray;

- (UserSong*)getSongWithSongId:(NSInteger)songId;

@end
