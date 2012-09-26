///////////////////////////////////////////////////////////
//
// constants_iZTrashFX.h: Constants for iZotope TrashFX Engine Interface
// Copyright (c) 2004-2011 - iZotope, Inc.  All Rights Reserved
// PackageID: %PACKAGEID%
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __CONSTANTS_IZTRASHFX_H_7494296__
#define __CONSTANTS_IZTRASHFX_H_7494296__

namespace iZTrashFX {

	//////////////////////////////////////////////////////////////////////////
	//! Error codes returned by TrashFXEngine functions
	enum ErrorCode {
		ERROR_OK,
        
        ERROR_INVALID_CHANNEL_COUNT,
        ERROR_INVALID_SAMPLE_RATE,
        
		ERROR_PARAMETER_RANGE,
        ERROR_INVALID_PATH,
		ERROR_INVALID_KEY,
		ERROR_INVALID_PRESET,
        
        ERROR_INVALID_BUFFER_SIZE,
        ERROR_NULL_BUFFER,
        
		ERROR_OTHER
	}; // end enum ErrorCode
    
    //////////////////////////////////////////////////////////////////////////
    // Trash distortion algorithms
	enum {
		TRASH_DISTORTION_NONE,
		TRASH_DISTORTION_AMPERICAL,
		TRASH_DISTORTION_NASTY_BOY,
		TRASH_DISTORTION_TUBE_DRAINER,
		TRASH_DISTORTION_AMP_DRAINER,
		TRASH_DISTORTION_GENTLE_PUSH,
		TRASH_DISTORTION_SMOOTH_OVERDRIVE,
		TRASH_DISTORTION_TAPE_SATURATION,
		TRASH_DISTORTION_SMOOTH_FUZZ,
		TRASH_DISTORTION_STRAIGHT_FUZZ,
		TRASH_DISTORTION_TEN_INCH_SPIKE,
		NUM_TRASH_DISTORTION_ALGORITHMS
	}; // end enum distortion algorithms
	
	const unsigned int TRASH_DISTORTION_ALGORITHM_DEFAULT= TRASH_DISTORTION_NONE;
    
    const char* const TRASH_DISTORTION_ALGORITHM_CAPTIONS[NUM_TRASH_DISTORTION_ALGORITHMS]= { "None", "Amperical", "Nasty Boy", "Tube Drainer", "Amp Drainer", "Gentle Push", "Smooth Overdrive", "Tape Saturation", "Smooth Fuzz", "Straight Fuzz", "Ten-Inch Spike"};
    
	
    //////////////////////////////////////////////////////////////////////////
	// Trash distortion parameters
	enum {
		TRASH_DISTORTION_INPUT_GAIN,
		TRASH_DISTORTION_OVERDRIVE,
		TRASH_DISTORTION_TRASH,
		TRASH_DISTORTION_MIX_PERCENT,
		TRASH_DISTORTION_OUTPUT_GAIN,
		NUM_TRASH_DISTORTION_PARAMETERS
	};	// end enum distortion parameters
	
    //////////////////////////////////////////////////////////////////////////
	//! Trash distortion parameter ranges and defaults
	const float TRASH_DISTORTION_INPUT_GAIN_MIN= -30.0f,
                TRASH_DISTORTION_INPUT_GAIN_MAX= 20.0f,
                TRASH_DISTORTION_INPUT_GAIN_DEFAULT= 0.0f,
                TRASH_DISTORTION_OVERDRIVE_MIN= 0.0f,
                TRASH_DISTORTION_OVERDRIVE_MAX= 10.0f,
                TRASH_DISTORTION_OVERDRIVE_DEFAULT= 5.0f,
                TRASH_DISTORTION_TRASH_MIN= 0.0f,
                TRASH_DISTORTION_TRASH_MAX= 1.0f,
                TRASH_DISTORTION_TRASH_DEFAULT= 0.5f,
                TRASH_DISTORTION_MIX_PERCENT_MIN= 0.0f,
                TRASH_DISTORTION_MIX_PERCENT_MAX= 100.0f,
                TRASH_DISTORTION_MIX_PERCENT_DEFAULT= 100.0f,
                TRASH_DISTORTION_OUTPUT_GAIN_MIN= -40.0f,
                TRASH_DISTORTION_OUTPUT_GAIN_MAX= 10.0f,
                TRASH_DISTORTION_OUTPUT_GAIN_DEFAULT= 0.0f;
    
    //////////////////////////////////////////////////////////////////////////
	//! Microphone types for Box Modeler
	enum {
		BOX_MODELER_MIC_DYNAMIC,
		BOX_MODELER_MIC_CONDENSER,
		BOX_MODELER_MIC_RIBBON,
		NUM_BOX_MODELER_MICS		
	}; // end enum mics
    
    const unsigned int BOX_MODELER_MIC_DEFAULT= BOX_MODELER_MIC_DYNAMIC;
    
    const char* const BOX_MODELER_MIC_CAPTIONS[NUM_BOX_MODELER_MICS]= { "Dynamic", "Condenser", "Ribbon" };
    
    //////////////////////////////////////////////////////////////////////////
	//! Box modeler parameter ranges and defaults
    const float BOX_MODELER_INPUT_GAIN_MIN= -20.0f,
                BOX_MODELER_INPUT_GAIN_MAX= 10.0f,
                BOX_MODELER_INPUT_GAIN_DEFAULT= -3.3f,
                BOX_MODELER_SEPARATION_MIN= -30.0f,
                BOX_MODELER_SEPARATION_MAX= 30.0f,
                BOX_MODELER_SEPARATION_DEFAULT= 0.0f,
                BOX_MODELER_SPREAD_MIN= 0.0f,
                BOX_MODELER_SPREAD_MAX= 1.0f,
                BOX_MODELER_SPREAD_DEFAULT= 1.0f,
                BOX_MODELER_MIX_PERCENT_MIN= 0.0f,
                BOX_MODELER_MIX_PERCENT_MAX= 100.0f,
                BOX_MODELER_MIX_PERCENT_DEFAULT= 100.0f,
                BOX_MODELER_OUTPUT_GAIN_MIN= -20.0f,
                BOX_MODELER_OUTPUT_GAIN_MAX= 10.0f,
                BOX_MODELER_OUTPUT_GAIN_DEFAULT= 0.0f;
    
} // end namespace iZTrashFX

#endif // multiple inclusion