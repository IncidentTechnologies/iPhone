//
//  SongParser.m
//  gTar
//
//  Created by Marty Greenia on 10/13/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "SongParser.h"

@implementation SongParser

@synthesize m_song;

- (SongParser*)initWithXmpBlob:(NSString *)xmpBlob
{
	if ( (self = [super init]) )
	{
        // Initialization code
		
		m_xmpBlob = xmpBlob;
		
		// Parse the thing into a song
		[self parseXmp];
		
    }
	
    return self;
	
}


+ (CSong*)songWithXmpBlob:(NSString*)xmpBlob
{

	SongParser * songParser = [[SongParser alloc] initWithXmpBlob:xmpBlob];

	CSong * song = songParser.m_song;
	
	[songParser release];
	
	return song;
	
}

#pragma mark -
#pragma mark XMP parsing and NSXMLParser delegate

- (void)parseXmp
{

	NSData * rawXmp = [m_xmpBlob dataUsingEncoding:NSASCIIStringEncoding];
	
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
	
	if ( [elementName isEqualToString:@"song"] )
	{
		
		//m_currentSong = [[Song alloc] init];
		m_currentSong = new CSong();
		
		//m_noteArray = [[NSMutableArray alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"measure"] )
	{
		
		//m_currentMeasure = [[Measure alloc] init];
		m_currentMeasure = new CMeasure();
		
	}
	else if ( [elementName isEqualToString:@"note"] )
	{
		
		m_currentNote = new CNote();
		
		const char * str = [[attributeDict objectForKey:@"value"] cString];
		m_currentNote->SetValue( str );
		
		m_currentNote->m_duration = [[attributeDict objectForKey:@"duration"] floatValue];
		m_currentNote->m_measureStart = [[attributeDict objectForKey:@"measurestart"] floatValue];
		
		m_currentNote->m_absoluteBeatStart = m_currentMeasure->m_startBeat + m_currentNote->m_measureStart - 1;
		
	}
	else if ( [elementName isEqualToString:@"startbeat"] )
	{
		m_currentMeasure->m_startBeat = [[attributeDict objectForKey:@"value"] floatValue];
	}
	else if ( [elementName isEqualToString:@"beatcount"] )
	{
		m_currentMeasure->m_beatCount = [[attributeDict objectForKey:@"value"] floatValue];
	}
	else if ([elementName isEqualToString:@"beatvalue"])
	{
		m_currentMeasure->m_beatValue = [[attributeDict objectForKey:@"value"] floatValue];
	}	
	else if ([elementName isEqualToString:@"tempo"])
	{
		m_currentSong->m_tempo = [[attributeDict objectForKey:@"value"] floatValue];
	}	
	else if ([elementName isEqualToString:@"guitarposition"])
	{
		m_currentNote->m_string = [[attributeDict objectForKey:@"string"] intValue];
		m_currentNote->m_string--; // convert one- to zero-based
		m_currentNote->m_fret = [[attributeDict objectForKey:@"fret"] intValue];
	}	
	else if ( [elementName isEqualToString:@"title"] )
	{
		m_currentText = [[NSMutableString alloc] init];
	}
	else if ( [elementName isEqualToString:@"author"] )
	{
		m_currentText = [[NSMutableString alloc] init];
	}
	else if ( [elementName isEqualToString:@"description"] )
	{
		m_currentText = [[NSMutableString alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
{
	
	if ( [elementName isEqualToString:@"song"] )
	{
		// Sort all the measures.
		m_currentSong->SortMeasures();

		m_song = m_currentSong;

		m_currentSong = nil;
		
	}
	else if ( [elementName isEqualToString:@"measure"] )
	{
		
//		CGFloat beatCount = m_currentMeasure->m_beatCount;
//		CGFloat startBeatCount = m_currentMeasure->m_startBeat;
//		CGFloat endBeat = beatCount + startBeatCount;

		// Sort the notes
		m_currentMeasure->SortNotes();
		m_currentMeasure->AlignNotes( SONG_PARSER_NOTE_ALIGN_THRESHOLD );

		// Add this measure to the song.
		m_currentSong->AddMeasure( m_currentMeasure );
		
		m_currentMeasure = nil;
		
	}
	else if ( [elementName isEqualToString:@"note"] )
	{
		
		// Save the note in the measure.
		//[m_currentMeasure addNote:m_currentNote];
		m_currentMeasure->AddNote( m_currentNote );
		
		// Release
		//[m_currentNote release];
		//delete m_currentNote;
		
		m_currentNote = nil;
		
	}
	else if ( [elementName isEqualToString:@"title"] )
	{
		const char * text = [m_currentText cString];
		m_currentSong->SetName(text);
		[m_currentText release];
		m_currentText = nil;
	}
	else if ( [elementName isEqualToString:@"author"] )
	{
		const char * text = [m_currentText cString];
		m_currentSong->SetArtist(text);
		[m_currentText release];
		m_currentText = nil;
	}
	else if ( [elementName isEqualToString:@"description"] )
	{
		const char * text = [m_currentText cString];
		m_currentSong->SetDescription(text);
		[m_currentText release];
		m_currentText = nil;
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
	
	[m_currentText appendString:string];
	
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
