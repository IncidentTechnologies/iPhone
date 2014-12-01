//
//  FreePlayController.m
//  keysPlay
//
//  Created by Kate Schnippering on 10/23/14.
//  Copyright 2014 Incident Technologies. All rights reserved.
//


#import "FreePlayController.h"


extern KeysController * g_keysController;
//extern SoundMaster * g_soundMaster;
//extern AudioController * g_audioController;
//extern TelemetryController * g_telemetryConstroller;

@interface FreePlayController ()

@property (strong, nonatomic) SoundMaster *g_soundMaster;

@property (strong, nonatomic) InstrumentsAndEffectsViewController *instrumentsAndEffectsVC;
@property (strong, nonatomic) LightsViewController *lightsVC;
@property (strong, nonatomic) FPMenuViewController *fpMenuVC;
@property (strong, nonatomic) VolumeViewController *volumeVC;

@property (strong, nonatomic) IBOutlet UIView *mainContentView;
@property (strong, nonatomic) IBOutlet UIView *generalTouchSurface;
@property (weak, nonatomic) UIViewController *currentMainContentVC;

@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *volumeButton;
@property (strong, nonatomic) IBOutlet UIButton *lightsButton;
@property (strong, nonatomic) IBOutlet UIButton *effectsButton;
@property (strong, nonatomic) IBOutlet UIButton *instrumentsButton;

@property (strong, nonatomic) IBOutlet UIButton *arrowMenu;
@property (strong, nonatomic) IBOutlet UIButton *arrowLights;
@property (strong, nonatomic) IBOutlet UIButton *arrowEffects;
@property (strong, nonatomic) IBOutlet UIButton *arrowInstruments;

@property (strong, nonatomic) IBOutlet UIView *menuBarDropShadowView;

@property BOOL isSlideEnabled;

-(void) switchMainContentControllerToVC:(UIViewController*)newVC;

@end

@implementation FreePlayController

@synthesize m_jamPad;
@synthesize m_wetSlider;
@synthesize m_currentEffectName;
@synthesize m_effectsTab;
//@synthesize m_volumeView;
//@synthesize m_lineOutVolumeSlider;
//@synthesize m_audioRouteSwitch;
@synthesize m_activityIndicatorView;
@synthesize m_connectingView;
@synthesize m_xParamLabel;
@synthesize m_yParamLabel;
@synthesize m_effect1OnOff;
@synthesize m_effect1Select;
@synthesize m_effect1Name;
@synthesize m_effect2OnOff;
@synthesize m_effect2Select;
@synthesize m_effect2Name;
@synthesize m_effect3OnOff;
@synthesize m_effect3Select;
@synthesize m_effect3Name;
@synthesize m_effect4OnOff;
@synthesize m_effect4Select;
@synthesize m_effect4Name;
@synthesize m_instrumentsTab;
@synthesize m_instrumentsScroll;
//@synthesize m_menuTab;
//@synthesize m_toneSlider;
@synthesize m_bSpeakerRoute;
@synthesize m_LEDTab;
@synthesize m_LEDGeneralSurface;
@synthesize m_LEDKeySurface;
//@synthesize m_LEDStringSurface;
@synthesize m_LEDAllSurface;
@synthesize m_LEDTouchArea;
@synthesize m_lastLEDTouch;
@synthesize m_LEDMode;
@synthesize m_LEDColorMode;
@synthesize m_colors;
@synthesize m_currentColorIndex;
@synthesize m_LEDShape;
@synthesize m_LEDLoop;
@synthesize m_LEDTimer;
@synthesize m_harmonizer;
@synthesize m_harmonizerValue;
@synthesize m_scaleSwitch;

@synthesize g_soundMaster;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSoundMaster:(SoundMaster *)soundMaster
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        // disable idle sleeping
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // Properly account for play time
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        // Register for slide/hammer state change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSlideHammer:) name:@"SlideHammerStateChange" object:nil];
        
        // Register for output change notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAudioRoute:) name:@"AudioRouteChange" object:nil];
        
        m_playTimeStart = [NSDate date];
        m_audioRouteTimeStart = [NSDate date];
        m_instrumentTimeStart = [NSDate date];
        m_scaleTimeStart = [NSDate date];
        
        g_soundMaster = soundMaster;
        [g_soundMaster start];
        
        //_instrumentsAndEffectsVC = [[InstrumentsAndEffectsViewController alloc] initWithAudioController:g_audioController];
        _instrumentsAndEffectsVC = [[InstrumentsAndEffectsViewController alloc] initWithSoundMaster:g_soundMaster];
        _lightsVC = [[LightsViewController alloc] init];
        _lightsVC.delegate = self;
        
        _fpMenuVC = [[FPMenuViewController alloc] init];
        [_fpMenuVC setDelegate:self];
        
        _volumeVC = [[VolumeViewController alloc] initWithNibName:nil bundle:nil andSoundMaster:g_soundMaster isInverse:NO];
        
        for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
        {
            m_effectTimeStart[effect] = [NSDate date];
        }
        
        m_playTimeAdjustment = 0;
        
        // Create audio controller
        [g_soundMaster start];
        
        RGBColor *white = [[RGBColor alloc] initWithRed:3 Green:3 Blue:3];
        RGBColor *red = [[RGBColor alloc] initWithRed:3 Green:0 Blue:0];
        RGBColor *green = [[RGBColor alloc] initWithRed:0 Green:3 Blue:0];
        RGBColor *blue = [[RGBColor alloc] initWithRed:0 Green:0 Blue:3];
        RGBColor *cyan = [[RGBColor alloc] initWithRed:0 Green:3 Blue:3];
        RGBColor *magenta = [[RGBColor alloc] initWithRed:3 Green:0 Blue:3];
        RGBColor *yellow = [[RGBColor alloc] initWithRed:3 Green:3 Blue:0];
        RGBColor *orange = [[RGBColor alloc] initWithRed:3 Green:1 Blue:0];
        
        m_colors = [[NSArray alloc] initWithObjects:white, red, magenta, blue, cyan, green, yellow, orange, nil];
        
        m_harmonizer = [[Harmonizer alloc] init];
        m_harmonizerValue = 0;
        
        m_ScaleArray[0] = 0;
        m_ScaleArray[1] = 2;
        m_ScaleArray[2] = 5;
        m_ScaleArray[3] = 7;
        m_ScaleArray[4] = 10;
        m_ScaleArray[5] = 12;
        m_ScaleArray[6] = 14;
        m_ScaleArray[7] = 17;
        m_ScaleArray[8] = 19;
        m_ScaleArray[9] = 22;
        m_ScaleArray[10] = 24;
        m_ScaleArray[11] = 26;
        m_ScaleArray[12] = 29;
        m_ScaleArray[13] = 31;
        m_ScaleArray[14] = 34;
        m_ScaleArray[15] = 36;
        m_ScaleArray[16] = 38;
        m_ScaleArray[17] = 41;
    }
    
    return self;
    
}

