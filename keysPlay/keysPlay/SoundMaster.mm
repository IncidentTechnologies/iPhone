//
//  FreePlayAudioController.m
//  gTarPlay
//
//  Created by Kate Schnippering on 4/8/14.
//
//

#import "SoundMaster.h"
#import "AudioController.h"
#import "AUNodeNetwork.h"
#import "AudioNodeCommon.h"

#define FLATSAMPLER

#define KEYS_NUM_KEYS 127

#define KEYS_FRET_DOWN_DURATION 0.005
#define KEYS_FRET_UP_DURATION 0.005
#define KEYS_STOP_FRET_DURATION 0.01

#define GRAPH_SAMPLE_RATE 44100.0f

#define EFFECTS_AVAILABLE 1
#define EFFECT_NAME_REVERB @"Reverb"
#define EFFECT_NAME_DELAY @"Echo"
#define EFFECT_NAME_CHORUS @"Chorus"
#define EFFECT_NAME_DISTORT @"Distortion"

#define DEFAULT_INSTRUMENT @"Piano"

#define DEFAULT_GAIN 0.4
#define GAIN_MULTIPLIER 0.6

@interface SoundMaster ()
{
    AudioController * audioController;
    AudioNode * root;
    
    SamplerNode * m_samplerNode;
    GtarSamplerNode * m_keysSamplerNode;
    int m_activeBankNode;
    int m_metronome;
    
    float m_channelGain;
    
    // Effects
#ifdef EFFECTS_AVAILABLE
    DelayNode * m_delayNode;
    ReverbNode * m_reverbNode;
    ChorusEffectNode * m_chorusEffectNode;
    DistortionNode * m_distortionNode;
    ButterWorthFilterNode * m_butterworthNode;
#endif
    
    // Slides and fret tracking
    BOOL isSlideEnabled;
    
    //int activeFretOnString[KEYS_NUM_STRINGS];
    //int pendingFretOnString[KEYS_NUM_STRINGS];
    //int fretsPressedDown[KEYS_NUM_STRINGS][KEYS_NUM_FRETS];
    
    //BOOL blockContinuousPluckString;
    
   // NSTimer * continuousFretTimer[KEYS_NUM_STRINGS];
    NSTimer * playingNotesTimers[KEYS_NUM_KEYS];
    
}
@end

@implementation SoundMaster

@synthesize m_instruments;
//@synthesize m_tuning;
//@synthesize m_standardTuning;

- (id)init
{
    self = [super init];
    if(self)
    {
        numEffects = 0;
        numInstruments = 0;
        currentInstrumentIndex = -1;
        m_metronome = -1;
        
#ifdef EFFECTS_AVAILABLE
        m_reverbNode = nil;
        m_chorusEffectNode = nil;
        m_delayNode = nil;
        m_distortionNode = nil;
        m_butterworthNode = nil;
#endif
        
        BOOL init = [self initAudio];
        
        if(!init){
            return nil;
        }
    }
    return self;
}

- (BOOL)initAudio
{
    DLog(@" **** Init Sound Master **** ");
    
    /*m_standardTuning = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                        [NSNumber numberWithInt:5],
                        [NSNumber numberWithInt:10],
                        [NSNumber numberWithInt:15],
                        [NSNumber numberWithInt:19],
                        [NSNumber numberWithInt:24],
                        nil];*/
    
    audioController = [AudioController sharedAudioController];
    root = [[audioController GetNodeNetwork] GetRootNode];
    
    m_keysSamplerNode = new GtarSamplerNode;
    [self setChannelGain:DEFAULT_GAIN];
    
    //root->ConnectInput(0, m_keysSamplerNode, 0);
    
    if(!m_instruments && ![self loadInstrumentArray]){
        DLog(@"Failed to load instrument array from instrument.plist");
        return false;
    }
    
    
    if(m_metronome < 0){
        [self initMetronome];
    }
    
    [self initTimers];
    
    [self initEffects];
    
    return true;
    
}

- (void)initTimers
{
    /*for(int s = 0; s < KEYS_NUM_STRINGS; s++){
        for(int f = 0; f < KEYS_NUM_FRETS; f++){
            playingNotesTimers[s][f] = nil;
        }
    }*/
}

