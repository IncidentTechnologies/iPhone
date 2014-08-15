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
@synthesize recordButton;
@synthesize recordPlaybackButton;
@synthesize shareButton;
@synthesize disablePlay;
@synthesize disableShare;
@synthesize disableRecord;
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
    [tempoSlider setDelegate:self];
    
    // Set up volume display:
    [self initVolumeDisplay];
    
    // Play/Pause button
    [self drawPlayButton:startStopButton];
    [self drawPlayButton:recordPlaybackButton];
    [self drawRecordButton];
    
    // Hide share button
    [self setShareMode:NO];
    
    isPlaying = FALSE;
    isPlaybackPlaying = FALSE;
    
    [self hideSessionOverlay];
    [self hideRecordOverlay];
    
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

#pragma mark - Share Mode
-(void)setShareMode:(BOOL)share
{
    if(share){
        [shareButton setHidden:NO];
        [recordPlaybackButton setHidden:NO];
    }else{
        [shareButton setHidden:YES];
        [recordPlaybackButton setHidden:YES];
    }
}

#pragma mark - Allow Record
- (void)setLockRecord:(BOOL)lock
{
    if(lock){
        [self drawRecordButton];
        [recordButton setEnabled:NO];
        [recordButton setAlpha:0.5];
    }else{
        [recordButton setEnabled:YES];
        [recordButton setAlpha:1.0];
    }
}

#pragma mark - Tempo Slider Delegate

