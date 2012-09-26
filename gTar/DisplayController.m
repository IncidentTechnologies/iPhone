//
//  DisplayController.m
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "DisplayController.h"


@implementation DisplayController

@synthesize m_playObject;
@synthesize m_learnObject;
@synthesize m_saysObject;


-(DisplayController*)initWithView:(EAGLView*)glView
{
	
	if ( self = [super init] )
	{
		m_glView = glView;
		//m_renderer = glView.m_renderer;
		
		m_cgRenderer = [[CGRenderer alloc] init];
		[m_cgRenderer resizeFromLayer:(CAEAGLLayer*)glView.layer];
		
		m_esRenderer = [[ES1Renderer alloc] init];
		[m_esRenderer resizeFromLayer:(CAEAGLLayer*)glView.layer];
	}
	
	return self;
	
}

- (void)dealloc
{
	[m_esRenderer release];
	[m_cgRenderer release];
	
	[m_playObject release];
	[m_learnObject release];
	[m_saysObject release];
}

-(void)changeDisplayMode:(DisplayControllerMode)mode
{
	
	switch ( mode )
	{
		case DisplayControllerModePlay:
		{
			
			[m_esRenderer setRenderObject:m_playObject];
			m_glView.m_renderer = m_esRenderer;
			
		} break;
			
		case DisplayControllerModeLearn:
		{
			
			[m_esRenderer setRenderObject:m_learnObject];
			m_glView.m_renderer = m_esRenderer;
			
		} break;
			
		case DisplayControllerModeSays:
		{
			
			[m_esRenderer setRenderObject:m_saysObject];
			m_glView.m_renderer = m_esRenderer;
			//[m_cgRenderer setRenderObject:m_saysObject];
			//m_glView.m_renderer = m_cgRenderer;

		} break;
			
		default:
		{
			
		} break;
	}
	
}

-(void)drawView
{
	
	//[m_renderer renderFromObject];
	[m_glView drawView];

}

-(void)createPlayObjectWithStringCount:(unsigned int)stringCount notes:(NoteArray*)noteArray andMeasures:(MeasureArray*)measureArray
{
	
	m_playObject = [[ES1PlayObject alloc] initWithBackingWidth:m_esRenderer.m_backingWidth andHeight:m_esRenderer.m_backingHeight];
	
	// TODO
	// These could / should just be combined somewhere
	[m_playObject initTextures];
	[m_playObject initSeekLine];
	
	[m_playObject convertStrings:stringCount];
	
	[m_playObject convertNoteArray:noteArray];
	
	[m_playObject convertMeasureArray:measureArray];
	
}

-(void)createLearnObject
{
	
	m_learnObject = [[ES1LearnObject alloc] initWithBackingWidth:m_esRenderer.m_backingWidth andHeight:m_esRenderer.m_backingHeight];
	
	[m_learnObject createGuitar];
	
}

-(void)createSaysObject
{
	
	m_saysObject = [[ES1SaysObject alloc] initWithBackingWidth:m_esRenderer.m_backingWidth andHeight:m_esRenderer.m_backingHeight];


	[m_saysObject initFrets];
	
	[m_saysObject initStrings];
	
	[m_saysObject initTextures];
	
	[m_saysObject initNotes];

	//m_saysObject = [[CGSaysObject alloc] init];
	
}
@end
