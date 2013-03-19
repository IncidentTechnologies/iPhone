//
//  FreePlayController.m
//  gTarPlay
//
//  Created by Marty Greenia on 3/15/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import "FreePlayController.h"
#import "TransparentAreaView.h"
#import "CustomComboBox.h"
#import "RGBColor.h"
#import "Harmonizer.h"

#import <MediaPlayer/MediaPlayer.h>

#import <AudioController/Effect.h>
#import <AudioController/Parameter.h>

#import <GtarController/GtarController.h>

#import <gTarAppCore/AppCore.h>
#import <gTarAppCore/TelemetryController.h>

extern GtarController * g_gtarController;
extern AudioController * g_audioController;
extern TelemetryController * g_telemetryController;

@implementation FreePlayController

@synthesize m_jamPad;
@synthesize m_wetSlider;
@synthesize m_currentEffectName;
@synthesize m_effectsTab;
@synthesize m_volumeView;
@synthesize m_lineOutVolumeSlider;
@synthesize m_audioRouteSwitch;
@synthesize m_activityIndicatorView;
@synthesize m_connectingView;
@synthesize m_xParamLabel;
@synthesize m_yParamLabel;
@synthesize m_effectsTabButton;
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
@synthesize m_instrumentsTabButton;
@synthesize m_instrumentsScroll;
@synthesize m_menuTab;
@synthesize m_menuTabButton;
@synthesize m_toneSlider;
@synthesize m_bSpeakerRoute;
@synthesize m_LEDTab;
@synthesize m_LEDTabButton;
@synthesize m_LEDGeneralSurface;
@synthesize m_LEDFretSurface;
@synthesize m_LEDStringSurface;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
        
        // Custom initialization
        
        // disable idle sleeping
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // Properly account for play time
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        m_playTimeStart = [[NSDate date] retain];
        m_audioRouteTimeStart = [[NSDate date] retain];
        m_instrumentTimeStart = [[NSDate date] retain];
        m_scaleTimeStart = [[NSDate date] retain];
        
        for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
        {
            m_effectTimeStart[effect] = [[NSDate date] retain];
        }

        m_playTimeAdjustment = 0;
        
        // Create audio controller
        g_audioController.m_delegate = self;
        //[g_audioController initializeAUGraph];
        [g_audioController startAUGraph];
        
        RGBColor *white = [[[RGBColor alloc] initWithRed:3 Green:3 Blue:3] autorelease];
        RGBColor *red = [[[RGBColor alloc] initWithRed:3 Green:0 Blue:0] autorelease];
        RGBColor *green = [[[RGBColor alloc] initWithRed:0 Green:3 Blue:0] autorelease];
        RGBColor *blue = [[[RGBColor alloc] initWithRed:0 Green:0 Blue:3] autorelease];
        RGBColor *cyan = [[[RGBColor alloc] initWithRed:0 Green:3 Blue:3] autorelease];
        RGBColor *magenta = [[[RGBColor alloc] initWithRed:3 Green:0 Blue:3] autorelease];
        RGBColor *yellow = [[[RGBColor alloc] initWithRed:3 Green:3 Blue:0] autorelease];
        RGBColor *orange = [[[RGBColor alloc] initWithRed:3 Green:1 Blue:0] autorelease];
        
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
    
    [g_gtarController removeObserver:self];
    
    [m_harmonizer release];
    [m_volumeView release];
    [m_activityIndicatorView release];
    [m_connectingView release];
    [m_jamPad release];
    [m_wetSlider release];
    [m_effectsTab release];
    [m_effectsTabButton release];
    [m_effect1OnOff release];
    [m_effect2OnOff release];
    [m_effect3OnOff release];
    [m_effect4OnOff release];
    [m_effect1Select release];
    [m_effect2Select release];
    [m_effect3Select release];
    [m_effect4Select release];
    [m_effect1Name release];
    [m_effect2Name release];
    [m_effect3Name release];
    [m_effect4Name release];
    [m_currentEffectName release];
    [m_instrumentsTab release];
    [m_instrumentsTabButton release];
    [m_menuTabButton release];
    [m_menuTab release];
    [m_toneSlider release];
    
    [g_audioController stopAUGraph];
    [g_audioController reset];
    
    [m_colors release];
    [m_instrumentsScroll release];
    [m_lineOutVolumeSlider release];
    [m_LEDTab release];
    [m_LEDGeneralSurface release];
    [m_LEDFretSurface release];
    [m_LEDStringSurface release];
    [m_LEDAllSurface release];
    
    [m_LEDTabButton release];
    
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }

    [m_audioRouteSwitch release];
    [m_scaleSwitch release];
    
    [m_playTimeStart release];
    [m_audioRouteTimeStart release];
    [m_instrumentTimeStart release];
    [m_scaleTimeStart release];
    
    // Unregister the AudioController Delegate
    g_audioController.m_delegate = nil;
    
    // Turn off all LEDs
    [g_gtarController turnOffAllLeds];

	[super dealloc];	
}

