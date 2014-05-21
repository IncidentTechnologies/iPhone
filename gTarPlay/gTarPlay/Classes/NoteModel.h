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
	Model * m_overlayModel;
    GLubyte * l_color;
    int m_fretNoteCounts[4];
}

- (NoteModel*)initWithCenter:(CGPoint)center andColor:(GLubyte*)color andTexture:(Texture2D*)texture andOverlay:(Model*)overlay;

- (void)drawWithHighlights:(BOOL)highlight highlightColor:(GLubyte*)color recolorNote:(BOOL)recolor;
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
