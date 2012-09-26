//
//  ES1SaysObject.m
//  gTar
//
//  Created by wuda on 12/6/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "ES1SaysObject.h"


@implementation ES1SaysObject

- (void)initTextures
{

	// General purpose digits
	for ( unsigned int i = 0; i < 20; i++ )
	{
		NSString * digitString = [NSString stringWithFormat:@"%d", i];
		
		m_textDigits[i] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(32, 32) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:28];
		
	}
	
	// Fret digits
	NSString * digitString;
	GLfloat x;
	GLfloat y;
	GLfloat top, bottom;

	digitString = [NSString stringWithFormat:@"%d", 1];
	m_fretDigits[0] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(128,128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:112];
	x = ([self convertFretToCoordSpace:0] + [self convertFretToCoordSpace:1]) / 2.0;
	y = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
	m_fretDigitsCoords[0] = CGPointMake(x, y);
	
	digitString = [NSString stringWithFormat:@"%d", 3];
	m_fretDigits[1] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(128,128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:112];
	x = ([self convertFretToCoordSpace:2] + [self convertFretToCoordSpace:3]) / 2.0;
	y = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
	m_fretDigitsCoords[1] = CGPointMake(x, y);
	
	digitString = [NSString stringWithFormat:@"%d", 5];
	m_fretDigits[2] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(128,128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:112];
	x = ([self convertFretToCoordSpace:4] + [self convertFretToCoordSpace:5]) / 2.0;
	y = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
	m_fretDigitsCoords[2] = CGPointMake(x, y);
	
	digitString = [NSString stringWithFormat:@"%d", 7];
	m_fretDigits[3] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(128,128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:112];
	x = ([self convertFretToCoordSpace:6] + [self convertFretToCoordSpace:7]) / 2.0;
	y = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
	m_fretDigitsCoords[3] = CGPointMake(x, y);
	
	digitString = [NSString stringWithFormat:@"%d", 9];
	m_fretDigits[4] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(128,128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:112];
	x = ([self convertFretToCoordSpace:8] + [self convertFretToCoordSpace:9]) / 2.0;
	y = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
	m_fretDigitsCoords[4] = CGPointMake(x, y);
	
	digitString = [NSString stringWithFormat:@"%d", 12];
	m_fretDigits[5] = [[Texture2D alloc] initWithString:digitString dimensions:CGSizeMake(128,128) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:112];
	x = ([self convertFretToCoordSpace:11] + [self convertFretToCoordSpace:12]) / 2.0;
	y = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
	m_fretDigitsCoords[5] = CGPointMake(x, y);
	
	
	NSString * filePath = [[NSBundle mainBundle] pathForResource:@"play_background_blank" ofType:@"png"];
	
	UIImage * frameImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	CGSize newSize;
	newSize.height = GL_SCREEN_HEIGHT;
	newSize.width = GL_SCREEN_WIDTH;
	
	UIGraphicsBeginImageContext(newSize);
    [frameImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
	
	
	m_backgroundFrame = [[Texture2D alloc] initWithImage:newImage];
	
}

//- (void)initStrings:(NSInteger)stringCount
- (void)initStrings
{
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"string" ofType:@"png"];
	
	CGSize newSize;
	newSize.width = GL_SCREEN_WIDTH;
	//newSize.width = g_fretCoords[15] + g_fretBuffer;
	
	for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
	{

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

- (void)initFrets
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"string" ofType:@"png"];
	
	CGSize newSize;
	newSize.height = GL_SCREEN_HEIGHT;
	newSize.width = GL_STRING_HEIGHT / 2.0; // temp
		
	for ( unsigned int i = 0; i < GTAR_GUITAR_FRET_COUNT; i++ )
	{
		UIImage * fretImage = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		UIGraphicsBeginImageContext(newSize);
		[fretImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();    
		UIGraphicsEndImageContext();
		
		m_fretTextures[i] = [[Texture2D alloc] initWithImage:newImage];
		
		// fret coords

		if ( i == 0 )
		{
			//g_fretCoords[i] = g_fretBuffer + (g_fretSpacingBase * g_fretSpacingMultiplier[i]);
			g_fretCoords[0] = g_fretBuffer;
			//g_fretCoords[0] = 0;
		}
		else 
		{
			g_fretCoords[i] = g_fretSpacingBase * g_fretSpacingMultiplier[i] + g_fretCoords[i-1];
		}
	}
	

}


