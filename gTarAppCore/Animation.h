//
//  Animation.h
//  gTarAppCore
//
//  Created by Marty Greenia on 3/22/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Model.h"

@interface Animation : NSObject
{

	CGPoint m_animationCenter;
	
	NSMutableArray * m_models;

	BOOL m_animating;
	BOOL m_loop;

	NSInteger m_framesPerModel;

	NSInteger m_currentFrame;	
	
	NSInteger m_currentModel;
	
}

- (id)initWithFramesPerModel:(NSInteger)framesPerModel;

- (void)addModel:(Model*)model;
- (void)addModelFromImageName:(NSString*)imageName withSize:(CGSize)imageSize andCenter:(CGPoint)center andColor:(GLubyte*)color;

- (void)drawCurrentFrame;
- (void)drawCurrentFrameAndAdvanceFrame;

- (void)startAnimation:(BOOL)loop;
- (void)stopAnimation;

- (void)resetAnimation;

- (void)changeCenter:(CGPoint)center;
- (void)changeAllColors:(GLubyte*)color;

@end
