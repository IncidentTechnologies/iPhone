/*
 *  DeviceController.cpp
 *  gTar
 *
 *  Created by Marty Greenia on 10/13/10.
 *  Copyright 2010 IncidentTech. All rights reserved.
 *
 */

#include "DeviceController.h"

void DeviceController::ConsolidateBufferBytes( int startIndex, int bytesToConsolidate )
{
	for ( NSInteger i = 0; i < bytesToConsolidate; i++ )
	{
		m_buffer[i] = m_buffer[ startIndex + i ];
	}

	m_bufferLength = bytesToConsolidate;
}

// TODO: return the midinote and velocity
void DeviceController::ReceiveDeviceOutput( char *fretsDown, char *notesOn )
{

	unsigned int currentIndex;
	unsigned int bytesRead = ReadSerialPort( m_buffer + m_bufferLength, MAX_BUFFER_SIZE - m_bufferLength );
	
	for(currentIndex = 0; currentIndex < bytesRead; currentIndex++)
	{
		// Check the first byte for command information
		switch( m_buffer[currentIndex] )
		{
			case 0x80:
			{
				// Make sure that the message is large enough
				if( (currentIndex + 3) >= bytesRead )
				{
					unsigned int bytesRemaining = (bytesRead - currentIndex);
					ConsolidateBufferBytes( currentIndex, bytesRemaining );
					currentIndex += bytesRemaining;
					continue;
				}
				
				// This is the Note Off event.
				// Bytes two and three indicate midi-note and velocity.
				// The final byte encodes string/fret position.
				unsigned char midinote = m_buffer[currentIndex + 1];
				unsigned char velocity = m_buffer[currentIndex + 2];  
				unsigned char strfret = m_buffer[currentIndex + 3];
				
				unsigned char str = (strfret >> 5);
				unsigned char fret = (strfret & 0x1F);
				
				if ( notesOn[str] == fret )
				{
					notesOn[str] = GTAR_GUITAR_NOTE_OFF;
				}

				currentIndex += 3;

			} break;
				
			case 0x90:
			{
				// Make sure that the message is large enough
				if((currentIndex + 3) >= bytesRead) 
				{
					unsigned int bytesRemaining = (bytesRead - currentIndex);
					ConsolidateBufferBytes( currentIndex, bytesRemaining );
					currentIndex += bytesRemaining;
					continue;
				}
				
				// This is the Note On event.
				// Bytes two and three indicate midi-note and velocity.
				// The final byte encodes string/fret position.
				unsigned char midinote = m_buffer[currentIndex + 1];
				unsigned char velocity = m_buffer[currentIndex + 2];  
				unsigned char strfret = m_buffer[currentIndex + 3];
				
				unsigned char str = (strfret >> 5);
				unsigned char fret = (strfret & 0x1F);

				notesOn[str] = fret;
				
				currentIndex += 3;

			} break;
				
			case 0xB0:
			{
				if((currentIndex + 2) >= bytesRead)
				{
					unsigned int bytesRemaining = (bytesRead - currentIndex);
					ConsolidateBufferBytes( currentIndex, bytesRemaining );
					currentIndex += bytesRemaining;
					continue;
				}
				
				// This is a Fret Down / Up message
				// First byte is whether its up or down.
				// Second byte is encoded string/fret position
				unsigned char updown = m_buffer[currentIndex + 1];
				unsigned char strfret = m_buffer[currentIndex + 2];  
				
				unsigned char str = (strfret >> 5);
				unsigned char fret = (strfret & 0x1F);
			
				if ( updown == 49 )
				{
					// Fret down
					fretsDown[str] = fret;
				}
				else if( updown = 48 )
				{
					// Fret up
					fretsDown[str] = GTAR_GUITAR_FRET_UP;
				}
				
			} break;
				
			default:
			{
				// Not a valid header byte, skip it
			} 
		}
	}

}

//
// LED related enable/disable functions
//

bool DeviceController::TurnOnLED( int str, int fret )
{
	return SendLEDMsg( str, fret, (char*)"on");
}

