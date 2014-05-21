//
//  Model.m
//  gTar
//
//  Created by wuda on 12/21/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "Model.h"

@implementation Model

@synthesize m_center;

- (id)initWithCenter:(CGPoint)center andColor:(GLubyte*)color andTexture:(Texture2D*)texture
{

    self = [super init];
    
	if ( self )
	{
		m_center = center;
		
		[self changeColor:color];
		
		m_texture = texture;
	}
	
	return self;
	
}


- (void)draw
{
	// This allows the texture to take on the color of the geometry
	glEnable(GL_COLOR_MATERIAL);
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
	
	[m_texture drawAtPoint:m_center];
	
	glDisable(GL_COLOR_MATERIAL);
	
}

- (void)drawAt:(CGPoint)point
{
	// This allows the texture to take on the color of the geometry
	glEnable(GL_COLOR_MATERIAL);
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
	
	[m_texture drawAtPoint:point];
	
	glDisable(GL_COLOR_MATERIAL);	
}

- (void)drawWithOffset:(CGPoint)offset
{
	// This allows the texture to take on the color of the geometry
	glEnable(GL_COLOR_MATERIAL);
	
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_color);
	
	CGPoint offsetPoint = CGPointMake( m_center.x + offset.x, m_center.y + offset.y );
	
	[m_texture drawAtPoint:offsetPoint];
	
	glDisable(GL_COLOR_MATERIAL);
}

- (void)changeColor:(GLubyte*)color
{
	m_color[0] = m_color[4] = m_color[8] = m_color[12] = color[0];
	m_color[1] = m_color[5] = m_color[9] = m_color[13] = color[1];
	m_color[2] = m_color[6] = m_color[10] = m_color[14] = color[2];
	m_color[3] = m_color[7] = m_color[11] = m_color[15] = color[3];
}	

- (void)changeOpacity:(GLubyte)opacity
{	
	m_color[3] = m_color[7] = m_color[11] = m_color[15] = opacity;
}

- (void)changeCenter:(CGPoint)center
{
	m_center = center;
}

@end
