
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ViewRenderer.h"
#import "ES1Renderer.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{
	ViewRenderer * m_renderer;
}

@property (nonatomic, strong) ViewRenderer * m_renderer;

- (void)drawView;
- (void)drawViewWithHighlightsFretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree;
- (void)drawViewWithHighlights;
- (void)layoutSubviews;

@end
