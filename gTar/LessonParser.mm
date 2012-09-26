//
//  LessonParser.m
//  gTar
//
//  Created by wuda on 10/24/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "LessonParser.h"
#import "Lesson.h"

@implementation LessonParser

@synthesize m_lesson;

- (LessonParser*)initWithXmp:(NSString *)xmpName
{
	if ( (self = [super init]) )
	{
        // Initialization code
		
		m_xmpName = xmpName;
		
		// Parse the thing into a song
		//[self parseXmp];
		
		// Parse xmp to create a lesson object.

		// TODO hack
		char allOff[] = { -1, -1, -1, -1, -1, -1 };
		char temp1[] = { 0, 1, 2, 3, 4, 5 };
		char temp2[] = { 3, 3, 3, 3, 3, 3 };
		
		Chapter * chap;
		Segment * seg;
		
		m_lesson = [[Lesson alloc] init];
		
		// chap 1
		chap = [[Chapter alloc] init];
		chap.m_chapterNumber = 1;
		chap.m_songXmpName = @"Tears_in_Heaven_Eric_Clapton";
		[m_lesson addChapter:chap];
		
		
		seg = [[Segment alloc] init];
		[seg setTargetNotes:allOff];
		seg.m_instructionText = @"Welcome to the first chapter. You will see a number of notes and you must play them all to proceed to the next step. Touch the screen to continue.";
		seg.m_id = 1;
		seg.m_nextId = 2;
		seg.m_advanceMethod = AdvanceMethodTouch;
		[chap addSegment:seg];
		
		seg = [[Segment alloc] init];
		[seg setTargetNotes:temp1];
		seg.m_instructionText = @"This is the first example. Play some notes.";
		seg.m_id = 2;
		seg.m_nextId = 3;
		seg.m_advanceMethod = AdvanceMethodNotes;
		[chap addSegment:seg];
		
		seg = [[Segment alloc] init];
		[seg setTargetNotes:temp2];
		seg.m_instructionText = @"Keep on playing notes and you will get better!";
		seg.m_id = 3;
		seg.m_nextId = 4;
		seg.m_advanceMethod = AdvanceMethodNotes;
		[chap addSegment:seg];
		
		seg = [[Segment alloc] init];
		[seg setTargetNotes:allOff];
		seg.m_instructionText = @"Your first chapter is complete. Touch the screen to do some more practice.";
		seg.m_id = 4;
		seg.m_nextId = 0;	//end
		seg.m_advanceMethod = AdvanceMethodTouch;
		[chap addSegment:seg];
		
		
		//chap 2
		chap = [[Chapter alloc] init];
		chap.m_chapterNumber = 2;
		chap.m_songXmpName = @"Tears_in_Heaven_Eric_Clapton";
		[m_lesson addChapter:chap];
		
		
		seg = [[Segment alloc] init];
		[seg setTargetNotes:temp2];
		seg.m_instructionText = @"This is the second example. Play some strings.";
		seg.m_id = 1;
		seg.m_nextId = 2;
		[chap addSegment:seg];
		
		seg = [[Segment alloc] init];
		[seg setTargetNotes:temp1];
		seg.m_instructionText = @"You can be a rock star if you believe in yourself!";
		seg.m_id = 2;
		seg.m_nextId = 0;
		[chap addSegment:seg];
		

		
    }
	
    return self;
	
}

+ (Lesson*)lessonWithXmp:(NSString*)xmpName
{
	
	LessonParser * lessonParser = [[LessonParser alloc] initWithXmp:xmpName];
	
	Lesson * lesson = lessonParser.m_lesson;
	
	[lessonParser release];
	
	return lesson;
	
}


#pragma mark -
#pragma mark XMP parsing and NSXMLParser delegate

- (void)parseXmp
{
	
	// Load the file into a data object
	NSString *filePath = [[NSBundle mainBundle] pathForResource:m_xmpName ofType:@"xmp"];
	
	NSData * rawXmp = [[NSData alloc] initWithContentsOfFile:filePath];
	
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
	
	if ( [elementName isEqualToString:@"lesson"] )
	{
		
		m_currentLesson = [[Lesson alloc] init];
		
	}
	else if ( [elementName isEqualToString:@"chapter"] )
	{
		
		m_currentChapter = [[Chapter alloc] init];
		
		m_currentChapter.m_chapterNumber = [[attributeDict objectForKey:@"number"] intValue];
		
	}
	else if ( [elementName isEqualToString:@"segment"] )
	{
		
		m_currentSegment = [[Segment alloc] init];
		
		m_currentSegment.m_nextId = [[attributeDict objectForKey:@"next"] intValue];

	}
	else if ( [elementName isEqualToString:@"target"] )
	{
		
		m_currentSegment.m_nextIdSuccess = [[attributeDict objectForKey:@"success"] intValue];
		m_currentSegment.m_nextIdFailure = [[attributeDict objectForKey:@"fail"] intValue];

	}
	else if ( [elementName isEqualToString:@"text"] )
	{
		
		m_currentText = [[NSMutableString alloc] init];		
		
	}
	else if ( [elementName isEqualToString:@"guitarposition"] )
	{
		unsigned int str = [[attributeDict objectForKey:@"string"] intValue];

		str--; // convert one- to zero-based
		
		[m_currentSegment setTargetNoteString:str andFret:[[attributeDict objectForKey:@"fret"] intValue]];
	}
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
{
	
	if ( [elementName isEqualToString:@"lesson"] )
	{
		
		m_lesson = m_currentLesson;
		
		m_lesson = nil;
		
	}
	else if ( [elementName isEqualToString:@"chapter"] )
	{
		
		[m_currentLesson addChapter:m_currentChapter];
		
		m_currentChapter = nil;
		
	}
	else if ( [elementName isEqualToString:@"segment"] )
	{
		
		[m_currentChapter addSegment:m_currentSegment];
		
		m_currentSegment = nil;
		
	}
	else if ( [elementName isEqualToString:@"text"] )
	{

		m_currentSegment.m_instructionText = m_currentText;
		
		[m_currentText release];
		
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
