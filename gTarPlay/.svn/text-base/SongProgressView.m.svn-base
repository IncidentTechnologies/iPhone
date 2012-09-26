//
//  SongProgessView.m
//  gTarPlay
//
//  Created by Marty Greenia on 8/10/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongProgressView.h"

#import "gTarColors.h"

#import <NSNote.h>
#import <NSMeasure.h>

#define SPOT_WIDTH 10
#define SPOT_HEIGHT (SPOT_WIDTH / 3.0)

@implementation SongProgressView

@synthesize m_currentBeat;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
    
}

- (void)dealloc
{
    [m_noteArray release];
    [m_measureArray release];
    
    [super dealloc];
}

- (void)setNoteArray:(NSArray*)noteArray
{
	m_noteArray = [noteArray retain];
}

- (void)setMeasureArray:(NSArray*)measureArray
{
	m_measureArray = [measureArray retain];
}

- (void)drawRect:(CGRect)rect
{
    
	if ( m_noteArray == nil )
	{
		return;
	}
	
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	// draw the measure lines first so they are on the bottom
	CGContextSetRGBStrokeColor(contextRef, 255, 255, 0, 1);
	CGContextSetLineWidth(contextRef, 1.0);
	
    for ( NSMeasure * measure in m_measureArray )
    {
		
		CGFloat beat = measure.m_startBeat;
		
		CGFloat x = [self convertToBeatCoordsScaled:beat];
		
		CGContextMoveToPoint(contextRef, x, 0);
		CGContextAddLineToPoint(contextRef, x, self.frame.size.height);
		CGContextStrokePath(contextRef);
		
		// draw the last measure line
        if ( [m_measureArray lastObject] == measure )
		{
			beat = measure.m_startBeat + measure.m_beatCount;
			
			x = [self convertToBeatCoordsScaled:beat];
			
			CGContextMoveToPoint(contextRef, x, 0);
			CGContextAddLineToPoint(contextRef, x, self.frame.size.height);
			CGContextStrokePath(contextRef);
		}			
		
	}

	
	// draw all the notes
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1);
	CGContextSetLineWidth(contextRef, 1.0);
    
    for ( NSNote * note in m_noteArray )
    {

		CGFloat beat = note.m_absoluteBeatStart;
		char str = note.m_string;
		
		unsigned char * strColor = g_stringColors[str - 1];
		
		CGFloat x = [self convertToBeatCoordsScaled:beat];
		CGFloat y = [self convertToStringCoords:str];
        
		CGContextSetRGBFillColor(contextRef,
								 ((CGFloat)strColor[0]/255.0),
								 ((CGFloat)strColor[1]/255.0), 
								 ((CGFloat)strColor[2]/255.0), 1);
		
		//CGContextSetRGBStrokeColor(contextRef, 0, 0, 255, 1);
        
		//CGContextFillEllipseInRect(contextRef, CGRectMake( x-SPOT_HEIGHT/2, y-SPOT_HEIGHT/2, SPOT_HEIGHT, SPOT_HEIGHT));
		CGContextFillRect(contextRef, CGRectMake( x-SPOT_WIDTH/2, y-SPOT_HEIGHT/2, SPOT_WIDTH, SPOT_HEIGHT));
		CGContextStrokeRect(contextRef, CGRectMake( x-SPOT_WIDTH/2, y-SPOT_HEIGHT/2, SPOT_WIDTH, SPOT_HEIGHT));
		//CGContextStrokeEllipseInRect(contextRef, CGRectMake(0, 0, 25, 25));
        
	}
	
    
	// draw the seek line
	CGFloat seekLine = [self convertToBeatCoords:m_currentBeat];
	CGContextSetRGBStrokeColor(contextRef, 255, 0, 0, 1);
	CGContextSetLineWidth(contextRef, 2.0);
	
	// Draw a single line from top to bottom
	CGContextMoveToPoint(contextRef, seekLine, 0);
	CGContextAddLineToPoint(contextRef, seekLine, self.frame.size.height);
	CGContextStrokePath(contextRef);
	
}

- (CGFloat)convertToStringCoords:(char)str
{
	
	CGFloat height = self.frame.size.height - SPOT_HEIGHT;
	
	CGFloat heightPerString = height / (GTAR_GUITAR_STRING_COUNT+1);
	
	// reverse the string order
	return self.frame.size.height - (SPOT_HEIGHT/2 + ((str+1)*heightPerString));
	
}

// This can be used to get the current beat location.
- (CGFloat)convertToBeatCoords:(CGFloat)beat
{
    
	CGFloat width = self.frame.size.width - SPOT_WIDTH;
	
    NSNote * lastNote = [m_noteArray lastObject];
	
	CGFloat beatMax = lastNote.m_absoluteBeatStart;
    
	CGFloat percentComplete = (beat / beatMax);
	
	return SPOT_WIDTH/2 + percentComplete * width;
	
}

- (CGFloat)convertToBeatCoordsScaled:(CGFloat)beat
{
	
	CGFloat width = self.frame.size.width - SPOT_WIDTH;
	
    NSNote * lastNote = [m_noteArray lastObject];
	
	CGFloat beatMax = lastNote.m_absoluteBeatStart;
	
	CGFloat percentComplete = (beat / beatMax);
    
	CGFloat windowMax = 24;
	
	if ( windowMax >= beatMax )
	{
		// stretch to fill the window
		return SPOT_WIDTH/2 + (percentComplete * width);
        
	}
	else 
	{
		// only show a partial view based on the window size
		CGFloat beatWidth = (beatMax / windowMax) * width;
		
		CGFloat excessWidth = beatWidth - width;
		CGFloat translation = (m_currentBeat / beatMax) * excessWidth;
		
		//return percentComplete * width - translation;
		return SPOT_WIDTH/2 + (percentComplete * beatWidth) - translation;
		
	}

}


@end