- (void)initNotes
{

//	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"note-white" ofType:@"png"];
	
//	UIImage * noteImage = [[UIImage alloc] initWithContentsOfFile:filePath];

//	CGSize newSize;
//	newSize.width = GL_NOTE_HEIGHT;
//	newSize.height = GL_NOTE_HEIGHT;
	
	m_noteModels = [[NSMutableArray alloc] init];
	
	for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		for ( unsigned int fret = 0; fret < GTAR_GUITAR_FRET_COUNT; fret++ )
		{
//			UIGraphicsBeginImageContext(newSize);
//			[noteImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//			UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();    
//			UIGraphicsEndImageContext();
			
			NSInteger index = [self convertToIndexString:str andFret:fret ];
			
			GLubyte colors[4];
			colors[0] = g_stringColorsQuads[str][0];
			colors[1] = g_stringColorsQuads[str][1];
			colors[2] = g_stringColorsQuads[str][2];
			colors[3] = g_stringColorsQuads[str][3];
			
			GLfloat x;
			GLfloat y;
			GLfloat diff;
			
			if ( fret == 0 )
			{
				//x = 0;
				//diff = g_fretCoords[0];
				// zero fret is the open string
				// just make a long note for now, but TODO is 
				// to make a special string gfc
				
				x = g_fretCoords[0]; // start at the previous fret
				diff = g_fretCoords[15] - g_fretCoords[0];
				
				y = [self convertStringToCoordSpace:str];
				
				GLfloat coords[4];
				coords[0] = x;
				coords[1] = y;
				coords[2] = x + diff;
				coords[3] = y;
				
				GLfloat noteHeight = GL_NOTE_HEIGHT;
				NoteModel * noteModel = [[NoteModel alloc] initWidthWithCoords:coords andColor:colors andHeight:GL_NOTE_HEIGHT];
				[m_noteModels insertObject:noteModel atIndex:index];				
				
			}
			else
			{
				x = g_fretCoords[fret-1]; // start at the previous fret
				diff = g_fretCoords[fret] - g_fretCoords[fret-1];

				y = [self convertStringToCoordSpace:str];
				
				GLfloat coords[4];
				coords[0] = x;
				coords[1] = y;
				coords[2] = x + diff;
				coords[3] = y;
				
				//		NoteModel * noteModel = [[NoteModel alloc] initSpotWithCoords:&m_noteVertices[i*2] andColor:&m_noteColors[i*4]];
				GLfloat noteHeight = GL_NOTE_HEIGHT;
				NoteModel * noteModel = [[NoteModel alloc] initWidthWithCoords:coords andColor:colors andHeight:GL_NOTE_HEIGHT];
				[m_noteModels insertObject:noteModel atIndex:index];
				
			}
			
		}
		
	}		
	
}

- (NSInteger)convertToIndexString:(NSInteger)str andFret:(NSInteger)fret
{
	return (str * GTAR_GUITAR_FRET_COUNT) + fret;
}

- (GLfloat)convertStringToCoordSpace:(NSInteger)str
{
	GLfloat effectiveScreenHeight = (GL_SCREEN_HEIGHT) - (GL_SCREEN_TOP_BUFFER + GL_SCREEN_BOTTOM_BUFFER);
	
	GLfloat heightPerString = effectiveScreenHeight / ((GLfloat)GTAR_GUITAR_STRING_COUNT-1);
	
	return GL_ORTHO_BOTTOM + GL_SCREEN_BOTTOM_BUFFER + ( str * heightPerString );
}

// 1 based
- (GLfloat)convertFretToCoordSpace:(NSInteger)fret
{

//	GLfloat effectiveScreenWidth = (GL_SCREEN_WIDTH);
	
//	GLfloat widthPerFret = effectiveScreenWidth / ((GLfloat)GTAR_GUITAR_FRET_COUNT-1);
	
	// zero is not a specific fret location, rather the whole string, so we based at 1
//	return ((fret-1) * widthPerFret);

//	GLfloat coordResult = 0;

	//frets are 1 based, convert to zero
	//fret--;
	
//	for ( unsigned int f = 0; f <= fret; f++ )
//	{
//		coordResult += (g_fretSpacingBase * g_fretSpacingMultiplier[f]);
//	}
	
	// This is the starting position of the fret board
	if ( fret < 0 )
	{
		return 0;
	}
	
//	return coordResult;
	return g_fretCoords[fret];
}

- (void)playNoteString:(NSInteger)str andFret:(NSInteger)fret
{
	[self playNoteString:str andFret:fret forFrames:SAYS_NOTE_LIFE_FRAMES];
}


