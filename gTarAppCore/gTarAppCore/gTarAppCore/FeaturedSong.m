//
//  FeaturedSong.m
//  gTarAppCore
//
//  Created by Marty Greenia on 7/12/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "FeaturedSong.h"

#import "UserSong.h"
#import "CloudController.h"
#import "XmlDictionary.h"
#import "XmlDom.h"

@implementation FeaturedSong

@synthesize m_id;
@synthesize m_userSongId;
@synthesize m_picFileId;
@synthesize m_htmlPreview;
@synthesize m_genre;
@synthesize m_created;
@synthesize m_userSong;
@synthesize m_featuedImage;

- (id)initWithXmlDictionary:(NSDictionary*)dictionary
{

    //<id>16</id>
    //<user_song_id>8</user_song_id>
    //<pic_path>user/1/img/app.png</pic_path>
    //<html_preview>Hurr durr</html_preview>
    //<genre></genre>
    //<created>2011-07-12 12:25:53</created>
    
    self = [super init];
    
    if ( self )
    {
        
        NSDictionary * node;
        NSString * text;
        
        node = [dictionary objectForKey:@"id"];
        text = [node objectForKey:XML_DICTIONARY_TEXT_NODE];
        
        self.m_id = [text integerValue];
        
        node = [dictionary objectForKey:@"user_song_id"];
        text = [node objectForKey:XML_DICTIONARY_TEXT_NODE];
        
        self.m_userSongId = [text integerValue];
        
        node = [dictionary objectForKey:@"pic_file_id"];
        text = [node objectForKey:XML_DICTIONARY_TEXT_NODE];
        
        self.m_picFileId = [[NSNumber numberWithFloat:[text floatValue]] integerValue];
        
        node = [dictionary objectForKey:@"html_preview"];
        text = [node objectForKey:XML_DICTIONARY_TEXT_NODE];
        
        self.m_htmlPreview = text;
        
        node = [dictionary objectForKey:@"genre"];
        text = [node objectForKey:XML_DICTIONARY_TEXT_NODE];
        
        self.m_genre = text;
        
        node = [dictionary objectForKey:@"created"];
        text = [node objectForKey:XML_DICTIONARY_TEXT_NODE];
        
        self.m_created = [text integerValue];
        
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

        // create the featured song
        XmlDom * featuredSongDom = [xmlDom getChildWithName:@"FeaturedSong"];
//        XmlDom * featuredSongDom = xmlDom;
        
        self.m_id = [featuredSongDom getIntegerFromChildWithName:@"id"];
        self.m_userSongId = [featuredSongDom getIntegerFromChildWithName:@"user_song_id"];
        self.m_picFileId = [[featuredSongDom getNumberFromChildWithName:@"pic_file_id"] integerValue];
        self.m_htmlPreview = [featuredSongDom getTextFromChildWithName:@"html_preview"];
        self.m_genre = [featuredSongDom getTextFromChildWithName:@"genre"];
        self.m_created = [featuredSongDom getDateFromChildWithName:@"create"];
        
        // create the user song
        XmlDom * userSongDom = [xmlDom getChildWithName:@"UserSong"];
        
        self.m_userSong = [[UserSong alloc] initWithXmlDom:userSongDom];
        
        // convenience in case the featued song wasn't populated ..
        if ( m_genre == nil || [m_genre isEqualToString:@""] == YES )
        {
            self.m_genre = m_userSong.m_genre;
        }

    }
    
    return self;
    
}


#pragma mark - Misc

- (NSComparisonResult)compareCreated:(id)anObject
{
    
    FeaturedSong * song = (FeaturedSong*)anObject;
    
    if ( song.m_created > self.m_created )
    {
        return NSOrderedAscending;
    }
    
    if ( song.m_created < self.m_created )
    {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
    
}

@end
