//
//  StoreGenreCollection.h
//  gTarAppCore
//
//  Created by Marty Greenia on 7/12/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreFeatureCollection.h"

@class UserSong;
@class FeaturedSong;

@interface StoreGenreCollection : StoreFeatureCollection
{
    
    NSString * m_genreName;
    
//    NSMutableArray * m_popularUserSongs;
//    NSMutableArray * m_newUserSongs;
//    
//    NSMutableArray * m_featuredSongs;
    
}

@property (nonatomic, readonly) NSString * m_genreName;

//@property (nonatomic, readonly) NSArray * m_popularUserSongs;
//@property (nonatomic, readonly) NSArray * m_newUserSongs;
//
//@property (nonatomic, readonly) NSArray * m_featuredSongs;

- (id)initWithGenreName:(NSString*)genreName;

//- (void)addNewSong:(UserSong*)userSong;
//- (void)addPopularSong:(UserSong*)userSong;
//- (void)addFeaturedSong:(FeaturedSong*)featuredSong;

@end
