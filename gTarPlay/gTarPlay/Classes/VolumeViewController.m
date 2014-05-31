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
    
    //
    // Stylize the normal slider
    //
    UIImage * sliderTrackMinImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    UIImage * sliderTrackMaxImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
    UIImage * sliderKnob = [UIImage imageNamed:@"VolumeKnob.png"];
    
    [_volumeSlider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
    [_volumeSlider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
    [_volumeSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
    
    //
    // Set the MP volume view slider too
    //
    _mpVolumeView = [[MPVolumeView alloc] initWithFrame:_volumeView.bounds];
    
    NSArray * subViews = _mpVolumeView.subviews;
    
    UIImage *invisibleImage = [[UIImage imageNamed:@"InvisibleTrack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
    
    for (id current in subViews)
    {
        if ([current isKindOfClass:[UISlider class]])
        {
            UISlider * slider = (UISlider *)current;
            
            // I gave up trying to align the track on the volume slider properly. Now I'm just hiding it and doing it in the nib
            [slider setMinimumTrackImage:invisibleImage forState:UIControlStateNormal];
            [slider setMaximumTrackImage:invisibleImage forState:UIControlStateNormal];
            [slider setThumbImage:sliderKnob forState:UIControlStateNormal];
            
            // This is placed behind the MP volume slider
            _volumeTrackView.image = sliderTrackMaxImage;
            
            break;
        }
    }
    
    [_mpVolumeView setShowsRouteButton:NO];
    
    [_volumeView addSubview:_mpVolumeView];
    
    [self showVolumeSliderForRoute:nil];
    
}

-(void)invertVolumeView
{
    [_innerView setFrame:CGRectMake(_innerView.frame.origin.x,8,_innerView.frame.size.width,_innerView.frame.size.height)];
    
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
    
    _sliderView.center = CGPointMake( self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 );
    
    [_sliderView setBounds:newFrame];
    
    [_mpVolumeView setFrame:_volumeView.bounds];
    
    _mpVolumeView.center = CGPointMake( _volumeView.frame.size.width / 2.0, _volumeView.frame.size.height / 2.0 );
    
    if(invertView){
        [self invertVolumeView];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
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
}

// For the new audio controller always show the volume slider
- (void)showVolumeSliderForRoute:(NSString*)routeName
{
    //if ([routeName isEqualToString:(NSString*)kAudioSessionOutputRoute_LineOut])
    //{
        // show custom volume view
        [_volumeView setHidden:YES];
        [_volumeTrackView setHidden:YES];
        
        [_volumeSlider setHidden:NO];
    /*}
    else
    {
        // show standard MPVolumeView
        [_volumeView setHidden:NO];
        [_volumeTrackView setHidden:NO];
        
        [_volumeSlider setHidden:YES];
    }
    */
}

@end
