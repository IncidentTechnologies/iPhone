//
//  GuitarModel.cpp
//  gTar
//
//  Created by Marty Greenia on 10/13/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#include "GuitarModel.h"

@implementation GuitarModel

- (GuitarModel*)initWithDebugger:(gTarDebug*)debugger andClone:(gTarDebug*)clone
{

	if ( self = [super init] )
	{
		
		[self clearArrays];

		m_debugger = debugger;
		m_clone = clone;
		
		// Take control from whoever currently owns this debug connection.
		if ( m_debugger.m_peerStatus == kServer )
		{
			[m_debugger serverTransferControl:self];
		}
		else if ( m_debugger.m_peerStatus == kClient )
		{
			[m_debugger clientTransferControl:self];
		}
		
		if ( m_clone.m_peerStatus == kServer )
		{
			[m_clone serverTransferControl:self];
		}
		else if ( m_clone.m_peerStatus == kClient )
		{
			[m_clone clientTransferControl:self];
		}
		
	}
	
}

- (GuitarModel*)initWithClone:(gTarDebug*)clone
{
	
	if ( self = [super init] )
	{
		
		[self clearArrays];
		
		m_deviceController = new DeviceController();

		m_clone = clone;
		
		// Take control from whoever currently owns this debug connection.
		if ( m_clone.m_peerStatus == kServer )
		{
			[m_clone serverTransferControl:self];
		}
		else if ( m_clone.m_peerStatus == kClient )
		{
			[m_clone clientTransferControl:self];
		}
		
	}
	
	return self;
	
}

- (GuitarModel*)initWithDebugger:(gTarDebug*)debugger
{

	if ( self = [super init] )
	{
		
		[self clearArrays];

		m_debugger = debugger;

		// Take control from whoever currently owns this debug connection.
		if ( m_debugger.m_peerStatus == kServer )
		{
			[m_debugger serverTransferControl:self];
		}
		else if ( m_debugger.m_peerStatus == kClient )
		{
			[m_debugger clientTransferControl:self];
		}
			
	}
	
	return self;
	
}

- (GuitarModel*)init
{
	
	if ( self = [super init] )
	{
		[self clearArrays];
		
		m_deviceController = new DeviceController();
	}
	
	return self;
	
}

- (void)clearArrays
{
	char allNotesOff[] = { GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF };
	char allFretsUp[] = { GTAR_GUITAR_FRET_UP, GTAR_GUITAR_FRET_UP, GTAR_GUITAR_FRET_UP, GTAR_GUITAR_FRET_UP, GTAR_GUITAR_FRET_UP, GTAR_GUITAR_FRET_UP };

	memcpy( m_fretsDownPrevious, allFretsUp, GUITAR_MODEL_STRING_COUNT );
	memcpy( m_fretsDown, allFretsUp, GUITAR_MODEL_STRING_COUNT );
	memcpy( m_notesOnPrevious, allNotesOff , GUITAR_MODEL_STRING_COUNT );
	memcpy( m_notesOn, allNotesOff, GUITAR_MODEL_STRING_COUNT );
}

- (void)dealloc
{
	[self turnOffAllLeds];
	
	[self disableState];
	
	if ( m_deviceController != nil )
	{
		delete m_deviceController;
	}
	
	[super dealloc];
}

- (void)handleDeviceOutput
{
	
	// Save the current values, before we get the new ones.
	memcpy( m_fretsDownPrevious, m_fretsDown, GUITAR_MODEL_STRING_COUNT );
	memcpy( m_notesOnPrevious, m_notesOn , GUITAR_MODEL_STRING_COUNT );

#if EDGE_TRIGGERED
	// nothing 
#else
	// else if level triggered, clear the current notes
	char allNotesOff[] = { GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF, GTAR_GUITAR_NOTE_OFF };
	memcpy( m_notesOn, allNotesOff, GUITAR_MODEL_STRING_COUNT );
#endif
	
	if ( m_debugger == nil )
	{
		m_deviceController->ReceiveDeviceOutput( m_fretsDown, m_notesOn );
		
		if ( m_clone != nil )
		{
			
			for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
			{
				
				if ( m_notesOn[ str ] != GTAR_GUITAR_NOTE_OFF )
				{
					[m_clone noteOnString:str andFret:m_notesOn[str]];
				}
				else 
				{
					[m_clone noteOffString:str andFret:m_notesOnPrevious[str]];
				}
				
				if ( m_fretsDown[ str ] != GTAR_GUITAR_FRET_UP )
				{
					[m_clone fretDownString:str andFret:m_fretsDown[str]];
				}
				else 
				{
					[m_clone fretUpString:str andFret:m_fretsDownPrevious[str]];
				}
				
			}
			
			[m_clone flushState];
			
		}
		
	}
	else 
	{
		
		for ( unsigned int str = 0; str < GUITAR_MODEL_STRING_COUNT; str++ )
		{

			m_notesOn[ str ] = GTAR_GUITAR_NOTE_OFF;
			m_fretsDown[ str ] = GTAR_GUITAR_FRET_UP;

			for ( unsigned int fret = 0; fret < GUITAR_MODEL_FRET_COUNT; fret++ )
			{
				unsigned int index = [self getNoteIndexFromString:str andFret:fret];
				
				if ( m_goutput.notesOn[ index ] == 1 )
				{
					m_notesOn[ str ] = fret;
				}
				
				if ( m_goutput.fretDown[ index ] == 1 )
				{
					m_fretsDown[ str ] = fret;
				}
				
			}
		}

	}
}

