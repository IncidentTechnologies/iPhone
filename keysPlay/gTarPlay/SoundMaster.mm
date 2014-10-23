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

#define GTAR_NUM_STRINGS 6
#define GTAR_NUM_FRETS 17

#define GTAR_NOTE_DURATION 1.0
#define GTAR_FRET_DOWN_DURATION 0.005
#define GTAR_FRET_UP_DURATION 0.005
#define GTAR_STOP_FRET_DURATION 0.01
#define GTAR_SLIDE_FRET_DURATION 0.015
//#define GTAR_SLIDE_FRET_DURATION 0.1

#define GRAPH_SAMPLE_RATE 44100.0f

#define EFFECTS_AVAILABLE 1
#define EFFECT_NAME_REVERB @"Reverb"
#define EFFECT_NAME_DELAY @"Echo"
#define EFFECT_NAME_CHORUS @"Chorus"
#define EFFECT_NAME_DISTORT @"Distortion"
#define EFFECT_NAME_SLIDING @"Sliding"

#define DEFAULT_INSTRUMENT @"Electric Guitar"

#define DEFAULT_GAIN 0.4
#define GAIN_MULTIPLIER 0.6

@interface SoundMaster ()
{
    AudioController * audioController;
    AudioNode * root;
    
    SamplerNode * m_samplerNode;
    GtarSamplerNode * m_gtarSamplerNode;
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
    
    int activeFretOnString[GTAR_NUM_STRINGS];
    int pendingFretOnString[GTAR_NUM_STRINGS];
    int fretsPressedDown[GTAR_NUM_STRINGS][GTAR_NUM_FRETS];
    
    BOOL blockContinuousPluckString;
    
    NSTimer * continuousFretTimer[GTAR_NUM_STRINGS];
    NSTimer * playingNotesTimers[GTAR_NUM_STRINGS][GTAR_NUM_FRETS];
    
}
@end

@implementation SoundMaster

@synthesize m_instruments;
@synthesize m_tuning;
@synthesize m_standardTuning;

- (id)init
{
    self = [super init];
    if(self)
    {
        numEffects = 0;
        numInstruments = 0;
        currentInstrumentIndex = -1;
        
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
    NSLog(@" **** Init Sound Master **** ");

    m_standardTuning = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                         [NSNumber numberWithInt:5],
                         [NSNumber numberWithInt:10],
                         [NSNumber numberWithInt:15],
                         [NSNumber numberWithInt:19],
                         [NSNumber numberWithInt:24],
                         nil];
    
    audioController = [AudioController sharedAudioController];
    root = [[audioController GetNodeNetwork] GetRootNode];
    
    m_gtarSamplerNode = new GtarSamplerNode;
    [self setChannelGain:DEFAULT_GAIN];
    
    //root->ConnectInput(0, m_gtarSamplerNode, 0);
    
    if(!m_instruments && ![self loadInstrumentArray]){
        NSLog(@"Failed to load instrument array from instrument.plist");
        return false;
    }
    
    
    [self initMetronome];
    
    [self initTimers];
    
    [self initEffects];
    
    return true;
    
}

- (void)initTimers
{
    for(int s = 0; s < GTAR_NUM_STRINGS; s++){
        for(int f = 0; f < GTAR_NUM_FRETS; f++){
            playingNotesTimers[s][f] = nil;
        }
    }
}

- (void)releaseAllTimers
{
    for(int s = 0; s < GTAR_NUM_STRINGS; s++){
        for(int f = 0; f < GTAR_NUM_FRETS; f++){
            [playingNotesTimers[s][f] invalidate];
            playingNotesTimers[s][f] = nil;
        }
    }
}

- (void)reset
{
    NSLog(@"Reset audio");
    
    //[self stop];
    
    //[self initAudio];
    
    //[self start];
}

