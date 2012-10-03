//
//  NewsTicker.m
//  gTarAppCore
//
//  Created by Marty Greenia on 5/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "NewsTicker.h"
#import "NewsStory.h"
#import "XmlDictionary.h"
#import "XmlDom.h"

@implementation NewsTicker

@synthesize m_newsArray;

- (id)initWithXmlDictionary:(XmlDictionary*)xmlDictionary
{
    self = [super init];
    
    if ( self )
    {

        m_newsArray = [[NSMutableArray alloc] init];
        
        NSDictionary * nodeDictionary = [xmlDictionary.m_xmlDictionary objectForKey:@"resultsCount"];
		NSString * numberStr = [nodeDictionary objectForKey:@"value"];
		NSInteger resultsCount = [numberStr integerValue];

        for ( unsigned int index = 0; index < resultsCount; index++ )
        {
            
            NewsStory * newsStory = [[NewsStory alloc] init];
            
            NSString * key = [NSString stringWithFormat:@"index%u", index];
            
            NSDictionary * newsNodeDictionary = [xmlDictionary.m_xmlDictionary objectForKey:key];

            NSDictionary * headlineNodeDictionary = [newsNodeDictionary objectForKey:@"headline"];
            newsStory.m_headline = [headlineNodeDictionary objectForKey:XML_DICTIONARY_TEXT_NODE];
            
            NSDictionary * linkNodeDictionary = [newsNodeDictionary objectForKey:@"link"];
            newsStory.m_link = [linkNodeDictionary objectForKey:XML_DICTIONARY_TEXT_NODE];
            
            [m_newsArray addObject:newsStory];
            
            [newsStory release];
            
        }
        
    }
    
    return self;
    
}

- (id)initWithXmlDom:(XmlDom*)xmlDom
{
    
    self = [super init];
    
    if ( self )
    {
        
        m_newsArray = [[NSMutableArray alloc] init];
        
        NSArray * storyArray = [xmlDom getChildArrayWithName:@"story"];
        
        for ( XmlDom * storyDom in storyArray )
        {
            
            NSString * headline = [storyDom getTextFromChildWithName:@"headline"];
            
            NSString * link = [storyDom getTextFromChildWithName:@"link"];
            
            NewsStory * newsStory = [[NewsStory alloc] init];

            newsStory.m_headline = headline;
            newsStory.m_link = link;
            
            [m_newsArray addObject:newsStory];
            
            [newsStory release];
            
        }
        
    }
    
    return self;

}

- (void)dealloc
{
    [m_newsArray release];
    
    [super dealloc];
}

@end
