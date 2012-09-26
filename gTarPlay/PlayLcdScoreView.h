//
//  PlayLcdScoreView.h
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LcdView.h"

#define LCD_MAX_SCORE 9999999
#define LCD_MAX_DIGITS 7

@interface PlayLcdScoreView : LcdView
{

	LcdDigitView * m_digitsArray[LCD_MAX_DIGITS];
	
	IBOutlet LcdDigitView * m_digit0;
	IBOutlet LcdDigitView * m_digit1;
	IBOutlet LcdDigitView * m_digit2;
	IBOutlet LcdDigitView * m_digit3;
	IBOutlet LcdDigitView * m_digit4;
	IBOutlet LcdDigitView * m_digit5;
	IBOutlet LcdDigitView * m_digit6;
	
}

@property (nonatomic, retain) LcdDigitView * m_digit0;
@property (nonatomic, retain) LcdDigitView * m_digit1;
@property (nonatomic, retain) LcdDigitView * m_digit2;
@property (nonatomic, retain) LcdDigitView * m_digit3;
@property (nonatomic, retain) LcdDigitView * m_digit4;
@property (nonatomic, retain) LcdDigitView * m_digit5;
@property (nonatomic, retain) LcdDigitView * m_digit6;

- (void)makeDigitArray;

@end
