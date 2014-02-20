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
#define NAVWIDTH 76
#define NAVTAB 0
#define SELECTORWIDTH 364
#define SELECTORHEIGHT 276

@implementation SequencerViewController

@synthesize optionsViewController;
@synthesize seqSetViewController;
@synthesize instrumentViewController;
@synthesize playControlViewController;
@synthesize infoViewController;
@synthesize leftNavigator;

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
    self.seqSetViewController = nil;
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
    
    onScreenMainFrame = CGRectMake(0,0,XBASE,TABLEHEIGHT);
    overScreenMainFrame = CGRectMake(NAVWIDTH-NAVTAB,0,XBASE,TABLEHEIGHT);
    
    //
    // SUBVIEW: OPTIONS
    //
    
    optionsViewController = [[OptionsViewController alloc] initWithNibName:@"OptionsView" bundle:nil];
    [optionsViewController.view setFrame:onScreenMainFrame];
    [optionsViewController setDelegate:self];
    
    [optionsViewController.view setHidden:YES];
    [self.view addSubview:optionsViewController.view];
    
    //
    // SUBVIEW: SET
    //
    
    seqSetViewController = [[SeqSetViewController alloc] initWithNibName:@"SeqSetView" bundle:nil];
    [seqSetViewController.view setFrame:onScreenMainFrame];
    [seqSetViewController setDelegate:self];
    
    NSLog(@"Get current instrument: Sequencer View Controller");
    Instrument * currentInstrument = [seqSetViewController getCurrentInstrument];
    
    if (currentInstrument){
        guitarView.measure = currentInstrument.selectedPattern.selectedMeasure;
    }
    
    [seqSetViewController.view setHidden:NO];
    [self.view addSubview:seqSetViewController.view];
    activeMainView = seqSetViewController.view;
    
    //
    // SUBVIEW: INSTRUMENT
    //
    
    instrumentViewController = [[InstrumentViewController alloc] initWithNibName:@"InstrumentViewController" bundle:nil];
    [instrumentViewController.view setFrame:onScreenMainFrame];
    [instrumentViewController setDelegate:self];
    
    [instrumentViewController.view setHidden:YES];
    [self.view addSubview:instrumentViewController.view];
    
    
    //
    // SUBVIEW: INFO
    //
    
    infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    [infoViewController.view setFrame:onScreenMainFrame];
    [infoViewController setDelegate:self];
    
    [infoViewController.view setHidden:YES];
    [self.view addSubview:infoViewController.view];
    
    
    //
    //  BOTTOM BAR
    //
    
    playControlViewController = [[PlayControlViewController alloc] initWithNibName:@"BottomBar" bundle:nil];
    [playControlViewController.view setFrame:CGRectMake(0,TABLEHEIGHT-4,XBASE,YBASE-TABLEHEIGHT+3)];
    [playControlViewController setDelegate:self];
    
    isPlaying = NO;
    
    [self.view addSubview:playControlViewController.view];
    
    //
    // LEFT NAVIGATOR
    //
    
    onScreenNavigatorFrame = CGRectMake(0,0,NAVWIDTH,TABLEHEIGHT);
    offLeftNavigatorFrame = CGRectMake(-1*NAVWIDTH+NAVTAB,0,NAVWIDTH,TABLEHEIGHT);
    
    leftNavigator = [[LeftNavigatorViewController alloc] initWithNibName:@"LeftNavigatorViewController" bundle:nil];
    [leftNavigator.view setFrame:offLeftNavigatorFrame];
    [leftNavigator setDelegate:self];
    leftNavOpen = false;
    [self selectNavChoice:@"Set" withShift:NO];
    
    [self.view addSubview:leftNavigator.view];
    
    //
    // GTAR CONNECTED
    //
    [leftNavigator changeConnectedButton:false];
    
    //
    // GESTURES
    //
    
    [self startGestures];
    
}

#pragma mark - Left Navigator Delegate

- (BOOL)isLeftNavOpen
{
    return leftNavOpen;
}

