//
//  CloudCacheEntry.m
//  gTar
//
//  Created by Marty Greenia on 11/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "CloudCacheEntry.h"


@implementation CloudCacheEntry

//@synthesize m_songId, m_title, m_description, m_lastUpdate, m_timeModified, m_current;
//@synthesize m_xmpPath;
@synthesize m_userSong, m_lastUpdate, m_current;

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{
//    [super encodeWithCoder:coder];
/*
	[coder encodeInteger:m_songId forKey:@"SongId"];
	[coder encodeObject:m_title forKey:@"Title"];
	[coder encodeObject:m_description forKey:@"Description"];
//	[coder encodeObject:m_xmpPath forKey:@"XmpPath"];

    [coder encodeDouble:m_lastUpdate forKey:@"LastUpdate"];
    [coder encodeInteger:m_timeModified forKey:@"TimeModified"];
*/
	[coder encodeObject:m_userSong forKey:@"UserSong"];
	[coder encodeDouble:m_lastUpdate forKey:@"LastUpdate"];
	[coder encodeBool:m_current forKey:@"Current"];
	
}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
    //self = [super initWithCoder:coder];
	self = [super init];
/*
    m_songId = [coder decodeIntegerForKey:@"SongId"];
    m_title = [[coder decodeObjectForKey:@"Title"] retain];
    m_description = [[coder decodeObjectForKey:@"Description"] retain];
//    m_xmpPath = [[coder decodeObjectForKey:@"XmpPath"] retain];

    m_lastUpdate = [coder decodeDoubleForKey:@"LastUpdate"];
	m_timeModified = [coder decodeIntegerForKey:@"TimeModified"];
*/	
	
	self.m_userSong = [coder decodeObjectForKey:@"UserSong"];
	self.m_lastUpdate = [coder decodeDoubleForKey:@"LastUpdate"];
	self.m_current = [coder decodeBoolForKey:@"Current"];
	
	return self;
}

@end
