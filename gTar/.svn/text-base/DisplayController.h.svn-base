//
//  DisplayController.h
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EAGLView.h"

#import "ViewRenderer.h"
#import "ESRenderer.h"
#import "ES1Renderer.h"
#import "CGRenderer.h"

#import "ES1PlayObject.h"
#import "ES1LearnObject.h"
#import "ES1SaysObject.h"
//#import "CGSaysObject.h"

enum DisplayControllerMode
{
	DisplayControllerModePlay,
	DisplayControllerModeLearn,
	DisplayControllerModeSays
};

@interface DisplayController : NSObject
{

	EAGLView * m_glView;
	
	ESRenderer * m_esRenderer;
	CGRenderer * m_cgRenderer;
	
	ES1PlayObject * m_playObject;
	ES1LearnObject * m_learnObject;
	ES1SaysObject * m_saysObject;
	//CGSaysObject * m_saysObject;
	
}

@property (nonatomic, readonly) ES1PlayObject * m_playObject;
@property (nonatomic, readonly) ES1LearnObject * m_learnObject;
@property (nonatomic, readonly) ES1SaysObject * m_saysObject;
//@property (nonatomic, readonly) CGSaysObject * m_saysObject;

-(DisplayController*)initWithView:(EAGLView*)glView;

-(void)changeDisplayMode:(DisplayControllerMode)mode;
-(void)drawView;
-(void)createPlayObjectWithStringCount:(unsigned int)stringCount notes:(NoteArray*)noteArray andMeasures:(MeasureArray*)measureArray;
-(void)createLearnObject;
-(void)createSaysObject;
@end
