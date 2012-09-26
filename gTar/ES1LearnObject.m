//
//  ES1LearnObject.m
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "ES1LearnObject.h"

@implementation ES1LearnObject


#pragma mark -
#pragma mark External input functions

- (void) setTargetNotes:(char*)notes
{
	
	m_targetNotesCount = 0;
	
	memcpy( m_targetNotes, notes, GTAR_GUITAR_STRING_COUNT );
	
	for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		
		if ( m_targetNotes[ str ] != GTAR_GUITAR_NOTE_OFF )
		{
			m_noteIndices[ m_targetNotesCount++ ] = [self getIndexForString:str andFret:m_targetNotes[str] ];
		}
	
	}
	
}

- (void) getTargetNotes:(char*)output
{

	memcpy( output, m_targetNotes, GTAR_GUITAR_STRING_COUNT);
		
}

#pragma mark -
#pragma mark OpenGL


- (void) createGuitar
{
	//NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BackButton" ofType:@"png"];

	//UIImage * testImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	//m_texture = [[Texture2D alloc] initWithString:@"oooo" dimensions:CGSizeMake(128, 64) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:58.0f];
	//testText = [[Texture2D alloc] initWithImage:testImage];
	
	GLfloat guitarWidth = LEARN_OBJECT_GUITAR_WIDTH;
	GLfloat guitarHeight = LEARN_OBJECT_GUITAR_HEIGHT;
	GLfloat stringSpacing = LEARN_OBJECT_STRING_SPACING;
	
	m_targetNotesCount = 0;
	
	m_guitarVertices = new GLfloat[ 4 * 3 ];
	m_guitarColors = new GLubyte[ 4 * 4 ];
	m_guitarCount = 2;
	m_guitarIndices = new GLushort( 3 * m_guitarCount );
	
	// Guitar body
	m_guitarVertices[0] = guitarWidth/2;
	m_guitarVertices[1] = guitarHeight/2;
	m_guitarVertices[2] = 0.2f;

	m_guitarVertices[3] = guitarWidth/2;
	m_guitarVertices[4] = -guitarHeight/2;
	m_guitarVertices[5] = 0.2f;

	m_guitarVertices[6] = -guitarWidth/2;
	m_guitarVertices[7] = guitarHeight/2;
	m_guitarVertices[8] = 0.2f;
	
	m_guitarVertices[9] = -guitarWidth/2;
	m_guitarVertices[10] = -guitarHeight/2;
	m_guitarVertices[11] = 0.2f;
	
	m_guitarColors[0] = 139;
	m_guitarColors[1] = 69;
	m_guitarColors[2] = 19;
	m_guitarColors[3] = 255;
	
	m_guitarColors[4] = 139;
	m_guitarColors[5] = 69;
	m_guitarColors[6] = 19;
	m_guitarColors[7] = 255;
	
	m_guitarColors[8] = 139;
	m_guitarColors[9] = 69;
	m_guitarColors[10] = 19;
	m_guitarColors[11] = 255;
	
	m_guitarColors[12] = 139;
	m_guitarColors[13] = 69;
	m_guitarColors[14] = 19;
	m_guitarColors[15] = 255;
	
	m_guitarIndices[0] = 0;
	m_guitarIndices[1] = 1;
	m_guitarIndices[2] = 2;

	m_guitarIndices[3] = 1;
	m_guitarIndices[4] = 2;
	m_guitarIndices[5] = 3;
	
	// Strings
	m_stringCount = 6;	
	m_stringVertices = new GLfloat[ m_stringCount * 3 * 2 ];
	m_stringColors = new GLubyte[ m_stringCount * 4 * 2 ];

	m_stringVertices[0] = stringSpacing/2 * 1;
	m_stringVertices[1] = guitarHeight/2;
	m_stringVertices[2] = 0.25f;
	m_stringVertices[3] = stringSpacing/2 * 1;
	m_stringVertices[4] = -guitarHeight/2;
	m_stringVertices[5] = 0.25f;
	
	m_stringVertices[6] = stringSpacing/2 * 3;
	m_stringVertices[7] = guitarHeight/2;
	m_stringVertices[8] = 0.25f;
	m_stringVertices[9] = stringSpacing/2 * 3;
	m_stringVertices[10] = -guitarHeight/2;
	m_stringVertices[11] = 0.25f;
	
	m_stringVertices[12] = stringSpacing/2 * 5;
	m_stringVertices[13] = guitarHeight/2;
	m_stringVertices[14] = 0.25f;
	m_stringVertices[15] = stringSpacing/2 * 5;
	m_stringVertices[16] = -guitarHeight/2;
	m_stringVertices[17] = 0.25f;
	

	m_stringVertices[18] = -stringSpacing/2 * 1;
	m_stringVertices[19] = guitarHeight/2;
	m_stringVertices[20] = 0.25f;
	m_stringVertices[21] = -stringSpacing/2 * 1;
	m_stringVertices[22] = -guitarHeight/2;
	m_stringVertices[23] = 0.25f;
	
	m_stringVertices[24] = -stringSpacing/2 * 3;
	m_stringVertices[25] = guitarHeight/2;
	m_stringVertices[26] = 0.25f;
	m_stringVertices[27] = -stringSpacing/2 * 3;
	m_stringVertices[28] = -guitarHeight/2;
	m_stringVertices[29] = 0.25f;
	
	m_stringVertices[30] = -stringSpacing/2 * 5;
	m_stringVertices[31] = guitarHeight/2;
	m_stringVertices[32] = 0.25f;
	m_stringVertices[33] = -stringSpacing/2 * 5;
	m_stringVertices[34] = -guitarHeight/2;
	m_stringVertices[35] = 0.25f;
	
	
	m_stringColors[0] = 0;
	m_stringColors[1] = 0;
	m_stringColors[2] = 0;
	m_stringColors[3] = 255;
	m_stringColors[4] = 0;
	m_stringColors[5] = 0;
	m_stringColors[6] = 0;
	m_stringColors[7] = 255;
	
	m_stringColors[8] = 0;
	m_stringColors[9] = 0;
	m_stringColors[10] = 0;
	m_stringColors[11] = 255;
	m_stringColors[12] = 0;
	m_stringColors[13] = 0;
	m_stringColors[14] = 0;
	m_stringColors[15] = 255;
	
	m_stringColors[16] = 0;
	m_stringColors[17] = 0;
	m_stringColors[18] = 0;
	m_stringColors[19] = 255;
	m_stringColors[20] = 0;
	m_stringColors[21] = 0;
	m_stringColors[22] = 0;
	m_stringColors[23] = 255;
	
	m_stringColors[24] = 0;
	m_stringColors[25] = 0;
	m_stringColors[26] = 0;
	m_stringColors[27] = 255;
	m_stringColors[28] = 0;
	m_stringColors[29] = 0;
	m_stringColors[30] = 0;
	m_stringColors[31] = 255;
	
	m_stringColors[32] = 0;
	m_stringColors[33] = 0;
	m_stringColors[34] = 0;
	m_stringColors[35] = 255;
	m_stringColors[36] = 0;
	m_stringColors[37] = 0;
	m_stringColors[38] = 0;
	m_stringColors[39] = 255;
	
	m_stringColors[40] = 0;
	m_stringColors[41] = 0;
	m_stringColors[42] = 0;
	m_stringColors[43] = 255;
	m_stringColors[44] = 0;
	m_stringColors[45] = 0;
	m_stringColors[46] = 0;
	m_stringColors[47] = 255;
	
	// Notes on the fretboard
	m_noteCount = (GLfloat)GTAR_GUITAR_FRET_COUNT * (GLfloat)GTAR_GUITAR_STRING_COUNT;
	
	unsigned int vertexIndex = 0;
	unsigned int colorIndex = 0;
	
	for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		for ( unsigned int fret = 0; fret < GTAR_GUITAR_FRET_COUNT; fret++ )
		{
			m_noteVertices[ vertexIndex++ ] = [self getPointForString:str];
			m_noteVertices[ vertexIndex++ ] = [self getPointForFret:fret];
			m_noteVertices[ vertexIndex++ ] = 0.25f;
			
			m_noteColors[ colorIndex++ ] = 0;
			m_noteColors[ colorIndex++ ] = 255;
			m_noteColors[ colorIndex++ ] = 0;
			m_noteColors[ colorIndex++ ] = 255;
		}
	}
		
	
}

