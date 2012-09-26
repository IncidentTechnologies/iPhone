//
//  NoteModel.h
//  gTar
//
//  Created by wuda on 12/21/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Texture2D.h"
#import "Model.h"

@interface NoteModel : Model
{

	// phase this stuff out
	GLfloat m_startX;
	GLfloat m_startY;

	GLfloat m_endX;
	GLfloat m_endY;
	
	GLfloat m_middleX;
	GLfloat m_middleY;
	
	Texture2D * m_start; // left cap, or standalone note
	Texture2D * m_end; // right cap
	Texture2D * m_middle;
	// phase this stuff out

	Texture2D * m_overlay;

}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andOverlay:(Texture2D*)overlay;

- (NoteModel*)initDurationWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height;
- (NoteModel*)initSpotWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height;
- (NoteModel*)initWidthWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height;

- (void)dealloc;
- (void)releaseCachedImages;
- (void)createImagesWithHeight:(GLfloat)height;

@end
