//
//  PlayLcdScoreMultView.m
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "PlayLcdMultView.h"


@implementation PlayLcdMultView

@synthesize m_digit0;
//@synthesize m_digit1;
@synthesize m_digitDummy;

- (void)makeDigitArray
{
	m_digitsMax = PLAY_LCD_MAX_DIGITS;
	m_valueMax = PLAY_LCD_MAX_SCORE;
	
	m_digitsArray[0] = m_digit0;
//	m_digitsArray[1] = m_digit1;
	
	m_digits = m_digitsArray;
	
	[m_digitDummy clearDigit];
}

@end
