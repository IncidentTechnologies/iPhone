//
//  AudioController.m
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AudioController.h"

// Native iPhone sampling rate of 44.1KHz 
const float g_GraphSampleRate = 44100.0f;

@implementation AudioController

@synthesize frequency, sinPhase;
//@synthesize m_pksobjects, m_pksobjects_n;

-(id) init
{
	if(self = [super init])
	{                
        m_pksobjects_n = 6;
		m_pksobjects = new KSObject[m_pksobjects_n];
		for(int i = 0; i < m_pksobjects_n ; i++)
        {
			m_pksobjects[i].m_Fs = g_GraphSampleRate;
            m_pksobjects[i].SetBWFilterOrder(0);        // set to order 0 by default since this is performance hungry
        }
        
        // Set up the oscs
        m_pSineOsc = new SineOscillator(440.0f, g_GraphSampleRate);
        m_pSawOsc = new SawOscillator(440.0f, g_GraphSampleRate);
        m_pSquareOsc = new SquareOscillator(440.0f, g_GraphSampleRate);
        
        // set up the BW filter
        m_pBwFilter = new ButterWorthFilter(2, 2000, g_GraphSampleRate);
        
        // Used for the other synths in the controller 
        m_fNoteOn = false;
        
        // Set up the Chorus Effect
        m_pChorusEffect = new ChorusEffect(20,                      // delay
                                           0.75f,                   // depth
                                           0.05f,                   // width
                                           3.0f,                    // Freq
                                           1.0f,                    // Wet level
                                           g_GraphSampleRate        // sampling rate
                                          );
        m_pChorusEffect->SetPassThru(true);
        
        // Set up the Delay Effect
        m_pDelayEffect = new DelayEffect(650, 0.5, 0.85, g_GraphSampleRate);
        m_pDelayEffect->SetPassThru(true);
        
        // Set up the distortion effect
        m_pDistortionEffect = new DistortionEffect(5.0f, 1.0f, g_GraphSampleRate);
        m_pDistortionEffect->SetPassThru(true);
        
        // Set up the iZotope Engine
        iZTrashFX::TrashFXEngine::Create(&m_pTFXEngine, 1, g_GraphSampleRate);
        m_pTFXEngine->SetTrashEnabled(TRUE, IZOTOPE_TRASH_UNLOCK);
        m_pTFXEngine->SetBoxModelerEnabled(TRUE, IZOTOPE_BOX_MODELER_UNLOCK);
        
        m_pTFXEngine->SetTrashDistortionAlgorithm(iZTrashFX::TRASH_DISTORTION_TAPE_SATURATION);
        m_pTFXEngine->SetTrashDistortionOverdrive(5.0f);
        
        m_pTFXEngine->SetTrashDistortionTrash(0.5f);
        
        m_pTFXEngine->SetBoxModelerMic(iZTrashFX::BOX_MODELER_MIC_DYNAMIC);
        m_pTFXEngine->SetBoxModelerSeparation(15.0f);
        
        m_pTFXEngine->AddBoxModel("Device - Metal Barrel.trashbox");            // 0
        m_pTFXEngine->AddBoxModel("Amp-Worcester Modified.trashbox");           // 1
        m_pTFXEngine->AddBoxModel("Amp-Worcester Bright.trashbox");             // 2
        m_pTFXEngine->AddBoxModel("Amp-Oxford Classic.trashbox");               // 3
        m_pTFXEngine->AddBoxModel("Amp-Oakdale 2x12.trashbox");                 // 4
        m_pTFXEngine->AddBoxModel("Amp-Leicester Boutique.trashbox");           // 5
        m_pTFXEngine->AddBoxModel("Amp-Harvard Standard.trashbox");             // 6
        m_pTFXEngine->AddBoxModel("Amp-Allston Classic.trashbox");              // 7
        m_pTFXEngine->AddBoxModel("Amp-Worcester 2x12.trashbox");               // 8
        
        m_pTFXEngine->SetBoxModel(2);
        m_pTFXEngine->SetBoxModelerMixPercent(100.0f);
        m_pTFXEngine->SetBoxModelerOutputGain(5.0f);
        
	}
	
	return self;
}

// Starts the render
- (void) startAUGraph
{
	// Reset the phase of the wavetable
	sinPhase = 0.0f;
	
	// Starts the AUGraph
	OSStatus result = AUGraphStart(augraph);
	
	// Print the result
	if(result)
	{
		printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result);
	}
	
	return;
}

