//
//  FeaturedSong.h
//  gTarAppCore
//
//  Created by Marty Greenia on 7/12/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UserSong;
@class XmlDom;
@class CloudController;

@interface FeaturedSong : NSObject
{
    
    NSInteger m_id;
    NSInteger m_userSongId;
    NSInteger m_picFileId;
    NSString * m_htmlPreview;
    NSString * m_genre;
    NSInteger m_created;
    
    UserSong * m_userSong;
    
    UIImage * m_featuedImage;
   
}

@property (nonatomic, assign) NSInteger m_id;
@property (nonatomic, assign) NSInteger m_userSongId;
@property (nonatomic, assign) NSInteger m_picFileId;
@property (nonatomic, retain) NSString * m_htmlPreview;
@property (nonatomic, retain) NSString * m_genre;
@property (nonatomic, assign) NSInteger m_created;
@property (nonatomic, retain) UserSong * m_userSong;
@property (nonatomic, retain) UIImage * m_featuedImage;

- (id)initWithXmlDictionary:(NSDictionary*)dictionary;
- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (NSComparisonResult)compareCreated:(id)anObject;

@end
