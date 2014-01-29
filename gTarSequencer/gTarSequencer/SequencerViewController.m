//
//  SequencerViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SequencerViewController.h"

#define MAX_SEQUENCES 15
#define LAST_FRET 15
#define LAST_MEASURE 3

#define XBASE 480
#define YBASE 320
#define TABLEHEIGHT 264

@implementation SequencerViewController

@synthesize instrumentTableViewController;
@synthesize playControlViewController;
@synthesize gTarConnectedBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initGlobalData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    [self loadStateFromDisk:nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view
    self.instrumentTableViewController = nil;
    self.playControlViewController = nil;
    
}

- (void)initGlobalData
{
    
    // Paths to load/save on disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    instrumentDataFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sequencerCurrentState"];
    
    // Gtar delegate and connection spoof
    if(TESTMODE) NSLog(@"Setup and connect gTar");
    //isConnected = NO;
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
    
    if(TESTMODE){
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:guitarView selector:@selector(observeGtar) userInfo:nil repeats:NO];
    }
    
    string = 0;
    fret = 0;
    
    patternQueue = [NSMutableArray array];
}

- (void)initSubviews
{
    
    // Instrument table
    if(TESTMODE) NSLog(@"Build the instrument table");
    
    instrumentTableViewController = [[InstrumentTableViewController alloc] initWithNibName:@"InstrumentTableView" bundle:nil];
    [instrumentTableViewController.view setFrame:CGRectMake(0, 0, XBASE, TABLEHEIGHT)];
    [instrumentTableViewController setDelegate:self];
    
    Instrument * currentInstrument = [instrumentTableViewController getCurrentInstrument];
    
    if (currentInstrument){
        guitarView.measure = currentInstrument.selectedPattern.selectedMeasure;
    }
    
    [self.view addSubview:instrumentTableViewController.view];
    
    // Tempo slider and play/pause
    if(TESTMODE) NSLog(@"Start to build the bottom bar");
    
    playControlViewController = [[PlayControlViewController alloc] initWithNibName:@"BottomBar" bundle:nil];
    [playControlViewController.view setFrame:CGRectMake(0,TABLEHEIGHT-4,XBASE,YBASE-TABLEHEIGHT+3)];
    [playControlViewController setDelegate:self];
    
    isPlaying = NO;
    
    [self.view addSubview:playControlViewController.view];
    
    // gTar connected bar
    CGRect barFrame = CGRectMake(0,0,XBASE,43);
    
    gTarConnectedBar = [[UIButton alloc] initWithFrame:barFrame];
    [gTarConnectedBar setTitle:@"gTar NOT CONNECTED" forState:UIControlStateNormal];
    [gTarConnectedBar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [gTarConnectedBar.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [gTarConnectedBar setBackgroundColor:[UIColor colorWithRed:194/255.0 green:46/255.0 blue:26/255.0 alpha:0.9]];
    [self.view addSubview:gTarConnectedBar];
    
    [gTarConnectedBar addTarget:self action:@selector(gTarConnectedToggleBarOff) forControlEvents:UIControlEventTouchUpInside];
    
    // Save load selector
    [self initSaveLoadSelector];
    
}

#pragma mark - Save Load Delegate

- (void)initSaveLoadSelector
{
    // TODO: figure out positioning for 4"
    NSLog(@"Init save load selector");
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    // construct selector:
    CGFloat selectorWidth = 364;
    CGFloat selectorHeight = 276;
    
    onScreenSaveLoadFrame = CGRectMake((x-selectorWidth)/2,
                                       (y-selectorHeight)/2,
                                       selectorWidth,
                                       selectorHeight);
    
    offLeftSaveLoadFrame = CGRectMake(onScreenSaveLoadFrame.origin.x,
                                        y,
                                        onScreenSaveLoadFrame.size.width,
                                        onScreenSaveLoadFrame.size.height);
    
    saveLoadSelector = [[SaveLoadSelector alloc] initWithFrame:offLeftSaveLoadFrame];
    [saveLoadSelector setDelegate:self];
    
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:saveLoadSelector];
    
    [saveLoadSelector setHidden:YES];
}

- (void)userDidLoadSequenceOptions
{
    
    [saveLoadSelector setHidden:NO];
    [saveLoadSelector moveFrame:offLeftSaveLoadFrame];
    [saveLoadSelector userDidSaveSequence];
    
    saveLoadSelector.alpha = 1.0;
    
    [UIView animateWithDuration:0.5f animations:^{[saveLoadSelector moveFrame:onScreenSaveLoadFrame];}];
    
    saveLoadSelector.userInteractionEnabled = YES;
    
}

- (void)closeSaveLoadSelector
{
    [UIView animateWithDuration:0.5f
                     animations:^{[saveLoadSelector moveFrame:offLeftSaveLoadFrame]; saveLoadSelector.alpha = 0.3;}
                     completion:^(BOOL finished){[self hideSaveLoadSelector]; }];
}

- (void)hideSaveLoadSelector
{
    [saveLoadSelector setHidden:YES];
}

- (void)saveWithName:(NSString *)filename
{
    activeSequencer = filename;
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [self closeSaveLoadSelector];
    
    [self saveContext:filepath];
    [self saveContext:nil];
}

- (void)loadFromName:(NSString *)filename
{
    activeSequencer = filename;
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [self closeSaveLoadSelector];
    
    [self loadStateFromDisk:filepath];
    [self saveContext:nil];
}


#pragma mark - Auto Save Load
- (void)saveContext:(NSString *)filepath
{
    if(filepath == nil){
        filepath = instrumentDataFilePath;
        NSLog(@"Load sequencer from disk");
    }else{
        NSLog(@"Save state to disk at %@",filepath);
    }
    
    NSData * instData = [NSKeyedArchiver archivedDataWithRootObject:[instrumentTableViewController getInstruments]];
    
    NSNumber * tempoNumber = [NSNumber numberWithInt:[playControlViewController getTempo]];
    
    NSNumber * selectedInstIndexNumber = [NSNumber numberWithInt:[instrumentTableViewController getSelectedInstrumentIndex]];
    
    [currentState setObject:instData forKey:@"Instruments Data"];
    [currentState setObject:tempoNumber forKey:@"Tempo"];
    [currentState setObject:selectedInstIndexNumber forKey:@"Selected Instrument Index"];
    
    if(activeSequencer){
        [currentState setObject:activeSequencer forKey:@"Active Sequencer"];
    }else{
        [currentState setObject:@"" forKey:@"Active Sequencer"];
    }
    
    BOOL success = [currentState writeToFile:filepath atomically:YES];
    
    NSLog(@"Save success: %i", success);
}

- (void)loadStateFromDisk:(NSString *)filepath
{
    
    if(filepath == nil){
        filepath = instrumentDataFilePath;
        NSLog(@"Load state from disk");
    }else{
        NSLog(@"Load sequencer from disk at %@", filepath);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filepath]) {
        NSLog(@"The sequencer save plist exists");
    } else {
        NSLog(@"The sequencer save plist does not exist");
    }
    
    currentState = [[NSDictionary dictionaryWithContentsOfFile:filepath] mutableCopy];
    
    if (currentState == nil )
        currentState = [[NSMutableDictionary alloc] init];
    
    if ( [[currentState allKeys] count] > 0 )
    {
        // Decode tempo:
        int tempo = [[currentState objectForKey:@"Tempo"] intValue];
        [playControlViewController setTempo:tempo];
        
        // Decode array of instruments:
        NSData * instrumentData = [currentState objectForKey:@"Instruments Data"];
        [instrumentTableViewController setInstrumentsFromData:instrumentData];
        
        // Decode selectedInstrumentIndex
        [instrumentTableViewController setSelectedInstrumentIndex:[[currentState objectForKey:@"Selected Instrument Index"] intValue]];
        
        // Decode active sequencer filename
        NSString * sequencerName = [currentState objectForKey:@"Active Sequencer"];
        if(![sequencerName isEqualToString:@""]){
            activeSequencer = sequencerName;
            saveLoadSelector.activeSequencer = sequencerName;
        }
    }else{
        [playControlViewController resetTempo];
        [instrumentTableViewController resetSelectedInstrumentIndex];
    }
}

