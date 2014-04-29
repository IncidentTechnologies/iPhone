//
//  LightsViewController.h
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "GtarController.h"
#import "RGBColor.h"
#import <gTarAppCore/AppCore.h>
#import <UIKit/UIKit.h>

extern GtarController * g_gtarController;

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

@protocol LightsViewDelegate <NSObject>

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface LightsViewController : UIViewController <GtarControllerObserver> {
 
    LEDMode _LEDMode;
    
}

@property (nonatomic, retain) IBOutlet UILabel *allLabel;
@property (assign, nonatomic) id <LightsViewDelegate> delegate;


@property (retain, nonatomic) IBOutlet UIView *generalSurface;
@property (retain, nonatomic) IBOutlet UIView *fretSurface;
@property (retain, nonatomic) IBOutlet UIView *stringSurface;
@property (retain, nonatomic) IBOutlet UIView *allSurface;

@property (retain, nonatomic) IBOutlet UIView *shapeView;
@property (retain, nonatomic) IBOutlet UIView *colorView;

@property (retain, nonatomic) IBOutlet UIButton *shapeButton;
@property (retain, nonatomic) IBOutlet UIButton *colorButton;
@property (retain, nonatomic) IBOutlet UIButton *loopButton;
@property (retain, nonatomic) IBOutlet UIButton *clearButton;

@property (retain, nonatomic) IBOutlet UIImageView *arrowFretsRight;
@property (retain, nonatomic) IBOutlet UIImageView *arrowStringsTop;
@property (retain, nonatomic) IBOutlet UIImageView *arrowStringsBottom;

@property (retain, nonatomic) IBOutlet UIButton *modeSingleButton;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *modeButtons;

@property (retain, nonatomic) IBOutlet UIButton *colorWhite;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *colorButtons;


@property (nonatomic, retain) IBOutlet UILabel *ledSingleLabel;
@property (nonatomic, retain) IBOutlet UILabel *ledQuadLabel;
@property (nonatomic, retain) IBOutlet UILabel *ledContinuousLabel;

@property (assign, nonatomic) LEDTouchArea LEDTouchArea;
@property (assign, nonatomic) CGPoint lastLEDTouch;
@property (assign, nonatomic) LEDColorMode LEDColorMode;
@property (retain, nonatomic) NSArray *colors;
@property (assign, nonatomic) NSInteger currentColorIndex;
@property (assign, nonatomic) LEDShape LEDShape;
@property (assign, nonatomic) LEDLoop LEDLoop;
@property (retain, nonatomic) NSTimer *LEDTimer;

- (void)localizeViews;

@end
