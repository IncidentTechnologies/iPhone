//
//  SaysModel.m
//  gTar
//
//  Created by wuda on 12/7/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "SaysModel.h"

@implementation SaysModel

@synthesize m_mode;
@synthesize m_delay;
@synthesize m_songModel;
@synthesize m_currentSequenceLengthTarget, m_currentSequenceLength;
@synthesize m_status;
@synthesize m_maxSequence;

- (SaysModel*)initWithSongModel:(SongModel*)songModel
{
	
	if ( self = [super init] )
	{
		self.m_songModel = songModel;
	
		[self resetModel];		
	}		
	
	return self;
}

- (void)resetModel
{

	self.m_mode = SaysModelModeDelay;
	m_delay = 3.00f; // 3 seconds
	
	// no external getters for these variables
	m_currentSequenceLength = 0;
	m_currentSequenceLengthTarget = 1;
	m_maxSequence = 0;
	
	// optional
	//m_currentSequenceLengthTargetMax = 8;
	//m_currentSequenceLengthTargetMax = 8;
	
	// until proven otherwise
	m_status = @"Success!";
	
	m_endOfSong = NO;
	
	// give a full beat before begining
	m_songModel->StartModelAtTime(0);
	
	m_currentMeasure = 0;
	
	MeasureArray * measures = m_songModel->GetMeasureArray();
	
	CMeasure * measure = &measures->m_measures[ m_currentMeasure ];
	
	m_currentMeasureStartBeat = measure->m_startBeat;
	m_currentMeasureNotesCount = measure->m_notesCount;
	
}

- (void)advanceModelByDeltaTimeSeconds:(double)delta
{
	
	// advance the internal song model. 
	// track how many notes we've past.
	// signal (?) when we hit the limit.
	// Then, reset for the next advancement.

	// Time based
	NoteArrayRange previousTargetNotes = m_songModel->GetTargetNotes();
	
	// Advance our song model
	m_songModel->AdvanceModelByDeltaTimeSeconds(delta);
	
	NoteArrayRange currentTargetNotes = m_songModel->GetTargetNotes();
	
	// Save what the currently targeted listen notes are.
	m_songModel->GetUnHitTargetNotesBytes( m_currentInstructNotes );
	
	// If the target notes changed
	// OR if the measure starts with a note (e.g. there is no edge)
	if ( (currentTargetNotes.m_index != previousTargetNotes.m_index || currentTargetNotes.m_count != previousTargetNotes.m_count) ||
		  (m_currentSequenceLength == 0 && currentTargetNotes.m_count > 0) )
	{
		
		if ( currentTargetNotes.m_count > 0 )
		{
			m_currentSequenceLength++;
		}
		
		if ( m_currentSequenceLength >= m_currentSequenceLengthTarget )
		{
			// we are done with this round of notes, switch modes
			m_mode = SaysModelModeListen;
			
			m_currentSequenceLength = 0;
			
			m_songModel->AdvanceModelToAbsoluteBeat( m_currentMeasureStartBeat );
			
			//[self advanceModelToNextTargetNotes];
			
			m_songModel->AdvanceModelToNextTargetNotesFromBeat();
			
			// Save what the currently targeted listen notes are.
			m_songModel->GetUnHitTargetNotesBytes( m_currentListenNotes );

		}
		
	}
	
}

- (void)advanceModelToNextTargetNotes
{
	
	m_currentSequenceLength++;
	
	NoteArrayRange range = m_songModel->GetTargetNotes();
	
	m_currentSequenceNotesSeen += range.m_count;
	
	m_songModel->AdvanceModelToNextTargetNotes();
	
	// Save what the currently targeted listen notes are.
	m_songModel->GetUnHitTargetNotesBytes( m_currentListenNotes );
	
	if ( m_currentSequenceLength >= m_currentSequenceLengthTarget )
	{
		
		m_currentSequenceLengthTarget++;
		m_maxSequence++;

		// move onto the next measure
//		if ( m_currentSequenceLengthTarget >= m_currentMeasureLength )
		if ( m_currentSequenceNotesSeen >= m_currentMeasureNotesCount )
		{
			// We are done with this measure, move to the next
			m_currentMeasure++;
			
			MeasureArray * measures = m_songModel->GetMeasureArray();
			
			if ( m_currentMeasure >= measures->m_measureCount )
			{
				m_endOfSong = YES;
				return;
			}
			
			CMeasure * measure = &measures->m_measures[ m_currentMeasure ];
			
			m_currentMeasureStartBeat = measure->m_startBeat;
			m_currentMeasureNotesCount = measure->m_notesCount;

			// reset the sequence length back to 1
			m_currentSequenceLengthTarget = 1;
						
		}

		m_currentSequenceNotesSeen = 0;
		m_currentSequenceLength = 0;
		
		m_songModel->AdvanceModelToAbsoluteTimeSeconds(m_currentMeasureStartBeat);
		
		//m_mode = SaysModelModeInstruct;
		m_mode = SaysModelModeDelay;
		m_delay = 2.00f; // 2 seconds
		
	}
	
}

- (void)delayForTimeDelta:(double)delta
{
	
	m_delay -= delta;
	
	if ( m_delay <= 0 )
	{
		m_mode = SaysModelModeInstruct;
	}
		
}

- (bool)hitTestNoteString:(char)str andFret:(char)fret
{
	if ( m_songModel->HitTestNote(str, fret) )
	{
		// if yes, we are good for now
		return YES;
	}
	else 
	{
		// else, we have failed!
		m_status = @"Failure!";
		return NO;
	}
}

- (void)hitWrongNote
{
	m_endOfSong = YES;
}

- (NoteArrayRange)getTargetNotes
{
	return m_songModel->GetTargetNotes();	
}

- (NSInteger)targetNotesRemaining
{	
	return m_songModel->TargetNotesRemaining();
}

- (void)getTargetInstructNotes:(char*)output
{
	memcpy( output, m_currentInstructNotes, GTAR_GUITAR_STRING_COUNT );
}

- (void)getTargetListenNotes:(char*)output
{
	memcpy( output, m_currentListenNotes, GTAR_GUITAR_STRING_COUNT );
}

- (bool)isEndOfSong
{
	return m_endOfSong;
}

@end
