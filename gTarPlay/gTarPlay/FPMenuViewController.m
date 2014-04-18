//
//  FPMenuViewController.m
//  gTarPlay
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
    
    // Customize tone slider
    UIImage * sliderTrackMinImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    UIImage * sliderTrackMaxImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
    UIImage * sliderKnob = [UIImage imageNamed:@"SliderKnobBlue.png"];
    
    [self.toneSlider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
    [self.toneSlider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
    [self.toneSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
    
    // Customize audio route switch
    self.audioRouteSwitch.thumbTintColor = [[UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0] retain];
    self.audioRouteSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    self.audioRouteSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    self.slideSwitch.thumbTintColor = [[UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0] retain];
    self.slideSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    self.slideSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
    
    if(audioSwitchOn){
        [self setAudioSwitchToDefault];
    }
}

- (void) localizeViews {
    _quitLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"Quit", NULL)];
    _toneLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"TONE", NULL)];
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
    
    [_toneSlider release];
    [audioRouteSwitch release];
    
    [_slideSwitch release];
    [super dealloc];
}

#pragma mark - Tone slider

- (IBAction)setTone:(UISlider *)sender
{
    [delegate setToneToBWCutoff:sender.value];
}

- (void)moveToneSliderToTone:(double)tone
{
    NSLog(@"Move tone slider to tone %f",tone);
    [_toneSlider setValue:tone animated:NO];
}

#pragma mark - Audio Routing

- (IBAction)setAudioRoute:(UISwitch *)sender
{
    if(sender.isOn){
        // route to default
        [delegate audioRouteChanged:NO];
    }else{
        // route to speaker
        [delegate audioRouteChanged:YES];
    }
}

- (void)setAudioSwitchToDefault
{
    NSLog(@"Set audio switch to default");
    [self.audioRouteSwitch setOn:YES];
    audioSwitchOn = YES;
}

- (void)setAudioSwitchToSpeaker
{
    NSLog(@"Set audio switch to speaker");
    [self.audioRouteSwitch setOn:NO];
    audioSwitchOn = NO;
}

- (IBAction)setSlideHammer:(id)sender
{
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
    
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

- (void) didChangeAudioRoute:(NSNotification *) notification
{
    
    NSLog(@"Did change audio route *** ");
    
    NSDictionary *data = [notification userInfo];
    BOOL routeIsSpeaker = [[data objectForKey:@"isRouteSpeaker"] boolValue];
    
    //NSString *routeName = [[NSString alloc] initWithString:[data objectForKey:@"routeName"]];
    /*
     TODO telemetry
     // Telemetetry log -- invert the speaker route so we log the previous state
     NSString* route = !m_bSpeakerRoute ? @"Speaker" : @"Aux";
     
     NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_audioRouteTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
     
     // Avoid the first setting
     if ( delta > 0 )
     {
     [g_telemetryController logEvent:GtarFreePlayToggleFeature
     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
     route, @"AudioRoute",
     [NSNumber numberWithInteger:delta], @"PlayTime",
     nil]];
     
     [m_audioRouteTimeStart release];
     m_audioRouteTimeStart = [[NSDate date] retain];
     }
     */
    
    //[_testText setText:routeName];
    
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
