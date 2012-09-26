/*
 *  LedMarquee.cpp
 *  gTar
 *
 *  Created by Marty Greenia on 10/24/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "LedMarquee.h"


DeviceController * LedMarquee::AbandonDeviceController()
{
	DeviceController * deviceController = m_deviceController;
	
	m_deviceController = NULL;
	
	return deviceController;
}

void LedMarquee::DisplayGtar()
{
	
	char text[6][14] = 
	{
		{"    xxx   xx "},
		{" xxx x    x x"},
		{" x   x  x xx "},
		{" x xxx x xx x"},
		{" x x   xxx   "},
		{" xxx   x x   "}
	};
	
	for ( unsigned int str = 0; str < 6; str++ )
	{
		for ( unsigned int fret = 1; fret < 13; fret++ )
		{
			if ( text[str][13-fret] == 'x' )
			{
				m_deviceController->TurnOnLED( str, fret );
				usleep( 10000 );
			}
		}
	}
	
}

void LedMarquee::ClearGtar()
{
	
#if 1
	char text[6][14] = 
	{
		{"    xxx   xx "},
		{" xxx x    x x"},
		{" x   x  x xx "},
		{" x xxx x xx x"},
		{" x x   xxx   "},
		{" xxx   x x   "}
	};
#else
	char text[6][14] = 
	{
		{"             "},
		{"            x"},
		{"            x"},
		{"            x"},
		{"            x"},
		{"             "}
	};	
#endif
	for ( unsigned int str = 0; str < 6; str++ )
	{
		for ( unsigned int fret = 1; fret < 13; fret++ )
		{
			if ( text[str][13-fret] == 'x' )
			{
				m_deviceController->TurnOffLED( str, fret );
				usleep( 10000 );
			}
		}
	}	
	
}
