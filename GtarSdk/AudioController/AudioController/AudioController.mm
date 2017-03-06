//
//  AudioController.m
//  AudioController
//
//  Created by Idan Beck on 10/2/10.
//  Copyright 2010 Incident Technologies. All rights reserved.
//

#import "AudioController.h"

#import "AUAudioNodeFactory.h"
#import "AUMixerNode.h"

#import "CAStreamBasicDescription.h"
#import "CAXException.h"

@implementation AudioController

<<<<<<< HEAD
+(id) sharedAudioController {
    static AudioController *sharedAudioController = NULL;
    static dispatch_once_t onceToken;
=======

@interface AudioController ()
{
    AVAudioSession *m_session;
    
    AudioSource m_audioSource;
	
	KSObject *m_pksobjects;
	int m_pksobjects_n;
>>>>>>> 5b0dd0a7e65454b9c5ce3a0de4c3eaa4fe2d7501
    
    dispatch_once(&onceToken, ^{
        sharedAudioController = [[self alloc] init];
    });
    
    return sharedAudioController;
}

<<<<<<< HEAD
- (id) init {
	if(self = [super init]) {
=======
@property (retain, nonatomic) NSMutableArray* effects;

@end

@implementation AudioController

@synthesize frequency;
@synthesize sinPhase;
@synthesize m_fNoteOn;

@synthesize m_LimiterOn;

@synthesize m_volumeGain;
@synthesize m_stringSet;
@synthesize m_stringPaths;

- (id) initWithAudioSource:(AudioSource)audioSource AndInstrument:(NSString*)instrument
{
	if(self = [super init])
	{
>>>>>>> 5b0dd0a7e65454b9c5ce3a0de4c3eaa4fe2d7501
        // Grab the audio session here
        m_session = [AVAudioSession sharedInstance];
        
        [self InitDefaultStreamDescription];
        
        // Activate audio session for good measure
        NSError *activationError = nil;
        BOOL success = [m_session setActive: YES error: &activationError];
        if (!success) {
            NSLog(@"Error: Failed to activate the audio session!");
            m_session = NULL;
        }
        
        // Look at avail routes
        NSLog(@"Lineout Name: %@, Headphones Name: %@, Speaker Name: %@", AVAudioSessionPortLineOut, AVAudioSessionPortHeadphones, AVAudioSessionPortBuiltInSpeaker);
<<<<<<< HEAD
=======
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
        
        _effects = [[NSMutableArray alloc] init];
        
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
        [_effects addObject:[NSValue valueWithPointer:m_pChorusEffect]];
        
        
        // Set up the Delay Effect
        m_pDelayEffect = new DelayEffect(20, 0.5, 1.0, g_GraphSampleRate);
        m_pDelayEffect->SetPassThru(true);
        [_effects addObject:[NSValue valueWithPointer:m_pDelayEffect]];
        
        // Set up the Reverb effect
        m_pReverbEffect = new Reverb(0.75, g_GraphSampleRate);
        m_pReverbEffect->SetPassThru(true);
        [_effects addObject:[NSValue valueWithPointer:m_pReverbEffect]];
        
        // Set up the distortion effects
        m_pDistortion = new Distortion(3.78f, 0.25f, g_GraphSampleRate);
        m_pDistortion->SetPassThru(true);
        [_effects addObject:[NSValue valueWithPointer:m_pDistortion]];

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
        
        if (SamplerSource == m_audioSource) {
            m_sampler = [[[Sampler alloc] initWithSampleRate:g_GraphSampleRate AndSamplePack:instrument AndStringSet:m_stringSet AndStringPaths:m_stringPaths] retain];
        }
        
        m_volumeGain = 1.0;
>>>>>>> 5b0dd0a7e65454b9c5ce3a0de4c3eaa4fe2d7501
        
        // seed rand for use by all audio generators and effects
        srand(time(NULL));
        
        [AUAudioNodeFactory InitWithAudioController:self];
        [self initializeAUGraph];
<<<<<<< HEAD
        [self RouteAudioToSpeaker]; 
=======
        
        // added 1.21: when running multiple audio controllers, need to not refresh route
        if([self GetNSAudioRoute]==NULL){
            [self RouteAudioToSpeaker];
        }
	}
	
	return self;
}

- (id) initWithAudioSource:(AudioSource)audioSource AndInstrument:(NSString*)instrument AndStringSet:(NSArray *)stringSet AndStringPaths:(NSArray *)stringPaths
{
    m_stringSet = stringSet;
    m_stringPaths = stringPaths;
    self = [self initWithAudioSource:audioSource AndInstrument:instrument];
    
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
>>>>>>> 5b0dd0a7e65454b9c5ce3a0de4c3eaa4fe2d7501
    }
    
    return self;
}

// Default stream description (MONO)
- (AudioStreamBasicDescription*) InitDefaultStreamDescription {
    // Initialize structure to zero
    memset(&m_StreamDefaultDescription, 0, sizeof(AudioStreamBasicDescription));
    
    // Make modifications to the CAStreamBasicDescription
    // Using 16 bit ints to make it easier
    // mixer will accept either 16 bit ints or 32 bit fixed point ints
    m_StreamDefaultDescription.mSampleRate =  AUDIO_CONTROLLER_SAMPLE_RATE;		// sample rate
    m_StreamDefaultDescription.mFormatID = kAudioFormatLinearPCM;               // Format
    m_StreamDefaultDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    m_StreamDefaultDescription.mBitsPerChannel = sizeof(AudioSampleType) * 8;
    m_StreamDefaultDescription.mChannelsPerFrame = 1;
    m_StreamDefaultDescription.mFramesPerPacket = 1;
    m_StreamDefaultDescription.mBytesPerFrame = (m_StreamDefaultDescription.mBitsPerChannel / 8) * m_StreamDefaultDescription.mChannelsPerFrame;
    m_StreamDefaultDescription.mBytesPerPacket = m_StreamDefaultDescription.mBytesPerFrame * m_StreamDefaultDescription.mFramesPerPacket;
    
    return &m_StreamDefaultDescription;
}

- (AudioStreamBasicDescription*)GetDefaultStreamDescription {
    return &m_StreamDefaultDescription;
}

// Returns the internal AUGraph (used by AudioNode)
- (AUGraph*) getAUGraph {
    return (AUGraph*)(&augraph);
}

- (float) getSampleRate {
    return AUDIO_CONTROLLER_SAMPLE_RATE;
}

// Starts the audio render
- (void) startAUGraph {
    Boolean fRunning;
    AUGraphIsRunning(augraph, &fRunning);

    if (fRunning)   // multiple calls to start requires the same number of calls to stop
        return;
	
	// Starts the AUGraph
	OSStatus result = AUGraphStart(augraph);

	if(result)
		printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (int)result, (char*)&result);
	
    // Announce what audio route we are using
    [self AnnounceAudioRouteChange];
    
	return;
}

- (void) HandleAVAudioSessionRouteChange:(NSNotification*)note {
#if TARGET_IPHONE_SIMULATOR
    /* do nothing */
    NSLog(@"HandleAVAudioSessionRouteChange doesn't do anything in simulator");
#else
    // Respond to the route change
    NSLog(@"AVAudioSessionRouteChanged: %@, %@",
          [note.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey],
          [note.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey]);
    
    // Don't let routing go to built in receiver 
    NSString *audioRoute = [self GetNSAudioRoute];
    if ([audioRoute isEqualToString:(NSString*)(AVAudioSessionPortBuiltInReceiver)])
        [self RouteAudioToSpeaker];
    
    [self requestAudioRouteDetails];
    [self AnnounceAudioRouteChange];
#endif
}

void AudioControllerPropertyListener (void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData) {
#if TARGET_IPHONE_SIMULATOR
    /* do nothing */
    NSLog(@"AudioControllerProperty Listner doesn't do anything in simulator");
#else
    if (inID != kAudioSessionProperty_AudioRouteChange)
        return;
    
    AudioController *ac = (AudioController*)inClientData;
    
    NSString *audioRoute = [ac GetNSAudioRoute];
    if (![audioRoute isEqualToString:(NSString*)(AVAudioSessionPortOverrideSpeaker)])
        [ac RouteAudioToSpeaker];
    
    [ac requestAudioRouteDetails];
    [ac AnnounceAudioRouteChange];
#endif
}

// Request that a AudioRouteChange notification get sent out, even though
// no actual change has happened. This is useful for getting the audio
// route state info for initial UI setup.
- (void) requestAudioRouteDetails {
    bool fRouteIsSpeaker = TRUE;
    NSString *audioRoute = [self GetNSAudioRoute];
    
    //CFStringRef newRoute = [self GetAudioRoute];
    //bool routeIsSpeaker = [(NSString*)newRoute isEqualToString:(NSString*)kAudioSessionOutputRoute_BuiltInSpeaker];
    
#if TARGET_IPHONE_SIMULATOR
    fRouteIsSpeaker = TRUE;     // spoof the speaker if it's in simulator
#else
    fRouteIsSpeaker = [audioRoute isEqualToString:(NSString*)(AVAudioSessionPortBuiltInSpeaker)];
#endif
    
    NSDictionary *routeData = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:fRouteIsSpeaker], @"isRouteSpeaker",
                               audioRoute, @"routeName", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioRouteChange" object:self userInfo:routeData];
}

