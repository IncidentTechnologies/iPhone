//
//  LcdDigitView.m
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "LcdDigitView.h"


@implementation LcdDigitView

@synthesize m_digitUpperLeft, m_digitTop, m_digitUpperRight, m_digitMiddle, m_digitLowerLeft, m_digitLowerRight, m_digitBottom;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)setDigitValue:(NSInteger)value
{

	m_value = value;
	m_isOff = NO;
	
	switch ( value )
	{
		case 0: 
		{
			//  _
			// | |
			// |_|
			//
			[m_digitUpperLeft setHidden:NO];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:YES];
			[m_digitLowerLeft setHidden:NO];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:NO];
			
		} break;

		case 1: 
		{
			//   
			//   |
			//   |
			//
			[m_digitUpperLeft setHidden:YES];
			[m_digitTop setHidden:YES];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:YES];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:YES];
		} break;

		case 2: 
		{
			//  _
			//  _|
			// |_ 
			//
			[m_digitUpperLeft setHidden:YES];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:NO];
			[m_digitLowerRight setHidden:YES];
			[m_digitBottom setHidden:NO];
		} break;

		case 3: 
		{
			//  _
			//  _|
			//  _|
			//
			[m_digitUpperLeft setHidden:YES];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:NO];
		} break;

		case 4: 
		{
			//  
			// |_|
			//   |
			//
			[m_digitUpperLeft setHidden:NO];
			[m_digitTop setHidden:YES];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:YES];
		} break;

		case 5: 
		{
			//  _
			// |_ 
			//  _|
			//
			[m_digitUpperLeft setHidden:NO];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:YES];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:NO];
		} break;

		case 6: 
		{
			//  _
			// |_ 
			// |_|
			//
			[m_digitUpperLeft setHidden:NO];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:YES];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:NO];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:NO];
		} break;

		case 7: 
		{
			//  _
			//   |
			//   |
			//
			[m_digitUpperLeft setHidden:YES];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:YES];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:YES];
		} break;

		case 8: 
		{
			//  _
			// |_|
			// |_|
			//
			[m_digitUpperLeft setHidden:NO];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:NO];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:NO];
		} break;

		case 9: 
		{
			//  _
			// |_|
			//  _|
			//
			[m_digitUpperLeft setHidden:NO];
			[m_digitTop setHidden:NO];
			[m_digitUpperRight setHidden:NO];
			[m_digitMiddle setHidden:NO];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:NO];
			[m_digitBottom setHidden:NO];
		} break;
			
		default:
		{
			//
			// Anything else is invalid/off
			//
			m_isOff = YES;
			
			[m_digitUpperLeft setHidden:YES];
			[m_digitTop setHidden:YES];
			[m_digitUpperRight setHidden:YES];
			[m_digitMiddle setHidden:YES];
			[m_digitLowerLeft setHidden:YES];
			[m_digitLowerRight setHidden:YES];
			[m_digitBottom setHidden:YES];
		} break;
	}
}

- (void)clearDigit
{
	[self setDigitValue:-1];
}


@end
