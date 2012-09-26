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
		}
	}
	
	return self;
}

/*
- (SInt16) GetNextKSSample
{
	SInt16 CurVal = BufferKS[eBufferKS];
	SInt16 B;
	SInt16 C;
	
	if(eBufferKS + 1 >= BufferKS_n)
		B = BufferKS[0];
	else 
		B = BufferKS[eBufferKS + 1];
	
	if(eBufferKS + 2 >= BufferKS_n)
		C = BufferKS[eBufferKS + 2 - BufferKS_n - 1];
	else 
		C = BufferKS[eBufferKS + 2];


	float NewValf = attenuationKS * (0.5 * (float)(CurVal / 32767.0f) + 0.5 * (float)(B / 32767.0f) + 0.0 * (float)(C / 327676.0f));
	SInt16 NewVal = (SInt16)(NewValf * 32767.0f);
	
	// Now replace the current sample with the filtered one
	BufferKS[eBufferKS] = NewVal;
	
	eBufferKS++;
	if(eBufferKS >= BufferKS_n)
		eBufferKS = 0;	
	
	return CurVal;
}*/

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

- (void) PluckStringFret:(int)string atFret:(int)fret
{
	m_pksobjects[string].Pluck(KSObject::GuitarFreqLookup(string, fret));
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
	
	// Loop through the callback buffer, generating the samples
	for(UInt32 i = 0; i < inNumberFrames; i++)
	{		
		switch (ac->m_WaveformSelect)
		{
			case 0:
			{
				// Calculate the next sample		
				// put the sample into the buffer
				// Scale the [-1, 1] samples to the int in [-32767, 32767]
				outA[i] = (SInt16)(sin(phase) * 32767.0f);
			} break;
		
			case 1:
			{
				// Saw
				outA[i] = (SInt16)((((phase / (2 * M_PI)) - 0.5f) * 2.0f) * 32767.0f);
			} break;
				
			case 2:
			{
				// Square
				if(phase < M_PI)				
					outA[i] = (SInt16)(1.0f * 32767.0f);				
				else				
					outA[i] = (SInt16)(-1.0f * 32767.0f);				
			} break;
				
			case 3:
			{
				// Karplus Strong Plucked String

				// Sum together all of the different strings
				// we should add some limiting logic here to ensure no clipping
				// occurs.
				
				//outA[i] = ac->m_pksobjects[0].GetNextKSSample();;
				outA[i] = 0;
				int tempVals[ac->m_pksobjects_n];
				int tempValSum = 0;
				int NewValSum = 0;
                
                int NumReflections = 100;
                int RevVal = 0;
				
				for(int j = 0; j < ac->m_pksobjects_n; j++)
				{
					tempVals[j] = ac->m_pksobjects[j].GetNextKSSample();
					tempValSum += tempVals[j];
				}		
                
                /*
                for(int j = 2; j <= NumReflections; j++)
                {
                    // Add reverb here
                    int MemBufferIndex = ac->m_MemoryBuffer_c - j * (int)(SAMPLING_FREQUENCY * 0.02f);
                    if(MemBufferIndex < 0)
                        MemBufferIndex = ac->m_MemoryBuffer_n + MemBufferIndex;
                    if(MemBufferIndex >= 0 && MemBufferIndex < ac->m_MemoryBuffer_n)
                        RevVal += (int)((0.5f/NumReflections) * (float)(ac->m_MemoryBuffer[MemBufferIndex]));
                    else {
                        NSLog(@"MemBufferIndex:%d m_MemoryBuffer_n:%d m_MemoryBuffer_c:%d", MemBufferIndex, ac->m_MemoryBuffer_n, ac->m_MemoryBuffer_c);
                    }

                }
                 */
                
                tempValSum += RevVal;
				
                
                // Limit at 30000
				if(abs(tempValSum) > 30000)
				{
					// we need to limit the output
					for(int j = 0; j < ac->m_pksobjects_n; j++)
					{
						float ratio = (float) (abs(tempVals[j]) + (RevVal/ac->m_pksobjects_n)) / 32767.0f;
						NewValSum += (int) (tempVals[j]) * ratio;
					}	
					
					outA[i] = (SInt16)(NewValSum + RevVal);
                    
				}
				else 
				{
					for(int j = 0; j < ac->m_pksobjects_n; j++)
					{
						outA[i] += tempVals[j];
					}	
                    outA[i] += RevVal;
				}
                
                /*
                ac->m_MemoryBuffer[ac->m_MemoryBuffer_c] = outA[i];
                ac->m_MemoryBuffer_c++;
                if(ac->m_MemoryBuffer_c >= ac->m_MemoryBuffer_n)
                    ac->m_MemoryBuffer_c = 0;
                 */

				
			} break;
		}
		
		// Calculate the phase for the next sample
		phase = phase + phaseIncrement;
		
		// Reset the phase value to prevent the float from overflowing
		if(phase >= 2 * M_PI)
			phase = phase - 2 * M_PI;
	}
	
	// Store the phase for next time
	ac->sinPhase = phase;
	
	return noErr;
}

- (void) initializeAUGraph:(float)freq withWaveform:(int)waveform;
{
	OSStatus result = noErr;
	frequency = freq;
	m_WaveformSelect = waveform;
    
    // set up the memory buffer
    /*
    m_MemoryBuffer_n = SAMPLING_FREQUENCY * 20;
    m_MemoryBuffer = new SInt16[m_MemoryBuffer_n];
    memset(m_MemoryBuffer, 0, sizeof(SInt16) * m_MemoryBuffer_n);
    m_MemoryBuffer_c = 0;
     */
	
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
	DisposeAUGraph(augraph);
	
	/*
	if(BufferKS != NULL)
	{
		delete [] BufferKS;
		BufferKS = NULL;
	}*/
	
	[super dealloc];
}

@end
