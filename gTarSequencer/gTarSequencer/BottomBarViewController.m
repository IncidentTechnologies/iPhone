//
//  RadialViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "BottomBarViewController.h"

#define DEFAULT_TEMPO 120
#define SECONDS_PER_MIN 60.0

@implementation BottomBarViewController

@synthesize tempoSlider;
@synthesize startStopButton;


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
    
    // Tempo slider stuff
    NSLog(@"Setup tempo slider");
    tempo = DEFAULT_TEMPO;
    [tempoSlider setToValue:tempo];
    [tempoSlider setDelegate:self];
    
    startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
    
}

- (void)viewDidUnload
{
    [self setStartStopButton:nil];
    [self setTempoSlider:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // call this code somewhere compartmentalized:
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


@end