- (void)closeLeftNavigator
{
    [seqSetViewController turnEditingOn];
    [UIView animateWithDuration:0.1 animations:^(){
        [leftNavigator.view setFrame:offLeftNavigatorFrame];
        [activeMainView setFrame:onScreenMainFrame];
    } completion:^(BOOL finished){
        leftNavOpen = false;
    }];
}

- (void)openLeftNavigator
{
    [seqSetViewController turnEditingOff];
    [UIView animateWithDuration:0.1 animations:^(){
        [leftNavigator.view setFrame:onScreenNavigatorFrame];
        [activeMainView setFrame:overScreenMainFrame];
    } completion:^(BOOL finished){
        leftNavOpen = true;
    }];
}

- (void)toggleLeftNavigator
{
    if(leftNavOpen){
        [self closeLeftNavigator];
    }else{
        [self openLeftNavigator];
    }
}

- (void)selectNavChoice:(NSString *)nav withShift:(BOOL)shift
{
    
    NSLog(@"Switch to %@ view",nav);
    
    [optionsViewController.view setHidden:YES];
    [seqSetViewController.view setHidden:YES];
    [instrumentViewController.view setHidden:YES];
    [shareViewController.view setHidden:YES];
    [infoViewController.view setHidden:YES];
    
    // Do any view unloading
    [optionsViewController unloadView];
    
    // Switch to new main subview
    if([nav isEqualToString:@"Options"]){
        
        [optionsViewController reloadFileTable];
        activeMainView = optionsViewController.view;
        
    }else if([nav isEqualToString:@"Set"]){
    
        [seqSetViewController reloadTableData];
        activeMainView = seqSetViewController.view;
        
    }else if([nav isEqualToString:@"Instrument"]){
        
        [instrumentViewController reopenView];
        activeMainView = instrumentViewController.view;
        
        NSLog(@"Get current instrument: Nav Controller");
        Instrument * newInstrument = [seqSetViewController getCurrentInstrument];
        [instrumentViewController setActiveInstrument:newInstrument];
        
    }else if([nav isEqualToString:@"Share"]){
        
        activeMainView = shareViewController.view;
        
    }else if([nav isEqualToString:@"Info"]){
        
        activeMainView = infoViewController.view;
        
    }
    
    // set nav button
    [leftNavigator setNavButtonOn:nav];
    
    // handle positioning
    if(leftNavOpen){
        [self closeLeftNavigator];
        [activeMainView setFrame:onScreenMainFrame];
    }else{
        if(shift){
            [activeMainView setFrame:overScreenMainFrame];
        }else{
            [activeMainView setFrame:onScreenMainFrame];
        }
    }
    [activeMainView setHidden:NO];
    
}

- (void)viewSeqSet
{
    [self selectNavChoice:@"Set" withShift:NO];
}

- (void)viewSelectedInstrument
{
    [self selectNavChoice:@"Instrument" withShift:NO];
}

- (void)setSelectedInstrument:(NSString *)iconName
{
    [leftNavigator enableInstrumentViewWithIcon:iconName];
}

#pragma mark - Save Load Delegate

- (void)userDidLoadSequenceOptions
{
    //[optionsViewController userDidSaveSequence];
}

- (void)saveWithName:(NSString *)filename
{
    activeSequencer = filename;
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [self saveContext:filepath];
    [self saveContext:nil];
}

- (void)loadFromName:(NSString *)filename
{
    activeSequencer = filename;
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [self loadStateFromDisk:filepath];
    [self saveContext:nil];
}

- (void)renameFromName:(NSString *)filename toName:(NSString *)newname
{
    if([activeSequencer isEqualToString:filename]){
        activeSequencer = newname;
    }
    
    filename = [@"usr_" stringByAppendingString:filename];
    newname = [@"usr_" stringByAppendingString:newname];
    
    // move
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * currentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newname];
    NSError * error = NULL;
    
    BOOL result = [[NSFileManager defaultManager] moveItemAtPath:currentPath toPath:newPath error:&error];
    
    if(!result)
        NSLog(@"Error moving");
   
    [self saveContext:nil];
}

- (void)createNewWithName:(NSString *)filename
{
    [seqSetViewController deleteAllCells];
    
    [self saveWithName:filename];
}

