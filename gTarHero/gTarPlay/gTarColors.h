//
//  gTarColors.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/11/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

static unsigned char g_whiteColor[4] =
{ 255, 255, 255, 255 };

static unsigned char g_whiteColorQuads[16] =
{ 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };

static unsigned char g_grayColor[4] =
{ 127, 127, 127, 255 };

static unsigned char g_grayColorQuads[16] =
{ 127, 127, 127, 255, 127, 127, 127, 255, 127, 127, 127, 255, 127, 127, 127, 255 };


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

static unsigned char g_measureColors[4] = 
{ 192, 192, 0, 255 };

static unsigned char g_beatColors[4] =
{ 128, 64, 0, 255 };

