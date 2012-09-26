//
//  CloudCache.m
//  gTar
//
//  Created by Marty Greenia on 11/22/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "CloudCache.h"

#import "CloudController.h"
#import "UserSong.h"
#import "UserSongs.h"
#import "UserSongSession.h"
#import "CloudResponse.h"

@implementation CloudCache

@synthesize m_userSongArray;

- (id)initWithCloudController:(CloudController*)cloudController andDelegate:(id)delegate
{
	
	// try to load this cache from the file system
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
    NSString * username = cloudController.m_username;
    
    if ( username == nil )
    {
        // need a username
        return nil;
    }
    
    NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"CloudCache.%@.archive",username]];
	
	// do I need to retain myself here? I'm pretty sure yes, because nothing is 
	// being explicitly 'alloc' so no reference is taken otherwise.
	CloudCache * archivedCache = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
	
	if ( archivedCache != nil )
	{
		
		self = [archivedCache retain];
        		
	}
	else if ( self = [super init] )
	{
        
		// unarchiving failed, starting from scratch
        m_highScoreCache = [[NSMutableDictionary alloc] init];
        m_starsCache = [[NSMutableDictionary alloc] init];

        m_updatingUserSongSessions = [[NSMutableArray alloc] init];
        m_postingUserSongSessions = [[NSMutableArray alloc] init];
		
	}
	
	if ( self != nil )
	{
		
		// it really makes sense to retain the delegate in this instance.
		m_delegate = [delegate retain];
		
		m_cloudController = [cloudController retain];
        
        m_requestedUserSongs = [[NSMutableArray alloc] init];
        m_updatingUserSongs = [[NSMutableArray alloc] init];

        // Upload anything that failed to upload
        
        for ( UserSongSession * userSongSession in m_updatingUserSongSessions )
        {                
            // upload song to server
            [m_cloudController requestUploadUserSongSession:userSongSession andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:) ];
        }
        
        for ( UserSongSession * userSongSession in m_postingUserSongSessions )
        {
            [m_cloudController requestFacebookPostUserSongSession:userSongSession andCallbackObj:self andCallbackSel:@selector(requestFacebookPostUserSongSessionCallback:) ];
        }
        
	}
	
	return self;

}

- (void)dealloc
{
	
	[m_delegate release];
	
    [m_userSongArray release];
    
    [m_requestedUserSongs release];
    
    [m_updatingUserSongs release];
    
    [m_updatingUserSongSessions release];
    [m_postingUserSongSessions release];
    
	[m_cloudController release];
	
	[super dealloc];
	
}

#pragma mark -
#pragma mark External access functions

- (void)refreshSongList
{

	[m_cloudController requestSongListCallbackObj:self andCallbackSel:@selector(requestSongListCallback:)];

}

- (void)refreshSongXmpCache
{

    // refresh all the song content
    for ( UserSong * userSong in m_userSongArray )
    {
        [m_updatingUserSongs addObject:userSong];
        
        [m_cloudController requestSongXmp:userSong andCallbackObj:self andCallbackSel:@selector(requestUserSongXmpCallback:)];
    }
    
}

- (void)requestSongXmp:(UserSong*)userSong
{
    
    // check to see if there are any xmp updates pending.
    // if yes, wait on that.
    if ( [m_updatingUserSongs containsObject:userSong] )
    {
        
        [m_requestedUserSongs addObject:userSong];
        
    }
    else
    {
        
        // otherwise return what we have
        NSString * xmpBlob = [self getXmpBlobForUserSong:userSong];
        
        [m_delegate cloudCache:self receivedXmpBlob:xmpBlob forEntry:userSong];
        
    }
    
}

#pragma mark -
#pragma mark Xmp helpers

- (void)setXmpBlob:(NSString*)xmpBlob forUserSong:(UserSong*)userSong
{

	// save the xmp to the file system
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName = [NSString stringWithFormat:@"%u.xmp", userSong.m_songId];
	
	NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	[xmpBlob writeToFile:xmpPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
	
	// save this new cache info
//	[self saveArchive];
	
}

- (NSString*)getXmpBlobForUserSong:(UserSong*)userSong
{
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName = [NSString stringWithFormat:@"%u.xmp", userSong.m_songId];
	
	NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	return [NSString stringWithContentsOfFile:xmpPath encoding:NSASCIIStringEncoding error:nil];
	
}

- (void)deleteLocalXmp:(UserSong*)userSong
{
    
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
	NSString * fileName = [NSString stringWithFormat:@"%u.xmp", userSong.m_songId];
	
	NSString * xmpPath = [documentsDirectory stringByAppendingPathComponent:fileName];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
    
	[fileManager removeItemAtPath:xmpPath error:NULL];
	
}

#pragma mark Cloud Helpers

- (void)uploadUserSongSession:(UserSongSession*)songSession
{
	
	// update the local cache until our next pull
	UserSong * userSong = songSession.m_userSong;
    
	NSNumber * currentScore = [NSNumber numberWithInteger:songSession.m_score];
	NSNumber * currentStars = [NSNumber numberWithInteger:songSession.m_stars];
	
    NSNumber * key = [NSNumber numberWithInteger:userSong.m_songId];

	NSNumber * highScore = [m_highScoreCache objectForKey:key];
	NSNumber * stars = [m_starsCache objectForKey:key];

	if ( [currentScore floatValue] > [highScore floatValue] )
	{
		[m_highScoreCache setObject:currentScore forKey:key];
	}
    
	if ( [currentStars floatValue] > [stars floatValue] )
	{
		[m_starsCache setObject:currentStars forKey:key];
	}
    
    [m_updatingUserSongSessions addObject:songSession];
    
    // save this new cache info
    [self saveArchive];
	
	// upload song to server
    [m_cloudController requestUploadUserSongSession:songSession andCallbackObj:self andCallbackSel:@selector(requestUploadUserSongSessionCallback:) ];
    
}

- (void)facebookPostUserSongSession:(UserSongSession*)songSession
{

    [m_postingUserSongSessions addObject:songSession];
    
    // save this new cache info
    [self saveArchive];

    [m_cloudController requestFacebookPostUserSongSession:songSession andCallbackObj:self andCallbackSel:@selector(requestFacebookPostUserSongSessionCallback:) ];

}

#pragma mark Archiver coder

- (BOOL)saveArchive
{
	
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	NSString * documentsDirectory = [paths objectAtIndex:0];
	
    NSString * username = m_cloudController.m_username;
    
    if ( username == nil )
    {
        // need a username
        return nil;
    }
    
    NSString * archivePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"CloudCache.%@.archive",username]];

	return [NSKeyedArchiver archiveRootObject:self toFile:archivePath];
	
}

