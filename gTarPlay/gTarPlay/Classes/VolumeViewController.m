//
//  VolumeViewController.m
//  gTarPlay
//
//  Created by Marty Greenia on 4/3/13.
//
//

#import "VolumeViewController.h"

#import <AudioController/AudioController.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

extern AudioController * g_audioController;

@interface VolumeViewController ()
{
    BOOL _isDown;
    BOOL _isSliding;
    MPVolumeView *_mpVolumeView;
}

@end

@implementation VolumeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self )
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
//    self.view.clipsToBounds = YES;
    
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
    
    // First resize the images to work around a 'bug' (?)
    sliderTrackMinImage = [sliderTrackMinImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 17) resizingMode:UIImageResizingModeStretch];
    sliderTrackMaxImage = [sliderTrackMinImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17, 0, 16) resizingMode:UIImageResizingModeStretch];
//    sliderKnob = [sliderKnob resizableImageWithCapInsets:UIEdgeInsetsMake(-10, 0, 10, 0)];
    
    _mpVolumeView = [[MPVolumeView alloc] initWithFrame:_volumeView.bounds];
    
    NSArray * subViews = _mpVolumeView.subviews;
    
    UIImage *invisibleImage = [[UIImage imageNamed:@"InvisibleTrack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
    
    for (id current in subViews)
    {
        if ([current isKindOfClass:[UISlider class]])
        {
            UISlider * slider = (UISlider *)current;
            
            [slider setMinimumTrackImage:invisibleImage forState:UIControlStateNormal];
            [slider setMaximumTrackImage:invisibleImage forState:UIControlStateNormal];
            [slider setThumbImage:sliderKnob forState:UIControlStateNormal];
//            [slider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
//            [slider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
        }
    }
    
    [_mpVolumeView setShowsRouteButton:NO];
    
    [_volumeView addSubview:_mpVolumeView];
    
    _volumeTrackView.image = sliderTrackMaxImage;
    
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
    
    newFrame.size.width = self.view.frame.size.height - 75;
    
    _sliderView.center = CGPointMake( self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0 );
    
    [_sliderView setBounds:newFrame];
    
    [_mpVolumeView setFrame:_volumeView.bounds];
    
    _mpVolumeView.center = CGPointMake( _volumeView.frame.size.width / 2.0, _volumeView.frame.size.height / 2.0 );
    
}

#pragma mark - Slider methods

- (IBAction)volumeValueChanged:(id)sender
{
    // Change the volume of the audio controller
    [g_audioController setM_volumeGain:_volumeSlider.value];
}

- (void)attachToSuperview:(UIView *)view
{
    [self attachToSuperview:view withFrame:view.bounds];
}

- (void)attachToSuperview:(UIView *)view withFrame:(CGRect)rect
{
    [self.view setFrame:rect];
    
    self.view.layer.transform = CATransform3DMakeTranslation(0 , -self.view.frame.size.height, 0);
    
    [view addSubview:self.view];
    
    _sliderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    _isDown = NO;
    _isSliding = NO;
}

- (void)toggleVolumeView
{
    if ( _isSliding )
    {
        // We don't want to slide multiple times at once
        return;
    }
    
    _isSliding = YES;
    
    _isDown = !_isDown;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slidingComplete)];
    
    if ( _isDown == YES )
    {
        self.view.layer.transform = CATransform3DIdentity;
    }
    else
    {
        self.view.layer.transform = CATransform3DMakeTranslation(0 , -self.view.frame.size.height, 0);
    }
    
    [UIView commitAnimations];
    
}

- (void)setFrame:(CGRect)frame
{
    self.view.layer.transform = CATransform3DIdentity;
    
    self.view.frame = frame;
    
    if ( _isDown == YES )
    {
        self.view.layer.transform = CATransform3DIdentity;
    }
    else
    {
        self.view.layer.transform = CATransform3DMakeTranslation(0 , -self.view.frame.size.height, 0);
    }
}

- (void)slidingComplete
{
    _displayed = _isDown;
    _isSliding = NO;
}

- (void)enableAppleSlider
{
    [_volumeView setHidden:NO];
    [_volumeTrackView setHidden:NO];
    
    [_volumeSlider setHidden:YES];
}

- (void)enableManualSlider
{
    [_volumeView setHidden:YES];
    [_volumeTrackView setHidden:YES];
    
    [_volumeSlider setHidden:NO];
}

- (void)dealloc
{
    [_mpVolumeView release];
    [_sliderView release];
    [_volumeSlider release];
    [_volumeView release];
    [_volumeTrackView release];
    [super dealloc];
}
@end
