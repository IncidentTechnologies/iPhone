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
    MPVolumeView *_mpVolumeView;
}

@end

@implementation VolumeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioRoute:) name:@"AudioRouteChange" object:nil];
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
    
    // This is the non-deprecated way of doing it
//    sliderTrackMinImage = [sliderTrackMinImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 17) resizingMode:UIImageResizingModeStretch];
//    sliderTrackMaxImage = [sliderTrackMinImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17, 0, 16) resizingMode:UIImageResizingModeStretch];
    
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
    
    //NSString * routeName = (NSString *)[g_audioController GetAudioRoute];
    //[self showVolumeSliderForRoute:routeName];
    
    NSLog(@"TODO: show volume slider for audio route");
    
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
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
    [_mpVolumeView release];
    [_sliderView release];
    [_volumeSlider release];
    [_volumeView release];
    [_volumeTrackView release];
    [super dealloc];
}

#pragma mark - Slider methods

- (IBAction)volumeValueChanged:(id)sender
{
    // Change the volume of the audio controller
    //[g_audioController setM_volumeGain:_volumeSlider.value];
    
    NSLog(@"TODO: change the volume of the audio controller");
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

// The global volume slider is not available when audio is routed to lineout.
// If the audio is not being outputed to lineout hide the global volume slider,
// and display our own slider that controlls volume in this mode.
- (void)showVolumeSliderForRoute:(NSString*)routeName
{
    if ([routeName isEqualToString:(NSString*)kAudioSessionOutputRoute_LineOut])
    {
        // show custom volume view
        [_volumeView setHidden:YES];
        [_volumeTrackView setHidden:YES];
        
        [_volumeSlider setHidden:NO];
    }
    else
    {
        // show standard MPVolumeView
        [_volumeView setHidden:NO];
        [_volumeTrackView setHidden:NO];
        
        [_volumeSlider setHidden:YES];
    }
}

@end