#pragma mark -
#pragma mark NSCoder functions

// Encode an object for an archive
- (void)encodeWithCoder:(NSCoder *)coder
{

    [coder encodeObject:m_userSongArray forKey:@"UserSongArray"];
    
    [coder encodeObject:m_starsCache forKey:@"StarsCache"];
    [coder encodeObject:m_highScoreCache forKey:@"HighScoreCache"];
    [coder encodeObject:m_updatingUserSongSessions forKey:@"UpdatingUserSongSessions"];
    [coder encodeObject:m_postingUserSongSessions forKey:@"PostingUserSongSessions"];

}

// Decode an object from an archive
- (id)initWithCoder:(NSCoder *)coder
{

    self = [super init];
	
    if ( self )
	{

        m_userSongArray = [[coder decodeObjectForKey:@"UserSongArray"] retain];
        
        m_starsCache = [[coder decodeObjectForKey:@"StarsCache"] retain];
        m_highScoreCache = [[coder decodeObjectForKey:@"HighScoreCache"] retain];
        m_updatingUserSongSessions = [[coder decodeObjectForKey:@"UpdatingUserSongSessions"] retain];
        m_postingUserSongSessions = [[coder decodeObjectForKey:@"PostingUserSongsessions"] retain];
        
	}
    
	return self;

}

#pragma mark -
#pragma mark CloudController callbacks

- (void)requestSongListCallback:(CloudResponse*)cloudResponse
{

    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate cloudCacheLoggedOut:self];
        return;
    }
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        // refresh table data
        UserSongs * userSongs = cloudResponse.m_responseUserSongs;
        
        [m_userSongArray release];
        
        m_userSongArray = [[NSMutableArray alloc] init];
        
        for ( UserSong * userSong in userSongs.m_songsArray )
        {
            
            NSNumber * key = [NSNumber numberWithInteger:userSong.m_songId];
            
            NSNumber * starsNumber = [m_starsCache objectForKey:key];

            if ( starsNumber != nil )
            {
                userSong.m_playStars = [starsNumber integerValue];
            }

            NSNumber * scoreNumber = [m_highScoreCache objectForKey:key];

            if ( scoreNumber != nil )
            {
                userSong.m_playScore = [scoreNumber integerValue];
            }

            [m_userSongArray addObject:userSong];
            
        }
        
        // save this new cache info
        [self saveArchive];
    }
	
    // if it fails, the delegate can just pull from the cached version of m_userSongsArray
	[m_delegate cloudCacheReceivedSongList:self];

}

- (void)requestUserSongXmpCallback:(CloudResponse*)cloudResponse
{

    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate cloudCacheLoggedOut:self];
        return;
    }
	
    // cache the received xmp blob
    NSString * xmpBlob = cloudResponse.m_receivedDataString;
    
	UserSong * userSong = nil; //cloudResponse.m_responseUserSong;
	
	if ( xmpBlob != nil && userSong != nil )
	{
		// we got some updated data
		[self setXmpBlob:xmpBlob forUserSong:userSong];
	
	}
    
    // take this song off the updating list
    [m_updatingUserSongs removeObject:userSong];
    
    // notify the delegate if the are waiting for it
    if ( [m_requestedUserSongs containsObject:userSong] == YES )
    {

        [m_requestedUserSongs removeObject:userSong];
        
        [m_delegate cloudCache:self receivedXmpBlob:xmpBlob forEntry:userSong];

    }
	
}

- (void)requestUploadUserSongSessionCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate cloudCacheLoggedOut:self];
        return;
    }
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {

        [m_updatingUserSongSessions removeObject:cloudResponse.m_responseUserSongSession];
        
        [self saveArchive];
        
    }
    
}

- (void)requestFacebookPostUserSongSessionCallback:(CloudResponse*)cloudResponse
{
    
    if ( cloudResponse.m_loggedIn == NO )
    {
        [m_delegate cloudCacheLoggedOut:self];
        return;
    }
    
    if ( cloudResponse.m_status == CloudResponseStatusSuccess )
    {
        
        [m_postingUserSongSessions removeObject:cloudResponse.m_responseUserSongSession];
        
        [self saveArchive];
        
    }
    
}

@end