- (GLfloat) getPointForString:(NSInteger)str
{
	
	GLfloat strPoint = (str - GTAR_GUITAR_STRING_COUNT/2 + 0.5) * LEARN_OBJECT_STRING_SPACING;
	
	return strPoint;
	
}

- (GLfloat) getPointForFret:(NSInteger)fret
{

	GLfloat fretSpacing =  LEARN_OBJECT_FRET_HEIGHT / (GTAR_GUITAR_FRET_COUNT-1);

	GLfloat fretPoint = (fret == 0 ) ? (-LEARN_OBJECT_FRET_HEIGHT/2) : (LEARN_OBJECT_FRET_HEIGHT/2 - ((fret-1) * fretSpacing));
	
	return fretPoint;
	
}

- (GLubyte) getIndexForString:(NSInteger)str andFret:(NSInteger)fret
{
	return (fret + (str * GTAR_GUITAR_FRET_COUNT ));
}


- (void) render3
{
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
			 GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			 GL_ORTHO_NEAR, GL_ORTHO_FAR );
	glMatrixMode(GL_MODELVIEW);
	
	// texturing will need these
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	// clear background to gray (don't need these if you draw a background image, since it will draw over whatever's there)
	glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	/* uncomment to draw a background image instead of gray background
	 if (backgroundTex == nil)
	 backgroundTex = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
	 
	 // background doesn't need blending
	 glDisable(GL_BLEND);
	 
	 [backgroundTex drawInRect:bounds];
	 */
	
	if (m_texture == nil)
		m_texture = [[Texture2D alloc] initWithString:@"TEST" dimensions:CGSizeMake(128, 64) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:28];
	
	// text will need blending
	glEnable(GL_BLEND);
	
	// text from Texture2D uses A8 tex format, so needs GL_SRC_ALPHA
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[m_texture drawAtPoint:CGPointMake(100, 100)];
	
	// switch it back to GL_ONE for other types of images, rather than text because Texture2D uses CG to load, which premultiplies alpha
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
}