// Callback for audio interruption, e.g. a phone call coming in".
void AudioInterruptionListener (void *inClientData, UInt32 inInterruptionState) {
    AudioController *ac = (AudioController *)inClientData;
    
    // Stop audio graph when an interruption comes in, and restart it when the interruption is done.
    if (inInterruptionState == kAudioSessionBeginInterruption) {
        NSError *errorSetActiveFalse = NULL;
        [[AVAudioSession sharedInstance] setActive:FALSE error:&errorSetActiveFalse];
        if(errorSetActiveFalse != NULL)
            NSLog(@"Failed to set AVAudioSession to not active: %@", [errorSetActiveFalse description]);
        else
            [ac stopAUGraph];
    }
    else if (inInterruptionState == kAudioSessionEndInterruption) {
        NSError *errorSetActiveTrue = NULL;
        [[AVAudioSession sharedInstance] setActive:TRUE error:&errorSetActiveTrue];
        if(errorSetActiveTrue != NULL)
            NSLog(@"Failed to set AVAudioSession to not active: %@", [errorSetActiveTrue description]);
        else
            [ac startAUGraph];
    }
}

- (void) initializeAUGraph {
	OSStatus result = noErr;
    
    if (m_session != NULL) {
        // Set Category
        NSError *setCategoryError = nil;
        BOOL fStatus = [m_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
        if(fStatus == FALSE) {
            NSLog(@"AVAudioSession SetCategory failed: %@", [setCategoryError description]);
        }
    }
    else {
        NSLog(@"InitializeAUGraph failed, session not initialized");
        return;
    }
    
    // subscribe for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(HandleAVAudioSessionRouteChange:)
                                          name:@"AVAudioSessionRouteChangeNotification" object:NULL];

	// Create the AUGraph
	NewAUGraph(&augraph);
	
    AUAudioNode *outputNode = [AUAudioNodeFactory MakeAudioNode:AUDIO_NODE_OUTPUT];
    AUMixerNode *mixerNode = (AUMixerNode*)[AUAudioNodeFactory MakeAudioNode:AUDIO_NODE_MIXER];
    [mixerNode ConnectOutput:0 toInput:outputNode channel:0];
	
	// Open the graph audio units.
	// Now open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(augraph);
    
    [mixerNode SetBusCount:1];
	[mixerNode InitializeMixerBusses];
	
	// Now call initialize to verify connections
	result = AUGraphInitialize(augraph);
    NSLog(@"AudioController: AUGraphInitialize: %s", CAX4CCString(result).get());
}

