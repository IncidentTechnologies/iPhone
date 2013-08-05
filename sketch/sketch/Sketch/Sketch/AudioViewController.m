//
//  AudioViewController.m
//  Sketch
//
//  Created by Franco on 8/2/13.
//
//

#import "AudioViewController.h"
#import <AudioController/AudioController.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioViewController ()
{
    MPVolumeView* _mpVolumeView;
}

@property (weak, nonatomic) IBOutlet UIView *mpVolumeContainer;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIImageView *volumeTrackImage;
// Use a button instead of switch for this, because when customizing the
// look of a UISwitch we cannot get rid of the glare/glass effect.
// With a button we just switch between the two images we want.
@property (weak, nonatomic) IBOutlet UIButton *audioRouteSwitch;

@end

@implementation AudioViewController

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
	
    UIImage * sliderTrackMinImage = [UIImage imageNamed: @"SliderEndCap.png"];
    UIImage * sliderTrackMaxImage = [UIImage imageNamed: @"SliderEndCap.png"];
    UIImage * sliderKnob = [UIImage imageNamed:@"VolumeKnob.png"];
    
    sliderTrackMinImage = [sliderTrackMinImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 19) resizingMode:UIImageResizingModeStretch];
    sliderTrackMaxImage = [sliderTrackMinImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 19, 0, 18) resizingMode:UIImageResizingModeStretch];
    
    
    [_volumeSlider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
    [_volumeSlider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
    [_volumeSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
    
    // Set the MP volume view slider too
    _mpVolumeView = [[MPVolumeView alloc] initWithFrame:_mpVolumeContainer.bounds];
    
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
            _volumeTrackImage.image = sliderTrackMaxImage;
            
            break;
        }
    }
     
    
    [_mpVolumeView setShowsRouteButton:NO];
    [_mpVolumeContainer addSubview:_mpVolumeView];
    
    _volumeSlider.hidden = YES;
    
    [_audioRouteSwitch setImage:[UIImage imageNamed:@"Switch_Left.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [_audioRouteSwitch setImage:[UIImage imageNamed:@"Switch_Right.png"] forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioRoute:) name:@"AudioRouteChange" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
}

- (void)viewDidLayoutSubviews
{
    _mpVolumeView.frame = _mpVolumeContainer.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Slider methods
- (IBAction)volumeValueChanged:(id)sender
{
    // Change the volume of the audio controller
    [_audioController setM_volumeGain:_volumeSlider.value];
}

- (IBAction)changeAudioRoute:(UIButton*)button
{
    
    if (button.selected)
    {
        [_audioController RouteAudioToSpeaker];
    }
    else
    {
        [_audioController RouteAudioToDefault];
    }
    button.selected = !button.selected;
}

#pragma mark - callbacks & helpers

- (void)didChangeAudioRoute:(NSNotification *) notification
{
    NSDictionary *data = [notification userInfo];
    
    BOOL routeIsSpeaker = [[data objectForKey:@"isRouteSpeaker"] boolValue];
    [self setAudioSwitchForRoute:routeIsSpeaker];
    
    NSString * routeName = [data objectForKey:@"routeName"];
    [self showVolumeSliderForRoute:routeName];
}

- (void)setAudioSwitchForRoute:(BOOL)routeIsSpeaker
{
    if (routeIsSpeaker)
    {
        _audioRouteSwitch.selected = NO;
    }
    else
    {
        _audioRouteSwitch.selected = YES;
    }
}

// The global volume slider is not available when audio is routed to lineout.
// If the audio is not being outputed to lineout hide the global volume slider,
// and display our own slider that controlls volume in this mode.
- (void)showVolumeSliderForRoute:(NSString*)routeName
{
    if ([routeName isEqualToString:(NSString*)kAudioSessionOutputRoute_LineOut])
    {
        // show custom volume view
        [_mpVolumeContainer setHidden:YES];
        [_volumeTrackImage setHidden:YES];
        
        [_volumeSlider setHidden:NO];
    }
    else
    {
        // show standard MPVolumeView
        [_mpVolumeContainer setHidden:NO];
        [_volumeTrackImage setHidden:NO];
        
        [_volumeSlider setHidden:YES];
    }
}




@end
