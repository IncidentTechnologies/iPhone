//
//  NSNote.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "AppCore.h"

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
	GtarString m_string; // 0-5
	GtarFret m_fret;
	
}

@property (nonatomic, assign) double m_duration;
@property (nonatomic, strong) NSString * m_value;
@property (nonatomic, assign) double m_measureStart;
@property (nonatomic, assign) double m_absoluteBeatStart;
@property (nonatomic, assign) GtarString m_string;
@property (nonatomic, assign) GtarFret m_fret;
@property (nonatomic, assign) BOOL m_standaloneActive;

- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (id)initWithDuration:(double)duration
			  andValue:(NSString*)value
	   andMeasureStart:(double)measureStart
  andAbsoluteBeatStart:(double)absoluteBeatStart
			 andString:(GtarString)str
			   andFret:(GtarFret)fret;

- (NSComparisonResult)compare:(NSNote*)note;

@end