- (void) render2
{

	// Set up the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
			 GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			 GL_ORTHO_NEAR, GL_ORTHO_FAR );
	m_backingWidth;
	m_backingHeight;
	//
	// Draw the model geometry
	//
	glMatrixMode(GL_MODELVIEW);
	
    // Set background color
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	//
	// Draw all the statics geometry
	//
	glLoadIdentity();

	//GLubyte textColor[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	//GLubyte textColor[] = {0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128};
	//GLubyte textColor[] = {0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255};
	GLubyte textColor[] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};
	//GLubyte textColor[] = {255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128};
	
	
	glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	//glColorPointer(4, GL_UNSIGNED_BYTE, 0, textColor);
	//glEnableClientState(GL_COLOR_ARRAY);
	//glEnableClientState(GL_VERTEX_ARRAY);
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY);

	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	[m_texture drawAtPoint:CGPointMake(GL_SCREEN_WIDTH/2, GL_SCREEN_HEIGHT/2)];
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

	glDisable(GL_BLEND);
	glDisable(GL_TEXTURE_2D);

	// Strings	
	glVertexPointer(3, GL_FLOAT, 0, m_stringVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_stringColors);
    glEnableClientState(GL_COLOR_ARRAY);
	
    glDrawArrays(GL_LINES, 0, m_stringCount * 2);
	
}

- (void) render
{
    
	// Set up the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
			  GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			  GL_ORTHO_NEAR, GL_ORTHO_FAR );
	m_backingWidth;
	m_backingHeight;
	//
	// Draw the model geometry
	//
	glMatrixMode(GL_MODELVIEW);
	
    // Set background color
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	//
	// Draw all the statics geometry
	//
	glLoadIdentity();
#if 1
	//GLubyte textColor[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	//GLubyte textColor[] = {0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128,0,0,0,128};
	//GLubyte textColor[] = {0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255};
	GLubyte textColor[] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};
	//GLubyte textColor[] = {255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128,255,255,255,128};

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glColorPointer(4, GL_UNSIGNED_BYTE, 0, textColor);
	glEnableClientState(GL_COLOR_ARRAY);	
	
	[m_texture drawAtPoint:CGPointMake(GL_SCREEN_WIDTH/2, GL_SCREEN_HEIGHT/2)];
	
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
//#else
	glRotatef( 20, 0.0f, 0.0f, 1.0f);
	glTranslatef( GL_SCREEN_WIDTH/3 + 20, GL_SCREEN_HEIGHT/3, 0.0f);
	
	glVertexPointer(3, GL_FLOAT, 0, m_guitarVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_guitarColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
	//glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_guitarIndices);    

    //glIndexPointer(4, GL_UNSIGNED_BYTE, 0, m_guitarColors);
    //glEnableClientState(GL_COLOR_ARRAY);
    
	glDrawElements(GL_TRIANGLES, m_guitarCount * 3, GL_UNSIGNED_SHORT, m_guitarIndices);
	
	// Strings	
	glVertexPointer(3, GL_FLOAT, 0, m_stringVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_stringColors);
    glEnableClientState(GL_COLOR_ARRAY);

    glDrawArrays(GL_LINES, 0, m_stringCount * 2);

	// Note highlights
	glVertexPointer(3, GL_FLOAT, 0, m_noteVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_noteColors);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glPointSize(5);
	glDrawElements(GL_POINTS, m_targetNotesCount, GL_UNSIGNED_BYTE, m_noteIndices);

#endif
	
}



@end