- (void)playNoteString:(NSInteger)str andFret:(NSInteger)fret forFrames:(NSInteger)frames
{
	NSInteger index = [self convertToIndexString:str andFret:fret];

	m_noteFramesVisible[index] = frames;
	
	NoteModel * noteModel = [m_noteModels objectAtIndex:index];
	
	[noteModel changeOpacity:255];
}

- (void)focusReset
{
	m_focusFretLeft = -1;
	m_focusFretRight = -1;
}

- (void)focusAddString:(NSInteger)str andFret:(NSInteger)fret
{
	
	// ignore the string since we will always show all the strings
	if ( m_focusFretLeft == -1 )
	{
		m_focusFretLeft = fret;
	}
	else if ( fret < m_focusFretLeft )
	{
		m_focusFretLeft = fret;
	}
			 
	if ( m_focusFretRight == -1 )
	{
		m_focusFretRight = fret;
	}
	else if ( fret > m_focusFretRight )
	{
		m_focusFretRight = fret;
	}
	
	
	[self zoomToIncludeFrets];
	
}

- (void)zoomToIncludeFrets
{
		
	// set the translation

	if ( m_focusFretLeft == -1 || m_focusFretRight == -1 )
	{
		m_focusTranslation = 0;
	}
	else if ( m_focusFretLeft == 0 )
	{
		m_focusTranslation = 0;
	}
//	else if ( m_focusFretLeft == m_focusFretRight )
//	{
//		GLfloat diff = g_fretCoords[ m_focusFretRight ] - g_fretCoords[ m_focusFretLeft ];
		//m_focusTranslation = g_fretCoords[ m_focusFretLeft ] - (diff / 2.0) - (GL_SCREEN_WIDTH / 2.0);
//		m_focusTranslation = (g_fretCoords[ m_focusFretLeft ]+g_fretCoords[ m_focusFretRight ]) / 2.0 - (GL_SCREEN_WIDTH / 2.0)
//	}
	else
	{
		//GLfloat diff = g_fretCoords[ m_focusFretRight ] - g_fretCoords[ m_focusFretLeft ];
		GLfloat diff = g_fretCoords[ m_focusFretLeft ] - g_fretCoords[ m_focusFretLeft - 1 ];
//		m_focusTranslation = g_fretCoords[ m_focusFretLeft ] + (diff / 2.0) - (GL_SCREEN_WIDTH / 2.0);
		m_focusTranslation = (g_fretCoords[ m_focusFretLeft ] + g_fretCoords[ m_focusFretRight ] - diff) / 2.0 - (GL_SCREEN_WIDTH / 2.0);
	}
	
	/*
	if ( m_focusFretLeft == -1 )
	{
		m_focusWindowLeft = 0;
	}
	else if ( m_focusWindowLeft > m_focusWindowLeftTarget )
	{
		m_focusLeftStep = (m_focusWindowLeft - m_focusWindowLeftTarget) / 10;		
	}

	if ( m_focusFretRight == -1 )
	{
		m_focusWindowRight = m_backingWidth;
	}
	else if ( m_focusWindowRight < m_focusWindowRightTarget )
	{
		m_focusRightStep = (m_focusWindowRightTarget - m_focusWindowRight) / 10;		
	}
	*/

}


