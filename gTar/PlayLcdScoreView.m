//
//  PlayLcdScoreView.m
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "PlayLcdScoreView.h"


@implementation PlayLcdScoreView

@synthesize m_digit0, m_digit1, m_digit2, m_digit3, m_digit4, m_digit5, m_digit6;

- (void)makeDigitArray
{
	m_digitsMax = MAX_DIGITS;
	m_valueMax = MAX_SCORE;
	
	m_digitsArray[0] = m_digit0;
	m_digitsArray[1] = m_digit1;
	m_digitsArray[2] = m_digit2;
	m_digitsArray[3] = m_digit3;
	m_digitsArray[4] = m_digit4;
	m_digitsArray[5] = m_digit5;
	m_digitsArray[6] = m_digit6;

	m_digits = m_digitsArray;
}

@end
