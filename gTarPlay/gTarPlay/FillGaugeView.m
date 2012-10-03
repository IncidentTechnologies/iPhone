//
//  FillGaugeView.m
//  gTar
//
//  Created by Marty Greenia on 1/28/11.
//  Copyright 2011 IncidentTech. All rights reserved.
//

#import "FillGaugeView.h"


@implementation FillGaugeView

@synthesize m_level1;
@synthesize m_level2;
@synthesize m_level3;
@synthesize m_level4;
@synthesize m_level5;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if ( self )
	{
        // Initialization code
		m_currentLevel = 0;
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

- (void)dealloc
{
    [super dealloc];
}

- (void)resetLevel
{
	m_currentLevel = 0;
	
	[self displayLevel];
}

- (void)increaseLevel
{

	m_currentLevel++;
	
	if ( m_currentLevel > MAX_LEVEL )
	{
		m_currentLevel = 1;
	}
	
	[self displayLevel];

}

- (void)setLevelToMax
{
	m_currentLevel = MAX_LEVEL;
	
	[self displayLevel];
}

- (void)setLevelWithRollover:(NSInteger)value
{

	if ( value == 0 )
	{
		m_currentLevel = 0;
	}
	else 
	{
		m_currentLevel = ((value-1) % MAX_LEVEL) + 1;
	}
	
	[self displayLevel];
	
}

- (void)displayLevel
{
	
	switch ( m_currentLevel )
	{
		case 5:
		{
			[m_level5 setHidden:NO];
			[m_level4 setHidden:NO];
			[m_level3 setHidden:NO];
			[m_level2 setHidden:NO];
			[m_level1 setHidden:NO];
		} break;
			
		case 4:
		{
			[m_level5 setHidden:YES];
			[m_level4 setHidden:NO];
			[m_level3 setHidden:NO];
			[m_level2 setHidden:NO];
			[m_level1 setHidden:NO];
		} break;

		case 3:
		{
			[m_level5 setHidden:YES];
			[m_level4 setHidden:YES];
			[m_level3 setHidden:NO];
			[m_level2 setHidden:NO];
			[m_level1 setHidden:NO];
		} break;
			
		case 2:
		{
			[m_level5 setHidden:YES];
			[m_level4 setHidden:YES];
			[m_level3 setHidden:YES];
			[m_level2 setHidden:NO];
			[m_level1 setHidden:NO];
		} break;
			
		case 1:
		{
			[m_level5 setHidden:YES];
			[m_level4 setHidden:YES];
			[m_level3 setHidden:YES];
			[m_level2 setHidden:YES];
			[m_level1 setHidden:NO];
		} break;

		case 0:
		default:
		{
			[m_level5 setHidden:YES];
			[m_level4 setHidden:YES];
			[m_level3 setHidden:YES];
			[m_level2 setHidden:YES];
			[m_level1 setHidden:YES];
		} break;
			
	}
			
}

@end
