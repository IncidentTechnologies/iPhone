/*
 *  GuitarInterface.h
 *  gTarGuitarInterface
 *
 *  Created by Marty Greenia on 3/7/11.
 *  Copyright 2011 IncidentTech. All rights reserved.
 *
 */

#import "DeviceInterface.h"

#define GUITAR_INTERFACE_STRING_COUNT 6
#define GUITAR_INTERFACE_FRET_COUNT 16
#define GUITAR_INTERFACE_LED_COUNT (GUITAR_INTERFACE_STRING_COUNT * GUITAR_INTERFACE_FRET_COUNT)

#define GUITAR_INTERFACE_NOTE_OFF DEVICE_INTERFACE_GUITAR_NOTE_OFF
#define GUITAR_INTERFACE_FRET_UP DEVICE_INTERFACE_GUITAR_FRET_UP

enum GuitarInterfaceEffect
{
	GuitarInterfaceEffectNone = 0,
	GuitarInterfaceEffectFretFollow,
	GuitarInterfaceEffectNoteActive,
	GuitarInterfaceEffectFretFollowNoteActive,
	GuitarInterfaceEffectLightningMode
};

typedef char GuitarString;
typedef char GuitarFret;

//
// This class holds various state about the actual guitar.
// It uses the device interface to do IO from the device.
//
//
class GuitarInterface
{
public:
	
	DeviceInterface * m_deviceInterface;
		
	GuitarFret m_fretsDown[ GUITAR_INTERFACE_STRING_COUNT ];
		
	GuitarFret m_notesOn[ GUITAR_INTERFACE_STRING_COUNT ];
		
	bool m_ledsOn[ GUITAR_INTERFACE_LED_COUNT ];
		
	GuitarInterfaceEffect m_currentEffect;
	
	GuitarInterface()
	{
		ClearArrays();
		
		m_deviceInterface = new DeviceInterface();
	}
	
	~GuitarInterface()
	{

		TurnOffAllLeds();

		DisableEffects();

		if ( m_deviceInterface != NULL )
		{
			delete m_deviceInterface;
		}
		
	}
	
	void ClearArrays();
	
	void HandleDeviceOutput();
	unsigned int GetNoteIndexFromString( GuitarString str, GuitarFret fret );

	void GetFretsDown( GuitarFret * output );
	void GetNotesOn( GuitarFret * output );

	void TurnOffLed( GuitarString str, GuitarFret fret );
	void TurnOffAllLeds();	
	void TurnOnLedColor( GuitarString str, GuitarFret fret, char red, char green, char blue );
	void TurnOnLedColorMapping( GuitarString str, GuitarFret fret );
//	void TurnOnLedWhite( GuitarString str, GuitarFret fret );
	
	void EnableFretFollow();
	void EnableNoteActive();
	void EnableLightningMode();
	void DisableEffects();

	void ChangeEffectColor( char red, char green, char blue );
	
	void ChangeFretFollowColor( char red, char green, char blue );
	void ChangeNoteActiveColor( char red, char green, char blue );
	void ChangeLightningColor( char red, char green, char blue );
	
};