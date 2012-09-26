//
//  PlayTabView.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/1/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "EtarLearnPlayTabsView.h"
#import "DisplayElement.h"
#import "EtarLearnPlayTabsViewController.h"

#define LEFT_SCREEN_BUFFER_FLOAT 50.0

#define NOTE_BOUND_SIZE 30
#define NOTE_TEXT_SIZE 30
#define NOTE_TEXT_OFFSET 3

@implementation EtarLearnPlayTabsView

//@synthesize tabsVc;
@synthesize displayElements;
@synthesize pixelsHeight;
@synthesize pixelsWidth;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		pixelsWidth = 480;
		pixelsHeight = 260;
		
    }

    return self;
}
/*
- (void)updateDisplayElements:(NSArray*)displayElements
{
	toBeDisplayed = displayElements;
}
*/
- (void)updateDisplayElements:(NSArray*)elements
{
	// This needs to retain the object. For some reason this isn't 
	// happening as expected.
	displayElements = [elements retain];
}

//- (void)drawVerticalLineAt:(CGFloat)x withColor:(CGFloat[])color
- (void)drawVerticalLineAt:(CGFloat)x withColor:(CGFloat[])color andContext:(CGContextRef)context
{
//	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetStrokeColor(context, color);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, x, 0.0f);
	CGContextAddLineToPoint(context, x, pixelsHeight);
	CGContextStrokePath(context);
}

//- (void)drawHorizontalLineAt:(CGFloat)y withColor:(CGFloat[])color
- (void)drawHorizontalLineAt:(CGFloat)y withColor:(CGFloat[])color andContext:(CGContextRef)context
{
//	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColor(context, color);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0, y);
	CGContextAddLineToPoint(context, pixelsWidth, y);
	CGContextStrokePath(context);
}

- (void)drawRectAt:(CGPoint)point withColor:(CGFloat[])color andLength:(CGFloat)length
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColor(context, color);
	CGContextSetStrokeColor(context, color);
	
	CGRect rect = CGRectMake( point.x, point.y - NOTE_BOUND_SIZE/2, length, NOTE_BOUND_SIZE );

	// Draw a circle (filled)
	CGContextFillRect(context, rect);
	
	// Draw a circle (border only)
	CGContextStrokeRect(context, rect);
}

//- (void)drawCircleAt:(CGPoint)point withColor:(CGFloat[])color
- (void)drawCircleAt:(CGPoint)point withColor:(CGFloat[])color andContext:(CGContextRef)context 
{
//	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColor(context, color);
	CGContextSetStrokeColor(context, color);
	
	// Draw a circle (filled)
	CGContextFillEllipseInRect(context, CGRectMake( point.x - NOTE_BOUND_SIZE/2, point.y - NOTE_BOUND_SIZE/2, NOTE_BOUND_SIZE, NOTE_BOUND_SIZE ));
	
	// Draw a circle (border only)
//	CGContextStrokeEllipseInRect(context, CGRectMake( point.x - NOTE_BOUND_SIZE/2, point.y - NOTE_BOUND_SIZE/2, NOTE_BOUND_SIZE, NOTE_BOUND_SIZE ));
}

