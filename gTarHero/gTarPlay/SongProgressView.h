//
//  SongProgessView.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/10/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SongProgressView : UIView
{
    
	NSArray * m_noteArray;
	NSArray * m_measureArray;
    
	CGFloat m_currentBeat;
	CGFloat m_windowStart;
	CGFloat m_windowSize;
    
}

@property (nonatomic) CGFloat m_currentBeat;

- (void)setNoteArray:(NSArray*)noteArray;
- (void)setMeasureArray:(NSArray*)measureArray;
- (CGFloat)convertToStringCoords:(char)str;
- (CGFloat)convertToBeatCoords:(CGFloat)beat;
- (CGFloat)convertToBeatCoordsScaled:(CGFloat)beat;

@end
