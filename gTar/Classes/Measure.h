//
//  Measure.h
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

@interface Measure : NSObject {
	
	NSMutableArray * m_notes;
	
	CGFloat m_startBeat;
	CGFloat m_beatCount;
	CGFloat m_beatValue;

}

@property (nonatomic, retain) NSMutableArray * m_notes;
@property (nonatomic) CGFloat m_startBeat;
@property (nonatomic) CGFloat m_beatCount;
@property (nonatomic) CGFloat m_beatValue;

-(id)init;
-(void)dealloc;
-(void)addNote:(Note*)note;
-(void)sortNotes;

@end