- (void)releaseAllTimers
{
    /*for(int s = 0; s < KEYS_NUM_STRINGS; s++){
        for(int f = 0; f < KEYS_NUM_FRETS; f++){
            [playingNotesTimers[s][f] invalidate];
            playingNotesTimers[s][f] = nil;
        }
    }*/
}

- (void)reset
{
    DLog(@"Reset audio");
    
    //[self stop];
    
    //[self initAudio];
    
    //[self start];
}

- (int)generateBank:(int)bank numSamples:(int)numSamples
{
    DLog(@"Generate bank %i",bank);
    
    return m_keysSamplerNode->CreateNewBank(bank,numSamples);
    
}

- (void)releaseBank:(int)bank
{
    m_keysSamplerNode->ReleaseBank(bank);
}

- (void)start
{
    if(!isLoadingInstrument){
        DLog(@"Start");
        [audioController startAUGraph];
    }
}

- (void)stop
{
    DLog(@"Stop");
    
    // End all samples that might be playing
    if(m_keysSamplerNode != nil){
        int numSamples = m_keysSamplerNode->m_numSamples[m_activeBankNode];
        for(int i = 0; i < numSamples; i++){
            m_keysSamplerNode->StopSample(m_activeBankNode,i);
        }
        m_keysSamplerNode->StopSample(m_metronome, 0);
    }
    
    [audioController stopAUGraph];
}

- (void)releaseCompletely
{
    DLog(@"Disconnect and release SoundMaster");
    
    [self stop];
    
    [self stopAllEffects];
    
    // release metronome
    [self releaseMetronome];
    
    // release bank
    [self releaseBank:m_activeBankNode];
    
    root->DeleteAndDisconnect(CONN_OUT);
    // start AU graph?
}

- (void)disconnectAndReleaseEffectNode:(EffectNode *)effectNode
{
    [self stop];
    effectNode->DeleteAndDisconnect(CONN_OUT);
    effectNode = nil;
    [self start];
}

#pragma mark - Routing
- (void)routeToSpeaker
{
    DLog(@"Route to speaker");
    
    [audioController RouteAudioToSpeaker];
    
}

- (void)routeToDefault
{
    DLog(@"Route to default");
    
    [audioController RouteAudioToDefault];
}

- (NSString *)getAudioRoute
{
    CFStringRef audioRoute = [audioController GetAudioRoute];
    
    return (__bridge NSString *)audioRoute;
}

#pragma mark - Volume
- (void) setChannelGain:(float)gain
{
    DLog(@"Set channel gain to %f",gain*GAIN_MULTIPLIER);
    
    m_channelGain = gain * GAIN_MULTIPLIER;
    
    m_keysSamplerNode->SetChannelGain(m_channelGain, CONN_OUT);
    
    
}

- (float) getChannelGain
{
    return m_channelGain / GAIN_MULTIPLIER;
}

#pragma mark - Tone
- (bool) SetBWCutoff:(double)cutoff
{
    DLog(@"SoundMaster: set BW cutoff to %f",cutoff);
    
#ifdef EFFECTS_AVAILABLE
    //m_butterworthNode->SetCutoff(cutoff);
    
    //if(m_pBwFilter != NULL)
    //    return m_pBwFilter->SetCutoff(cutoff);
    //else
    //    return false;
#endif
    
    return true;
}
/*
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
 }*/

