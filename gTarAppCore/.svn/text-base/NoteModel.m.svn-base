//
//  NoteModel.m
//  gTar
//
//  Created by wuda on 12/21/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "NoteModel.h"

@implementation NoteModel

// these have to go here, basically because objc says so.
// (static variables in the class def don't work as expected)
// pretend that they are class variables for NoteModel
static UIImage * m_noteImage;
static UIImage * m_noteLeftImage;
static UIImage * m_noteMiddleImage;
static UIImage * m_noteRightImage;

static Texture2D * m_noteTexture;
static Texture2D * m_noteLeftTexture;
static Texture2D * m_noteMiddleTexture;
static Texture2D * m_noteRightTexture;

static GLfloat m_noteHeight = 0;
//static GLfloat m_noteSize = CGPointMake(0,0);

static unsigned int m_notesRemaining = 0;

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andOverlay:(Model*)overlay
{
	
    self = [super init];
    
	if ( self )
	{
		m_notesRemaining++;
		
		m_center = center;
		
		m_overlayModel = [overlay retain];
		
		[self changeColor:color];
		
		[self createImagesWithHeight:size.height];
		
		m_texture = [m_noteTexture retain];
		
	}
	
	return self;
	
}

// This might be the only relevant constructor right now
- (id)initWithCenter:(CGPoint)center andColor:(GLubyte*)color andTexture:(Texture2D*)texture andOverlay:(Model*)overlay
{
    
    self = [super initWithCenter:center andColor:color andTexture:texture];
    
    if ( self )
    {
        
        m_overlayModel = [overlay retain];
        
    }
    
    return self;
}

// basically a duration that includes the end caps within the given width
- (NoteModel*)initWidthWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height
{
	
	coords[0] += height/2.0;
	coords[2] -= height/2.0;
	
	return [self initDurationWithCoords:coords andColor:color andHeight:height];
	
}

- (NoteModel*)initDurationWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height
{
    
    self = [super init];
    
	if ( self )
	{
		m_notesRemaining++;
	}
	else 
	{
		return nil;
	}
	
	m_startX = coords[0];
	m_startY = coords[1];
	m_endX = coords[2];
	m_endY = coords[3];
	m_middleX = m_startX + (m_endX - m_startX) / 2;
	m_middleY = m_startY; // same
	
	[self changeColor:color];
	
	// should be cached and not creating anything most of the time
	[self createImagesWithHeight:height];	
	
	m_start = [m_noteLeftTexture retain];
	m_end = [m_noteRightTexture retain];
	
	// specialize the middle for this note
	UIImage * scaledImage;
	CGSize newSize;
	newSize.height = height;
	newSize.width = m_endX - m_startX;
	
	UIGraphicsBeginImageContext(newSize);
	[m_noteMiddleImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
	UIGraphicsEndImageContext();
	
	m_middle = [[Texture2D alloc] initWithImage:scaledImage];
	
	return self;	
}

- (NoteModel*)initSpotWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height
{
    
    self = [super init];
    
	if ( self )
	{
		m_notesRemaining++;
	}
	else 
	{
		return nil;
	}
	
	m_startX = coords[0];
	m_startY = coords[1];
	
	[self changeColor:color];
	
	[self createImagesWithHeight:height];
	
	m_start = [m_noteTexture retain];
	
	return self;
	
}

- (void)dealloc
{
	
	// this releases all the specific textures that we retained
	[m_start release];
	[m_middle release];
	[m_end release];
	
	[m_overlayModel release];
	
    if ( m_notesRemaining > 0 )
    {
        m_notesRemaining--;

        if ( m_notesRemaining == 0 )
        {
            // we can clear out all the static state
            m_noteHeight = 0;
            
            [self releaseCachedImages];
            
        }
    }
	
	[super dealloc];
}

- (void)releaseCachedImages
{
	[m_noteImage release];
	[m_noteLeftImage release];
	[m_noteMiddleImage release];
	[m_noteRightImage release];
	
	[m_noteTexture release];
	[m_noteLeftTexture release];
	[m_noteMiddleTexture release];
	[m_noteRightTexture release];
	
	m_noteImage  = nil;
	m_noteLeftImage  = nil;
	m_noteMiddleImage  = nil;
	m_noteRightImage  = nil;
	
	m_noteTexture  = nil;
	m_noteLeftTexture  = nil;
	m_noteMiddleTexture  = nil;
	m_noteRightTexture  = nil;
	
}

- (void)createImagesWithHeight:(GLfloat)height
{
	if ( height > 0 && height == m_noteHeight )
	{
		// the cache is good enough
		return;
	}
	
	m_noteHeight = height;
	
	// release any old ones
	[self releaseCachedImages];
	
	NSString * filePath;
	UIImage * scaledImage;
	
	CGSize newSize;
	newSize.height = height;
	newSize.width = height;
	
	// circle note
	
	//filePath = [[NSBundle mainBundle] pathForResource:@"blank-note" ofType:@"png"];
	filePath = [[NSBundle mainBundle] pathForResource:@"note-blank4" ofType:@"png"];
	m_noteImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	UIGraphicsBeginImageContext(newSize);
	[m_noteImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
	UIGraphicsEndImageContext();
	
	m_noteTexture = [[Texture2D alloc] initWithImage:scaledImage];
	
	// left end cap
	
	filePath = [[NSBundle mainBundle] pathForResource:@"blank-note-left" ofType:@"png"];
	m_noteLeftImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	UIGraphicsBeginImageContext(newSize);
	[m_noteLeftImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
	UIGraphicsEndImageContext();
	
	m_noteLeftTexture = [[Texture2D alloc] initWithImage:scaledImage];
	
	// right end cap
	
	filePath = [[NSBundle mainBundle] pathForResource:@"blank-note-right" ofType:@"png"];
	m_noteRightImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	UIGraphicsBeginImageContext(newSize);
	[m_noteRightImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
	UIGraphicsEndImageContext();
	
	m_noteRightTexture = [[Texture2D alloc] initWithImage:scaledImage];
	
	// middle section
	
	filePath = [[NSBundle mainBundle] pathForResource:@"blank-note-middle" ofType:@"png"];
	m_noteMiddleImage = [[UIImage alloc] initWithContentsOfFile:filePath];
	
	// cant do the scaling now, because it depends on the duration of a given note.
	
}

- (void)draw
{
	
	// This allows the texture to take on the color of the geometry
	glEnable(GL_COLOR_MATERIAL);
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
	
	if ( m_texture != nil )
	{
		// this is a texture
		[m_texture drawAtPoint:m_center];
		// this is a model
		[m_overlayModel drawAt:m_center];
	}
	else 
	{
		
		[m_start drawAtPoint:CGPointMake(m_startX, m_startY)];
		
		if ( m_end != nil )
		{
			//glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
			// Fix up the 'x' coord to make the texture seamless
			[m_end drawAtPoint:CGPointMake(m_endX - 0, m_endY)];
		}
		
		if ( m_middle != nil )
		{
			//glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
			// Fix up the 'x' coord to make the texture seamless
			[m_middle drawAtPoint:CGPointMake(m_middleX - 0, m_middleY)];
		}
	}
	
	glDisable(GL_COLOR_MATERIAL);
	
}

@end
