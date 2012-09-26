/*
 *  SerialPort.h
 *  SerialPortJunk1
 *
 *  Created by Idan Beck on 10/4/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>		// Unix standard function definitions
#include <fcntl.h>		// File control definitions
#include <errno.h>		// Error number definitions
#include <termios.h>	// POSIX terminal control definitions

#include <sys/ioctl.h>	// ioctl 

#define MAX_BUFFER_SIZE 256

#define printf(...) \
{ \
  char buff[MAX_BUFFER_SIZE]; \
  sprintf(buff, __VA_ARGS__); \
  printToConsoleFromC(buff); \
}

extern void printToConsoleFromC( char * str );

class SerialPort
{
public:
	SerialPort() :
		m_fd(-1)
	{
		m_fd = OpenSerialPort();
		
	}
	
	~SerialPort()
	{
		
	}
	
	int ReadSerialPort(unsigned char * &n_pBuffer)
	{
		if (m_fd == -1) 
			return 0;
		
		n_pBuffer = new unsigned char[MAX_BUFFER_SIZE];
		int bytes_n = 0;
		
		bytes_n = read(m_fd, n_pBuffer, MAX_BUFFER_SIZE);
		
		return bytes_n;
	}
	
	bool SendLEDMsg(int string, int fret, char *pszOnOff)
	{
		if(m_fd == -1)
			//return 0;
			return false;
		
		char *tempString = new char[MAX_BUFFER_SIZE];
		sprintf(tempString, "&led %s %d %d&", pszOnOff, string, fret);
		
		int bytes_n = write(m_fd, tempString, strlen(tempString));
		
		delete [] tempString;
		tempString = NULL;
		
		return (strlen(tempString) == bytes_n);
	}
	
	int WriteSerialPort(unsigned char *psz, int psz_n)
	{
		// This will write to the serial port
		if(m_fd == -1)
			return 0;
		
		int bytes_n = write(m_fd, psz, psz_n);
		
		if(psz_n != bytes_n)
			printf("mismatch between length of sent message %d and %d bytes sent!", psz_n, bytes_n);
		
		return bytes_n;
	}
	
	int OpenSerialPort()
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
	
private:
	struct termios m_OriginalTTYAttrs;
	int m_fd;
};

