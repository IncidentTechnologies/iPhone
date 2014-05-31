//
//  LightsViewController.m
//  gTarPlay
//
//  Created by Franco on 3/28/13.
//
//

#import "LightsViewController.h"

@implementation LightsViewController

@synthesize delegate;

- (id)init
{
    self = [super initWithNibName:@"LightsViewController" bundle:nil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFreePlay:) name:@"ExitFreePlay" object:nil];

        RGBColor *white = [[RGBColor alloc] initWithRed:3 Green:3 Blue:3];
        RGBColor *red = [[RGBColor alloc] initWithRed:3 Green:0 Blue:0];
        RGBColor *green = [[RGBColor alloc] initWithRed:0 Green:3 Blue:0];
        RGBColor *blue = [[RGBColor alloc] initWithRed:0 Green:0 Blue:3];
        RGBColor *cyan = [[RGBColor alloc] initWithRed:0 Green:3 Blue:3];
        RGBColor *magenta = [[RGBColor alloc] initWithRed:3 Green:0 Blue:3];
        RGBColor *yellow = [[RGBColor alloc] initWithRed:3 Green:3 Blue:0];
        RGBColor *orange = [[RGBColor alloc] initWithRed:3 Green:1 Blue:0];
        
        _colors = [[NSArray alloc] initWithObjects:white, red, magenta, blue, cyan, green, yellow, orange, nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self localizeViews];
    
    _generalSurface.transform = CGAffineTransformMakeScale(1, -1);
    _stringSurface.transform = CGAffineTransformMakeScale(1, -1);
    
    _lastLEDTouch = CGPointMake(-1, -1);
    _LEDMode = LEDModeTrail;
    _LEDShape = LEDShapeDot;
    _LEDLoop = NUM_LEDLoop_ENTRIES;
    
    _arrowFretsRight.transform = CGAffineTransformMakeRotation(-M_PI);
    _arrowStringsBottom.transform = CGAffineTransformMakeRotation(-M_PI_2);
    _arrowStringsTop.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [g_gtarController addObserver:self];
    
    _modeSingleButton.selected = YES;
    _colorWhite.selected = YES;
}

