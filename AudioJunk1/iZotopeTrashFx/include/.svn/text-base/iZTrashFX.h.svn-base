///////////////////////////////////////////////////////////
//
// iZTrashFX.h: iZotope TrashFX Engine Interface
// Copyright (c) 2004-2011 - iZotope, Inc.  All Rights Reserved
// PackageID: %PACKAGEID%
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __IZTrashFX_H_7494296__
#define __IZTrashFX_H_7494296__

#include "constants_iZTrashFX.h"

namespace iZTrashFX {
	
	//////////////////////////////////////////////////////////////////////////////
	//! iZotope TrashFX Engine
	class TrashFXEngine {
	public:
		//- -------------------------------------------------------------------------
		//	Engine creation and destruction
		//- -------------------------------------------------------------------------
		//! Creates a new TrashFX engine.
		static ErrorCode Create( TrashFXEngine** ppInstance, unsigned int uNumChannels, unsigned int uSamplesPerSecond );
		//! Destroys the given instance of the iZotope TrashFX Engine
		static ErrorCode Destroy( TrashFXEngine* pInstance );
        
        //! Get the version number and build number
        virtual ErrorCode GetVersion( unsigned int& outBuildNumber, unsigned int& outMajor, unsigned int& outMinor )= 0;
		
        //- -------------------------------------------------------------------------
		//	Effect modules
		//- -------------------------------------------------------------------------
        //! Return whether Trash is currently enabled
		virtual ErrorCode IsTrashEnabled( bool& bOutTrashEnabled )= 0;
		//! Set whether Trash is currently enabled with a valid unlock key
		virtual ErrorCode SetTrashEnabled( bool bEnable, unsigned int uUnlockKey )= 0;
        
        //! Return whether Box Modeler is currently enabled
		virtual ErrorCode IsBoxModelerEnabled( bool& bOutBoxModelerEnabled )= 0;
		//! Set whether Box Modeler is currently enabled with a valid unlock key
		virtual ErrorCode SetBoxModelerEnabled( bool bEnable, unsigned int uUnlockKey )= 0;

        
        
        //- -------------------------------------------------------------------------
        //
        //  Trash (distortion)
        //
        //- -------------------------------------------------------------------------
        //! Get the distortion algorithm
		virtual ErrorCode GetTrashDistortionAlgorithm( unsigned int& uOutAlgorithm )= 0;
		//! Set the distortion algorithm
		virtual ErrorCode SetTrashDistortionAlgorithm( unsigned int uAlgorithm )= 0;
		
		//! Returns whether or not the algorithm uses the Trash parameter in distortion processing
		virtual ErrorCode GetAlgorithmDoesUseTrashParameter( unsigned int uAlgorithm, bool& bOutDoesUse )= 0;
        
        //! Get the distortion input gain
		virtual ErrorCode GetTrashDistortionInputGain( float& fOutGain )= 0;
		//! Set the distortion input gain
		virtual ErrorCode SetTrashDistortionInputGain( float fGain )= 0;

        //! Get the distortion overdrive
		virtual ErrorCode GetTrashDistortionOverdrive( float& fOutOverdrive )= 0;
		//! Set the distortion overdrive
		virtual ErrorCode SetTrashDistortionOverdrive( float fOverdrive )= 0;
		
        //! Get the distortion trash
		virtual ErrorCode GetTrashDistortionTrash( float& fOutTrash )= 0;
		//! Set the distortion trash 
		virtual ErrorCode SetTrashDistortionTrash( float fTrash )= 0;
		
        //! Get the distortion mix percent
		virtual ErrorCode GetTrashDistortionMixPercent( float& fOutMixPercent )= 0;
		//! Set the distortion mix percent
		virtual ErrorCode SetTrashDistortionMixPercent( float fMixPercent )= 0;
		
        //! Get the distortion output gain
		virtual ErrorCode GetTrashDistortionOutputGain( float& fOutOutputGain)= 0;
		//! Set the distortion output gain
		virtual ErrorCode SetTrashDistortionOutputGain( float fOutputGain )= 0;
        
        
        
        //- -------------------------------------------------------------------------
        //
        //  Box modeler
        //
        //- -------------------------------------------------------------------------
        //! Get the box modeler input gain
		virtual ErrorCode GetBoxModelerInputGain( float& fOutInputGain )= 0;
		//! Set the box modeler input gain
		virtual ErrorCode SetBoxModelerInputGain( float fInputGain )= 0;

        //! Get the box modeler microphone
		virtual ErrorCode GetBoxModelerMic( unsigned int& uOutMic )= 0;
		//! Set the box modeler microphone
		virtual ErrorCode SetBoxModelerMic( unsigned int uMic )= 0;
        
        //! Get the box modeler separation
		virtual ErrorCode GetBoxModelerSeparation( float& fOutSeparation )= 0;
		//! Set the box modeler separation
		virtual ErrorCode SetBoxModelerSeparation( float fSeparation )= 0;
        
        //! Get the box modeler spread
		virtual ErrorCode GetBoxModelerSpread( float& fOutSpread )= 0;
		//! Set the box modeler spread
		virtual ErrorCode SetBoxModelerSpread( float fSpread )= 0;
        
        //! Get the box modeler output gain
		virtual ErrorCode GetBoxModelerOutputGain( float& fOutOutputGain )= 0;
		//! Set the box modeler output gain
		virtual ErrorCode SetBoxModelerOutputGain( float fOutputGain )= 0;
        
        //! Get the box modeler mix
		virtual ErrorCode GetBoxModelerMixPercent( float& fOutMixPercent )= 0;
		//! Set the box modeler mix
		virtual ErrorCode SetBoxModelerMixPercent( float fMixPercent )= 0;
        
        //! Add the requested impulse to the box modeler
		virtual ErrorCode AddBoxModel( const char* file )= 0;
        
        //! Get the index of the current box model
		virtual ErrorCode GetBoxModel( unsigned int& uOutModel )= 0;
        //! Set the index of the current box model
		virtual ErrorCode SetBoxModel( unsigned int uModel )= 0;
        
        
        
        //- -------------------------------------------------------------------------
		//	Processing
		//- -------------------------------------------------------------------------
        //! Process given samples in place, for deinterleaved floats
		virtual ErrorCode ProcessInPlace( unsigned int uSampleFrames, float* const* pChannels )= 0;
		//! Process given samples in place, for deinterleaved shorts
		virtual ErrorCode ProcessInPlace( unsigned int uSampleFrames, short* const* pChannels )= 0;
		//! Process given samples in place, for interleaved floats
		virtual ErrorCode ProcessInPlace( unsigned int uSampleFrames, float* pInput )= 0;
		//! Process given samples in place, for interleaved shorts
		virtual ErrorCode ProcessInPlace( unsigned int uSampleFrames, short* pInput )= 0;
        
        //! Destroy the internal Trash engine
        virtual ErrorCode DestroyTrashEngine()= 0;
        //! Destroy the internal box modeler engine
        virtual ErrorCode DestroyBoxModelerEngine()= 0;
        
	protected:
		virtual ~TrashFXEngine() {} //!< Virtual destructor for proper polymorphic deletion
	}; // end class TrashFXEngine
	
} // end namespace iZTrashFX

#endif // multiple inclusion