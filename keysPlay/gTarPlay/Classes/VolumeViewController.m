//
//  VolumeViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/3/13.
//
//

#import "VolumeViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

//extern AudioController * g_audioController;

@interface VolumeViewController ()
{
    BOOL invertView;
    MPVolumeView *_mpVolumeView;
    SoundMaster *g_soundMaster;
}

@end

@implementation VolumeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSoundMaster:(SoundMaster *)soundMaster isInverse:(BOOL)invert;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioRoute:) name:@"AudioRouteChange" object:nil];
        
        invertView = invert;
        [super invertView:invert];
        
        g_soundMaster = soundMaster;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self drawTrack];
    [self drawSliderKnob];
    
}

- (void)drawTrack
{
    // Slider Knob
    CGSize size = CGSizeMake(1,6);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:24/255.0 green:29/255.0 blue:33/255.0 alpha:1.0].CGColor);
    
    CGContextFillRect(context, CGRectMake(0,0,size.width,size.height));
    
    UIImage * maxSliderKnob = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Min slider knob
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:166/255.0 green:203/255.0 blue:116/255.0 alpha:1.0].CGColor);
    
    CGContextFillRect(context, CGRectMake(0,0,size.width,size.height));
    
    UIImage * minSliderKnob = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [_volumeSlider setMaximumTrackImage:maxSliderKnob forState:UIControlStateNormal];
    [_volumeSlider setMinimumTrackImage:minSliderKnob forState:UIControlStateNormal];
}

- (void)drawSliderKnob
{
    // Slider Knob
    CGSize size = CGSizeMake(25,25);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:166/255.0 green:203/255.0 blue:116/255.0 alpha:1.0].CGColor);
    
    CGContextFillEllipseInRect(context, CGRectMake(0,0,size.width,size.height));
    
    UIImage * sliderKnob = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [_volumeSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
}

-(void)invertVolumeView
{
    [_innerView setFrame:CGRectMake(_innerView.frame.origin.x,8,_innerView.frame.size.width,_innerView.frame.size.height)];
    
    [_outputToggleButton setFrame:CGRectMake(_innerView.frame.size.width/2.0-_outputToggleButton.frame.size.width/2.0,5,_outputToggleButton.frame.size.width,_outputToggleButton.frame.size.height)];
    
    [_sliderView setFrame:CGRectMake(_sliderView.frame.origin.x,self.view.frame.size.height-_sliderView.frame.size.height,_sliderView.frame.size.width,_sliderView.frame.size.height)];
    
    [super invertTriangleIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    // Center the volume view and expand the width to match the height.
    // (After rotating, width->height)
    CGRect newFrame = _sliderView.bounds;
    
    newFrame.size.width = self.view.frame.size.height - 55;
    
    _sliderView.center = CGPointMake( self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 - 14.0 );
    
    [_sliderView setBounds:newFrame];
    
    [_mpVolumeView setFrame:_volumeView.bounds];
    
    _mpVolumeView.center = CGPointMake( _volumeView.frame.size.width / 2.0, _volumeView.frame.size.height / 2.0 );
    
    [_outputToggleButton setFrame:CGRectMake(_innerView.frame.size.width/2.0-_outputToggleButton.frame.size.width/2.0,self.view.frame.size.height-10-_outputToggleButton.frame.size.height,_outputToggleButton.frame.size.width,_outputToggleButton.frame.size.height)];
    
    if(invertView){
        [self invertVolumeView];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [self showOutputToggleButton];
    [_volumeSlider setValue:[g_soundMaster getChannelGain]];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
}

#pragma mark - Slider methods

- (IBAction)volumeValueChanged:(id)sender
{
    [g_soundMaster setChannelGain:_volumeSlider.value];
}

- (IBAction)outputToggleButtonClicked:(id)sender
{
    // Determine current routing
    NSString * audioRoute = [g_soundMaster getAudioRoute];
    BOOL _speakerRoute = ([audioRoute isEqualToString:@"Speaker"]) ? YES : NO;
    
    if ( _speakerRoute == NO)
    {
        [g_soundMaster routeToSpeaker];
    }
    else
    {
        [g_soundMaster routeToDefault];
    }
    
    //[self showOutputToggleButton];
}

- (void)showOutputToggleButton
{
    // Determine current routing
    NSString * audioRoute = [g_soundMaster getAudioRoute];
    BOOL _speakerRoute = ([audioRoute isEqualToString:@"Speaker"]) ? YES : NO;
    
    if ( _speakerRoute == NO)
    {
        [_outputToggleButton setImage:[UIImage imageNamed:@"SpeakerIcon"] forState:UIControlStateNormal];
        [_outputToggleButton setImageEdgeInsets:UIEdgeInsetsMake(11, 8, 11, 8)];
    }else{
        [_outputToggleButton setImage:[UIImage imageNamed:@"AuxIcon"] forState:UIControlStateNormal];
        [_outputToggleButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    }
}

- (void)attachToSuperview:(UIView *)view
{
    [self attachToSuperview:view withFrame:view.bounds];
}

- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect
{
    [super attachToSuperview:view withFrame:rect];
    
    _sliderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

- (void)didChangeAudioRoute:(NSNotification *) notification
{
    NSString * routeName = [[notification userInfo] objectForKey:@"routeName"];
    [self showVolumeSliderForRoute:routeName];
    [self showOutputToggleButton];
}

// For the new audio controller always show the volume slider
- (void)showVolumeSliderForRoute:(NSString*)routeName
{
    [_volumeView setHidden:YES];
    [_volumeTrackView setHidden:YES];
    
    [_volumeSlider setHidden:NO];
}

@end
