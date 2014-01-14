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

SoundMaker * audio;

@implementation SequencerViewController

@synthesize instrumentTableViewController;
@synthesize playControlViewController;
@synthesize gTarLogoImageView;
@synthesize gTarConnectedText;

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
    audio = [[SoundMaker alloc] init];
}

- (void)initSubviews
{
    
    // Gtar delegate and connection spoof
    NSLog(@"Setup and connect gTar");
    isConnected = NO;
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
    [guitarView observeGtar];
    
    string = 0;
    fret = 0;
    
    // Instrument table
    NSLog(@"Start to build instrument table");
    
    instrumentTableViewController = [[InstrumentTableViewController alloc] initWithNibName:@"InstrumentTableView" bundle:nil];
    [instrumentTableViewController.view setFrame:CGRectMake(0, 0, XBASE, 255)];
    [instrumentTableViewController setDelegate:self];
    
    if (selectedInstrumentIndex >= 0){
        Instrument * tempInst = [instruments objectAtIndex:selectedInstrumentIndex];
        guitarView.measure = tempInst.selectedPattern.selectedMeasure;
    }
    
    [self.view addSubview:instrumentTableViewController.view];
    
    // Tempo slider and play/pause
    NSLog(@"Start to build the bottom bar");
    playControlViewController = [[PlayControlViewController alloc] initWithNibName:@"BottomBar" bundle:nil];
    [playControlViewController.view setFrame:CGRectMake(0,251,XBASE,YBASE-252)];
    [playControlViewController setDelegate:self];
    isPlaying = NO;
    
    [self.view addSubview:playControlViewController.view];
    
}

- (void)saveContext
{
    NSLog(@"Perform context save");
}

- (void)updateGuitarView
{
    [guitarView update];
}

#pragma mark - Play Control Delegate
- (void)stopAllPlaying
{
    isPlaying = FALSE;
    [playTimer invalidate];
    playTimer = nil;
}

- (void)startAllPlaying:(float)secondsperbeat
{
    isPlaying = TRUE;
    secondsPerBeat = secondsperbeat;
    [self performSelectorInBackground:@selector(startBackgroundLoop) withObject:nil];
}

- (void)startBackgroundLoop
{
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    
    NSLog(@"Trying to init background loop with secondsPerBeat %f",secondsPerBeat);
    
    playTimer = [NSTimer scheduledTimerWithTimeInterval:secondsPerBeat target:self selector:@selector(mainEventLoop) userInfo:nil repeats:YES];
        
    [runLoop run];
}

- (void)mainEventLoop
{
    
    // Tell all of the sequencers to play their next fret
    
    // TODO: Compartmentalize?
    for (int i=0;i<[instruments count];i++){
         Instrument * instToPlay = [instruments objectAtIndex:i];
     
         @synchronized(instToPlay.selectedPattern){
             int realMeasure = [instToPlay.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
     
             // If we are back at the beginning of the pattern, then check the queue:
             if (realMeasure == 0 && currentFret == 0 && [patternQueue count] > 0){
                 [self checkQueueForPatternsFromInstrument:instToPlay];
             }
     
             [instToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!instToPlay.isMuted];
         }
     }
    
    [instrumentTableViewController updateAllVisibleCells];
     
    [guitarView update];
     
    [self increasePlayLocation];
    
    NSLog(@"Main event loop");
}

- (void)checkQueueForPatternsFromInstrument:(Instrument *)inst
{
    NSMutableArray * objectsToRemove = [NSMutableArray array];
   
    @synchronized(patternQueue)
    {
        // Pull out every pattern in the queue and select it
        for (NSDictionary * patternToSelect in patternQueue)
        {
            int nextPatternIndex = [[patternToSelect objectForKey:@"Index"] intValue];
            Instrument * nextPatternInstrument = [patternToSelect objectForKey:@"Instrument"];
            
            if (inst == nextPatternInstrument){
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

- (void)updateInstruments:(NSMutableArray *)instrumentlist setSelected:(int)index
{
    instruments = instrumentlist;
    selectedInstrumentIndex = index;
}

- (void)forceStopAll
{
    [playControlViewController stopAll];
}

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{
    if (!isConnected || fr == 0){
        return;
    }
    
    NSLog(@"trying selectedInstrumentIndex %i with Instrument Count %i",selectedInstrumentIndex,[instruments count]);
    
    if (selectedInstrumentIndex < 0 || [instruments count] == 0){
        NSLog(@"No instruments opened, or selected instrument index < 0");
        return;
    }
    
    NSLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];
    
    NSLog(@"notePlayedAtString");
}

- (void)notePlayed:(SEQNote *)note
{
    NSLog(@"gTarSeq received note played message string %i and fret %i",note.string,note.fret);
    
    // Pass note-played message onto the selected instrument
    Instrument * selectedInst = [instruments objectAtIndex:selectedInstrumentIndex];
    [selectedInst notePlayedAtString:note.string andFret:note.fret];
    
    [instrumentTableViewController updateAllVisibleCells];
    
    [guitarView update];
    
    [self saveContext];
}

- (void)guitarConnected
{
    NSLog(@"Guitar connected");
    
    isConnected = YES;
    
    [self updateConnectedImages];
}

- (void)guitarDisconnected
{
    NSLog(@"Guitar disconnected");
    
    isConnected = NO;
    
    [self updateConnectedImages];
}

- (void)updateConnectedImages
{
    NSLog(@"Update connected image");
    
    if (isConnected){
        [self.gTarLogoImageView setImage:[UIImage imageNamed: @"gTarConnectedLogo"]];
        [self.gTarConnectedText setText:@"Connected"];
    }else{
        [self.gTarLogoImageView setImage:[UIImage imageNamed: @"gTarNotConnectedLogo"]];
        [self.gTarConnectedText setText:@"Not Connected"];
    }
}


/* Ensures that the current playband is accurately reflected in
 the data, provided that there is a playband to display (ie >= 0).
 Only needs to be called when the number of measures changes. */
- (void)updatePlaybandForInstrument:(Instrument *)inst
{
    /*if (currentFret >= 0){
         int realMeasure = [inst.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
         [inst playFret:currentFret inRealMeasure:realMeasure withSound:NO];
    }*/
    
    NSLog(@"update playband...");
}


@end
