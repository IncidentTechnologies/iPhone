//
//  NSSongCreator.h
//  gTar
//
//  Created by Marty Greenia on 10/1/2012.
//  Copyright 2012 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSSong;
@class NSMeasure;
@class NSNote;

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


@interface NSSongCreator : NSObject
{
	// State members
	NSMutableString * m_xmpBlob;
	NSSong * m_song;
	
	// XML (XMP) members
	NSSong * m_currentSong;
	NSMeasure * m_currentMeasure;
	NSNote * m_currentNote;
	
	NSInteger m_indent;
}

// State members
@property (nonatomic, retain) NSMutableString * m_xmpBlob;

// Init functions
- (id)initWithSong:(NSSong*)song;
+ (NSString*)xmpBlobWithSong:(NSSong*)song;

// XML (XMP) functions
- (void)createXmp;
- (void)outputDummyHeader;
- (void)outputSmartHeader;

@end
