//
//  CGSaysObject.m
//  gTar
//
//  Created by wuda on 12/20/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//


#import "CGSaysObject.h"


@implementation CGSaysObject

-(CGSaysObject*)init
{

	if ( self = [super init] )
	{
		
		
	}
	
	return self;
	
}

-(void)render
{

	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor (myContext, 1, 0, 0, 1);// 3
    CGContextFillRect (myContext, CGRectMake (0, 0, 200, 100 ));// 4
    CGContextSetRGBFillColor (myContext, 0, 0, 1, .5);// 5
    CGContextFillRect (myContext, CGRectMake (0, 0, 100, 200));// 6
	
}

@end
