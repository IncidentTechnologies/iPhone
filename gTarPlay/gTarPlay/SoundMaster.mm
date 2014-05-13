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

#define GTAR_NUM_STRINGS 6
#define GTAR_NUM_FRETS 16

#define GRAPH_SAMPLE_RATE 44100.0f

#define EFFECTS_AVAILABLE 1
#define EFFECT_NAME_REVERB @"Reverb"
#define EFFECT_NAME_DELAY @"Echo"
#define EFFECT_NAME_CHORUS @"Chorus"
#define EFFECT_NAME_DISTORT @"Distortion"

#define DEFAULT_INSTRUMENT @"Electric Guitar"

#define DEFAULT_GAIN 0.5
#define GAIN_MULTIPLIER 1.0

@interface SoundMaster ()
{
    AudioController * audioController;
    AudioNode * root;
    
    SamplerNode * m_samplerNode;
    SamplerBankNode * m_activeBankNode;
    SamplerBankNode * m_metronome;
    
    // Effects
    //EnvelopeNode * m_envelopeNode;
#ifdef EFFECTS_AVAILABLE
    DelayNode * m_delayNode;
    ReverbNode * m_reverbNode;
    ChorusEffectNode * m_chorusEffectNode;
    DistortionNode * m_distortionNode;
    ButterWorthFilterNode * m_butterworthNode;
#endif
    
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
    
    m_samplerNode = new SamplerNode;
    m_samplerNode->SetChannelGain(DEFAULT_GAIN, CONN_OUT);
    
    root->ConnectInput(0, m_samplerNode, 0);
    
    if(!m_instruments && ![self loadInstrumentArray]){
        NSLog(@"Failed to load instrument array from instrument.plist");
        return false;
    }
    
    [self initEffects];
    
    [self initMetronome];
    
    //[audioController initializeAUGraph];
    
    return true;
    
}

- (void)reset
{
    NSLog(@"Reset audio");
    
    //[self stop];
    
    //[self initAudio];
    
    //[self start];
}

- (SamplerBankNode *)generateBank
{
    NSLog(@"Generate bank");
    
    SamplerBankNode * m_samplerBank = NULL;
    m_samplerNode->CreateNewBank(m_samplerBank);
    
    return m_samplerBank;
}

- (void)releaseBank:(SamplerBankNode *)bank
{
    
    // Start and stop the AUGraph with timing
    
    NSLog(@"Release bank");
    
    m_samplerNode->ReleaseBank(bank);
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
    if(m_activeBankNode != nil){
        int numSamples = m_activeBankNode->m_samples.length();
        for(int i = 0; i < numSamples; i++){
            m_activeBankNode->StopSample(i);
        }
    }
    
    [audioController stopAUGraph];
}

- (void)releaseCompletely
{
    NSLog(@"Disconnect and release SoundMaster");
    
    [self stop];
    
    [self stopAllEffects];
    
    // release envelope node
    //m_envelopeNode->DeleteAndDisconnect(CONN_OUT);
    //m_envelopeNode = nil;
    
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
    
    // ARC: (__bridge NSString *)audioRoute
    return (__bridge NSString *)audioRoute;
}

#pragma mark - Volume
- (void) setChannelGain:(float)gain
{
    NSLog(@"Set channel gain to %f",gain*GAIN_MULTIPLIER);
    m_samplerNode->SetChannelGain(gain*GAIN_MULTIPLIER, CONN_OUT);
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
    //NSInteger index = [[timer userInfo] intValue];
    
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
    
    [self releaseInstrument:currentInstrumentIndex];
    
    currentInstrumentIndex = index;
    
    // Generate a bank
    SamplerBankNode * newBank = [self generateBank];
    NSMutableDictionary * instrument = [m_instruments objectAtIndex:index];
    
    NSLog(@"Load samples for instrument %i",index);
    
    int firstNote = [[instrument objectForKey:@"FirstNoteMidiNum"] intValue];
    int numNotes = [[instrument objectForKey:@"NumNotes"] intValue];
    
    if(m_instruments && index < [m_instruments count] && index > -1){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            SampleNode * newSample;
            
            NSString * instrumentName = [instrument objectForKey:@"Name"];
            if([instrumentName isEqualToString:@"Electric"] || [instrumentName isEqualToString:@"Strat"]){
                instrumentName = DEFAULT_INSTRUMENT;
            }
            
            for(int j = firstNote; j < firstNote+numNotes; j++){
                
                // make sure instrument hasn't been released off thread
                if(currentInstrumentIndex == index){
                    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:[instrumentName stringByAppendingFormat:@" %i",j] ofType:@"mp3"] UTF8String];
                    
                    newBank->LoadSampleIntoBank(filepath, newSample);
                }
            }
            
            // broadcast instrument changed
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:currentInstrumentIndex ], @"instrumentIndex", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InstrumentChanged" object:self userInfo:userInfo];
            
            NSLog(@"Changed instrument to %@",[instrument objectForKey:@"Name"]);
            
            // Add an entry
            m_activeBankNode = newBank;
            
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

- (void) releaseInstrument:(NSInteger)index
{
    //if(m_tuning != nil){
    //    [m_tuning release];
    //}
    
    if(index > -1){
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
        if(string >= 0 && string < GTAR_NUM_STRINGS && fret >= 0 && fret <= GTAR_NUM_FRETS){
            
            if(m_activeBankNode == nil){
                [self setCurrentInstrument:0 withSelector:nil andOwner:nil];
            }
            
            int noteIndex = [[m_tuning objectAtIndex:string] intValue] + fret;
            
            NSLog(@"Note at index %i",noteIndex);
            
            m_activeBankNode->TriggerSample(noteIndex);
        }
    }
}

