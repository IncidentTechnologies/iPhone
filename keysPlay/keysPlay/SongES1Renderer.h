//
//  SongES1Renderer.h
//  keysPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <gTarAppCore/ES1Renderer.h>

@class LineModel;
@class StringModel;
@class NoteAnimation;
@class NoteModel;
@class Model;

@interface SongES1Renderer : ES1Renderer
{

    GLfloat m_offset;
    GLfloat m_currentPosition;
    GLfloat m_viewShift;
	
	NSMutableArray * m_noteAnimations;
    NSMutableArray * m_noteModels;
	
	NSMutableArray * m_stringModels;	
	NSMutableArray * m_lineModels;
    NSMutableArray * m_loopModels;

	LineModel * m_seekLineModel;
    LineModel * m_seekLineStandaloneModel;
    
    Model * m_backgroundTexture;
    
    CGFloat m_backgroundOffset;
}

@property (nonatomic, strong) LineModel * m_seekLineModel;
@property (nonatomic, strong) LineModel * m_seekLineStandaloneModel;
@property (nonatomic, strong) Model * m_backgroundTexture;
@property (nonatomic, assign) GLfloat m_offset;
@property (nonatomic, assign) GLfloat m_viewShift;

- (void)renderWithHighlights:(BOOL)highlight fretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree;
- (void)addAnimation:(NoteAnimation*)animation;
- (void)removeAnimation:(NoteAnimation*)animation;
- (void)addModel:(NoteModel*)model;
- (void)removeModel:(NoteModel*)model;
- (void)addString:(StringModel*)str;
- (void)removeString:(StringModel*)str;
- (void)addLoop:(LineModel*)loop;
- (void)removeLoop:(LineModel*)loop;
- (void)addLine:(LineModel*)line;
- (void)removeLine:(LineModel*)line;
- (void)clearModelData;

- (void)updatePositionAndRender:(double)position;

@end
