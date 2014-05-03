
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import <QuartzCore/QuartzCore.h>

#import "ViewRenderer.h"

@interface ES1Renderer : ViewRenderer
{

	EAGLContext * m_context;
	
	// The pixel dimensions of the CAEAGLLayer
	GLint m_backingWidth;
	GLint m_backingHeight;
	
	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint m_defaultFramebuffer, m_colorRenderbuffer;	

}

@property (nonatomic, readonly) GLint m_backingWidth;
@property (nonatomic, readonly) GLint m_backingHeight;

- (BOOL)resizeFromLayer:(CAEAGLLayer*)layer;

@end
