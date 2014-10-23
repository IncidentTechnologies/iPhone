//
//  JamPad.h
//  gTar
//
//  Created by Marty Greenia on 2/16/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYInputView.h"

#define JAM_PAD_WIDTH 10
#define JAM_PAD_HEIGHT 9

@interface JamPad : XYInputView
{	
	CGPoint m_currentDiscretizedPosition;
	UIView * m_ledOnGrid[JAM_PAD_HEIGHT][JAM_PAD_WIDTH];
	UIView * m_ledOffGrid[JAM_PAD_HEIGHT][JAM_PAD_WIDTH];
	
	UIImage * m_ledOn;
	UIImage * m_ledOff;
	
	char m_ledRefCount[JAM_PAD_HEIGHT][JAM_PAD_WIDTH];
}

@property (nonatomic, readonly) CGPoint m_currentDiscretizedPosition;

- (void)setupJamPadWithRows:(NSInteger)rows andColumns:(NSInteger)columns;

- (void)turnOffLedWidth:(NSInteger)width andHeight:(NSInteger)height;
- (void)turnOnLedWidth:(NSInteger)width andHeight:(NSInteger)height;
- (void)changeHalo:(BOOL)on atPosition:(CGPoint)position;
//- (void)clearHaloAtPosition:(CGPoint)position;
//- (void)moveHaloFromPosition:(CGPoint)position;

@end
