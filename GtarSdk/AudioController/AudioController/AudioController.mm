//
//  AudioController.m
//  AudioController
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 Incident Technologies. All rights reserved.
//

#import "AudioController.h"
#import "CAStreamBasicDescription.h"

#import "Sampler.h"
#import "Effect.h"
#import "Distortion.h"
#import "TanhDistortion.h"
#import "Overdrive.h"
#import "HardCutoffDistortion.h"
#import "SoftClippingOverdrive.h"
#import "FuzzExpDistortion.h"
#import "DelayEffect.h"
#import "ChorusEffect.h"
#import "Reverb.h"
#import "ButterWorthFilter.h"
#import "KSObject.h"
#import "Compressor.h"

// Native iPhone sampling rate of 44.1KHz 
const float g_GraphSampleRate = 44100.0f;

@implementation AudioController

@synthesize frequency;
@synthesize sinPhase;
@synthesize m_fNoteOn;

@synthesize m_LimiterOn;

@synthesize m_volumeGain;

- (id) initWithAudioSource:(AudioSource)audioSource AndInstrument:(NSString*)instrument
{
	if(self = [super init])
	{
        // Default audio route to speaker
        [self RouteAudioToSpeaker];
        
        m_audioSource = audioSource;
        
		m_pksobjects_n = 6;
		m_pksobjects = new KSObject[m_pksobjects_n];
        // Set up attenuation for each string. Higher strings will be attenuated less.
        /* TODO: The reason different attenuations are needed is because the lowpass filter
           (running averager) used in the KS model will attenuate higher freq more (its a LP)
           Look into using a simple LP filter with an adjustable cutoff that increases with
           higher frequencies, so that the same attenuation factor can be used for all strings.
         */
        float stringAttenuation[] = {0.9928f, 0.9945f, 0.9957f, 0.9967f, 0.9972f, 0.9983f};
		for(int i = 0; i < m_pksobjects_n ; i++)
        {
			m_pksobjects[i].m_Fs = g_GraphSampleRate;
            m_pksobjects[i].SetBWFilterOrder(0);        // set to order 0 by default since this is performance hungry
            m_pksobjects[i].m_attenuationKS = stringAttenuation[i];
        }
        
        // set up the BW filter
        m_pBwFilter = new ButterWorthFilter(2, 8000, g_GraphSampleRate);
        
        // Used for the other synths in the controller 
        m_fNoteOn = false;
        
        // Set up the Chorus Effect
        m_pChorusEffect = new ChorusEffect(25,                      // delay
                                           0.75f,                   // depth
                                           0.05f,                   // width
                                           3.0f,                    // Freq
                                           1.0f,                    // Wet level
                                           g_GraphSampleRate        // sampling rate
                                           );
        m_pChorusEffect->SetPassThru(true);
        m_effects.push_back(m_pChorusEffect);
        
        // Set up the Delay Effect
        m_pDelayEffect = new DelayEffect(20, 0.5, 1.0, g_GraphSampleRate);
        m_pDelayEffect->SetPassThru(true);
        m_effects.push_back(m_pDelayEffect);
        
        // Set up the Reverb effect
        m_pReverbEffect = new Reverb(0.75, g_GraphSampleRate);
        m_pReverbEffect->SetPassThru(true);
        m_effects.push_back(m_pReverbEffect);
        
        // Set up the distortion effects
        m_pDistortion = new Distortion(3.78f, 0.25f, g_GraphSampleRate);
        m_pDistortion->SetPassThru(true);
        m_effects.push_back(m_pDistortion);
        m_pDistortion->getPrimaryParam().getValue();

        m_pTanhDistortion = new TanhDistortion(1.0, 1.0, g_GraphSampleRate);
        m_pTanhDistortion->SetPassThru(true);
       
        m_pOverdrive = new Overdrive(5.0, 1.0, g_GraphSampleRate);
        m_pOverdrive->SetPassThru(true);
        
        m_pHardCutoffDistortion = new HardCutoffDistortion(1.0, 1.0, g_GraphSampleRate);
        m_pHardCutoffDistortion->SetPassThru(true);
        
        m_pSoftClipOverdriveEffect = new SoftClippingOverdrive(1.0, 5, 1.0, g_GraphSampleRate);
        m_pSoftClipOverdriveEffect->SetPassThru(true);
        
        m_pFuzzExpDistortion = new FuzzExpDistortion(1.0, 1.0, g_GraphSampleRate);
        m_pFuzzExpDistortion->SetPassThru(true);
        
        m_pEndBwFilter = new ButterWorthFilter(2, 8000, g_GraphSampleRate);
        
        m_tempOut = new Float32[4096];
        
        // setup compressor
        m_LimiterOn = true;
        m_pCompressor = new Compressor(.97, 3, 1, 5000, g_GraphSampleRate);
        
        if (SamplerSource == m_audioSource)
        {
            m_sampler = [[Sampler alloc] initWithSampleRate:g_GraphSampleRate AndSamplePack:instrument];
        }
        
        m_volumeGain = 1.0;
        
        // seed rand for use by all audio generators and effects
        srand( time(NULL) );
	}
	
	return self;
}