- (int)generateBank:(int)bank numSamples:(int)numSamples
{
    NSLog(@"Generate bank %i",bank);
    
    return m_gtarSamplerNode->CreateNewBank(bank,numSamples);

}

- (void)releaseBank:(int)bank
{
    NSLog(@"Release bank");
    
    m_gtarSamplerNode->ReleaseBank(bank);
}

- (void)start
{
    if(!isLoadingInstrument){
        NSLog(@"Start");
        [audioController startAUGraph];
    }
}

- (void)stop
{
    NSLog(@"Stop");
    
    // End all samples that might be playing
    if(m_gtarSamplerNode != nil){
        int numSamples = m_gtarSamplerNode->m_numSamples[m_activeBankNode];
        for(int i = 0; i < numSamples; i++){
            m_gtarSamplerNode->StopSample(m_activeBankNode,i);
        }
        m_gtarSamplerNode->StopSample(m_metronome, 0);
    }
    
    [audioController stopAUGraph];
}

- (void)releaseCompletely
{
    NSLog(@"Disconnect and release SoundMaster");
    
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
    NSLog(@"Route to speaker");
    
    [audioController RouteAudioToSpeaker];
    
}

- (void)routeToDefault
{
    NSLog(@"Route to default");
    
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
    NSLog(@"Set channel gain to %f",gain*GAIN_MULTIPLIER);

    m_channelGain = gain * GAIN_MULTIPLIER;
    
    m_gtarSamplerNode->SetChannelGain(m_channelGain, CONN_OUT);

    
}

- (float) getChannelGain
{
    return m_channelGain / GAIN_MULTIPLIER;
}

#pragma mark - Tone
- (bool) SetBWCutoff:(double)cutoff
{
    NSLog(@"SoundMaster: set BW cutoff to %f",cutoff);
    
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
        NSLog(@"Instrument already loaded");

        // Callback
        if(sender != nil){
            [sender performSelectorInBackground:cb withObject:[NSNumber numberWithBool:TRUE]];
        }
        return;
        
    }else if (index >= [m_instruments count] || index < 0){
        
        NSLog(@"Attempting to access instrument index out of bounds");
        
        // Callback
        if(sender != nil){
            [sender performSelectorInBackground:cb withObject:[NSNumber numberWithBool:TRUE]];
        }
        return;
        
    }else{
        
        NSLog(@"Release %i, set new to %i",currentInstrumentIndex,index);
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
    m_activeBankNode = [self generateBank:0 numSamples:numNotes];
    
    NSLog(@"Load samples for instrument %i",index);
    
    // Reset active frets
    for(int i = 0; i < GTAR_NUM_STRINGS; i++){
        activeFretOnString[i] = -1;
        pendingFretOnString[i] = -1;
        
        for(int j = 0; j < GTAR_NUM_FRETS; j++){
            fretsPressedDown[i][j] = 0;
        }
    }
    
    if(m_instruments && index < [m_instruments count] && index > -1){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            //SampleNode * newSample;
            
            NSString * instrumentName = [instrument objectForKey:@"Name"];
            if([instrumentName isEqualToString:@"Electric"] || [instrumentName isEqualToString:@"Strat"]){
                instrumentName = DEFAULT_INSTRUMENT;
            }
            
            for(int j = firstNote; j < firstNote+numNotes; j++){
                
                // make sure instrument hasn't been released off thread
                if(currentInstrumentIndex == index){
                    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:[instrumentName stringByAppendingFormat:@" %i",j] ofType:@"mp3"] UTF8String];
                    
                    m_gtarSamplerNode->LoadSampleIntoBank(m_activeBankNode,filepath);
                }
            }
            
            // broadcast instrument changed
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:currentInstrumentIndex ], @"instrumentIndex", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InstrumentChanged" object:self userInfo:userInfo];
            
            NSLog(@"Changed instrument to %@",[instrument objectForKey:@"Name"]);
            
            // End loading
            isLoadingInstrument = NO;
            
            [self start];
            
            // Determine the tuning
            if([instrument objectForKey:@"Tuning"]){
                m_tuning = [[NSArray alloc] initWithArray:[instrument objectForKey:@"Tuning"]];
            }else{
                m_tuning = [[NSArray alloc] initWithArray:m_standardTuning];
            }
            
            dispatch_semaphore_signal([audioController TakeSemaphore]);
            
            // Perform callback
            
            if(sender != nil){
                [sender performSelectorInBackground:cb withObject:[NSNumber numberWithBool:TRUE]];
            }
        });
        
    }else{
        
        NSLog(@"Cannot load samples for instrument %i",index);
    
    }
}

