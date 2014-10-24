//
//  LightsViewController.h
//  keysPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "KeysController.h"
#import "RGBColor.h"
#import <gTarAppCore/AppCore.h>
#import <UIKit/UIKit.h>

extern KeysController * g_keysController;

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

@interface LightsViewController : UIViewController <KeysControllerObserver> {
 
    LEDMode _LEDMode;
    
}

@property (nonatomic, strong) IBOutlet UILabel *allLabel;
@property (weak, nonatomic) id <LightsViewDelegate> delegate;


@property (strong, nonatomic) IBOutlet UIView *generalSurface;
@property (strong, nonatomic) IBOutlet UIView *fretSurface;
@property (strong, nonatomic) IBOutlet UIView *stringSurface;
@property (strong, nonatomic) IBOutlet UIView *allSurface;

@property (strong, nonatomic) IBOutlet UIView *shapeView;
@property (strong, nonatomic) IBOutlet UIView *colorView;

@property (strong, nonatomic) IBOutlet UIButton *shapeButton;
@property (strong, nonatomic) IBOutlet UIButton *colorButton;
@property (strong, nonatomic) IBOutlet UIButton *loopButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;

@property (strong, nonatomic) IBOutlet UIImageView *arrowFretsRight;
@property (strong, nonatomic) IBOutlet UIImageView *arrowStringsTop;
@property (strong, nonatomic) IBOutlet UIImageView *arrowStringsBottom;

@property (strong, nonatomic) IBOutlet UIButton *modeSingleButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *modeButtons;

@property (strong, nonatomic) IBOutlet UIButton *colorWhite;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *colorButtons;


@property (nonatomic, strong) IBOutlet UILabel *ledSingleLabel;
@property (nonatomic, strong) IBOutlet UILabel *ledQuadLabel;
@property (nonatomic, strong) IBOutlet UILabel *ledContinuousLabel;

@property (assign, nonatomic) LEDTouchArea LEDTouchArea;
@property (assign, nonatomic) CGPoint lastLEDTouch;
@property (assign, nonatomic) LEDColorMode LEDColorMode;
@property (strong, nonatomic) NSArray *colors;
@property (assign, nonatomic) NSInteger currentColorIndex;
@property (assign, nonatomic) LEDShape LEDShape;
@property (assign, nonatomic) LEDLoop LEDLoop;
@property (strong, nonatomic) NSTimer *LEDTimer;

- (void)localizeViews;

@end
