//
//  JamPad.m
//  gTar
//
//  Created by Marty Greenia on 2/16/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "JamPad.h"

#import <UIKit/UIKit.h>

@implementation JamPad

@synthesize m_currentDiscretizedPosition;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
	if ( self )
	{
		[self initJamPad];
	}
	
	return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
	{
		[self initJamPad];
	}
    
	return self;
    
}

- (void)initJamPad
{
	
	m_currentDiscretizedPosition.x = -1;
	m_currentDiscretizedPosition.y = -1;
	
	[m_slider setHidden:YES];
	
	double ledWidth = self.frame.size.width / JAM_PAD_WIDTH;
	double ledHeight = self.frame.size.height / JAM_PAD_HEIGHT;
	
	for ( unsigned int h = 0; h < JAM_PAD_HEIGHT; h++ )
	{
		for ( unsigned int w = 0; w < JAM_PAD_WIDTH; w++ )
		{
			CGRect fr = CGRectMake( w * ledWidth, h * ledHeight, ledWidth, ledHeight);
			
            NSInteger offset = 2;
            
            UIView *view = [[UIView alloc] initWithFrame:fr];
            view.backgroundColor = [UIColor colorWithRed:(50/255.0) green:(59/255.0) blue:(66/255.0) alpha:1.0];
            UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(offset, offset, ledWidth - 2*offset, ledHeight - 2*offset)];
            innerView.backgroundColor = [UIColor colorWithRed:(77/255.0) green:(91/255.0) blue:(100/255.0) alpha:1.0];
            [view addSubview:innerView];
			m_ledOffGrid[h][w] = view;
			
			[self addSubview:view];
			
			view = [[UIView alloc] initWithFrame:fr];
            view.backgroundColor = [UIColor colorWithRed:(50/255.0) green:(59/255.0) blue:(66/255.0) alpha:1.0];
            innerView = [[UIView alloc] initWithFrame:CGRectMake(offset, offset, ledWidth - 2*offset, ledHeight - 2*offset)];
            innerView.backgroundColor = [UIColor colorWithRed:(1/255.0) green:(161/255.0) blue:(223/255.0) alpha:1.0];
            [view addSubview:innerView];
			view.alpha = 0.0;
			m_ledOnGrid[h][w] = view;
			
			[self insertSubview:view aboveSubview:m_ledOffGrid[h][w]];
		}
		
	}
	
}

	
- (void)dealloc
{

	for ( unsigned int h = 0; h < JAM_PAD_HEIGHT; h++ )
	{
		for ( unsigned int w = 0; w < JAM_PAD_WIDTH; w++ )
		{

			UIView * image;
			image = m_ledOffGrid[h][w];
			[image removeFromSuperview];
			[image release];
			
			image = m_ledOnGrid[h][w];
			[image removeFromSuperview];
			[image release];
			
		}
		
	}
	
	[m_ledOff release];
	[m_ledOn release];
	
	[super dealloc];
}

- (void)setCurrentPosition:(CGPoint)point
{

	double width = self.frame.size.width;
	double height = self.frame.size.height;

	NSInteger widthIncrements = (point.x / width) * JAM_PAD_WIDTH;
	NSInteger heightIncrements = (point.y / height) * JAM_PAD_HEIGHT;
	
	if ( widthIncrements < 0 )
	{
		widthIncrements = 0;
	}
	if ( widthIncrements > (JAM_PAD_WIDTH - 1) )
	{
		widthIncrements = (JAM_PAD_WIDTH - 1);
	}
	if ( heightIncrements < 0 )
	{
		heightIncrements = 0;
	}
	if ( heightIncrements > (JAM_PAD_HEIGHT - 1) )
	{
		heightIncrements = (JAM_PAD_HEIGHT - 1);
	}
	
	// only change the discreet pos / animationm if it changes
	if ( widthIncrements != m_currentDiscretizedPosition.x ||
		heightIncrements != m_currentDiscretizedPosition.y )
	{

		CGPoint newPosition = CGPointMake(widthIncrements, heightIncrements);
		[self moveSliderToPosition:newPosition];
		
		[self clearSliderFromPosition:m_currentDiscretizedPosition];
		m_currentDiscretizedPosition = newPosition;
	}
		
	// update the specific location regardless
	m_currentPosition = point;

}

