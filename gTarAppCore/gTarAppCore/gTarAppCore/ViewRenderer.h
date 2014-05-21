

#import <QuartzCore/QuartzCore.h>

@interface ViewRenderer : NSObject
{
	
}

// Pure Virtual -- is there any syntax for this?
- (void)render;
- (void)renderWithHighlights:(BOOL)highlight fretOne:(BOOL)fretOne fretTwo:(BOOL)fretTwo fretThree:(BOOL)fretThree;
- (BOOL)resizeFromLayer:(CALayer *)layer;

@end


