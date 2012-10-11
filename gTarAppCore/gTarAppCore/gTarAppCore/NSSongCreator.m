//
//  NSSongCreator.m
//  gTar
//
//  Created by Marty Greenia on 10/1/2012.
//  Copyright 2012 IncidentTech. All rights reserved.
//

#import "NSSongCreator.h"

#import "AppCore.h"

#import "NSSong.h"
#import "NSMeasure.h"
#import "NSNote.h"

@implementation NSSongCreator

@synthesize m_xmpBlob;

- (id)initWithSong:(NSSong*)song
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

+ (NSString*)xmpBlobWithSong:(NSSong*)song
{
	NSSongCreator * songCreator = [[NSSongCreator alloc] initWithSong:song];
	
	NSString * xmpBlock = songCreator.m_xmpBlob;
	
	[songCreator autorelease];
	
	return xmpBlock;
}

- (void)dealloc
{
	[m_xmpBlob release];

	[super dealloc];
}

// XML (XMP) functions
- (void)createXmp
{
	m_xmpBlob = [[NSMutableString alloc] init];
    
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
    for ( NSMeasure * measure in m_song.m_measures )
    {		
		OUTPUT_XMP("<measure>");
		INCREASE_INDENT;
		
		OUTPUT_XMP("<startbeat value=\"%u\" />", (unsigned int)measure.m_startBeat );
		OUTPUT_XMP("<beatcount value=\"4\" />", measure.m_beatCount );
		OUTPUT_XMP("<beatvalue value=\"1\" />", measure.m_beatValue );
		
        for ( NSNote * note in measure.m_notes )
		{
			
			OUTPUT_XMP("<note value=\"%@\" duration=\"%f\" measurestart=\"%f\">", note.m_value, note.m_duration, note.m_measureStart );
			INCREASE_INDENT;
            
            if ( note.m_fret == GTAR_GUITAR_FRET_MUTED )
            {
                OUTPUT_XMP("<guitarposition string=\"%u\" fret=\"X\" />", note.m_string );
            }
            else
            {
                OUTPUT_XMP("<guitarposition string=\"%u\" fret=\"%u\" />", note.m_string, note.m_fret );
            }
			
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
	
    OUTPUT_XMP("<id value=\"%d\" />", m_song.m_id);
	
	if ( [m_song.m_title length] > 0 )
	{
		OUTPUT_XMP("<title>%s</title>", [m_song.m_title cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	else
	{
		OUTPUT_XMP("<title>gTar Song</title>");
	}

	if ( [m_song.m_author length] > 0 )
	{
		OUTPUT_XMP("<author>%s</author>", [m_song.m_author cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	else 
	{
	    OUTPUT_XMP("<author>Author Name</author>");
	}
	
	if ( [m_song.m_description length] > 0 )
	{
		OUTPUT_XMP("<description>%s</description>", [m_song.m_description cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	else 
	{
		OUTPUT_XMP("<description>www.incidenttech.com</description>");
	}
	
	if ( m_song.m_tempo > 0 )
	{
		OUTPUT_XMP("<tempo value=\"%f\" />", m_song.m_tempo);
	}
	else
	{
		OUTPUT_XMP("<tempo value=\"120\" />");
	}
    
    if ( [m_song.m_instrument length] > 0 )
	{
		OUTPUT_XMP("<instrument name=\"%s\" />", [m_song.m_instrument cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	
    DECREASE_INDENT;
    OUTPUT_XMP("</header>");
	
}

@end
