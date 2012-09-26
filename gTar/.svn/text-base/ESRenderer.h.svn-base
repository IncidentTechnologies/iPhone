//
//  ESRenderer.h
//  gTar
//
//  Created by wuda on 12/20/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewRenderer.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface ESRenderer : ViewRenderer
{
	ESObject * m_renderObject;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint m_defaultFramebuffer, m_colorRenderbuffer;	
}

- (void)setRenderObject:(ESObject*)object;

@end
