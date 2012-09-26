/*
 
 File: EAGLView.m
 
 Abstract: The EAGLView class is a UIView subclass that renders OpenGL scene.
 If the current hardware supports OpenGL ES 2.0, it draws using OpenGL ES 2.0;
 otherwise it draws using OpenGL ES 1.1.
 
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

#import "EAGLView.h"
//#import "PlayController.h"

#import "ES1Renderer.h"
#import "ES2Renderer.h"

@implementation EAGLView

@synthesize m_renderer;
//@synthesize m_playController;
@synthesize m_displayMode;

EAGLViewDisplayMode g_eaglDisplayMode;

#pragma mark -
#pragma mark Basic object management

// You must implement this method

+ (Class) layerClass
{
	
	if ( g_eaglDisplayMode == DisplayModeCG )
	{
		return [super layerClass];
	}
	else if ( g_eaglDisplayMode == DisplayModeES )
	{
		return [CAEAGLLayer class];
	}

}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
	{
		if ( g_eaglDisplayMode == DisplayModeCG )
		{

		}
		else if ( g_eaglDisplayMode == DisplayModeES )
		{	
        // Get and init the layer
			CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
			eaglLayer.opaque = TRUE;

			eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
//                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
										[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];
		}
		// TODO: Get 2.0 rendering working
		
		//renderer = [[ES2Renderer alloc] init];
		
		//if (!renderer)
		{
			/*
			m_renderer = [[ES1Renderer alloc] init];
			
			if (!m_renderer)
			{
				[self release];
				return nil;
			}
//
			// For iPhone 3g / iOS 3.1.3-
			// For some reason, iPhone 4 / iOS 4.0+ don't need this.
			[self layoutSubviews];
			 */
		}
        
		
		//animating = FALSE;
		//displayLinkSupported = FALSE;
		//animationFrameInterval = 1;
		//displayLink = nil;
		//animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		//NSString *reqSysVer = @"3.1";
		//NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		//if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
		//	displayLinkSupported = TRUE;
    }
	
    return self;
}

- (IBAction)drawView
{

	if ( g_eaglDisplayMode == DisplayModeCG )
	{
		[self setNeedsDisplay];
	}
	else if ( g_eaglDisplayMode == DisplayModeES )
	{
		[m_renderer renderFromObject];
	}
	
}

- (void)drawRect:(CGRect)rect
{
    [m_renderer renderFromObject];	
	/*
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor (myContext, 1, 0, 0, 1);// 3
    CGContextFillRect (myContext, CGRectMake (0, 0, 200, 100 ));// 4
    CGContextSetRGBFillColor (myContext, 0, 0, 1, .5);// 5
    CGContextFillRect (myContext, CGRectMake (0, 0, 100, 200));// 6
	*/
}

- (void) layoutSubviews
{
	[m_renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView];
}
/*
- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}
*/
- (void) dealloc
{
    [m_renderer release];
	
    [super dealloc];
}

/*
- (void) initWithStringCount:(unsigned int)stringCount notes:(NoteArray*)noteArray andMeasures:(MeasureArray*)measureArray
{
	
	[renderer initSeekLine];
	
	[renderer convertStrings:stringCount];
	
	[renderer convertNoteArray:noteArray];
	
	[renderer convertMeasureArray:measureArray];
	
	[renderer render];
	
}

#pragma mark -
#pragma mark Draw request functions

- (void) drawAtBeat:(GLfloat)beat
{
	[renderer setCurrentBeat:beat];
	[renderer render];
}

- (void) drawAtBeatDelta:(GLfloat)beatDelta
{
	[renderer incrementCurrentBeat:beatDelta];
	[renderer render];
}

#pragma mark -
#pragma mark External input functions

- (void) setTargetNotes:(NoteArrayRange)arrayRange
{
	[renderer setTargetNotes:arrayRange];
}
*/
@end
