//
//  EtarLearnPlayTabsViewController.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/1/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "EtarLearnPlayTabsViewController.h"
#import "EtarLearnPlayTabsView.h"
#import "DisplayElement.h"

@implementation EtarLearnPlayTabsViewController

@synthesize tabView;
@synthesize consoleView;
@synthesize tempoButton;
@synthesize playButton;
@synthesize song;

@synthesize displayElements;

@synthesize audioController;
@synthesize noteVerifier;

@synthesize maxBeat;
@synthesize currentBeat;
@synthesize measureStartIndex;
@synthesize measureCount;
@synthesize measureMaxCount;
@synthesize currentNotesIndexStart;
@synthesize currentNotesCount;
@synthesize nextNotesIndexStart;
@synthesize nextNotesCount;

@synthesize pixelsHeight;
@synthesize pixelsWidth;
@synthesize activePixelsHeight;
@synthesize activePixelsWidth;
@synthesize beatsPerScreen;
@synthesize pixelsPerBeat;
@synthesize stringsPerScreen;
@synthesize pixelsPerString;

@synthesize animationTimer;
@synthesize framesRemaining;
@synthesize beatDeltaPerFrame;
@synthesize continuousPlay;
@synthesize tempoScale;

@synthesize songObj;
@synthesize currentNoteObj;
@synthesize currentMeasureObj;
@synthesize noteObjArray;
@synthesize displayObjArray;

@synthesize serialRxTimer;
@synthesize easyMode;

EtarLearnPlayTabsViewController * g_vc;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		// Create and init the audio controller
		audioController = [[AudioController alloc] init];
		
		// TODO: dynamic Attenuation and Freq
		[audioController SetAttentuation:0.985f];
		[audioController initializeAUGraph:600.0f withWaveform:3];
		[audioController startAUGraph];
		
	
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	for ( NSInteger i = 0; i < GUITAR_STRINGS; i++ )
	{
		ghostNotesOn[i] = -1;
	}
		 
	g_vc = self;
	easyMode = NO;
	[noteVerifier initStuff];
	
	// Write the build time/date to the console
	[self printToConsole:[NSString stringWithFormat:@"Build date: %s", __DATE__]];
	[self printToConsole:[NSString stringWithFormat:@"Build time: %s", __TIME__]];
	
	// Init the note verifier 
	noteVerifier = [[NoteVerifier alloc] init];
	noteVerifier.delegate = self;
	
	// Init the serial port
	serialPort = new SerialPort();

	// Set up a polling thread to read from the port
	serialRxTimer = [NSTimer scheduledTimerWithTimeInterval:0.002 target:self selector:@selector(checkRxSerialInput) userInfo:nil repeats:YES];

	
	// TODO: Does not exist in the 3.1.3 sdk
//	[tabView initGestureRecognizer:self];

	[self initDisplayAndStepToActiveNotes];
	

}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)initDisplayAndStepToActiveNotes
{
	[self initDisplayParameters];
	
	// Make the next notes equal to the first notes.
	nextNotesIndexStart = [self findNextNoteAfterBeat:currentBeat];
	nextNotesCount = [self findNotesCloseToNote:currentNotesIndexStart];
	//nextNotesIndexStart = currentNotesIndexStart + currentNotesCount;
	//nextNotesCount = [self findNotesCloseToNote:nextNotesIndexStart];

	[self stepToNextActiveNoteGroupIsAnimated:NO];
}

#pragma mark -
#pragma mark XMP parsing and NSXMLParser delegate

- (void)parseXmp:(NSString*)xmpName
{
	// Get the members ready.
	maxBeat = 0;
	
	// Load the file into a data object
	NSString *filePath = [[NSBundle mainBundle] pathForResource:xmpName ofType:@"xmp"];
	
	NSData * rawXmp = [[NSData alloc] initWithContentsOfFile:filePath];
	
	// Init and kick off the parser
	NSXMLParser * parser = [[NSXMLParser alloc] initWithData:rawXmp];
	
	[parser setDelegate:self];
	
	[parser parse];
}

