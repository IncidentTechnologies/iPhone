//
//  ES1PlayRenderer.m
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "ES1PlayObject.h"


@implementation ES1PlayObject

- (void)dealloc
{

	delete m_noteVertices;
	delete m_noteColors;
	delete m_noteIndices;
	
	delete m_digitsValues;
//	delete m_digitsVertices;

	delete m_stringVertices;
	delete m_stringColors;
	
	delete m_measureVertices;
	delete m_measureColors;
	
	[m_noteModels release];

	for ( unsigned int i = 0; i < 20; i++ )
	{
		Texture2D * texture = m_textDigits[i];
		[texture release];
	}
	
	for ( unsigned int i = 0; i < 4; i++ )
	{
		[m_countdownTextures[i] release];		
	}
	
	[m_seekLineTexture release];
	[m_backgroundFrame release];
}

#pragma mark -
#pragma mark Current beat accesors

- (void) setCurrentBeat:(GLfloat)beat
{
	m_currentBeat = beat;
	m_currentPosition = [self convertBeatToCoordSpace:m_currentBeat];
}

- (void) incrementCurrentBeat:(GLfloat)beatDelta
{
	[self setCurrentBeat:(m_currentBeat+beatDelta)];
}

#pragma mark -
#pragma mark Model initialization functions