- (void) render
{
	/*
	// update any per-frame state
	if ( m_focusWindowLeft > m_focusWindowLeftTarget )
	{
		m_focusWindowLeft -= m_focusLeftStep;
	}
	
	if ( m_focusWindowRight < m_focusWindowRightTarget )
	{
		m_focusWindowRight += m_focusRightStep;
	}
	*/
	GLfloat window = g_fretCoords[15] + g_fretBuffer;
	// Set up the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
			 GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			 -300, 300 );
	glMatrixMode(GL_MODELVIEW);
	
    // Set background color
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
	//
	// Draw all the statics i.e. with identity matrix
	//
	glLoadIdentity();
	
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
	
	// Frets go down first so they are always on the bottom
    glEnableClientState(GL_COLOR_ARRAY);
	
	glTranslatef(-m_focusTranslation, 0, 0);
	
	GLubyte whiteColor[16] = 
	{  
		255, 255, 255, 255,
		255, 255, 255, 255,
		255, 255, 255, 255,
		255, 255, 255, 255
	};
	
	GLubyte grayColor[16] = 
	{  
		60, 60, 60, 255,
		60, 60, 60, 255,
		60, 60, 60, 255,
		60, 60, 60, 255
	};
	
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, whiteColor);
	
	for ( unsigned i = 0; i < GTAR_GUITAR_FRET_COUNT; i++ )
	{		
		CGFloat y = GL_SCREEN_HEIGHT / 2.0;
		CGFloat x = [self convertFretToCoordSpace:(i+1)];
		[m_fretTextures[i] drawAtPoint:CGPointMake(x, y)];
		
		// float it between the 3rd and 4th (2 and 3) strings
		//CGFloat fy = ([self convertStringToCoordSpace:2] + [self convertStringToCoordSpace:3]) / 2.0;
		
		// float it between the x and the x-1 fret
		//CGFloat fx = ([self convertFretToCoordSpace:(i-1)] + [self convertFretToCoordSpace:i]) / 2.0;

		//[m_textDigits[i] drawAtPoint:CGPointMake(fx, fy) ];
	}

	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, grayColor);
	
	for ( unsigned i = 0; i < 6; i++ )
	{
		[m_fretDigits[i] drawAtPoint:m_fretDigitsCoords[i]];
	}
	
	// For strings, return the ortho to the 'normal' size'
	glPushMatrix();
	glLoadIdentity();

	for ( unsigned str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		glColorPointer(4, GL_UNSIGNED_BYTE, 0, &g_stringColorsQuads[str]);
		
		CGFloat y = [self convertStringToCoordSpace:str];
		//CGFloat x = (g_fretCoords[15]+g_fretBuffer)/2.0;
		[m_stringTextures[str] drawAtPoint:CGPointMake(GL_SCREEN_WIDTH/2.0, y)];
		//[m_stringTextures[str] drawAtPoint:CGPointMake(x, y)];
		
	}
	
	glPopMatrix();
	
	// For notes go back to the stretched ortho
/*
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, window, //GL_ORTHO_RIGHT,
			 GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			 -300, 300 );
	glMatrixMode(GL_MODELVIEW);
*/	
	for ( unsigned str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		//glColorPointer(4, GL_UNSIGNED_BYTE, 0, &g_stringColorsQuads[str]);
		
		for ( unsigned int fret = 0; fret < GTAR_GUITAR_FRET_COUNT; fret++ )
		{
			NSInteger index = [self convertToIndexString:str andFret:fret];
			
			if ( m_noteFramesVisible[index] > 0 )
			{
				if ( fret > 0 )
				{
					m_noteFramesVisible[index]--;
					
					NoteModel * model = [m_noteModels objectAtIndex:index];
					
					// change the opacity based on the ttl
					if ( m_noteFramesVisible[index] < (SAYS_NOTE_LIFE_FRAMES - 5) )
					{
						GLubyte newOpacity = (m_noteFramesVisible[index] * 255) / SAYS_NOTE_LIFE_FRAMES;
						[model changeOpacity:newOpacity];
					}
					
					[model draw];
				}
				else 
				{
					// draw a string
					
				}
			}
			
		}
		
	}
	
//	glPopMatrix();
/*	
	// Draw the note textures
	for ( unsigned int index = 0; index < [m_noteModels count]; index++)
	{
		NoteModel * noteModel = [m_noteModels objectAtIndex:index];
		
		[noteModel draw];
	}
	
	// Draw the numbers
	GLubyte textColor[] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, textColor);
	//    glEnableClientState(GL_COLOR_ARRAY);
	
	for ( unsigned int i = 0; i < m_noteCount; i++ )
	{
		unsigned int digit = m_digitsValues[i];
		
		int x = m_noteVertices[i*2 +0];
		int y = m_noteVertices[i*2 +1];
		
		[m_textDigits[digit] drawAtPoint:CGPointMake(x, y)];
		
	}
*/	
	//
	// Draw the background. It goes after all the notes/etc. so it is on top.
	// Load the Id so our frame doesn't move
	//
	//glLoadIdentity();
/*	
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
			 GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
			 -300, 300 );
	glMatrixMode(GL_MODELVIEW);
*/
	glLoadIdentity();
	glDisableClientState(GL_COLOR_ARRAY);
	
	//[m_backgroundFrame drawAtPoint:CGPointMake(GL_SCREEN_WIDTH / 2.0, GL_SCREEN_HEIGHT / 2.0)];
	//[m_backgroundFrame drawAtPoint:CGPointMake( 0, 0 ) ];
	
	// Blend function for everything else
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	
}
@end
