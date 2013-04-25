//
//  FPMenuViewController.m
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "FPMenuViewController.h"

extern AudioController * g_audioController;

@interface FPMenuViewController ()

@property (retain, nonatomic) IBOutlet UISlider *toneSlider;
@property (retain, nonatomic) IBOutlet UISwitch *audioRouteSwitch;

@end

@implementation FPMenuViewController

- (id)init
{
    self = [super initWithNibName:@"FPMenuViewController" bundle:nil];
    if (self) {
        // Custom initialization
        g_audioController.m_delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customize tone slider
    UIImage * sliderTrackMinImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    UIImage * sliderTrackMaxImage = [[UIImage imageNamed: @"EndCap.png"] stretchableImageWithLeftCapWidth:17 topCapHeight:0];
    UIImage * sliderKnob = [UIImage imageNamed:@"SliderKnobBlue.png"];
    
    [self.toneSlider setMinimumTrackImage:sliderTrackMinImage forState:UIControlStateNormal];
    [self.toneSlider setMaximumTrackImage:sliderTrackMaxImage forState:UIControlStateNormal];
    [self.toneSlider setThumbImage:sliderKnob forState:UIControlStateNormal];
    
    // Customize audio route switch
    self.audioRouteSwitch.thumbTintColor = [UIColor colorWithRed:0 green:160.0/255.0 blue:222.0/255.0 alpha:1.0];
    self.audioRouteSwitch.offImage = [UIImage imageNamed:@"SwitchBG.png"];
    self.audioRouteSwitch.onImage = [UIImage imageNamed:@"SwitchBG.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_toneSlider release];
    [_audioRouteSwitch release];
    
    g_audioController.m_delegate = nil;
    
    [super dealloc];
}

#pragma mark - IBActions

- (IBAction)setTone:(UISlider *)sender
{
    [g_audioController SetBWCutoff:sender.value];
}

- (IBAction)setAudioRoute:(UISwitch *)sender
{
    if (sender.isOn)
    {
        [g_audioController RouteAudioToDefault];
    }
    else
    {
        [g_audioController RouteAudioToSpeaker];
    }
}

- (IBAction)exitFreePlay:(id)sender
{
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AudioController Delegate

-(void) audioRouteChanged:(bool)routeIsSpeaker
{
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
    
    if (routeIsSpeaker)
    {
        [self.audioRouteSwitch setOn:NO];
    }
    else
    {
        [self.audioRouteSwitch setOn:YES];
    }
    
    // The global volume slider is not available when audio is routed to lineout.
    // If the audio is not being outputed to lineout hide the global volume slider,
    // and display our own slider that controlls volume in this mode.
    NSString * routeName = (NSString *)[g_audioController GetAudioRoute];
    if ([routeName isEqualToString:@"LineOut"])
    {
        // TODO tell volume slider widget what to display
    }
    else
    {
        // TODO tell volume slider widget what to display
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:routeIsSpeaker forKey:@"RouteToSpeaker"];
    [settings synchronize];
}

@end