- (void) initTextures
{

	// init digit
	for ( unsigned int i = 0; i < 20; i++ )
	{
		NSString * imageName = [NSString stringWithFormat:@"note-%u", i];
		NSString * filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
		UIImage * image = [[UIImage alloc] initWithContentsOfFile:filePath];

		CGSize newSize;
		newSize.height = GL_NOTE_HEIGHT;
		newSize.width = GL_NOTE_HEIGHT;
		
		UIGraphicsBeginImageContext(newSize);
		[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		m_textDigits[i] = [[Texture2D alloc] initWithImage:scaledImage];
		//m_textDigits[i] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(32, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:28];

	}
	
	// init countdown textures
	for ( unsigned int i = 1; i < 4; i++ )
	{
		NSString * imageName = [NSString stringWithFormat:@"note-%u", i];
		NSString * filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
		UIImage * image = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		CGSize newSize;
		newSize.height = GL_NOTE_HEIGHT * 4;
		newSize.width = GL_NOTE_HEIGHT * 4;
		
		UIGraphicsBeginImageContext(newSize);
		[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		m_countdownTextures[i] = [[Texture2D alloc] initWithImage:scaledImage];
		//m_textDigits[i] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(32, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:28];
		
	}

	m_countdownTextures[0] = [[Texture2D alloc] initWithString:@"GO!" dimensions:CGSizeMake(128, 128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:60];

	[self countdownOff];
	
	// init the seek line
	NSString * filePath = [[NSBundle mainBundle] pathForResource:@"string" ofType:@"png"];
	
	CGSize newSize;
	//newSize.width = GL_SCREEN_WIDTH;
	newSize.width = 7;
	newSize.height = GL_SCREEN_HEIGHT; 
		
	UIImage * stringImage = [[UIImage alloc] initWithContentsOfFile:filePath];
		
	UIGraphicsBeginImageContext(newSize);
	[stringImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();    
	UIGraphicsEndImageContext();
		
	m_seekLineTexture = [[Texture2D alloc] initWithImage:newImage];
	
	[stringImage release];
	
		
	// init the background texture
	filePath = [[NSBundle mainBundle] pathForResource:@"play_background_blank" ofType:@"png"];
	
	UIImage * frameImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
//	CGSize newSize;
	newSize.height = GL_SCREEN_HEIGHT;
	newSize.width = GL_SCREEN_WIDTH;
	
	UIGraphicsBeginImageContext(newSize);
    [frameImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
	
	m_backgroundFrame = [[Texture2D alloc] initWithImage:newImage];
	
}

- (void) initSeekLine
{
	// Seek line vertices: start and end
	m_seekVertices[0] = GL_ORTHO_LEFT + GL_SCREEN_SEEK_LINE_OFFSET;
	m_seekVertices[1] = GL_ORTHO_TOP;
	
	m_seekVertices[2] = GL_ORTHO_LEFT + GL_SCREEN_SEEK_LINE_OFFSET;
	m_seekVertices[3] = GL_ORTHO_BOTTOM;
	
	// Seek line colors: start and end
	m_seekColors[0] = 255;
	m_seekColors[1] = 0;
	m_seekColors[2] = 0;
	m_seekColors[3] = 255;
	
	m_seekColors[4] = 255;
	m_seekColors[5] = 0;
	m_seekColors[6] = 0;
	m_seekColors[7] = 255;
	
}

- (void) convertStrings:(unsigned int)str
{
	m_stringCount = str;
	
	m_stringVertices = new GLfloat[ m_stringCount * 4 ];
	m_stringColors = new GLubyte[ m_stringCount * 8 ];
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"string" ofType:@"png"];
		
	CGSize newSize;
	newSize.width = GL_SCREEN_WIDTH;

	for ( unsigned int i = 0; i < m_stringCount; i++ )
	{
		// Coords: start and end
		m_stringVertices[i*4 +0] = GL_ORTHO_LEFT;
		m_stringVertices[i*4 +1] = [self convertStringToCoordSpace:i];
		
		m_stringVertices[i*4 +2] = GL_ORTHO_RIGHT;
		m_stringVertices[i*4 +3] = [self convertStringToCoordSpace:i];
		
		// Colors: start and end
		m_stringColors[i*8 +0] = g_stringColors[i][0];
		m_stringColors[i*8 +1] = g_stringColors[i][1];
		m_stringColors[i*8 +2] = g_stringColors[i][2];
		m_stringColors[i*8 +3] = g_stringColors[i][3];
		
		m_stringColors[i*8 +4] = g_stringColors[i][0];
		m_stringColors[i*8 +5] = g_stringColors[i][1];
		m_stringColors[i*8 +6] = g_stringColors[i][2];
		m_stringColors[i*8 +7] = g_stringColors[i][3];
		
		// strings number and size are inversely proportional
		newSize.height = GL_STRING_HEIGHT + (GTAR_GUITAR_STRING_COUNT - 1 - i) * GL_STRING_HEIGHT_INCREMENT; // gets slightly bigger 
		
		UIImage * stringImage = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(newSize);
		[stringImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		m_stringTextures[i] = [[Texture2D alloc] initWithImage:newImage];
				
	}
	
}

- (void) convertNoteArray:(NoteArray*)noteArray
{
	
	m_noteCount = noteArray->m_noteCount;
	
	GLuint verticesTotal = m_noteCount * PLAY_OBJECT_VERTICES_PER_NOTE;
	
	m_noteVertices = new GLfloat[ verticesTotal * 3 ];
	m_noteColors = new GLubyte[ verticesTotal * 4 ];
	m_noteIndices = new GLushort[ m_noteCount * PLAY_OBJECT_TRIANGLES_PER_NOTE * 3];
	
	m_digitsValues = new char[ m_noteCount ];
//	m_digitsVertices = new GLfloat[ m_noteCount * 2 ];
								   
	CNote * notes = noteArray->m_notes;
	
#ifdef TETRAS
	unsigned int vertexIndex = 0;
	unsigned int colorIndex = 0;
	unsigned int indexIndex = 0;
	
	for ( int currentNote = 0; currentNote < m_noteCount; currentNote++ )
	{
		GLfloat x = [self convertBeatToCoordSpace:notes[currentNote].m_absoluteBeatStart];

		GLfloat y = [self convertStringToCoordSpace:notes[currentNote].m_string];

		unsigned short baseIndex = vertexIndex;

		for ( unsigned int currentCounter = 0; currentCounter < PLAY_OBJECT_VERTICES_PER_NOTE; currentCounter++ )
		{
			// Adjust radius and shift to match center
			GLfloat temp = (vdata[currentCounter][0] * PLAY_OBJECT_NOTE_RADIUS) + x;
			m_noteVertices[vertexIndex++] = temp;
			
			temp = (vdata[currentCounter][1] * PLAY_OBJECT_NOTE_RADIUS) + y;
			m_noteVertices[vertexIndex++] = temp;
			
			temp = (vdata[currentCounter][2] * PLAY_OBJECT_NOTE_RADIUS) + 0;
			m_noteVertices[vertexIndex++] = temp;
			
			// Just use original icosahedron for normals
			//newVertex[0] = vdata[currentCounter][0];
			//newVertex[1] = vdata[currentCounter][1];
			//newVertex[2] = vdata[currentCounter][2];
						
			m_noteColors[colorIndex++] = 0;
			m_noteColors[colorIndex++] = 255;
			m_noteColors[colorIndex++] = 255;
			m_noteColors[colorIndex++] = 255;
		}
	
		for ( unsigned int currentCounter = 0; currentCounter < PLAY_OBJECT_TRIANGLES_PER_NOTE; currentCounter++ )
		{
			for ( unsigned int internalCounter = 0; internalCounter < 3; internalCounter++ )
			{
				m_noteIndices[indexIndex++] = baseIndex + tindices[currentCounter][internalCounter];
			}
		}	
	}
	
#else
	m_noteModels = [[NSMutableArray alloc] init];
	
	for ( unsigned int i = 0; i < m_noteCount; i++ )
	{
		// Beat
		m_noteVertices[i*2 +0] = [self convertBeatToCoordSpace:notes[i].m_absoluteBeatStart];
		// String
		m_noteVertices[i*2 +1] = [self convertStringToCoordSpace:notes[i].m_string];
		
		// Color
		m_noteColors[i*4 +0] = g_stringColors[notes[i].m_string][0];
		m_noteColors[i*4 +1] = g_stringColors[notes[i].m_string][1];
		m_noteColors[i*4 +2] = g_stringColors[notes[i].m_string][2];
		m_noteColors[i*4 +3] = g_stringColors[notes[i].m_string][3];
		
		m_digitsValues[i] = notes[i].m_fret;
		
		GLfloat coords[4];
		coords[0] = m_noteVertices[i*2 +0];
		coords[1] = m_noteVertices[i*2 +1];
		coords[2] = m_noteVertices[i*2 +0] + 50;
		coords[3] = m_noteVertices[i*2 +1];
		
		NoteModel * noteModel = [[NoteModel alloc] initSpotWithCoords:coords andColor:&m_noteColors[i*4] andHeight:GL_NOTE_HEIGHT];
		//NoteModel * noteModel = [[NoteModel alloc] initDurationWithCoords:coords andColor:&m_noteColors[i*4] andHeight:GL_NOTE_HEIGHT];
		[m_noteModels addObject:noteModel];
		
		[noteModel release];
	}
#endif
}

- (void) convertMeasureArray:(MeasureArray*)measureArray
{
	
	CMeasure * measures = measureArray->m_measures;
	
	m_measureCount = measureArray->m_measureCount;
	
	m_measureVertices = new GLfloat[ m_measureCount * 4 ];
	m_measureColors = new GLubyte[ m_measureCount * 8 ];
	
	for ( unsigned int i = 0; i < m_measureCount; i++ )
	{
		
		// Coords: start and end
		m_measureVertices[i*4 +0] = [self convertBeatToCoordSpace:measures[i].m_startBeat];
		m_measureVertices[i*4 +1] = GL_ORTHO_TOP;
		
		m_measureVertices[i*4 +2] = [self convertBeatToCoordSpace:measures[i].m_startBeat];
		m_measureVertices[i*4 +3] = GL_ORTHO_BOTTOM;
		
		// Colors: start and end
		m_measureColors[i*8 +0] = 255;
		m_measureColors[i*8 +1] = 255;
		m_measureColors[i*8 +2] = 0;
		m_measureColors[i*8 +3] = 255;
		
		m_measureColors[i*8 +4] = 255;
		m_measureColors[i*8 +5] = 255;
		m_measureColors[i*8 +6] = 0;
		m_measureColors[i*8 +7] = 255;
		
	}
	
}

- (GLfloat) convertBeatToCoordSpace:(CGFloat)beat
{
	return beat * (GLfloat)PLAY_OBJECT_PIXELS_PER_BEAT;
}

- (GLfloat) convertStringToCoordSpace:(NSInteger)str
{
	GLfloat effectiveScreenHeight = (GL_SCREEN_HEIGHT) - (GL_SCREEN_TOP_BUFFER + GL_SCREEN_BOTTOM_BUFFER);
	
	GLfloat heightPerString = effectiveScreenHeight / ((GLfloat)m_stringCount-1);
	
	return GL_ORTHO_BOTTOM + GL_SCREEN_BOTTOM_BUFFER + ( str * heightPerString );
}


#pragma mark -
#pragma mark External input functions

- (void) setTargetNotes:(NoteArrayRange)arrayRange
{
#ifdef TETRAS
	return;
#endif
	// No change, no update needed.
	if ( m_targetNotes.m_count == arrayRange.m_count &&
		m_targetNotes.m_index == arrayRange.m_index )
	{
		return;
	}
	else
	{
		// Something has changed, clear the notes
		[self clearTargetNotes];
	}
	
	m_targetNotes = arrayRange;
	
	// There are no target notes, nothing to do.
	if ( m_targetNotes.m_count == 0 )
	{
		return;
	}
	
#if 0
	// Change the color of the notes
	for ( unsigned int i = 0; i < m_targetNotes.m_count; i++ )
	{
		unsigned int index = m_targetNotes.m_index;
		
		// Color
		m_noteColors[(index+i) *4 +0] = 255;
		m_noteColors[(index+i) *4 +1] = 0;
		m_noteColors[(index+i) *4 +2] = 0;
		m_noteColors[(index+i) *4 +3] = 255;
		
		NoteModel * noteModel = [m_noteModels objectAtIndex:index];
		[noteModel changeColor:&m_noteColors[(index+i) *4] ];
	}
#endif
}

- (void) clearTargetNotes
{
#if 0
	// Change the color of the notes
	for ( unsigned int i = 0; i < m_targetNotes.m_count; i++ )
	{
		unsigned int index = m_targetNotes.m_index;
		
		// Color
		m_noteColors[(index+i) *4 +0] = 0;
		m_noteColors[(index+i) *4 +1] = 0;
		m_noteColors[(index+i) *4 +2] = 255;
		m_noteColors[(index+i) *4 +3] = 255;
		
		NoteModel * noteModel = [m_noteModels objectAtIndex:index];
		[noteModel changeColor:&m_noteColors[(index+i) *4]];
		
	}
#endif
	m_targetNotes.m_count = 0;
	m_targetNotes.m_index = 0;
	
}

- (void)countdownOn:(NSInteger)count
{	
	m_countdownTextureIndex = count;
}

- (void)countdownOff
{
	m_countdownTextureIndex = PLAY_OBJECT_COUNTDOWN;
}

#pragma mark -
#pragma mark OpenGL


- (void) render
{
    
	// Set up the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
			 GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			 -300, 300 );
			 //GL_ORTHO_NEAR * 10.0, GL_ORTHO_FAR * 10.0 );
	
	//
	// Draw the model geometry
	//
	glMatrixMode(GL_MODELVIEW);
	
    // Set background color
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	//
	// Draw all the statics i.e. with identity matrix
	//
	glLoadIdentity();
	
	//	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//	[m_numberTextures[1] drawAtPoint:CGPointMake( 0, 0 ) ];
	
	
	// Draw string lines and colors
#if 0
	glVertexPointer(2, GL_FLOAT, 0, m_stringVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_stringColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_LINES, 0, m_stringCount * 2);
#else 
	
	
#endif
	// Draw seek line and color
	
	glVertexPointer(2, GL_FLOAT, 0, m_seekVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_seekColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_LINES, 0, 2);
	
	//
	// Draw all the dynamics
	//
	// Left screen coord - buffer - currentPosition
	glTranslatef(GL_ORTHO_LEFT + GL_SCREEN_SEEK_LINE_OFFSET - m_currentPosition, 
				 0.0f, 0.0f);
	
	// Draw measure lines and colors
	glVertexPointer(2, GL_FLOAT, 0, m_measureVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_measureColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_LINES, 0, m_measureCount * 2);
	
	// Draw note vertices and colors
#ifdef TETRAS
	
    glVertexPointer(3, GL_FLOAT, 0, m_noteVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_noteColors);
    glEnableClientState(GL_COLOR_ARRAY);

	glPointSize(15.0);
    glDrawElements(GL_TRIANGLES, m_noteCount * PLAY_OBJECT_TRIANGLES_PER_NOTE * 3, GL_UNSIGNED_SHORT, m_noteIndices);
	//glDrawElements(GL_TRIANGLES, PLAY_OBJECT_TRIANGLES_PER_NOTE * 3, GL_UNSIGNED_SHORT, m_noteIndices);
	GLushort temp[] = {0,1,2,3,4,5,6,7,8};
	//glDrawElements(GL_POINTS, 9, GL_UNSIGNED_SHORT, temp);
	//glDrawElements(GL_POINTS, 9, GL_UNSIGNED_SHORT, m_noteIndices);

#else
	
/*
	glVertexPointer(2, GL_FLOAT, 0, m_noteVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
	
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_noteColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
	glPointSize(15.0);
    glDrawArrays(GL_POINTS, 0, m_noteCount);
*/

#endif

	//
	// Texture rendering
	//
	
	// texturing will need these
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	
	// Blend function for textures
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Strings go down first so they are always on the bottom
	glPushMatrix();
	glLoadIdentity();
	
    glEnableClientState(GL_COLOR_ARRAY);
	
	for ( unsigned i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, &g_stringColorsQuads[i]);
		
		CGFloat y = [self convertStringToCoordSpace:i];
		[m_stringTextures[i] drawAtPoint:CGPointMake(GL_SCREEN_WIDTH / 2.0, y)];
	}
	

	// also draw the seek line
	GLubyte whiteColor[] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};	
	//GLubyte whiteColor[] = {255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255,255,0,0,255};	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, whiteColor);
	[m_seekLineTexture drawAtPoint:CGPointMake(GL_ORTHO_LEFT + GL_SCREEN_SEEK_LINE_OFFSET, GL_SCREEN_HEIGHT / 2.0)];
	
	glPopMatrix();
	
	// Draw the note textures
	for ( unsigned int index = 0; index < [m_noteModels count]; index++)
	{
		NoteModel * noteModel = [m_noteModels objectAtIndex:index];
		
		[noteModel draw];
	}
	
	// Draw the numbers
	GLubyte textColor[] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, textColor);

	for ( unsigned int i = 0; i < m_noteCount; i++ )
	{
		unsigned int digit = m_digitsValues[i];
		
		int x = m_noteVertices[i*2 +0];
		int y = m_noteVertices[i*2 +1];
		
		[m_textDigits[digit] drawAtPoint:CGPointMake(x, y)];
		
	}
	
	glLoadIdentity();
	
	// Draw the countdown timer, if applicable.
	if ( m_countdownTextureIndex < PLAY_OBJECT_COUNTDOWN )
	{
		[m_countdownTextures[m_countdownTextureIndex] drawAtPoint:CGPointMake(GL_SCREEN_WIDTH/2, GL_SCREEN_HEIGHT/2)];
	}

	//
	// Draw the background. It goes after all the notes/etc. so it is on top.
	// Load the Id so our frame doesn't move
	//

	glDisableClientState(GL_COLOR_ARRAY);

//	[m_backgroundFrame drawAtPoint:CGPointMake(GL_SCREEN_WIDTH / 2.0, GL_SCREEN_HEIGHT / 2.0)];

	// Blend function for everything else
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
}

@end