#pragma mark - Play Events

- (void)startBackgroundLoop:(NSNumber *)spb
{
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    
    if(TESTMODE) NSLog(@"Starting Background Loop with %f seconds per beat",[spb floatValue]);
    
    playTimer = [NSTimer scheduledTimerWithTimeInterval:[spb floatValue] target:self selector:@selector(mainEventLoop) userInfo:nil repeats:YES];
    
    [runLoop run];
}

- (void)mainEventLoop
{
    
    // Tell all of the sequencers to play their next fret
    int instrumentCount = [instrumentTableViewController countInstruments];
    for (int i=0; i<instrumentCount; i++){
        
        Instrument * instToPlay = [instrumentTableViewController getInstrumentAtIndex:i];
        
        @synchronized(instToPlay.selectedPattern){
            int realMeasure = [instToPlay.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
            
            // If we are back at the beginning of the pattern, then check the queue:
            if (realMeasure == 0 && currentFret == 0 && [patternQueue count] > 0){
                [self checkQueueForPatternsFromInstrument:instToPlay];
            }else if([patternQueue count] > 0){
                
                BOOL resetCount = NO;
                if(currentFret == 0){
                    resetCount = YES;
                }
                
                // Cause queued pattern to blink
                [instrumentTableViewController notifyQueuedPatternsAtIndex:i andResetCount:resetCount];
            }
            
            [instToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!instToPlay.isMuted];
        }
    }
    
    [instrumentTableViewController updateAllVisibleCells];
    
    [guitarView update];
    
    [self increasePlayLocation];
    
    if(TESTMODE) NSLog(@"Main event loop");
}


#pragma mark - Pattern Queue

- (void)checkQueueForPatternsFromInstrument:(Instrument *)inst
{
    
    NSLog(@"CHECK QUEUE FOR PATTERNS FROM INSTRUMENT");
    
    NSMutableArray * objectsToRemove = [NSMutableArray array];
    
    @synchronized(patternQueue)
    {
        // Pull out every pattern in the queue and select it
        for (NSDictionary * patternToSelect in patternQueue)
        {
            int nextPatternIndex = [[patternToSelect objectForKey:@"Index"] intValue];
            Instrument * nextPatternInstrument = [patternToSelect objectForKey:@"Instrument"];
            
            if (inst == nextPatternInstrument){
                NSLog(@"DEQUEUEING THE NEXT PATTERN");
                [objectsToRemove addObject:patternToSelect];
                [instrumentTableViewController commitSelectingPatternAtIndex:nextPatternIndex forInstrument:nextPatternInstrument];
            }
        }
        
        [patternQueue removeObjectsInArray:objectsToRemove];
    }
}

- (void)enqueuePattern:(NSMutableDictionary *)pattern
{
    @synchronized(patternQueue){
        [patternQueue addObject:pattern];
    }
}


#pragma mark - Play Control Delegate

- (void)stopAllPlaying
{
    isPlaying = FALSE;
    [playTimer invalidate];
    playTimer = nil;
}

- (void)startAllPlaying:(float)spb
{
    isPlaying = TRUE;
    
    [self performSelectorInBackground:@selector(startBackgroundLoop:) withObject:[NSNumber numberWithFloat:spb]];
}

- (void)initPlayLocation
{
    if(currentFret == -1){
        [self increasePlayLocation];
    }
}

- (void)increasePlayLocation
{
    NSLog(@"Increase play location");
    
    currentFret++;
    
    if (currentFret > LAST_FRET){
        currentFret = 0;
        currentAbsoluteMeasure++;
        
        if (currentAbsoluteMeasure > LAST_MEASURE){
            currentAbsoluteMeasure = 0;
        }
    }
}

- (void)resetPlayLocation
{
    currentFret = -1;
    currentAbsoluteMeasure = 0;
}


#pragma mark - Instrument Delegate

- (BOOL)checkIsPlaying
{
    return isPlaying;
}

- (void)forceStopAll
{
    [playControlViewController stopAll];
}

- (void)setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying
{
    guitarView.measure = measure;
    
    if(!checkNotPlaying || (checkNotPlaying && !isPlaying)){
        [guitarView update];
    }
}

- (void)turnOffGuitarEffects
{
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
}

- (void)updateGuitarView
{
    [guitarView update];
}

// Ensure current playband is reflected in the data if displayed (>=0)
// Only need to call when # measures changes
- (void)updatePlaybandForInstrument:(Instrument *)inst
{
    if (currentFret >= 0){
        int realMeasure = [inst.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
        [inst playFret:currentFret inRealMeasure:realMeasure withSound:NO];
    }
    
    NSLog(@"update playband...");
}

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{
    if (!isConnected || fr == 0){
        return;
    }
    
    if ([instrumentTableViewController getSelectedInstrumentIndex] < 0 || [instrumentTableViewController countInstruments] == 0){
        NSLog(@"No Instruments opened, or selected instrument index < 0");
        return;
    }
    
    NSLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];
    
}

- (void)notePlayed:(SEQNote *)note
{
    NSLog(@"gTarSeq received note played message string %i and fret %i",note.string,note.fret);
    
    // Pass note-played message onto the selected instrument
    [[instrumentTableViewController getCurrentInstrument] notePlayedAtString:note.string andFret:note.fret];
    
    [instrumentTableViewController updateAllVisibleCells];
    
    [guitarView update];
    
    [self saveContext:nil];
}

#pragma mark - gTar Connected

- (void)gtarConnected:(BOOL)toConnect
{
    
    if(toConnect) NSLog(@"gTar connected");
    else NSLog(@"gTar disconnected");
    
    isConnected = toConnect;
    
    [self updategTarConnectedBar];
}

- (void)updategTarConnectedBar
{
    if(TESTMODE) NSLog(@"Update connected image");
    
    if (isConnected){
        [gTarConnectedBar setTitle:@"gTar CONNECTED" forState:UIControlStateNormal];
        [gTarConnectedBar setBackgroundColor:[UIColor colorWithRed:40/255.0 green:194/255.0 blue:94/255.0 alpha:0.9]];
    
    }else{
        [gTarConnectedBar setTitle:@"gTar NOT CONNECTED" forState:UIControlStateNormal];
        [gTarConnectedBar setBackgroundColor:[UIColor colorWithRed:194/255.0 green:46/255.0 blue:26/255.0 alpha:0.9]];
    }

    [self gTarConnectedToggleBarOn];

}

- (void)gTarConnectedToggleBarOff
{
    CGRect hiddenFrame = CGRectMake(0,-1*gTarConnectedBar.frame.size.height,gTarConnectedBar.frame.size.width,gTarConnectedBar.frame.size.height);
    [UIView animateWithDuration:0.5f animations:^(){
        [gTarConnectedBar setFrame:hiddenFrame];
    }];
}

- (void)gTarConnectedToggleBarOn
{
    
    CGRect normalFrame = CGRectMake(0,0,gTarConnectedBar.frame.size.width,gTarConnectedBar.frame.size.height);
    [UIView animateWithDuration:0.5f animations:^(){
        [gTarConnectedBar setFrame:normalFrame];
    }];
}

@end
