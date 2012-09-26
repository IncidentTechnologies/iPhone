/*
 *  GuitarInterface.cpp
 *  gTarGuitarInterface
 *
 *  Created by Marty Greenia on 3/7/11.
 *  Copyright 2011 IncidentTech. All rights reserved.
 *
 */

#include "GuitarInterface.h"

void GuitarInterface::ClearArrays()
{
	char allNotesOff[] = { DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF };
	char allFretsUp[] = { DEVICE_INTERFACE_GUITAR_FRET_UP, DEVICE_INTERFACE_GUITAR_FRET_UP, DEVICE_INTERFACE_GUITAR_FRET_UP, DEVICE_INTERFACE_GUITAR_FRET_UP, DEVICE_INTERFACE_GUITAR_FRET_UP, DEVICE_INTERFACE_GUITAR_FRET_UP };
	
	memcpy( m_fretsDown, allFretsUp, GUITAR_INTERFACE_STRING_COUNT );
	memcpy( m_notesOn, allNotesOff, GUITAR_INTERFACE_STRING_COUNT );
}

void GuitarInterface::HandleDeviceOutput()
{
	
	//  clear the current notes
	char allNotesOff[] = { DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF, DEVICE_INTERFACE_GUITAR_NOTE_OFF };

	memcpy( m_notesOn, allNotesOff, GUITAR_INTERFACE_STRING_COUNT );
	
	m_deviceInterface->ReceiveDeviceOutput( m_fretsDown, m_notesOn );
}

unsigned int GuitarInterface::GetNoteIndexFromString( GuitarString str, GuitarFret fret )
{
	// string x fret = 'width' x 'height'
	return ((str * GUITAR_INTERFACE_FRET_COUNT) + fret);
}

void GuitarInterface::GetFretsDown( GuitarFret * output )
{
	memcpy( output, m_fretsDown, GUITAR_INTERFACE_STRING_COUNT);
}

void GuitarInterface::GetNotesOn( GuitarFret * output )
{
	memcpy( output, m_notesOn, GUITAR_INTERFACE_STRING_COUNT );
}

void GuitarInterface::TurnOffLed( GuitarString str, GuitarFret fret )
{
	m_deviceInterface->TurnOffLED( str, fret );
}

void GuitarInterface::TurnOffAllLeds()
{
	for ( unsigned int str = 0; str < GUITAR_INTERFACE_STRING_COUNT; str++ )
	{
		TurnOffLed(str, 0);
		usleep(DEVICE_INTERFACE_GUITAR_MESSAGE_DELAY);
	}
}

void GuitarInterface::TurnOnLedColor( GuitarString str, GuitarFret fret, char red, char green, char blue )
{
    m_deviceInterface->TurnOnLEDColor( str, fret, red, green, blue );
}

void GuitarInterface::TurnOnLedColorMapping( GuitarString str, GuitarFret fret )
{
    
    // phasing out this function, just using for compatibility
    char stringColorMap[6][3] = 
    {
        {3, 0, 0},
        {2, 1, 0},
        {3, 3, 0},
        {0, 3, 0},
        {0, 0, 3},
        {2, 0, 2}
    };
    
    TurnOnLedColor( str, fret, stringColorMap[str][0], stringColorMap[str][1], stringColorMap[str][2] );
    
}

//void GuitarInterface::TurnOnLedWhite( GuitarString str, GuitarFret fret )
//{
//	m_deviceInterface->TurnOnLED( str, fret );
//}


void GuitarInterface::EnableFretFollow()
{
	if ( m_currentEffect == GuitarInterfaceEffectLightningMode )
	{
		DisableEffects();
	}
	
	m_deviceInterface->TurnOnStateFretFollow(3, 0, 0);
	
	if ( m_currentEffect == GuitarInterfaceEffectNoteActive )
	{
		m_currentEffect = GuitarInterfaceEffectFretFollowNoteActive;
	}
	else 
	{
		m_currentEffect = GuitarInterfaceEffectFretFollow;
	}
}

void GuitarInterface::EnableNoteActive()
{
	if ( m_currentEffect == GuitarInterfaceEffectLightningMode )
	{
		DisableEffects();
	}
	
	m_deviceInterface->TurnOnStateNoteActive(3, 0, 0);
	
	if ( m_currentEffect == GuitarInterfaceEffectFretFollow )
	{
		m_currentEffect = GuitarInterfaceEffectFretFollowNoteActive;
	}
	else 
	{
		m_currentEffect = GuitarInterfaceEffectNoteActive;
	}
}

void GuitarInterface::EnableLightningMode()
{
	DisableEffects();
	
	m_deviceInterface->TurnOnStateLightning(3, 0, 0);
	
	m_currentEffect = GuitarInterfaceEffectLightningMode;

}

void GuitarInterface::DisableEffects()
{
	switch ( m_currentEffect )
	{
			
		case GuitarInterfaceEffectFretFollow:
		{
			m_deviceInterface->TurnOffStateFretFollow();
		} break;
			
		case GuitarInterfaceEffectNoteActive:
		{
			m_deviceInterface->TurnOffStateNoteActive();
		} break;
			
		case GuitarInterfaceEffectFretFollowNoteActive:
		{
			m_deviceInterface->TurnOffStateNoteActive();
			m_deviceInterface->TurnOffStateFretFollow();
		} break;
			
		case GuitarInterfaceEffectLightningMode:
		{
			m_deviceInterface->TurnOffStateLightning();
		} break;
			
		case GuitarInterfaceEffectNone:
		default:
		{
			// nothing
		} break;
			
	}
}

void GuitarInterface::ChangeEffectColor( char red, char green, char blue )
{
	switch ( m_currentEffect )
	{
		case GuitarInterfaceEffectFretFollow:
		{
			//			m_deviceController->TurnOnStateFretFollow(red, green, blue);
		} break;
			
		case GuitarInterfaceEffectNoteActive:
		{
			m_deviceInterface->TurnOnStateNoteActive(red, green, blue);
		} break;
			
		case GuitarInterfaceEffectFretFollowNoteActive:
		{
			//			m_deviceController->TurnOnStateFretFollow(red, green, blue);
			m_deviceInterface->TurnOnStateNoteActive(red, green, blue);
		} break;
			
		case GuitarInterfaceEffectLightningMode:
		{
			m_deviceInterface->TurnOnStateLightning(red, green, blue);
		} break;
			
		case GuitarInterfaceEffectNone:
		default:
		{
			// nothing
		} break;
	}		
}

void GuitarInterface::ChangeFretFollowColor( char red, char green, char blue )
{
	m_deviceInterface->TurnOnStateFretFollow(red, green, blue);
}

void GuitarInterface::ChangeNoteActiveColor( char red, char green, char blue )
{
	m_deviceInterface->TurnOnStateNoteActive(red, green, blue);
}

void GuitarInterface::ChangeLightningColor( char red, char green, char blue )
{
	m_deviceInterface->TurnOnStateLightning(red, green, blue);
}
