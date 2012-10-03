/*
 *  Chord.h
 *  gTar
 *
 *  Created by wuda on 10/24/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "gTar.h"

class Chord
{
public:
	
	char m_strings[ GTAR_GUITAR_STRING_COUNT ];
	
	Chord()
	{
		
		for ( unsigned int i = 0; i < GTAR_GUITAR_STRING_COUNT; i++ )
		{
			m_strings[i] = -1;
		}
	
	}
	
	char operator[]( unsigned int str )
	{
		if ( str < GTAR_GUITAR_STRING_COUNT )
		{
			return m_strings[ str ];
		}
		else
		{
			return -1;
		}
	}
	
};