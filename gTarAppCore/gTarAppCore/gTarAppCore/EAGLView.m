
#import "EAGLView.h"

@implementation EAGLView

@synthesize m_renderer;

#pragma mark -
#pragma mark Basic object management

// You must implement this method
+ (Class)layerClass
{
	// This looks kind of hacky but it is the apple support way to do it
	return [CAEAGLLayer class];
}

// The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{
    
    self = [super initWithCoder:coder];
    
    if ( self )
	{
		
        // Get and init the layer
		CAEAGLLayer * eaglLayer = (CAEAGLLayer*)self.layer;
        
		eaglLayer.opaque = TRUE;
		
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:FALSE],
										kEAGLDrawablePropertyRetainedBacking,
										kEAGLColorFormatRGB565,
										kEAGLDrawablePropertyColorFormat,
										nil];
		
		
    }
	
    return self;
    
}

- (void)dealloc
{
    
    [m_renderer release];
    
    [super dealloc];
    
}

- (void)drawView
{
    
    [m_renderer render];

}

- (void)drawViewWithHighlightsFretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree
{
    [m_renderer renderWithHighlights:YES fretOne:fretOne fretTwo:fretTwo fretThree:fretThree];
}

- (void)layoutSubviews
{
	
	[m_renderer resizeFromLayer:(CAEAGLLayer*)self.layer];	
	
}


@end
