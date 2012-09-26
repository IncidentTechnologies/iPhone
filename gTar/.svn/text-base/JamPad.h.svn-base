//
//  JamPad.h
//  gTar
//
//  Created by Marty Greenia on 2/16/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYInputView.h"

#define JAM_PAD_WIDTH 8
#define JAM_PAD_HEIGHT 8

@class JamPad;

@protocol JamPadDelegate
-(void)jamPad:(JamPad*)jamPad positionChanged:(CGPoint)position;
@end

@interface JamPad : XYInputView
{
	id<JamPadDelegate> m_delegate;
	
	CGPoint m_currentDiscretizedPosition;
	UIImageView * m_ledOnGrid[JAM_PAD_HEIGHT][JAM_PAD_WIDTH];
	UIImageView * m_ledOffGrid[JAM_PAD_HEIGHT][JAM_PAD_WIDTH];
	
	UIImage * m_ledOn;
	UIImage * m_ledOff;
	
	char m_ledRefCount[JAM_PAD_HEIGHT][JAM_PAD_WIDTH];
}

@property (nonatomic, retain) id<JamPadDelegate> m_delegate;
@property (nonatomic, readonly) CGPoint m_currentDiscretizedPosition;

- (void)initJamPad;

- (void)turnOffLedWidth:(NSInteger)width andHeight:(NSInteger)height;
- (void)turnOnLedWidth:(NSInteger)width andHeight:(NSInteger)height;
- (void)changeHalo:(BOOL)on atPosition:(CGPoint)position;
- (void)clearHaloAtPosition:(CGPoint)position;
- (void)moveHaloFromPosition:(CGPoint)position;

@end