// Starts the audio render
- (void) startAUGraph
{
    Boolean fRunning;
    AUGraphIsRunning(augraph, &fRunning);
    if (fRunning)
    {
        // AUGraph already running, do not call AUGraphStart again, multiple
        // calls to start requires the same number of calls to stop (i.e. a 
        // single call to stop after multiple start calls will not stop the 
        // AU graph. There is no need or benefit to make multiple start calls.
        return;
    }
    
	// Reset the phase of the wavetable
	sinPhase = 0.0f;
	
	// Starts the AUGraph
	OSStatus result = AUGraphStart(augraph);
	
	// Print the result
	if(result)
	{
		printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result);
	}
	
    // Announce what audio route we are using
    [self AnnounceAudioRouteChange];
    
	return;
}

- (void) SetAudioSource:(AudioSource)audioSource
{
	// Stop the graph
	[self stopAUGraph];
	
	// Set the aveform
	m_audioSource = audioSource;
	
	[self startAUGraph];	// this should also reset the phase
}

// TODO: get rid of this method and only use the one with amplitude.
- (void) PluckString:(int)string atFret:(int)fret
{
    if (string < 0 || string > 5 || fret < 0 || fret > 16)
    {
        NSLog(@"invalid plucking position, string:%d fret:%d", string, fret);
        return;
    }
    
    [self PluckString:string atFret:fret withAmplitude:1.0f];
}

- (void) PluckString:(int)string atFret:(int)fret withAmplitude:(float)amp
{
    if (string < 0 || string > 5 || fret < 0 || fret > 16)
    {
        NSLog(@"invalid plucking position, string:%d fret:%d", string, fret);
        return;
    }
    
    if (KarplusStrong == m_audioSource)
    {
        m_pksobjects[string].Pluck(KSObject::GuitarFreqLookup(string, fret), amp);
    }
    else if (SamplerSource == m_audioSource)
    {
        [m_sampler PluckString:string atFret:fret withAmplitude:amp];
    }
    else // synth
    {
        [self NoteOnAtString:string andFret:fret];
    }
}

- (void) PluckMutedString:(int)string
{
    [m_sampler PluckMutedString:string];
}

- (bool) FretDown:(int)fret onString:(int)string
{
    Boolean running = false;
	AUGraphIsRunning(augraph, &running);
    if (!running)
    {
        return false;
    }
    
    if (SamplerSource == m_audioSource)
    {
        [m_sampler FretDown:fret onString:string];
    }
    
    return true;
}

- (bool) FretUp:(int)fret onString:(int)string
{
    if (SamplerSource == m_audioSource)
    {
        [m_sampler FretUp:fret onString:string];
    }
    
    return true;   
}

- (bool) NoteOnAtString:(int)string andFret:(int)fret
{
    // needs strings to be zero based
    string--;
    
    frequency = KSObject::GuitarFreqLookup(string, fret);
    m_fNoteOn = true;
    return true;
}