//- (void)drawText:(NSString*)text at:(CGPoint)point withColor:(CGFloat[])color
- (void)drawText:(NSString*)text at:(CGPoint)point withColor:(CGFloat[])color andContext:(CGContextRef)context
{
//	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColor(context, color);
	CGContextSetStrokeColor(context, color);
	
	// Draw text at a point
	//[text drawAtPoint:point withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
	CGPoint adjustedPoint;
//	adjustedPoint.x = point.x + NOTE_TEXT_OFFSET;
	adjustedPoint.x = point.x - NOTE_TEXT_SIZE/4 - 2;
	adjustedPoint.y = point.y - NOTE_TEXT_SIZE/2 - NOTE_TEXT_OFFSET;
	[text drawAtPoint:adjustedPoint withFont:[UIFont systemFontOfSize:NOTE_TEXT_SIZE]];

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

	pixelsWidth = 480;
	pixelsHeight = 260;

	// Drawing code
	/*
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat components[] = {0.0f, 0.0f, 0.0f, 0.5f, 0.0f};
	CGContextSetFillColor(context, components);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	CGPoint center;
	center.x = 0;
	center.y = 0;

	CGContextDrawRadialGradient(context, gradient, center, 0, center, (inkBlots[i].radius/2), 0);
*/
//	self.toBeDisplayed = tabsVc.toBeDisplayed;
	/*
	for ( NSInteger i = 0; i < [toBeDisplayed count]; i++ )
	{
		NSDictionary * displayElement = [toBeDisplayed objectAtIndex:i];
		
		NSString * type = [displayElement objectForKey:@"type"];
		
		if ( [type isEqualToString:@"currentline"] )
		{
			NSNumber * num = [displayElement objectForKey:@"x"];
			
			CGFloat color[4] = {1.0f, 0.0f, 0.0f, 1.0f};
			
			[self drawVerticalLineAt:[num floatValue] withColor:color];
			 
		}
		else if ( [type isEqualToString:@"stringline"] )
		{
			
			NSNumber * num = [displayElement objectForKey:@"y"];
			
			CGFloat color[4] = {1.0f, 1.0f, 1.0f, 1.0f};
			
			[self drawHorizontalLineAt:[num floatValue] withColor:color];
			
		}
		else if ( [type isEqualToString:@"measure"] )
		{
				
			NSNumber * num = [displayElement objectForKey:@"x"];
			
			CGFloat color[4] = {0.7f, 0.7f, 0.0f, 1.0f};

			[self drawVerticalLineAt:[num floatValue] withColor:color];

		}
		else if ( [type isEqualToString:@"beat"] )
		{
			
			NSNumber * num = [displayElement objectForKey:@"x"];
			
			CGFloat color[4] = {0.7f, 0.7f, 0.0f, 0.2f};
			
			[self drawVerticalLineAt:[num floatValue] withColor:color];
			
		}
		else if ( [type isEqualToString:@"note"] )
		{
			
			CGPoint point;

			point.x	= [[displayElement objectForKey:@"x"] floatValue];
			point.y	= [[displayElement objectForKey:@"y"] floatValue];
			
			CGFloat color[4] = {0.7f, 0.0f, 0.7f, 0.8f};
			
			[self drawCircleAt:point withColor:color];
			
		}
		
	}
	 */
	for ( NSInteger i = 0; i < [displayElements count]; i++ )
	{
		DisplayElement * element = [displayElements objectAtIndex:i];
		
		// TODO: Makes rendering faster on the 3G. Put a proper fix in production.
		// Clip any elemnts that are not visible.
		// Put a hacky 50 pixel buffer around the screen.
		if ( element.m_start.x < -50.0 || element.m_start.x >  (pixelsWidth+50.0) )
		{
			continue;
		}
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		switch ( element.m_type )
		{
			case TypeHorizontalLine:
			{
				//[self drawHorizontalLineAt:element.m_start.y withColor:[element getColor]];
				[self drawHorizontalLineAt:element.m_start.y withColor:[element getColor] andContext:context];
			} break;
			case TypeVerticalLine:
			{
				//[self drawVerticalLineAt:element.m_start.x withColor:[element getColor]];
				[self drawVerticalLineAt:element.m_start.x withColor:[element getColor] andContext:context];
			} break;
			case TypeNote:
			{
				// Add a 'shadow' under the note.
				//CGFloat color[4] = {1.0f, 1.0f, 1.0f, 0.7f};
				//[self drawRectAt:element.m_start withColor:color andLength:NOTE_BOUND_SIZE*1.5];

				// TODO: push the note clipping to the controller
				if ( YES )
//				if ( element.m_start.x >= LEFT_SCREEN_BUFFER_FLOAT )
				{
					// Draw the note itself.
					// TODO: Removing the rect drawing speeds up the 3G render speed...
					//[self drawRectAt:element.m_start withColor:[element getColor] andLength:element.m_length];
					//[self drawCircleAt:element.m_start withColor:[element getColor]];
					//[self drawText:element.m_text at:element.m_start withColor:[element getTextColor]];
					[self drawCircleAt:element.m_start withColor:[element getColor] andContext:context];
					[self drawText:element.m_text at:element.m_start withColor:[element getTextColor] andContext:context];
				}
				else
				{
					CGFloat	adjustedLength = element.m_length-(LEFT_SCREEN_BUFFER_FLOAT-element.m_start.x);
					if ( adjustedLength > 0 )
					{
						// Do some coord touchup to clip the note at the buffer lines
						CGPoint adjustedPoint;
						adjustedPoint.x = LEFT_SCREEN_BUFFER_FLOAT;
						adjustedPoint.y = element.m_start.y;
					
						[self drawRectAt:adjustedPoint withColor:[element getColor] andLength:adjustedLength];
				
					}
				}
				
			} break;
			case TypeGhostNote:
			{
				CGPoint adjustedPoint;
				adjustedPoint.x = 10;
				adjustedPoint.y = element.m_start.y;
				
				[self drawRectAt:element.m_start withColor:[element getColor] andLength:element.m_length];
				[self drawText:element.m_text at:adjustedPoint withColor:[element getTextColor] andContext:context];
				
			} break;
				
		}
	}
		  
}

- (void) initGestureRecognizer:(EtarLearnPlayTabsViewController*)controller
{
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:controller action:@selector(panGesture:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:controller];
    [self addGestureRecognizer:panGesture];
    [panGesture release];
}

- (void)dealloc {
    [super dealloc];
}


@end