- (bool) FretDown:(int)fret onString:(int)string
{
    NSLog(@" *** fret down *** at f%i s%i",fret,string);
    if(!isLoadingInstrument){
        //[self PluckString:string atFret:fret];
    }
    return YES;
}

- (bool) FretUp:(int)fret onString:(int)string
{
    NSLog(@" *** fret down *** at f%i s%i",fret,string);
    if(!isLoadingInstrument){
        
    }
    return NO;
}

- (bool) NoteOnAtString:(int)string andFret:(int)fret
{
    NSLog(@" *** fret down *** at f%i s%i",fret,string);
    if(!isLoadingInstrument){
        //[self PluckString:string atFret:fret];
    }
    return YES;
}

- (bool) NoteOffAtString:(int)string andFret:(int)fret
{
    NSLog(@" *** fret down *** at f%i s%i",fret,string);
    if(!isLoadingInstrument){
        //m_envelopeNode->NoteOff();
    }
    return NO;
}

#pragma mark - Metronome
- (void)initMetronome
{
    m_metronome = [self generateBank];
    SampleNode * newSample;
    
    char * filepath = (char *)[[[NSBundle mainBundle] pathForResource:@"Metronome" ofType:@"mp3"] UTF8String];
    
    m_metronome->LoadSampleIntoBank(filepath, newSample);

}

- (void)releaseMetronome
{
    [self releaseBank:m_metronome];
}

- (void)playMetronomeTick
{
    m_metronome->TriggerSample(0);
}

#pragma mark - Effects
- (void)initEffects
{
    // setup a chain of effects
    
    // init metadata
    
#ifdef EFFECTS_AVAILABLE
    effectNames = [[NSArray alloc] initWithObjects:
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)],
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)],
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)],
                   [NSString stringWithString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)],nil];
    
    effectStatus = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],
                    [NSNumber numberWithBool:NO],nil];
    
    numEffects = [effectNames count];

    
    //[self toggleEffect:0 isOn:NO];
    
    // always on
    //m_butterworthNode = new ButterWorthFilterNode(2,8000,GRAPH_SAMPLE_RATE);
    //m_butterworthNode->ConnectInput(0, m_samplerNode, 0);
    //root->ConnectInput(0, m_butterworthNode, 0);
#endif
    
    // Always on
    //m_envelopeNode = new EnvelopeNode();
    //m_envelopeNode->ConnectInput(0, m_samplerNode, 0);
    //root->ConnectInput(0, m_envelopeNode, 0);
    
}

- (void)stopAllEffects
{
    
#ifdef EFFECTS_AVAILABLE
    [self stop];

    @synchronized(self){
        if(m_reverbNode){
            
            [self disconnectAndReleaseEffectNode:m_reverbNode];
            m_reverbNode = nil;
            
        }else if(m_delayNode){
            
            [self disconnectAndReleaseEffectNode:m_delayNode];
            m_delayNode = nil;
            
        }else if(m_chorusEffectNode){
            
            [self disconnectAndReleaseEffectNode:m_chorusEffectNode];
            m_chorusEffectNode = nil;
            
        }else if(m_distortionNode){
            
            [self disconnectAndReleaseEffectNode:m_distortionNode];
            m_distortionNode = nil;
            
        }
    }
    
    for(int i = 0; i < [effectStatus count]; i++){
        [effectStatus setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:i];
    }
    
    [self start];
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
            
            [self disconnectAndReleaseEffectNode:m_reverbNode];
            m_reverbNode = nil;
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
            
            [self disconnectAndReleaseEffectNode:m_delayNode];
            m_delayNode = nil;
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
            
            [self disconnectAndReleaseEffectNode:m_chorusEffectNode];
            m_chorusEffectNode = nil;
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
            
            [self disconnectAndReleaseEffectNode:m_distortionNode];
            m_distortionNode = nil;
            
        }
        
    }else{
        
        NSLog(@"Toggle effect on for %@ at %i",[effectNames objectAtIndex:index],index);
        
        if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_REVERB, NULL)]){
            
            m_reverbNode = new ReverbNode(0.75); // wet
            m_reverbNode->ConnectInput(0, m_samplerNode, 0);
            root->ConnectInput(0, m_reverbNode, 0);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DELAY, NULL)]){
            
            m_delayNode = new DelayNode(500,     // ms delay
                                        0.5,    // feedback
                                        1.0     // wet
                                        );
            m_delayNode->ConnectInput(0, m_samplerNode, 0);
            root->ConnectInput(0, m_delayNode, 0);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_CHORUS, NULL)]){
            
            m_chorusEffectNode = new ChorusEffectNode(25,               // delay
                                                      0.75,             // depth
                                                      0.05,             // width
                                                      3.0,              // frequency
                                                      1.0,              // wet
                                                      GRAPH_SAMPLE_RATE);
            m_chorusEffectNode->ConnectInput(0, m_samplerNode, 0);
            root->ConnectInput(0, m_chorusEffectNode, 0);
            
        }else if([effectNode isEqualToString:NSLocalizedString(EFFECT_NAME_DISTORT, NULL)]){
            
            m_distortionNode = new DistortionNode(3.78,             // gain
                                                  0.25,             // wet
                                                  GRAPH_SAMPLE_RATE);
            m_distortionNode->ConnectInput(0, m_samplerNode, 0);
            root->ConnectInput(0, m_distortionNode, 0);
            
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

    }    
#endif
}

@end
