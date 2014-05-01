//
//  NoteModel.h
//  gTar
//
//  Created by wuda on 12/21/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

//#import "Texture2D.h"
#import <gTarAppCore/Model.h>
#import "HighlightModel.h"
#import "gTarColors.h"

@interface NoteModel : Model
{
	
//	// phase this stuff out
//	GLfloat m_startX;
//	GLfloat m_startY;
//	
//	GLfloat m_endX;
//	GLfloat m_endY;
//	
//	GLfloat m_middleX;
//	GLfloat m_middleY;
//	
//	Texture2D * m_start; // left cap, or standalone note
//	Texture2D * m_end; // right cap
//	Texture2D * m_middle;
//	// phase this stuff out
//	
//	//Texture2D * m_overlay;
    
	Model * m_overlayModel;
    GLubyte * l_color;
    int m_fretNoteCounts[4];

}

- (id)initWithCenter:(CGPoint)center andSize:(CGSize)size andColor:(GLubyte*)color andOverlay:(Model*)overlay;

//- (NoteModel*)initDurationWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height;
//- (NoteModel*)initSpotWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height;
- (NoteModel*)initWithCenter:(CGPoint)center andColor:(GLubyte*)color andTexture:(Texture2D*)texture andOverlay:(Model*)overlay;
//- (NoteModel*)initWidthWithCoords:(GLfloat*)coords andColor:(GLubyte*)color andHeight:(GLfloat)height;

- (void)drawWithHighlights:(BOOL)highlight highlightColor:(GLubyte*)color recolorNote:(BOOL)recolor;
- (void)dealloc;
- (void)releaseCachedImages;
- (void)hitNote;
- (void)missNote;
- (void)attemptNote;
- (void)unattemptNote;
- (void)setFretNoteCount:(int)count AtIndex:(int)index;
- (int)getFretNoteCountAtIndex:(int)index;

@property (nonatomic, assign) int m_fret;
@property (nonatomic, assign) int m_standalonefret;
@property (nonatomic, assign) double m_hit;

@end
