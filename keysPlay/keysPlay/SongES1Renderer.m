//
//  SongES1Renderer.m
//  keysPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongES1Renderer.h"

#import "LineModel.h"
#import "KeyPathModel.h"
#import "NoteModel.h"
#import <gTarAppCore/NoteAnimation.h>
#import <gTarAppCore/Model.h>

#define GL_ORTHO_LEFT (0.0f)
#define GL_ORTHO_RIGHT (m_backingWidth)
#define GL_ORTHO_TOP (m_backingHeight)
#define GL_ORTHO_BOTTOM (0.0f)
#define GL_ORTHO_NEAR (-1.0f)
#define GL_ORTHO_FAR (+1.0f)

@implementation SongES1Renderer

@synthesize m_seekLineModel;
@synthesize m_seekLineStandaloneModel;
@synthesize m_backgroundTexture;
@synthesize m_offset;
@synthesize m_horizontalOffset;
@synthesize m_viewShift;
@synthesize m_isVertical;

- (id)init
{
    
    self = [super init];
    
    if ( self )
    {
        
        // container for notes
        m_noteAnimations = [[NSMutableArray alloc] init];
        m_noteModels = [[NSMutableArray alloc] init];
        
        m_keyPathModels = [[NSMutableArray alloc] init];
        m_lineModels = [[NSMutableArray alloc] init];
        m_loopModels = [[NSMutableArray alloc] init];
        
        m_isVertical = YES;
        
    }
    
    return self;
    
}


#pragma mark - Accessors

- (void)addAnimation:(NoteAnimation*)animation
{
    [m_noteAnimations addObject:animation];
}

- (void)removeAnimation:(NoteAnimation*)animation
{
    [m_noteAnimations removeObject:animation];
}

- (void)addModel:(NoteModel*)model
{
    [m_noteModels addObject:model];
}

- (void)removeModel:(NoteModel*)model
{
    [m_noteModels removeObject:model];
}

- (void)addKeyPath:(KeyPathModel*)keypath
{
    [m_keyPathModels addObject:keypath];
}

- (void)removeKeyPath:(KeyPathModel*)keypath
{
    [m_keyPathModels removeObject:keypath];
}

- (void)addLoop:(LineModel *)loop
{
    [m_loopModels addObject:loop];
}

- (void)removeLoop:(LineModel *)loop
{
    [m_loopModels removeObject:loop];
}

- (void)addLine:(LineModel*)line
{
    [m_lineModels addObject:line];
}

- (void)removeLine:(LineModel*)line
{
    [m_lineModels removeObject:line];
}

- (void)clearModelData
{
    
    [m_noteModels removeAllObjects];
    [m_noteAnimations removeAllObjects];
    [m_keyPathModels removeAllObjects];
    [m_lineModels removeAllObjects];
    [m_loopModels removeAllObjects];
    
    m_noteAnimations = nil;
    m_noteModels = nil;
    m_keyPathModels = nil;
    m_lineModels = nil;
    
    m_noteAnimations = [[NSMutableArray alloc] init];
    m_noteModels = [[NSMutableArray alloc] init];
    
    m_keyPathModels = [[NSMutableArray alloc] init];
    m_lineModels = [[NSMutableArray alloc] init];
    
    m_seekLineModel = nil;
    m_seekLineStandaloneModel = nil;
    
}

#pragma mark -
#pragma mark Render

- (void)updatePositionAndRender:(double)position
{
    m_currentPosition = position;
}

- (void)render
{
    [self startRender];
	
    [self renderNoteModelsWithHighlights:NO hitCorrect:0.0 hitNear:0.0 hitIncorrect:0.0];
    
    [self endRender];
}

- (void)renderWithHighlights:(BOOL)highlight hitCorrect:(float)hitCorrect hitNear:(float)hitNear hitIncorrect:(float)hitIncorrect
{
    [self startRender];
    [self renderNoteModelsWithHighlights:YES hitCorrect:hitCorrect hitNear:hitNear hitIncorrect:hitIncorrect];
    [self endRender];
}

