//
//  SongCreator.m
//  gTar
//
//  Created by Marty Greenia on 1/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "SongCreator.h"

@implementation SongCreator

@synthesize m_xmpBlob;

- (SongCreator*)initWithSong:(CSong*)song
{
	if ( (self = [super init]) )
	{
        // Initialization code
		
		m_song = song;
		
		m_indent = 0;
		
		// Parse the thing into a song
		[self createXmp];
		
    }
	
    return self;
}

+ (NSString*)xmpBlobWithSong:(CSong*)song
{
	SongCreator * songCreator = [[SongCreator alloc] initWithSong:song];
	
	NSString * xmpBlock = [songCreator.m_xmpBlob autorelease];
	
	[songCreator release];
	
	return xmpBlock;
}

- (void)dealloc
{
	//[m_xmpBlob release];

	[super dealloc];
}

// XML (XMP) functions
- (void)createXmp
{
	m_xmpBlob = [[NSMutableString alloc] init];

	CMeasure * measure;
	CNote * note;

	OUTPUT_XMP("<song>");
    INCREASE_INDENT;
	
	// output header info
	// ....
	//[self outputDummyHeader];
	[self outputSmartHeader];
	
	OUTPUT_XMP("<content>");
    INCREASE_INDENT;
	
    OUTPUT_XMP("<track name=\"main\">");
    INCREASE_INDENT;

	// output measure info
	for ( measure = m_song->m_measures; measure != NULL; measure = measure->m_next )
	{
		
		OUTPUT_XMP("<measure>");
		INCREASE_INDENT;
		
		OUTPUT_XMP("<startbeat value=\"%u\" />", (unsigned int)measure->m_startBeat );
		OUTPUT_XMP("<beatcount value=\"4\" />", measure->m_beatCount );
		OUTPUT_XMP("<beatvalue value=\"1\" />", measure->m_beatValue );
		

		for ( note = measure->m_notes; note != NULL; note = note->m_next )
		{
			
			OUTPUT_XMP("<note value=\"%s\" duration=\"%f\" measurestart=\"%f\">", note->m_value, note->m_duration, note->m_measureStart );
			INCREASE_INDENT;
			// convert zero- to one-based strings
			OUTPUT_XMP("<guitarposition string=\"%u\" fret=\"%u\" />", (note->m_string+1), note->m_fret );
			
			DECREASE_INDENT;
			OUTPUT_XMP("</note>");
			
		}
		
		DECREASE_INDENT;
		OUTPUT_XMP("</measure>");

	}
	
	DECREASE_INDENT;
    OUTPUT_XMP("</track>");
	
    DECREASE_INDENT;
    OUTPUT_XMP("</content>");
   
	DECREASE_INDENT;
	OUTPUT_XMP("</song>");
	
}

- (void)outputDummyHeader
{
	
    OUTPUT_XMP("<header>");
    INCREASE_INDENT;
	
    OUTPUT_XMP("<id value=\"1\" />");
	
    OUTPUT_XMP("<title>gTar Song</title>");
	
    OUTPUT_XMP("<author>Author Name</author>");
	
    OUTPUT_XMP("<description>www.strumhub.com</description>");
	
    OUTPUT_XMP("<tempo value=\"120\" />");
	
    DECREASE_INDENT;
    OUTPUT_XMP("</header>");
	
}

- (void)outputSmartHeader
{
	
    OUTPUT_XMP("<header>");
    INCREASE_INDENT;
	
    OUTPUT_XMP("<id value=\"%d\" />", m_song->m_id);
	
	if ( strlen(m_song->m_name) > 0 )
	{
		OUTPUT_XMP("<title>%s</title>", m_song->m_name);
	}
	else
	{
		OUTPUT_XMP("<title>gTar Song</title>");
	}

	if ( strlen(m_song->m_artist) > 0 )
	{
		OUTPUT_XMP("<author>%s</author>", m_song->m_artist);
	}
	else 
	{
	    OUTPUT_XMP("<author>Author Name</author>");
	}
	
	if ( strlen(m_song->m_description) > 0 )
	{
		OUTPUT_XMP("<description>%s</description>", m_song->m_description);
	}
	else 
	{
		OUTPUT_XMP("<description>www.strumhub.com</description>");
	}
	
	if ( m_song->m_tempo > 0 )
	{
		OUTPUT_XMP("<tempo value=\"%f\" />", m_song->m_tempo);
	}
	else
	{
		OUTPUT_XMP("<tempo value=\"120\" />");
	}
	
    DECREASE_INDENT;
    OUTPUT_XMP("</header>");
	
}

@end