- (void)turnOffLedWidth:(NSInteger)width andHeight:(NSInteger)height
{
	
	m_ledRefCount[height][width]--;

	// if last decrement ...
	if ( m_ledRefCount[height][width] == 0 )
	{
		UIView * imageOn = m_ledOnGrid[height][width];
		UIView * imageOff = m_ledOffGrid[height][width];
	
		[UIImageView beginAnimations:nil context:NULL];
		[UIImageView setAnimationDuration:0.5f];
	
		imageOn.alpha = 0.0;
		imageOff.alpha = 1.0;
	
		[UIImageView commitAnimations];
	}
}

- (void)turnOnLedWidth:(NSInteger)width andHeight:(NSInteger)height
{
	
	m_ledRefCount[height][width]++;
	
	// if this is the first increment..
	if ( m_ledRefCount[height][width] == 1 )
	{
		UIView * imageOn = m_ledOnGrid[height][width];
		UIView * imageOff = m_ledOffGrid[height][width];
        
//		[UIImageView beginAnimations:nil context:NULL];
//		[UIImageView setAnimationDuration:0.5f];
        
		imageOn.alpha = 1.0;
		imageOff.alpha = 0.0;
	
//		[UIImageView commitAnimations];
	}
	
}

- (void)changeHalo:(BOOL)on atPosition:(CGPoint)position
{
	//UIImageView * image = m_ledOnGrid[(unsigned int)m_currentDiscretizedPosition.y][(unsigned int)m_currentDiscretizedPosition.x];
	NSInteger wIndex;
	NSInteger hIndex;
	
	wIndex = position.x - 1;
	hIndex = position.y;
	
	if ( wIndex >= 0 && wIndex < JAM_PAD_WIDTH &&
		hIndex >= 0 && hIndex < JAM_PAD_HEIGHT )
	{
		if ( on == YES )
		{
			[self turnOnLedWidth:wIndex andHeight:hIndex];
		}
		else
		{
			[self turnOffLedWidth:wIndex andHeight:hIndex];
		}
	}
	
	wIndex = position.x + 1;
	hIndex = position.y;
	
	if ( wIndex >= 0 && wIndex < JAM_PAD_WIDTH &&
		hIndex >= 0 && hIndex < JAM_PAD_HEIGHT )
	{
		if ( on == YES )
		{
			[self turnOnLedWidth:wIndex andHeight:hIndex];
		}
		else
		{
			[self turnOffLedWidth:wIndex andHeight:hIndex];
		}
	}
	
	wIndex = position.x;
	hIndex = position.y + 1;
	
	if ( wIndex >= 0 && wIndex < JAM_PAD_WIDTH &&
		hIndex >= 0 && hIndex < JAM_PAD_HEIGHT )
	{
		if ( on == YES )
		{
			[self turnOnLedWidth:wIndex andHeight:hIndex];
		}
		else
		{
			[self turnOffLedWidth:wIndex andHeight:hIndex];
		}
	}
	
	wIndex = position.x;
	hIndex = position.y - 1;
	
	if ( wIndex >= 0 && wIndex < JAM_PAD_WIDTH &&
		hIndex >= 0 && hIndex < JAM_PAD_HEIGHT )
	{
		if ( on == YES )
		{
			[self turnOnLedWidth:wIndex andHeight:hIndex];
		}
		else
		{
			[self turnOffLedWidth:wIndex andHeight:hIndex];
		}
	}

}

- (void)clearHaloFromPosition:(CGPoint)position
{
	[self changeHalo:NO atPosition:position];
}

- (void)moveHaloToPosition:(CGPoint)position
{
	[self changeHalo:YES atPosition:position];
}

- (void)clearSliderFromPosition:(CGPoint)position
{
	// turn off the required leds
	if ( position.x < 0 ||
		position.y < 0 )
	{
		return;
	}

	NSInteger w = position.x;
	NSInteger h = position.y;

	[self turnOffLedWidth:w andHeight:h];
	[self clearHaloFromPosition:position];
}

- (void)moveSliderToPosition:(CGPoint)position
{
	// light up the required leds
	NSInteger w = position.x;
	NSInteger h = position.y;

	[self turnOnLedWidth:w andHeight:h];
	[self moveHaloToPosition:position];
}

@end
