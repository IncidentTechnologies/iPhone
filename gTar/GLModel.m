//
//  GLModel.m
//  gTar
//
//  Created by wuda on 10/26/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "GLModel.h"


@implementation GLModel

#pragma mark -
#pragma mark Initialization and deallocation

- (id)init;
{
	if (![super init])
		return nil;
	
	m_numVertices = 0;
	m_numIndices = 0;
	m_numberOfVertexBuffers = 0;
	m_vertexArray = nil;
	m_numberOfIndicesForBuffers = NULL;
	
	m_vertexBufferHandle = NULL;
	m_indexBufferHandle = NULL;
	
	isBeingDisplayed = NO;
	isRenderingCancelled = NO;
	isDoneRendering = NO;
	

	return self;
}


- (void)dealloc;
{
	// All buffers are deallocated after they are bound to their OpenGL counterparts,
	// but we still need to delete the OpenGL buffers themselves when done
	if (m_numberOfIndicesForBuffers != NULL)
	{
		free(m_numberOfIndicesForBuffers);
		//		m_numberOfVertexBuffers = NULL;
	}
	
	if (m_vertexBufferHandle != NULL)
		[self freeVertexBuffers];
	[m_vertexArrays release];
	[m_indexArrays release];
	[m_vertexArray release];
	[m_indexArray release];
	
	
	[super dealloc];
}

#pragma mark -
#pragma mark OpenGL

- (void)addVertexBuffer;
{
	if (m_vertexArray != nil)
	{
		[m_vertexArray release];
		[m_indexArray release];
	}
	m_vertexArray = [[NSMutableData alloc] init];
	m_indexArray = [[NSMutableData alloc] init];
	m_numberOfVertexBuffers++;
	[m_vertexArrays addObject:m_vertexArray];
	[m_indexArrays addObject:m_indexArray];
	m_numVertices = 0;
	m_numIndices = 0;
}

- (void)freeVertexBuffers;
{
	if (isRenderingCancelled)
		return;
	for (unsigned int bufferIndex = 0; bufferIndex < m_numberOfVertexBuffers; bufferIndex++)
	{
		glDeleteBuffers(1, &m_indexBufferHandle[bufferIndex]);
		glDeleteBuffers(1, &m_vertexBufferHandle[bufferIndex]);
	}
	
	
	if (m_vertexBufferHandle != NULL)
	{
		free(m_vertexBufferHandle);
		m_vertexBufferHandle = NULL;
	}
	if (m_indexBufferHandle != NULL)
	{
		free(m_indexBufferHandle);
		m_indexBufferHandle = NULL;
	}
	if (m_numberOfIndicesForBuffers != NULL)
	{
		free(m_numberOfIndicesForBuffers);
		m_numberOfIndicesForBuffers = NULL;
	}
	
}


- (void)addNormal:(GLfloat *)newNormal;
{
	GLshort shortNormals[4];
	shortNormals[0] = (GLshort)round(newNormal[0] * 32767.0f);
	shortNormals[1] = (GLshort)round(newNormal[1] * 32767.0f);
	shortNormals[2] = (GLshort)round(newNormal[2] * 32767.0f);
	shortNormals[3] = 0;
	
	[m_vertexArray appendBytes:shortNormals length:(sizeof(GLshort) * 4)];	
}

- (void)addVertex:(GLfloat *)newVertex;
{
	GLshort shortVertex[4];
	shortVertex[0] = (GLshort)MAX(MIN(round(newVertex[0] * 32767.0f), 32767), -32767);
	shortVertex[1] = (GLshort)MAX(MIN(round(newVertex[1] * 32767.0f), 32767), -32767);
	shortVertex[2] = (GLshort)MAX(MIN(round(newVertex[2] * 32767.0f), 32767), -32767);
	shortVertex[3] = 0;
	
	[m_vertexArray appendBytes:shortVertex length:(sizeof(GLshort) * 4)];	
	
	m_numVertices++;
}

- (void)addIndex:(GLushort *)newIndex;
{
	[m_indexArray appendBytes:newIndex length:sizeof(GLushort)];
	m_numIndices++;
}

- (void)addColor:(GLubyte *)newColor;
{
	[m_vertexArray appendBytes:newColor length:(sizeof(GLubyte) * 4)];
}

#pragma mark -
#pragma mark Render and draw

- (void)renderModel
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	isDoneRendering = NO;
//	[self performSelectorOnMainThread:@selector(showStatusIndicator) withObject:nil waitUntilDone:NO];
	
	m_vertexArrays = [[NSMutableArray alloc] init];
	m_indexArrays = [[NSMutableArray alloc] init];
	
	m_numberOfVertexBuffers = 0;
	[self addVertexBuffer];
	
	// Render all the vertices
	
	if (!isRenderingCancelled)
	{
		[self performSelectorOnMainThread:@selector(bindVertexBuffersForMolecule) withObject:nil waitUntilDone:YES];
	}
	else
	{
		m_numberOfVertexBuffers = 0;
		
		isBeingDisplayed = NO;
		isRenderingCancelled = NO;
		
		// Release all the NSData arrays that were partially generated
		[m_indexArray release];	
		m_indexArray = nil;
		[m_indexArrays release];
		
		[m_vertexArray release];
		m_vertexArray = nil;
		[m_vertexArrays release];	
		
	}
	
	isDoneRendering = YES;
	
	[pool release];
	
}


- (void)drawModel
{
	for (unsigned int bufferIndex = 0; bufferIndex < m_numberOfVertexBuffers; bufferIndex++)
	{
		// Bind the buffers
		glBindBuffer(GL_ARRAY_BUFFER, m_vertexBufferHandle[bufferIndex]); 
		glVertexPointer(3, GL_SHORT, 20, (char *)NULL + 0); 		
		glNormalPointer(GL_SHORT, 20, (char *)NULL + 8); 
		glColorPointer(4, GL_UNSIGNED_BYTE, 20, (char *)NULL + 16);
		
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_indexBufferHandle[bufferIndex]);    
		
		// Do the actual drawing to the screen
		glDrawElements(GL_TRIANGLES,m_numberOfIndicesForBuffers[bufferIndex],GL_UNSIGNED_SHORT, NULL);
		
		// Unbind the buffers
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); 
		glBindBuffer(GL_ARRAY_BUFFER, 0); 
	}
}


@end