#pragma mark - Instrument
- (void) loadInstrument:(NSInteger)index withSelector:(SEL)cb andOwner:(id)sender
{
    
    if(index == currentInstrumentIndex){
        DLog(@"Instrument already loaded");
        
        // Callback
        if(sender != nil){
            [sender performSelectorInBackground:cb withObject:[NSNumber numberWithBool:TRUE]];
        }
        return;
        
    }else if (index >= [m_instruments count] || index < 0){
        
        DLog(@"Attempting to access instrument index out of bounds");
        
        // Callback
        if(sender != nil){
            [sender performSelectorInBackground:cb withObject:[NSNumber numberWithBool:TRUE]];
        }
        return;
        
    }else{
        
        DLog(@"Release %i, set new to %i",currentInstrumentIndex,index);
    }
    
    isLoadingInstrument = YES;
    
    dispatch_semaphore_wait([audioController TakeSemaphore], DISPATCH_TIME_FOREVER);
    
    // Release the previous instrument before starting anew
    [self releaseInstrument:currentInstrumentIndex];
    
    // Get all the instrument info
    currentInstrumentIndex = index;
    NSMutableDictionary * instrument = [m_instruments objectAtIndex:index];
    int firstNote = [[instrument objectForKey:@"FirstNoteMidiNum"] intValue];
    int numNotes = [[instrument objectForKey:@"NumNotes"] intValue];
    
    // Generate a bank
    m_activeBankNode = [self generateBank:0 numSamples:KEYS_KEY_COUNT];
    
    DLog(@"Active bank node is %i",m_activeBankNode);
    
    DLog(@"Load samples for instrument %i",index);
    
    // Reset active frets
    /*for(int i = 0; i < KEYS_NUM_STRINGS; i++){
        activeFretOnString[i] = -1;
        pendingFretOnString[i] = -1;
        
        for(int j = 0; j < KEYS_NUM_FRETS; j++){
            fretsPressedDown[i][j] = 0;
        }
    }*/
    
    if(m_instruments && index < [m_instruments count] && index > -1){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            //SampleNode * newSample;
            
            NSString * instrumentName = [instrument objectForKey:@"Name"];
            if([instrumentName isEqualToString:@"Electric"] || [instrumentName isEqualToString:@"Strat"]){
                instrumentName = DEFAULT_INSTRUMENT;
            }
            
            // Fill so samples always starts at 0
            for(int i = 0; i < firstNote; i++){
                
                //DLog(@"Load note %i",i);
                
                // make sure instrument hasn't been released off thread
                if(currentInstrumentIndex == index){
                    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:@"Silence" ofType:@"mp3"] UTF8String];
                    
                    m_keysSamplerNode->LoadSampleIntoBank(m_activeBankNode,filepath);
                }
            }
            
            for(int j = firstNote; j < numNotes; j++){
                
                //DLog(@"Load note %i",j);
                
                // make sure instrument hasn't been released off thread
                if(currentInstrumentIndex == index){
                    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:[instrumentName stringByAppendingFormat:@" %i",j] ofType:@"mp3"] UTF8String];
                    
                    m_keysSamplerNode->LoadSampleIntoBank(m_activeBankNode,filepath);
                }
            }
            
            for(int i = numNotes; i < KEYS_KEY_COUNT; i++){
                
                //DLog(@"Load note %i",i);
                
                // make sure instrument hasn't been released off thread
                if(currentInstrumentIndex == index){
                    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:@"Silence" ofType:@"mp3"] UTF8String];
                    
                    m_keysSamplerNode->LoadSampleIntoBank(m_activeBankNode,filepath);
                }
            }
            
            // broadcast instrument changed
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:currentInstrumentIndex ], @"instrumentIndex", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InstrumentChanged" object:self userInfo:userInfo];
            
            DLog(@"Changed instrument to %@",[instrument objectForKey:@"Name"]);
            
            // End loading
            isLoadingInstrument = NO;
            
            [self start];
            
            // Determine the tuning
            /*if([instrument objectForKey:@"Tuning"]){
                m_tuning = [[NSArray alloc] initWithArray:[instrument objectForKey:@"Tuning"]];
            }else{
                m_tuning = [[NSArray alloc] initWithArray:m_standardTuning];
            }*/
            
            dispatch_semaphore_signal([audioController TakeSemaphore]);
            
            // Perform callback
            
            if(sender != nil){
                [sender performSelectorInBackground:cb withObject:[NSNumber numberWithBool:TRUE]];
            }
        });
        
    }else{
        
        DLog(@"Cannot load samples for instrument %i",index);
        
    }
}

/*- (BOOL) isAnyFretDownOnString:(int)string
{
    for(int f = 1; f < KEYS_NUM_FRETS; f++){
        
        if(fretsPressedDown[string][f] == 1){
            return YES;
        }
        
    }
    
    return NO;
}*/

