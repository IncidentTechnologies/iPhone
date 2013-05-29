//
//  FreePlayController.h
//  gTarPlay
//
//  Created by Marty Greenia on 3/15/11.
//  Copyright 2011 Msft. All rights reserved.
//

#import <gTarAppCore/MainEventController.h>

#import <AudioController/AudioController.h>
#import <GtarController/GtarController.h>

#import "JamPad.h"

#define FREE_PLAY_EFFECT_COUNT 4

@class TransparentAreaView;
@class CustomComboBox;
@class RGBColor;
@class Harmonizer;

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

@interface FreePlayController: MainEventController <GtarControllerObserver, AudioControllerDelegate, XYInputViewDelegate>
{
    IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
    IBOutlet UIView * m_connectingView;
    
    std::vector<Effect*> m_effects;
    Effect *m_selectedEffect;
    
    int m_ScaleArray[41];
    
    NSDate * m_playTimeStart;
    NSDate * m_audioRouteTimeStart;
    NSDate * m_instrumentTimeStart;
    NSDate * m_effectTimeStart[FREE_PLAY_EFFECT_COUNT];
    NSDate * m_scaleTimeStart;
    NSTimeInterval m_playTimeAdjustment;
    
}

@property (retain, nonatomic) IBOutlet JamPad *m_jamPad;
@property (retain, nonatomic) IBOutlet UISlider *m_wetSlider;
@property (retain, nonatomic) IBOutlet UILabel *m_currentEffectName;


@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * m_activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIView * m_connectingView;
@property (retain, nonatomic) IBOutlet UILabel *m_xParamLabel;
@property (retain, nonatomic) IBOutlet UILabel *m_yParamLabel;

@property (retain, nonatomic) IBOutlet TransparentAreaView *m_effectsTab;
@property (retain, nonatomic) IBOutlet UIButton *m_effectsTabButton;
@property (retain, nonatomic) IBOutlet UIButton *m_effect1OnOff;
@property (retain, nonatomic) IBOutlet UIButton *m_effect1Select;
@property (retain, nonatomic) IBOutlet UILabel *m_effect1Name;
@property (retain, nonatomic) IBOutlet UIButton *m_effect2OnOff;
@property (retain, nonatomic) IBOutlet UIButton *m_effect2Select;
@property (retain, nonatomic) IBOutlet UILabel *m_effect2Name;
@property (retain, nonatomic) IBOutlet UIButton *m_effect3OnOff;
@property (retain, nonatomic) IBOutlet UIButton *m_effect3Select;
@property (retain, nonatomic) IBOutlet UILabel *m_effect3Name;
@property (retain, nonatomic) IBOutlet UIButton *m_effect4OnOff;
@property (retain, nonatomic) IBOutlet UIButton *m_effect4Select;
@property (retain, nonatomic) IBOutlet UILabel *m_effect4Name;

@property (retain, nonatomic) IBOutlet TransparentAreaView *m_instrumentsTab;
@property (retain, nonatomic) IBOutlet UIButton *m_instrumentsTabButton;
@property (retain, nonatomic) IBOutlet CustomComboBox *m_instrumentsScroll;


@property (retain, nonatomic) IBOutlet TransparentAreaView *m_menuTab;
@property (retain, nonatomic) IBOutlet UIButton *m_menuTabButton;
@property (retain, nonatomic) IBOutlet UISlider *m_toneSlider;
@property (nonatomic, retain) IBOutlet UIView * m_volumeView;
@property (retain, nonatomic) IBOutlet UISlider *m_lineOutVolumeSlider;
@property (retain, nonatomic) IBOutlet UIButton *m_audioRouteSwitch;
@property (assign) BOOL m_bSpeakerRoute;

// LED light tab
@property (retain, nonatomic) IBOutlet TransparentAreaView *m_LEDTab;
@property (retain, nonatomic) IBOutlet UIButton *m_LEDTabButton;
@property (retain, nonatomic) IBOutlet UIView *m_LEDGeneralSurface;
@property (retain, nonatomic) IBOutlet UIView *m_LEDFretSurface;
@property (retain, nonatomic) IBOutlet UIView *m_LEDStringSurface;
@property (retain, nonatomic) IBOutlet UIView *m_LEDAllSurface;
@property (assign, nonatomic) LEDTouchArea m_LEDTouchArea;
@property (assign, nonatomic) CGPoint m_lastLEDTouch;
@property (assign, nonatomic) LEDMode m_LEDMode;
@property (assign, nonatomic) LEDColorMode m_LEDColorMode;
@property (retain, nonatomic) NSArray *m_colors;
@property (assign, nonatomic) NSInteger m_currentColorIndex;
@property (assign, nonatomic) LEDShape m_LEDShape;
@property (assign, nonatomic) LEDLoop m_LEDLoop;
@property (retain, nonatomic) NSTimer *m_LEDTimer;

// Harmonizer
@property (retain, nonatomic) Harmonizer *m_harmonizer;
@property (assign, nonatomic) NSInteger m_harmonizerValue;
@property (retain, nonatomic) IBOutlet UIButton *m_scaleSwitch;

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
- (void) turnONLED:(int)string AndFret:(int)fret WithColorRed:(int)red AndGreen:(int)green AndBlue:(int)blue;
- (void) turnOffLED:(int)string AndFret:(int)fret;
- (void) turnOffLEDDelayed:(NSArray *)params;
- (void) turnOffLEDByShape:(int)string AndFret:(int)fret;
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
