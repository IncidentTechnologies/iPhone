//
//  SequencerViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SequencerViewController.h"

#define DEFAULT_TEMPO 120
#define MAX_SEQUENCES 15
#define LAST_FRET 15
#define LAST_MEASURE 3
#define SECONDS_PER_MIN 60.0

@implementation SequencerViewController

@synthesize instrumentTableViewController;
@synthesize startStopButton;
@synthesize gTarLogoImageView;
@synthesize gTarConnectedText;
@synthesize tempoSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setTempoSlider:nil];
    [self setStartStopButton:nil];
    //[self setPlayNotesButton:nil];
    
    // Release any retained subviews of the main view
    self.instrumentTableViewController = nil;
    
}


- (void)initSubviews
{
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    // Gtar delegate and connection spoof
    NSLog(@"Setup and connect gTar");
    isConnected = NO;
    isPlaying = NO;
    tempo = DEFAULT_TEMPO;
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
   /* if ( selectedInstrumentIndex >= 0 )
    {
        Instrument * tempInst = [instruments objectAtIndex:selectedInstrumentIndex];
        guitarView.measure = tempInst.selectedPattern.selectedMeasure;
    } */
    [guitarView observeGtar];
    
    string = 0;
    fret = 0;
    
    // Tempo slider stuff
    [tempoSlider setToValue:tempo];
    [tempoSlider setDelegate:self];
    
    // Instrument table
    NSLog(@"Start to build instrument table");
    
    instrumentTableViewController = [[InstrumentTableViewController alloc] initWithNibName:@"InstrumentTableView" bundle:nil];
    
    [instrumentTableViewController.view setFrame:CGRectMake(0, 0, x, 3*y/4)];
    
    [self.view addSubview:instrumentTableViewController.view];
    
}


#pragma mark - Playing/Pausing

- (IBAction)startStop:(id)sender
{
    
    NSLog(@"Start stop!");
    
    if ( isPlaying )
    {
        [self stopAll];
    }
    else {
       // if ( currentFret == -1 )
        //{
        //    [self increasePlayLocation];
        //}
        
        [self playAll];
    }
}

- (void)stopAll
{
    
    NSLog(@"stop all");
    [startStopButton setTitle:@"PLAY" forState:UIControlStateNormal];
    startStopButton.selected = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [playTimer invalidate];
    playTimer = nil;
    isPlaying = NO;
}

- (void)playAll
{
    
    NSLog(@"play all");
    [startStopButton setTitle:@"PAUSE" forState:UIControlStateSelected];
    startStopButton.selected = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Compute seconds per beat from tempo:
    double beatsPerSecond = tempo/SECONDS_PER_MIN;
    beatsPerSecond*=4;
    secondsPerBeat = 1/beatsPerSecond;
    
    NSLog(@"Seconds per beat: %f", secondsPerBeat);
    
    isPlaying = YES;
    
    [self performSelectorInBackground:@selector(startBackgroundLoop) withObject:nil];
}

- (void)startBackgroundLoop
{
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    
    playTimer = [NSTimer scheduledTimerWithTimeInterval:secondsPerBeat target:self selector:@selector(mainEventLoop) userInfo:nil repeats:YES];
    
    [runLoop run];
}

- (void)mainEventLoop
{
    // Tell all of the sequencers to play their next fret
   /* for (int i=0;i<[instruments count];i++)
    {
        Instrument * instToPlay = [instruments objectAtIndex:i];
        
        @synchronized(instToPlay.selectedPattern)
        {
            int realMeasure = [instToPlay.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
            
            // If we are back at the beginning of the pattern, then check the queue:
            if ( realMeasure == 0 && currentFret == 0 && [patternQueue count] > 0)
            {
                [self checkQueueForPatternsFromInstrument:instToPlay];
            }
            
            [instToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!instToPlay.isMuted];
        }
    }
    
    [self updateAllVisibleCells];
    
    [guitarView update];
    
    [self increasePlayLocation];*/
    
    NSLog(@"Main event loop");
}


#pragma mark - Tempo Slider Delegate

- (void)radialButtonValueDidChange:(int)newValue
{
    if ( tempo != newValue )
    {
        tempo = newValue;
        if ( isPlaying )
        {
            [self stopAll];
            [self playAll];
        }
    }
    
    // [self save];
}


// checkQueueForPatternsFromInstrument
// updateAllVisibleCells
// increasePlayLocation
// resetPlaySpot
// muteInstrument
// unmuteInstrument

// userDidSelectPattern
// commitSelectingPatternAtIndex
// userDidSelectMeasure
// userDidAddMeasures
// userDidRemoveMeasures
// updatePlaybandForInstrument

// addNewInstrumentWithIndex
// turnOffGuitarEffects
// retrieveInstrumentOptions
// loadInstrumentSelector
// closeInstrumentSelector
// hideInstrumentSelector

// scrollingSelectorUserDidSelectIndex

// selectInstrument
// playSomeNotes

// deleteCell
// removeSequencerWithIndex

// addInstrumentBackIntoOptions
// ...

// notePlayedAtString
// notePlayed
// guitarConnected
// guitarDisconnected
// updateConnectedImages

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{
  /*  if ( !isConnected || fr == 0 )
    {
        return;
    }
    
    if ( selectedInstrumentIndex < 0 || [instruments count] == 0 )
    {
        NSLog(@"No instruments opened, or selected instrument index < 0");
        return;
    }
    NSLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];*/
    
    NSLog(@"notePlayedAtString");
}

/*- (void)notePlayed:(SEQNote *)note
{
    NSLog(@"gTarSeq received note played message");
    
    // Pass note-played message onto the selected instrument
    Instrument * selectedInst = [instruments objectAtIndex:selectedInstrumentIndex];
    [selectedInst notePlayedAtString:note.string andFret:note.fret];
    
    [self updateAllVisibleCells];
    
    [guitarView update];
    
    [self save];
}*/

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
    if ( isConnected )
    {
        NSLog(@"update images connected");
        
        [self.gTarLogoImageView setImage:[UIImage imageNamed: @"gTarConnectedLogo"]];
        
        [self.gTarConnectedText setText:@"Connected"];
        
    }
    else {
        
        NSLog(@"update images not connected");
        
        [self.gTarLogoImageView setImage:[UIImage imageNamed: @"gTarNotConnectedLogo"]];
        
        [self.gTarConnectedText setText:@"Not Connected"];
    }
    
}


@end