- (void) SetWaveform:(int)WaveformSelect
{
	// Stop the graph
	[self stopAUGraph];
	
	// Set the aveform
	m_WaveformSelect = WaveformSelect;
	
	[self startAUGraph];	// this should also reset the phase
	
}

- (void) KillString:(int)string
{
    if(string >= 0 && string < m_pksobjects_n)
        m_pksobjects[string].Kill();
}

- (void) PluckStringFret:(int)string atFret:(int)fret
{
	m_pksobjects[string].Pluck(KSObject::GuitarFreqLookup(string, fret));
}

- (bool) NoteOnStringFret:(int)string atFret:(int)fret
{
    frequency = KSObject::GuitarFreqLookup(string, fret);

    m_pSineOsc->NoteOn(frequency);
    m_pSawOsc->NoteOn(frequency);
    m_pSquareOsc->NoteOn(frequency);
    
    m_fNoteOn = true;
    
    return true;
}

- (void) SetAttentuation:(float)atten
{
	for(int i = 0; i < m_pksobjects_n; i++)
		m_pksobjects[i].m_attenuationKS = atten;
}

- (void) SetWaveFrequency:(float)freq
{
	//[self stopAUGraph];
	frequency = freq;
	//sinPhase = 0.0f;
	//[self startAUGraph];	// this will also reset the phase
    
    m_pSawOsc->SetFrequency(freq);
    m_pSineOsc->SetFrequency(freq);
    m_pSquareOsc->SetFrequency(freq);
    
}

- (bool) SetBWCutoff:(double)cutoff
{
    if(m_pBwFilter != NULL)
        return m_pBwFilter->SetCutoff(cutoff);
    else
        return false;
}

- (bool) SetBWOrder:(int)order
{
    return false;
}

- (bool) SetKSBWCutoff:(double)cutoff
{
    bool retVal = true;
    
    for(int i = 0; i < m_pksobjects_n; i++)
        if(!(retVal = m_pksobjects[i].SetBWFilterCutoff(cutoff)))
            break;
    
    return retVal;
}

- (bool) SetKSBWOrder:(int)order
{
    bool retVal = true;
    
    for(int i = 0; i < m_pksobjects_n; i++)
        if(!(retVal = m_pksobjects[i].SetBWFilterOrder(order)))
            break;
    
    return retVal;
}

- (bool) NoteOn:(double)freq
{
    m_fNoteOn = true;
    frequency = freq;    
    
    m_pSineOsc->NoteOn();
    m_pSquareOsc->NoteOn();
    m_pSawOsc->NoteOn();
    
    return true;
}

- (bool) NoteOff
{
    m_fNoteOn = false;   
    
    m_pSineOsc->NoteOff();
    m_pSawOsc->NoteOff();
    m_pSquareOsc->NoteOff();
    
    return true;
}

