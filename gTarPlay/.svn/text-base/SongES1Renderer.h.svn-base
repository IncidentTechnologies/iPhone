//
//  SongES1Renderer.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/8/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ES1Renderer.h>

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

	LineModel * m_seekLineModel;
    
    Model * m_backgroundTexture;
    
    CGFloat m_backgroundOffset;
}

@property (nonatomic, retain) LineModel * m_seekLineModel;
@property (nonatomic, retain) Model * m_backgroundTexture;
@property (nonatomic, assign) GLfloat m_offset;
@property (nonatomic, assign) GLfloat m_viewShift;

- (void)addAnimation:(NoteAnimation*)animation;
- (void)removeAnimation:(NoteAnimation*)animation;
- (void)addModel:(NoteModel*)model;
- (void)removeModel:(NoteModel*)model;
- (void)addString:(StringModel*)str;
- (void)removeString:(StringModel*)str;
- (void)addLine:(LineModel*)line;
- (void)removeLine:(LineModel*)line;
- (void)clearModelData;

- (void)updatePositionAndRender:(double)position;

@end
