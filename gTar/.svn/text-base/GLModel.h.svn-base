//
//  GLModel.h
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface GLModel : NSObject
{
	
	// OpenGL vertex buffer objects
	unsigned int *m_numberOfIndicesForBuffers;
	GLuint *m_vertexBufferHandle, *m_indexBufferHandle;

	NSMutableArray *m_vertexArrays, *m_indexArrays;
	unsigned int m_numberOfVertexBuffers;

	NSMutableData *m_vertexArray, *m_indexArray;
	unsigned int m_numVertices, m_numIndices;
	
	BOOL isBeingDisplayed;
	BOOL isRenderingCancelled;
	BOOL isDoneRendering;


}

- (void) drawModel;

@end