- (bool) NoteOffAtString:(int)string andFret:(int)fret
{
    if (KarplusStrong == m_audioSource)
    {
        m_fNoteOn = false;
    }
    else if (SamplerSource == m_audioSource)
    {
        [m_sampler noteOffAtString:(int)string andFret:fret];
    }
    
    return true;
}

#pragma mark - Setters

- (void) SetAttentuation:(float)atten
{
	for(int i = 0; i < m_pksobjects_n; i++)
		m_pksobjects[i].m_attenuationKS = atten;
}

- (void) SetKSAttenuation:(float)atten forString:(int)string
{
    m_pksobjects[string].m_attenuationKS = atten;
}

- (bool) SetAttenuationVariation:(float)variation
{
    for(int i = 0; i < m_pksobjects_n; i++)
		m_pksobjects[i].SetAttenuationVariation(variation);
    
    return true;
}

- (void) SetWaveFrequency:(float)freq
{
	frequency = freq;
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

- (bool) SetReverbWet:(double)wet
{
    return m_pReverbEffect->SetWet(wet);
}

- (bool) SetReverbPassThrough:(bool)passThrough
{
    return m_pReverbEffect->SetPassThru(passThrough);
}

- (bool) SetReverbBandwidth:(double)bandwidth
{
    return m_pReverbEffect->SetBandwidth(bandwidth);
}

- (bool) SetReverbDamping:(double)damping
{
    return m_pReverbEffect->SetDamping(damping);    
}

- (bool) SetReverbDecay:(double)decay
{
    return m_pReverbEffect->SetDecay(decay);
}

- (bool) SetReverbInputDiffusion1:(double)inputDiffusion1
{
    return m_pReverbEffect->SetInputDiffusion1(inputDiffusion1);
}

- (bool) SetReverbInputDiffusion2:(double)inputDiffusion2
{
    return m_pReverbEffect->SetInputDiffusion2(inputDiffusion2);
}

- (bool) SetReverbDecayDiffusion1:(double)decayDiffusion1
{
    return m_pReverbEffect->SetDecayDiffusion1(decayDiffusion1);
}

- (bool) SetReverbDecayDiffusion2:(double)decayDiffusion2
{
    return m_pReverbEffect->SetDecayDiffusion2(decayDiffusion2);
}

- (bool) SetPreDelayLineLength:(double)scale
{
    return m_pReverbEffect->SetPreDelayLength(scale);    
}

- (bool) SetDelayLineL1Length:(double)length
{
    return m_pReverbEffect->SetDelayL1Length(length);
}

- (bool) SetDelayLineL2Length:(double)length
{
    return m_pReverbEffect->SetDelayL2Length(length);
}

- (bool) SetDelayLineR1Length:(double)length
{
    return m_pReverbEffect->SetDelayR1Length(length);
}

- (bool) SetDelayLineR2Length:(double)length
{
    return m_pReverbEffect->SetDelayR2Length(length);
}

- (bool) SetDistortion2PassThrough:(bool)passThrough
{
    return m_pTanhDistortion->SetPassThru(passThrough);
}

- (bool) SetTanhDistortionPosFactor:(double)factor
{
    return m_pTanhDistortion->setPosFactor(factor);
}

- (bool) SetTanhDistortionNegFactor:(double)factor
{
    return m_pTanhDistortion->setNegFactor(factor);    
}

- (bool) SetCutffDistortionPassThrough:(bool)passThrough
{
    return m_pHardCutoffDistortion->SetPassThru(passThrough);
}

- (bool) SetCutoffDistortionCutoff:(double)cutoff
{
    return m_pHardCutoffDistortion->SetCutoff(cutoff);
}

- (bool) SetOverdrivePassThru:(bool)passThru
{
    return m_pOverdrive->SetPassThru(passThru);
}

- (bool) SetOverdrive:(double)gain
{
    return m_pOverdrive->SetGain(gain);
}

- (bool) SetSoftClipOverdrivePassThru:(bool)passThru
{
    return m_pSoftClipOverdriveEffect->SetPassThru(passThru);
}

- (bool) SetSoftClipOverdriveThreshold:(double)threshold
{
    return m_pSoftClipOverdriveEffect->SetThreshold(threshold);
}

- (bool) SetSoftClipOverdriveMultiplier:(double)multiplier
{
    return m_pSoftClipOverdriveEffect->SetMultiplier(multiplier);
}

- (bool) SetFuzzExpPassThru:(bool)passThru
{
    return m_pFuzzExpDistortion->SetPassThru(passThru);
}

- (bool) SetFuzzExpGain:(double)gain
{
    return m_pFuzzExpDistortion->SetGain(gain);
}

- (void) SetKS3rdOrderHarmonicOn:(bool)on
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].Set3rdOrderHarmonicOn(on);
    }
}