- (void)deleteWithName:(NSString *)filename
{
    /*NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    NSString * directoryPath = [paths objectAtIndex:0];
    
    NSMutableArray * fileSet = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    // Exclude four default files
    for(NSString * path in fileSet){
        
        NSString * fullPath = [directoryPath stringByAppendingPathComponent:path];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        
    }*/
    
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * currentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSError * error = NULL;
    
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:currentPath error:&error];
    
    if(!result)
        NSLog(@"Error deleting");
    
    [self saveContext:nil];
}


#pragma mark - Auto Save Load
- (void)saveContext:(NSString *)filepath
{
    if(filepath == nil){
        filepath = instrumentDataFilePath;
        NSLog(@"Save state to disk");
    }else{
        NSLog(@"Save state to disk at %@",filepath);
    }
    
    NSData * instData = [NSKeyedArchiver archivedDataWithRootObject:[seqSetViewController getInstruments]];
    
    NSNumber * tempoNumber = [NSNumber numberWithInt:[playControlViewController getTempo]];
    
    NSNumber * volumeNumber = [NSNumber numberWithDouble:[playControlViewController getVolume]];
    
    NSNumber * selectedInstIndexNumber = [NSNumber numberWithInt:[seqSetViewController getSelectedInstrumentIndex]];
    
    [currentState setObject:instData forKey:@"Instruments Data"];
    [currentState setObject:tempoNumber forKey:@"Tempo"];
    [currentState setObject:volumeNumber forKey:@"Volume"];
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
        
        double volume = [[currentState objectForKey:@"Volume"] doubleValue];
        [playControlViewController setVolume:volume];
        
        // Decode selectedInstrumentIndex
        [seqSetViewController setSelectedInstrumentIndex:[[currentState objectForKey:@"Selected Instrument Index"] intValue]];
        
        // Decode array of instruments:
        NSData * instrumentData = [currentState objectForKey:@"Instruments Data"];
        [seqSetViewController setInstrumentsFromData:instrumentData];
        
        // Decode active sequencer filename
        NSString * sequencerName = [currentState objectForKey:@"Active Sequencer"];
        if(![sequencerName isEqualToString:@""]){
            activeSequencer = sequencerName;
            optionsViewController.activeSequencer = sequencerName;
        }

        // Load icon into left navigator
        
        NSLog(@"Get current instrument: Load Icon");
        Instrument * selectedInst = [seqSetViewController getCurrentInstrument];
        if(selectedInst != nil){
            [leftNavigator enableInstrumentViewWithIcon:selectedInst.iconName];
        }
        
    }else{
        [playControlViewController resetTempo];
        [playControlViewController resetVolume];
        [seqSetViewController resetSelectedInstrumentIndex];
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
    int instrumentCount = [seqSetViewController countInstruments];
    for (int i=0; i<instrumentCount; i++){
        
        Instrument * instToPlay = [seqSetViewController getInstrumentAtIndex:i];
        
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
                [seqSetViewController notifyQueuedPatternsAtIndex:i andResetCount:resetCount];
                
                // update Instrument view if it's open
                if(activeMainView == instrumentViewController.view && instToPlay == [seqSetViewController getCurrentInstrument]){
                    [instrumentViewController notifyQueuedPatternAndResetCount:resetCount];
                }
            }
            
            // play sound and update Set view
            [instToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!instToPlay.isMuted withAmplitude:playVolume];
            
            // update Instrument view if it's open
            if(activeMainView == instrumentViewController.view && instToPlay == [seqSetViewController getCurrentInstrument]){
                [instrumentViewController setPlaybandForMeasure:realMeasure toPlayband:currentFret];
            }
        }
    }
    
    [seqSetViewController updateAllVisibleCells];
    
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
                [seqSetViewController commitSelectingPatternAtIndex:nextPatternIndex forInstrument:nextPatternInstrument];
                
                if(activeMainView == instrumentViewController.view && inst==[seqSetViewController getCurrentInstrument]){
                    [instrumentViewController commitPatternChange:nextPatternIndex];
                }
                
                [self dequeuePatternAtIndex:inst.instrument];
            }
        }
        
        [patternQueue removeObjectsInArray:objectsToRemove];
    }
}

