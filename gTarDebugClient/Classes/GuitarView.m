//
//  GuitarView.m
//  gTarDebugClient
//
//  Created by wuda on 10/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GuitarView.h"


@implementation GuitarView

@synthesize m_ginput, m_goutput, m_debugger, m_connectionStatus;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code

	}
	
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    // Drawing code
	CGFloat blueColor[4] = {0.0f, 0.0f, 1.0f, 1.0f};
	CGFloat greenColor[4] = {0.0f, 1.0f, 0.0f, 1.0f};
	CGFloat redColor[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	CGFloat blackColor[4] = {0.0f, 0.0f, 0.0f, 1.0f};
	
	for ( unsigned int str = 0; str < 6; str++ )
	{
		for ( unsigned int fret = 0; fret < 13; fret++ )
		{
			
			CGPoint point;
			point.x = GUITAR_VIEW_STRING_SPACING * str + GUITAR_VIEW_STRING_SPACING/2;
			point.y = GUITAR_VIEW_FRET_SPACING * fret + GUITAR_VIEW_FRET_SPACING/2;
			
			int index = [self indexFromString:str andFret:fret];
			
			if ( m_goutput.notesOn[ index ] == 1 )
			{
				[self drawCircleAt:point withColor:redColor];
			} else if ( m_goutput.fretDown[ index ] == 1 )
			{
				[self drawCircleAt:point withColor:blueColor];
			} else if ( m_ginput.ledsOn[ index ] == 1 )
			{
				[self drawCircleAt:point withColor:greenColor];
			}
			else
			{
				[self drawCircleAt:point withColor:blackColor];
			}

				
		}
	}
}

- (void)drawCircleAt:(CGPoint)point withColor:(CGFloat[])color
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColor(context, color);
	CGContextSetStrokeColor(context, color);
	
	// Draw a circle (filled)
	CGContextFillEllipseInRect(context, CGRectMake( point.x - 10, point.y - 10, 20, 20 ));
	
	// Draw a circle (border only)
	CGContextStrokeEllipseInRect(context, CGRectMake( point.x - 10, point.y - 10, 20, 20 ));
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark  -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSArray *ts = [touches allObjects];
	
	int numTouches = [touches count];
	
	UITouch * t;

	for ( unsigned int i = 0; i < numTouches; i++ )
	{
		t = [ts objectAtIndex:i];
	
		if ( m_debugger.m_peerStatus == kServer )
		{
			CGPoint point = [t locationInView:self];
			int closestIndex = [self findClosestIndexToPoint:point];
			
			[m_debugger ledOnString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];
		}
		else if ( m_debugger.m_peerStatus == kClient )
		{
			CGPoint point = [t locationInView:self];
			int closestIndex = [self findClosestIndexToPoint:point];
			
			[m_debugger fretDownString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];
			m_goutput.fretDown[ closestIndex ] = 1;
		}

	}

	[self stateChanged];
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	NSArray *ts = [touches allObjects];
	
	int numTouches = [touches count];
	
	UITouch * t;

	for ( unsigned int i = 0; i < numTouches; i++ )
	{
		t = [ts objectAtIndex:i];

		if ( m_debugger.m_peerStatus == kServer )
		{
			// Turn off old LED, on new LED
			CGPoint point = [t previousLocationInView:self];
			int previousClosestIndex = [self findClosestIndexToPoint:point];

			[m_debugger ledOffString:[self stringFromIndex:previousClosestIndex] andFret:[self fretFromIndex:previousClosestIndex]];

			
			point = [t locationInView:self];
			int closestIndex = [self findClosestIndexToPoint:point];
			
			[m_debugger ledOnString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];
			
			if ( previousClosestIndex != closestIndex )
			{
				[m_debugger noteOffString:[self stringFromIndex:previousClosestIndex] andFret:[self fretFromIndex:previousClosestIndex]];

			}
		}
		else if ( m_debugger.m_peerStatus == kClient )
		{
			// Toggle the frets
			CGPoint point = [t previousLocationInView:self];
			int previousClosestIndex = [self findClosestIndexToPoint:point];

			[m_debugger fretUpString:[self stringFromIndex:previousClosestIndex] andFret:[self fretFromIndex:previousClosestIndex]];
			m_goutput.fretDown[ previousClosestIndex ] = 0;

			
			point = [t locationInView:self];
			int closestIndex = [self findClosestIndexToPoint:point];
			
			[m_debugger fretDownString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];
			m_goutput.fretDown[ closestIndex ] = 1;

			
			// Also, if the move leaves a note, turn that note off
			if ( previousClosestIndex != closestIndex )
			{
				[m_debugger noteOffString:[self stringFromIndex:previousClosestIndex] andFret:[self fretFromIndex:previousClosestIndex]];
				m_goutput.notesOn[ previousClosestIndex ] = 0;

			}
		}
		
	}
	
	[self stateChanged];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSArray *ts = [touches allObjects];
	
	int numTouches = [touches count];
	
	UITouch * t;
	
	for ( unsigned int i = 0; i < numTouches; i++ )
	{
		t = [ts objectAtIndex:i];

		if ( m_debugger.m_peerStatus == kServer )
		{
			// Turn off LED
			CGPoint point = [t previousLocationInView:self];
			
			int closestIndex = [self findClosestIndexToPoint:point];
			//m_ginput.ledsOn[ closestIndex ] = 0;
			[m_debugger ledOffString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];

		}
		else if ( m_debugger.m_peerStatus == kClient )
		{
			CGPoint point = [t previousLocationInView:self];
			int closestIndex = [self findClosestIndexToPoint:point];

			[m_debugger fretUpString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];
			[m_debugger noteOffString:[self stringFromIndex:closestIndex] andFret:[self fretFromIndex:closestIndex]];
			m_goutput.fretDown[ closestIndex ] = 0;
			m_goutput.notesOn[ closestIndex ] = 0;

		}
	}	

	[self stateChanged];
}