/*
- (int) highestFretDownIndexForString:(int)string
{
    for(int f = KEYS_NUM_FRETS-1; f >= 0; f--){
        if(fretsPressedDown[string][f] == 1){
            return f;
        }
    }
    
    return -1;
}
 */

- (int) noteIndexForKey:(int)key
{
    /*if(fret < 0){
        return -1;
    }
    
    return [[m_tuning objectAtIndex:string] intValue] + fret;*/
    
    // TODO: samples should range 0-127
    
    return key;
}

- (void) releaseInstrument:(NSInteger)index
{
    if(index > -1){
        [self releaseAllTimers];
        [self stopAllEffects];
        [self releaseBank:m_activeBankNode];
    }
}

- (bool) loadInstrumentArray
{
    // load the plist file
    NSError *error = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    plistPath = [rootPath stringByAppendingPathComponent:@"instrumentList.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"instrumentList" ofType:@"plist"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"instrumentList" ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *plistDict = (NSDictionary *) [NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    
    if (!plistDict) {
        DLog(@"Error reading plist: %@", [error localizedDescription]);
        return false;
    }
    
    // get sample pack info from plist
    m_instruments = [[NSArray alloc] initWithArray:[plistDict objectForKey:@"instruments"]];
    numInstruments = [m_instruments count];
    
    return true;
}

- (void) didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    DLog(@"SoundMaster didSelectInstrument %@",instrumentName);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSInteger newInstrument = [self getIndexForInstrument:instrumentName];
        [self setCurrentInstrument:newInstrument withSelector:cb andOwner:sender];
        
    });
}

- (void) setCurrentInstrument:(NSInteger)index withSelector:(SEL)cb andOwner:(id)sender
{
    if(index < numInstruments){
        DLog(@"Selecting instrument at index %i",index);
        
        [self stop];
        
        [self loadInstrument:index withSelector:cb andOwner:sender];
        
    }else{
        DLog(@"Attempting to select instrument with index %i out of range",index);
    }
}

- (NSInteger) getCurrentInstrument
{
    return currentInstrumentIndex;
}

- (NSInteger) getIndexForInstrument:(NSString *)instrumentName
{
    for(int i = 0; i < numInstruments; i++){
        if([[[m_instruments objectAtIndex:i] objectForKey:@"Name"] isEqualToString:instrumentName]){
            return i;
        }
    }
    
    for(int i = 0; i < numInstruments; i++){
        if([[[m_instruments objectAtIndex:i] objectForKey:@"SecondName"] isEqualToString:instrumentName]){
            return i;
        }
    }
    
    // Default to instrument 0
    return 0;
}

- (NSArray *)getInstrumentList
{
    
    if(!m_instruments){
        [self loadInstrumentArray];
    }
    
    NSMutableArray * instrumentNames = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < numInstruments; i++){
        [instrumentNames addObject:[[m_instruments objectAtIndex:i] objectForKey:@"Name"]];
    }
    
    return [NSArray arrayWithArray:instrumentNames];
}

#pragma mark - keys
//- (void) PluckString:(int)string atFret:(int)fret
- (void) playKey:(int)key withDuration:(double)duration
{
    if(!isLoadingInstrument){
        
        //key = 60;
        
        // Ensure it's a valid string + fret
        if(key >= 0 && key < KEYS_NUM_KEYS){
            
            // Ensure there's a valid instrument enabled
            if(m_keysSamplerNode == nil){
                [self setCurrentInstrument:0 withSelector:nil andOwner:nil];
                return;
            }
            
            // Stop anything playing on the string
            //[self stopString:string setFret:fret];
            //activeFretOnString[string] = fret;
            
            // Get note index
            int noteIndex = [self noteIndexForKey:key];
            
            DLog(@"Note at index %i",noteIndex);
            
            BOOL retrigger = m_keysSamplerNode->IsNoteOn(m_activeBankNode, key);
            
            // First check if there's a timer on the note already (playing again before it's timed out) and stop it
            if(playingNotesTimers[key] != nil){
                
                [self EndPlayKey:playingNotesTimers[key]];
            
            }
            
            if(retrigger){
                m_keysSamplerNode->RetriggerSample(m_activeBankNode,key);
            }else{
                m_keysSamplerNode->TriggerSample(m_activeBankNode, key);
            }
                
            // Set a timer to keep the note short
            playingNotesTimers[key] = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(EndPlayKey:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:key],@"Key", nil] repeats:NO];
        }
    }
}