- (BOOL) isAnyFretDownOnString:(int)string
{
    for(int f = 1; f < GTAR_NUM_FRETS; f++){
        
        if(fretsPressedDown[string][f] == 1){
            return YES;
        }
        
    }
    
    return NO;
}

- (int) highestFretDownIndexForString:(int)string
{
    for(int f = GTAR_NUM_FRETS-1; f >= 0; f--){
        if(fretsPressedDown[string][f] == 1){
            return f;
        }
    }
    
    return -1;
}

- (int) noteIndexForString:(int)string andFret:(int)fret
{
    if(fret < 0){
        return -1;
    }
    
    return [[m_tuning objectAtIndex:string] intValue] + fret;
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
        NSLog(@"Error reading plist: %@", [error localizedDescription]);
        return false;
    }
    
    // get sample pack info from plist
    m_instruments = [[NSArray alloc] initWithArray:[plistDict objectForKey:@"instruments"]];
    numInstruments = [m_instruments count];
    
    return true;
}

- (void) didSelectInstrument:(NSString *)instrumentName withSelector:(SEL)cb andOwner:(id)sender
{
    NSLog(@"SoundMaster didSelectInstrument %@",instrumentName);
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSInteger newInstrument = [self getIndexForInstrument:instrumentName];
        [self setCurrentInstrument:newInstrument withSelector:cb andOwner:sender];
        
    });
}

- (void) setCurrentInstrument:(NSInteger)index withSelector:(SEL)cb andOwner:(id)sender
{
    if(index < numInstruments){
        NSLog(@"Selecting instrument at index %i",index);
        
        [self stop];
        
        [self loadInstrument:index withSelector:cb andOwner:sender];
        
    }else{
        NSLog(@"Attempting to select instrument with index %i out of range",index);
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

#pragma mark - gTar
- (void) PluckString:(int)string atFret:(int)fret
{
    if(!isLoadingInstrument){
        
        // Ensure it's a valid string + fret
        if(string >= 0 && string < GTAR_NUM_STRINGS && fret >= 0 && fret < GTAR_NUM_FRETS){
                        
            // Ensure there's a valid instrument enabled
            if(m_gtarSamplerNode == nil){
                [self setCurrentInstrument:0 withSelector:nil andOwner:nil];
                return;
            }
            
            // Stop anything playing on the string
            [self stopString:string setFret:fret];
            activeFretOnString[string] = fret;
            
            // Get note index
            int noteIndex = [self noteIndexForString:string andFret:fret];
            
            NSLog(@"Note at index %i",noteIndex);
            
            // First check if there's a timer on the note already (playing again before it's timed out) and stop it
            if(playingNotesTimers[string][fret] != nil){
                [self EndPluckString:playingNotesTimers[string][fret]];
            }
            
            // Trigger the note
            m_gtarSamplerNode->TriggerSample(m_activeBankNode,noteIndex);
            
            // Set a timer to keep the note short
            playingNotesTimers[string][fret] = [NSTimer scheduledTimerWithTimeInterval:GTAR_NOTE_DURATION target:self selector:@selector(EndPluckString:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:string],@"String",[NSNumber numberWithInt:fret],@"Fret", nil] repeats:NO];
        }
    }
}

// Timer End Pluck String
- (void) EndPluckString:(NSTimer *)timer
{
    NSDictionary * info = [timer userInfo];
    
    int string = [[info objectForKey:@"String"] intValue];
    int fret = [[info objectForKey:@"Fret"] intValue];
    
    int stopIndex = [self noteIndexForString:string andFret:fret];
    
    if(stopIndex >= 0 && [self IsNoteOnAtString:string andFret:fret]){
        [self EndNoteOnString:string andFret:fret];
    }
    
    [playingNotesTimers[string][fret] invalidate];
    playingNotesTimers[string][fret] = nil;
    
}

- (void) PluckContinuousString:(int)string atFret:(int)fret
{
    if(!blockContinuousPluckString){
        blockContinuousPluckString = true;
        
        int highestFret = [self highestFretDownIndexForString:string];
        int noteIndex = [self noteIndexForString:string andFret:fret];
        int pendingIndex = [self noteIndexForString:string andFret:highestFret];
        //int pendingIndex = [self noteIndexForString:string andFret:pendingFretOnString[string]];
        
        NSLog(@"Note at index %i",noteIndex);
        
        if(pendingIndex > 0){
            
            //m_gtarSamplerNode->TriggerContinuousSample(m_activeBankNode, noteIndex, pendingIndex);
            
            //activeFretOnString[string] = highestFret;
            //pendingFretOnString[string] = -1;
        
            [NSTimer scheduledTimerWithTimeInterval:GTAR_SLIDE_FRET_DURATION target:self selector:@selector(EndBlockContinuousPluckString:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:string],@"String",[NSNumber numberWithInt:fret],@"Fret", nil] repeats:NO];
            
            //blockContinuousPluckString = false;
            
        }else{
            blockContinuousPluckString = false;
        }
    }

}