// Audio Render Callback Procedure 
// Don't allocate memory, don't take any locks, don't waste time
// This is a sensitive function that will be called many times
static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, 
							UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
	// Get a reference to the object that was passed with the callback
	// In this case, it is the AudioController object so we can access it's data in the static method
	AudioController *ac = (AudioController*)inRefCon;
	
	// Get a pointer to the dataBuffer of the AudioBufferList
	// This is the memory location we will look to fill at
	AudioSampleType *outA = (AudioSampleType*)ioData->mBuffers[0].mData;
	
	// Store this here in case the value changes during this callback
	// so we don't have phase problems
	float freq = ac->frequency;	
	
	// Pass in a reference to the phase value, you have to keep track
	// of it so that the sin wave resumes where the callback left off
	double phase = ac->sinPhase;
	
	// Phase Increment
	float phaseIncrement = (freq/2.0f) * (2 * M_PI) / g_GraphSampleRate;
    
    //double tempSample = 0.0f;
    float tempSample = 0.0f;
	
	// Loop through the callback buffer, generating the samples
	for(UInt32 i = 0; i < inNumberFrames; i++)
	{		
		switch (ac->m_WaveformSelect)
		{
			case 0:
			{
                // Sine
                tempSample = ac->m_pSineOsc->GetSample();                
			} break;
		
			case 1:
			{
				// Square
                tempSample = ac->m_pSawOsc->GetSample();
			} break;
				
			case 2:
			{
                // Square
                tempSample = ac->m_pSquareOsc->GetSample();
			} break;
				
			case 3:
			{
				// Karplus Strong Plucked String

				// Sum together all of the different strings
				// we should add some limiting logic here to ensure no clipping
				// occurs.
                tempSample = 0.0f;               
				
				for(int j = 0; j < ac->m_pksobjects_n; j++)
                    tempSample += (1.0f/6.0f) * ac->m_pksobjects[j].GetNextKSSample();
                
			} break;
                
            case 4:
            {
                // (Levels) Summation
                tempSample += ac->m_pSineOsc->GetSample();
                tempSample += ac->m_pSquareOsc->GetSample();
                tempSample += ac->m_pSawOsc->GetSample();
                
            } break;
		}
        
        // BW Filter
        if(ac->m_pBwFilter != NULL)
            tempSample = ac->m_pBwFilter->InputSample(tempSample);
        
        // Effects
        if(ac->m_pDelayEffect != NULL)  
            tempSample = ac->m_pDelayEffect->InputSample(tempSample);
        if(ac->m_pChorusEffect != NULL)
            tempSample = ac->m_pChorusEffect->InputSample(tempSample);
        if(ac->m_pDistortionEffect != NULL)
            tempSample = ac->m_pDistortionEffect->InputSample(tempSample);
        
        
        //ac->m_pTFXEngine->ProcessInPlace(1, &tempSample);
                
        
        /*
        // limit at 1.0f
        if(tempSample > 1.0f)
            tempSample = 1.0f;
        else if(tempSample < -1.0f)
            tempSample = -1.0f;
        */
        
        // Pass it to the output
        outA[i] = (SInt16)(tempSample * 32767.0f);
		
		// Calculate the phase for the next sample
		phase = phase + phaseIncrement;
		
		// Reset the phase value to prevent the float from overflowing
		if(phase >= 2 * M_PI)
			phase = phase - 2 * M_PI;
	}
    
    // process the saples in the buffer
    //ac->m_pTFXEngine->ProcessInPlace(inNumberFrames, (short*)outA);
	
	// Store the phase for next time
	ac->sinPhase = phase;
	
	return noErr;
}

