//
//  NewsStory.h
//  gTarAppCore
//
//  Created by Marty Greenia on 5/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NewsStory : NSObject
{
    NSString * m_headline;
    NSString * m_link;
}

@property (nonatomic, retain) NSString * m_headline;
@property (nonatomic, retain) NSString * m_link;
@end
