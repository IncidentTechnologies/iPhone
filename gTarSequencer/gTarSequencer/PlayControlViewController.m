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
@synthesize volumeButton;
@synthesize startStopButton;
@synthesize delegate;

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
    
    // Tempo slider
    if(TESTMODE) NSLog(@"Setup tempo slider");
    [tempoSlider setDelegate:self];
    
    // Set up volume display:
    [self initVolumeDisplay];
    
    // Play/Pause button
    if(TESTMODE) NSLog(@"Draw Play Pause button");
    [self drawPlayButton];
    
    isPlaying = FALSE;
    
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

- (void)radialButtonValueDidChange:(int)newValue withSave:(BOOL)save
{
    if (tempo != newValue)
    {
        tempo = newValue;
        if (isPlaying)
        {
            [self stopAll];
            [self playAll];
        }
        
        if(save){
            [delegate saveContext:nil];
        }
    }
}

- (BOOL) allowTempoDisplayToOpen
{
    if(isVolumeSliderOpen){
        [volumeDisplay contract];
        [self volumeDisplayDidClose];
    }
    return TRUE;
    //return !isVolumeSliderOpen;
}

- (void) tempoDisplayDidOpen
{
    isTempoSliderOpen = true;
    [delegate stopGestures];
}

- (void) tempoDisplayDidClose
{
    isTempoSliderOpen = false;
    [delegate startGestures];
}

#pragma mark - Tempo Interface

- (int)getTempo
{
    return tempo;
}

- (void)resetTempo
{
    tempo = DEFAULT_TEMPO;
    [tempoSlider setToValue:tempo];
}

- (void)setTempo:(int)newTempo
{
    tempo = newTempo;
    [tempoSlider setToValue:tempo];
}

#pragma mark - Volume Slider Delegate
- (void)initVolumeDisplay
{
    int bottomBarHeight = 55;
    CGRect wholeScreen = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, YBASE-bottomBarHeight-1);
    
    volumeDisplay = [[VolumeDisplay alloc] initWithFrame:wholeScreen];
    volumeDisplay.userInteractionEnabled = YES;
    volumeDisplay.alpha = NOT_VISIBLE;
    volumeDisplay.delegate = self;
    
    // overlay by adding to the main view
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:volumeDisplay];
}

- (void)volumeButtonValueDidChange:(double)newValue withSave:(BOOL)save
{
    if(volume != newValue)
    {
        volume = newValue;
        
        [delegate changePlayVolume:volume];
       
        //if(isPlaying)
        //{
            //[self stopAll];
            //[self playAll];
        //}
    }
    
    if(save){
        [delegate saveContext:nil];
    }
}

- (BOOL) allowVolumeDisplayToOpen
{
    return !isTempoSliderOpen;
}

- (void) volumeDisplayDidOpen
{
    isVolumeSliderOpen = true;
    [delegate stopGestures];
}

- (void) volumeDisplayDidClose
{
    isVolumeSliderOpen = false;
    [delegate startGestures];
    [delegate refreshVolumeSliders];
}

#pragma mark - Volume Slider Interface
- (double)getVolume
{
    return volume;
}

- (void)resetVolume
{
    volume = DEFAULT_VOLUME;
    [volumeDisplay setVolume:volume];
}

- (void)setVolume:(double)newVolume
{
    volume = newVolume;
    [volumeDisplay setVolume:volume];
}

- (IBAction)toggleVolumeOpen:(id)sender
{
    NSLog(@"Toggle volume open");
    
    if(isVolumeSliderOpen){
        [volumeDisplay contract];
        [self volumeDisplayDidClose];
    }else if([self allowVolumeDisplayToOpen]){
        [volumeDisplay expand];
        [self volumeDisplayDidOpen];
    }
}

#pragma mark - Playing/Pausing

- (IBAction)startStop:(id)sender
{
    if (isPlaying){
        [self stopAll];
    }else{
        [delegate endTutorialIfOpen];
        [delegate initPlayLocation];
        [self playAll];
    }
}

- (void)stopAll
{
    [self clearButton:startStopButton];
    [self drawPlayButton];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [delegate stopAllPlaying];
    
    isPlaying = NO;
}

- (void)playAll
{
    [self clearButton:startStopButton];
    [self drawPauseButton];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Compute seconds per beat from tempo:
    double beatsPerSecond = tempo/SECONDS_PER_MIN;
    beatsPerSecond*=4;
    secondsPerBeat = 1/beatsPerSecond;
    
    [delegate startAllPlaying:secondsPerBeat withAmplitude:volume];
    
    isPlaying = YES;
    
}

- (void)clearButton:(UIButton *)button
{
    
    NSArray *viewsToRemove = [button subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

#pragma mark - Save / Load

- (IBAction)userDidLoadOptions:(id)sender
{
    [delegate userDidLoadSequenceOptions];
}

#pragma mark - Drawing

- (void)drawPlayButton
{
    
    [startStopButton setBackgroundColor:[UIColor colorWithRed:105/255.0 green:214/255.0 blue:90/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(startStopButton.frame.size.width, startStopButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 20;
    int playX = startStopButton.frame.size.width/2 - playWidth/2;
    int playY = 15;
    CGFloat playHeight = startStopButton.frame.size.height - 2*playY;
    UIColor * transparentWhite = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
    
    CGContextSetStrokeColorWithColor(context, transparentWhite.CGColor);
    CGContextSetFillColorWithColor(context, transparentWhite.CGColor);
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextMoveToPoint(context, playX, playY);
    CGContextAddLineToPoint(context, playX, playY+playHeight);
    CGContextAddLineToPoint(context, playX+playWidth, playY+(playHeight/2));
    CGContextClosePath(context);
    
    CGContextFillPath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [startStopButton addSubview:image];
    
    UIGraphicsEndImageContext();
}

- (void)drawPauseButton
{
    
    [startStopButton setBackgroundColor:[UIColor colorWithRed:244/255.0 green:151/255.0 blue:39/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(startStopButton.frame.size.width, startStopButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int pauseWidth = 8;
    
    CGFloat pauseHeight = startStopButton.frame.size.height - 30;
    CGRect pauseFrameLeft = CGRectMake(startStopButton.frame.size.width/2 - pauseWidth - 2, 15, pauseWidth, pauseHeight);
    CGRect pauseFrameRight = CGRectMake(pauseFrameLeft.origin.x+pauseWidth+3, 15, pauseWidth, pauseHeight);
    
    CGContextAddRect(context,pauseFrameLeft);
    CGContextAddRect(context,pauseFrameRight);
    CGContextSetFillColorWithColor(context,[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor);
    CGContextFillRect(context,pauseFrameLeft);
    CGContextFillRect(context,pauseFrameRight);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [startStopButton addSubview:image];
    
    UIGraphicsEndImageContext();
}

-(NSMutableArray *)getInstruments
{
    return [delegate getInstruments];
}

@end
