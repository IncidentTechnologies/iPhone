//
//  PlayControllerProgressView.h
//  gTar
//
//  Created by wuda on 1/17/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <gTarAppCore/AppCore.h>

#import "gTarColors.h"

@interface PlayControllerProgressView : UIView
{
    NSMutableArray * m_noteArray;
	NSMutableArray * m_measureArray;
	CGFloat m_currentBeat;
	CGFloat m_windowStart;
	CGFloat m_windowSize;
}

@property (nonatomic) CGFloat m_currentBeat;

//- (void)setNoteArray:(NoteArray*)noteArray;
//- (void)setMeasureArray:(MeasureArray*)measureArray;
- (CGFloat)convertToStringCoords:(char)str;
- (CGFloat)convertToBeatCoords:(CGFloat)beat;
- (CGFloat)convertToBeatCoordsScaled:(CGFloat)beat;

@end