- (void) SetKS5thOrderHarmonicOn:(bool)on
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].Set5thOrderHarmonicOn(on);
    }
}

- (bool) SetKSNoiseScale:(float)scale
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].SetNoiseScale(scale);
    }
    return true;
}

- (bool) SetKSNoiseVariation:(float)variation
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].SetNoiseVariation(variation);
    }
    return true;
}


- (void) SetKSSawToothOn:(bool)on
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].SetSawToothOn(on);
    }
}

- (bool) SetKSSawToothMultiplier:(float)multiplier
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].SetSawMultiplier(multiplier);
    }
    return true;
}

- (void) SetKSSqWaveOn:(bool)on
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].SetSqWaveOn(on);
    }    
}

- (bool) SetKSSqWaveMultiplier:(float)multiplier
{
    for(int i = 0; i < m_pksobjects_n ; i++)
    {
        m_pksobjects[i].SetSqMultiplier(multiplier);
    }
    return true;
}

- (NSArray*) GetEffects
{
    NSMutableArray *effects = [NSMutableArray array];
    
    for (int i = 0; i < m_effects.size(); i++)
    {
        Effect *e  = m_effects[i];
        NSValue *val = [NSValue valueWithPointer:e];
        [effects addObject:val];
    }
    
    return effects;
}

- (NSArray*) getEffectNames
{
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:m_effects.size()];
    for (int i = 0; i < m_effects.size(); i++)
    {
        [names addObject:[NSString stringWithCString:m_effects[i]->getName().c_str() encoding:[NSString defaultCStringEncoding]]];
    }

    return names;
}

- (Parameter&) getReverbLFO
{
    return m_pReverbEffect->getLFO();
}

- (Parameter&) getReverbExcursion
{
    return m_pReverbEffect->getExcursion();
}

- (NSArray*) getInstrumentNames
{
    return [m_sampler getInstrumentNames];
}

- (int) getCurrentSamplePackIndex
{
    return [m_sampler getCurrentSamplePackIndex];
}

void AudioControllerPropertyListener (void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData)
{
    if (inID != kAudioSessionProperty_AudioRouteChange) return;
    
    AudioController *ac = (AudioController*)inClientData;
    
    CFStringRef newRoute = [ac GetAudioRoute];
    
    // If the audio source is set to the Receiver, force it to the speaker.
    if ([(NSString*)newRoute isEqualToString:(NSString*)kAudioSessionOutputRoute_BuiltInReceiver] == YES)
    {
        [ac RouteAudioToSpeaker];
        return;
    }
    
    bool routeIsSpeaker = [(NSString*)newRoute isEqualToString:(NSString*)kAudioSessionOutputRoute_BuiltInSpeaker];
    
    NSDictionary *routeData = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:routeIsSpeaker], @"isRouteSpeaker",
            (NSString*)newRoute, @"routeName", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioRouteChange" object:ac userInfo:routeData];
    
    [ac AnnounceAudioRouteChange];
}

