//
//  PlayControllerProgressView.m
//  gTar
//
//  Created by wuda on 1/17/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "PlayControllerProgressView.h"

#define SPOT_WIDTH 10
#define SPOT_HEIGHT (SPOT_WIDTH / 3.0)


@implementation PlayControllerProgressView

@synthesize m_currentBeat;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


- (void)setNoteArray:(NoteArray*)noteArray
{
	m_noteArray = noteArray;
}
- (void)setMeasureArray:(MeasureArray*)measureArray
{
	m_measureArray = measureArray;
}

- (void)drawRect:(CGRect)rect
{

	if ( m_noteArray == NULL )
	{
		return;
	}
	
	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	// draw the measure lines first so they are on the bottom
	CGContextSetRGBStrokeColor(contextRef, 255, 255, 0, 1);
	CGContextSetLineWidth(contextRef, 1.0);
	
	for ( unsigned int index = 0; index < m_measureArray->m_measureCount; index++ )
	{
		CMeasure * measure = &m_measureArray->m_measures[index];
		
		CGFloat beat = measure->m_startBeat;
		
		CGFloat x = [self convertToBeatCoordsScaled:beat];
		
		CGContextMoveToPoint(contextRef, x, 0);
		CGContextAddLineToPoint(contextRef, x, self.frame.size.height);
		CGContextStrokePath(contextRef);
		
		// draw the last measure line
		if ( index == (m_measureArray->m_measureCount - 1) )
		{
			beat = measure->m_startBeat + measure->m_beatCount;
			
			x = [self convertToBeatCoordsScaled:beat];
			
			CGContextMoveToPoint(contextRef, x, 0);
			CGContextAddLineToPoint(contextRef, x, self.frame.size.height);
			CGContextStrokePath(contextRef);
		}			
		
	}
		
	
	// draw all the notes
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1);
	CGContextSetLineWidth(contextRef, 1.0);

	for ( unsigned int index = 0; index < m_noteArray->m_noteCount; index++ )
	{
		CNote * note = &m_noteArray->m_notes[index];

		CGFloat beat = note->m_absoluteBeatStart;
		char str = note->m_string;
		
		unsigned char * strColor = g_stringColors[str];
		
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
	
	CNote * lastNote = &m_noteArray->m_notes[ m_noteArray->m_noteCount - 1];
	
	CGFloat beatMax = lastNote->m_absoluteBeatStart;

	CGFloat percentComplete = (beat / beatMax);
	
	return SPOT_WIDTH/2 + percentComplete * width;
	
}

- (CGFloat)convertToBeatCoordsScaled:(CGFloat)beat
{
	
	CGFloat width = self.frame.size.width - SPOT_WIDTH;
	
	CNote * lastNote = &m_noteArray->m_notes[ m_noteArray->m_noteCount - 1];
	
	CGFloat beatMax = lastNote->m_absoluteBeatStart;
	
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