bool DeviceController::TurnOffLED( int str, int fret )
{
	return SendLEDMsg( str, fret, (char*)"off");	
}

bool DeviceController::SendLEDMsg(int string, int fret, char *pszOnOff)
{
	if(m_fd == -1)
		return false;
	
	char tempString[MAX_BUFFER_SIZE];
	sprintf(tempString, "&led %s %d %d&", pszOnOff, string, fret);
	
	int bytes_n = write(m_fd, tempString, strlen(tempString));
		
	return (strlen(tempString) == bytes_n);
}

bool DeviceController::TurnOnLEDColor( int str, int fret, char red, char green, char blue )
{
	char colorString[] = "      ";
	
	colorString[0] = red;
	colorString[2] = green;
	colorString[4] = blue;
	
	return SendLEDColorMsg( str, fret, colorString);
}

bool DeviceController::TurnOnLEDStringColor( int str, int fret )
{
	char * colorString = g_deviceStringColorMap[str];
	
	return SendLEDColorMsg( str, fret, colorString );
}

bool DeviceController::SendLEDColorMsg(int string, int fret, char *pszColor)
{
	if(m_fd == -1)
		return false;
	
	char tempString[MAX_BUFFER_SIZE];
	sprintf(tempString, "&led color %d %d %s&", string, fret, pszColor);
	
	int bytes_n = write(m_fd, tempString, strlen(tempString));
	
	return (strlen(tempString) == bytes_n);
}

// 
// State related enable/disable functions
//

bool DeviceController::TurnOnStateFretFollow(char red, char green, char blue)
{
	char colorString[] = "on       ";
	
	colorString[3] = red + '0';
	colorString[5] = green + '0';
	colorString[7] = blue + '0';
	
	return SendStateMsg( "fretfollow", colorString );
}

bool DeviceController::TurnOffStateFretFollow()
{
	return SendStateMsg( "fretfollow", "off" );
}

bool DeviceController::TurnOnStateNoteActive(char red, char green, char blue)
{
	char colorString[] = "on       ";
	
	colorString[3] = red + '0';
	colorString[5] = green + '0';
	colorString[7] = blue + '0';
	
	return SendStateMsg( "noteactive", colorString );
}

bool DeviceController::TurnOffStateNoteActive()
{
	return SendStateMsg( "noteactive", "off" );
}

bool DeviceController::TurnOnStateLightning(char red, char green, char blue)
{
	char colorString[] = "on       ";
	
	colorString[3] = red + '0';
	colorString[5] = green + '0';
	colorString[7] = blue + '0';
	
	return SendStateMsg( "lightning", colorString );
}

bool DeviceController::TurnOffStateLightning()
{
	return SendStateMsg( "lightning", "off" );
}
								   
bool DeviceController::SendStateMsg(char *pszState, char *pszOnOffColor)
{
	if(m_fd == -1)
		return false;
	
	char tempString[MAX_BUFFER_SIZE];
	sprintf(tempString, "&state %s %s&", pszState, pszOnOffColor);
	
	int bytes_n = write(m_fd, tempString, strlen(tempString));
	
	return (strlen(tempString) == bytes_n);
}

//
// Serial access functions
//

int DeviceController::ReadSerialPort(unsigned char * pBuffer, unsigned int pBuffer_n)
{
	if (m_fd == -1) 
		return 0;

	int bytes_n = 0;
	
	bytes_n = read(m_fd, pBuffer, pBuffer_n);
	
	return bytes_n;

}


int DeviceController::ReadSerialPort(unsigned char * &n_pBuffer)
{
	if (m_fd == -1) 
		return 0;
	
	n_pBuffer = new unsigned char[MAX_BUFFER_SIZE];
	int bytes_n = 0;
	
	bytes_n = read(m_fd, n_pBuffer, MAX_BUFFER_SIZE);
	
	return bytes_n;
}

