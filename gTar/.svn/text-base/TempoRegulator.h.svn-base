//
//  TempoRegulator.h
//  gTar
//
//  Created by Marty Greenia on 2/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TEMPO_REGULATOR_LONGTERM_HIGH_WATERMARK 0.75f
#define TEMPO_REGULATOR_LONGTERM_LOW_WATERMARK 0.25f

#define TEMPO_REGULATOR_SHORTTERM_HIGH_WATERMARK 0.95f
#define TEMPO_REGULATOR_SHORTTERM_LOW_WATERMARK 0.05f

#define TEMPO_REGULATOR_LONGTERM_TIME 6
#define TEMPO_REGULATOR_SHORTTERM_TIME 4

#define TEMPO_REGULATOR_SCHEDULE_COUNT 6

//unsigned int g_tempoSchedule[] = { 15, 30, 45, 60, 90, 120 };
//static double g_tempoScalerSchedule[] = { 0.125, 0.25, 0.375, 0.50, 0.75, 1.0 };

@interface TempoRegulator : NSObject
{

//	double m_watermarkHigh;
//	double m_watermarkLow;

	double m_currentTempoScaler;
	
	NSInteger m_currentTempoIndex;

	NSInteger m_totalNotes;
	NSInteger m_correctNotes;
	
	NSInteger m_correctNotesInSeries;
	NSInteger m_incorrectNotesInSeries;
	
}

- (id)initWithTempo:(NSInteger)tempo;

//- (NSInteger)currentTempo;
- (double)currentTempoTimeScaler;

/*
- (void)playCorrectNote;
- (void)playCorrectNoteCount:(NSInteger)count;
- (void)playIncorrectNote;
- (void)playIncorrectNoteCount:(NSInteger)count;
- (void)evaluateCurrentTempo;
- (void)increaseTempo;
- (void)decreaseTempo;
- (double)calculatePercentCorrect;
*/

- (void)increaseTempo;
- (void)decreaseTempo;
@end