- (void)EndBlockContinuousPluckString:(NSTimer *)timer
{
    int string = [[[timer userInfo] objectForKey:@"String"] intValue];
    int fret = [[[timer userInfo] objectForKey:@"Fret"] intValue];
    
    blockContinuousPluckString = false;
    
    int highestFret = [self highestFretDownIndexForString:string];
    int noteIndex = [self noteIndexForString:string andFret:fret];
    int pendingIndex = [self noteIndexForString:string andFret:highestFret];
    
    if(activeFretOnString[string] > 0){
        
        activeFretOnString[string] = highestFret;
        pendingFretOnString[string] = -1;
        
        m_gtarSamplerNode->TriggerContinuousSample(m_activeBankNode, noteIndex, pendingIndex);
    
    }
}

- (void) PluckMutedString:(int)string
{
    if(!isLoadingInstrument){
        if(string >= 0 && string < GTAR_NUM_STRINGS){
            
            if(m_gtarSamplerNode == nil){
                [self setCurrentInstrument:0 withSelector:nil andOwner:nil];
            }
            
            [self stopString:string setFret:0];
            
            int noteIndex = [self noteIndexForString:string andFret:0];
            
            NSLog(@"Muted note at index %i",noteIndex);
            
            m_gtarSamplerNode->TriggerMutedSample(m_activeBankNode,noteIndex);
        }
    }
}

