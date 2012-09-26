//
//  ES1LearnObject.h
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRenderer.h"
#import "ESObject.h"

#import "Texture2D.h"


#define LEARN_OBJECT_GUITAR_WIDTH (0.3 * GL_SCREEN_WIDTH)
#define LEARN_OBJECT_GUITAR_HEIGHT (1.6 * GL_SCREEN_HEIGHT)

#define LEARN_OBJECT_STRING_SPACING (0.05 * GL_SCREEN_WIDTH)
#define LEARN_OBJECT_FRET_HEIGHT (0.8 * GL_SCREEN_HEIGHT)


@interface ES1LearnObject : ESObject
{

	GLfloat * m_guitarVertices;
	GLubyte * m_guitarColors;
	GLushort * m_guitarIndices;
	GLuint m_guitarCount;

	GLfloat * m_stringVertices;
	GLubyte * m_stringColors;
	GLuint m_stringCount;
	
	GLfloat m_noteVertices[ GTAR_GUITAR_FRET_COUNT * GTAR_GUITAR_STRING_COUNT * 3 ];
	GLubyte m_noteColors[ GTAR_GUITAR_FRET_COUNT * GTAR_GUITAR_STRING_COUNT * 4 ];
	GLubyte m_noteIndices[ GTAR_GUITAR_FRET_COUNT * GTAR_GUITAR_STRING_COUNT ];
	GLuint m_noteCount;
	
	// Notes for highlighting
	char m_targetNotes[ GTAR_GUITAR_STRING_COUNT ];
	unsigned int m_targetNotesCount;
	
	Texture2D * m_texture;
	
}

- (void) createGuitar;
- (GLfloat) getPointForString:(NSInteger)str;
- (GLfloat) getPointForFret:(NSInteger)fret;
- (GLubyte) getIndexForString:(NSInteger)str andFret:(NSInteger)fret;

- (void) setTargetNotes:(char*)notes;
- (void) getTargetNotes:(char*)output;


@end
