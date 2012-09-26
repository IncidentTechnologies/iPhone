//
//  UserSong.m
//  gTar
//
//  Created by wuda on 11/11/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "UserSong.h"


@implementation UserSong

@synthesize m_songId, m_authorId, m_title, m_author, m_genre, m_description, m_urlPath, m_timeCreated, m_timeModified;

// just a container class, doesn't have anything else
// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{

	[coder encodeInteger:m_songId forKey:@"SongId"];
	[coder encodeInteger:m_authorId forKey:@"AuthorId"];
	
	[coder encodeObject:m_title forKey:@"Title"];
	[coder encodeObject:m_author forKey:@"Author"];
	[coder encodeObject:m_genre forKey:@"Genre"];
	[coder encodeObject:m_description forKey:@"Description"];
	[coder encodeObject:m_urlPath forKey:@"UrlPath"];
	
    [coder encodeInteger:m_timeModified forKey:@"TimeModified"];
    [coder encodeInteger:m_timeCreated forKey:@"TimeCreated"];

}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{
    //self = [super initWithCoder:coder];
	self = [super init];
	
    self.m_songId = [coder decodeIntegerForKey:@"SongId"];
	self.m_authorId = [coder decodeIntegerForKey:@"AuthorId"];
	
    self.m_title = [coder decodeObjectForKey:@"Title"];
	self.m_author = [coder decodeObjectForKey:@"Author"];
	self.m_genre = [coder decodeObjectForKey:@"Genre"];
    self.m_description = [coder decodeObjectForKey:@"Description"];
	self.m_urlPath = [coder decodeObjectForKey:@"UrlPath"]; 
	
	self.m_timeModified = [coder decodeIntegerForKey:@"TimeModified"];
	self.m_timeCreated = [coder decodeIntegerForKey:@"TimeCreated"];

	return self;
}

- (void)dealloc
{
	
	[m_title release];
	[m_author release];
	[m_genre release];
	[m_description release];
	[m_urlPath release];

}

@end