// Timer End Play Key
- (void) EndPlayKey:(NSTimer *)timer
{
    NSDictionary * info = [timer userInfo];
    
    int key = [[info objectForKey:@"Key"] intValue];
    
    int stopIndex = [self noteIndexForKey:key];
    
    if(stopIndex >= 0 && [self IsNoteOnForKey:key]){
        [self EndNoteForKey:key];
    }
    
    [playingNotesTimers[key] invalidate];
    playingNotesTimers[key] = nil;
    
}
 
- (void) playMutedKey:(int)key
{
    if(!isLoadingInstrument){
        if(key >= 0 && key < KEYS_NUM_KEYS){
            
            if(m_keysSamplerNode == nil){
                [self setCurrentInstrument:0 withSelector:nil andOwner:nil];
            }
            
            //[self stopString:string setFret:0];
            
            int noteIndex = [self noteIndexForKey:key];
            
            DLog(@"Muted note at index %i",noteIndex);
            
            m_keysSamplerNode->TriggerMutedSample(m_activeBankNode,noteIndex);
        }
    }
}

/*
- (void) stopString:(int)string setFret:(int)fret
{
    // Stop all other notes playing on that string by keeping an active note per string
    int stopIndex = [self noteIndexForString:string andFret:activeFretOnString[string]];
    BOOL overlapNotePlaying = NO;
    
    if(stopIndex < 0){
        return;
    }
    
    // Make sure it's not playing on another string
    for(int s = 0; s < KEYS_NUM_STRINGS; s++){
        if(s != string && [self noteIndexForString:s andFret:activeFretOnString[s]] == stopIndex){
            overlapNotePlaying = YES;
            break;
        }
    }
    
    // Stop that string from playing
    if(!overlapNotePlaying){
        [self EndNoteOnString:string andFret:activeFretOnString[string]];
    }
    
    activeFretOnString[string] = fret;
}
 */


/*
- (void) EndContinuousFretWindow:(NSTimer *)timer
{
    
    int s = [[[timer userInfo] objectForKey:@"String"] intValue];
    
    int highestFret = [self highestFretDownIndexForString:s];
    
    pendingFretOnString[s] = highestFret;
    [self PluckContinuousString:s atFret:activeFretOnString[s]];
    
    [continuousFretTimer[s] invalidate];
    continuousFretTimer[s] = nil;
    
}
*/

/*
- (void) EndStopStringWindow:(NSTimer *)timer
{
    int s = [[[timer userInfo] objectForKey:@"String"] intValue];
    
    if(![self isAnyFretDownOnString:s]){
        [self stopString:s setFret:-1];
    }
}
*/

- (bool) NoteOnForKey:(int)key withDuration:(double)duration
{
    if(!isLoadingInstrument){
        
        [self playKey:key withDuration:duration];
        
    }
    return YES;
}

- (bool) IsNoteOnForKey:(int)key
{
    int noteIndex = [self noteIndexForKey:key];
    
    return m_keysSamplerNode->IsNoteOn(m_activeBankNode, noteIndex);
}

// Keys Note Off At String
- (bool) NoteOffForKey:(int)key
{
    if(!isLoadingInstrument){
        
        int stopIndex = [self noteIndexForKey:key];
        
        if(stopIndex >= 0 && [self IsNoteOnForKey:key]){
            
            if(playingNotesTimers[key] != nil){
                [self EndPlayKey:playingNotesTimers[key]];
                
                return YES;
                
            }else{
                [self EndNoteForKey:key];
                
                return YES;
            }
            
        }
        
    }
    return NO;
}

// Note Off Event
- (void) EndNoteForKey:(int)key
{
    int stopIndex = [self noteIndexForKey:key];
    
    if(stopIndex >= 0){
        
        m_keysSamplerNode->NoteOff(m_activeBankNode, stopIndex);
        
    }
}

#pragma mark - Sliding

- (void)enableSliding
{
    isSlideEnabled = YES;
}

