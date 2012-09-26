//
//  AudioController.h
//  AudioJunk1
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"

#define MIN_FREQ 25
#define SAMPLING_FREQUENCY 44100

class KSObject
{
public:
	KSObject() :
		m_BufferKS(NULL),
		m_eBufferKS(0),
		m_FreqKS(0),
		m_Fs(44100.0f),
		m_attenuationKS(0.99f)
	{
        m_BufferKS_n = (int) m_Fs / MIN_FREQ;
        m_BufferKS = new SInt16[m_BufferKS_n];
        memset(m_BufferKS, 0, sizeof(SInt16) * m_BufferKS_n);
	}
	
	KSObject(float SamplingFreq) :
		m_BufferKS(NULL),
		m_eBufferKS(0),
		m_FreqKS(420),
		m_Fs(SamplingFreq),
		m_attenuationKS(0.99f)
	{
		m_BufferKS_n = (int) m_Fs / MIN_FREQ;
        m_BufferKS = new SInt16[m_BufferKS_n];
        memset(m_BufferKS, 0, sizeof(SInt16) * m_BufferKS_n);
	}
	
	void Pluck(float freq)
	{
		// set up an example pluck
		m_FreqKS = freq;
		m_BufferKS_CurLength = (int) m_Fs / m_FreqKS;
		m_eBufferKS = m_BufferKS_CurLength - 1;
		
		srand( time(NULL) );
		
		// Now initialize the delay line buffer with noise
		for(int i = 0; i < m_BufferKS_CurLength; i++)
		{
			float randFloat = (float)rand() / (float)RAND_MAX;
			float randFloatAdj = (randFloat - 0.5f) * 2.0f;
			SInt16 randSInt16 = (SInt16)(randFloatAdj * 32767.0f);
			m_BufferKS[i] = randSInt16;
		}
	}
	
	SInt16 GetNextKSSample()
	{
		// first ensure that the pluck is initialized
		if(m_BufferKS == NULL || m_FreqKS == 0)
			return 0;
		
		SInt16 CurVal;
		SInt16 B;
		SInt16 C;
		
		CurVal = m_BufferKS[m_eBufferKS];
		
		if(m_eBufferKS + 1 >= m_BufferKS_CurLength)
			B = m_BufferKS[0];
		else 
			B = m_BufferKS[m_eBufferKS + 1];
		
		if(m_eBufferKS + 2 >= m_BufferKS_CurLength)
			C = m_BufferKS[m_eBufferKS + 2 - m_BufferKS_CurLength - 1];
		else 
			C = m_BufferKS[m_eBufferKS + 2];		
		
		float NewValf = m_attenuationKS * (0.5 * (float)(CurVal / 32767.0f) + 0.5 * (float)(B / 32767.0f) + 0.0 * (float)(C / 327676.0f));
		SInt16 NewVal = (SInt16)(NewValf * 32767.0f);
		
		// Now replace the current sample with the filtered one
		m_BufferKS[m_eBufferKS] = NewVal;
		
		m_eBufferKS++;
		if(m_eBufferKS >= m_BufferKS_CurLength)
			m_eBufferKS = 0;	
		
		return CurVal;
	}
	
	~KSObject()
	{	
		if(m_BufferKS != NULL)
		{
			delete [] m_BufferKS;
			m_BufferKS = NULL;
		}
	}
	
private:
	SInt16 *m_BufferKS;
	int m_BufferKS_n;
    int m_BufferKS_CurLength;
	int m_eBufferKS;
	float m_FreqKS;
	
public:
	float m_Fs;
	
public:
	float m_attenuationKS;
	
public:
	static float GuitarFreqLookup(int string, int fret)
	{
		int midi = 40 + string * 5;
		if(string > 3) 
			midi -= 1;
		
		midi += fret;
		
		// Now we have the midi note we can get the frequency
		// f = Fr * 2^(midi / 12)
		float f = 440.0f * pow(2.0, (float)(midi - 69) / 12.0f);
		
		return f;
	}
};

@interface AudioController : NSObject 
{
	// Audio Graph Members
	AUGraph augraph;
	AudioUnit mixer;
	
	// Audio Stream Descriptors
	CAStreamBasicDescription outputCASBD;
	

	// Sine Phase Indicator;
	double sinPhase;
	float frequency;
	
	int m_WaveformSelect;
	
	/*
	SInt16 *BufferKS;
	int BufferKS_n;
	int cBufferKS;
	int eBufferKS;
	float FreqKS;
	float attenuationKS;
	 */
	
	KSObject *m_pksobjects;
	int m_pksobjects_n;
    
    // Hold on to the last second of samples
    /*
    SInt16 *m_MemoryBuffer;
    int m_MemoryBuffer_n;
    int m_MemoryBuffer_c;
     */
	
}

@property (assign) float frequency;
@property (assign) double sinPhase;
//@property (assign) float attenuationKS;

//@property (assign) KSObject *m_pksobjects;
//@property (readonly) int m_pksobjects_n;

- (void) initializeAUGraph:(float)freq withWaveform:(int)waveform;
- (void) startAUGraph;
- (void) stopAUGraph;

- (void) SetWaveform:(int)WaveformSelect;
- (void) SetWaveFrequency:(float)freq;

- (void) PluckStringFret:(int)string atFret:(int)fret;
- (void) SetAttentuation:(float)atten;

@end
