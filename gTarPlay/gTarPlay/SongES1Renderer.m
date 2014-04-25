//
//  SongES1Renderer.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongES1Renderer.h"

#import "LineModel.h"
#import "StringModel.h"
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
        
        m_stringModels = [[NSMutableArray alloc] init];
        m_lineModels = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}

- (void)dealloc
{
    
    [m_noteAnimations release];
    [m_noteModels release];
    
    [m_stringModels release];
    [m_lineModels release];
        
    [m_seekLineModel release];
    [m_backgroundTexture release];
    
    [super dealloc];
    
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

- (void)addString:(StringModel*)str
{
    [m_stringModels addObject:str];
}

- (void)removeString:(StringModel*)str
{
    [m_stringModels removeObject:str];
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
    
    [m_noteAnimations release];
    [m_noteModels release];
    
    [m_stringModels release];
    [m_lineModels release];
    
    m_noteAnimations = [[NSMutableArray alloc] init];
    m_noteModels = [[NSMutableArray alloc] init];
    
    m_stringModels = [[NSMutableArray alloc] init];
    m_lineModels = [[NSMutableArray alloc] init];
    
    [m_seekLineModel release];
    
    m_seekLineModel = nil;
    
}

#pragma mark -
#pragma mark Render

- (void)updatePositionAndRender:(double)position
{
    
    m_currentPosition = position;
    
    //
    // This is for the initial offset, which is currently negative.
    // 
    if ( position < 0 && position < -m_backgroundOffset )
    {
        m_backgroundOffset = -position;
    }
    
//    [self render];
    
}

- (void)render
{

    [self startRender];
	
    [self renderNoteModelsWithHighlights:NO fretOne:NO fretTwo:NO fretThree:NO];
    
    [self endRender];
    
    
}

- (void)renderWithHighlights:(BOOL)highlight fretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree
{
    [self startRender];
    [self renderNoteModelsWithHighlights:YES fretOne:fretOne fretTwo:fretTwo fretThree:fretThree];
    [self endRender];
}

- (void)startRender
{
    
    
	// update model
    //	[self updateCurrentPosition];
    //    NSLog(@"Rendering GL frame");
    
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
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
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
    [m_backgroundTexture drawAt:CGPointMake(m_backingWidth/2.0, m_backingHeight/2.0)];
    
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
    
    glTranslatef( -m_viewShift, 0.0f, 0.0f);
	glTranslatef( m_offset - m_currentPosition, 0.0f, 0.0f);
    
	// draw measure lines
    for ( LineModel * lineModel in m_lineModels )
    {
		[lineModel draw];
	}
    
    glTranslatef( -(m_offset - m_currentPosition), 0.0f, 0.0f);
    
    // draw the seek line
	[m_seekLineModel drawWithOffset:CGPointMake(m_offset, 0)];
    
    // The strings are fixed, so undo any translattion
    glTranslatef( +m_viewShift, 0.0f, 0.0f);
    
    //
	// Draw strings -- these do not move
    //
    for ( LineModel * stringModel in m_stringModels )
    {
		[stringModel draw];
	}
    
    //    //
    //    // Translate the view to draw the seek line
    //    //
    glTranslatef( -m_viewShift, 0.0f, 0.0f);
    //
    //	// draw the seek line
    //	[m_seekLineModel drawWithOffset:CGPointMake(m_offset, 0)];
    
    //
    // Now we translate forward for the notes
    //
    glTranslatef( m_offset - m_currentPosition, 0.0f, 0.0f);
    
	// draw notes
    for ( Animation * animation in m_noteAnimations )
    {
		[animation drawCurrentFrameAndAdvanceFrame];
	}
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

- (void)renderNoteModelsWithHighlights:(BOOL)highlights fretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree
{
    for(int n = [m_noteModels count] - 1; n >= 0; n--){
        
        NoteModel * model = [m_noteModels objectAtIndex:n];
        
        if(highlights){
            
            if(model.m_hit > 0){
                
                [model drawWithHighlights:highlights highlightColor:g_standaloneHitFretColor];
                
            }else if(model.m_hit < 0){
                
                [model drawWithHighlights:highlights highlightColor:g_standaloneMissFretColor];
                
            }else{
                
                // Which fret to show?
                if(fretOne && model.m_standalonefret == 1){
                    [model drawWithHighlights:highlights highlightColor:g_standaloneHighlightColors[1]];
                    
                }else if(fretTwo && model.m_standalonefret == 2){
                    
                    [model drawWithHighlights:highlights highlightColor:g_standaloneHighlightColors[2]];
                
                }else if(fretThree && model.m_standalonefret == 3){
                    [model drawWithHighlights:highlights highlightColor:g_standaloneHighlightColors[3]];
                    
                }else if(model.m_standalonefret == 0){
                    
                    if((model.m_notecount == 0 && !fretOne && !fretTwo && !fretThree) || (model.m_notecount > 0)){
                        [model drawWithHighlights:highlights highlightColor:g_standaloneHighlightColors[0]];
                    }else{
                        [model drawWithHighlights:NO highlightColor:nil];
                    }
                    
                }else{
                    [model drawWithHighlights:NO highlightColor:nil];
                }
            }
            
        }else{
            [model drawWithHighlights:NO highlightColor:nil];
        }
    }
}

@end