// Callback for audio interruption, e.g. a phone call coming in".
void AudioInterruptionListener (void *inClientData, UInt32 inInterruptionState)
{
    AudioController *ac = (AudioController *)inClientData;
    
    // stop audio graph when an interruption comes in, and restart it when the interruption
    // is done.
    if (inInterruptionState == kAudioSessionBeginInterruption)
    {
        AudioSessionSetActive(false);
        [ac stopAUGraph];
    }
    else if (inInterruptionState == kAudioSessionEndInterruption)
    {
        AudioSessionSetActive(true);
        [ac startAUGraph];
    }
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
    
    float tempSample = 0;
	
	// Loop through the callback buffer, generating the samples
	for(UInt32 i = 0; i < inNumberFrames; i++)
	{
		switch (ac->m_audioSource)
		{
            case KarplusStrong:
			{
				// Karplus Strong Plucked String
                
				// Sum together all of the different strings
				// we should add some limiting logic here to ensure no clipping
				// occurs.
                tempSample = 0.0f;               
				
				for(int j = 0; j < ac->m_pksobjects_n; j++)
                    tempSample += ac->m_pksobjects[j].GetNextKSSample();
                
			} break;
            case SamplerSource:
            {
                tempSample = [ac->m_sampler getNextSample];
            } break;
			case SinWave:
			{
				// Calculate the next sample		
				// put the sample into the buffer
				// Scale the [-1, 1] samples to the int in [-32767, 32767]
                if(ac->m_fNoteOn)
                    //outA[i] = (SInt16)(sin(phase) * 32767.0f);
                    tempSample = sin(phase);
                else
                    tempSample = 0.0f;
			} break;
                
			case SawWave:
			{
				// Saw
                if(ac->m_fNoteOn)
                    //outA[i] = (SInt16)((((phase / (2 * M_PI)) - 0.5f) * 2.0f) * 32767.0f);
                    tempSample = ((phase / (2 * M_PI)) - 0.5f) * 2.0f;
                else
                    tempSample = 0.0f;
			} break;
				
			case SquareWave:
			{
				// Square
                if(ac->m_fNoteOn)
                {
                    if(phase < M_PI)				
                        tempSample = 1.0f;			
                    else				
                        tempSample = -1.0f;
                }
                else
                    tempSample = 0.0f;
			} break;
		}
        
        
        if(ac->m_pReverbEffect != NULL)
            tempSample = ac->m_pReverbEffect->InputSample(tempSample);
        
        if(ac->m_pDistortion != NULL)
            tempSample = ac->m_pDistortion->InputSample(tempSample);
        
        if(ac->m_pTanhDistortion != NULL)
            tempSample = ac->m_pTanhDistortion->InputSample(tempSample);

        // These conditionals are never hit and cost several % CPU in total
        if(ac->m_pOverdrive != NULL)
            tempSample = ac->m_pOverdrive->InputSample(tempSample);
        
        if(ac->m_pHardCutoffDistortion != NULL)
            tempSample = ac->m_pHardCutoffDistortion->InputSample(tempSample);
        
        if(ac->m_pSoftClipOverdriveEffect != NULL)
            tempSample = ac->m_pSoftClipOverdriveEffect->InputSample(tempSample);
        
        if(ac->m_pFuzzExpDistortion != NULL)
            tempSample = ac->m_pFuzzExpDistortion->InputSample(tempSample);
           
        //if(ac->m_pEndBwFilter != NULL)
            //tempSample = ac->m_pEndBwFilter->InputSample(tempSample);
        
        if(ac->m_pDelayEffect != NULL)  
            tempSample = ac->m_pDelayEffect->InputSample(tempSample);
        
        if(ac->m_pChorusEffect != NULL)
            tempSample = ac->m_pChorusEffect->InputSample(tempSample);
        
        if(ac->m_pBwFilter != NULL)
            tempSample = ac->m_pBwFilter->InputSample(tempSample); 
        
        // Pass it to the output
        ac->m_tempOut[i] = tempSample * ac->m_volumeGain;
		
		// Calculate the phase for the next sample
		phase = phase + phaseIncrement;
		
		// Reset the phase value to prevent the float from overflowing
		if(phase >= 2 * M_PI)
			phase = phase - 2 * M_PI;
	}
    
    if (ac->m_LimiterOn)
    {
        // Compress output to prevent any distortion from clipping
        ac->m_pCompressor->Process<Float32, 1>(inNumberFrames, ac->m_tempOut);
    }
    
    for (UInt32 i = 0; i < inNumberFrames; i++)
	{
        outA[i] = (SInt16)(ac->m_tempOut[i] * 32767.0f);
        
        //Limit at 32700
        if(outA[i] > 32700) 
            outA[i] = 32700;
        else if(outA[i] < -32700) 
            outA[i] = -32700;
    }
    //ac->m_pCoreFXEngine->ProcessInPlace( inNumberFrames, outA);
    //ac->m_pTrashFXEngine->ProcessInPlace( inNumberFrames, outA);

	// Store the phase for next time
	ac->sinPhase = phase;
	
	return noErr;
}

