//
//  StoreFeatureCollection.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/7/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserSong;
@class FeaturedSong;
@class XmlDom;

@interface StoreFeatureCollection : NSObject
{

    NSMutableArray * m_popularUserSongs;
    NSMutableArray * m_newUserSongs;
    NSMutableArray * m_featuredSongs;

    NSMutableArray * m_genreList;
    NSMutableDictionary * m_genreCollectionDictionary;
    
    NSMutableArray * m_allUserSongs;
    
}

@property (nonatomic, readonly) NSArray * m_popularUserSongs;
@property (nonatomic, readonly) NSArray * m_newUserSongs;
@property (nonatomic, readonly) NSArray * m_featuredSongs;

@property (nonatomic, readonly) NSArray * m_genreList;
@property (nonatomic, readonly) NSDictionary * m_genreCollectionDictionary;
@property (nonatomic, readonly) NSArray * m_allUserSongs;

- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (void)addNewSong:(UserSong*)userSong;
- (void)addPopularSong:(UserSong*)userSong;
- (void)addFeaturedSong:(FeaturedSong*)featuredSong;


@end