- (void)enqueuePattern:(NSMutableDictionary *)pattern
{
    // For now, clear all the queued patterns for the active instrument
    [self removeQueuedPatternForInstrumentAtIndex:[seqSetViewController getCurrentInstrument].instrument];
    
    @synchronized(patternQueue){
        [patternQueue addObject:pattern];
    }
    
    NSLog(@"Pattern Queue is: %@",patternQueue);
}

-(void)dequeueAllPatternsForInstrument:(Instrument *)inst
{
    for(NSMutableDictionary * p in patternQueue){
        Instrument * i = [p objectForKey:@"Instrument"];
        if(i == inst)
        {
            [patternQueue removeObject:p];
        }
    }
}

-(void)removeQueuedPatternForInstrumentAtIndex:(int)instIndex
{
    for(NSMutableDictionary * p in patternQueue){
        Instrument * i = [p objectForKey:@"Instrument"];
        if(i.instrument == instIndex)
        {
            [patternQueue removeObject:p];
        }
    }
}

- (void)dequeuePatternAtIndex:(int)instIndex
{
    NSLog(@"dequeuing pattern for instrument at index %i",instIndex);
    [seqSetViewController clearQueuedPatternButtonAtIndex:instIndex];
}

#pragma mark - Play Control Delegate

- (void)startGestures
{
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftNavigator)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [swipeLeft setNumberOfTouchesRequired:1];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openLeftNavigator)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [swipeRight setNumberOfTouchesRequired:1];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];

}

- (void)stopGestures
{
    [self.view removeGestureRecognizer:swipeLeft];
    [self.view removeGestureRecognizer:swipeRight];
}

- (void)stopAllPlaying
{
    isPlaying = FALSE;
    [playTimer invalidate];
    playTimer = nil;
}

- (void)startAllPlaying:(float)spb withAmplitude:(double)volume
{
    isPlaying = TRUE;
    playVolume = volume;
    
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
    if(TESTMODE) NSLog(@"Increase play location");
    
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


#pragma mark - Seq Set Delegate

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
    
    // Also update selected instrument
    [self setSelectedInstrument:[seqSetViewController getCurrentInstrument].iconName];
    
    // Also update the selected table cell
    //[seqSetViewController setSelectedCellToSelectedInstrument];
    
}

- (void)updateSelectedInstrument
{
    [self setSelectedInstrument:[seqSetViewController getCurrentInstrument].iconName];
}

// Ensure current playband is reflected in the data if displayed (>=0)
// Only need to call when # measures changes
- (void)updatePlaybandForInstrument:(Instrument *)inst
{
    if (currentFret >= 0){
        int realMeasure = [inst.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
        [inst playFret:currentFret inRealMeasure:realMeasure withSound:NO withAmplitude:playVolume];
        
        // update Instrument view if it's open
        if(activeMainView == instrumentViewController.view && inst == [seqSetViewController getCurrentInstrument]){
            [instrumentViewController setPlaybandForMeasure:realMeasure toPlayband:currentFret];
        }
    }
    
    NSLog(@"updatePlaybandForInstrument");
}

- (void) numInstrumentsDidChange:(int)numInstruments
{
    if(numInstruments > 0){
        [leftNavigator enableInstrumentViewWithIcon:[seqSetViewController getCurrentInstrument].iconName];
    }else{
        [leftNavigator disableInstrumentView];
    }
}

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{
    if (!isConnected || fr == 0){
        return;
    }
    
    if ([seqSetViewController getSelectedInstrumentIndex] < 0 || [seqSetViewController countInstruments] == 0){
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
    [[seqSetViewController getCurrentInstrument] notePlayedAtString:note.string andFret:note.fret];
    
    [seqSetViewController updateAllVisibleCells];
    
    [guitarView update];
    
    [self saveContext:nil];
}

#pragma mark - gTar Connected

- (void)gtarConnected:(BOOL)toConnect
{
    if(toConnect) NSLog(@"gTar connected");
    else NSLog(@"gTar disconnected");
    
    isConnected = toConnect;
    
    [leftNavigator changeConnectedButton:isConnected];
}


@end
