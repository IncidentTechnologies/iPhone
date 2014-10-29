//
//  FPMenuViewController.m
//  keysPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "FPMenuViewController.h"

@implementation FPMenuViewController

@synthesize delegate;
@synthesize audioRouteSwitch;

- (id)init
{
    self = [super initWithNibName:@"FPMenuViewController" bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioRoute:) name:@"AudioRouteChange" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    [self initSwitches];

}

- (void) initSwitches
{
    
    // Customize tone slider
    /*UIImage * sliderTrackMinImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    UIImage * sliderTrackMaxImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
    UIImage * sliderKnob = [UIImage imageNamed:@"SliderKnobBlue.png"];
    
    [self.toneSlider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
    [self.toneSlider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
    [self.toneSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
    */
    
    // Customize audio route switch
    self.audioRouteSwitch.thumbTintColor = [UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0];
    self.audioRouteSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    self.audioRouteSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    self.slideSwitch.thumbTintColor = [UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0];
    self.slideSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    self.slideSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    [_slideSwitch setOn:YES];
    
    if(!audioSwitchOn){
        [self setAudioSwitchToDefault];
    }else{
        [self setAudioSwitchToSpeaker];
    }

}

- (void) localizeViews {
    _quitLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Quit", NULL)];
    //_toneLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"TONE", NULL)];
    _outputLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"OUTPUT", NULL)];
    _speakerLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SPEAKER", NULL)];
    _auxLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"AUX", NULL)];
    _slidingLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"SLIDING", NULL)];
    _offLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"OFF", NULL)];
    _onLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ON", NULL)];
    //_exitToMainLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"EXIT TO MAIN", NULL)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
    
}

#pragma mark - Tone slider

- (IBAction)setTone:(UISlider *)sender
{
    [delegate setToneToBWCutoff:sender.value];
}

- (void)moveToneSliderToTone:(double)tone
{
    DLog(@"Move tone slider to tone %f",tone);
    //[_toneSlider setValue:tone animated:NO];
}

#pragma mark - Audio Routing

- (IBAction)setAudioRoute:(UISwitch *)sender
{
    if(!sender.isOn){
        // route to default
        [delegate audioRouteChanged:NO];
    }else{
        // route to speaker
        [delegate audioRouteChanged:YES];
    }
}

- (void)setAudioSwitchToDefault
{
    DLog(@"Set audio switch to default");
    [self.audioRouteSwitch setOn:NO];
    audioSwitchOn = NO;
}

- (void)setAudioSwitchToSpeaker
{
    DLog(@"Set audio switch to speaker");
    [self.audioRouteSwitch setOn:YES];
    audioSwitchOn = YES;
}

- (IBAction)setSlideHammer:(id)sender
{
    
    // Set a notification
    NSDictionary *routeData = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:_slideSwitch.isOn], @"isSlideEnabled", nil];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SlideHammerStateChange"
     object:self userInfo:routeData];
    
    
}

- (IBAction)exitFreePlay:(id)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ExitFreePlay"
     object:self];
    
    [delegate backButtonClicked];
    
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

- (void) didChangeAudioRoute:(NSNotification *) notification
{
    
    DLog(@"Did change audio route *** ");
    
    NSDictionary *data = [notification userInfo];
    BOOL routeIsSpeaker = [[data objectForKey:@"isRouteSpeaker"] boolValue];
    
    if (routeIsSpeaker)
    {
        [self setAudioSwitchToSpeaker];
    }
    else
    {
        [self setAudioSwitchToDefault];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:routeIsSpeaker forKey:@"RouteToSpeaker"];
    [settings synchronize];
}

@end