- (void) initializeAUGraph;
{
	OSStatus result = noErr;
    frequency= 440;
    
    OSStatus status = AudioSessionInitialize ( NULL,
                                              NULL,
                                              AudioInterruptionListener,
                                              self );
    
    if ( status == 0 )
    {
        
        // do it
        UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
        status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        
        if ( status == 0 )
        {
            NSLog(@"Mute override enabled!");
        }
        else
        {
            NSError * error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                  code:status
                                              userInfo:nil];
            
            NSLog(@"SetProp OSStatus: %@", [error description]);
        }
        
    }
    else
    {
        NSError * error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                              code:status
                                          userInfo:nil];
        
        NSLog(@"Init OSStatus: %@", [error description]);
    }
    
    // Register a property change handler
    status = AudioSessionAddPropertyListener( kAudioSessionProperty_AudioRouteChange, &AudioControllerPropertyListener, self );
    
    if ( status != 0 )
    {
        NSLog(@"Failed to add property listener!");
    }

	
	// Create the AUGraph
	NewAUGraph(&augraph);
	
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
	
	
    // UInt32 buses_s = sizeof(buses_n);
	result = AudioUnitSetProperty(mixer, 
								  kAudioUnitProperty_ElementCount, 
								  kAudioUnitScope_Input, 
								  0, 
								  &buses_n, 
								  sizeof(buses_n));
	
	// Create the stream buffer description
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
	AUGraphIsRunning(augraph, &fRunning);
    
    // If multiple AUGraphStart calls were made it will take an equal number
    // of AUGraphStop calls to actually stop the graph.
    while (fRunning)
    {
        AUGraphStop(augraph);
        AUGraphIsRunning(augraph, &fRunning);
    }
	
	return;
}

- (void) reset
{
    m_pChorusEffect->Reset();
    m_pDelayEffect->Reset();
    m_pReverbEffect->Reset();
    m_pDistortion->Reset();
    
    [m_sampler Reset];
}

- (void) ClearOutEffects
{
    m_pChorusEffect->ClearOutEffect();
    m_pDelayEffect->ClearOutEffect();
    m_pReverbEffect->ClearOutEffect();
    m_pDistortion->ClearOutEffect();
}

- (void) setSamplePackWithName:(NSString*)name
{
    [self stopAUGraph];
    [m_sampler loadSamplerWithName:name];
    [m_sampler Reset];
    [self startAUGraph];
}

- (void) setSamplePackWithName:(NSString*)name withSelector:(SEL)aSelector andOwner:(NSObject*)parent
{
    [self stopAUGraph];
    [m_sampler asynchLoadSamplerWithName:name withSelector:aSelector andOwner:parent];
}

- (void) setSamplePackWithIndex:(int)index withSelector:(SEL)aSelector andOwner:(NSObject*)parent
{
    [self stopAUGraph];
    [m_sampler asynchLoadSamplerWithIndex:index withSelector:aSelector andOwner:parent];
}

