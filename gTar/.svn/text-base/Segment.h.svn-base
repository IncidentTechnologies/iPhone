//
//  Segment.h
//  gTar
//
//  Created by wuda on 11/3/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "gTar.h"

enum SegmentAdvanceMethod
{
	AdvanceMethodTouch,
	AdvanceMethodNotes
};

@interface Segment : NSObject
{
	NSInteger m_id;
	NSInteger m_nextId;
	NSInteger m_nextIdSuccess;
	NSInteger m_nextIdFailure;

	NSString * m_instructionText;

	char m_targetNotes[ GTAR_GUITAR_STRING_COUNT ];
	
	SegmentAdvanceMethod m_advanceMethod;

}

@property (nonatomic) NSInteger m_id;
@property (nonatomic) NSInteger m_nextId;
@property (nonatomic) NSInteger m_nextIdSuccess;
@property (nonatomic) NSInteger m_nextIdFailure;
@property (nonatomic, retain) NSString * m_instructionText;
@property (nonatomic) SegmentAdvanceMethod m_advanceMethod;

-(void)setTargetNotes:(char*)targetNote;
-(void)getTargetNotes:(char*)output;
-(void)setTargetNoteString:(char)str andFret:(char)fret;


@end
