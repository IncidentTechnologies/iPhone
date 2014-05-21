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

static HighlightModel * m_highlightModel;

- (id)initWithCenter:(CGPoint)center andColor:(GLubyte*)color andTexture:(Texture2D*)texture andOverlay:(Model*)overlay
{
    self = [super initWithCenter:center andColor:color andTexture:texture];
    
    if ( self )
    {
        m_overlayModel = overlay;
        
        m_highlightModel = [[HighlightModel alloc] initWithCenter:m_center andSize:CGSizeMake(25, 25) andColor:g_standaloneClearColor andShape:@"Round"];
        
        m_hit = 0;
        
        l_color = color;
        
        [self initFretNoteCounts];
    }
    
    return self;
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

- (void)attemptNote
{
    m_hit = -1;
}

- (void)unattemptNote
{
    if(m_hit == -1){
        m_hit = 0;
    }
}

- (void)initFretNoteCounts
{
    for(int f = 0; f < 4; f++){
        m_fretNoteCounts[f] = 0;
    }
}

- (void)setFretNoteCount:(int)count AtIndex:(int)index
{
    m_fretNoteCounts[index] = count;
}

- (int)getFretNoteCountAtIndex:(int)index
{
    return m_fretNoteCounts[index];
}

- (void)drawWithHighlights:(BOOL)highlight highlightColor:(GLubyte *)color recolorNote:(BOOL)recolor
{
	if(_m_standalonefret >= 0){
        
        // Recolor notes on hit, ensure opaque
        if(recolor){
            GLubyte solidColor[4] = {color[0],color[1],color[2],255.0};
            [super changeColor:solidColor];
        }
        
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