- (void) samplerFinishedLoadingCB:(NSNumber*)result
{
    if ([result boolValue])
    {
        [m_sampler Reset];
        [self startAUGraph];
    }
}

- (void) RouteAudioToSpeaker
{
    
    UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    
    [self AnnounceAudioRouteChange];
    
}

- (void) RouteAudioToDefault
{
    
    UInt32 audioRoute = kAudioSessionOverrideAudioRoute_None;
    
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    
    [self AnnounceAudioRouteChange];
    
}

- (CFStringRef) GetAudioRoute
{
    
    CFDictionaryRef routes;
    
    UInt32 propertySize = sizeof(CFStringRef);
    
    OSStatus result = AudioSessionGetProperty(kAudioSessionProperty_AudioRouteDescription, &propertySize, &routes);
    
    if ( result == 0 )
    {
        CFArrayRef outputs = (CFArrayRef) CFDictionaryGetValue(routes, kAudioSession_AudioRouteKey_Outputs);
        if (NULL == outputs)
        {
            return NULL;
        }
        CFDictionaryRef mainOut = (CFDictionaryRef) CFArrayGetValueAtIndex(outputs, 0);
        if (NULL == mainOut)
        {
            return NULL;
        }
        CFStringRef routeName = (CFStringRef) CFDictionaryGetValue(mainOut, kAudioSession_AudioRouteKey_Type);
        
        return routeName;
    }
    
    return NULL;
}

- (void) AnnounceAudioRouteChange
{
    
    NSString * routeName = (NSString *)[self GetAudioRoute];
    
    // Print out the current route
    NSLog(@"Routing audio through %@", routeName);
        
}

- (void) dealloc
{
    
    [self stopAUGraph];
    
    OSStatus status = AudioSessionRemovePropertyListenerWithUserData( kAudioSessionProperty_AudioRouteChange, &AudioControllerPropertyListener, self );
    
    if ( status != 0 )
    {
        NSLog(@"Failed to remove property listener!");
    }

	DisposeAUGraph(augraph);
    
    if (m_pksobjects != NULL)
    {
        delete[] m_pksobjects;
        m_pksobjects = NULL;
    }
    
    if (m_pBwFilter != NULL)
    {
        delete m_pBwFilter;
        m_pBwFilter = NULL;
    }
    
    if (m_pChorusEffect != NULL)
    {
        delete m_pChorusEffect;
        m_pChorusEffect = NULL;
    }
    
    if (m_pDelayEffect != NULL)
    {
        delete m_pDelayEffect;
        m_pDelayEffect = NULL;
    }
    
    if (m_pReverbEffect != NULL)
    {
        delete m_pReverbEffect;
        m_pReverbEffect = NULL;
    }
    
    if (m_pTanhDistortion != NULL)
    {
        delete m_pTanhDistortion;
        m_pTanhDistortion = NULL;
    }
    
    if (m_pOverdrive != NULL)
    {
        delete m_pOverdrive;
        m_pOverdrive = NULL;
    }
    
    if (m_pHardCutoffDistortion != NULL)
    {
        delete m_pHardCutoffDistortion;
        m_pHardCutoffDistortion = NULL;
    }
    
    if (m_pSoftClipOverdriveEffect != NULL)
    {
        delete m_pSoftClipOverdriveEffect;
        m_pSoftClipOverdriveEffect = NULL;
    }
    
    if (m_pFuzzExpDistortion != NULL)
    {
        delete m_pFuzzExpDistortion;
        m_pFuzzExpDistortion = NULL;
    }
    
    if (m_pEndBwFilter != NULL)
    {
        delete m_pEndBwFilter;
        m_pEndBwFilter = NULL;
    }
    
    if (m_tempOut != NULL)
    {
        delete m_tempOut;
        m_tempOut = NULL;
    }
    
    if (m_pCompressor != NULL)
    {
        delete m_pCompressor;
        m_pCompressor = NULL;
    }
    
    delete m_pDistortion;
    m_pDistortion = NULL;
    
    [m_sampler release];
    
	[super dealloc];
}

@end
