//
//  GuitarModel.h
//  gTar
//
//  Created by Marty Greenia on 10/13/10.
//  Copyright 2010 IncidentTech. All rights reserved.
//

#import "DeviceController.h"
#import "gTarDebug.h"

#define GUITAR_MODEL_STRING_COUNT GTAR_GUITAR_STRING_COUNT
#define GUITAR_MODEL_FRET_COUNT GTAR_GUITAR_FRET_COUNT
#define GUITAR_MODEL_LED_COUNT (GUITAR_MODEL_STRING_COUNT * GUITAR_MODEL_FRET_COUNT)

enum GuitarModelStates
{
	StateNone = 0,
	StateFretFollow,
	StateNoteActive,
	StateFretFollowNoteActive,
	StateLightningMode
};

@interface GuitarModel : NSObject <gTarDebugClient, gTarDebugServer>
{
	
	DeviceController * m_deviceController;
	
	gTarDebug * m_debugger;
	gTarDebug * m_clone;
	
	char m_fretsDown[ GUITAR_MODEL_STRING_COUNT ];
	char m_fretsDownPrevious[ GUITAR_MODEL_STRING_COUNT ];
	
	char m_notesOn[ GUITAR_MODEL_STRING_COUNT ];
	char m_notesOnPrevious[ GUITAR_MODEL_STRING_COUNT ];
	
	bool m_ledsOn[ GUITAR_MODEL_LED_COUNT ];
	
	GuitarOutput m_goutput;
	GuitarInput m_ginput;
	
	GuitarModelStates m_currentState;
}

- (GuitarModel*)init;
- (void)clearArrays;

- (void)handleDeviceOutput;
- (unsigned int)getNoteIndexFromString:(char)str andFret:(char)fret;
- (void)getFretsDown:(char*)output;
- (void)getFretsDownDelta:(char*)output;
- (void)getNotesOn:(char*)output;
- (void)getNotesOnDelta:(char*)output;
- (void)turnOffLedString:(char)str andFret:(char)fret;
- (void)turnOffAllLeds;
- (void)turnOnLedColorString:(char)str andFret:(char)fret;
- (void)turnOnLedWhiteString:(char)str andFret:(char)fret;

- (void)enableFretFollow;
- (void)enableNoteActive;
- (void)enableLightningMode;
- (void)disableState;
- (void)changeStateColorRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (void)changeFretFollowColorRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (void)changeNoteActiveColorRed:(char)red andGreen:(char)green andBlue:(char)blue;
- (void)changeLightningColorRed:(char)red andGreen:(char)green andBlue:(char)blue;
@end