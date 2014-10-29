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
@synthesize m_viewShift;

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

- (void)addKeyPath:(KeyPathModel*)str
{
    [m_keyPathModels addObject:str];
}

- (void)removeKeyPath:(KeyPathModel*)str
{
    [m_keyPathModels removeObject:str];
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
    
    //NSLog(@"Current position is %f",m_currentPosition);
    
    //
    // This is for the initial offset, which is currently negative.
    // 
    /*if ( position < 0 && position < -m_backgroundOffset )
    {
        m_backgroundOffset = -position;
    }*/
    
//    [self render];
    
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
	// init stuff
	[EAGLContext setCurrentContext:m_context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_defaultFramebuffer);
    glViewport(0, 0, m_backingWidth, m_backingHeight);
    
	
	// Set up the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof( GL_ORTHO_LEFT, GL_ORTHO_RIGHT,
             GL_ORTHO_BOTTOM, GL_ORTHO_TOP,
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
	
    //
    // Draw the background that doesn't move
    //
    //[m_backgroundTexture drawAt:CGPointMake(m_backingWidth/2.0, m_backingHeight/2.0)];
    
    //
    // These backgrounds move
    //
    //    [m_backgroundTexture drawAt:CGPointMake(-fmod(m_backgroundOffset+m_currentPosition+m_viewShift, m_backingWidth) + m_backingWidth/2.0,
    //                                            m_backingHeight/2.0)];
    //    [m_backgroundTexture drawAt:CGPointMake(-fmod(m_backgroundOffset+m_currentPosition+m_viewShift, m_backingWidth) + m_backingWidth/2.0 + m_backingWidth,
    //                                            m_backingHeight/2.0)];
    
    //
    // First translate for the measure lines -- view shift + position
    //
    
     /*glTranslatef( 0.0f, -m_viewShift, 0.0f);*/
	glTranslatef( 0.0f, m_offset - m_currentPosition, 0.0f);
    
	// draw measure lines
    for ( LineModel * lineModel in m_lineModels )
    {
		[lineModel draw];
	}
    
    glTranslatef( 0.0f, -(m_offset - m_currentPosition), 0.0f);
    
    // draw the seek line(s)
	/*[m_seekLineModel drawWithOffset:CGPointMake(m_offset, 0)];
    
    if(m_seekLineStandaloneModel != nil){
        [m_seekLineStandaloneModel drawWithOffset:CGPointMake(m_offset, 0)];
    }
     */
        
    // The strings are fixed, so undo any translattion
      /*glTranslatef( 0.0f, +m_viewShift, 0.0f);*/
    
    //
	// Draw key paths -- these do not move
    //
    for ( LineModel * keyPathModel in m_keyPathModels )
    {
		[keyPathModel draw];
	}
    
    //    //
    //    // Translate the view to draw the seek line
    //    //
      /*glTranslatef( 0.0f, -m_viewShift, 0.0f);*/
    //
    //	// draw the seek line
    //	[m_seekLineModel drawWithOffset:CGPointMake(m_offset, 0)];
    
    
    //
    // Draw loops
    //
    for (LineModel * loopModel in m_loopModels)
    {
        CGPoint center = [loopModel getCenter];
        
        [loopModel drawAt:CGPointMake(center.x +m_offset - m_currentPosition,center.y)];
    }
    
    //
    // Now we translate forward for the notes
    //
    glTranslatef( 0.0f, m_offset - m_currentPosition, 0.0f);
    /*
	// draw notes
    for ( Animation * animation in m_noteAnimations )
    {
		[animation drawCurrentFrameAndAdvanceFrame];
	}*/
}

- (void)endRender
{
    
    //
    // Done -- Switch the buffer
    //
    
	// finish stuff
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