- (unsigned int)getNoteIndexFromString:(char)str andFret:(char)fret
{
	// string x fret = 'width' x 'height'
	return ((str * GUITAR_MODEL_FRET_COUNT) + fret);
}

- (void)getFretsDown:(char*)output
{
	memcpy( output, m_fretsDown, GUITAR_MODEL_STRING_COUNT);
}

- (void)getFretsDownDelta:(char*)output
{
	for ( unsigned int i = 0; i < GUITAR_MODEL_STRING_COUNT; i++ )
	{
		if ( m_fretsDownPrevious[i] != m_fretsDown[i] )
		{
			output[i] = m_fretsDown[i];
		}
	}
}

- (void)getNotesOn:(char*)output
{
	memcpy( output, m_notesOn, GUITAR_MODEL_STRING_COUNT );
}

- (void)getNotesOnDelta:(char*)output
{
	for ( unsigned int i = 0; i < GUITAR_MODEL_STRING_COUNT; i++ )
	{
		if ( m_notesOnPrevious[i] != m_notesOn[i] )
		{
			output[i] = m_notesOn[i];
		}
	}
}

- (void)turnOffLedString:(char)str andFret:(char)fret
{
	if ( m_debugger != nil && m_debugger.m_peerStatus == kServer )
	{
		// fret zero is the open string
		/*
		if ( fret == 0 )
		{
			for ( unsigned int i = 1; i < 12; i++ )
			{
				[m_debugger ledOffString:str andFret:i];
				usleep(GTAR_GUITAR_MESSAGE_DELAY);
			}
		}
		else 
		 */
		{
			[m_debugger ledOffString:str andFret:fret];
		}
	
		[m_debugger flushState];

	}
	else 
	{
		// fret zero is the open string
		/*
		if ( fret == 0 )
		{
			for ( unsigned int i = 1; i < 12; i++ )
			{
				m_deviceController->TurnOffLED( str, i );
				usleep(GTAR_GUITAR_MESSAGE_DELAY);
			}
		}
		else 
			*/
		{
			m_deviceController->TurnOffLED( str, fret );
		}
	}
}

- (void)turnOffAllLeds
{
	
	for ( unsigned int str = 0; str < GTAR_GUITAR_STRING_COUNT; str++ )
	{
		[self turnOffLedString:str andFret:0];
		usleep(GTAR_GUITAR_MESSAGE_DELAY);
	}
}

- (void)turnOnLedColorString:(char)str andFret:(char)fret
{
	if ( m_debugger != nil && m_debugger.m_peerStatus == kServer )
	{
		// fret zero is the open string
		/*
		if ( fret == 0 )
		{
			for ( unsigned int i = 1; i < 12; i++ )
			{
				[m_debugger ledOnString:str andFret:i];
				usleep(GTAR_GUITAR_MESSAGE_DELAY);
			}

		}
		else 
		 */
		{
			[m_debugger ledOnString:str andFret:fret];
		}

		[m_debugger flushState];

	}
	else 
	{
		// fret zero is the open string
/*
		if ( fret == 0 )
		{
			for ( unsigned int i = 1; i < 12; i++ )
			{
				//m_deviceController->TurnOnLED( str, i );
				m_deviceController->TurnOnLEDStringColor( str, i );
				usleep(GTAR_GUITAR_MESSAGE_DELAY);
			}

		}
		else 
 */
		{
			//m_deviceController->TurnOnLED( str, fret );	
			m_deviceController->TurnOnLEDStringColor( str, fret );
		}
	}
}

