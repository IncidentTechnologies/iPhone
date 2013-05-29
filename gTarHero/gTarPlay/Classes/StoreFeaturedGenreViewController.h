//
//  StoreFeaturedGenreViewController.h
//  gTarPlay
//
//  Created by Marty Greenia on 7/7/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreFeaturedViewController.h"

@class StoreGenreCollection;

@interface StoreFeaturedGenreViewController : StoreFeaturedViewController
{

    IBOutlet UILabel * m_genreLabel;
    IBOutlet UIView * m_genreView;
    
    NSString * m_genreName;
    
    StoreGenreCollection * m_featuredGenreCollection;
    
}

@property (nonatomic, retain) IBOutlet UILabel * m_genreLabel;
@property (nonatomic, retain) IBOutlet UIView * m_genreView;
@property (nonatomic, retain) NSString * m_genreName;
@property (nonatomic, retain) StoreGenreCollection * m_featuredGenreCollection;

@end