- (void)viewDidLoad
{

    [super viewDidLoad];

    // images for slider
    UIImage *sliderTrackMinImage = [[UIImage imageNamed: @"SliderEndMin.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
    UIImage *sliderTrackMaxImage = [[UIImage imageNamed: @"SliderEndMax.png"] stretchableImageWithLeftCapWidth: 1 topCapHeight: 0];

    // Attach a volume view
    m_volumeView.backgroundColor = [UIColor clearColor];
    MPVolumeView * myVolumeView = [[[MPVolumeView alloc] initWithFrame:m_volumeView.bounds] autorelease];
    NSArray *subViews = myVolumeView.subviews;
    
    for (id current in subViews)
    {
        if ([current isKindOfClass:[UISlider class]])
        {
            UISlider *slider = (UISlider*) current;
            [slider setMinimumTrackImage: sliderTrackMinImage forState: UIControlStateNormal];
            [slider setMaximumTrackImage: sliderTrackMaxImage forState: UIControlStateNormal];
            [slider setThumbImage:[UIImage imageNamed: @"Knob_BlueLine.png"] forState:UIControlStateNormal];
        }
    }
    
    [myVolumeView setShowsRouteButton:NO];
	[m_volumeView addSubview:myVolumeView];
    [myVolumeView sizeToFit];
    
    // For some reason, releasing this crashes the app
//    [myVolumeView release];
    
    // centered in the x dimension (and y dimension, we change that in a moment)
    m_effectsTab.center = self.view.center;
    m_instrumentsTab.center = self.view.center;
    m_menuTab.center = self.view.center;
    m_LEDTab.center = self.view.center;
    
    CGRect smallTabFrame = m_effectsTab.frame;
    CGRect menuTabFrame = m_menuTab.frame;
    CGRect largeTabFrame = m_LEDTab.frame;
    
    smallTabFrame.origin.x = -105; 
    menuTabFrame.origin.x = -328; 
    largeTabFrame.origin.x = -446; 
    // move tab up to align with wet/dry frame
    smallTabFrame.origin.y = 0;
    largeTabFrame.origin.y = 0;
    menuTabFrame.origin.y = 0;
    [m_effectsTab setFrame:smallTabFrame];
    [m_instrumentsTab setFrame:smallTabFrame];
    [m_menuTab setFrame:menuTabFrame];
    [m_LEDTab setFrame:largeTabFrame];
    [m_effectsTabButton setSelected:NO];
    [m_instrumentsTabButton setSelected:NO];
    [m_menuTabButton setSelected:NO];
    [m_LEDTabButton setSelected:NO];
    
    [m_effectsTab addTransparentAreaWithXmin:(m_instrumentsTab.frame.size.width - 30) xMax:m_effectsTab.frame.size.width yMin:80 yMax:m_effectsTab.frame.size.height]; 
    [m_instrumentsTab addTransparentAreaWithXmin:(m_instrumentsTab.frame.size.width - 30) xMax:m_instrumentsTab.frame.size.width yMin:0 yMax:80];
    [m_instrumentsTab addTransparentAreaWithXmin:(m_instrumentsTab.frame.size.width - 30) xMax:m_instrumentsTab.frame.size.width yMin:155 yMax:m_instrumentsTab.frame.size.height];
    [m_LEDTab addTransparentAreaWithXmin:m_LEDTab.frame.size.width - 30 xMax:m_LEDTab.frame.size.width yMin:0 yMax:155];
    [m_LEDTab addTransparentAreaWithXmin:m_LEDTab.frame.size.width - 30 xMax:m_LEDTab.frame.size.width yMin:225 yMax:m_LEDTab.frame.size.height];
    [m_menuTab addTransparentAreaWithXmin:(m_menuTab.frame.size.width - 30) xMax:m_menuTab.frame.size.width yMin:0 yMax:225];

    [self.view addSubview:m_effectsTab];
    [self.view addSubview:m_instrumentsTab];
    [self.view addSubview:m_LEDTab];
    [self.view addSubview:m_menuTab];
    
    [m_instrumentsScroll setBackgroundColor:[UIColor clearColor]];
    NSArray *ar = [g_audioController getInstrumentNames];
    NSMutableArray *instrumentScrollText = [ar mutableCopy];
    [instrumentScrollText insertObject:@"Guitars"  atIndex:0];
    [instrumentScrollText insertObject:@"Keys" atIndex:4];
    [instrumentScrollText insertObject:@"Synths" atIndex:7];
    [m_instrumentsScroll populateWithText:instrumentScrollText];
    [m_instrumentsScroll makeHeaderEntryAtIndex:0];
    [m_instrumentsScroll makeHeaderEntryAtIndex:4];
    [m_instrumentsScroll makeHeaderEntryAtIndex:7];
    // TODO: snap to the currently selected sample, not just the first. Currently we
    // can get the current sample index from the audioController, but this number will
    // not match directly the index in the instruments scroll, due to the extra header
    // entries
    [m_instrumentsScroll snapToIndex:0];
    
    [instrumentScrollText release];
    
    m_volumeView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    m_effectsTabButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    m_instrumentsTabButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    m_menuTabButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    m_LEDTabButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    
    // Set up effects tab. Set image to display when button is "selected"
    [m_effect1OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect1Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    [m_effect2OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect2Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    [m_effect3OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect3Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];
    
    [m_effect4OnOff setImage:[UIImage imageNamed:@"EffectOnButton.png"] forState:UIControlStateSelected];
    [m_effect4Select setImage:[UIImage imageNamed:@"EffectSelectOnButton.png"] forState:UIControlStateSelected];

    // set effects name
    m_effects = [g_audioController GetEffects];
    [m_effect1Name setText:[[NSString stringWithCString:m_effects[0]->getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    [m_effect2Name setText:[[NSString stringWithCString:m_effects[1]->getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    [m_effect3Name setText:[[NSString stringWithCString:m_effects[2]->getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    [m_effect4Name setText:[[NSString stringWithCString:m_effects[3]->getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    
    [m_effect1Select setSelected:YES];
    
    // set custom images for sliders
    UIImage *sliderKnobImage = [UIImage imageNamed: @"Knob_BlueLine.png"];
    
    [m_wetSlider setMinimumTrackImage: sliderTrackMinImage forState: UIControlStateNormal];
    [m_wetSlider setMaximumTrackImage: sliderTrackMaxImage forState: UIControlStateNormal];
    [m_wetSlider setThumbImage: [UIImage imageNamed: @"SliderKnob.png"] forState:UIControlStateNormal];
    
    [m_toneSlider setMinimumTrackImage: sliderTrackMinImage forState: UIControlStateNormal];
    [m_toneSlider setMaximumTrackImage: sliderTrackMaxImage forState: UIControlStateNormal];
    [m_toneSlider setThumbImage: sliderKnobImage forState:UIControlStateNormal];
    
    [m_lineOutVolumeSlider setMinimumTrackImage: sliderTrackMinImage forState:UIControlStateNormal];
    [m_lineOutVolumeSlider setMaximumTrackImage: sliderTrackMaxImage forState:UIControlStateNormal];
    [m_lineOutVolumeSlider setThumbImage: sliderKnobImage forState:UIControlStateNormal];
    
    m_wetSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    m_toneSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    m_lineOutVolumeSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    
    // Set up menu tab
    // Get audio route setting and move route knob appropriately
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings synchronize];
    // temporarily set the bool to the opposite of the actual value
    m_bSpeakerRoute = ![settings boolForKey:@"RouteToSpeaker"];
    // toogle the route so that its what we actually want
    [self toggleAudioRoute:self];
    m_bSpeakerRoute = !m_bSpeakerRoute;
    [self audioRouteChanged:m_bSpeakerRoute];
    
    // To avoid displaying the wrong image when the switch selected and being pressed,
    // we must set an image for the selected AND highlighted state (UIControlState
    // is a bit map), besides having set the image for selected state in IB
    [m_audioRouteSwitch setImage:[UIImage imageNamed:@"SwitchUp.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [m_scaleSwitch setImage:[UIImage imageNamed:@"SwitchUp.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
    
    // Setup Jam Pad
    //rotate y label and dry/wet slider 90 degrees counterclockwise
    m_yParamLabel.transform = CGAffineTransformMakeRotation(-M_PI_2 );
    // Flip y axis of JamPad so that +y points upwards instead of down
    m_jamPad.transform = CGAffineTransformMakeScale(1, -1);
    m_jamPad.m_delegate = self;
    // Initialize jam pad with first effect in list
    [self setupJamPadWithEffectAtIndex:0];
    
    // Setup LED light tab
    [m_LEDGeneralSurface setBackgroundColor:[UIColor clearColor]];
    [m_LEDAllSurface setBackgroundColor:[UIColor clearColor]];
    [m_LEDFretSurface setBackgroundColor:[UIColor clearColor]];
    [m_LEDStringSurface setBackgroundColor:[UIColor clearColor]];
    m_LEDGeneralSurface.transform = CGAffineTransformMakeScale(1, -1);
    m_LEDStringSurface.transform = CGAffineTransformMakeScale(1, -1);
    
    m_lastLEDTouch = CGPointMake(-1, -1);
    m_LEDMode = LEDModeTrail;
    m_LEDShape = LEDShapeDot;
    m_LEDLoop = NUM_LEDLoop_ENTRIES;
    
    // Start activity spinner while we connect to gtar
//    if ( g_gtarController.m_connected == NO )
//    {
//        //[self.view addSubview:m_connectingView];
//    }
    
    [g_gtarController addObserver:self];
    
}

- (void)viewDidUnload
{
    [self setM_jamPad:nil];
    [self setM_wetSlider:nil];
    
    self.m_volumeView = nil;
    self.m_activityIndicatorView = nil;
    self.m_connectingView = nil;

    [self setM_effectsTab:nil];
    [self setM_effectsTabButton:nil];
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
    [self setM_menuTabButton:nil];
    [self setM_menuTab:nil];
    [self setM_toneSlider:nil];
    [self setM_instrumentsScroll:nil];
    [self setM_lineOutVolumeSlider:nil];
    [self setM_LEDTab:nil];
    [self setM_LEDGeneralSurface:nil];
    [self setM_LEDFretSurface:nil];
    [self setM_LEDStringSurface:nil];
    [self setM_LEDAllSurface:nil];
    
    [self setM_LEDTabButton:nil];
    
    [self setM_audioRouteSwitch:nil];
    [self setM_scaleSwitch:nil];
    [super viewDidUnload];
}

- (void)handleResignActive
{
    m_playTimeAdjustment += [[NSDate date] timeIntervalSince1970] - [m_playTimeStart timeIntervalSince1970];
}

- (void)handleBecomeActive
{
    [m_playTimeStart release];
    [m_audioRouteTimeStart release];
    [m_instrumentTimeStart release];
    [m_scaleTimeStart release];
    
    for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
    {
        [m_effectTimeStart[effect] release];
    }
    
    m_playTimeStart = [[NSDate date] retain];
    m_audioRouteTimeStart = [[NSDate date] retain];
    m_instrumentTimeStart = [[NSDate date] retain];
    m_scaleTimeStart = [[NSDate date] retain];
    
    for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
    {
        m_effectTimeStart[effect] = [[NSDate date] retain];
    }
}

- (void)finalLogging
{
    
    // Log relevant things before exiting
    NSString* route = m_bSpeakerRoute ? @"Speaker" : @"Aux";
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_audioRouteTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarFreePlayToggleFeature
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     route, @"AudioRoute",
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     nil]];
    
    NSString *instrumentName = [m_instrumentsScroll getNameAtIndex:[g_audioController getCurrentSamplePackIndex]];
    
    delta = [[NSDate date] timeIntervalSince1970] - [m_instrumentTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarFreePlayToggleFeature
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     instrumentName, @"Instrument",
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     nil]];
    
    UIButton *effectButtons[FREE_PLAY_EFFECT_COUNT] = { m_effect1OnOff, m_effect2OnOff, m_effect3OnOff, m_effect4OnOff };
    
    for ( NSInteger effect = 0; effect < FREE_PLAY_EFFECT_COUNT; effect++ )
    {
        NSString* name = [NSString stringWithCString:m_effects[effect]->getName().c_str() encoding:[NSString defaultCStringEncoding]];
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_effectTimeStart[effect] timeIntervalSince1970] + m_playTimeAdjustment;
        
        if ( [effectButtons[effect] isSelected] == YES )
        {
            [g_telemetryController logEvent:GtarFreePlayToggleFeature
                             withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                             @"Off", name,
                                             [NSNumber numberWithInteger:delta], @"PlayTime",
                                             nil]];
        }
        
        [m_effectTimeStart[effect] release];
    }
    
}

#pragma mark - Main event loop

//- (void)mainEventLoop
//{
//
//}

#pragma mark - GtarObserverProtocol

- (void)gtarFretDown:(GtarPosition)position
{
    [g_audioController FretDown:position.fret onString:position.string - 1];
}

- (void)gtarFretUp:(GtarPosition)position
{
    [g_audioController FretUp:position.fret onString:position.string - 1];
}

- (void)gtarNoteOn:(GtarPluck)pluck
{
    GtarFret fret = pluck.position.fret;
    GtarString str = pluck.position.string;
    
    GtarPluckVelocity velocity = pluck.velocity;
    
    // zero base the string
    str--;
    
    if (0 !=  m_harmonizerValue)
    {        
        NSDictionary *harmonizedValues = [m_harmonizer getHarmonizedValuesForString:str andFret:fret];
        
        str = [[harmonizedValues valueForKey:@"String"] intValue];
        fret = [[harmonizedValues valueForKey:@"Fret"] intValue];
    }
    
    [g_audioController PluckString:str atFret:fret withAmplitude:(float)velocity/127.0f];
}

- (void)gtarNoteOff:(GtarPosition)position
{
    [g_audioController NoteOffAtString:position.string - 1 andFret:position.fret];
}

- (void)gtarConnected
{
    
//    [m_activityIndicatorView stopAnimating];
    [m_connectingView removeFromSuperview];
    
    [g_gtarController turnOffAllEffects];
    [g_gtarController turnOffAllLeds];
    [g_gtarController setMinimumInterarrivalTime:0.05f];
    
    [self startMainEventLoop];
    
}

- (void)gtarDisconnected
{
    
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_playTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarFreePlayDisconnected
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     nil]];
    
    [self finalLogging];

    [self.navigationController popViewControllerAnimated:YES];

}


- (void) setupJamPadWithEffectAtIndex:(int)index
{
    m_selectedEffect = m_effects[index];
    [m_currentEffectName setText:[[NSString stringWithCString:m_selectedEffect->getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    Parameter &primary = m_selectedEffect->getPrimaryParam();
    Parameter &secondary = m_selectedEffect->getSecondaryParam();
    [m_xParamLabel setText:[[NSString stringWithCString:primary.getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    [m_yParamLabel setText:[[NSString stringWithCString:secondary.getName().c_str() encoding:[NSString defaultCStringEncoding]] uppercaseString]];
    // set inital position of JamPad, set normalized value
    float x = (primary.getValue() - primary.getMin()) / (primary.getMax() - primary.getMin());
    float y = (secondary.getValue() - secondary.getMin()) / (secondary.getMax() - primary.getMin());
    [m_jamPad setNormalizedPosition:CGPointMake(x, y)];
    // set wet slider
    [m_wetSlider setValue:m_selectedEffect->GetWet()];
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
    else if (touchedView == m_LEDFretSurface)
    {
        m_LEDTouchArea = LEDTouchFret;
    }
    else if (touchedView == m_LEDStringSurface)
    {
        m_LEDTouchArea = LEDTouchString;
    }
    else if (touchedView == m_LEDAllSurface)
    {
        m_LEDTouchArea = LEDTouchAll;
    }
    else
    {
#ifdef Debug_BUILD
        CGPoint point = [touch locationInView:self.view];
        
        int str = point.x / (480/GTAR_GUITAR_STRING_COUNT);
        if ( str >= GTAR_GUITAR_STRING_COUNT ) str = (GTAR_GUITAR_STRING_COUNT-1);
        
        int fret = point.y / (320/GTAR_GUITAR_FRET_COUNT);
        if ( fret >= GTAR_GUITAR_FRET_COUNT ) fret = (GTAR_GUITAR_FRET_COUNT-1);
        
        GtarPluck pluck;
        pluck.velocity = GtarMaxPluckVelocity;
        pluck.position.fret = (GTAR_GUITAR_FRET_COUNT-fret-1);
        pluck.position.string = (str+1);
        
        [self gtarNoteOn:pluck];
#endif
        m_LEDTouchArea = LEDTouchNone;
        return;
    }
    
    [self touchedLEDs:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Only take action if the touch is inside a designated LED area
    if (LEDTouchNone != m_LEDTouchArea)
    {
        [self touchedLEDs:touches];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Check that last touchBegan was inside an LED touch area
    if (LEDTouchNone != m_LEDTouchArea)
    {
        // Turn off last LED touch point when finger touch ends
        [self turnOffLED:m_lastLEDTouch.x AndFret:m_lastLEDTouch.y];
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
        CGPoint stringFret = [self getFretPositionFromTouch:touch];
        
        string = stringFret.x;
        fret = stringFret.y;
        if (string < 0 || fret < 0)
        {
            NSLog(@"touchedLED: Invalid fret & string. fret:%d string:%d", fret, string);
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
            
            string = (point.y / (m_LEDGeneralSurface.frame.size.height/GTAR_GUITAR_STRING_COUNT)) + 1;
            if (string < 1)
            {
                string = 1;
            }
            else if ( string > GTAR_GUITAR_STRING_COUNT)
            {
                string = (GTAR_GUITAR_STRING_COUNT);
            }
            
            fret = (point.x / (m_LEDGeneralSurface.frame.size.width/GTAR_GUITAR_FRET_COUNT)) + 1;
            if (fret < 1)
            {
                fret = 1;
            }
            else if ( fret > GTAR_GUITAR_FRET_COUNT ) 
            {
                fret = (GTAR_GUITAR_FRET_COUNT);
            }
            
            break;
            
        case LEDTouchFret:
            point = [touch locationInView:self.m_LEDFretSurface];
            
            fret = (point.x / (m_LEDFretSurface.frame.size.width/GTAR_GUITAR_FRET_COUNT)) + 1;
            if ( fret < 1 ) 
            {
                fret = 1;
            }
            else if ( fret > GTAR_GUITAR_FRET_COUNT ) 
            {
                fret = (GTAR_GUITAR_FRET_COUNT);
            }
            
            // Light up this fret across all strings
            string = 0;
            
            break;
            
        case LEDTouchString:
            point = [touch locationInView:self.m_LEDStringSurface];
            
            string = (point.y / (m_LEDStringSurface.frame.size.height/GTAR_GUITAR_STRING_COUNT)) + 1;
            if (string < 1)
            {
                string = 1;
            }
            else if ( string > GTAR_GUITAR_STRING_COUNT)
            {
                string = (GTAR_GUITAR_STRING_COUNT);
            }
            
            // Light up this string on all frets
            fret = 0;
            
            break;
            
        case LEDTouchAll:
            // Light up the entire fret board
            string = 0;
            fret = 0;
            
            break;
            
        default:
            NSLog(@"Invalid LEDTouchArea: %d", m_LEDTouchArea);
            break;
    }
    
    return CGPointMake(string, fret);
}

// turns on the LED at the specified string and fret based on the current
// m_LEDShape value
- (void) turnONLED:(int)string AndFret:(int)fret WithColorRed:(int)red AndGreen:(int)green AndBlue:(int)blue
{
    // Regardless of shape we will turn on the touch point.
    [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string)
                                withColor:GtarLedColorMake(red, green, blue)];
    
    switch (m_LEDShape)
    {
        case LEDShapeCross:
            // Turn on adjacent leds to make a + shape
            if (string + 1 < GTAR_GUITAR_STRING_COUNT + 1)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string+1)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            if (string - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string-1)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            if (fret + 1 < GTAR_GUITAR_FRET_COUNT + 1)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, string)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            if (fret - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret-1, string)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            
            break;
            
        case LEDShapeSquare:
            
            if (string + 1 < GTAR_GUITAR_STRING_COUNT + 1)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string+1)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            if (fret - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret-1, string)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            if (string + 1 < GTAR_GUITAR_STRING_COUNT + 1 && fret - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret-1, string+1)
                                            withColor:GtarLedColorMake(red, green, blue)];
            }
            
            break;
            
        default:
            break;
    }
}

// handles turning off LEDs based on the current m_LEDMode
- (void) turnOffLED:(int)string AndFret:(int)fret
{
    if (LEDModeSingle == m_LEDMode)
    {
        [self turnOffLEDByShape:string AndFret:fret];
    }
    else if (LEDModeTrail == m_LEDMode)
    {
        // Turn off LED after a delay to create a trailing effect
        NSArray *params = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:string],
                           [NSNumber numberWithInt:fret],
                           nil];
        
        [self performSelector:@selector(turnOffLEDDelayed:) withObject:params afterDelay:0.4];
    }
    
}

// a method in a form that can be used as a selector, i.e. has a single
// paramter that contains the string and fret positions to turn off.
- (void) turnOffLEDDelayed:(NSArray *)params
{
    [[params objectAtIndex:0] intValue];
    [self turnOffLEDByShape:[[params objectAtIndex:0] intValue]
                    AndFret:[[params objectAtIndex:1] intValue]];
}

// turns off the LED at the specified string and fret based on the current
// m_LEDShape value
- (void) turnOffLEDByShape:(int)string AndFret:(int)fret
{
    // Regardless of shape we will turn off the touch point.
    [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string)
                                withColor:GtarLedColorMake(0, 0, 0)];
    
    switch (m_LEDShape)
    {
        case LEDShapeCross:
            // Turn on adjacent leds to make a + shape
            if (string + 1 < GTAR_GUITAR_STRING_COUNT + 1)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string+1)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            if (string - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string-1)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            if (fret + 1 < GTAR_GUITAR_FRET_COUNT + 1)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret+1, string)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            if (fret - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret-1, string)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            
            break;
            
        case LEDShapeSquare:
            
            if (string + 1 < GTAR_GUITAR_STRING_COUNT + 1)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string+1)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            if (fret - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret-1, string)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            if (string + 1 < GTAR_GUITAR_STRING_COUNT + 1 && fret - 1 > 0)
            {
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret-1, string+1)
                                            withColor:GtarLedColorMake(0, 0, 0)];
            }
            break;
            
        default:
            break;
    }
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
    [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                withColor:GtarLedColorMake(0, 0, 0)];
}

- (IBAction)autoPlayLEDs:(id)sender
{
    if (++m_LEDLoop >= NUM_LEDLoop_ENTRIES)
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

// turns on the entire fretboard with a different color for each
// fret position, the colors are rotating fromt the colors array
- (void) turnOnAllLEDRandom
{
    RGBColor *color;
    for (int fret = 1; fret <= GTAR_GUITAR_FRET_COUNT; fret++)
    {
        for (int string = 1; string <= GTAR_GUITAR_STRING_COUNT; string++)
        {
            m_currentColorIndex = arc4random_uniform([m_colors count]);
            
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
        }
    }
}

- (void) LEDRainbow
{    
    RGBColor *color;
    for (int fret = 1; fret <= GTAR_GUITAR_FRET_COUNT; fret++)
    {
        for (int string = 1; string <= GTAR_GUITAR_STRING_COUNT; string++)
        {
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++m_currentColorIndex >= [m_colors count])
            {
                // loop starting at 1, skip 0 (white) for the full fretboard random display
                m_currentColorIndex = 1;
            }
        }
    }
}

- (void) LEDSquarePatches
{
    RGBColor *color;
    for (int fret = 1; fret <= GTAR_GUITAR_FRET_COUNT; fret = fret+2)
    {
        for (int string = 1; string <= GTAR_GUITAR_STRING_COUNT; string=string+2)
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
}

- (void) LEDLgSquarePatches
{    
    RGBColor *color;
    for (int fret = 1; fret <= GTAR_GUITAR_FRET_COUNT; fret = fret+3)
    {
        for (int string = 1; string <= GTAR_GUITAR_STRING_COUNT; string=string+3)
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
}
                      
- (void) animateLEDs:(NSTimer*)theTimer
{
    RGBColor *color;
    
    switch (m_LEDLoop)
    {
        case LEDLoopSolid:
            
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            [self turnONLED:0 AndFret:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++m_currentColorIndex >= [m_colors count])
            {
                m_currentColorIndex = 0;
            }
            
            break;
            
        case LEDLoopUp:
            
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            int static fret = GTAR_GUITAR_FRET_COUNT;

            [self turnONLED:0 AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (--fret < 1)
            {
                fret = 16;
                if (++m_currentColorIndex >= [m_colors count])
                {
                    m_currentColorIndex = 0;
                }
            }
            
            break;
            
        case LEDLoopSide:
            
            color = [m_colors objectAtIndex:m_currentColorIndex];
            
            int static string = 1;
            
            [self turnONLED:string AndFret:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++string > GTAR_GUITAR_STRING_COUNT)
            {
                string = 1;
                if (++m_currentColorIndex >= [m_colors count])
                {
                    m_currentColorIndex = 0;
                }
            }
            
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
    m_selectedEffect->SetWet([m_wetSlider value]);
}


#pragma mark - Button clicked handlers

- (IBAction)toggleEffectOnOff:(id)sender
{
    // get effect number, this tag is manually set in Interface Builder for each button
    int effectNum = [sender tag];
    
    // toggle senders selected state
    [sender setSelected:![sender isSelected]];
    
    // set pass through of effect based on new state
    if ([sender isSelected])
    {
        m_effects[effectNum]->SetPassThru(false);
        
        // Telemetetry log
        NSString* name = [NSString stringWithCString:m_effects[effectNum]->getName().c_str() encoding:[NSString defaultCStringEncoding]];
        
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"On", name,
                                         nil]];
        
        [m_effectTimeStart[effectNum] release];
        m_effectTimeStart[effectNum] = [[NSDate date] retain];
        
    }
    else
    {

        m_effects[effectNum]->SetPassThru(true);
        
        // Telemetetry log
        NSString* name = [NSString stringWithCString:m_effects[effectNum]->getName().c_str() encoding:[NSString defaultCStringEncoding]];
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_effectTimeStart[effectNum] timeIntervalSince1970] + m_playTimeAdjustment;
        
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"Off", name,
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         nil]];
        
        [m_effectTimeStart[effectNum] release];
        m_effectTimeStart[effectNum] = [[NSDate date] retain];
        
    }
    
}

- (IBAction)selectEffect:(id)sender
{
    // get effect number, this tag is manually set in Interface Builder for each button
    int effectNum = [sender tag];
    
    // unselect all effects
    [m_effect1Select setSelected:NO];
    [m_effect2Select setSelected:NO];
    [m_effect3Select setSelected:NO];
    [m_effect4Select setSelected:NO];
    // set only this button as selected
    [sender setSelected:YES];
    
    [self setupJamPadWithEffectAtIndex:effectNum];
}

- (IBAction)setTone:(id)sender
{
    [g_audioController SetBWCutoff:[m_toneSlider value]];
}

- (IBAction)toggleAudioRoute:(id)sender
{
    if (m_bSpeakerRoute)
    {
        [g_audioController RouteAudioToDefault];
    }
    else
    {
        [g_audioController RouteAudioToSpeaker];
    }
}

- (IBAction)setLineoutGain:(id)sender
{
    [g_audioController setM_volumeGain:[m_lineOutVolumeSlider value]];
}

- (IBAction)instrumentSelected:(id)sender
{
    
    NSString *instrumentName = [m_instrumentsScroll getNameAtIndex:[g_audioController getCurrentSamplePackIndex]];
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_instrumentTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    // Avoid the first setting
    if ( delta > 0 )
    {
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         instrumentName, @"Instrument",
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         nil]];
        
        [m_instrumentTimeStart release];
        m_instrumentTimeStart = [[NSDate date] retain];
    }
    
    NSString *sampleName = [m_instrumentsScroll getNameAtIndex:[sender m_selectedIndex]];
    [m_instrumentsScroll flickerSelectedItem];
    [g_audioController setSamplePackWithName:sampleName withSelector:@selector(samplerFinishedLoadingCB:) andOwner:self];
}

- (void) samplerFinishedLoadingCB:(NSNumber*)result
{
    if ([result boolValue])
    {
        [g_audioController ClearOutEffects];
        [g_audioController startAUGraph];
        [m_instrumentsScroll stopFlicker];
    }
}

- (IBAction)backButtonClicked:(id)sender
{   
    if (m_LEDTimer != nil)
    {
        [m_LEDTimer invalidate];
        m_LEDTimer = nil;
    }
    
    NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_playTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
    [g_telemetryController logEvent:GtarFreePlayCompleted
                     withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:delta], @"PlayTime",
                                     nil]];
    [self finalLogging];
     
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleEffectsTab:(id)sender
{
    // First toggle selected state
    [m_effectsTabButton setSelected:![m_effectsTabButton isSelected]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    // Then perform action based on new state
    if ([m_effectsTabButton isSelected])
    {
        // open tab
        m_effectsTab.transform = CGAffineTransformMakeTranslation(-1 * m_effectsTab.frame.origin.x, 0);
        [self.view bringSubviewToFront:m_effectsTab];
    }
    else
    {
        // close tab
        m_effectsTab.transform = CGAffineTransformIdentity;
    }
    
    [UIView commitAnimations];
}

- (IBAction)toggleInstrumentsTab:(id)sender
{
    // First toggle selected state
    [m_instrumentsTabButton setSelected:![m_instrumentsTabButton isSelected]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    // Then perform action based on new state
    if ([m_instrumentsTabButton isSelected])
    {
        // open tab
        m_instrumentsTab.transform = CGAffineTransformMakeTranslation(-1 * m_instrumentsTab.frame.origin.x, 0);
        [self.view bringSubviewToFront:m_instrumentsTab];
    }
    else
    {
        m_instrumentsTab.transform = CGAffineTransformIdentity;
    }
    
    [UIView commitAnimations];
}

- (IBAction)toggleLEDTab:(id)sender
{
    // First toggle selected state
    [m_LEDTabButton setSelected:![m_LEDTabButton isSelected]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    // Then perform action based on new state
    if ([m_LEDTabButton isSelected])
    {
        // open tab
        m_LEDTab.transform = CGAffineTransformMakeTranslation(-1 * m_LEDTab.frame.origin.x, 0);
        [self.view bringSubviewToFront:m_LEDTab];
    }
    else
    {
        // close tab
        m_LEDTab.transform = CGAffineTransformIdentity;
    }
    
    [UIView commitAnimations];
}

// Toggle between turning LEDs on/off to display a scale
// TODO: expand scale light functionality to multiple scales.
- (IBAction)toggleScaleLights:(id)sender
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
                [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string+1)
                                            withColor:GtarLedColorMake(0, 0, 3)];
                
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
        [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                    withColor:GtarLedColorMake(0, 0, 0)];
    }
    
    // Telemetetry log
    if ( [m_scaleSwitch isSelected] )
    {
        
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"On", @"ScaleLights",
                                         nil]];
        
        [m_scaleTimeStart release];
        m_scaleTimeStart = [[NSDate date] retain];
        
    }
    else
    {
        
        NSInteger delta = [[NSDate date] timeIntervalSince1970] - [m_scaleTimeStart timeIntervalSince1970] + m_playTimeAdjustment;
    
        [g_telemetryController logEvent:GtarFreePlayToggleFeature
                         withDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                         @"Off", @"ScaleLights",
                                         [NSNumber numberWithInteger:delta], @"PlayTime",
                                         nil]];
        
        [m_scaleTimeStart release];
        m_scaleTimeStart = [[NSDate date] retain];
        
    }
    
    
}

