

#import <QuartzCore/QuartzCore.h>

@interface ViewRenderer : NSObject
{
	
}

// Pure Virtual -- is there any syntax for this?
- (void)render;
- (BOOL)resizeFromLayer:(CALayer *)layer;

@end


