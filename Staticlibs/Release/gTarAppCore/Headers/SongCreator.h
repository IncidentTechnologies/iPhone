//
//  SongCreator.h
//  gTar
//
//  Created by Marty Greenia on 1/24/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSong.h"

#define INCREASE_INDENT m_indent++
#define DECREASE_INDENT m_indent--

#define OUTPUT_XMP( ... ) \
 \
	for ( unsigned int m_i = 0; m_i < m_indent; m_i++ ) \
	{ \
		[m_xmpBlob appendString:@"  "]; \
	} \
	[m_xmpBlob appendFormat:@__VA_ARGS__]; \
	[m_xmpBlob appendString:@"\n"]; \


@interface SongCreator : NSObject
{
	// State members
	NSMutableString * m_xmpBlob;
	CSong * m_song;
	
	// XML (XMP) members
	CSong * m_currentSong;
	CMeasure * m_currentMeasure;
	CNote * m_currentNote;
	
	NSInteger m_indent;
}

// State members
@property (nonatomic, retain) NSMutableString * m_xmpBlob;

// Init functions
- (SongCreator*)initWithSong:(CSong*)song;
+ (NSString*)xmpBlobWithSong:(CSong*)song;

// XML (XMP) functions
- (void)createXmp;
- (void)outputDummyHeader;
- (void)outputSmartHeader;

@end
