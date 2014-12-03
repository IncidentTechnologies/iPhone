//
//  keysColors.h
//  keysPlay
//
//  Created by Marty Greenia on 8/11/11.
//  Copyright 2011 Incident Technologies. All rights reserved.
//

static unsigned char g_whiteColor[4] =
{ 255, 255, 255, 255 };

static unsigned char g_whiteColorTransparent[4] =
{ 154, 184, 195, 100 };

static unsigned char g_whiteColorTransparentLight[4] =
{ 154, 184, 195, 30 };

static unsigned char g_whiteGrayColor[4] =
{ 110, 148, 158, 255 };

static unsigned char g_lightGrayColor[4] =
{ 192, 192, 192, 255 };

static unsigned char g_keyColors[12][4] =
{
    { 218, 87, 51, 255 }, // R
    { 242, 197, 154, 255 }, // RYW
    { 238, 188, 53, 255 }, // Y
    { 200, 228, 163, 255 }, // YGW
    { 49, 214, 90, 255 }, // G
    { 25, 204, 166, 255 }, // GB
    { 134, 227, 219, 255 }, // GBBW
    { 0, 194, 202, 255 }, // B
    { 162, 200, 219, 255 }, // BPW
    { 136, 96, 163, 255 }, // P
    { 220, 187, 210, 255 }, // PKW
    { 234, 140, 168, 255 } // K
};

static unsigned char g_standaloneKeyColors[2][4] =
{
    { 225, 255, 255, 255}, // W 0
	{ 35, 194, 238, 255 }   // B 1
};
static unsigned char g_standaloneHighlightColors[4][4] =
{
	{ 255, 255, 255, 130 }, // W
	{ 239, 92, 53, 130 },   // R
	{ 238, 188, 53, 130 },  // Y
	{ 0, 141, 218, 130 }    // B
};

static unsigned char g_standaloneHitKeyCorrectColor[4] =
    { 31, 195, 72, 130 }; // Green

static unsigned char g_standaloneHitKeyNearColor[4] =
    { 238, 188, 53, 130 }; // Yellow

static unsigned char g_standaloneHitKeyIncorrectColor[4] =
    { 239, 92, 53, 130 }; // Red

static unsigned char g_standaloneMissKeyColor[4] =
    { 0, 0, 0, 255 }; // Black
    //{ 38, 45, 51, 255 }; // Black

static unsigned char g_standaloneClearColor[4] =
    { 1, 1, 1, 0}; // Clear


