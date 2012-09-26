//
//  CloudCache.m
//  gTar
//
//  Created by Marty Greenia on 11/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "CloudCache.h"
#import "UserSongs.h"

@implementation CloudCache

- (CloudCache*)init
{
	if ( self = [super init] )
	{
		
		m_cache = [[NSMutableDictionary alloc] init];
		
	}
	
	return self;
}

- (void)dealloc
{
	
	[m_cache release];
	
	[super dealloc];
	
}

- (void)populateCache:(UserSongs*)userSongs
{
	
	for ( unsigned int songIndex = 0; songIndex < [userSongs.m_songsArray count]; songIndex++ )
	{

		UserSong * song = [userSongs.m_songsArray objectAtIndex:songIndex];

		[self setCacheEntryWithUserSong:song];

	}
/*
	// fake entries for now.
	CloudCacheEntry * entry = [self getCacheEntryWithSongId:1234];
	if ( entry == nil )
	{
		entry = [[CloudCacheEntry alloc] init];
	}
	entry.m_title = @"Poker face";
	entry.m_songId = 1234;
	entry.m_description = @"A song by some lady";
	[self setCacheEntry:entry];
	
	entry = [self getCacheEntryWithSongId:1235];
	if ( entry == nil )
	{
		entry = [[CloudCacheEntry alloc] init];
	}
	entry.m_title = @"Stairway to Marty";
	entry.m_songId = 1235;
	entry.m_description = @"A song by some guy";
	[self setCacheEntry:entry];
	
	entry = [self getCacheEntryWithSongId:1236];
	if ( entry == nil )
	{
		entry = [[CloudCacheEntry alloc] init];
	}
	entry.m_title = @"Telephone";
	entry.m_songId = 1236;
	entry.m_description = @"A song by some lady";
	[self setCacheEntry:entry];
	
	entry = [self getCacheEntryWithSongId:1237];
	if ( entry == nil )
	{
		entry = [[CloudCacheEntry alloc] init];
	}
	entry.m_title = @"Aerodynamic SOLO";
	entry.m_songId = 1237;
	entry.m_description = @"A song by some robots";
	[self setCacheEntry:entry];

	entry = [self getCacheEntryWithSongId:1238];
	if ( entry == nil )
	{
		entry = [[CloudCacheEntry alloc] init];
	}
	entry.m_title = @"Aerodynamic";
	entry.m_songId = 1238;
	entry.m_description = @"A song by some robots";
	[self setCacheEntry:entry];
	*/
}

#pragma mark -
#pragma mark NSCoder functions

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
//    [super encodeWithCoder:coder];
	
    [coder encodeObject:m_cache forKey:@"Cache"];

}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
//    self = [super initWithCoder:coder];
	self = [super init];

    m_cache = [[coder decodeObjectForKey:@"Cache"] retain];
	
	return self;

}

#pragma mark Entry get/set 

- (CloudCacheEntry*)getCacheEntryWithUserSong:(UserSong*)userSong
{
	return [m_cache objectForKey:[NSNumber numberWithInt:userSong.m_songId]];
}
/*
- (CloudCacheEntry*)getCacheEntryWithSongId:(NSInteger)songId
{
	
	CloudCacheEntry * entry = [m_cache objectForKey:[NSNumber numberWithInt:songId]];
	
	return entry;
	
}
*/
- (CloudCacheEntry*)getCacheEntryAtIndex:(NSInteger)index
{
	
	NSArray * allValue = [m_cache allValues];
	
	return [allValue objectAtIndex:index];
						  
}

- (void)setCacheEntry:(CloudCacheEntry*)cacheEntry
{
	
	NSNumber * songId = [NSNumber numberWithInt:cacheEntry.m_userSong.m_songId];
	
	// No return value from this setter..
	[m_cache setObject:cacheEntry forKey:songId];
	
}
	
- (void)setCacheEntryWithUserSong:(UserSong*)userSong
{

	CloudCacheEntry * entry = [self getCacheEntryWithUserSong:userSong];
	
	if ( entry == nil )
	{
		entry = [[CloudCacheEntry alloc] init];
		
		entry.m_userSong = userSong;
		
		entry.m_current = NO;
	}
	else
	{

		// The 'new' entry is actually older, don't do anything
		if ( entry.m_userSong.m_timeModified >= userSong.m_timeModified )
		{
			entry.m_current = YES;
		}
		else 
		{
			// Otherwise replace the old entry
			if ( entry.m_userSong != userSong )
			{
				entry.m_userSong = userSong;
				
				entry.m_current = NO;
			}
			
		}
		

	}

	[self setCacheEntry:entry];

}

- (NSInteger)getCacheSize
{
	
	return [m_cache count];
}

- (NSString*)getXmpForUserSong:(UserSong*)userSong
{

	CloudCacheEntry * entry = [self getCacheEntryWithUserSong:userSong];
	
	if ( entry == nil )
	{
		return nil;
	}
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName = [NSString stringWithFormat:@"%u.xmp", userSong.m_songId];
	
	NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	return [NSString stringWithContentsOfFile:xmpPath];
	
}
/*
- (void)setXmp:(NSString*)xmpBlob forEntry:(CloudCacheEntry*)cacheEntry
{
	
	NSInteger songId = cacheEntry.m_songId;

	[self setXmp:xmpBlob forSongId:songId];
}
*/
- (void)setXmp:(NSString*)xmpBlob forUserSong:(UserSong*)userSong
{

	CloudCacheEntry * entry = [self getCacheEntryWithUserSong:userSong];
	
	if ( entry == nil )
	{
		return;
	}
	
	// save the last update time
	entry.m_lastUpdate = [NSDate timeIntervalSinceReferenceDate];
	entry.m_current = YES;
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName = [NSString stringWithFormat:@"%u.xmp", userSong.m_songId];
	
	NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	[xmpBlob writeToFile:xmpPath atomically:YES];

}

#pragma mark Archiver coder

- (BOOL)saveArchive
{
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:@"CloudCache.archive"];

	return [NSKeyedArchiver archiveRootObject:self toFile:archivePath];
	
}

+ (CloudCache*)loadArchive
{

	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];

	NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:@"CloudCache.archive"];

	CloudCache * cache = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
	NSInteger size = [cache getCacheSize];
	
	[cache retain];
	
	return cache;
	
}

@end
