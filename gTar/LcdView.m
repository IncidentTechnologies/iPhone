//
//  LcdView.m
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "LcdView.h"

@implementation LcdView

/*
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		[self makeDigitArray];
		[self clearDigits];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		// init
		[self makeDigitArray];
		[self clearDigits];
	}
	return self;
}

- (id)init
{
	if ((self = [super init]))
	{
		// init
		[self makeDigitArray];
		[self clearDigits];
	}
	return self;
}
*/
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)initDigits
{
	// Initialization code
	// Ideally this would run in the init method but 
	// the child digits don't exist yet when loaded from
	// a nib file.
	[self makeDigitArray];
	[self clearDigits];
}

- (void)dealloc
{
    [super dealloc];
}


- (void)setDigitsValue:(NSInteger)value
{
	
	if ( value > m_valueMax )
	{
		value = m_valueMax;
	}
	if ( value < 0 )
	{
		value = 0;
	}
				
	
	[self clearDigits];
	
	// set the first digit to zero if it is zero
	if ( value == 0 )
	{
		LcdDigitView * lcdDigit = m_digits[0];
		
		[lcdDigit setDigitValue:0];

		return;
	}
	
	NSInteger digitNum = 0;
	
	while ( value > 0 )
	{
		NSInteger digit = value % 10;
		value = value / 10;
		
		LcdDigitView * lcdDigit = m_digits[digitNum++];
		
		[lcdDigit setDigitValue:digit];
	}
}

// 'pure virtual'
- (void)makeDigitArray
{

}

- (void)clearDigits
{
	
	for ( unsigned int i = 0; i < m_digitsMax; i++ )
	{
		LcdDigitView * lcdDigit = m_digits[i];
		
		[lcdDigit clearDigit];
	}
	
}
@end
