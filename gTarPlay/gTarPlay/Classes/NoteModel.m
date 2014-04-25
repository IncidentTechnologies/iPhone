//
//  NoteModel.m
//  gTar
//
//  Created by wuda on 12/21/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "NoteModel.h"

@implementation NoteModel

@synthesize m_hit;

// these have to go here, basically because objc says so.
// (static variables in the class def don't work as expected)
// pretend that they are class variables for NoteModel

static UIImage * m_noteImage;

static Texture2D * m_noteTexture;

static HighlightModel * m_highlightModel;

static GLfloat m_noteHeight = 0;

static unsigned int m_notesRemaining = 0;

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andOverlay:(Model*)overlay
{
	
    self = [super init];
    
	if ( self )
	{
		m_notesRemaining++;
		
		m_center = center;
		
		m_overlayModel = [overlay retain];
		
		m_texture = [m_noteTexture retain];
        
        m_highlightModel = [[[HighlightModel alloc] initWithCenter:m_center andSize:CGSizeMake(25, 25) andColor:g_standaloneClearColor andShape:@"Round"] retain];
        
        m_hit = 0;
		
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
        
        m_highlightModel = [[[HighlightModel alloc] initWithCenter:m_center andSize:CGSizeMake(25, 25) andColor:g_standaloneClearColor andShape:@"Round"] retain];
        
        m_hit = 0;
    }
    
    return self;
}

- (void)dealloc
{
	
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
	
	[m_noteTexture release];
    
    [m_highlightModel release];
	
	m_noteImage  = nil;
	
	m_noteTexture  = nil;
    
    m_highlightModel = nil;
	
}

- (void)hitNote
{
    m_hit = 1;
}

- (void)missNote
{
    if(!m_hit){
        m_hit = -1;
    }
}

- (void)drawWithHighlights:(BOOL)highlight highlightColor:(GLubyte *)color
{
	if(_m_standalonefret >= 0){
        // This allows the texture to take on the color of the geometry
        glEnable(GL_COLOR_MATERIAL);
        
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
        
        if ( m_texture != nil )
        {
            // this is a texture
            [m_texture drawAtPoint:m_center];
            
            // this is a model
            if(m_overlayModel != nil){
                [m_overlayModel drawAt:m_center];
            }
        }
        
        glDisable(GL_COLOR_MATERIAL);
        
        if(highlight){
            [m_highlightModel changeColor:color];
            [m_highlightModel drawAt:m_center];
        }
    }
	
}

@end