- (void)localizeViews {
    _allLabel.text = [[NSString alloc] initWithString:NSLocalizedString(@"ALL", NULL)];
    
    [_colorButton setTitle:NSLocalizedString(@"COLOR", NULL) forState:UIControlStateNormal];
    [_shapeButton setTitle:NSLocalizedString(@"SHAPE", NULL) forState:UIControlStateNormal];
    [_loopButton setTitle:NSLocalizedString(@"LOOP", NULL) forState:UIControlStateNormal];
    [_clearButton setTitle:NSLocalizedString(@"CLEAR", NULL) forState:UIControlStateNormal];
    
    
    [_ledSingleLabel setText:NSLocalizedString(@"Single", NULL)];
    [_ledQuadLabel setText:NSLocalizedString(@"2 X 2", NULL)];
    [_ledContinuousLabel setText:NSLocalizedString(@"Continuous", NULL)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view insertSubview:_shapeView belowSubview:_shapeButton];
    [self.view insertSubview:_colorView belowSubview:_shapeView];
    
    _shapeView.transform = CGAffineTransformIdentity;
    _colorView.transform = CGAffineTransformIdentity;
    
    CGRect frame = _shapeView.frame;
    frame.origin.y = _shapeButton.frame.origin.y;
    frame.size.width = self.view.frame.size.width;
    
    [_shapeView setFrame:frame];
    [_colorView setFrame:frame];
    
    [_shapeButton setSelected:NO];
    [_colorButton setSelected:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [g_gtarController removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ExitFreePlay" object:nil];
    
    
    [self stopLoop];
    
}


- (void) willExitFreePlay:(NSNotification *) notification
{
    [self stopLoop];
}

- (IBAction)toggleShapeView:(id)sender
{
    [_shapeButton setSelected:![_shapeButton isSelected]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    
    // Then perform action based on new state
    if ([_shapeButton isSelected])
    {
        _shapeView.transform = CGAffineTransformMakeTranslation(0, -1 * _shapeView.frame.size.height);
    }
    else
    {
        _shapeView.transform = CGAffineTransformIdentity;
    }
    
    // if color view is up bring it down
    if ([_colorButton isSelected])
    {
        [_colorButton setSelected:NO];
        _colorView.transform = CGAffineTransformIdentity;
    }
    
    [UIView commitAnimations];
}

- (IBAction)toggleColorView:(id)sender
{
    [_colorButton setSelected:![_colorButton isSelected]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    
    // Then perform action based on new state
    if ([_colorButton isSelected])
    {
        _colorView.transform = CGAffineTransformMakeTranslation(0, -1 * _colorView.frame.size.height);
        //[_shapeView setHidden:NO];
    }
    else
    {
        _colorView.transform = CGAffineTransformIdentity;
        //[_shapeView setHidden:YES];
    }
    
    // if shape view is up bring it down
    if ([_shapeButton isSelected])
    {
        [_shapeButton setSelected:NO];
        _shapeView.transform = CGAffineTransformIdentity;
    }
    
    [UIView commitAnimations];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [delegate touchesBegan:touches withEvent:event];
    
	// For now we just want to recognize that a touch (any touch) occurred
	UITouch * touch = [[touches allObjects] objectAtIndex:0];
    
    if (LEDColorRoatating == _LEDColorMode)
    {
        _currentColorIndex++;
        if (_currentColorIndex >= [_colors count])
        {
            _currentColorIndex = 0;
        }
    }
    
    UIView *touchedView = [touch view];
    if (touchedView == _generalSurface)
    {
        _LEDTouchArea = LEDTouchGeneral;
    }
    else if (touchedView == _fretSurface)
    {
        _LEDTouchArea = LEDTouchFret;
    }
    else if (touchedView == _stringSurface)
    {
        _LEDTouchArea = LEDTouchString;
    }
    else if (touchedView == _allSurface)
    {
        _LEDTouchArea = LEDTouchAll;
    }
    else
    {
        _LEDTouchArea = LEDTouchNone;
        return;
    }
    
    [self touchedLEDs:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate touchesMoved:touches withEvent:event];
    
    // Only take action if the touch is inside a designated LED area
    if (LEDTouchNone != _LEDTouchArea)
    {
        [self touchedLEDs:touches];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate touchesEnded:touches withEvent:event];
    
    // Check that last touchBegan was inside an LED touch area
    if (LEDTouchNone != _LEDTouchArea && LEDTouchAll != _LEDTouchArea)
    {
        // Turn off last LED touch point when finger touch ends
        [self turnOffLED:_lastLEDTouch.x AndFret:_lastLEDTouch.y];
    }
    
    // reset the last touch point
    _lastLEDTouch = CGPointMake(-1, -1);
}


#pragma mark - LED light logic

- (void) touchedLEDs:(NSSet *)touches
{
    [self stopLoop];
    
    RGBColor *color = [_colors objectAtIndex:_currentColorIndex];
    
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
        
        if (string == _lastLEDTouch.x && fret == _lastLEDTouch.y && (string > 0 || fret > 0))
        {
            // finger is on same fret, do nothing
            return;
        }
        
        // Finger position had changed, turn off previous location according
        // to LEDMode
        [self turnOffLED:_lastLEDTouch.x AndFret:_lastLEDTouch.y];
        
        _lastLEDTouch = CGPointMake(string, fret);
        
        // Turn on new fret position
        if (LEDTouchAll == _LEDTouchArea && LEDColorRandom == _LEDColorMode)
        {
            // turn all all frets with rotating colors
            [self turnOnAllLEDRandom];
        }
        else
        {
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
        }
        
        // if color mode is 'random' rotate colors on every new led position
        if (LEDColorRandom == _LEDColorMode)
        {
            _currentColorIndex++;
            if (_currentColorIndex >= [_colors count])
            {
                _currentColorIndex = 0;
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
    switch (_LEDTouchArea)
    {
        case LEDTouchGeneral:
            point = [touch locationInView:_generalSurface];
            
            string = (point.y / (_generalSurface.frame.size.height/GTAR_GUITAR_STRING_COUNT)) + 1;
            if (string < 1)
            {
                string = 1;
            }
            else if ( string > GTAR_GUITAR_STRING_COUNT)
            {
                string = (GTAR_GUITAR_STRING_COUNT);
            }
            
            fret = (point.x / (_generalSurface.frame.size.width/GTAR_GUITAR_FRET_COUNT)) + 1;
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
            point = [touch locationInView:_fretSurface];
            
            fret = (point.x / (_fretSurface.frame.size.width/GTAR_GUITAR_FRET_COUNT)) + 1;
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
            point = [touch locationInView:_stringSurface];
            
            string = (point.y / (_stringSurface.frame.size.height/GTAR_GUITAR_STRING_COUNT)) + 1;
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
            NSLog(@"Invalid LEDTouchArea: %d", _LEDTouchArea);
            break;
    }
    
    return CGPointMake(string, fret);
}

// turns on the LED at the specified string and fret based on the current
// _LEDShape value
- (void) turnONLED:(int)string AndFret:(int)fret WithColorRed:(int)red AndGreen:(int)green AndBlue:(int)blue
{
    // Regardless of shape we will turn on the touch point.
    [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string)
                                withColor:GtarLedColorMake(red, green, blue)];
    
    switch (_LEDShape)
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

// handles turning off LEDs based on the current _LEDMode
- (void) turnOffLED:(int)string AndFret:(int)fret
{
    if (LEDModeSingle == _LEDMode)
    {
        [self turnOffLEDByShape:string AndFret:fret];
    }
    else if (LEDModeTrail == _LEDMode)
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
// _LEDShape value
- (void) turnOffLEDByShape:(int)string AndFret:(int)fret
{
    // Regardless of shape we will turn off the touch point.
    [g_gtarController turnOnLedAtPosition:GtarPositionMake(fret, string)
                                withColor:GtarLedColorMake(0, 0, 0)];
    
    switch (_LEDShape)
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

- (IBAction)setLEDMode:(UIButton*)sender
{
    [self stopLoop];
    
    // Set only this mode button as selected
    for (UIButton* button in _modeButtons)
    {
        button.selected = NO;
    }
    sender.selected = YES;
    
    // Bring down shape view
    _shapeButton.selected = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    _shapeView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    switch ([sender tag])
    {
        case 11:
            _LEDMode = LEDModeTrail;
            _LEDShape = LEDShapeDot;
            break;
        case 12:
            _LEDMode = LEDModeTrail;
            _LEDShape = LEDShapeSquare;
            break;
        case 13:
            _LEDMode = LEDModeHold;
            _LEDShape = LEDShapeDot;
            break;
            
        default:
            break;
    }
    
}


- (IBAction)setLEDColor:(UIButton*)sender
{
    // Set only this color button as selected
    for (UIButton* button in _colorButtons)
    {
        button.selected = NO;
    }
    sender.selected = YES;
    
    // Bring down color view
    _colorButton.selected = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.8];
    _colorView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    
    if (9 == [sender tag])
    {
        _LEDColorMode = LEDColorRoatating;
    }
    else if (10 == [sender tag])
    {
        _LEDColorMode = LEDColorRandom;
    }
    else
    {
        _LEDColorMode = LEDColorSingle;
        _currentColorIndex = [sender tag] - 1;
    }
}

- (IBAction)clearAllLEDs:(id)sender
{
    [self stopLoop];
    
    [g_gtarController turnOnLedAtPosition:GtarPositionMake(0, 0)
                                withColor:GtarLedColorMake(0, 0, 0)];
}

- (IBAction)playLoop:(id)sender
{
    // ++_LEDLoop
    _LEDLoop = (LEDLoop)int(_LEDLoop+1);
    
    if(_LEDLoop >= NUM_LEDLoop_ENTRIES)
    {
        _LEDLoop = LEDLoopSolid;
    }
    
    float timeInterval;
    
    switch (_LEDLoop)
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
    
    [self stopLoop];
    
    self.LEDTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(animateLEDs:) userInfo:nil repeats:YES];
    [self animateLEDs:_LEDTimer];
}

- (void)stopLoop
{
    // stop the LED auto loop playback if its on
    if (_LEDTimer != nil)
    {
        [_LEDTimer invalidate];
        self.LEDTimer = nil;
    }
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
            _currentColorIndex = arc4random_uniform([_colors count]);
            
            color = [_colors objectAtIndex:_currentColorIndex];
            
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
            color = [_colors objectAtIndex:_currentColorIndex];
            
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++_currentColorIndex >= [_colors count])
            {
                // loop starting at 1, skip 0 (white) for the full fretboard random display
                _currentColorIndex = 1;
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
            color = [_colors objectAtIndex:_currentColorIndex];
            
            [self turnONLED:string AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            [self turnONLED:string+1 AndFret:fret+1 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++_currentColorIndex >= [_colors count])
            {
                // loop starting at 1, skip 0 (white) for the full fretboard random display
                _currentColorIndex = 1;
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
            color = [_colors objectAtIndex:_currentColorIndex];
            
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
            
            if (++_currentColorIndex >= [_colors count])
            {
                // loop starting at 1, skip 0 (white) for the full fretboard random display
                _currentColorIndex = 1;
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
    
    switch (_LEDLoop)
    {
        case LEDLoopSolid:
            
            color = [_colors objectAtIndex:_currentColorIndex];
            
            [self turnONLED:0 AndFret:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++_currentColorIndex >= [_colors count])
            {
                _currentColorIndex = 0;
            }
            
            break;
            
        case LEDLoopUp:
            
            color = [_colors objectAtIndex:_currentColorIndex];
            
            int static fret = GTAR_GUITAR_FRET_COUNT;
            
            [self turnONLED:0 AndFret:fret WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (--fret < 1)
            {
                fret = 16;
                if (++_currentColorIndex >= [_colors count])
                {
                    _currentColorIndex = 0;
                }
            }
            
            break;
            
        case LEDLoopSide:
            
            color = [_colors objectAtIndex:_currentColorIndex];
            
            int static string = 1;
            
            [self turnONLED:string AndFret:0 WithColorRed:color.R AndGreen:color.G AndBlue:color.B];
            
            if (++string > GTAR_GUITAR_STRING_COUNT)
            {
                string = 1;
                if (++_currentColorIndex >= [_colors count])
                {
                    _currentColorIndex = 0;
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

#pragma mark - GtarControllerObserver

- (void)gtarDisconnected
{
    [self stopLoop];
}

@end