- (void)startRender
{
    double cameraScale = (m_isVertical) ? [g_keysMath cameraScale] : DEFAULT_CAMERA_SCALE;
    
    // init stuff
	[EAGLContext setCurrentContext:m_context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_defaultFramebuffer);
    glViewport(0, 0, m_backingWidth, m_backingHeight);
    
	// Set up the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, cameraScale*GL_ORTHO_RIGHT,
             GL_ORTHO_BOTTOM, cameraScale*GL_ORTHO_TOP,
             GL_ORTHO_NEAR, GL_ORTHO_FAR );
	
	//
	// Draw the model geometry
	//
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
    // Set background color
    glClearColor(38/255.0, 45/255.0, 51/255.0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
	//
	// Textures
	//
	// texturing will need these
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	
	// Blend function for textures
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    // Translate and draw note path areas
    if(m_isVertical){
        glTranslatef(m_horizontalOffset, 0.0f, 0.0f);
    }
        
    for ( LineModel * keyPathModel in m_keyPathModels )
    {
		[keyPathModel draw];
	}
    
    //
    // Now we translate forward for the notes
    //
    if(m_isVertical){
        glTranslatef( 0.0f, cameraScale*m_offset - m_currentPosition, 0.0f);
    }else{
        glTranslatef( m_horizontalOffset - m_currentPosition, 0.0f, 0.0f);
    }
    
    // And draw the moving loop lines
    
    for (LineModel * loopModel in m_loopModels )
    {
        CGPoint center = [loopModel getCenter];
        
        [loopModel drawAt:CGPointMake(center.x,center.y)];
    }
    
    // Draw the moving measure/ledger lines
    
    for (LineModel * lineModel in m_lineModels )
    {
        CGPoint center = [lineModel getCenter];
        
        if(m_horizontalOffset-m_currentPosition+center.x > GL_SEEK_LINE_X){
            [lineModel drawAt:CGPointMake(center.x,center.y)];
        }
    }
    

}

- (void)endRender
{
    // Done
    
    //
    // Draw the background overlay that doesn't move
    //
    if(!m_isVertical){
        
        glTranslatef( -(m_horizontalOffset - m_currentPosition), 0.0f, 0.0f);
        
        [m_backgroundTexture drawAt:CGPointMake((GL_SEEK_LINE_X-1)/2.0, 273/2.0)];
        
        [m_seekLineModel draw];
    }
    
	// Switch the buffer
	glBindRenderbufferOES( GL_RENDERBUFFER_OES, m_colorRenderbuffer );
    
    [m_context presentRenderbuffer: GL_RENDERBUFFER_OES ];
}

- (void)renderNoteModelsWithHighlights:(BOOL)highlights hitCorrect:(float)hitCorrect hitNear:(float)hitNear hitIncorrect:(float)hitIncorrect
{
    
    for(int n = [m_noteModels count] - 1; n >= 0; n--){
        
        NoteModel * model = [m_noteModels objectAtIndex:n];
        
        if(model == nil){
            continue;
        }
        
        // Sheet music
        if(!m_isVertical){
            
            if(model.m_hit >= 0){
                // Stop rendering notes that have been hit or missed
                [model drawWithHighlights:NO highlightColor:nil recolorNote:NO];
                continue;
            }
            
        }
        
        if(highlights){
            
            if(model.m_hit > hitCorrect){
                
                [model drawWithHighlights:highlights highlightColor:g_standaloneHitKeyCorrectColor recolorNote:YES];
            
            }else if(model.m_hit > hitNear){
                
                [model drawWithHighlights:highlights highlightColor:g_standaloneHitKeyNearColor recolorNote:YES];
                
            }else if(model.m_hit > hitIncorrect){
                
                [model drawWithHighlights:highlights highlightColor:g_standaloneHitKeyIncorrectColor recolorNote:YES];
                
            }else if(model.m_hit == 0){
                
                [model drawWithHighlights:highlights highlightColor:g_standaloneMissKeyColor recolorNote:NO];
                
            }else{
                
                if(model.m_standalonekey < KEYS_OCTAVE_COUNT){
                    [model drawWithHighlights:highlights highlightColor:[self getHighlightColorForMappedKey:model.m_standalonekey] recolorNote:NO];
                }else{
                    [model drawWithHighlights:NO highlightColor:nil recolorNote:NO];
                }
            }
            
        }else{
        
            [model drawWithHighlights:NO highlightColor:nil recolorNote:NO];
        }
    }
}

- (GLubyte *)getHighlightColorForMappedKey:(int)mappedKey
{
    GLubyte * noteColor;
    
    if((mappedKey < 5 && mappedKey%2==0) || (mappedKey >= 5 && mappedKey%2==1)){
        // WHITE
        noteColor = g_standaloneKeyColors[0];
    }else{
        // BLACK
        noteColor = g_standaloneKeyColors[1];
    }
    
    return noteColor;
}



@end