- (void) stopString:(int)string setFret:(int)fret
{
    // Stop all other notes playing on that string by keeping an active note per string
    int stopIndex = [self noteIndexForString:string andFret:activeFretOnString[string]];
    BOOL overlapNotePlaying = NO;
    
    if(stopIndex < 0){
        return;
    }
    
    // Make sure it's not playing on another string
    for(int s = 0; s < GTAR_NUM_STRINGS; s++){
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

- (bool) FretDown:(int)fret onString:(int)string
{
    if(!isLoadingInstrument){
    
        fretsPressedDown[string][fret] = 1;
        
        int activeFret = activeFretOnString[string];
        
        if(activeFret <= 0){
            
            //activeFretOnString[string] = highestFret;
            //[self NoteOffAtString:s andFret:activeFret];
            
        }else if(activeFret > 0){
            
            /*if(continuousFretTimer[string] == nil && isSlideEnabled){
                
                // Slide Up or Hammer On
                continuousFretTimer[string] = [NSTimer scheduledTimerWithTimeInterval:GTAR_FRET_DOWN_DURATION target:self selector:@selector(EndContinuousFretWindow:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:string],@"String", nil] repeats:NO];
                
            }*/
            
            if(isSlideEnabled){
                pendingFretOnString[string] = [self highestFretDownIndexForString:string];
                [self PluckContinuousString:string atFret:activeFretOnString[string]];
            }
            
        }
        
    }
    
    return YES;
}

- (void) EndContinuousFretWindow:(NSTimer *)timer
{
    
    int s = [[[timer userInfo] objectForKey:@"String"] intValue];
    
    int highestFret = [self highestFretDownIndexForString:s];
    
    pendingFretOnString[s] = highestFret;
    [self PluckContinuousString:s atFret:activeFretOnString[s]];

    [continuousFretTimer[s] invalidate];
    continuousFretTimer[s] = nil;
    
}

- (void) EndStopStringWindow:(NSTimer *)timer
{
    int s = [[[timer userInfo] objectForKey:@"String"] intValue];
    
    if(![self isAnyFretDownOnString:s]){
        [self stopString:s setFret:-1];
    }
}

- (bool) FretUp:(int)fret onString:(int)string
{
    if(!isLoadingInstrument){
        
        fretsPressedDown[string][fret] = 0;
        
        // Consider stopping the string
        if(![self isAnyFretDownOnString:string]){
            [NSTimer scheduledTimerWithTimeInterval:GTAR_STOP_FRET_DURATION target:self selector:@selector(EndStopStringWindow:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:string],@"String", nil] repeats:NO];
        }
        
        if(isSlideEnabled){
            
            if(fret == activeFretOnString[string]){
            
                int highestFret = [self highestFretDownIndexForString:string];
                
                if(highestFret <= 0){
                    
                    //pendingFretOnString[string] = -1;
                    //activeFretOnString[string] = -1;
                    
                }else{
                    
                    /*if(continuousFretTimer[string] == nil){
                     
                        // Slide Down or Pull Off
                        continuousFretTimer[string] = [NSTimer scheduledTimerWithTimeInterval:GTAR_FRET_UP_DURATION target:self selector:@selector(EndContinuousFretWindow:) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:string],@"String", nil] repeats:NO];
                    }*/
                    
                    pendingFretOnString[string] = [self highestFretDownIndexForString:string];
                    [self PluckContinuousString:string atFret:activeFretOnString[string]];
                    
                }
                
            }
            
        }
    }
    
    return NO;
}

- (bool) NoteOnAtString:(int)string andFret:(int)fret
{
    if(!isLoadingInstrument){
        
        [self PluckString:string atFret:fret];
        
    }
    return YES;
}

- (bool) IsNoteOnAtString:(int)string andFret:(int)fret
{
    int noteIndex = [self noteIndexForString:string andFret:fret];
    
    return m_gtarSamplerNode->IsNoteOn(m_activeBankNode, noteIndex);
}

// Gtar Note Off At String
- (bool) NoteOffAtString:(int)string andFret:(int)fret
{
    if(!isLoadingInstrument){
        
        int stopIndex = [self noteIndexForString:string andFret:fret];
        
        if(stopIndex >= 0 && [self IsNoteOnAtString:string andFret:fret]){
            
            if(playingNotesTimers[string][fret] != nil){
                [self EndPluckString:playingNotesTimers[string][fret]];
                
                return YES;
                
            }else{
                [self EndNoteOnString:string andFret:fret];
                
                return YES;
            }
            
        }
        
    }
    return NO;
}

// Note Off Event
- (void) EndNoteOnString:(int)string andFret:(int)fret
{
    int stopIndex = [self noteIndexForString:string andFret:fret];
    
    if(stopIndex >= 0){
        
        m_gtarSamplerNode->NoteOff(m_activeBankNode, stopIndex);
        
    }
}

- (void) StopNoteOnString:(int)string andFret:(int)fret
{
    int stopIndex = [self noteIndexForString:string andFret:fret];
    
    if(stopIndex >= 0){
        m_gtarSamplerNode->StopNote(m_activeBankNode, stopIndex);
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
    
    m_gtarSamplerNode->LoadSampleIntoBank(m_metronome, filepath);

}

- (void)releaseMetronome
{
    [self releaseBank:m_metronome];
}

- (void)playMetronomeTick
{
    m_gtarSamplerNode->TriggerSample(m_metronome,0);
}

#pragma mark - Effects
- (void)initEffects
{
    // setup a chain of effects
    
    // init metadata
    
#ifdef EFFECTS_AVAILABLE
    
    isSlideEnabled = YES;
    
    effectNames = [[NSArray alloc] initWithObjects:
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_SLIDING, NULL)],
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
    m_chorusEffectNode->ConnectInput(0, m_gtarSamplerNode, 0);
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
        BOOL isOn = [[effectStatus objectAtIndex:i] boolValue];
        
        if(isOn){
            [self toggleEffect:i isOn:YES];
        }
    }
    
#endif
}

