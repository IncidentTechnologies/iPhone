//
//  DrawObject.m
//  gTar
//
//  Created by wuda on 12/20/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "DrawObject.h"


@implementation DrawObject

-(DrawObject*)initWithBackingWidth:(float)width andHeight:(float)height
{
	
	if ( self = [super init] )
	{
		m_backingWidth = width;
		m_backingHeight = height;
	}
	
	return self;
}

-(void)resizeWidth:(float)width andHeight:(float)height
{
	
	m_backingWidth = width;
	m_backingHeight = height;
	
}

@end