- (IBAction)toggleMenuTab:(id)sender
{
    // First toggle selected state
    [m_menuTabButton setSelected:![m_menuTabButton isSelected]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.7];
    // Then perform action based on new state
    if ([m_menuTabButton isSelected])
    {
        // open tab 
        m_menuTab.transform = CGAffineTransformMakeTranslation(-1 * m_menuTab.frame.origin.x, 0);
        [self.view bringSubviewToFront:m_menuTab];
    }
    else
    {
        // close tab
        m_menuTab.transform = CGAffineTransformIdentity;
    }
        
    [UIView commitAnimations];
}


#pragma mark - Misc


-(void) positionChanged:(CGPoint)position forView:(XYInputView *)view
{
    // translate the normalized value the JamPad position to a range
    // in [min, max] for the respective parameter
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
}

-(void) audioRouteChanged:(bool)routeIsSpeaker
{
    m_bSpeakerRoute = routeIsSpeaker;
    
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
    
    if (m_bSpeakerRoute)
    {
        [m_audioRouteSwitch setSelected:NO];
    }
    else
    {
        [m_audioRouteSwitch setSelected:YES];
    }
    
    // The global volume slider is not available when audio is routed to lineout. 
    // If the audio is not being outputed to lineout hide the global volume slider,
    // and display our own slider that controlls volume in this mode.
    NSString * routeName = (NSString *)[g_audioController GetAudioRoute];
    if ([routeName isEqualToString:@"LineOut"])
    {
        [m_lineOutVolumeSlider setHidden:NO];
        [m_volumeView setHidden:YES];
    }
    else
    {
        [m_lineOutVolumeSlider setHidden:YES];
        [m_volumeView setHidden:NO];
    }
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:m_bSpeakerRoute forKey:@"RouteToSpeaker"];
    [settings synchronize];
}

@end