//
//  DrawObject.h
//  gTar
//
//  Created by wuda on 12/20/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import <Foundation/Foundation.h>

// red, orange, yellow, green, blue, purple
// red orange green yellow blue purple 

static unsigned char g_stringColors[6][4] = 
{ 
	{ 255, 0, 0, 255 }, // R
	{ 255, 128, 0, 255 }, // O
	{ 255, 255, 0, 255 }, // Y
	{ 0, 255, 0, 255 }, // G
	{ 0, 0, 255, 255 }, // B
	{ 128, 0, 128, 255 } // P
};

static unsigned char g_stringColorsQuads[6][16] = 
{ 
	{ 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255 }, // red
	{ 255, 128, 0, 255, 255, 128, 0, 255, 255, 128, 0, 255, 255, 128, 0, 255 }, //oran
	{ 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255 }, //yelo
	{ 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255 }, // gre
	{ 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255 }, // blue 
	{ 128, 0, 128, 255, 128, 0, 128, 255, 128, 0, 128, 255, 128, 0, 128, 255 } //pur
};

@interface DrawObject : NSObject
{
	unsigned int m_backingHeight;
	unsigned int m_backingWidth;
}

-(DrawObject*)initWithBackingWidth:(float)width andHeight:(float)height;
-(void)render;
-(void)resizeWidth:(float)width andHeight:(float)height;

@end
