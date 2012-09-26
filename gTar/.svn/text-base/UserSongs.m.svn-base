//
//  UserSongs.m
//  gTar
//
//  Created by wuda on 11/11/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "UserSongs.h"


@implementation UserSongs

@synthesize m_songsXml, m_songsArray;

- (UserSongs*)initWithXml:(NSString*)xml
{
	
	if ( self = [super init] )
	{
		m_songsXml = xml;
		
		[self parseXml];
	}
		
	return self;
	
}

- (UserSong*)getSongWithSongId:(NSInteger)songId
{
	
	for ( unsigned int songIndex = 0; songIndex < [m_songsArray count]; songIndex++ )
	{
		UserSong * userSong = [m_songsArray objectAtIndex:songIndex];
		
		if ( userSong.m_songId == songId )
		{
			return userSong;
		}
	}
	
	return nil;
	
}

#pragma mark -
#pragma mark XMP parsing and NSXMLParser delegate

- (void)parseXml
{

	NSData * rawXmp = [m_songsXml dataUsingEncoding:NSASCIIStringEncoding];
	
	// Init and kick off the parser
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:rawXmp];
	
	[parser setDelegate:self];
	
	[parser parse];
	
}

//
// NSXML delegate functions
//
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{
	
	if ( [elementName isEqualToString:@"usersongs"] )
	{
		
		if ( m_songsArray != nil )
		{
			[m_songsArray release];
			
			m_songsArray = nil;
		}
		
		m_songsArray = [[NSMutableArray alloc] init];
				
	}
	else if ( [elementName isEqualToString:@"song"] )
	{
		
		m_currentSong = [[UserSong alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"id"] )
	{
		
		NSInteger authorId = [[attributeDict objectForKey:@"value"] intValue];
							
		m_currentSong.m_songId = authorId;
		
	}
	else if ( [elementName isEqualToString:@"author_id"] )
	{
		
		NSInteger songId = [[attributeDict objectForKey:@"value"] intValue];
		
		m_currentSong.m_songId = songId;
		
	}
	else if ( [elementName isEqualToString:@"title"] )
	{
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"author"] )
	{
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"genre"] )
	{
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"description"] )
	{
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"path"] )
	{
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"timecreated"] )
	{
		
		//NSInteger timeCreated = [[attributeDict objectForKey:@"value"] intValue];
		
		//m_currentSong.m_timeCreated = timeCreated;
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
		
	}
	else if ( [elementName isEqualToString:@"timemodified"] )
	{
		
		//NSInteger timeModified = [[attributeDict objectForKey:@"value"] intValue];
		
		//m_currentSong.m_timeModified = timeModified;
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
		
	}
	else if ( [elementName isEqualToString:@"created"] )
	{
		
		//NSInteger timeCreated = [[attributeDict objectForKey:@"value"] intValue];
		
		//m_currentSong.m_timeCreated = timeCreated;
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
		
	}
	else if ( [elementName isEqualToString:@"modified"] )
	{
		
		//NSInteger timeModified = [[attributeDict objectForKey:@"value"] intValue];
		
		//m_currentSong.m_timeModified = timeModified;
		
		m_accumulatedText = [[NSMutableString alloc] init];
		
		
	}
	
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
{
	
	if ( [elementName isEqualToString:@"usersongs"] )
	{

	}
	else if ( [elementName isEqualToString:@"song"] )
	{
		
		[m_songsArray addObject:m_currentSong];
		
		[m_currentSong release];
		
		m_currentSong = nil;
		
	}
	else if ( [elementName isEqualToString:@"title"] )
	{
		
		m_currentSong.m_title = m_accumulatedText;
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	else if ( [elementName isEqualToString:@"author"] )
	{
		
		m_currentSong.m_author = m_accumulatedText;
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	else if ( [elementName isEqualToString:@"genre"] )
	{
		
		m_currentSong.m_genre = m_accumulatedText;
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	else if ( [elementName isEqualToString:@"description"] )
	{
		
		m_currentSong.m_description = m_accumulatedText;
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	else if ( [elementName isEqualToString:@"path"] )
	{
		
		m_currentSong.m_urlPath = m_accumulatedText;
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	else if ( [elementName isEqualToString:@"timecreated"] )
	{
		
		m_currentSong.m_timeCreated = [m_accumulatedText integerValue];
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
		
	}
	else if ( [elementName isEqualToString:@"timemodified"] )
	{
		
		m_currentSong.m_timeModified = [m_accumulatedText integerValue];
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	else if ( [elementName isEqualToString:@"created"] )
	{
		
		m_currentSong.m_timeCreated = [m_accumulatedText integerValue];
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
		
	}
	else if ( [elementName isEqualToString:@"modified"] )
	{
		
		m_currentSong.m_timeModified = [m_accumulatedText integerValue];
		
		[m_accumulatedText release];
		
		m_accumulatedText = nil;
		
	}
	
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	/*
	 if (accumulatingParsedCharacterData) {
	 // If the current element is one whose content we care about, append 'string'
	 // to the property that holds the content of the current element.
	 //
	 [self.currentParsedCharacterData appendString:string];
	 }
	 */
	
	[m_accumulatedText appendString:string];
	
}

// Parse error
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	/*
	 if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
	 {
	 [self performSelectorOnMainThread:@selector(handleEarthquakesError:)
	 withObject:parseError
	 waitUntilDone:NO];
	 }
	 */
}

@end
