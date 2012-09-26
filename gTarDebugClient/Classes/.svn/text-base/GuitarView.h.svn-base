//
//  GuitarView.h
//  gTarDebugClient
//
//  Created by wuda on 10/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gTarDebug.h"
#import "AudioController.h"

#define GUITAR_VIEW_FRET_SPACING (420.0 / 13.0f)
#define GUITAR_VIEW_STRING_SPACING (320.0 / 6.0f)

@interface GuitarView : UIView <gTarDebugClient, gTarDebugServer>
{
	GuitarInput m_ginput;
	GuitarOutput m_goutput;
	gTarDebug * m_debugger;
	
	IBOutlet UILabel * m_connectionStatus;
	
	AudioController * m_audioController;
	
}

@property (nonatomic) GuitarInput m_ginput;
@property (nonatomic) GuitarOutput m_goutput;
@property (nonatomic, retain) gTarDebug * m_debugger;
@property (nonatomic, retain) IBOutlet UILabel * m_connectionStatus;


- (void)drawCircleAt:(CGPoint)point withColor:(CGFloat[])color;
- (void)drawRect:(CGRect)rect;

- (int)findClosestIndexToPoint:(CGPoint)point;
- (int)stringFromIndex:(int)index;
- (int)fretFromIndex:(int)index;
- (int)indexFromString:(int)str andFret:(int)fret;

- (void)stateChanged;
- (void)serverStateChanged;
- (void)clientStateChanged;

- (IBAction)pluckButtonClicked;


@end