- (void)disableSliding
{
    isSlideEnabled = NO;
    
}

- (BOOL)isSlideEnabled
{
    return isSlideEnabled;
}

#pragma mark - Metronome
- (void)initMetronome
{
    m_metronome = [self generateBank:1 numSamples:1];
    
    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:@"Metronome" ofType:@"mp3"] UTF8String];
    
    DLog(@"Filepath is %s",filepath);
    
    m_keysSamplerNode->LoadSampleIntoBank(m_metronome, filepath);
    
}

- (void)releaseMetronome
{
    DLog(@"Release metronome");
    
    [self releaseBank:m_metronome];
}

- (void)playMetronomeTick
{
    m_keysSamplerNode->TriggerSample(m_metronome,0);
}

#pragma mark - Effects
- (void)initEffects
{
    // setup a chain of effects
    
    // init metadata
    
#ifdef EFFECTS_AVAILABLE
    
    isSlideEnabled = YES;
    
    effectNames = [[NSArray alloc] initWithObjects:
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)],
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)],
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)],
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)],nil];
    
    effectStatus = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithBool:isSlideEnabled],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],nil];
    
    numEffects = [effectNames count];
    
    // Chorus
    //
    m_chorusEffectNode = new ChorusEffectNode(25,               // delay
                                              0.75,             // depth
                                              0.05,             // width
                                              3.0,              // frequency
                                              1.0,              // wet
                                              GRAPH_SAMPLE_RATE);
    m_chorusEffectNode->ConnectInput(0, m_keysSamplerNode, 0);
    m_chorusEffectNode->SetPassThru(YES);
    
    // Delay
    //
    m_delayNode = new DelayNode(500,     // ms delay
                                0.5,    // feedback
                                1.0     // wet
                                );
    m_delayNode->ConnectInput(0, m_chorusEffectNode, 0);
    m_delayNode->SetPassThru(YES);
    
    // Reverb
    //
    m_reverbNode = new ReverbNode(0.75); // wet
    m_reverbNode->ConnectInput(0, m_delayNode, 0);
    m_reverbNode->SetPassThru(YES);
    
    // Distort
    //
    m_distortionNode = new DistortionNode(3.78,             // gain
                                          0.25,             // wet
                                          GRAPH_SAMPLE_RATE);
    m_distortionNode->ConnectInput(0, m_reverbNode, 0);
    root->ConnectInput(0, m_distortionNode, 0);
    m_distortionNode->SetPassThru(YES);
    
#endif
    
}

- (void)stopAllEffects
{
    
#ifdef EFFECTS_AVAILABLE
    for(int i = 0; i < [effectStatus count]; i++){
        //BOOL isOn = [[effectStatus objectAtIndex:i] boolValue];
        
        //if(isOn){
            [self toggleEffect:i isOn:YES];
        //}
    }
    
#endif
}

- (void)toggleEffect:(NSInteger)index isOn:(BOOL)on
{
    
#ifdef EFFECTS_AVAILABLE
    //BOOL isOn = [[effectStatus objectAtIndex:index] boolValue];
    
    if(index >= [effectNames count]){
        return;
    }
    
    NSString * effectNode = [effectNames objectAtIndex:index];
    
    [effectStatus setObject:[NSNumber numberWithBool:!on] atIndexedSubscript:index];
    
    if(on){
        
        DLog(@"Toggle effect off for %@",effectNode);
        
        if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
            
            m_reverbNode->SetPassThru(YES);
            //[self disconnectAndReleaseEffectNode:m_reverbNode];
            //m_reverbNode = nil;
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
            
            m_delayNode->SetPassThru(YES);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
            
            m_chorusEffectNode->SetPassThru(YES);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
            
            m_distortionNode->SetPassThru(YES);
            
        }
        
    }else{
        
        DLog(@"Toggle effect on for %@ at %i",[effectNames objectAtIndex:index],index);
        
        if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
            
            m_reverbNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
            
            m_delayNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
            
            m_chorusEffectNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
            
            m_distortionNode->SetPassThru(NO);
            
        }
        
        // TODO: refresh jampad
    }
#endif
}