- (void)turnOnLedWhiteString:(char)str andFret:(char)fret
{
	if ( m_debugger != nil && m_debugger.m_peerStatus == kServer )
	{
		// fret zero is the open string
		/*
		 if ( fret == 0 )
		 {
		 for ( unsigned int i = 1; i < 12; i++ )
		 {
		 [m_debugger ledOnString:str andFret:i];
		 usleep(GTAR_GUITAR_MESSAGE_DELAY);
		 }
		 
		 }
		 else 
		 */
		{
			[m_debugger ledOnString:str andFret:fret];
		}
		
		[m_debugger flushState];
		
	}
	else 
	{
		// fret zero is the open string
		/*
		 if ( fret == 0 )
		 {
		 for ( unsigned int i = 1; i < 12; i++ )
		 {
		 //m_deviceController->TurnOnLED( str, i );
		 m_deviceController->TurnOnLEDStringColor( str, i );
		 usleep(GTAR_GUITAR_MESSAGE_DELAY);
		 }
		 
		 }
		 else 
		 */
		{
			//m_deviceController->TurnOnLED( str, fret );	
			m_deviceController->TurnOnLED( str, fret );
		}
	}
}

#pragma mark -
#pragma mark Debugger protocol
- (void)clientRecvGuitarInput:(GuitarInput*)ginput
{
	// Send input from the device
	//memcpy( &m_ginput, ginput, sizeof(GuitarInput) );
}

- (void)clientEndpointDisconnected
{
	
}

- (void)clientEndpointConnected
{
	
}


- (void)serverRecvGuitarOutput:(GuitarOutput*)goutput
{
	// Handle the output from the device
	memcpy( &m_goutput, goutput, sizeof(GuitarOutput) );
}

- (void)serverEndpointDisconnected
{
	
}

- (void)serverEndpointConnected
{
		
}

#pragma mark -
#pragma mark State changes

- (void)enableFretFollow
{
	if ( m_currentState == StateLightningMode )
	{
		[self disableState];
	}
	
	m_deviceController->TurnOnStateFretFollow(3, 0, 0);

	if ( m_currentState == StateNoteActive )
	{
		m_currentState = StateFretFollowNoteActive;
	}
	else 
	{
		m_currentState = StateFretFollow;
	}
	
}

- (void)enableNoteActive
{
	if ( m_currentState == StateLightningMode )
	{
		[self disableState];
	}
	
	m_deviceController->TurnOnStateNoteActive(3, 0, 0);

	if ( m_currentState == StateFretFollow )
	{
		m_currentState = StateFretFollowNoteActive;
	}
	else 
	{
		m_currentState = StateNoteActive;
	}

}

- (void)enableLightningMode
{
	[self disableState];
	
	m_deviceController->TurnOnStateLightning(3, 0, 0);
	
	m_currentState = StateLightningMode;
}

- (void)disableState
{
	switch ( m_currentState )
	{

		case StateFretFollow:
		{
			m_deviceController->TurnOffStateFretFollow();
		} break;
			
		case StateNoteActive:
		{
			m_deviceController->TurnOffStateNoteActive();
		} break;

		case StateFretFollowNoteActive:
		{
			m_deviceController->TurnOffStateNoteActive();
			m_deviceController->TurnOffStateFretFollow();
		} break;
			
		case StateLightningMode:
		{
			m_deviceController->TurnOffStateLightning();
		} break;
			
		case StateNone:
		default:
		{
			// nothing
		} break;
			
	}
			
}

- (void)changeStateColorRed:(char)red andGreen:(char)green andBlue:(char)blue
{
	switch ( m_currentState )
	{
		case StateFretFollow:
		{
//			m_deviceController->TurnOnStateFretFollow(red, green, blue);
		} break;
			
		case StateNoteActive:
		{
			m_deviceController->TurnOnStateNoteActive(red, green, blue);
		} break;
			
		case StateFretFollowNoteActive:
		{
//			m_deviceController->TurnOnStateFretFollow(red, green, blue);
			m_deviceController->TurnOnStateNoteActive(red, green, blue);
		} break;
			
		case StateLightningMode:
		{
			m_deviceController->TurnOnStateLightning(red, green, blue);
		} break;
			
		case StateNone:
		default:
		{
			// nothing
		} break;
	}			
}

- (void)changeFretFollowColorRed:(char)red andGreen:(char)green andBlue:(char)blue
{
	m_deviceController->TurnOnStateFretFollow(red, green, blue);
}

- (void)changeNoteActiveColorRed:(char)red andGreen:(char)green andBlue:(char)blue
{
	m_deviceController->TurnOnStateNoteActive(red, green, blue);
}

- (void)changeLightningColorRed:(char)red andGreen:(char)green andBlue:(char)blue
{
	m_deviceController->TurnOnStateLightning(red, green, blue);
}



@end