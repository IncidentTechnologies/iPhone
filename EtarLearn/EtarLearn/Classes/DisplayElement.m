//
//  DisplayElement.m
//  EtarLearn
//
//  Created by Marty Greenia on 10/4/10.
//  Copyright 2010 Microsoft. All rights reserved.
//

#import "DisplayElement.h"


@implementation DisplayElement

@synthesize m_type;
//@synthesize m_color;
@synthesize m_start;
@synthesize m_length;
@synthesize m_text;

- (void)setColor:(CGFloat*)color
{
	m_color[0] = color[0];
	m_color[1] = color[1];
	m_color[2] = color[2];
	m_color[3] = color[3];
}

- (CGFloat*)getColor
{
	return m_color;
}

- (void)setTextColor:(CGFloat*)color
{
	m_textColor[0] = color[0];
	m_textColor[1] = color[1];
	m_textColor[2] = color[2];
	m_textColor[3] = color[3];
}

- (CGFloat*)getTextColor
{
	return m_textColor;
}

@end
