//
//  LcdView.h
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LcdDigitView.h"

// 'pure virtual'
@interface LcdView : UIView
{
	LcdDigitView ** m_digits;
	NSInteger m_digitsMax;
	NSInteger m_valueMax;
}

- (void)initDigits;
- (void)setDigitsValue:(NSInteger)value;
- (void)makeDigitArray;
- (void)clearDigits;

@end
