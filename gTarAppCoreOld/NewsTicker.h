//
//  NewsTicker.h
//  gTarAppCore
//
//  Created by Marty Greenia on 5/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XmlDictionary;
@class XmlDom;

@interface NewsTicker : NSObject
{
    NSMutableArray * m_newsArray;
}

@property (nonatomic, readonly) NSArray * m_newsArray;

- (id)initWithXmlDictionary:(XmlDictionary*)xmlDictionary;
- (id)initWithXmlDom:(XmlDom*)xmlDom;

@end
