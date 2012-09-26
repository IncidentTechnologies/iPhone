//
//  CloudCache.h
//  gTar
//
//  Created by Marty Greenia on 11/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudCacheEntry.h"
#import "UserSongs.h"
#import "UserSong.h"

@interface CloudCache : NSObject <NSCoding>
{

	NSMutableDictionary * m_cache;
	
}

- (CloudCache*)init;
- (void)populateCache:(UserSongs*)userSongs;
- (NSInteger)getCacheSize;

- (NSString*)getXmpForUserSong:(UserSong*)userSong;
- (CloudCacheEntry*)getCacheEntryWithUserSong:(UserSong*)userSong;
//- (CloudCacheEntry*)getCacheEntryWithSongId:(NSInteger)songId;
- (CloudCacheEntry*)getCacheEntryAtIndex:(NSInteger)index;

- (void)setCacheEntry:(CloudCacheEntry*)cacheEntry;

//- (void)setXmp:(NSString*)xmpBlob forEntry:(CloudCacheEntry*)cacheEntry;
- (void)setXmp:(NSString*)xmpBlob forUserSong:(UserSong*)userSong;


- (BOOL)saveArchive;
+ (CloudCache*)loadArchive;



@end
