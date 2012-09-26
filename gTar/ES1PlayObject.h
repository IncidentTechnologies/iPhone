//
//  ES1PlayRenderer.h
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRenderer.h"
#import "ESObject.h"
#import "NoteModel.h"

// These are from the OpenGL documentation at www.opengl.org
#define X .525731112119133606 
#define Z .850650808352039932

static GLfloat vdata[12][3] = 
{    
	{-X, 0.0f, Z}, 
	{0.0f, Z, X}, 
	{X, 0.0f, Z}, 
	{-Z, X, 0.0f}, 	
	{0.0f, Z, -X}, 
	{Z, X, 0.0f}, 
	{Z, -X, 0.0f}, 
	{X, 0.0f, -Z},
	{-X, 0.0f, -Z},
	{0.0f, -Z, -X},
    {0.0f, -Z, X},
	{-Z, -X, 0.0f} 
};

static GLushort tindices[20][3] = 
{ 
	{0,1,2},
	{0,3,1},
	{3,4,1},
	{1,4,5},
	{1,5,2},    
	{5,6,2},
	{5,7,6},
	{4,7,5},
	{4,8,7},
	{8,9,7},    
	{9,6,7},
	{9,10,6},
	{9,11,10},
	{11,0,10},
	{0,2,10}, 
	{10,2,6},
	{3,0,11},
	{3,11,8},
	{3,8,4},
	{9,8,11} 
};

#define PLAY_OBJECT_VERTICES_PER_NOTE 12
#define PLAY_OBJECT_TRIANGLES_PER_NOTE 20
#define PLAY_OBJECT_NOTE_RADIUS 30.0f

#define PLAY_OBJECT_BEATS_PER_SCREEN 4
#define PLAY_OBJECT_PIXELS_PER_BEAT (GL_SCREEN_WIDTH / PLAY_OBJECT_BEATS_PER_SCREEN)

#define PLAY_OBJECT_COUNTDOWN 4

@interface ES1PlayObject : ESObject
{
	// ortho view state
	GLfloat m_currentBeat;
	GLfloat m_currentPosition;
	
	// Song model related members 
	GLfloat m_seekVertices[4];
	GLubyte m_seekColors[8];
	
	GLfloat * m_stringVertices;
	GLubyte * m_stringColors;
	GLuint m_stringCount;
	
	GLfloat * m_noteVertices;
	GLubyte * m_noteColors;
	GLushort * m_noteIndices;
	GLuint m_noteCount;
	
	GLfloat * m_measureVertices;
	GLubyte * m_measureColors;
	GLuint m_measureCount;
	
	// Modifiers
	NoteArrayRange m_targetNotes;
	
	// Texture / text
	Texture2D * m_textDigits[20];
	char * m_digitsValues;
	GLfloat * m_digitsVertices;
	
	Texture2D * m_backgroundFrame;
	Texture2D * m_seekLineTexture;
	Texture2D * m_stringTextures[ GTAR_GUITAR_STRING_COUNT ];
	Texture2D * m_countdownTextures[ PLAY_OBJECT_COUNTDOWN ];
	
	NSUInteger m_countdownTextureIndex;

	// Note Model array
	NSMutableArray * m_noteModels;
	
}

// Time functions
- (void) setCurrentBeat:(GLfloat)beat;
- (void) incrementCurrentBeat:(GLfloat)beatDelta;

// Model functions
- (void) initSeekLine;

- (void) convertStrings:(unsigned int)str;

- (void) convertNoteArray:(NoteArray*)noteArray;
- (void) convertMeasureArray:(MeasureArray*)measureArray;

- (GLfloat) convertBeatToCoordSpace:(CGFloat)beat;
- (GLfloat) convertStringToCoordSpace:(NSInteger)str;

// External input functions
- (void) setTargetNotes:(NoteArrayRange)arrayRange;

- (void)countdownOn:(NSInteger)count;
- (void)countdownOff;

@end
