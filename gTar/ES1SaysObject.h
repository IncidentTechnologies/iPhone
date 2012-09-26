//
//  ES1SaysObject.h
//  gTar
//
//  Created by wuda on 12/6/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Texture2D.h"
#import "ESRenderer.h"
#import "ESObject.h"
#import "NoteModel.h"

#define SAYS_NOTE_LIFE_FRAMES 30
#define g_fretBuffer ((GLfloat)(GL_SCREEN_WIDTH / 16.0))
#define g_fretSpacingBase ((GLfloat)(GL_SCREEN_WIDTH / 8.0))
//#define GL_FRET_SPACING_BASE 
static GLfloat g_fretSpacingMultiplier[16] = { 0.0, 2.0, 1.8, 1.6, 1.6, 1.4, 1.4, 1.2, 1.2, 1.1, 1.1, 1.1, 1.0, 1.0, 1.0, 1.0 }; 
static GLfloat g_fretCoords[16];

@interface ES1SaysObject : ESObject
{

//	GLfloat * m_stringVertices;
//	GLubyte * m_stringColors;
//	GLuint m_stringCount;
	
	//GLuint m_fretCount;
	
	// Texture / text
	Texture2D * m_fretDigits[6]; // 1 3 5 7 9 12 15 17
	CGPoint m_fretDigitsCoords[6];
	
	Texture2D * m_textDigits[20];
	char * m_digitsValues;
	GLfloat * m_digitsVertices;
	
	Texture2D * m_backgroundFrame;
	Texture2D * m_stringTextures[ GTAR_GUITAR_STRING_COUNT ];
	Texture2D * m_fretTextures[ GTAR_GUITAR_FRET_COUNT ];
	Texture2D * m_noteTextures[ GTAR_GUITAR_FRET_COUNT * GTAR_GUITAR_STRING_COUNT ];

	char m_noteFramesVisible[ GTAR_GUITAR_FRET_COUNT * GTAR_GUITAR_STRING_COUNT ];
	
	GLfloat m_focusWindowLeftTarget;
	GLfloat m_focusWindowRightTarget;
	GLfloat m_focusWindowLeft;
	GLfloat m_focusWindowRight;
	GLfloat m_focusLeftStep;
	GLfloat m_focusRightStep;
	GLfloat	m_focusTranslation;
	
	NSInteger m_focusFretLeft;
//	NSInteger m_focusFretLeftTarget;
	NSInteger m_focusFretRight;
//	NSInteger m_focusFretRightTarget;
	
	NSMutableArray * m_noteModels;
	
}

- (void)initStrings;
- (void)initFrets;
- (void)initNotes;
- (void)initTextures;
- (NSInteger)convertToIndexString:(NSInteger)str andFret:(NSInteger)fret;
- (GLfloat)convertStringToCoordSpace:(NSInteger)str;
- (GLfloat)convertFretToCoordSpace:(NSInteger)fret;

- (void)playNoteString:(NSInteger)str andFret:(NSInteger)fret;
- (void)playNoteString:(NSInteger)str andFret:(NSInteger)fret forFrames:(NSInteger)frames;

- (void)focusReset;
- (void)focusAddString:(NSInteger)str andFret:(NSInteger)fret;
@end
