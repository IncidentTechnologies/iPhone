
#import "ES1Renderer.h"

@implementation ES1Renderer

@synthesize m_backingWidth, m_backingHeight;

// Create an ES 1.1 context
- (ES1Renderer*)init
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
		
	}
	
	return self;
}

- (void)dealloc
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


- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
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
    else 
    {
        NSLog(@"Created complete framebuffer object");
    }
    
    return YES;
}



@end
