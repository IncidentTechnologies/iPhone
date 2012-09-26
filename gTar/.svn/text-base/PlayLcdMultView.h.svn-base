//
//  PlayLcdScoreMultView.h
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LcdView.h"


#define MAX_SCORE 9
#define MAX_DIGITS 1

@interface PlayLcdMultView : LcdView
{
	LcdDigitView * m_digitsArray[MAX_DIGITS];
	
	IBOutlet LcdDigitView * m_digit0;
	//	IBOutlet LcdDigitView * m_digit1;
	IBOutlet LcdDigitView * m_digitDummy;
	
}

@property (nonatomic, retain) LcdDigitView * m_digit0;
//@property (nonatomic, retain) LcdDigitView * m_digit1;
@property (nonatomic, retain) LcdDigitView * m_digitDummy;

- (void)makeDigitArray;

@end
