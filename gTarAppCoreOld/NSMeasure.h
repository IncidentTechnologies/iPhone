//
//  NSMeasure.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/16/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "CNote.h"
#import "CMeasure.h"

@class NSNote;
@class XmlDom;

@interface NSMeasure : NSObject
{
	
	NSMutableArray * m_notes;
	
	double m_startBeat;
	double m_beatCount;
	double m_beatValue;
	
}

@property (nonatomic, retain) NSArray * m_notes;

@property (nonatomic, assign) double m_startBeat;
@property (nonatomic, assign) double m_beatCount;
@property (nonatomic, assign) double m_beatValue;

- (id)initWithXmlDom:(XmlDom*)xmlDom;

- (id)initWithStartBeat:(double)startBeat
		   andBeatCount:(double)beatCount
		   andBeatValue:(double)beatValue;

- (void)addNote:(NSNote*)note;
- (NSComparisonResult)compare:(NSMeasure*)measure;
- (CMeasure*)convertToCMeasure;

@end