- (int)findClosestIndexToPoint:(CGPoint)point
{
	
	int str = point.x / GUITAR_VIEW_STRING_SPACING;
	int fret = point.y / GUITAR_VIEW_FRET_SPACING;
	
	return [self indexFromString:str andFret:fret];
	
}

- (int)stringFromIndex:(int)index
{
	return index / 13;
}

- (int)fretFromIndex:(int)index
{
	return index % 13;
}

- (int)indexFromString:(int)str andFret:(int)fret
{	
	return str * 13 + fret;
}

- (void)stateChanged
{
	if ( m_debugger.m_peerStatus == kServer )
	{
		[self serverStateChanged];
	}
	else if ( m_debugger.m_peerStatus == kClient )
	{
		[self clientStateChanged];
	}
}

- (void)serverStateChanged
{
	[self setNeedsDisplay];
	
	[m_debugger flushState];
}

- (void)clientStateChanged
{
	[self setNeedsDisplay];

	[m_debugger flushState];
}

#pragma mark -
#pragma mark Server/Client debug protocol

- (void)clientRecvGuitarInput:(GuitarInput*)ginput
{
	// LEDs are turning on.
	memcpy( &m_ginput, ginput, sizeof(GuitarInput));
	
	[self setNeedsDisplay];
}

-(void)clientEndpointDisconnected
{
	NSString * status = [[NSString alloc] initWithFormat:@"Cli:Discon"];
	[m_connectionStatus setText:status];
	[status release];
}

-(void)clientEndpointConnected
{
	NSString * status = [[NSString alloc] initWithFormat:@"Cli:Conn"];
	[m_connectionStatus setText:status];
	[status release];
}

-(void)serverRecvGuitarOutput:(GuitarOutput*)goutput
{

	// This is lame, but whatever, this is the only place
	// where we use audio.
	if ( m_audioController == nil )
	{
		m_audioController = [[AudioController alloc] init];
	
		[m_audioController SetAttentuation:0.985f];
		[m_audioController initializeAUGraph:600.0f withWaveform:3];
		[m_audioController startAUGraph];
	
	}
	
	for ( unsigned int str = 0; str < 6; str++ )
	{
		for ( unsigned int fret = 0; fret < 13; fret++ )
		{
			int index = [self indexFromString:str andFret:fret];
			
			if ( goutput->notesOn[ index ] == 1 && 
				 m_goutput.notesOn[ index ] == 0 )
			{
				[m_audioController PluckStringFret:str atFret:fret];
			}
		}
	}
	
	// Received some note plays / fret downs
	memcpy( &m_goutput, goutput, sizeof(GuitarOutput));
	
	[self setNeedsDisplay];
	
}

-(void)serverEndpointDisconnected
{
	NSString * status = [[NSString alloc] initWithFormat:@"Srv:Discon"];
	[m_connectionStatus setText:status];
	[status release];
}

-(void)serverEndpointConnected
{
	NSString * status = [[NSString alloc] initWithFormat:@"Srv:Conn"];
	[m_connectionStatus setText:status];
	[status release];
}

#pragma mark -
#pragma mark Button handling

-(IBAction)pluckButtonClicked
{

	memcpy( m_goutput.notesOn, m_goutput.fretDown, 78 );

	
	for ( unsigned int str = 0; str < 6; str++ )
	{
		for ( unsigned int fret = 0; fret < 13; fret++ )
		{
			int index = [self indexFromString:str andFret:fret];
			
			if ( m_goutput.fretDown[ index ] == 1 )
			{
				[m_debugger noteOnString:str andFret:fret];
			}
		}
	}
	
	
	[self stateChanged];
	
}
@end
