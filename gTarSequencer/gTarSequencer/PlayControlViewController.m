//
//  PlayControlViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 1/2/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "PlayControlViewController.h"

#define DEFAULT_TEMPO 120
#define SECONDS_PER_MIN 60.0

@implementation PlayControlViewController

@synthesize tempoSlider;
@synthesize startStopButton;
@synthesize delegate;
@synthesize playNotesButton;

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
    
    // Play notes button
    // [playNotesButton setTitle:@"N" forState:UIControlStateNormal];
    
    // Tempo slider stuff
    NSLog(@"Setup tempo slider");
    tempo = DEFAULT_TEMPO;
    [tempoSlider setToValue:tempo];
    [tempoSlider setDelegate:self];
    
    startStopButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    isPlaying = FALSE;
    
}

- (void)viewDidUnload
{
    [self setStartStopButton:nil];
    [self setTempoSlider:nil];
    [self setPlayNotesButton:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tempo Slider Delegate

- (void)radialButtonValueDidChange:(int)newValue
{
    if (tempo != newValue)
    {
        tempo = newValue;
        if (isPlaying)
        {
            [self stopAll];
            [self playAll];
        }
    }
    
    [delegate saveContext];
}

#pragma mark - Playing/Pausing

- (IBAction)startStop:(id)sender
{
    if (isPlaying){
        [self stopAll];
    }else{
        [delegate initPlayLocation];
        [self playAll];
    }
}

- (void)stopAll
{
    
    NSLog(@"stop all");
    [startStopButton setTitle:@"PLAY" forState:UIControlStateNormal];
    startStopButton.selected = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [delegate stopAllPlaying];
    
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
    
    [delegate startAllPlaying:secondsPerBeat];
    
    isPlaying = YES;
    
}

// TEST
- (IBAction)playSomeNotes:(id)sender
{
    NSLog(@"Play some notes!");
    
    //[guitarView turnOffEffects];
    
    //[delegate notePlayedAtString:5 andFret:3];
    
}


@end
