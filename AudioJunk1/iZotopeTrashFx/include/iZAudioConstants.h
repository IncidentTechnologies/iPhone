///////////////////////////////////////////////////////////
//
// iZAudioConstants.h: iPhone Audio Processing Constants
// Copyright (c) 2010 - iZotope, Inc.  All Rights Reserved
//
//////////////////////////////////////////////////////////////////////////////
#pragma once

#define kBufferDurationSeconds 1.0f  //! For allocating buffer (in sec) for audio queue services. 
												  //! Make sure it is larger then twice any buffer size that may be 
												  //! requested by the SRC. 

namespace iZAudioConstants {
	
	//////////////////////////////////////////////////////////////////////////
	//! iPhone audio engine constants
	const unsigned int  NUM_CHANNELS_MIN=       1,
    NUM_CHANNELS_DEFAULT=   1;
    
    const unsigned int  SAMPLE_RATE_MIN=        6000,
    SAMPLE_RATE_MAX=        192000,
    SAMPLE_RATE_DEFAULT=    48000;
    
    const unsigned int	BUFFER_SIZE=			2048;
	const float         BUFFER_DURATION=		BUFFER_SIZE/SAMPLE_RATE_DEFAULT;
    
	const float CONVERSION_CONSTANT=	32767.0f; //! Used to convert back and forth between floating point and integer
} // end namespace Constants