- (NSString *)getEffectNameAtIndex:(NSInteger)index
{
    if(index >= numEffects){
        DLog(@"Trying to get effect index %i out of range",index);
        index = numEffects-1;
    }
    
    // get the actual names
    return [effectNames objectAtIndex:index];
}

- (NSInteger)getNumEffects
{
#ifdef EFFECTS_AVAILABLE
    return numEffects;
#endif
    return 0;
}

- (BOOL)isEffectOnAtIndex:(NSInteger)index
{
    
#ifdef EFFECTS_AVAILABLE
    if(index >= numEffects){
        DLog(@"Trying to get effect index %i out of range",index);
        index = numEffects-1;
    }
    
    return [[effectStatus objectAtIndex:index] boolValue];
#endif
    return NO;
}

#pragma mark - JamPad
// set the normalized default value for JamPad
- (CGPoint)getPointForEffectAtIndex:(NSInteger)index
{
    
#ifdef EFFECTS_AVAILABLE
    NSString *effectNode = [effectNames objectAtIndex:index];
    Parameter *primary;
    Parameter *secondary;
    float x = 0;
    float y = 0;
    
    DLog(@"Get point for effect %@",effectNode);
    
    if(![self isEffectOnAtIndex:index]){
        DLog(@"Effect %@ not on",effectNode);
        return CGPointMake(x,y);
    }
    
    if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
        
        primary = m_reverbNode->getPrimaryParam();
        secondary = m_reverbNode->getSecondaryParam();
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
        
        primary = m_delayNode->getPrimaryParam();
        secondary = m_delayNode->getSecondaryParam();
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
        
        primary = m_chorusEffectNode->getPrimaryParam();
        secondary = m_chorusEffectNode->getSecondaryParam();
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
        
        primary = m_distortionNode->getPrimaryParam();
        secondary = m_distortionNode->getSecondaryParam();
        
    }else{
        
        return CGPointMake(x,y);
    }
    
    x = (primary->getValue() - primary->getMin()) / (primary->getMax() - primary->getMin());
    y = (secondary->getValue() - secondary->getMin()) / (secondary->getMax() - primary->getMin());
    
    return CGPointMake(x,y);
#endif
    return CGPointMake(0,0);
}

// translate the normalized value the JamPad position to a range
// in [min, max] for the respective parameter
- (void)adjustEffectAtIndex:(NSInteger)index toPoint:(CGPoint)position
{
    
#ifdef EFFECTS_AVAILABLE
    NSString * effectNode = [effectNames objectAtIndex:index];
    Parameter *primary;
    Parameter *secondary;
    float pmin;
    float pmax;
    float smin;
    float smax;
    
    float pnew;
    float snew;
    
    if(![self isEffectOnAtIndex:index]){
        DLog(@"Effect %@ not on",effectNode);
        return;
    }
    
    if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
        
        primary = m_reverbNode->getPrimaryParam();
        secondary = m_reverbNode->getSecondaryParam();
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
        
        primary = m_delayNode->getPrimaryParam();
        secondary = m_delayNode->getSecondaryParam();
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
        
        primary = m_chorusEffectNode->getPrimaryParam();
        secondary = m_chorusEffectNode->getSecondaryParam();
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
        
        primary = m_distortionNode->getPrimaryParam();
        secondary = m_distortionNode->getSecondaryParam();
        
    }else{
        
        return;
    }
    
    pmin = primary->getMin();
    pmax = primary->getMax();
    smin = secondary->getMin();
    smax = secondary->getMax();
    
    pnew = position.x*(pmax - pmin) + pmin;
    snew = position.y*(smax - smin) + smin;
    
    DLog(@"Update %@ to %f %f",effectNode,pnew,snew);
    
    if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
        
        m_reverbNode->setPrimaryParam(pnew);
        m_reverbNode->setSecondaryParam(snew);
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
        
        m_delayNode->setPrimaryParam(pnew);
        m_delayNode->setSecondaryParam(snew);
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
        
        m_chorusEffectNode->setPrimaryParam(pnew);
        m_chorusEffectNode->setSecondaryParam(snew);
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
        
        m_distortionNode->setPrimaryParam(pnew);
        m_distortionNode->setSecondaryParam(snew);
        
    }
    
#endif
}


@end
