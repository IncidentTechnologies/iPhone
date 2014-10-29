//
//  FreePlayController.h
//  keysPlay
//
//  Created by Kate Schnippering on 10/23/14.
//  Copyright 2014 Incident Technologies. All rights reserved.
//

#import <gTarAppCore/MainEventController.h>

#import "SoundMaster.h"
#import "KeysController.h"

#import "JamPad.h"

#import "InstrumentsAndEffectsViewController.h"
#import "LightsViewController.h"
#import "FPMenuViewController.h"
#import "VolumeViewController.h"

#import "TransparentAreaView.h"
#import "CustomComboBox.h"
#import "RGBColor.h"
#import "Harmonizer.h"

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import "AppCore.h"

#import "UIView+Keys.h"
#import "Mixpanel.h"

#define FREE_PLAY_EFFECT_COUNT 4
//#define Debug_BUILD 1


@class TransparentAreaView;
@class CustomComboBox;
@class RGBColor;
@class Harmonizer;

/*
typedef enum
{
    LEDTouchGeneral,
    LEDTouchFret,
    LEDTouchString,
    LEDTouchAll,
    LEDTouchNone
} LEDTouchArea;

typedef enum
{
    LEDModeSingle,
    LEDModeTrail,
    LEDModeHold
} LEDMode;

typedef enum
{
    LEDColorSingle,
    LEDColorRoatating,
    LEDColorRandom
} LEDColorMode;

typedef enum
{
    LEDShapeDot,
    LEDShapeCross,
    LEDShapeSquare
} LEDShape;

typedef enum
{
    LEDLoopSolid,
    LEDLoopUp,
    LEDLoopSide,
    LEDRainbow,
    LEDSquares,
    LEDLgSquares,
    LEDLoopRandom,
    
    // KEEP AT END OF LIST!
    NUM_LEDLoop_ENTRIES // keep track of the number of entries in this enum
} LEDLoop;
 */

@interface FreePlayController: MainEventController <KeysControllerObserver, XYInputViewDelegate, LightsViewDelegate, FPMenuDelegate>
{
    IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
    IBOutlet UIView * m_connectingView;
    
    //Effect *m_selectedEffect;
    
    int m_ScaleArray[41];
    
    NSDate * m_playTimeStart;
    NSDate * m_audioRouteTimeStart;
    NSDate * m_instrumentTimeStart;
    NSDate * m_effectTimeStart[FREE_PLAY_EFFECT_COUNT];
    NSDate * m_scaleTimeStart;
    NSTimeInterval m_playTimeAdjustment;
    
}


@property (strong, nonatomic) IBOutlet JamPad *m_jamPad;
@property (strong, nonatomic) IBOutlet UISlider *m_wetSlider;
@property (strong, nonatomic) IBOutlet UILabel *m_currentEffectName;


@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
@property (nonatomic, strong) IBOutlet UIView * m_connectingView;
@property (strong, nonatomic) IBOutlet UILabel *m_xParamLabel;
@property (strong, nonatomic) IBOutlet UILabel *m_yParamLabel;

@property (strong, nonatomic) IBOutlet UIView *m_effectsView;
@property (strong, nonatomic) IBOutlet UITableView *m_effectsScroll;

@property (strong, nonatomic) IBOutlet TransparentAreaView *m_effectsTab;
@property (strong, nonatomic) IBOutlet UIButton *m_effect1OnOff;
@property (strong, nonatomic) IBOutlet UIButton *m_effect1Select;
@property (strong, nonatomic) IBOutlet UILabel *m_effect1Name;
@property (strong, nonatomic) IBOutlet UIButton *m_effect2OnOff;
@property (strong, nonatomic) IBOutlet UIButton *m_effect2Select;
@property (strong, nonatomic) IBOutlet UILabel *m_effect2Name;
@property (strong, nonatomic) IBOutlet UIButton *m_effect3OnOff;
@property (strong, nonatomic) IBOutlet UIButton *m_effect3Select;
@property (strong, nonatomic) IBOutlet UILabel *m_effect3Name;
@property (strong, nonatomic) IBOutlet UIButton *m_effect4OnOff;
@property (strong, nonatomic) IBOutlet UIButton *m_effect4Select;
@property (strong, nonatomic) IBOutlet UILabel *m_effect4Name;

