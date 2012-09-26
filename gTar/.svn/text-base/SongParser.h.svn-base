//
//  SongParser.h
//  gTar
//
//  Created by Marty Greenia on 10/13/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSong.h"
#import "CMeasure.h"
#import "CNote.h"

#define SONG_PARSER_NOTE_ALIGN_THRESHOLD (0.2f)

// iOS 3.2 doesn't have this delegate
//@interface SongParser : NSObject <NSXMLParserDelegate>
@interface SongParser : NSObject 
{
	// State members
	NSString * m_xmpBlob;
	CSong * m_song;
	
	// XML (XMP) members
	CSong * m_currentSong;
	CMeasure * m_currentMeasure;
	CNote * m_currentNote;
	
	NSMutableString * m_currentText;

}

// State members
@property (nonatomic) CSong * m_song;

// Init functions
- (SongParser*)initWithXmpBlob:(NSString*)xmpBlob;
+ (CSong*)songWithXmpBlob:(NSString*)xmpBlob;

// XML (XMP) functions
- (void)parseXmp;

@end
