/*
 
 File: ES1Renderer.m
 
 Abstract: The ES1Renderer class creates an OpenGL ES 1.1 context and draws 
 using OpenGL ES 1.1 functions.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
*/

#import "ES1Renderer.h"

@implementation ES1Renderer

// Create an ES 1.1 context
- (ES1Renderer*) init
{
	if (self = [super init])
	{
		m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!m_context || ![EAGLContext setCurrentContext:m_context])
		{
            [self release];
            return nil;
        }
		
		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffersOES(1, &m_defaultFramebuffer);
		glGenRenderbuffersOES(1, &m_colorRenderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_defaultFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_colorRenderbuffer);
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, m_colorRenderbuffer);
		
		//for ( unsigned int i = 0; i < 10; i++ )
		//{
		//	NSString * numberString = [NSString stringWithFormat:@"%u", i];
		//	m_numberTextures[i] = [[Texture2D alloc] initWithString:numberString dimensions:CGSizeMake(1, 1) alignment:UITextAlignmentCenter fontName:@"Arial" fontSize:1];
		//}
		
	}
	
	return self;
}


- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{	
	// Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_colorRenderbuffer);
    [m_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &m_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &m_backingHeight);
	
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void) dealloc
{
	// Tear down GL
	if (m_defaultFramebuffer)
	{
		glDeleteFramebuffersOES(1, &m_defaultFramebuffer);
		m_defaultFramebuffer = 0;
	}
	
	if (m_colorRenderbuffer)
	{
		glDeleteRenderbuffersOES(1, &m_colorRenderbuffer);
		m_colorRenderbuffer = 0;
	}
	
	// Tear down context
	if ([EAGLContext currentContext] == m_context)
        [EAGLContext setCurrentContext:nil];
	
	[m_context release];
	m_context = nil;
	
	[super dealloc];
}

- (void) renderFromObject
{
	
	[EAGLContext setCurrentContext:m_context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_defaultFramebuffer);
    glViewport(0, 0, m_backingWidth, m_backingHeight);

	// Have the object render its contents
	[m_renderObject render];
	
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_colorRenderbuffer);
    [m_context presentRenderbuffer:GL_RENDERBUFFER_OES];

}



@end