@property (strong, nonatomic) IBOutlet TransparentAreaView *m_instrumentsTab;
@property (strong, nonatomic) IBOutlet CustomComboBox *m_instrumentsScroll;


//@property (retain, nonatomic) IBOutlet TransparentAreaView *m_menuTab;
//@property (retain, nonatomic) IBOutlet UISlider *m_toneSlider;
//@property (nonatomic, retain) IBOutlet UIView * m_volumeView;
//@property (retain, nonatomic) IBOutlet UISlider *m_lineOutVolumeSlider;
//@property (retain, nonatomic) IBOutlet UIButton *m_audioRouteSwitch;
@property (assign) BOOL m_bSpeakerRoute;

// LED light tab
@property (strong, nonatomic) IBOutlet TransparentAreaView *m_LEDTab;
@property (strong, nonatomic) IBOutlet UIView *m_LEDGeneralSurface;
@property (strong, nonatomic) IBOutlet UIView *m_LEDFretSurface;
@property (strong, nonatomic) IBOutlet UIView *m_LEDStringSurface;
@property (strong, nonatomic) IBOutlet UIView *m_LEDAllSurface;
@property (assign, nonatomic) LEDTouchArea m_LEDTouchArea;
@property (assign, nonatomic) CGPoint m_lastLEDTouch;
@property (assign, nonatomic) LEDMode m_LEDMode;
@property (assign, nonatomic) LEDColorMode m_LEDColorMode;
@property (strong, nonatomic) NSArray *m_colors;
@property (assign, nonatomic) NSInteger m_currentColorIndex;
@property (assign, nonatomic) LEDShape m_LEDShape;
@property (assign, nonatomic) LEDLoop m_LEDLoop;
@property (strong, nonatomic) NSTimer *m_LEDTimer;

// Harmonizer
@property (strong, nonatomic) Harmonizer *m_harmonizer;
@property (assign, nonatomic) NSInteger m_harmonizerValue;
@property (strong, nonatomic) IBOutlet UIButton *m_scaleSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSoundMaster:(SoundMaster *)soundMaster;

- (void)handleResignActive;
- (void)handleBecomeActive;
- (void)finalLogging;

- (IBAction)setWet:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)toggleEffectsTab:(id)sender;
- (IBAction)toggleEffectOnOff:(id)sender;
- (IBAction)selectEffect:(id)sender;
- (IBAction)toggleInstrumentsTab:(id)sender;
- (IBAction)toggleMenuTab:(id)sender;
- (IBAction)setTone:(id)sender;
- (IBAction)toggleAudioRoute:(id)sender;
- (IBAction)setLineoutGain:(id)sender;
- (IBAction)instrumentSelected:(id)sender;
- (IBAction)toggleLEDTab:(id)sender;

- (IBAction)toggleScaleLights:(id)sender;

- (void) setupJamPadWithEffectAtIndex:(int)index;
- (void) samplerFinishedLoadingCB:(NSNumber*)result;

// LED methods
- (void) touchedLEDs:(NSSet *)touches;
- (CGPoint) getFretPositionFromTouch:(UITouch *)touch;
- (void) turnOnLED:(int)key WithColorRed:(int)red AndGreen:(int)green AndBlue:(int)blue;
- (void) turnOffLED:(int)key;
- (void) turnOffLEDDelayed:(NSArray *)params;
- (void) turnOffLEDByShape:(int)key;
- (void) LEDRainbow;
- (void) LEDSquarePatches;
- (void) LEDLgSquarePatches;
- (void) turnOnAllLEDRandom;
- (void) animateLEDs:(NSTimer*)theTimer;
- (IBAction)setLEDMode:(id)sender;
- (IBAction)setLEDColor:(id)sender;
- (IBAction)clearAllLEDs:(id)sender;
- (IBAction)autoPlayLEDs:(id)sender;

@end
