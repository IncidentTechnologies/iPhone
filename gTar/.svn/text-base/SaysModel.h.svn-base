//
//  SaysModel.h
//  gTar
//
//  Created by wuda on 12/7/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SongModel.h"
#include "CMeasure.h"

enum SaysModelMode
{
	SaysModelModeDelay = 0,
	SaysModelModeInstruct,
	SaysModelModeListen
};

// get the current measure
// iterate through it in 'two loops', playing sounds+getting input
// move to the next measure

// play sounds with some sense of timing -- input can be timeless


// this could wrap an existing songmodel? would that acutlally make thigns easierr tho:
// -the song object provides access to the measures and notes. 
// -i need to be able to coalesce notes with the same start time
// -it should be able to handle outputting sound at the appropriate time based on the xmp startimes
// -similarlly handling input in-time, although doesn't have to (except on hard mode?)
// -find the 'next notes', target notes, etc. the same way that songmodel does it.
// -- maybee just add some new functions to song model, why reinvent the wheel?

// song model needs the ability to:
// -- re-align the current beat to a measure start.
// -- play w/o input PlayMode .. 'play next n notes'
// -- work in step-mode .. 'input next n notes'
// -- detect end of measure
@interface SaysModel : NSObject
{

	SaysModelMode m_mode;

	double m_delay;
	
	SongModel * m_songModel;
	NSInteger m_currentMeasure;
	NSInteger m_currentMeasureLength;
	double m_currentMeasureStartBeat;
	NSInteger m_currentMeasureNotesCount;
	
	NSInteger m_currentSequenceLength;
	NSInteger m_currentSequenceLengthTarget;
	NSInteger m_currentSequenceLengthTargetMax;	
	NSInteger m_currentSequenceNotesSeen;
	
	NSString * m_status;
	NSInteger m_maxSequence;
	
	bool m_endOfSong;
	
	char m_currentInstructNotes[ GTAR_GUITAR_STRING_COUNT ];
	char m_currentListenNotes[ GTAR_GUITAR_STRING_COUNT ];

	
}

@property (nonatomic, assign) SaysModelMode m_mode;
@property (nonatomic, assign) double m_delay;
@property (nonatomic, assign) SongModel * m_songModel;
@property (nonatomic, assign) NSInteger m_currentSequenceLength;
@property (nonatomic, assign) NSInteger m_currentSequenceLengthTarget;
@property (nonatomic, retain) NSString * m_status;
@property (nonatomic, assign) NSInteger m_maxSequence;

- (SaysModel*)initWithSongModel:(SongModel*)songModel;
- (void)resetModel;
- (void)advanceModelByDeltaTimeSeconds:(double)delta;
- (void)advanceModelToNextTargetNotes;
//- (bool)hitTestString:(char)str andFret:(char)fret;
- (void)delayForTimeDelta:(double)delta;
- (bool)hitTestNoteString:(char)str andFret:(char)fret;
- (void)hitWrongNote;

- (NoteArrayRange)getTargetNotes;
- (NSInteger)targetNotesRemaining;
- (void)getTargetInstructNotes:(char*)output;
- (void)getTargetListenNotes:(char*)output;

- (bool)isEndOfSong;
@end