- (void)radialButtonValueDidChange:(int)newValue withSave:(BOOL)save
{
    if (tempo != newValue)
    {
        tempo = newValue;
        if(isRecording){
            
            [self stopPlayRecordAndAnimate:YES showEndScreen:YES];
            
        }else if(isPlaying){
            
            [self endPlaySession];
            [self beginPlaySession];
        }
        
        [delegate updateTempo:newValue];
        
        if(save){
            [delegate saveContext:nil force:NO];
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
    //DLog(@"**** tempo display did open");
    isTempoSliderOpen = true;
    [delegate stopGestures];
    [delegate stopDrawing];
}

- (void) tempoDisplayDidClose
{
    //DLog(@"**** tempo display did close");
    isTempoSliderOpen = false;
    [delegate startGestures];
    [delegate startDrawing];
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
        [delegate saveContext:nil force:NO];
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
    //[delegate stopDrawing];
}

- (void) volumeDisplayDidClose
{
    isVolumeSliderOpen = false;
    [delegate startGestures];
    //[delegate startDrawing];
    [delegate refreshVolumeSliders];
}

- (void) openInstrument:(int)instIndex
{
    [self volumeDisplayDidClose];
    [delegate openInstrument:instIndex];
}

- (void) commitMasterLevelSlider:(UILevelSlider *)masterSlider
{
    [delegate commitMasterLevelSlider:masterSlider];
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
    DLog(@"Toggle volume open");
    
    if(isVolumeSliderOpen){
        [volumeDisplay contract];
        [self volumeDisplayDidClose];
    }else if([self allowVolumeDisplayToOpen]){
        [volumeDisplay expand];
        [self volumeDisplayDidOpen];
    }
}

- (void)enableInstrument:(int)instIndex
{
    [delegate enableInstrument:instIndex];
}

- (void)disableInstrument:(int)instIndex
{
    [delegate disableInstrument:instIndex];
}

#pragma mark - Playing/Pausing

- (IBAction)startStop:(id)sender
{
    DLog(@"Start stop, %i",isRecording);
    
    if(isRecording){
        [self stopRecordingAndAnimate:YES showEndScreen:YES];
    }else{
        if (isPlaying){
            [self stopAll];
        }else{
            [delegate endTutorialIfOpen];
            [delegate initPlayLocation];
            [self playAll];
        }
    }
}

- (void)stopAll
{
    [self clearButton:startStopButton];
    [self drawPlayButton:startStopButton];
    [self endPlaySession];
}

- (void)stopPlayRecordAndAnimate:(BOOL)animate showEndScreen:(BOOL)showEndScreen;
{
    if(isRecording){
        [self stopRecordingAndAnimate:animate showEndScreen:showEndScreen];
    }else{
        [self stopAll];
    }
    
    if(isPlaybackPlaying){
        [self startStopRecordPlayback:self];
    }
}

- (void)playAll
{
    [self clearButton:startStopButton];
    [self drawPauseButton:startStopButton];
    [self beginPlaySession];
}

- (void)beginPlaySession
{
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Compute seconds per beat from tempo:
    double beatsPerSecond = tempo/SECONDS_PER_MIN;
    beatsPerSecond*=4;
    secondsPerBeat = 1/beatsPerSecond;
    
    [delegate startAllPlaying:secondsPerBeat withAmplitude:volume];
    
    isPlaying = YES;
}

- (void)endPlaySession
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [delegate stopAllPlaying];
    
    isPlaying = NO;
}

- (void)clearButton:(UIButton *)button
{
    NSArray *viewsToRemove = [button subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

#pragma mark - Record Playback
-(IBAction)startStopRecordPlayback:(id)sender
{
    if(isPlaybackPlaying){
        
        [self clearButton:recordPlaybackButton];
        [self drawPlayButton:recordPlaybackButton];
        
        [delegate pauseRecordPlayback];
        isPlaybackPlaying = NO;
        
    }else{
        
        [self clearButton:recordPlaybackButton];
        [self drawPauseButton:recordPlaybackButton];
        
        [delegate playRecordPlayback];
        isPlaybackPlaying = YES;
    }
}

-(void)pauseRecordPlayback
{
    isPlaybackPlaying = NO;
    
    [self clearButton:recordPlaybackButton];
    [self drawPlayButton:recordPlaybackButton];
}

#pragma mark - Record Session

-(IBAction)recordSession:(id)sender
{
    
    if(isPlaying && !isRecording){
        [self stopAll];
    }else{
        if(isRecording){
            [self stopRecordingAndAnimate:YES showEndScreen:YES];
        }else{
            [self startRecording];
        }
    }
    
}

-(void)startRecording
{
    isRecording = TRUE;
    
    if(isPlaying){
        [self endPlaySession];
    }
    
    [delegate setRecordMode:isRecording andAnimate:NO];
    [delegate resetPlayLocation];
    [delegate initPlayLocation];
    [self beginPlaySession];
    [self drawStopButton];
}

-(void)stopRecordingAndAnimate:(BOOL)animate showEndScreen:(BOOL)showEndScreen
{
    isRecording = FALSE;
    
    [self endPlaySession];
    if(showEndScreen){
        [delegate setRecordMode:isRecording andAnimate:animate];
    }
    [self drawRecordButton];
}


#pragma mark - Save / Load

- (IBAction)userDidLoadOptions:(id)sender
{
    [delegate userDidLoadSequenceOptions];
}

#pragma mark - Drawing

- (void)drawPlayButton:(UIButton *)button
{
    
    [button setBackgroundColor:[UIColor colorWithRed:105/255.0 green:214/255.0 blue:90/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(button.frame.size.width, button.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 20;
    int playX = button.frame.size.width/2 - playWidth/2;
    int playY = 15;
    CGFloat playHeight = button.frame.size.height - 2*playY;
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
    
    [button addSubview:image];
    
    UIGraphicsEndImageContext();
}

- (void)drawPauseButton:(UIButton *)button
{
    
    [button setBackgroundColor:[UIColor colorWithRed:244/255.0 green:151/255.0 blue:39/255.0 alpha:1]];
    
    CGSize size = CGSizeMake(button.frame.size.width, startStopButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int pauseWidth = 8;
    
    CGFloat pauseHeight = button.frame.size.height - 30;
    CGRect pauseFrameLeft = CGRectMake(button.frame.size.width/2 - pauseWidth - 2, 15, pauseWidth, pauseHeight);
    CGRect pauseFrameRight = CGRectMake(pauseFrameLeft.origin.x+pauseWidth+3, 15, pauseWidth, pauseHeight);
    
    CGContextAddRect(context,pauseFrameLeft);
    CGContextAddRect(context,pauseFrameRight);
    CGContextSetFillColorWithColor(context,[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor);
    CGContextFillRect(context,pauseFrameLeft);
    CGContextFillRect(context,pauseFrameRight);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [button addSubview:image];
    
    UIGraphicsEndImageContext();
}

- (void)drawRecordButton
{
    for(UIView * v in recordButton.subviews){
        [v removeFromSuperview];
    }
    
    [recordButton setBackgroundColor:[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0]];
    
    float circleWidth = 20;
    UIButton * recordButtonCircle = [[UIButton alloc] initWithFrame:CGRectMake(recordButton.frame.size.width/2-circleWidth/2,recordButton.frame.size.height/2-circleWidth/2,circleWidth,circleWidth)];
    
    recordButtonCircle.layer.cornerRadius = circleWidth/2;
    [recordButtonCircle setBackgroundColor:[UIColor colorWithRed:216/266.0 green:64/255.0 blue:64/255.0 alpha:1.0]];
    [recordButtonCircle setAlpha:1.0];
    
    [recordButtonCircle addTarget:self action:@selector(recordSession:) forControlEvents:UIControlEventTouchUpInside];
    
    [recordButton addSubview:recordButtonCircle];
}

- (void)drawStopButton
{
    for(UIView * v in recordButton.subviews){
        [v removeFromSuperview];
    }
    
    [recordButton setBackgroundColor:[UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0]];
    
    float squareWidth = 20;
    UIButton * recordButtonSquare = [[UIButton alloc] initWithFrame:CGRectMake(recordButton.frame.size.width/2-squareWidth/2,recordButton.frame.size.height/2-squareWidth/2,squareWidth,squareWidth)];
    
    [recordButtonSquare setBackgroundColor:[UIColor whiteColor]];
    [recordButtonSquare setAlpha:0.7];
    
    [recordButtonSquare addTarget:self action:@selector(recordSession:) forControlEvents:UIControlEventTouchUpInside];
    
    [recordButton addSubview:recordButtonSquare];
}

-(NSMutableArray *)getTracks
{
    return [delegate getTracks];
}

#pragma mark - Record Session Overlays
-(void)showSessionOverlay
{
    [disablePlay setHidden:NO];
    [disableShare setHidden:NO];
}

-(void)hideSessionOverlay
{
    [disablePlay setHidden:YES];
    [disableShare setHidden:YES];
}

-(void)showRecordOverlay
{
    [disableRecord setHidden:NO];
}

-(void)hideRecordOverlay
{
    [disableRecord setHidden:YES];
}

-(IBAction)userDidSelectShare:(id)sender
{
    [delegate userDidSelectShare];
}
@end
