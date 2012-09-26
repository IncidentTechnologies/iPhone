//
//  TempoRegulator.m
//  gTar
//
//  Created by Marty Greenia on 2/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "TempoRegulator.h"


@implementation TempoRegulator

- (id)initWithTempo:(NSInteger)tempo
{
    self = [super init];
    
	if ( self )
	{
	
//		if ( tempo > TEMPO_REGULATOR_SCHEDULE_COUNT - 1 )
//		{
//			tempo = TEMPO_REGULATOR_SCHEDULE_COUNT - 1;
//		}
//		
//		if ( tempo < 0 )
//		{
//			tempo = 0;
//		}
		
		//m_currentTempoIndex = tempo;
		m_currentTempoScaler = 0.125f;
		
	}
	
	return self;
	
}

//- (NSInteger)currentTempo
//{
//	return g_tempoSchedule[ m_currentTempoIndex ];
//}


- (double)currentTempoTimeScaler
{
	//return g_tempoScalerSchedule[ m_currentTempoIndex ];
	return m_currentTempoScaler;
}

/*
- (void)playCorrectNote
{
	m_correctNotes++;
	m_totalNotes++;

	m_correctNotesInSeries++;
	m_incorrectNotesInSeries = 0;

	[self evaluateCurrentTempo];
}

- (void)playCorrectNoteCount:(NSInteger)count
{
	m_correctNotes += count;
	m_totalNotes += count;

	m_correctNotesInSeries += count;
	m_incorrectNotesInSeries = 0;

	[self evaluateCurrentTempo];	
}

- (void)playIncorrectNote
{
	m_totalNotes++;
	
	m_incorrectNotesInSeries++;
	m_correctNotesInSeries = 0;
	
	[self evaluateCurrentTempo];
}

- (void)playIncorrectNoteCount:(NSInteger)count
{
	m_totalNotes += count;

	m_incorrectNotesInSeries += count;
	m_correctNotesInSeries = 0;

	[self evaluateCurrentTempo];
}

- (void)evaluateCurrentTempo
{
	
	// long term changes
	if ( m_totalNotes >= TEMPO_REGULATOR_LONGTERM_TIME )
	{
		double percentCorrect = ((double)m_correctNotes / (double)m_totalNotes);
	
		if ( percentCorrect <= TEMPO_REGULATOR_LONGTERM_LOW_WATERMARK )
		{
			[self decreaseTempo];
		}

		if ( percentCorrect >= TEMPO_REGULATOR_LONGTERM_HIGH_WATERMARK )
		{
			[self increaseTempo];
		}
	}
	
	// short term changes
	if ( m_totalNotes >= TEMPO_REGULATOR_SHORTTERM_TIME )
	{
		double percentCorrect = ((double)m_correctNotesInSeries / (double)TEMPO_REGULATOR_SHORTTERM_TIME);
		double percentIncorrect = ((double)m_incorrectNotesInSeries / (double)TEMPO_REGULATOR_SHORTTERM_TIME);

		// if all wrong
		if ( (1.0 - percentIncorrect) <= TEMPO_REGULATOR_LONGTERM_LOW_WATERMARK )
		{
			[self decreaseTempo];
		}
		
		// if all right
		if ( percentCorrect >= TEMPO_REGULATOR_LONGTERM_HIGH_WATERMARK )
		{
			[self increaseTempo];
		}
		
	}

}

- (void)increaseTempo
{

	// don't overflow
	if ( m_currentTempoIndex < TEMPO_REGULATOR_SCHEDULE_COUNT - 1 )
	{
		m_currentTempoIndex++;
		
		m_totalNotes = 0;
		m_correctNotes = 0;
		
		m_correctNotesInSeries = 0;
		m_incorrectNotesInSeries = 0;
	}
	
}

- (void)decreaseTempo
{

	// don't underflow
	if ( m_currentTempoIndex > 0 )
	{
		m_currentTempoIndex--;

		m_totalNotes = 0;
		m_correctNotes = 0;

		m_correctNotesInSeries = 0;
		m_incorrectNotesInSeries = 0;
	}
	
}
*/

- (void)increaseTempo
{
	m_currentTempoScaler += 0.05f;
	
	if ( m_currentTempoScaler > 1.0f )
	{
		m_currentTempoScaler = 1.0f;
	}
}

- (void)decreaseTempo
{
	m_currentTempoScaler -= 0.05f;
	
	if ( m_currentTempoScaler < 0.125f )
	{
		m_currentTempoScaler = 0.125f;
	}
}

@end
