/*
 *  DeviceController.h
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "gTar.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>		// Unix standard function definitions
#include <fcntl.h>		// File control definitions
#include <errno.h>		// Error number definitions
#include <termios.h>	// POSIX terminal control definitions

#include <sys/ioctl.h>	// ioctl 

#define MAX_BUFFER_SIZE 256

static char g_deviceStringColorMap[GTAR_GUITAR_STRING_COUNT][8] = 
	{
		"3 0 0",
		"2 1 0",
		"3 3 0",
		"0 3 0",
		"0 0 3",
		"2 0 2"
	};

class DeviceController
{
private:

	struct termios m_OriginalTTYAttrs;
	int m_fd;
	
	unsigned char m_buffer[ MAX_BUFFER_SIZE ];
	unsigned int m_bufferLength;

public:
	
	DeviceController() :
		m_fd(-1),
		m_bufferLength(0)
	{
		m_fd = OpenSerialPort();
	}
	
	~DeviceController()
	{
		CloseSerialPort();
	}
	
	// Receive Output from device
	void ConsolidateBufferBytes( int startIndex, int bytesToConsolidate );
	void ReceiveDeviceOutput( char *fretsDown, char *notesOn ); 

	// Send Input to device
	bool TurnOnLED(int str, int fret);
	bool TurnOffLED(int str, int fret);
	bool SendLEDMsg(int string, int fret, char *pszOnOff);

	bool TurnOnLEDColor(int str, int fret, char red, char green, char blue);
	bool TurnOnLEDStringColor( int str, int fret );
	bool SendLEDColorMsg(int string, int fret, char *pszColor);

	bool TurnOnStateFretFollow(char red, char green, char blue);
	bool TurnOffStateFretFollow();
	bool TurnOnStateNoteActive(char red, char green, char blue);
	bool TurnOffStateNoteActive();
	bool TurnOnStateLightning(char red, char green, char blue);
	bool TurnOffStateLightning();
	bool SendStateMsg( char *pszState, char *pszOnOffColor);
		
	// Socket IO
	int ReadSerialPort(unsigned char * &n_pBuffer);
 	int ReadSerialPort(unsigned char * pBuffer, unsigned int pBuffer_n);
	int WriteSerialPort(unsigned char *psz, int psz_n);
	int OpenSerialPort();
	void CloseSerialPort();
	
};