//
// General form is:
// NSDictionary representing an Element, containing:
// --"parent" - NSDictionary pointing to the parent element
// --"attributes" - NSDictionary of all attributes
// --"name" - NSString naming this element
// --"children" - NSArray point to children
//
/*
- (NSString)nameFromElement:(NSDictionary*)element
{
	return [element objectForKey:@"name"];
}

- (NSString)attribute:(NSString*)attr fromElement:(NSDictionary*)element
{
	NSDictionary * attributes = [element objectForKey:@"attributes"];
	return [attributes objectForKey:attr];
}
*/
//
// NSXML delegate functions
//
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{

	if ([elementName isEqualToString:@"song"])
	{

		songObj = [[Song alloc] init];

		noteObjArray = [[NSMutableArray alloc] init];

	}
	else if ([elementName isEqualToString:@"measure"])
	{

		currentMeasureObj = [[Measure alloc] init];
		
	}
	else if ([elementName isEqualToString:@"note"])
	{

		currentNoteObj = [[Note alloc] init];
		
		// Track all notes in this array.
		[noteObjArray addObject:currentNoteObj];
		
		currentNoteObj.m_value = [attributeDict objectForKey:@"value"];
		currentNoteObj.m_duration = [[attributeDict objectForKey:@"duration"] floatValue];
		currentNoteObj.m_measureStart = [[attributeDict objectForKey:@"measurestart"] floatValue];

		currentNoteObj.m_absoluteBeatStart = currentMeasureObj.m_startBeat + currentNoteObj.m_measureStart - 1;
		
	}
	else if ([elementName isEqualToString:@"startbeat"])
	{
		currentMeasureObj.m_startBeat = [[attributeDict objectForKey:@"value"] floatValue];
	}
	else if ([elementName isEqualToString:@"beatcount"])
	{
		currentMeasureObj.m_beatCount = [[attributeDict objectForKey:@"value"] floatValue];
	}
	else if ([elementName isEqualToString:@"beatvalue"])
	{
		currentMeasureObj.m_beatValue = [[attributeDict objectForKey:@"value"] floatValue];
	}	
	else if ([elementName isEqualToString:@"guitarposition"])
	{
		currentNoteObj.m_string = [[attributeDict objectForKey:@"string"] intValue];
		currentNoteObj.m_fret = [[attributeDict objectForKey:@"fret"] intValue];
	}	
			  
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName 
{

	if ([elementName isEqualToString:@"song"])
	{
		// Sort all the notes.
		[noteObjArray sortUsingSelector:@selector(compare:)];
	}
	else if ([elementName isEqualToString:@"measure"])
	{

		CGFloat beatCount = currentMeasureObj.m_beatCount;
		CGFloat startBeatCount = currentMeasureObj.m_startBeat;
		CGFloat endBeat = beatCount + startBeatCount;
		
		if ( endBeat > maxBeat )
		{
			maxBeat = endBeat;
		}

		// Add this measure to the song.
		[songObj addMeasure:currentMeasureObj];
		
		// Release
		[currentMeasureObj release];

		currentMeasureObj = nil;
		
	}
	else if ([elementName isEqualToString:@"note"])
	{

		// Save the note in the measure.
		[currentMeasureObj addNote:currentNoteObj];
		
		// Release
		[currentNoteObj release];

		currentNoteObj = nil;
		
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

#pragma mark -
#pragma mark Note verifier delegate

// Callback called when a correct string is played
- (void)correctString:(NSInteger)str andFret:(NSInteger)fret
{
	[audioController PluckStringFret:str atFret:fret];
	[self turnOffString:str andFret:fret];
}

- (void)correctString:(NSInteger)str wrongFret:(NSInteger)fret
{
	if ( easyMode == YES )
	{
		[self correctString:str andFret:fret];
	}
}

// Callback called when an incorrect string is played
- (void)incorrectString:(NSInteger)str andFret:(NSInteger)fret
{

}

// Callback called when all correct strings are played
- (void)allCorrectStringsAndFrets
{
	[self stepToNextActiveNoteGroupIsAnimated:NO];
}

#pragma mark -
#pragma mark Hardware interface 

- (Boolean)getEasyMode
{
	return easyMode;
}

// Polling thread
- (void)checkRxSerialInput
{
	unsigned char *pBuffer;
	int bytes_n = serialPort->ReadSerialPort(pBuffer);
	
	if(bytes_n > 0)
	{
		for(int i = 0; i < bytes_n; i++)
		{
			switch(pBuffer[i])
			{
				case 0x80:
				{
					// Make sure that the message is large enough
					if((i + 3) >= bytes_n) 
						return;
					
					// this is note off, the next two indicate midi-note and velocity
					// then one more byte of encoded string/fret position
					unsigned char midinote = pBuffer[i + 1];
					unsigned char vel = pBuffer[i + 2];  
					unsigned char strfret = pBuffer[i + 3];
					
					
					i += 3;
				} break;
					
				case 0x90:
				{
					// Make sure that the message is large enough
					if((i + 3) >= bytes_n) 
						return;
					
					// Note ON, first byte indicates midi note, second byte velocity
					// then last byte is string/fret position
					unsigned char midinote = pBuffer[i + 1];
					unsigned char vel = pBuffer[i + 2];  
					unsigned char strfret = pBuffer[i + 3];
					
					unsigned char str = (strfret >> 5);
					unsigned char fret = (strfret & 0x1F);
					
					// Lets just send the pluck info for this, the other messages are unneeded for now
					//[audioController PluckStringFret:(int)str atFret:(int)fret];
					
					// Send it to the note verifier for review
					[noteVerifier handleInputString:str andFret:fret];
					
					i += 3;
				} break;
					
				case 0xB0:
				{
					if((i + 2) >= bytes_n) 
						return;
					
					// This is a fret down / up message
					// First byte is whether its up or down, second byte is encoded string/fret position
					unsigned char updown = pBuffer[i + 1];
					unsigned char strfret = pBuffer[i + 2];  
					
					unsigned char str = (strfret >> 5);
					unsigned char fret = (strfret & 0x1F);

					if ( updown == 0 )
					{
						[self downString:str andFret:fret];
					}
					else 
					{
						[self upString:str andFret:fret];
					}
					
					i += 2;
				} break;
			}
		}
	}
	
	return;
}

- (void)upString:(NSInteger)str andFret:(NSInteger)fret
{
	if ( ghostNotesOn[str] == fret )
	{
		ghostNotesOn[str] = -1;
	}
}

- (void)downString:(NSInteger)str andFret:(NSInteger)fret
{
	ghostNotesOn[str] = fret;
}

void printToConsoleFromC( char * str )
{
	NSString * msg = [NSString stringWithCString:str];
	[g_vc printToConsole:msg];	
}

- (void)printToConsole:(NSString*)msg
{
	NSString * oldText = consoleView.text;
	NSMutableString * newText = [NSString stringWithFormat:@"%@\n%@", oldText, msg];
	self.consoleView.text = newText;
}

// These notes are represented as strings from the XMP
// They are converted to actual waveforms by the sound layer
- (void)playString:(NSInteger)string atFret:(NSInteger)fret
{
	// The audio controller uses zero-based.
	[audioController PluckStringFret:(string-1) atFret:fret];
}

- (void)turnOnAllActiveNotes
{
	
	for ( NSInteger i = currentNotesIndexStart; i < (currentNotesIndexStart + currentNotesCount); i++ )
	{
		
		Note * note = [noteObjArray objectAtIndex:i];
		
		// The device users zero-based strings
		serialPort->SendLEDMsg((note.m_string-1), note.m_fret, "on");
	
		[NSThread sleepForTimeInterval:0.01];
		
	}
	
}

- (void)turnOffString:(NSInteger)str andFret:(NSInteger)fret
{
	serialPort->SendLEDMsg(str, fret, "off");
	
	[NSThread sleepForTimeInterval:0.01];
}

- (void)turnOffAllActiveNotes
{

	for ( NSInteger i = currentNotesIndexStart; i < (currentNotesIndexStart + currentNotesCount); i++ )
	{
		
		Note * note = [noteObjArray objectAtIndex:i];
		
		// The device users zero-based strings
		serialPort->SendLEDMsg((note.m_string-1), note.m_fret, "off");

		[NSThread sleepForTimeInterval:0.01];
	
	}
	
}

- (void)playAllActiveNotes
{
	
	for ( NSInteger i = currentNotesIndexStart; i < (currentNotesIndexStart + currentNotesCount); i++ )
	{
		
		Note * note = [noteObjArray objectAtIndex:i];
		
		[self playString:note.m_string atFret:note.m_fret];
		
	}
}

// This function takes an array of notes played,
// compares it versus the currently active notes,
// and steps to the next note if they matched.
- (void)verifyNotesPlayedAndStepToNextNote:(NSArray*)notesPlayed
{
	Boolean correct = NO;
	
	// TODO:
	// Compare the notes from this array
	// to the notes in the currentNotesIndexStart subarray
		
	if ( correct == YES )
	{
		// If match, play 'success' sound
		for ( NSInteger i = 0; i < [notesPlayed count]; i++ )
		{
			Note * note = [notesPlayed objectAtIndex:i];
			[self playNote:note.m_value];
		}
	
		// And advance
		[self stepToNextActiveNoteGroupIsAnimated:YES];
	}
	else 
	{
		// Play a bad sound to indicate failure
		[self playNote:FAILURE_NOTE];
	}
}

#pragma mark -
#pragma mark Gesture handling
/*
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
	
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
	{
        UIView * touchView = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:touchView];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:touchView.superview];
        
        touchView.layer.anchorPoint = CGPointMake(locationInView.x / touchView.bounds.size.width, locationInView.y / touchView.bounds.size.height);
        touchView.center = locationInSuperview;
    }
	
}
*/
- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView * touchView = [gestureRecognizer view];
    
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ( [gestureRecognizer state] == UIGestureRecognizerStateBegan ||
		 [gestureRecognizer state] == UIGestureRecognizerStateChanged )
	{
        CGPoint translation = [gestureRecognizer translationInView:[touchView superview]];
        
        //[touchView setCenter:CGPointMake( [piece center].x + translation.x, [piece center].y + translation.y)];
		// Reduces the velocity to zero, very important.
        [gestureRecognizer setTranslation:CGPointZero inView:[touchView superview]];

		CGFloat horizontalTranslation = -translation.x;

		if ( fabsf( horizontalTranslation ) > 0 )
		{
			// Stop animations
			if ( continuousPlay == YES )
			{
				[self toggleContinuousPlay];
			}

			[self stopAnimation];
		
			// Change the current beat.
			[self stepToPixel:horizontalTranslation isAnimated:NO];
		
			// Update the current note
			nextNotesIndexStart = [self findNextNoteAfterBeat:currentBeat];
			nextNotesCount = [self findNotesCloseToNote:nextNotesIndexStart];
			currentNotesIndexStart = nextNotesIndexStart;
			currentNotesCount = 0;

		}
    }
}


#pragma mark -
#pragma mark State management

// Given a beat, find the first note that occurs afterwards.
// Return the index of that note.
- (NSInteger)findNextNoteAfterBeat:(CGFloat)beat
{

	for ( NSInteger i = 0; i < [noteObjArray count]; i++ )
	{
		Note * note = [noteObjArray objectAtIndex:i];
		CGFloat abosoluteBeat = note.m_absoluteBeatStart;
		
		if ( abosoluteBeat > beat )
		{
			return i;
		}
	}

	return -1;
	
}
/*
- (NSInteger)findNextNote
{
	
	for ( NSInteger i = 0; i < [noteObjArray count]; i++ )
	{
		Note * note = [noteObjArray objectAtIndex:i];
		CGFloat abosoluteBeat = note.m_absoluteBeatStart;
		
		if ( abosoluteBeat > currentBeat )
		{
			return i;
		}
	}
	
	return 0;
}
*/


// Given a note index, find all notes that occur within
// a small threshold of that note. Return the count.
- (NSInteger)findNotesCloseToNote:(NSInteger)noteIndex
{
	
	// Include the initial node.
	NSInteger notesFound = 1;

	Note * note = [noteObjArray objectAtIndex:noteIndex];
	CGFloat targetBeat = note.m_absoluteBeatStart;

	for ( NSInteger i = (noteIndex + 1); i < [noteObjArray count]; i++ )
	{
		note = [noteObjArray objectAtIndex:i];
		CGFloat abosoluteBeat = note.m_absoluteBeatStart;
		
		if ( (abosoluteBeat - targetBeat) < BEAT_THRESHOLD )
		{
			notesFound++;
		}
	}
	
	return notesFound;
	
}

#pragma mark -
#pragma mark Display management

- (void)initDisplayParameters
{
	currentBeat = 0.0;
	measureStartIndex = 0;
	measureCount = 1;
	measureMaxCount = 4;
	
	currentNotesIndexStart = 0;
	currentNotesCount = 0;
	
	// TODO: get these dimensions dynamically
	pixelsWidth = VIEW_WIDTH;
	pixelsHeight = VIEW_HEIGHT;
	
	// Calc the distance between beats, after subtracting the buffer
	beatsPerScreen = 4;
	pixelsPerBeat = (pixelsWidth - LEFT_SCREEN_BUFFER) / beatsPerScreen;
	
	// Calc the distance between strings, after subtracting the buffer
	// Strings is '-1' to make sure the spacing is balanced on both sides.
	stringsPerScreen = 6;
	pixelsPerString = (pixelsHeight - TOP_SCREEN_BUFFER - BOTTOM_SCREEN_BUFFER ) / (stringsPerScreen-1);
	
	continuousPlay = NO;
	tempoScale = 1.0;

}

- (CGFloat)convertPixelToBeat:(CGFloat)pixel
{
	return (pixel / pixelsPerBeat);
}

- (CGFloat)convertBeatToPixel:(CGFloat)beat
{
	return (beat * pixelsPerBeat);
}

- (CGFloat)convertAndNormalizeBeatToPixel:(CGFloat)beatStart
{
	// Normalize to the start time
	beatStart -= currentBeat;
	
	// Turn beats into pixels
	CGFloat beatStartPixel = [self convertBeatToPixel:beatStart];
	
	// Bias the pixel start
	beatStartPixel += LEFT_SCREEN_BUFFER;
	
	return beatStartPixel;
}

- (CGFloat)convertStringToPixel:(NSInteger)string
{
	// Calc the pixel locations
	// Strings are 'one-based'
	CGFloat pixel = pixelsHeight - BOTTOM_SCREEN_BUFFER - ((string - 1) * pixelsPerString);

	return pixel;
}

- (void)insertStringLines
{
	// Create and init the element
	// Strings are 'one-based'
	for ( NSInteger i = 1; i < (stringsPerScreen+1); i++ )
	{

		// Get the pixel locations
		CGFloat pixel = [self convertStringToPixel:i];

		DisplayElement * displayElement = [[DisplayElement alloc] init];
		displayElement.m_type = TypeHorizontalLine;
		CGPoint point; 
		point.x = 0;
		point.y = pixel;
		displayElement.m_start = point;
		CGFloat color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
		[displayElement setColor:color];
		
		// Add to display list.
		[displayObjArray addObject:displayElement];
		
		[displayElement release];
		
	}

}

- (void)insertCurrentLine
{
	// Convert the beat to a pixel location
	CGFloat pixel = [self convertAndNormalizeBeatToPixel:currentBeat];

	DisplayElement * displayElement = [[DisplayElement alloc] init];
	displayElement.m_type = TypeVerticalLine;
	CGPoint point; 
	point.x = pixel;
	point.y = 0;
	displayElement.m_start = point;
	CGFloat color[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	[displayElement setColor:color];
	
	// Add to display list.
	[displayObjArray addObject:displayElement];
	
	[displayElement release];
}

- (void)insertMeasureAtBeat:(CGFloat)beat
{
	// Convert the beat to a pixel location
	CGFloat pixel = [self convertAndNormalizeBeatToPixel:beat];

	DisplayElement * displayElement = [[DisplayElement alloc] init];
	displayElement.m_type = TypeVerticalLine;
	CGPoint point; 
	point.x = pixel;
	point.y = 0;
	displayElement.m_start = point;
	CGFloat color[4] = {0.7f, 0.7f, 0.0f, 1.0f};
	[displayElement setColor:color];
	
	// Add to display list.
	[displayObjArray addObject:displayElement];
	
	[displayElement release];

}

- (void)insertBeatAtBeat:(CGFloat)beat
{
	// Convert the beat to a pixel location
	CGFloat pixel = [self convertAndNormalizeBeatToPixel:beat];

	DisplayElement * displayElement = [[DisplayElement alloc] init];
	displayElement.m_type = TypeVerticalLine;
	CGPoint point; 
	point.x = pixel;
	point.y = 0;
	displayElement.m_start = point;
	CGFloat color[4] = {0.2f, 0.2f, 0.0f, 1.0f};
	[displayElement setColor:color];
	
	// Add to display list.
	[displayObjArray addObject:displayElement];
	
	[displayElement release];
	
}

- (void)insertGhostNoteString:(NSInteger)str andFret:(NSInteger)fret
{

	CGFloat stringPixel = [self convertStringToPixel:str];

	DisplayElement * displayElement = [[DisplayElement alloc] init];
	displayElement.m_type = TypeGhostNote;
	CGPoint point; 
	point.x = 0;
	point.y = stringPixel;
	displayElement.m_start = point;
	displayElement.m_length = LEFT_SCREEN_BUFFER;
	
	CGFloat color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
	[displayElement setColor:color];
			
	CGFloat textColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
	[displayElement setTextColor:textColor];
	
	displayElement.m_text = [NSString stringWithFormat:@"%d", fret];
	
	// Add to display list.
	[displayObjArray addObject:displayElement];
}

// This is for forcing notes to align with one another.
// It doesn't actually change the stored values.
- (void)insertNote:(Note*)note withAlignment:(CGFloat)x ofType:(NoteType)type 
{
	Note * adjustedNote = [note mutableCopy];

	adjustedNote.m_absoluteBeatStart = x;
	
	[self insertNote:adjustedNote ofType:type];
	
	[adjustedNote release];
}

- (void)insertNote:(Note*)note ofType:(NoteType)type
{

	// Convert the beats to pixels
	CGFloat beatPixel = [self convertAndNormalizeBeatToPixel:note.m_absoluteBeatStart];
	CGFloat durationPixels = [self convertBeatToPixel:note.m_duration];
	
	// Get String
	CGFloat stringPixel = [self convertStringToPixel:note.m_string];
	

	DisplayElement * displayElement = [[DisplayElement alloc] init];
	displayElement.m_type = TypeNote;
	CGPoint point; 
	point.x = beatPixel;
	point.y = stringPixel;
	displayElement.m_start = point;
	displayElement.m_length = durationPixels;

	switch (type)
	{
	case TypeCurrentNote:
	{
		CGFloat color[4] = {1.0f, 0.0f, 0.0f, 1.0f};
		[displayElement setColor:color];
			
		CGFloat textColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
		[displayElement setTextColor:textColor];
	} break;
			
	case TypeNextNote:
	{
		CGFloat color[4] = {0.0f, 0.0f, 1.0f, 1.0f};
		[displayElement setColor:color];
		
		CGFloat textColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
		[displayElement setTextColor:textColor];
	} break;
			
	case TypeNormalNote:
	default:
	{
		CGFloat color[4] = {0.7f, 0.0f, 0.7f, 1.0f};
//		CGFloat color[4] = {0.0f, 0.0f, 1.0f, 0.4f};
		[displayElement setColor:color];
		
		CGFloat textColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
		[displayElement setTextColor:textColor];
	} break;
	}
	
	displayElement.m_text = [NSString stringWithFormat:@"%d", note.m_fret];
	
	// Add to display list.
	[displayObjArray addObject:displayElement];
	
	[displayElement release];
	
}


// This finds the measure that the 'current line' falls inside.
// (Or the first/last measure if the song is beginning/finished.)
- (void)findCurrentMeasure
{
	NSInteger count = [song count];

	// Search the measures
	for ( NSInteger i = 0; i < count; i++ )
	{
		// Get the measure
		NSDictionary * measure = [song objectAtIndex:i];
		
		CGFloat measureStartBeat = [[measure objectForKey:@"startbeat"] floatValue];	
		
		if ( currentBeat < measureStartBeat )
		{
			measureStartIndex = i;
			
			// Create a one measure buffer to trail off the end of our tab view.
			if ( measureStartIndex > 0 )
			{
				measureStartIndex--;
			}

			// Lower the count if we've run out of measures.
			if ( (count - measureStartIndex) < measureMaxCount )
			{
				measureCount = (count - measureStartIndex);
			}
			else
			{
				measureCount = measureMaxCount;
			}

			return;
			
		}
	}
	
	// We didn't find anything, so the song must be over. 
	// Display the last two measures e.g. as it trails off the end
	if ( count > 1 )
	{
		measureStartIndex = count - 2;
		measureCount = 2;
	}
	else
	{
		// In case the song only has one measure ...
		measureStartIndex = count - 1;
		measureCount = 1;
	}

}

- (void)convertToDisplayElementsAndDisplay
{

	displayObjArray = [[NSMutableArray alloc] init];
	
	
	NSArray * measures = songObj.m_measures;
	// Add the measures
//	for ( NSInteger i = measureStartIndex; i < (measureStartIndex + measureCount); i++ )
	for ( NSInteger i = 0; i < [measures count]; i++ )
	{
		// Insert the measure
		Measure * measure = [measures objectAtIndex:i];

		//CGFloat measureStartBeat = [[measure objectForKey:@"startbeat"] floatValue];
		CGFloat measureStartBeat = measure.m_startBeat;

		if ( measureStartBeat > (currentBeat - 0.5) ||
			 measureStartBeat < (currentBeat + 4.0) )
		{
			[self insertMeasureAtBeat:measureStartBeat];
		}

		// Insert the beats
		NSInteger beatCount = measure.m_beatCount;
		
		// TODO: All beats in the data are Ints for now, but can be floats in the future
		//NSInteger beatValue = [[measure objectForKey:@"beatvalue"] intValue];
		
		// We skip the first beat because the measure's line is already there.
		for ( NSInteger j = 1; j < beatCount; j++ )
		{
			NSInteger adjustedBeat = measureStartBeat + j; 
			if ( adjustedBeat > (currentBeat - 0.5) ||
				adjustedBeat < (currentBeat + 4.0) )
			{
				[self insertBeatAtBeat:adjustedBeat];
			}
		}
		
#if 0
		// Insert the notes.
		NSArray * notes = measure.m_notes;
		
		for ( NSInteger j = 0; j < [notes count]; j++ )
		{
			Note * note = [notes objectAtIndex:j];
			
			// Convert note to x/y coords
			CGFloat beat = note.m_absoluteBeatStart;
			NSInteger string = note.m_string;

			{
				[self insertNote:note isActive:NO];
			}
			
		}
#endif
	}

	// Add the string lines
	[self insertStringLines];

	//
	// These three subsets of notes are rendered in this order
	// with the painters algorithm in minde. We want active notes
	// to render last so they are on top and more visible.
	//
		
	// Add the current note line
	// We add this last so it is always on top
	[self insertCurrentLine];
	
	// Inactive notes
	for ( NSInteger i = 0; i < currentNotesIndexStart; i++ )
	{
		Note * note = [noteObjArray objectAtIndex:i];
		if ( note.m_absoluteBeatStart > (currentBeat - 0.5) ||
			note.m_absoluteBeatStart < (currentBeat + 4.0) )
		{
			[self insertNote:note ofType:TypeNormalNote];
		}
	}

	// The rest of the inactive notes.
	for ( NSInteger i = (nextNotesIndexStart + nextNotesCount); i < [noteObjArray count]; i++ )
	{
		Note * note = [noteObjArray objectAtIndex:i];

		if ( note.m_absoluteBeatStart > (currentBeat - 0.5) ||
			note.m_absoluteBeatStart < (currentBeat + 4.0) )
		{
			[self insertNote:note ofType:TypeNormalNote];
		}
	}

	// Next notes.
	Note * nextNote = [noteObjArray objectAtIndex:nextNotesIndexStart];
	for ( NSInteger i = nextNotesIndexStart; i < (nextNotesIndexStart + nextNotesCount); i++ )
	{
		Note * note = [noteObjArray objectAtIndex:i];
//		[self insertNote:note ofType:TypeNextNote];
		if ( note.m_absoluteBeatStart > (currentBeat - 0.5) ||
			 note.m_absoluteBeatStart < (currentBeat + 4.0) )
		{
			[self insertNote:note withAlignment:nextNote.m_absoluteBeatStart ofType:TypeNextNote];
		}
	}
	
	// Ghost notes
	for ( NSInteger i = 0; i < GUITAR_STRINGS; i++ )
	{
		if ( ghostNotesOn[i] != -1 )
		{
			[self insertGhostNoteString:(i+1) andFret:ghostNotesOn[i]];
		}
	}
	
	// Current notes
	Note * activeNote = [noteObjArray objectAtIndex:currentNotesIndexStart];
	for ( NSInteger i = currentNotesIndexStart; i < (currentNotesIndexStart + currentNotesCount); i++ )
	{
		Note * note = [noteObjArray objectAtIndex:i];
		if ( note.m_absoluteBeatStart > (currentBeat - 0.5) ||
			note.m_absoluteBeatStart < (currentBeat + 4.0) )
		{
			[self insertNote:note withAlignment:activeNote.m_absoluteBeatStart ofType:TypeCurrentNote];
		}
	}

	// Update the view and flag as in need of display
	[tabView updateDisplayElements:displayObjArray];

	[tabView setNeedsDisplay];
	
	[displayObjArray release];
	
}

#pragma mark -
#pragma mark Step handling

- (void)stepToNextActiveNoteGroupIsAnimated:(Boolean)animated
{
	
	// Play the notes as we are passing by them.
	if ( currentNotesCount > 0 )
	{
		//[self turnOffAllActiveNotes];
		//[self playAllActiveNotes];
	}
	
	// The set of next notes become the current notes
	currentNotesIndexStart = nextNotesIndexStart;
	currentNotesCount = nextNotesCount;
	
	// Figure out which note comes next
	nextNotesIndexStart = currentNotesIndexStart + currentNotesCount;
	
	// TODO: Currently Wrap around to front -- should we just stop instead?
	if ( nextNotesIndexStart >= [noteObjArray count] )
	{
		nextNotesIndexStart = 0;
	}
	
	// .. and how many are in the cluster of notes
	nextNotesCount = [self findNotesCloseToNote:nextNotesIndexStart];
	
	// Move to the location of the current note
	Note * note = [noteObjArray objectAtIndex:currentNotesIndexStart];
	
	[self stepToBeatAbsolute:note.m_absoluteBeatStart isAnimated:animated];
	
	// Turn on the lights of the new current notes
	[self turnOnAllActiveNotes];
	
	// Inform the note verifier what notes it should look for
	NSRange range;
	
	range.location = currentNotesIndexStart;
	range.length = currentNotesCount;
	
	noteVerifier.targetNotes = [[noteObjArray subarrayWithRange:range] mutableCopyWithZone:nil];
	
	/*
	 currentNotesIndexStart += currentNotesCount;
	 
	 // Start over.
	 if ( currentNotesIndexStart >= [noteObjArray count] )
	 {
	 if ( continuousPlay == YES )
	 {
	 [self toggleContinuousPlay];
	 }
	 
	 [self initDisplayParameters];
	 [self convertToDisplayElementsAndDisplay];
	 return;
	 }
	 
	 Note * note = [noteObjArray objectAtIndex:currentNotesIndexStart];
	 
	 currentNotesCount = [self findNotesCloseToNote:currentNotesIndexStart];
	 
	 [self stepToBeatAbsolute:note.m_absoluteBeatStart isAnimated:animated];
	 */
}

- (void)stepToBeatAbsolute:(CGFloat)absolute isAnimated:(Boolean)animated
{
	CGFloat delta = absolute - currentBeat;
	[self stepToBeat:delta isAnimated:animated];
}

- (void)stepToBeat:(CGFloat)delta isAnimated:(Boolean)animated
{
	
	if ( animated == NO )
	{
		currentBeat += delta;
		[self convertToDisplayElementsAndDisplay];
		
	}
	// Only start a new animation if no other is running.
	else if ( framesRemaining == 0 )
	{
		
		if ( fabsf(delta) < ANIMATE_BEATS_PER_FRAME )
		{
			[self stepToBeat:delta isAnimated:NO];
		}
		else
		{
			
			framesRemaining = fabsf(delta) / ANIMATE_BEATS_PER_FRAME;
			beatDeltaPerFrame = delta / framesRemaining;
			CGFloat remainder = delta - (framesRemaining * beatDeltaPerFrame);
			
			// Increment the remaining delta now
			if ( remainder > 0 )
			{
				[self stepToBeat:remainder isAnimated:NO];
			}
			
			[self startAnimation];
			
		}
		
	}
	
}

- (void)stepToPixel:(CGFloat)delta isAnimated:(Boolean)animated
{
	CGFloat beatDelta = [self convertPixelToBeat:delta];
	[self stepToBeat:beatDelta isAnimated:animated];
}

#pragma mark -
#pragma mark Animation handlings

- (void)eachFrame
{
	if ( framesRemaining > 0 )
	{
		framesRemaining--;
		
		[self stepToBeat:beatDeltaPerFrame isAnimated:NO];

//		NSTimeInterval animationInterval = 1.0 / FRAMES_PER_SECOND;
//		self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(eachFrame) userInfo:nil repeats:YES];
	}
	else
	{
		[self stopAnimation];
		
		// If we are on continuous loop, start again.
		if ( continuousPlay )
		{
			
			if ( (currentNotesIndexStart + currentNotesCount) < [noteObjArray count] )
			{
				[self stepToNextActiveNoteGroupIsAnimated:YES];
			}
			else
			{
				// We hit the end of the song, stop the playing.
				[self toggleContinuousPlay];
				
				// Reset the state.
				[self initDisplayAndStepToActiveNotes];
			}				
		}
		
	}
}

- (void)startAnimation
{
	NSTimeInterval animationInterval = 1.0 / FRAMES_PER_SECOND;

    animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(eachFrame) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
	if ( animationTimer != nil )
	{
		[animationTimer invalidate];
		animationTimer = nil;
		framesRemaining = 0;
	}
}

/*
- (void)setAnimationTimer:(NSTimer *)newTimer
{
    [animationTimer invalidate];
    animationTimer = newTimer;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}
*/

- (void)toggleContinuousPlay
{
	if ( continuousPlay == NO )
	{
		[self stepToNextActiveNoteGroupIsAnimated:YES];
		[playButton setTitle:@"Pause" forState:nil];
	}
	else
	{
		[playButton setTitle:@"Play" forState:nil];
	}
	
	continuousPlay = !continuousPlay;	
}

#pragma mark -
#pragma mark Button click handling

- (IBAction)pauseButtonClicked:(id)sender
{
	// Pause/restart the animation
	[self toggleContinuousPlay];	
}

- (IBAction)stopButtonClicked:(id)sender
{
	// TODO: We also need to save the progress before we return.
	[self stopAnimation];
	[self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)stepForwardButtonClicked:(id)sender
{
	
	// Transition to the next step
	[self turnOffAllActiveNotes];
	[self stepToNextActiveNoteGroupIsAnimated:NO];
	
}

- (IBAction)stepBackwardButtonClicked:(id)sender
{

	// This is currently the restart button.
	[self initDisplayAndStepToActiveNotes];
	
}

- (IBAction)tempoButtonClicked:(id)sender
{
	// Cycle the speeds: 1x, 0.5x, 0.25x
	if ( tempoScale > 0.9f ) // 1.0
	{
		tempoScale = 0.75f;
	}
	else if ( tempoScale > 0.7 ) // 0.75
	{
		tempoScale = 0.5f;

	}
	else if ( tempoScale > 0.4 ) // 0.5
	{
		tempoScale = 0.25f;

	}
	else // 0.25
	{
		tempoScale = 1.0f;
	}
	
	NSString * label = [[NSString alloc] initWithFormat:@"Tempo (%.2fx)", tempoScale];
	
	[tempoButton setTitle:label forState:nil];
	
	[label release];
}

- (IBAction)debugButtonClicked:(id)sender
{

	consoleView.hidden = !consoleView.hidden;
	
}

- (IBAction)easyButtonClicked:(id)sender
{
	
	if ( easyMode == NO )
	{
		[easyButton setTitle:@"Hard" forState:nil];
		easyMode = YES;
	}
	else
	{
		[easyButton setTitle:@"Easy" forState:nil];
		easyMode = NO;
	}

}

#pragma mark -
#pragma mark External access

- (CGFloat)getPercentCompletion
{
	CGFloat notesComplete = currentNotesIndexStart;
	CGFloat notesTotal = [noteObjArray count];
	return (notesComplete / notesTotal);
}

#pragma mark -
#pragma mark VC teardown

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	
	delete serialPort;
}


@end
