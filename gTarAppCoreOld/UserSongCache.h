//
//  UserSongCache.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/21/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "UserSongs.h"
#import "UserSong.h"

#import "CloudController.h"

@interface UserSongCache : NSObject
{
	
	NSMutableArray * m_userSongCache;
	
}

- (void)setUserSongs:(UserSongs*)userSongs;

- (NSInteger)getEntryCount;
- (NSString*)getEntryTitle:(NSInteger)index;
- (NSString*)getEntryAuthor:(NSInteger)index;
- (NSInteger)getEntryScore:(NSInteger)index;
- (NSInteger)getEntryStars:(NSInteger)index;
- (void)requestEntryXmpBlob:(NSInteger)index;

// Indirection
- (void)setEntry:(UserSong*)userSong atIndex:(NSInteger)index;
- (UserSong*)getEntryAtIndex:(NSInteger)index;

// Internal
- (void)setXmpBlob:(NSString*)xmpBlob forUserSong:(UserSong*)userSong;
- (NSString*)getXmpBlobForUserSong:(UserSong*)userSong;


@end