- (void) initializeAUGraph:(int)waveform;
{
	OSStatus result = noErr;
    frequency= 440;
	m_WaveformSelect = waveform;
	
	// Create the AUGraph
	result = NewAUGraph(&augraph);
	
	// AUNodes represent Audio Units on the AUGraph and provide
	// an easy way to connect them together
	AUNode outputNode;
	AUNode mixerNode;
	
	// Create an AudioComponentDescription for the AUs we want in the
	// graph mixer component
	AudioComponentDescription mixerDesc;
	mixerDesc.componentType = kAudioUnitType_Mixer;
	mixerDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixerDesc.componentFlags = 0;
	mixerDesc.componentFlagsMask = 0;
	mixerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Output Component
	AudioComponentDescription outputDesc;
	outputDesc.componentType = kAudioUnitType_Output;
	outputDesc.componentSubType = kAudioUnitSubType_RemoteIO;
	outputDesc.componentFlags = 0;
	outputDesc.componentFlagsMask = 0;
	outputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Add nodes to the graph to hold the audio units
	// You pass in a reference to the AudioComponentDescription
	// and get back an AudioUnit
	result = AUGraphAddNode(augraph, &outputDesc, &outputNode);
	result = AUGraphAddNode(augraph, &mixerDesc, &mixerNode);
	
	// Now we manage the connections in the audio graph
	// and connect the output of the mixer to the input of the output node
	result = AUGraphConnectNodeInput(augraph, mixerNode, 0, outputNode, 0);
	
	// Open the graph audio units.
	// Now open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(augraph);
	
	// Get a link to the mixer AU so that we can talk to it later
	result = AUGraphNodeInfo(augraph, mixerNode, NULL, &mixer);
	
	// MAKE CONNECTIONS TO THE MIXER UNIT's INPUTS
	// Set the number of input busses on the mixer's inputs
	// currently only using one bus
	
	UInt32 buses_n = 1;		// we use 6 buses, one for each guitar string
	
	
//	UInt32 buses_s = sizeof(buses_n);
	result = AudioUnitSetProperty(mixer, 
								  kAudioUnitProperty_ElementCount, 
								  kAudioUnitScope_Input, 
								  0, 
								  &buses_n, 
								  sizeof(buses_n));
	
	//Create the stream buffer description
	CAStreamBasicDescription desc;
	
	// Loop through and set up a callback for each source sent to the mixer
	// Right now we are only doing a single bus so the loop is a little redundant
	for(int i = 0; i < buses_n; ++i)
	{
		// Set up the render callback struct
		// This describes the function that will be called
		// to provide a buffer of audio for the mixer unit
		AURenderCallbackStruct renderCallbackStruct;
		renderCallbackStruct.inputProc = &renderInput;
		renderCallbackStruct.inputProcRefCon = self;
		
		// Set a callback for the specified node's specified output
		result = AUGraphSetNodeInputCallback(augraph, mixerNode, i, &renderCallbackStruct);
		
		// Get a CAStreamBasicDescription from the mixer bus
		UInt32 desc_s = sizeof(desc);
		result = AudioUnitGetProperty(mixer, 
									  kAudioUnitProperty_StreamFormat, 
									  kAudioUnitScope_Input, 
									  i, 
									  &desc, 
									  &desc_s);
		
		// Initialize structure to zero
		memset(&desc, 0, sizeof(desc));
		
		// Make modifications to the CAStreamBasicDescription
		// Using 16 bit ints to make it easier
		// mixer will accept either 16 bit ints or 32 bit fixed point ints
		desc.mSampleRate = g_GraphSampleRate;		// sample rate
		desc.mFormatID = kAudioFormatLinearPCM;		// Format
		
		desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
		//desc.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kLinearPCMFormatFlagIsNonInterleaved;
		
		desc.mBitsPerChannel = sizeof(AudioSampleType) * 8;
		desc.mChannelsPerFrame = 1;
		desc.mFramesPerPacket = 1;
		desc.mBytesPerFrame = (desc.mBitsPerChannel / 8) * desc.mChannelsPerFrame;
		desc.mBytesPerPacket = desc.mBytesPerFrame * desc.mFramesPerPacket;
		
		printf("Mixer File Format:");
		desc.Print();
		
		// Apply the modified CAStreamBasicDescription to the mixer output bus
		result = AudioUnitSetProperty(mixer, 
									  kAudioUnitProperty_StreamFormat, 
									  kAudioUnitScope_Input, 
									  i, 
									  &desc, 
									  sizeof(desc));
	}
	
	// Apply the CAStreamBasicDescription to the mixer output bus
	result = AudioUnitSetProperty(mixer, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  0, 
								  &desc, 
								  sizeof(desc));
	
	// SET UP THE OUTPUT STREAM
	UInt32 desc_s = sizeof(desc);
	
	// Get a CAudioStreamBasicDescription from the output audio unit
	result = AudioUnitGetProperty(mixer, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  0, 
								  &desc, 
								  &desc_s);
	
	// initialize the structure again
	memset(&desc, 0, sizeof(desc));
	
	// Make modifications to the CAStreamBasicDescription
	// AUCanonical on the iPhone is the 8.24 integer format that is native to the iPhone
	// The mixer unit does the format shifting for you
	desc.SetAUCanonical(1, true);
	desc.mSampleRate = g_GraphSampleRate;
	
	// Apply the modified CAStreamBasicDescription to the mixer output bus
	result = AudioUnitSetProperty(mixer, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Output, 
								  0, 
								  &desc, 
								  sizeof(desc));
	
	// Now call initialize to verify connections
	result = AUGraphInitialize(augraph);
}

// Stops the render
- (void) stopAUGraph
{
	Boolean fRunning = false;
	
	// Check to see if graph is running
	OSStatus result = AUGraphIsRunning(augraph, &fRunning);
	
	// If the graph is running, stop it
	if(fRunning)
	{
		result = AUGraphStop(augraph);
	}
	
	return;
}


- (void) dealloc
{
	[self stopAUGraph];
    
    DisposeAUGraph(augraph);
    
    if(m_pTFXEngine != NULL)
    {
        iZTrashFX::TrashFXEngine::Destroy(m_pTFXEngine);
        m_pTFXEngine = NULL;
    }
	
	/*
	if(BufferKS != NULL)
	{
		delete [] BufferKS;
		BufferKS = NULL;
	}*/
	
	[super dealloc];
}

@end
