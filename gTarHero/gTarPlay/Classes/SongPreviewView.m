//
//  SongPreviewView.m
//  gTarPlay
//
//  Created by Marty Greenia on 10/28/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

#import "SongPreviewView.h"

#import <gTarAppCore/AppCore.h>
#import <gTarAppCore/NSMeasure.h>
#import <gTarAppCore/NSNote.h>
#import <gTarAppCore/NSSongModel.h>
#import <gTarAppCore/NSSong.h>

#import "gTarColors.h"

#define PIXELS_PER_BEAT_MIN 12.0

#define SPOT_WIDTH 5.5
#define SPOT_HEIGHT 5.5
#define LINE_WIDTH 0.5

@implementation SongPreviewView

- (id)initWithFrame:(CGRect)frame andSongModel:(NSSongModel*)songModel
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
        m_songModel = [songModel retain];
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor blackColor];
        
        // content view
        UIImage * content = [self drawContentImage];
        
        m_contentView = [[UIImageView alloc] initWithImage:content];
        m_contentView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:m_contentView];
        
        // foreground view
        UIImage * foreground = [self drawForegroundImage];
        
        m_foregroundView = [[UIImageView alloc] initWithImage:foreground];
        m_foregroundView.backgroundColor = [UIColor clearColor];    
        
        [self addSubview:m_foregroundView];
        
        // Order them appropriately
        [self sendSubviewToBack:m_contentView];
        [self bringSubviewToFront:m_foregroundView];
        
//        [self toggleGradients];
        
    }
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        // Initialization code
    }
    
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    
    [m_contentView release];
    [m_foregroundView release];
    
    [m_songModel release];
    
    [super dealloc];
    
}

- (UIImage*)drawContentImage
{
    
    NSArray * measureArray = m_songModel.m_song.m_measures;
    NSArray * noteArray = [m_songModel.m_song getSortedNotes];
        
    CGSize size = self.frame.size;
    
    CGFloat pixelsPerBeat = size.width / m_songModel.m_lengthBeats;
    
    if ( pixelsPerBeat > PIXELS_PER_BEAT_MIN )
    {
        // keep the same size
    }
    else
    {
        size.width = m_songModel.m_lengthBeats * PIXELS_PER_BEAT_MIN;
    }
    
    m_contentSize = size;
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
	
	// draw the measure lines first so they are on the bottom
	CGContextSetRGBStrokeColor(contextRef, 255, 255, 0, 1);
	CGContextSetLineWidth(contextRef, LINE_WIDTH);
    
    for ( NSMeasure * measure in measureArray )
    {
		
		CGFloat beat = measure.m_startBeat;
		
		CGFloat x = [self convertToBeatCoords:beat];
		
		CGContextMoveToPoint(contextRef, x, 0);
		CGContextAddLineToPoint(contextRef, x, size.height);
		CGContextStrokePath(contextRef);
		
		// draw the last measure line
        if ( [measureArray lastObject] == measure )
		{
			beat = measure.m_startBeat + measure.m_beatCount;
			
			x = [self convertToBeatCoords:beat];
			
			CGContextMoveToPoint(contextRef, x, 0);
			CGContextAddLineToPoint(contextRef, x, size.height);
			CGContextStrokePath(contextRef);
		}			
		
	}
    
	// draw all the notes
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 0, 1);
	CGContextSetLineWidth(contextRef, LINE_WIDTH);
    
    for ( NSNote * note in noteArray )
    {
        
		CGFloat beat = note.m_absoluteBeatStart;
		char str = note.m_string;
		
		unsigned char * strColor = g_stringColors[str - 1];
		
		CGFloat x = [self convertToBeatCoords:beat];
		CGFloat y = [self convertToStringCoords:str];
        
		CGContextSetRGBFillColor(contextRef,
								 ((CGFloat)strColor[0]/255.0),
								 ((CGFloat)strColor[1]/255.0), 
								 ((CGFloat)strColor[2]/255.0), 1);
		
		CGContextFillRect(contextRef, CGRectMake( x-SPOT_WIDTH/2, y-SPOT_HEIGHT/2, SPOT_WIDTH, SPOT_HEIGHT));
		CGContextStrokeRect(contextRef, CGRectMake( x-SPOT_WIDTH/2, y-SPOT_HEIGHT/2, SPOT_WIDTH, SPOT_HEIGHT));
        
	}
	
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;

}

- (UIImage*)drawForegroundImage
{
    
    CGSize foregroundSize = CGSizeMake( 4.0, m_contentSize.height );
    
    UIGraphicsBeginImageContext(foregroundSize);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
	CGContextSetRGBStrokeColor(contextRef, 255, 0, 0, 1);
	CGContextSetLineWidth(contextRef, 4.0);
	
	// Draw a single line from top to bottom
	CGContextMoveToPoint(contextRef, 0, 0);
	CGContextAddLineToPoint(contextRef, 0, m_contentSize.height);
	CGContextStrokePath(contextRef);

    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;

}

- (void)updateView
{
        
    CGFloat percentage = m_songModel.m_percentageComplete;
    
    // content
    CGFloat shiftContent = (m_contentView.frame.size.width - self.frame.size.width) * percentage;
    
    m_contentView.transform = CGAffineTransformMakeTranslation( -shiftContent, 0);
    
    // foreground
    CGFloat shiftForeground = self.frame.size.width * percentage;
    
    m_foregroundView.transform = CGAffineTransformMakeTranslation( shiftForeground, 0);
    
}

- (CGFloat)convertToStringCoords:(char)str
{
	
	CGFloat height = m_contentSize.height - SPOT_HEIGHT;
	
	CGFloat heightPerString = height / (GTAR_GUITAR_STRING_COUNT-1);
	
	// reverse the string order
	return m_contentSize.height - ((str-1) * heightPerString + SPOT_HEIGHT/2);
	
}

// This can be used to get the current beat location.
- (CGFloat)convertToBeatCoords:(CGFloat)beat
{
    
	CGFloat width = m_contentSize.width - SPOT_WIDTH;
    
    CGFloat percentComplete = beat / m_songModel.m_lengthBeats;
	
	return percentComplete * width + SPOT_WIDTH/2;
	
}

- (void)toggleGradients
{
    
    if ( m_gradientLeft || m_gradientRight )
    {
        
        [m_gradientLeft removeFromSuperview];
        [m_gradientRight removeFromSuperview];
        [m_gradientLeft release];
        [m_gradientRight release];
        
        m_gradientLeft = nil;
        m_gradientRight = nil;
        
    }
    else
    {
        
        m_gradientLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GradientL.png"]];
        m_gradientRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GradientR.png"]];
        
        m_gradientLeft.frame = CGRectMake( 0, 0, self.frame.size.height, self.frame.size.height);
        m_gradientRight.frame = CGRectMake( self.frame.size.width-self.frame.size.height, 0, 
                                            self.frame.size.height, self.frame.size.height);
        
        [self addSubview:m_gradientLeft];
        [self addSubview:m_gradientRight];
        
        [self bringSubviewToFront:m_gradientLeft];
        [self bringSubviewToFront:m_gradientRight];
        
    }
    
}
@end