- (void)toggleEffect:(NSInteger)index isOn:(BOOL)on
{

#ifdef EFFECTS_AVAILABLE
    BOOL isOn = [[effectStatus objectAtIndex:index] boolValue];
    
    NSString * effectNode = [effectNames objectAtIndex:index];
    
    [effectStatus setObject:[NSNumber numberWithBool:!isOn] atIndexedSubscript:index];
    
    if(isOn){
        
        NSLog(@"Toggle effect off for %@",effectNode);
        
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
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_SLIDING, NULL)]){
            
            [self disableSliding];
            
        }
        
    }else{
        
        NSLog(@"Toggle effect on for %@ at %i",[effectNames objectAtIndex:index],index);
        
        if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
            
            m_reverbNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
            
            m_delayNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
            
            m_chorusEffectNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
            
            m_distortionNode->SetPassThru(NO);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_SLIDING, NULL)]){
            
            [self enableSliding];
            
        }
        
        // TODO: refresh jampad
    }
#endif
}

- (NSString *)getEffectNameAtIndex:(NSInteger)index
{
    if(index >= numEffects){
        NSLog(@"Trying to get effect index %i out of range",index);
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
        NSLog(@"Trying to get effect index %i out of range",index);
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
    
    NSLog(@"Get point for effect %@",effectNode);
    
    if(![self isEffectOnAtIndex:index]){
        NSLog(@"Effect %@ not on",effectNode);
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
        
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_SLIDING, NULL)]){
        
        primary = m_gtarSamplerNode->getPrimaryParam();
        secondary = m_gtarSamplerNode->getSecondaryParam();
        
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
        NSLog(@"Effect %@ not on",effectNode);
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
    
    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_SLIDING, NULL)]){
        
        primary = m_gtarSamplerNode->getPrimaryParam();
        secondary = m_gtarSamplerNode->getSecondaryParam();
        
    }else{
        
        return;
    }
    
    pmin = primary->getMin();
    pmax = primary->getMax();
    smin = secondary->getMin();
    smax = secondary->getMax();
    
    pnew = position.x*(pmax - pmin) + pmin;
    snew = position.y*(smax - smin) + smin;
    
    NSLog(@"Update %@ to %f %f",effectNode,pnew,snew);
    
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

    }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_SLIDING, NULL)]){
        
        m_gtarSamplerNode->setPrimaryParam(pnew);
        m_gtarSamplerNode->setSecondaryParam(snew);
        
    }
    
#endif
}


@end
