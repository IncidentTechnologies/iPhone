//
//  gTarColors.h
//  gTarPlay
//
//  Created by Marty Greenia on 8/11/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

static unsigned char g_whiteColor[4] =
{ 255, 255, 255, 255 };

static unsigned char g_whiteColorTransparent[4] =
{ 154, 184, 195, 100 };

static unsigned char g_whiteColorTransparentLight[4] =
{ 154, 184, 195, 50 };

static unsigned char g_lightGrayColor[4] =
{ 192, 192, 192, 255 };

/*
 static unsigned char g_whiteColorQuads[16] =
 { 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 };

static unsigned char g_grayColor[4] =
{ 127, 127, 127, 255 };

static unsigned char g_grayColorQuads[16] =
{ 127, 127, 127, 255, 127, 127, 127, 255, 127, 127, 127, 255, 127, 127, 127, 255 };


static unsigned char g_stringColorsOriginal[6][4] =
{
	{ 255, 0, 0, 255 }, // R
	{ 255, 128, 0, 255 }, // O
	{ 255, 255, 0, 255 }, // Y
	{ 0, 255, 0, 255 }, // G
	{ 0, 0, 255, 255 }, // B
	{ 128, 0, 128, 255 } // P
};
*/
static unsigned char g_stringColors[6][4] =
{
	{ 214, 10, 1, 255 }, // R
	{ 221, 151, 17, 255 }, // O
	{ 170, 196, 13, 255 }, // Y
	{ 49, 181, 9, 255 }, // G
	{ 0, 141, 218, 255 }, // B
	{ 167, 102, 179, 255 } // P
};
static unsigned char g_standaloneStringColors[6][4] =
{
	{ 255, 255, 255, 255 }, // W
	{ 255, 255, 255, 255 }, // W
	{ 255, 255, 255, 255 }, // W
	{ 255, 255, 255, 255 }, // W
	{ 255, 255, 255, 255 }, // W
	{ 255, 255, 255, 255 }  // W
};
static unsigned char g_standaloneFretColors[17][4] =
{
    { 225, 255, 255, 255}, // W 0
	{ 239, 92, 53, 255 },  // R 1
	{ 239, 92, 53, 255 },  // R 2
	{ 239, 92, 53, 255 },  // R 3
	{ 239, 92, 53, 255 },  // R 4
	{ 238, 188, 53, 255 }, // Y 5
	{ 238, 188, 53, 255 }, // Y 6
	{ 238, 188, 53, 255 }, // Y 7
	{ 238, 188, 53, 255 }, // Y 8
	{ 238, 188, 53, 255 }, // Y 9
	{ 238, 188, 53, 255 }, // Y 10
	{ 0, 141, 218, 255 },  // B 11
	{ 0, 141, 218, 255 },  // B 12
	{ 0, 141, 218, 255 },  // B 13
	{ 0, 141, 218, 255 },  // B 14
	{ 0, 141, 218, 255 },  // B 15
	{ 0, 141, 218, 255 }   // B 16
};
static unsigned char g_standaloneHighlightColors[4][4] =
{
	{ 255, 255, 255, 130 }, // W
	{ 239, 92, 53, 130 },   // R
	{ 238, 188, 53, 130 },  // Y
	{ 0, 141, 218, 130 }    // B
};

static unsigned char g_standaloneHitFretColor[4] =
    { 31, 195, 72, 130 }; // Green

static unsigned char g_standaloneMissFretColor[4] =
    { 0, 0, 0, 255 }; // Black
    //{ 38, 45, 51, 255 }; // Black

static unsigned char g_standaloneClearColor[4] =
    { 1, 1, 1, 0}; // Clear

/*
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
*/
