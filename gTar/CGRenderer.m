//
//  CGRenderer.m
//  gTar
//
//  Created by wuda on 12/20/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "CGRenderer.h"


@implementation CGRenderer

- (void)setRenderObject:(CGObject*)object
{
	m_renderObject = object;
}

- (void)renderFromObject
{
	[m_renderObject render];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
	m_backingWidth = layer.bounds.size.width;
	m_backingHeight = layer.bounds.size.width;	
}

@end
