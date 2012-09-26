/*
 *  CNote.c
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "CNote.h"

void CNote::SetValue( const char * str )
{

	//Copy the string into the local buffer.
	strcpy( m_value, str );
	
}