- (void)dealloc
{
    
    // disable idle sleeping
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AudioRouteChange" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SlideHammerStateChange" object:nil];
    
    [g_keysController removeObserver:self];
    
    
    //[m_volumeView release];
    //[m_menuTab release];
    //[m_toneSlider release];
    
    //[g_soundMaster releaseAfterUse];
    
    //[m_lineOutVolumeSlider release];
    
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
    }
    
    //[m_audioRouteSwitch release];
    
    
    // Turn off all LEDs
    if(g_keysController.connected){
        [g_keysController turnOffAllLeds];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self initSliding];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up initial content VC to be instruments & effects.
    [self addChildViewController:self.instrumentsAndEffectsVC];
    [self.mainContentView addSubview:self.instrumentsAndEffectsVC.view];
    [self.instrumentsAndEffectsVC didMoveToParentViewController:self];
    _currentMainContentVC = self.instrumentsAndEffectsVC;
    
    [_arrowMenu addShadow];
    [_arrowLights addShadow];
    [_arrowEffects addShadow];
    [_arrowInstruments addShadow];
    [_menuBarDropShadowView addShadow];
    
    // images for slider
    //UIImage *sliderTrackMinImage = [[UIImage imageNamed: @"SliderEndMin.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    //UIImage *sliderTrackMaxImage = [[UIImage imageNamed: @"SliderEndMax.png"] stretchableImageWithLeftCapWidth: 1 topCapHeight: 0];
    
    // centered in the x dimension (and y dimension, we change that in a moment)
    m_effectsTab.center = self.view.center;
    m_instrumentsTab.center = self.view.center;
    //m_menuTab.center = self.view.center;
    m_LEDTab.center = self.view.center;
    
    CGRect smallTabFrame = m_effectsTab.frame;
    //CGRect menuTabFrame = m_menuTab.frame;
    CGRect largeTabFrame = m_LEDTab.frame;
    
    smallTabFrame.origin.x = -105;
    //menuTabFrame.origin.x = -328;
    largeTabFrame.origin.x = -446;
    // move tab up to align with wet/dry frame
    smallTabFrame.origin.y = 0;
    largeTabFrame.origin.y = 0;
    //menuTabFrame.origin.y = 0;
    [m_effectsTab setFrame:smallTabFrame];
    [m_instrumentsTab setFrame:smallTabFrame];
    //[m_menuTab setFrame:menuTabFrame];
    [m_LEDTab setFrame:largeTabFrame];
    
    [m_effectsTab addTransparentAreaWithXmin:(m_instrumentsTab.frame.size.width - 30) xMax:m_effectsTab.frame.size.width yMin:80 yMax:m_effectsTab.frame.size.height];
    [m_instrumentsTab addTransparentAreaWithXmin:(m_instrumentsTab.frame.size.width - 30) xMax:m_instrumentsTab.frame.size.width yMin:0 yMax:80];
    [m_instrumentsTab addTransparentAreaWithXmin:(m_instrumentsTab.frame.size.width - 30) xMax:m_instrumentsTab.frame.size.width yMin:155 yMax:m_instrumentsTab.frame.size.height];
    [m_LEDTab addTransparentAreaWithXmin:m_LEDTab.frame.size.width - 30 xMax:m_LEDTab.frame.size.width yMin:0 yMax:155];
    [m_LEDTab addTransparentAreaWithXmin:m_LEDTab.frame.size.width - 30 xMax:m_LEDTab.frame.size.width yMin:225 yMax:m_LEDTab.frame.size.height];
    //[m_menuTab addTransparentAreaWithXmin:(m_menuTab.frame.size.width - 30) xMax:m_menuTab.frame.size.width yMin:0 yMax:225];
    
    /*[self.view addSubview:m_effectsTab];
     [self.view addSubview:m_instrumentsTab];
     [self.view addSubview:m_LEDTab];
     [self.view addSubview:m_menuTab];*/
    
    [m_instrumentsScroll setBackgroundColor:[UIColor clearColor]];
    
    //NSMutableArray *instrumentScrollText = [ar mutableCopy];
    NSMutableArray * instrumentScrollText = [[NSMutableArray alloc] initWithArray:[g_soundMaster getInstrumentList]];
    [m_instrumentsScroll populateWithText:instrumentScrollText];
    
    // Set up effects tab. Set image to display when button is "selected"
    [m_effect1OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect1Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    [m_effect2OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect2Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    [m_effect3OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect3Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    [m_effect4OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect4Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    // set custom images for sliders
    //UIImage *sliderKnobImage = [UIImage imageNamed: @"Knob_BlueLine.png"];
    
    //[m_wetSlider setMinimumTrackImage: sliderTrackMinImage forState: UIControlStateNormal];
    //[m_wetSlider setMaximumTrackImage: sliderTrackMaxImage forState: UIControlStateNormal];
    //[m_wetSlider setThumbImage: [UIImage imageNamed: @"SliderKnob.png"] forState:UIControlStateNormal];
    
    //[m_toneSlider setMinimumTrackImage: sliderTrackMinImage forState: UIControlStateNormal];
    //[m_toneSlider setMaximumTrackImage: sliderTrackMaxImage forState: UIControlStateNormal];
    //[m_toneSlider setThumbImage: sliderKnobImage forState:UIControlStateNormal];
    
    //[m_lineOutVolumeSlider setMinimumTrackImage: sliderTrackMinImage forState:UIControlStateNormal];
    //[m_lineOutVolumeSlider setMaximumTrackImage: sliderTrackMaxImage forState:UIControlStateNormal];
    //[m_lineOutVolumeSlider setThumbImage: sliderKnobImage forState:UIControlStateNormal];
    
    //m_wetSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //m_toneSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //m_lineOutVolumeSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    // Set up menu tab
    // Get audio route setting and move route knob appropriately
    
    //NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    //[settings synchronize];
    // temporarily set the bool to the opposite of the actual value
    //m_bSpeakerRoute = ![settings boolForKey:@"RouteToSpeaker"];
    // toogle the route so that its what we actually want
    //[self toggleAudioRoute:self];
    //m_bSpeakerRoute = !m_bSpeakerRoute;
    
    // To avoid displaying the wrong image when the switch selected and being pressed,
    // we must set an image for the selected AND highlighted state (UIControlState
    // is a bit map), besides having set the image for selected state in IB
    //[m_audioRouteSwitch setImage:[UIImage imageNamed:@"SwitchUp.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [m_scaleSwitch setImage:[UIImage imageNamed:@"SwitchUp.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    // Setup Jam Pad
    //rotate y label and dry/wet slider 90 degrees counterclockwise
    m_yParamLabel.transform = CGAffineTransformMakeRotation(-M_PI_2 );
    // Flip y axis of JamPad so that +y points upwards instead of down
    m_jamPad.transform = CGAffineTransformMakeScale(1, -1);
    m_jamPad.m_delegate = self;
    // Initialize jam pad with first effect in list
    //    [self setupJamPadWithEffectAtIndex:0];
    
    // Setup LED light tab
    [m_LEDGeneralSurface setBackgroundColor:[UIColor clearColor]];
    [m_LEDAllSurface setBackgroundColor:[UIColor clearColor]];
    [m_LEDKeySurface setBackgroundColor:[UIColor clearColor]];
    //[m_LEDStringSurface setBackgroundColor:[UIColor clearColor]];
    m_LEDGeneralSurface.transform = CGAffineTransformMakeScale(1, -1);
    //m_LEDStringSurface.transform = CGAffineTransformMakeScale(1, -1);
    
    m_lastLEDTouch = CGPointMake(-1, -1);
    m_LEDMode = LEDModeTrail;
    m_LEDShape = LEDShapeDot;
    m_LEDLoop = NUM_LEDLoop_ENTRIES;
    
    // Start activity spinner while we connect to keys
    //    if ( g_keysController.m_connected == NO )
    //    {
    //        //[self.view addSubview:m_connectingView];
    //    }
    
    [g_keysController addObserver:self];
    
    [g_soundMaster start];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = CGRectMake(_volumeButton.frame.origin.x, _mainContentView.frame.origin.y, _volumeButton.frame.size.width, _mainContentView.frame.size.height);
    _volumeVC.view.frame = frame;
    
    [_instrumentsAndEffectsVC.view setFrame:_mainContentView.bounds];
    [_lightsVC.view setFrame:_mainContentView.bounds];
    [_fpMenuVC.view setFrame:_mainContentView.bounds];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[_menuButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[_volumeButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[_lightsButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[_effectsButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[_instrumentsButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    
    CGRect frame = CGRectMake(_volumeButton.frame.origin.x, _mainContentView.frame.origin.y, _volumeButton.frame.size.width, _mainContentView.frame.size.height);
    [_volumeVC attachToSuperview:self.view withFrame:frame];
    
    //
    // Set the audio routing destination
    //
    NSString * audioRoute = [g_soundMaster getAudioRoute];
    BOOL isSpeakerRoute = ([audioRoute isEqualToString:@"Speaker"]) ? YES : NO;
    
    [self audioRouteChanged:isSpeakerRoute];
    
    
}

- (void)viewDidUnload
{
    [self setM_jamPad:nil];
    [self setM_wetSlider:nil];
    
    //self.m_volumeView = nil;
    self.m_activityIndicatorView = nil;
    self.m_connectingView = nil;
    
    [self setM_effectsTab:nil];
    [self setM_effect1OnOff:nil];
    [self setM_effect2OnOff:nil];
    [self setM_effect3OnOff:nil];
    [self setM_effect4OnOff:nil];
    [self setM_effect1Select:nil];
    [self setM_effect2Select:nil];
    [self setM_effect3Select:nil];
    [self setM_effect4Select:nil];
    [self setM_effect1Name:nil];
    [self setM_effect2Name:nil];
    [self setM_effect3Name:nil];
    [self setM_effect4Name:nil];
    [self setM_currentEffectName:nil];
    //[self setM_menuTab:nil];
    //[self setM_toneSlider:nil];
    [self setM_instrumentsScroll:nil];
    //[self setM_lineOutVolumeSlider:nil];
    [self setM_LEDTab:nil];
    [self setM_LEDGeneralSurface:nil];
    [self setM_LEDKeySurface:nil];
    //[self setM_LEDStringSurface:nil];
    [self setM_LEDAllSurface:nil];
    
    //[self setM_audioRouteSwitch:nil];
    [self setM_scaleSwitch:nil];
    [super viewDidUnload];
}

- (void)handleResignActive
{
    m_playTimeAdjustment += [[NSDate date] timeIntervalSince1970] - [m_playTimeStart timeIntervalSince1970];
}

- (void)handleBecomeActive
{
    
    for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
    {
    }
    
    m_playTimeStart = [NSDate date];
    m_audioRouteTimeStart = [NSDate date];
    m_instrumentTimeStart = [NSDate date];
    m_scaleTimeStart = [NSDate date];
    
    for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
    {
        m_effectTimeStart[effect] = [NSDate date];
    }
}

- (void)finalLogging
{
    
    // Log relevant things before exiting
    NSString* route = m_bSpeakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_audioRouteTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    //    [g_telemetryController logEvent:KeysFreePlayToggleFeature
    //                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                     route, @"AudioRoute",
    //                                     [NSNumber numberWithInteger:delta], @"PlayTime",
    //                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"FreePlay toggle feature" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           route, @"AudioRoute",
                                                           [NSNumber numberWithInteger:delta], @"PlayTime",
                                                           nil]];
    
    NSString *instrumentName = [m_instrumentsScroll getNameAtIndex:[g_soundMaster getCurrentInstrument]];
    
    delta = [[NSDate date] timeIntervalSince1970] - [m_instrumentTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    //    [g_telemetryController logEvent:KeysFreePlayToggleFeature
    //                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                     instrumentName, @"Instrument",
    //                                     [NSNumber numberWithInteger:delta], @"PlayTime",
    //                                     nil]];
    
    [mixpanel track:@"FreePlay toggle feature" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           instrumentName, @"Instrument",
                                                           [NSNumber numberWithInteger:delta], @"PlayTime",
                                                           nil]];
    
    UIButton *effectButtons[FREE_PLAY_EFFECT_COUNT] = { m_effect1OnOff, m_effect2OnOff, m_effect3OnOff, m_effect4OnOff };
    
    for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
    {
        //NSString* name = [g_audioController getEffectNames][effect];
        NSString * name = [g_soundMaster getEffectNameAtIndex:effect];
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_effectTimeStart[effect] timeIntervalSince1970] + m_playTimeAdjustment;
        
        if ( [effectButtons[effect] isSelected] == YES )
        {
            //            [g_telemetryController logEvent:KeysFreePlayToggleFeature
            //                             withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
            //                                             @"Off", name,
            //                                             [NSNumber numberWithInteger:delta], @"PlayTime",
            //                                             nil]];
            [mixpanel track:@"FreePlay toggle feature" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"Off", name,
                                                                   [NSNumber numberWithInteger:delta], @"PlayTime",
                                                                   nil]];
        }
        
    }
    
}

- (void)initSliding
{
    _isSlideEnabled = YES;
    
    [g_soundMaster enableSliding];
    
}

#pragma mark - Main event loop

//- (void)mainEventLoop
//{
//
//}

#pragma mark - KeysObserverProtocol

- (void)keysDown:(KeyPosition)position
{
    // Only act upon this message if sliding/hammering is enabled
    if (_isSlideEnabled)
    {
        //[g_soundMaster KeyDown:position];
    }
}

- (void)keysUp:(KeyPosition)position
{
    // Only act upon this message if sliding/hammering is enabled
    if (_isSlideEnabled)
    {
        //[g_soundMaster KeyUp:position];
    }
}

- (void)keysNoteOn:(KeysPress)press
{
    KeyPosition key = press.position;
    
    [g_soundMaster NoteOnForKey:key];
}

- (void)keysNoteOff:(KeyPosition)position
{
    [g_soundMaster NoteOnForKey:position];
}

- (void)keysRangeChange:(KeysRange)range
{
    DLog(@"Free Play Controller | Keys Range Change");
    
    // Redraw the grid
    [_lightsVC drawGeneralSurface];
}

- (void)keysConnected
{
    
    //    [m_activityIndicatorView stopAnimating];
    [m_connectingView removeFromSuperview];
    
    [g_keysController turnOffAllEffects];
    [g_keysController turnOffAllLeds];
    [g_keysController setMinimumInterarrivalTime:0.05f];
    
    [self startMainEventLoop:SECONDS_PER_EVENT_LOOP];
    
    [g_soundMaster routeToDefault];
    
}

- (void)keysDisconnected
{
    
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_playTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    //    [g_telemetryController logEvent:KeysFreePlayDisconnected
    //                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                     [NSNumber numberWithInteger:delta], @"PlayTime",
    //                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"FreePlay disconnected" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                                         nil]];
    
    [self finalLogging];
    
    [g_soundMaster disableSliding];
    [g_soundMaster stopAllEffects];
    [g_soundMaster stop];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

// selector to update the slide/hammer state when NSNotification is received
- (void) didChangeSlideHammer:(NSNotification *) notification
{
    NSDictionary *data = [notification userInfo];
    _isSlideEnabled = [[data objectForKey:@"isSlideEnabled"] boolValue];
    
    if(_isSlideEnabled){
        [g_soundMaster enableSliding];
    }else{
        [g_soundMaster disableSliding];
    }
    
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // For now we just want to recognize that a touch (any touch) occurred
    UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
    if (LEDColorRoatating == m_LEDColorMode)
    {
        m_currentColorIndex++;
        if (m_currentColorIndex >= [m_colors count])
        {
            m_currentColorIndex = 0;
        }
    }
    
    UIView *touchedView = [touch view];
    if (touchedView == m_LEDGeneralSurface)
    {
        m_LEDTouchArea = LEDTouchGeneral;
    }
    else if (touchedView == m_LEDKeySurface)
    {
        m_LEDTouchArea = LEDTouchKey;
    }
    /*else if (touchedView == m_LEDStringSurface)
    {
        m_LEDTouchArea = LEDTouchString;
    }*/
    else if (touchedView == m_LEDAllSurface)
    {
        m_LEDTouchArea = LEDTouchAll;
    }
    else
    {
        
//#ifdef Debug_BUILD
        CGPoint point = [touch locationInView:self.view];
        
        int keyMin = [g_keysController range].keyMin;
        int keyMax = [g_keysController range].keyMax;
        
        if(point.x < _generalTouchSurface.frame.origin.x || point.x > _generalTouchSurface.frame.origin.x+_generalTouchSurface.frame.size.width){
            DLog(@"Touch out of range");
            return;
        }
        
        int key = ((point.x-_generalTouchSurface.frame.origin.x) / (_generalTouchSurface.frame.size.width/(keyMax - keyMin))) + keyMin;
        
        DLog(@"Play key %f/(%f/%i)+1 = %i",point.x-_generalTouchSurface.frame.origin.x,_generalTouchSurface.frame.size.width,(keyMax-keyMin),key);
        
        KeysPress press;
        press.velocity = KeysMaxPressVelocity;
        press.position = key;
        
        [self keysNoteOn:press];
        
        /*
        if(point.y > 60 && point.y < 202 && point.x > 15 && point.x < 410){
            
            int str = KEYS_GUITAR_STRING_COUNT - ceil((point.y-60) / (143/KEYS_GUITAR_STRING_COUNT));
            if (str >= KEYS_GUITAR_STRING_COUNT){
                str = (KEYS_GUITAR_STRING_COUNT-1);
            }
            
            int fret = KEYS_GUITAR_FRET_COUNT - (point.x-15)/(395/KEYS_GUITAR_FRET_COUNT);
            if(fret >= KEYS_GUITAR_FRET_COUNT){
                fret = (KEYS_GUITAR_FRET_COUNT-1);
            }
            
        }
         */
//#endif
        
        m_LEDTouchArea = LEDTouchNone;
        return;
    }
    
    [self touchedLEDs:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    DLog(@"touches moved free play controller");
    
    // Only take action if the touch is inside a designated LED area
    if (LEDTouchNone != m_LEDTouchArea)
    {
        [self touchedLEDs:touches];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"touches ended free play controller");
    
    // Check that last touchBegan was inside an LED touch area
    if (LEDTouchNone != m_LEDTouchArea)
    {
        // Turn off last LED touch point when finger touch ends
        //[self turnOffLED:m_lastLEDTouch.x AndFret:m_lastLEDTouch.y];
    }
    
    // reset the last touch point
    m_lastLEDTouch = CGPointMake(-1, -1);
}

#pragma mark - LED light logic

- (void) touchedLEDs:(NSSet *)touches
{
    // stop the LED auto loop playback if its on
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    RGBColor *color = [m_colors objectAtIndex:m_currentColorIndex];
    
    // string and fret position, 1 based. A value of 0 for string/fret
    // indicates all strings/frets respectively on the specified fret/string
    int string, fret;
    
    for (UITouch *touch in touches)
    {
        /*
        CGPoint stringFret = [self getFretPositionFromTouch:touch];
        
        string = stringFret.x;
        fret = stringFret.y;
        if (string < 0 || fret < 0)
        {
            DLog(@"touchedLED: Invalid fret & string. fret:%d string:%d", fret, string);
            return;
        }
        
        if (string == m_lastLEDTouch.x && fret == m_lastLEDTouch.y)
        {
            // finger is on same fret, do nothing
            return;
        }
        
        // Finger position had changed, turn off previous location according
        // to LEDMode
        [self turnOffLED:m_lastLEDTouch.x AndFret:m_lastLEDTouch.y];
        
        m_lastLEDTouch = CGPointMake(string, fret);
        
        // Turn on new fret position
        if (LEDTouchAll == m_LEDTouchArea && LEDColorRandom == m_LEDColorMode)
        {
            // turn all all frets with rotating colors
            [self turnOnAllLEDRandom];
        }
        else
        {
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
        }
        
        // if color mode is 'random' rotate colors on every new led position
        if (LEDColorRandom == m_LEDColorMode)
        {
            m_currentColorIndex++;
            if (m_currentColorIndex >= [m_colors count])
            {
                m_currentColorIndex = 0;
            }
        }
         */
    }
}

// Turns the UITouch point and converts it into a string and fret position
// corresponding to this point based on the active LEDTouchArea.
- (CGPoint) getFretPositionFromTouch:(UITouch *)touch
{
    int string = -1;
    int fret = -1;
    CGPoint point;
    
    switch (m_LEDTouchArea)
    {
        case LEDTouchGeneral:
            
            point = [touch locationInView:self.m_LEDGeneralSurface];
            
            string = (point.y / (m_LEDGeneralSurface.frame.size.height/KEYS_GUITAR_STRING_COUNT)) + 1;
            if (string < 1)
            {
                string = 1;
            }
            else if ( string > KEYS_GUITAR_STRING_COUNT)
            {
                string = (KEYS_GUITAR_STRING_COUNT);
            }
            
            fret = (point.x / (m_LEDGeneralSurface.frame.size.width/KEYS_GUITAR_FRET_COUNT)) + 1;
            if (fret < 1)
            {
                fret = 1;
            }
            else if ( fret > KEYS_GUITAR_FRET_COUNT )
            {
                fret = (KEYS_GUITAR_FRET_COUNT);
            }
            
            break;
            
        case LEDTouchKey:
            point = [touch locationInView:self.m_LEDKeySurface];
            
            fret = (point.x / (m_LEDKeySurface.frame.size.width/KEYS_GUITAR_FRET_COUNT)) + 1;
            if ( fret < 1 )
            {
                fret = 1;
            }
            else if ( fret > KEYS_GUITAR_FRET_COUNT )
            {
                fret = (KEYS_GUITAR_FRET_COUNT);
            }
            
            // Light up this fret across all strings
            string = 0;
            
            break;
            
        /*case LEDTouchString:
            point = [touch locationInView:self.m_LEDStringSurface];
            
            string = (point.y / (m_LEDStringSurface.frame.size.height/KEYS_GUITAR_STRING_COUNT)) + 1;
            if (string < 1)
            {
                string = 1;
            }
            else if ( string > KEYS_GUITAR_STRING_COUNT)
            {
                string = (KEYS_GUITAR_STRING_COUNT);
            }
            
            // Light up this string on all frets
            fret = 0;
            
            break;*/
            
        case LEDTouchAll:
            // Light up the entire fret board
            string = 0;
            fret = 0;
            
            break;
            
        default:
            DLog(@"Invalid LEDTouchArea: %d", m_LEDTouchArea);
            break;
    }
    
    return CGPointMake(string, fret);
}

// turns on the LED at the specified string and fret based on the current
// m_LEDShape value
- (void) turnOnLED:(int)key WithColorRed:(int)red AndGreen:(int)green AndBlue:(int)blue
{
    // Regardless of shape we will turn on the touch point.
    [g_keysController turnOnLedAtPosition:key
                                withColor:KeysLedColorMake(red, green, blue)];
    
    /*switch (m_LEDShape)
    {
        case LEDShapeCross:
            // Turn on adjacent leds to make a + shape
            if (string + 1 < KEYS_GUITAR_STRING_COUNT + 1)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string+1)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            if (string - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string-1)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            if (fret + 1 < KEYS_GUITAR_FRET_COUNT + 1)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret+1, string)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            if (fret - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret-1, string)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            
            break;
            
        case LEDShapeSquare:
            
            if (string + 1 < KEYS_GUITAR_STRING_COUNT + 1)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string+1)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            if (fret - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret-1, string)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            if (string + 1 < KEYS_GUITAR_STRING_COUNT + 1 && fret - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret-1, string+1)
                                            withColor:KeysLedColorMake(red, green, blue)];
            }
            
            break;
            
        default:
            break;
    }*/
}

// handles turning off LEDs based on the current m_LEDMode
- (void) turnOffLED:(int)key
{
    if (LEDModeSingle == m_LEDMode)
    {
        [self turnOffLEDByShape:key];
    }
    else if (LEDModeTrail == m_LEDMode)
    {
        // Turn off LED after a delay to create a trailing effect
        NSArray *params = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:key],
                           nil];
        
        [self performSelector:@selector(turnOffLEDDelayed:) withObject:params afterDelay:0.4];
    }
    
}

// a method in a form that can be used as a selector, i.e. has a single
// paramter that contains the string and fret positions to turn off.
- (void) turnOffLEDDelayed:(NSArray *)params
{
    [[params objectAtIndex:0] intValue];
    [self turnOffLEDByShape:[[params objectAtIndex:0] intValue]];
}

// turns off the LED at the specified string and fret based on the current
// m_LEDShape value
- (void) turnOffLEDByShape:(int)key
{
    // Regardless of shape we will turn off the touch point.
    [g_keysController turnOnLedAtPosition:key
                                withColor:KeysLedColorMake(0, 0, 0)];
    
    /*
    switch (m_LEDShape)
    {
        case LEDShapeCross:
            // Turn on adjacent leds to make a + shape
            if (string + 1 < KEYS_GUITAR_STRING_COUNT + 1)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string+1)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            if (string - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string-1)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            if (fret + 1 < KEYS_GUITAR_FRET_COUNT + 1)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret+1, string)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            if (fret - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret-1, string)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            
            break;
            
        case LEDShapeSquare:
            
            if (string + 1 < KEYS_GUITAR_STRING_COUNT + 1)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string+1)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            if (fret - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret-1, string)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            if (string + 1 < KEYS_GUITAR_STRING_COUNT + 1 && fret - 1 > 0)
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret-1, string+1)
                                            withColor:KeysLedColorMake(0, 0, 0)];
            }
            break;
            
        default:
            break;
    }
     */
}

- (IBAction)setLEDMode:(id)sender
{
    // stop the LED auto loop playback if its on
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    switch ([sender tag])
    {
        case 11:
            m_LEDMode = LEDModeTrail;
            m_LEDShape = LEDShapeDot;
            break;
        case 12:
            m_LEDMode = LEDModeTrail;
            m_LEDShape = LEDShapeSquare;
            break;
        case 13:
            m_LEDMode = LEDModeHold;
            m_LEDShape = LEDShapeDot;
            break;
            
        default:
            break;
    }
}

- (IBAction)setLEDColor:(id)sender
{
    if (9 == [sender tag])
    {
        m_LEDColorMode = LEDColorRoatating;
    }
    else if (10 == [sender tag])
    {
        m_LEDColorMode = LEDColorRandom;
    }
    else
    {
        m_LEDColorMode = LEDColorSingle;
        m_currentColorIndex = [sender tag] - 1;
    }
}

- (IBAction)clearAllLEDs:(id)sender
{
    [g_keysController turnOnLedAtPosition:0
                                withColor:KeysLedColorMake(0, 0, 0)];
}

- (IBAction)autoPlayLEDs:(id)sender
{
    // TODO: fix this
    if(m_LEDLoop >= NUM_LEDLoop_ENTRIES)
        //if (++m_LEDLoop >= NUM_LEDLoop_ENTRIES)
    {
        m_LEDLoop = LEDLoopSolid;
    }
    
    float timeInterval;
    
    switch (m_LEDLoop)
    {
        case LEDLoopSolid:
            timeInterval = .6;
            break;
            
        case LEDLoopUp:
            timeInterval = 0.1;
            break;
        case LEDLoopSide:
            timeInterval = 0.13;
            break;
            
        case LEDRainbow:
            timeInterval = 0.3;
            break;
            
        case LEDSquares:
        case LEDLgSquares:
            timeInterval = 1.5;
            break;
            
        case LEDLoopRandom:
            timeInterval = 0.4;
            break;
            
        default:
            timeInterval = 0.75;
            break;
    }
    
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    m_LEDTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(animateLEDs:) userInfo:nil repeats:YES];
    [self animateLEDs:m_LEDTimer];
}

// turns on the entire keyboard with a different color for each
// key position, the colors are rotating fromt the colors array
- (void) turnOnAllLEDRandom
{
    int keyMin = [g_keysController range].keyMin;
    int keyMax = [g_keysController range].keyMax;
    
    RGBColor *color;
    for (int key = keyMin; key <= keyMax; key++)
    {
        m_currentColorIndex = arc4random_uniform([m_colors count]);
        
        color = [m_colors objectAtIndex:m_currentColorIndex];
        
        [self turnOnLED:key WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
    }
}

- (void) LEDRainbow
{
    int keyMin = [g_keysController range].keyMin;
    int keyMax = [g_keysController range].keyMax;
    
    RGBColor *color;
    for (int key = keyMin; key <= keyMax; key++)
    {
        color = [m_colors objectAtIndex:m_currentColorIndex];
        
        [self turnOnLED:key WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
        
        if (++m_currentColorIndex >= [m_colors count])
        {
            // loop starting at 1, skip 0 (white) for the full fretboard random display
            m_currentColorIndex = 1;
        }
    }
}

- (void) LEDSquarePatches
{
    /*
    RGBColor *color;
    for (int fret = 1; fret <= KEYS_GUITAR_FRET_COUNT; fret = fret+2)
    {
        for (int string = 1; string <= KEYS_GUITAR_STRING_COUNT; string=string+2)
        {
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++m_currentColorIndex >= [m_colors count])
            {
                // loop starting at 1, skip 0 (white) for the full fretboard random display
                m_currentColorIndex = 1;
            }
        }
    }
    */
}

- (void) LEDLgSquarePatches
{
    /*
    RGBColor *color;
    for (int fret = 1; fret <= KEYS_GUITAR_FRET_COUNT; fret = fret+3)
    {
        for (int string = 1; string <= KEYS_GUITAR_STRING_COUNT; string=string+3)
        {
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string AndFret:fret+2 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret+2 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+2 AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+2 AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+2 AndFret:fret+2 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (fret >= 13)
            {
                // if this is the last group of 3, fill in the last (16th) fret with the same
                // colour instead of having it be it's own new color.
                [self turnONLED:string AndFret:fret+3 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
                [self turnONLED:string+1 AndFret:fret+3 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
                [self turnONLED:string+2 AndFret:fret+3 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            }
            
            if (++m_currentColorIndex >= [m_colors count])
            {
                // loop starting at 1, skip 0 (white) for the full fretboard random display
                m_currentColorIndex = 1;
            }
        }
        
        if (fret >= 13)
        {
            break;
        }
    }
     */
}

- (void) animateLEDs:(NSTimer*)theTimer
{
    RGBColor *color;
    
    switch (m_LEDLoop)
    {
        case LEDLoopSolid:
            
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            [self turnOnLED:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++m_currentColorIndex >= [m_colors count])
            {
                m_currentColorIndex = 0;
            }
            
            break;
            
        case LEDLoopUp:
            
            /*
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            int static key = KEYS_KEY_COUNT;
            
            [self turnOnLED:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (--key < 1)
            {
                key = 16;
                if (++m_currentColorIndex >= [m_colors count])
                {
                    m_currentColorIndex = 0;
                }
            }
            */
            
            break;
            
        case LEDLoopSide:
            
            /*
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            int static string = 1;
            
            [self turnOnLED:string AndFret:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++string > KEYS_GUITAR_STRING_COUNT)
            {
                string = 1;
                if (++m_currentColorIndex >= [m_colors count])
                {
                    m_currentColorIndex = 0;
                }
            }
             */
            
            break;
            
        case LEDRainbow:
            [self LEDRainbow];
            break;
            
        case LEDSquares:
            [self LEDSquarePatches];
            break;
            
        case LEDLgSquares:
            [self LEDLgSquarePatches];
            break;
            
        case LEDLoopRandom:
            [self turnOnAllLEDRandom];
            break;
            
        default:
            break;
    }
}

- (IBAction)setWet:(id)sender
{
    //m_selectedEffect->SetWet([m_wetSlider value]);
}


#pragma mark - Button clicked handlers

- (IBAction)instrumentSelected:(id)sender
{
    
    NSString *instrumentName = [m_instrumentsScroll getNameAtIndex:[g_soundMaster getCurrentInstrument]];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_instrumentTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    // Avoid the first setting
    if ( delta > 0 )
    {
        //        [g_telemetryController logEvent:KeysFreePlayToggleFeature
        //                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        //                                         instrumentName, @"Instrument",
        //                                         [NSNumber numberWithInteger:delta], @"PlayTime",
        //                                         nil]];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"FreePlay toggle feature" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               instrumentName, @"Instrument",
                                                               [NSNumber numberWithInteger:delta], @"PlayTime",
                                                               nil]];
        
        m_instrumentTimeStart = [NSDate date];
    }
    
    NSString *sampleName = [m_instrumentsScroll getNameAtIndex:[sender m_selectedIndex]];
    [m_instrumentsScroll flickerSelectedItem];
    [g_soundMaster didSelectInstrument:sampleName withSelector:@selector(samplerFinishedLoadingCB:) andOwner:self];
}

- (void) samplerFinishedLoadingCB:(NSNumber*)result
{
    if ([result boolValue])
    {
        [g_soundMaster stopAllEffects];
        [m_instrumentsScroll stopFlicker];
    }
}

// -(void)backButtonClicked
- (IBAction)backButtonClicked:(id)sender
{
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_playTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    //    [g_telemetryController logEvent:KeysFreePlayCompleted
    //                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                     [NSNumber numberWithInteger:delta], @"PlayTime",
    //                                     nil]];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"FreePlay completed" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInteger:delta], @"PlayTime",
                                                      nil]];
    
    [self finalLogging];
    
    [g_soundMaster disableSliding];
    [g_soundMaster stopAllEffects];
    [g_soundMaster stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleEffectsTab:(id)sender
{
    [self.instrumentsAndEffectsVC displayEffects];
    [self switchMainContentControllerToVC:self.instrumentsAndEffectsVC];
    [self showArrow:_arrowEffects];
}

- (IBAction)toggleInstrumentsTab:(id)sender
{
    [self.instrumentsAndEffectsVC displayInstruments];
    [self switchMainContentControllerToVC:self.instrumentsAndEffectsVC];
    [self showArrow:_arrowInstruments];
}

- (IBAction)toggleVolumeView:(id)sender
{
    [_volumeVC colorTriangleIndicator:[UIColor colorWithRed:71/255.0 green:94/255.0 blue:69/255.0 alpha:1.0]];
    [self.mainContentView bringSubviewToFront:_volumeVC.view];
    [_volumeVC toggleView:YES];
}

- (IBAction)toggleLEDTab:(id)sender
{
    [self switchMainContentControllerToVC:self.lightsVC];
    [self showArrow:_arrowLights];
}

- (void)showArrow:(UIView*)arrow
{
    _arrowMenu.hidden = YES;
    _arrowLights.hidden = YES;
    _arrowEffects.hidden = YES;
    _arrowInstruments.hidden = YES;
    
    arrow.hidden = NO;
}

// Toggle between turning LEDs on/off to display a scale
// TODO: expand scale light functionality to multiple scales.
/*- (IBAction)toggleScaleLights:(id)sender
{
    
    [m_scaleSwitch setSelected:![m_scaleSwitch isSelected]];
    
    if ([m_scaleSwitch isSelected])
    {
        int stringOffset[] = {0, 5, 10, 15, 19, 24};
        // index into scale array
        int index = 1;
        
        // Turn on the LED for each string at a time, based on scale array
        for (int string = 1; string <= 6; string++)
        {
            int fret = m_ScaleArray[index] - stringOffset[string - 1];
            
            // Turn on LED for each fret position that should be on
            while (fret <= 16 )
            {
                [g_keysController turnOnLedAtPosition:KeysPositionMake(fret, string+1) withColor:KeysLedColorMake(0, 0, 3)];
                
                index++;
                fret = m_ScaleArray[index] - stringOffset[string - 1];
            }
            
            // find starting index for next string
            index = 1;
            fret = m_ScaleArray[index];
            while (fret <= stringOffset[string])
            {
                index++;
                fret = m_ScaleArray[index];
            }
        }
    }
    else
    {
        // Turn off all LEDs on the fret board
        [g_keysController turnOnLedAtPosition:KeysPositionMake(0, 0) withColor:KeysLedColorMake(0, 0, 0)];
    }
    
    // Telemetetry log
    if ( [m_scaleSwitch isSelected] )
    {
        
        //        [g_telemetryController logEvent:KeysFreePlayToggleFeature
        //                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        //                                         @"On", @"ScaleLights",
        //                                         nil]];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"FreePlay toggle feature" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               @"On", @"ScaleLights",
                                                               nil]];
        
        m_scaleTimeStart = [NSDate date];
        
    }
    else
    {
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_scaleTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
        
        //        [g_telemetryController logEvent:KeysFreePlayToggleFeature
        //                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        //                                         @"Off", @"ScaleLights",
        //                                         [NSNumber numberWithInteger:delta], @"PlayTime",
        //                                         nil]];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"FreePlay toggle feature" properties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               @"Off", @"ScaleLights",
                                                               [NSNumber numberWithInteger:delta], @"PlayTime",
                                                               nil]];
        
        m_scaleTimeStart = [NSDate date];
        
    }
    
    
}
 */

- (IBAction)toggleMenuTab:(id)sender
{
    
    [self switchMainContentControllerToVC:self.fpMenuVC];
    [self showArrow:_arrowMenu];
    
}


-(void) switchMainContentControllerToVC:(UIViewController *)newVC
{
    [_volumeVC closeView:YES];
    
    if (_currentMainContentVC ==  newVC)
    {
        // already on this view, do nothing
        return;
    }
    
    UIViewController *oldVC = _currentMainContentVC;
    
    [oldVC willMoveToParentViewController:nil];
    
    [self addChildViewController:newVC];
    
    [self transitionFromViewController:oldVC  toViewController:newVC duration:0.25
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:^(BOOL finished) {
                                [oldVC removeFromParentViewController];
                                [newVC didMoveToParentViewController:self];
                                _currentMainContentVC = newVC;
                            }];
}


#pragma mark - Misc
-(void) setToneToBWCutoff:(double)value
{
    //[g_soundMaster SetBWCutoff:value];
    //[g_audioController SetBWCutoff:sender.value];
}

-(void) positionChanged:(CGPoint)position forView:(XYInputView *)view
{
    // translate the normalized value the JamPad position to a range
    // in [min, max] for the respective parameter
    /*
     Parameter *p = &(m_selectedEffect->getPrimaryParam());
     float min = p->getMin();
     float max = p->getMax();
     float newVal = position.x*(max - min) + min;
     m_selectedEffect->setPrimaryParam(newVal);
     
     p = &(m_selectedEffect->getSecondaryParam());
     min = p->getMin();
     max = p->getMax();
     newVal = position.y*(max - min) + min;
     m_selectedEffect->setSecondaryParam(newVal);
     */
}

- (void)didChangeAudioRoute:(NSNotification *) notification
{
    BOOL speakerRoute = [[[notification userInfo] objectForKey:@"isRouteSpeaker"] boolValue];
    
    [self audioRouteChanged:speakerRoute];
}

-(void) audioRouteChanged:(BOOL)routeIsSpeaker
{
    m_bSpeakerRoute = routeIsSpeaker;
    
    if (m_bSpeakerRoute){
        
        [_volumeButton setImage:[UIImage imageNamed:@"SpeakerIcon"] forState:UIControlStateNormal];
        [_volumeButton setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 3, 0)];
        
        [g_soundMaster routeToSpeaker];
        [_fpMenuVC setAudioSwitchToSpeaker];
        
    }else{
        [_volumeButton setImage:[UIImage imageNamed:@"AuxIcon"] forState:UIControlStateNormal];
        [_volumeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [g_soundMaster routeToDefault];
        [_fpMenuVC setAudioSwitchToDefault];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:m_bSpeakerRoute forKey:@"RouteToSpeaker"];
    [settings synchronize];
}

@end