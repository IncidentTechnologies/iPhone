//
//  StoreFeatureCollection.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/7/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreFeatureCollection.h"

#import "StoreGenreCollection.h"
#import "UserSong.h"
#import "UserSongs.h"
#import "FeaturedSong.h"
#import "XmlDom.h"

@implementation StoreFeatureCollection


@synthesize m_popularUserSongs;
@synthesize m_newUserSongs;
@synthesize m_featuredSongs;

@synthesize m_genreList;
@synthesize m_genreCollectionDictionary;

@synthesize m_allUserSongs;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_popularUserSongs = [[NSMutableArray alloc] init];
        m_newUserSongs  = [[NSMutableArray alloc] init];
        m_featuredSongs = [[NSMutableArray alloc] init];
        
        // this just forces ordering of known genres
        m_genreList = [[NSMutableArray alloc] initWithObjects:(id)@"Rock", (id)@"Pop", (id)@"Jazz", nil];
        m_genreCollectionDictionary = [[NSMutableDictionary alloc] init];
        
        m_allUserSongs = [[NSMutableArray alloc] init];

    }
    
    return self;
    
}

- (id)initWithXmlDom:(XmlDom*)xmlDom
{
    
    if ( xmlDom == nil )
    {
        return nil;
    }
    
    self = [super init];
    
    if ( self )
    {

        m_popularUserSongs = [[NSMutableArray alloc] init];
        m_newUserSongs  = [[NSMutableArray alloc] init];        
        m_featuredSongs = [[NSMutableArray alloc] init];
        
        // this just forces ordering of known genres
        m_genreList = [[NSMutableArray alloc] initWithObjects:(id)@"Rock", (id)@"Pop", (id)@"Jazz", nil];
        m_genreCollectionDictionary = [[NSMutableDictionary alloc] init];

        m_allUserSongs = [[NSMutableArray alloc] init];
        
        // 
        // New songs
        //
        XmlDom * newSongsDom = [xmlDom getChildWithName:@"NewSongsList"];
        UserSongs * newUserSongs = [[[UserSongs alloc] initWithXmlDom:newSongsDom] autorelease];

        for ( UserSong * userSong in newUserSongs.m_songsArray )
        {
            [self addNewSong:userSong];
        }
        
        [m_newUserSongs sortUsingSelector:@selector(compareCreated:)];
        
        //
        // Popular songs
        //
        XmlDom * popSongsDom = [xmlDom getChildWithName:@"PopularSongsList"];
        UserSongs * popUserSongs = [[[UserSongs alloc] initWithXmlDom:popSongsDom] autorelease];

        for ( UserSong * userSong in popUserSongs.m_songsArray )
        {
            [self addPopularSong:userSong];
        }
        
        [m_popularUserSongs sortUsingSelector:@selector(compareCreated:)];

        //
        // Featured Songs
        //
        XmlDom * featuredSongs = [xmlDom getChildWithName:@"FeaturedSongsList"];
        NSArray * featuredSongsDomArray = [featuredSongs getChildArrayWithName:@"UserSongs"];
        
        for ( XmlDom * featuredSongsDom in featuredSongsDomArray )
        {
            
            FeaturedSong * featuredSong = [[FeaturedSong alloc] initWithXmlDom:featuredSongsDom];
            
            [self addFeaturedSong:featuredSong];
            
            [featuredSong release];
            
        }
        
        [m_featuredSongs sortUsingSelector:@selector(compareCreated:)];

    }
    
    return self;
    
}


- (void)dealloc
{

    [m_popularUserSongs release];
    [m_newUserSongs release];
    [m_featuredSongs release];
    
    [m_genreList release];
    [m_genreCollectionDictionary release];
    
    [m_allUserSongs release];
    
    [super dealloc];

}


- (void)addNewSong:(UserSong*)userSong
{
    
    [m_newUserSongs addObject:userSong];
    
    // only add it if it doesn't exist
    if ( [m_allUserSongs containsObject:userSong] == NO )
    {
        [m_allUserSongs addObject:userSong];
    }
    
    // also add to the genre
    NSString * genre = userSong.m_genre;
    
    if ( genre == nil || [genre isEqualToString:@""] )
    {
        return;
    }
    
    // add this song's genre to the list
    if ( [m_genreList containsObject:genre] == NO )
    {
        [m_genreList addObject:genre];
    }
    
    // now add it to this genres collection
    StoreGenreCollection * genreCollection = [m_genreCollectionDictionary objectForKey:genre];
    
    if ( genreCollection == nil )
    {
    
        genreCollection = [[[StoreGenreCollection alloc] initWithGenreName:genre] autorelease];
        
        [m_genreCollectionDictionary setObject:genreCollection forKey:genre];
        
    }
    
    [genreCollection addNewSong:userSong];
    
}

- (void)addPopularSong:(UserSong*)userSong
{
    
    [m_popularUserSongs addObject:userSong];
    
    // only add it if it doesn't exist
    if ( [m_allUserSongs containsObject:userSong] == NO )
    {
        [m_allUserSongs addObject:userSong];
    }
    
    // also add to the genre
    NSString * genre = userSong.m_genre;
    
    if ( genre == nil || [genre isEqualToString:@""] )
    {
        return;
    }
    
    // add this song's genre to the list
    if ( [m_genreList containsObject:genre] == NO )
    {
        [m_genreList addObject:genre];
    }
    
    // now add it to this genres collection
    StoreGenreCollection * genreCollection = [m_genreCollectionDictionary objectForKey:genre];
    
    if ( genreCollection == nil )
    {
        
        genreCollection = [[[StoreGenreCollection alloc] initWithGenreName:genre] autorelease];
        
        [m_genreCollectionDictionary setObject:genreCollection forKey:genre];
        
    }
    
    [genreCollection addPopularSong:userSong];

}

- (void)addFeaturedSong:(FeaturedSong*)featuredSong
{
    
    [m_featuredSongs addObject:featuredSong];
    
    // only add it if it doesn't exist
    if ( [m_allUserSongs containsObject:featuredSong.m_userSong] == NO )
    {
        [m_allUserSongs addObject:featuredSong.m_userSong];
    }
    
    // also add to the genre
    NSString * genre = featuredSong.m_userSong.m_genre;
    
    if ( genre == nil || [genre isEqualToString:@""] )
    {
        return;
    }
    
    // add this song's genre to the list
    if ( [m_genreList containsObject:genre] == NO )
    {
        [m_genreList addObject:genre];
    }
    
    // now add it to this genres collection
    StoreGenreCollection * genreCollection = [m_genreCollectionDictionary objectForKey:genre];
    
    if ( genreCollection == nil )
    {
        
        genreCollection = [[[StoreGenreCollection alloc] initWithGenreName:genre] autorelease];
        
        [m_genreCollectionDictionary setObject:genreCollection forKey:genre];
        
    }
    
    [genreCollection addFeaturedSong:featuredSong];
    
}

@end
