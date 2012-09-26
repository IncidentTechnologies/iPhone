//
//  StoreFeatureCollection.m
//  gTarPlay
//
//  Created by Marty Greenia on 7/7/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "StoreFeatureCollectionOld.h"


@implementation StoreFeatureCollectionOld

@synthesize m_collectionName;

@synthesize m_featuredUserSongsArray;    
@synthesize m_newUserSongsArray;
@synthesize m_popularUserSongsArray;

@synthesize m_subcategoryArray;
@synthesize m_subcategoryDictionary;

@synthesize m_allUserSongsArray;

- (void)dealloc
{

    [m_collectionName release];
    
    [m_featuredUserSongsArray release];
    [m_newUserSongsArray release];
    [m_popularUserSongsArray release];

    [m_subcategoryArray release];
    [m_subcategoryDictionary release];

    [m_allUserSongsArray release];
    
    [super dealloc];

}

@end