int DeviceController::WriteSerialPort(unsigned char *psz, int psz_n)
{
	// This will write to the serial port
	if(m_fd == -1)
		return 0;
	
	int bytes_n = write(m_fd, psz, psz_n);
	
	if(psz_n != bytes_n)
		printf("mismatch between length of sent message %d and %d bytes sent!", psz_n, bytes_n);
	
	return bytes_n;
}

int DeviceController::OpenSerialPort()
{
	m_fd = -1;
	struct termios options;
	
	// Open the serial port read/write, with no controlling terminal, and don't wait for a connection.
	// The O_NONBLOCK flag also causes subsequent I/O on the device to be non-blocking.
	// See open(2) ("man 2 open") for details
	
	m_fd = open("/dev/tty.iap", O_RDWR | O_NOCTTY | O_NONBLOCK);
	if(m_fd == -1)
	{
		printf("Error opening serial port %s - %s(%d).\n", "/dev/tty.iap", strerror(errno), errno);
		goto error;
	}
	
	// Note that the open() follows POSIX semantics: multiple open() calls to the same file will succeed
	// unless the TIOCEXCL ioctl is issued. This will prevent additional opens except by root-owned
	// processes 
	// see tty(4) ("man 4 tty") and ioctl(2) ("man 2 ioctl") for details
	
	if(ioctl(m_fd, TIOCEXCL) == -1)
	{
		printf("Error setting TIOCEXCL on %s - %s(%d).\n", "/dev/tty.iap", strerror(errno), errno);
		goto error;
	}
	
	// Now that the device is open, clear the O_NONBLOCK flag so no subsequent I/O will block.
	// see fcntl(2) ("man 2 fcntl") for details
	
	// FNDELAY means read will return 0 if no characters are waiting
	if(fcntl(m_fd, F_SETFL, FNDELAY) == -1)
	{
		printf("Error clearing O_NONBLOCK %s - %s(%d).\n", "/dev/tty.iap", strerror(errno), errno);
		goto error;
	}
	
	// Get the current options and save them for later for restoration
	if(tcgetattr(m_fd, &m_OriginalTTYAttrs) == -1)
	{
		printf("Error getting tty attributes %s - %s(%d).\n", "/dev/tty.iap", strerror(errno), errno);
		goto error;
	}
	
	// The serial port attributes such as timeouts and baud rate are set by modifying the termios
	// structure and then calling tcsetattr() to cause the changes to take effect. Note that the
	// changes will not take affect until the tcsetattr() call.
	// See tcsetattr(4) ("man 4 tcsetattr") for details
	options = m_OriginalTTYAttrs;
	
	// Print the current in/out baud rates
	
	printf("Current input baud rate is %d\n", (int)cfgetispeed(&options));
	printf("Current output baud rate is %d\n", (int)cfgetospeed(&options));
	
	// Set raw input mode (non-canonincal), with reads blocking unitl either a single character
	// has been received or a one second timeout occurs
	// see termios(4) ("man 4 termios") for details
	
	// setting both to zero sets up a poll 
	cfmakeraw(&options);
	options.c_cc[VMIN] = 0;
	options.c_cc[VTIME] = 0;
	
	// The baud rate, word length, and handshake options are set as follows
	cfsetspeed(&options, B57600);	// set 19200 baud rate
	options.c_cflag |= (CS8);		// RTS flow control of input
	
	printf("Input baud rate changed to %d\n", (int) cfgetispeed(&options));
	printf("Output baud rate changed to %d\n", (int) cfgetospeed(&options));
	
	// cause the new changes to take effect immediately
	if(tcsetattr(m_fd, TCSANOW, &options) == -1 )
	{
		printf("Error setting tty attributes %s - %s(%d).\n", "/dev/tty.iap", strerror(errno), errno);
		goto error;
	}
	
	// Success!
	return m_fd;
	
	// Failure on "/dev/tty/iap"
error:
	if(m_fd != -1)
	{
		close(m_fd);
	}
	
	return -1;
}

void DeviceController::CloseSerialPort()
{
	if(m_fd != -1)
	{
		close(m_fd);
	}
}