// Stops the render
- (void) stopAUGraph {
	Boolean fRunning = false;
	
    // Check to see if graph is running
	AUGraphIsRunning(augraph, &fRunning);
    
    // If multiple AUGraphStart calls were made it will take an equal number
    // of AUGraphStop calls to actually stop the graph.
    while (fRunning) {
        AUGraphStop(augraph);
        AUGraphIsRunning(augraph, &fRunning);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioEngineStopped" object:self userInfo:nil];
}

- (void) RouteAudioToSpeaker {
    //UInt32 audioRoute = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Routing not available in simulator");
#else
    NSError *overrideError = NULL;
    [m_session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&overrideError];
    
    if(overrideError != NULL) {
        NSLog(@"Failed to route audio to speaker: %@", [overrideError description]);
        [self GetAudioRoute];
    }
    else
        [self AnnounceAudioRouteChange];

#endif
}

- (void) RouteAudioToDefault {
    //UInt32 audioRoute = kAudioSessionOverrideAudioRoute_None;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRoute), &audioRoute);
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Routing not available in simulator");
#else
    NSError *overrideError = NULL;
    [m_session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&overrideError];
    
    if(overrideError != NULL) {
        NSLog(@"Failed to route audio to speaker: %@", [overrideError description]);
        [self GetAudioRoute];
    }
    else
        [self AnnounceAudioRouteChange];
#endif
}

- (NSString *) GetNSAudioRoute {
#if TARGET_IPHONE_SIMULATOR
    return @"simulator";
#else
    AVAudioSessionRouteDescription *routeDesc = [m_session currentRoute];
    AVAudioSessionPortDescription *outputPortDesc = [[routeDesc outputs] firstObject];
    if(outputPortDesc != NULL)
    {
        NSLog(@"Current Route: %@", [outputPortDesc portName]);
        return [outputPortDesc portName];
    }
    else
        return NULL;
#endif
}

- (CFStringRef) GetAudioRoute {
    return (CFStringRef)[self GetNSAudioRoute];
}

- (void) AnnounceAudioRouteChange {
    // Print out the current route
    NSString * routeName = (NSString *)[self GetAudioRoute];
    NSLog(@"Routing audio through %@", routeName);
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopAUGraph];
	DisposeAUGraph(augraph);
    
	[super dealloc];
}

@end
