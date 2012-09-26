//
//  NSNote.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <gTar.h>

#import "CNote.h"

@class XmlDom;

@interface NSNote : NSObject
{
	
	double m_duration;
	NSString * m_value;

	// The beat within the measure where this note starts.
	// Although relative to the start of the measure,
	// it is actually one-indexed.
	double m_measureStart;
	
	// Absolute beat start (relative to the begining of the song, beat 0)
	double m_absoluteBeatStart;
	
	// Attributes of the 'guitarposition' element, stored in this note for simplicity
	GuitarString m_string; // 0-5
	GuitarFret m_fret;
	
}

@property (nonatomic, assign) double m_duration;
@property (nonatomic, retain) NSString * m_value;
@property (nonatomic, assign) double m_measureStart;
@property (nonatomic, assign) double m_absoluteBeatStart;
@property (nonatomic, assign) GuitarString m_string;
@property (nonatomic, assign) GuitarFret m_fret;

- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (id)initWithDuration:(double)duration
			  andValue:(NSString*)value
	   andMeasureStart:(double)measureStart
  andAbsoluteBeatStart:(double)absoluteBeatStart
			 andString:(GuitarString)str
			   andFret:(GuitarFret)fret;

- (NSComparisonResult)compare:(NSNote*)note;
- (CNote*)convertToCNote;

@end
