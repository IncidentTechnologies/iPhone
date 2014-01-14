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
    
    // Play button
    [self drawPlayButton];
    
    // Tempo slider stuff
    NSLog(@"Setup tempo slider");
    tempo = DEFAULT_TEMPO;
    [tempoSlider setToValue:tempo];
    [tempoSlider setDelegate:self];
    
    [startStopButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:148/255.0 blue:29/255.0 alpha:1]];
    startStopButton.layer.cornerRadius = 5.0;
    
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
    
    [delegate startAllPlaying:secondsPerBeat];
    
    isPlaying = YES;
    
}

- (void)clearButton:(UIButton *)button
{
    
    NSArray *viewsToRemove = [button subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)drawPlayButton
{
    
    
    CGSize size = CGSizeMake(startStopButton.frame.size.width, startStopButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 15;
    int playX = startStopButton.frame.size.width/2 - playWidth/2;
    int playY = 10;
    CGFloat playHeight = startStopButton.frame.size.height - 20;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
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
    CGSize size = CGSizeMake(startStopButton.frame.size.width, startStopButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int pauseWidth = 5;
    
    CGFloat pauseHeight = startStopButton.frame.size.height - 20;
    CGRect pauseFrameLeft = CGRectMake(startStopButton.frame.size.width/2 - pauseWidth - 2, 10, pauseWidth, pauseHeight);
    CGRect pauseFrameRight = CGRectMake(pauseFrameLeft.origin.x+pauseWidth+3, 10, pauseWidth, pauseHeight);
    
    CGContextAddRect(context,pauseFrameLeft);
    CGContextAddRect(context,pauseFrameRight);
    CGContextSetFillColorWithColor(context,[UIColor whiteColor].CGColor);
    CGContextFillRect(context,pauseFrameLeft);
    CGContextFillRect(context,pauseFrameRight);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [startStopButton addSubview:image];
    
    UIGraphicsEndImageContext();
}


@end
