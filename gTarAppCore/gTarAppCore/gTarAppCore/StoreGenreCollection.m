//
//  StoreGenreCollection.m
//  gTarAppCore
//
//  Created by Marty Greenia on 7/12/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "StoreGenreCollection.h"

#import "UserSong.h"
#import "FeaturedSong.h"


@implementation StoreGenreCollection

@synthesize m_genreName;

//@synthesize m_popularUserSongs;
//@synthesize m_newUserSongs;
//
//@synthesize m_featuredSongs;

- (id)initWithGenreName:(NSString*)genreName
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_genreName = [genreName retain];
        
//        m_popularUserSongs = [[NSMutableArray alloc] init];
//        m_newUserSongs = [[NSMutableArray alloc] init];
//        
//        m_featuredSongs = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}

- (void)dealloc
{

    [m_genreName release];
    
//    [m_popularUserSongs release];
//    [m_newUserSongs release];
//    
//    [m_featuredSongs release];
    
    [super dealloc];
    
}

//- (void)addNewSong:(UserSong*)userSong
//{
//    
//    [m_newUserSongs addObject:userSong];
//
//}
//
//- (void)addPopularSong:(UserSong*)userSong
//{
//    
//    [m_popularUserSongs addObject:userSong];
//    
//}
//
//- (void)addFeaturedSong:(FeaturedSong*)featuredSong
//{
//    
//    [m_featuredSongs addObject:featuredSong];
//    
//}

- (void)addNewSong:(UserSong*)userSong
{
    
    [m_newUserSongs addObject:userSong];
    
    // only add it if it doesn't exist
    if ( [m_allUserSongs containsObject:userSong] == NO )
    {
        [m_allUserSongs addObject:userSong];
    }
        
}

- (void)addPopularSong:(UserSong*)userSong
{
    
    [m_popularUserSongs addObject:userSong];
    
    
    // only add it if it doesn't exist
    if ( [m_allUserSongs containsObject:userSong] == NO )
    {
        [m_allUserSongs addObject:userSong];
    }

}

- (void)addFeaturedSong:(FeaturedSong*)featuredSong
{
    
    [m_featuredSongs addObject:featuredSong];
    
    // only add it if it doesn't exist
    if ( [m_allUserSongs containsObject:featuredSong.m_userSong] == NO )
    {
        [m_allUserSongs addObject:featuredSong.m_userSong];
    }
    
}


@end
