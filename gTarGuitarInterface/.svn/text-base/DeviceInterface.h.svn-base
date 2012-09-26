/*
 *  DeviceInterface.h
 *  gTarGuitarInterface
 *
 *  Created by Marty Greenia on 3/7/11.
 *  Copyright 2011 IncidentTech. All rights reserved.
 *
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>		// Unix standard function definitions
#include <fcntl.h>		// File control definitions
#include <errno.h>		// Error number definitions
#include <termios.h>	// POSIX terminal control definitions

#include <sys/ioctl.h>	// ioctl 

#define DEVICE_INTERFACE_MAX_BUFFER_SIZE 256

#define DEVICE_INTERFACE_GUITAR_NOTE_OFF -1
#define DEVICE_INTERFACE_GUITAR_FRET_UP -1

// in microseconds (usleep)
#define DEVICE_INTERFACE_GUITAR_MESSAGE_DELAY 8000

typedef char GuitarString;
typedef char GuitarFret;

//
// This class is a pure IO class
//
class DeviceInterface
{
private:
	
	struct termios m_OriginalTTYAttrs;
	int m_fd;
	
	unsigned char m_buffer[ DEVICE_INTERFACE_MAX_BUFFER_SIZE ];
	unsigned int m_bufferLength;
	
	
public:
	
	DeviceInterface() :
	m_fd(-1),
	m_bufferLength(0)
	{
		m_fd = OpenSerialPort();
	}
	
	~DeviceInterface()
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
