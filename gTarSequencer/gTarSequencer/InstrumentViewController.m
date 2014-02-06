//
//  InstrumentViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "InstrumentViewController.h"

#define MEASURE_WIDTH 432
#define MEASURE_MARGIN 8
#define NOTE_WIDTH 27
#define NOTE_HEIGHT 27

@implementation InstrumentViewController

@synthesize delegate;
@synthesize scrollView;
@synthesize patternButton;
@synthesize instrumentTitle;
@synthesize instrumentIcon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        activePattern = -1;
        activeMeasure = -1;
        
        freezeMeasureChange = nil;
        
        patternTitles[0] = @"A";
        patternTitles[1] = @"B";
        patternTitles[2] = @"C";
        patternTitles[3] = @"D";
        
        [self initColors];
        
        for(int i = 0; i < NUM_PATTERNS; i++){
            declaredActiveMeasures[i] = -1;
        }
        
        for(int i = 0; i < NUM_PATTERNS; i++){
            for(int j = 0; j < NUM_MEASURES; j++){
                measureSet[i][j] = nil;
                for(int k = 0; k < MAX_NOTES; k++){
                    noteButtons[i][j][k] = nil;
                }
            }
        }
        
    }
    return self;
}

- (void)initColors
{
    colors[5] = [UIColor colorWithRed:150/255.0 green:12/255.0 blue:238/255.0 alpha:1.0];
    colors[4] = [UIColor colorWithRed:9/255.0 green:109/255.0 blue:245/255.0 alpha:1.0];
    colors[3] = [UIColor colorWithRed:19/255.0 green:133/255.0 blue:4/255.0 alpha:1.0];
    colors[2] = [UIColor colorWithRed:245/255.0 green:214/255.0 blue:9/255.0 alpha:1.0];
    colors[1] = [UIColor colorWithRed:238/255.0 green:129/255.0 blue:13/255.0 alpha:1.0];
    colors[0] = [UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // GESTURES
    //
    
    CGRect leftButtonFrame = CGRectMake(0,scrollView.frame.origin.y,MEASURE_MARGIN*3,scrollView.frame.size.height);
    CGRect rightButtonFrame = CGRectMake(scrollView.frame.size.width-MEASURE_MARGIN*3,scrollView.frame.origin.y,MEASURE_MARGIN*3,scrollView.frame.size.height);
    UIButton * leftInvisibleButton = [[UIButton alloc] initWithFrame:leftButtonFrame];
    UIButton * rightInvisibleButton = [[UIButton alloc] initWithFrame:rightButtonFrame];
    
    // Move left
    UILongPressGestureRecognizer * pressLeft = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(decrementMeasure:)];
    pressLeft.minimumPressDuration = 0.5;
    
    // Move right
    UILongPressGestureRecognizer * pressRight = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(incrementMeasure:)];
    pressRight.minimumPressDuration = 0.5;
    
    [self.view addSubview:leftInvisibleButton];
    [self.view addSubview:rightInvisibleButton];
    
    [leftInvisibleButton addGestureRecognizer:pressLeft];
    [rightInvisibleButton addGestureRecognizer:pressRight];
    
}

- (void)reopenView
{
    // Clear previous pattern data
    if(activePattern > 0){
        NSLog(@"Clear previous pattern data");
        
        for(int i = 0; i < NUM_PATTERNS; i++){
            for(int j = 0; j < NUM_MEASURES; j++){
                [self clearMeasure:j forPattern:i];
            }
        }
    }
    
}

#pragma mark - Instrument Updates
- (void)setMeasureCountTo:(int)measureCount forPattern:(int)patternIndex
{
    Pattern * p = [currentInst.patterns objectAtIndex:patternIndex];
    
    if(measureCount < measureCounts[patternIndex]){
        
        [p halveMeasures];
        if(measureCount == measureCounts[patternIndex]/4){
            [p halveMeasures];
        }
        
    }else if(measureCount > measureCounts[patternIndex]){
        
        [p doubleMeasures];
        if(measureCount == measureCounts[patternIndex]*4){
            [p doubleMeasures];
        }
    }
    
    measureCounts[patternIndex] = measureCount;
}

- (void)setActiveMeasureIndex:(int)measureIndex forPattern:(int)patternIndex
{
    Pattern * p = [currentInst.patterns objectAtIndex:patternIndex];
    Measure * m = [p.measures objectAtIndex:measureIndex];
    
    [p setSelectedMeasure:m];
    [p setSelectedMeasureIndex:measureIndex];
}

- (void)setActivePatternIndex:(int)patternIndex
{
    [currentInst setSelectedPatternIndex:patternIndex];
    [currentInst setSelectedPattern:currentInst.patterns[patternIndex]];
}

#pragma mark - Instruments

- (void)setActiveInstrument:(Instrument *)inst
{
 
    if(inst == NULL){
        // TODO: handle 0 instruments case
        return;
    }
 
    currentInst = inst;
    
    // Title
    [instrumentTitle setText:inst.instrumentName];
    
    // Icon
    [instrumentIcon setImage:[UIImage imageNamed:inst.iconName]];
                 
    // Measure counts
    for(int i = 0; i < NUM_PATTERNS; i++){
        Pattern * p = [inst.patterns objectAtIndex:i];
        measureCounts[i] = p.measureCount;
    }
    
    // Update active pattern
    if(activePattern < 0) activePattern = inst.selectedPatternIndex;
    [self changePatternToPattern:inst.selectedPatternIndex];
    
    // Update active measure
    if(activeMeasure < 0) activeMeasure = inst.selectedPattern.selectedMeasureIndex;
    [self changeActiveMeasureToMeasure:inst.selectedPattern.selectedMeasureIndex];
    
    NSLog(@"Using pattern %i and measure %i",activePattern,activeMeasure);
}

#pragma mark - Measures
- (void)changeActiveMeasureToMeasure:(int)measureIndex
{
    [self scrollToAndSetActiveMeasure:measureIndex];
    
    if(freezeMeasureChange == nil){
        freezeMeasureChange = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(resetFreezeMeasure) userInfo:nil repeats:NO];
    }
    
    // SAVE CONTEXT
    [delegate saveContext:nil];
}

- (void)drawMeasuresForPattern:(int)patternIndex
{
    
    for(int i = 0; i < NUM_MEASURES; i++){
        
        UIView * newMeasure = [[UIView alloc] init];
        
        if(i < measureCounts[activePattern]){
            newMeasure = [self drawMeasureOnActive:i forPattern:activePattern];
        }else{
            newMeasure = [self drawMeasureOff:i forPattern:activePattern];
        }
            
        measureSet[activePattern][i] = newMeasure;
        
    }
    
    // Fade in
    [UIView animateWithDuration:1.5 animations:^(){
        for(int i = 0; i < NUM_MEASURES; i++){
            if(i == activeMeasure){
                [measureSet[patternIndex][i] setAlpha:1.0];
            }else{
                [measureSet[patternIndex][i] setAlpha:0.5];
            }
        }
    } completion:^(BOOL finished){
        
    }];
}

- (void)pinchMeasure:(UIPinchGestureRecognizer *)recognizer
{
    
    // TODO: clean this up
    
    // pinch in
    if(recognizer.scale < 1){
        
        // measure is active
        if(activeMeasure < measureCounts[activePattern]){
            
            switch(activeMeasure){
                case 1:
                    NSLog(@"DEACTIVATE %i",activeMeasure);
                    
                    if(measureCounts[activePattern] > 2){
                        
                        [self clearMeasure:1 forPattern:activePattern];
                        [self clearMeasure:2 forPattern:activePattern];
                        [self clearMeasure:3 forPattern:activePattern];
                        
                        [self setMeasureCountTo:1 forPattern:activePattern];
                        
                        measureSet[activePattern][1] = [self drawMeasureOff:1 forPattern:activePattern];
                        measureSet[activePattern][2] = [self drawMeasureOff:2 forPattern:activePattern];
                        measureSet[activePattern][3] = [self drawMeasureOff:3 forPattern:activePattern];
                        
                    }else{
                        
                        [self clearMeasure:1 forPattern:activePattern];
                    
                        [self setMeasureCountTo:1 forPattern:activePattern];
                        
                        measureSet[activePattern][1] = [self drawMeasureOff:1 forPattern:activePattern];
                        
                    }
                    
                    [self scrollToAndSetActiveMeasure:0];
                    
                    break;
                case 2:
                case 3:
                    NSLog(@"DEACTIVATE %i",activeMeasure);
                    
                    [self clearMeasure:2 forPattern:activePattern];
                    [self clearMeasure:3 forPattern:activePattern];
                    
                    [self setMeasureCountTo:2 forPattern:activePattern];
                    
                    measureSet[activePattern][2] = [self drawMeasureOff:2 forPattern:activePattern];
                    measureSet[activePattern][3] = [self drawMeasureOff:3 forPattern:activePattern];
                    
                    [self scrollToAndSetActiveMeasure:1];
                    
                    break;
            }
            
            
            // SAVE CONTEXT
            [delegate saveContext:nil];
        }
        
        
    }else if(recognizer.scale > 1){ // pinch out
        
        // measure is inactive
        if(activeMeasure >= measureCounts[activePattern]){
            
            switch (activeMeasure) {
                case 1:
                    NSLog(@"ACTIVATE %i",activeMeasure);
                    
                    [self clearMeasure:1 forPattern:activePattern];
                    
                    // These must be called before drawing the measure so data is up to date
                    [self setMeasureCountTo:2 forPattern:activePattern];
                    
                    measureSet[activePattern][1] = [self drawMeasureOnActive:1 forPattern:activePattern];
                    
                    break;
                case 2:
                case 3:
                    NSLog(@"ACTIVATE %i",activeMeasure);
                    
                    if(measureCounts[activePattern] < 2){
                        
                        [self clearMeasure:1 forPattern:activePattern];
                        [self clearMeasure:2 forPattern:activePattern];
                        [self clearMeasure:3 forPattern:activePattern];
                        
                        [self setMeasureCountTo:4 forPattern:activePattern];
                        
                        measureSet[activePattern][1] = [self drawMeasureOnActive:1 forPattern:activePattern];
                        measureSet[activePattern][2] = [self drawMeasureOnActive:2 forPattern:activePattern];
                        measureSet[activePattern][3] = [self drawMeasureOnActive:3 forPattern:activePattern];
                        
                    }else{
                        [self clearMeasure:2 forPattern:activePattern];
                        [self clearMeasure:3 forPattern:activePattern];
                        
                        [self setMeasureCountTo:4 forPattern:activePattern];
                        
                        measureSet[activePattern][2] = [self drawMeasureOnActive:2 forPattern:activePattern];
                        measureSet[activePattern][3] = [self drawMeasureOnActive:3 forPattern:activePattern];
                    }
                    
                    break;
            }
            
            [self scrollToAndSetActiveMeasure:activeMeasure];
            
            // SAVE CONTEXT
            [delegate saveContext:nil];
        }
    }
}

- (void)clearMeasure:(int)measureIndex forPattern:(int)patternIndex
{
    
    NSLog(@"Clear measure %i at pattern %i",measureIndex,patternIndex);
    
    // remove all gesture recognizers
    while(measureSet[patternIndex][measureIndex].gestureRecognizers.count){
        [measureSet[patternIndex][measureIndex] removeGestureRecognizer:[measureSet[patternIndex][measureIndex].gestureRecognizers objectAtIndex:0]];
    }
    
    // remove button clicks
    for(int k = 0; k < MAX_NOTES; k++){
        [noteButtons[patternIndex][measureIndex][k] removeTarget:self action:@selector(toggleNote:) forControlEvents:UIControlEventTouchUpInside];
        [noteButtons[patternIndex][measureIndex][k] removeFromSuperview];
        noteButtons[patternIndex][measureIndex][k] = nil;
    }
    
    [measureSet[patternIndex][measureIndex] removeFromSuperview];
    measureSet[patternIndex][measureIndex] = nil;
    
}

- (void)scrollToAndSetActiveMeasure:(int)measureIndex
{
    activeMeasure = measureIndex;
    [self setDeclaredActiveMeasure:measureIndex];
    
    CGPoint newOffset = CGPointMake(measureIndex*(MEASURE_WIDTH+MEASURE_MARGIN),0);
    
    [UIView animateWithDuration:1.5 animations:^(){
        [scrollView setContentOffset:newOffset];
        for(int i = 0; i < NUM_MEASURES; i++){
            if(i == measureIndex){
                [measureSet[activePattern][i] setAlpha:1.0];
            }else{
                [measureSet[activePattern][i] setAlpha:0.5];
            }
        }
    } completion:^(BOOL finished){
        
    }];
    
    
}

- (void)setDeclaredActiveMeasure:(int)measureIndex
{
    if(measureIndex < measureCounts[activePattern]){
        
        int prevIndex = declaredActiveMeasures[activePattern];
        
        declaredActiveMeasures[activePattern] = measureIndex;
        [self setActiveMeasureIndex:declaredActiveMeasures[activePattern] forPattern:activePattern];
        
        // remove old border
        measureSet[activePattern][prevIndex].layer.borderWidth = 0.0f;
        
        // draw new border
        measureSet[activePattern][measureIndex].layer.borderColor = [UIColor blackColor].CGColor;
        measureSet[activePattern][measureIndex].layer.borderWidth = 3.0f;
    }
}

- (UIView *)drawMeasureOnActive:(int)measureIndex forPattern:(int)patternIndex
{
    CGRect measureFrame = CGRectMake(3*MEASURE_MARGIN+measureIndex*(MEASURE_WIDTH+MEASURE_MARGIN), 0, MEASURE_WIDTH, scrollView.frame.size.height);
    UIView * newMeasure = [[UIView alloc] initWithFrame:measureFrame];
    
    [newMeasure setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    
    for (int s = 0; s < STRINGS_ON_GTAR; s++)
    {
        for (int f = 0; f < FRETS_ON_GTAR; f++)
        {
            CGRect noteFrame = CGRectMake(f*NOTE_WIDTH,(STRINGS_ON_GTAR-s-1)*NOTE_HEIGHT,NOTE_WIDTH,NOTE_HEIGHT);
            UIButton * newButton = [[UIButton alloc] initWithFrame:noteFrame];
            
            Pattern * p = currentInst.patterns[patternIndex];
            Measure * m = p.measures[measureIndex];
            
            if([m isNoteOnAtString:s andFret:f]){
                [newButton setBackgroundColor:colors[s]];
            }else{
                [newButton setBackgroundColor:[UIColor grayColor]];
            }
            
            newButton.layer.borderWidth = 1.0;
            newButton.layer.borderColor = [UIColor whiteColor].CGColor;
            
            [newButton addTarget:self action:@selector(toggleNote:) forControlEvents:UIControlEventTouchUpInside];
            
            noteButtons[patternIndex][measureIndex][FRETS_ON_GTAR*s+f] = newButton;
            
            [newMeasure addSubview:newButton];
            
            // default invisible
            [newMeasure setAlpha:0.0];
        }
    }
    
    [scrollView addSubview:newMeasure];
    
    
    //
    // GESTURES
    //
    
    if(measureIndex > 0){
        UIPinchGestureRecognizer * pinchMeasure = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchMeasure:)];
        [newMeasure addGestureRecognizer:pinchMeasure];
    }
    
    return newMeasure;
}

- (UIView *)drawMeasureOff:(int)measureIndex forPattern:(int)patternIndex
{
    CGRect measureFrame = CGRectMake(3*MEASURE_MARGIN+measureIndex*(MEASURE_WIDTH+MEASURE_MARGIN),0,MEASURE_WIDTH,scrollView.frame.size.height);
    UIView * newOffMeasure = [[UIView alloc] initWithFrame:measureFrame];
    
    [newOffMeasure setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0]];
    
    [scrollView addSubview:newOffMeasure];
    
    
    //
    // GESTURES
    //
    
    if(measureIndex > 0){
        UIPinchGestureRecognizer * pinchMeasure = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchMeasure:)];
        [newOffMeasure addGestureRecognizer:pinchMeasure];
    }
    
    return newOffMeasure;
}

- (void)decrementMeasure:(id)sender
{
    if(activeMeasure > 0 && freezeMeasureChange == nil){
        [self scrollToAndSetActiveMeasure:activeMeasure-1];
        
        freezeMeasureChange = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(resetFreezeMeasure) userInfo:nil repeats:NO];
    }
}

- (void)incrementMeasure:(id)sender
{
    if(activeMeasure < NUM_MEASURES-1 && freezeMeasureChange == nil){
        [self scrollToAndSetActiveMeasure:activeMeasure+1];
        
        freezeMeasureChange = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(resetFreezeMeasure) userInfo:nil repeats:NO];
    }
}

- (void)resetFreezeMeasure
{
    freezeMeasureChange = nil;
}

#pragma mark - Patterns

-(IBAction)changePattern:(id)sender
{
    changingPattern = activePattern;
    
    patternButton.titleLabel.font = [UIFont systemFontOfSize:80.0];
    
    patternTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementChangingPattern) userInfo:nil repeats:YES];
    
}

-(IBAction)stopChangePattern:(id)sender
{
    [patternTimer invalidate];
    patternTimer = nil;
    
    [self changePatternToPattern:changingPattern];
    
    // Update active measure
    [self changeActiveMeasureToMeasure:0];
}

-(void)incrementChangingPattern
{
    changingPattern = (changingPattern+1)%NUM_PATTERNS;
    [patternButton setTitle:patternTitles[changingPattern] forState:UIControlStateNormal];
    
}

-(void)changePatternToPattern:(int)patternIndex
{
    if(activePattern != patternIndex){
        [self fadeOutPattern:activePattern];
    }
    activePattern = patternIndex;
    [self drawMeasuresForPattern:activePattern];
    
    patternButton.titleLabel.font = [UIFont systemFontOfSize:40.0];
    [patternButton setTitle:patternTitles[activePattern] forState:UIControlStateNormal];
    
    [self setActivePatternIndex:activePattern];
    
    // SAVE CONTEXT
    [delegate saveContext:nil];
}

- (void)fadeOutPattern:(int)patternIndex
{
    
    [UIView animateWithDuration:1.5 animations:^(){
        for(int i = 0; i < NUM_MEASURES; i++){
            [measureSet[patternIndex][i] setAlpha:0.0];
        }
    } completion:^(BOOL finished){
        for(int i = 0; i < NUM_MEASURES; i++){
            [self clearMeasure:i forPattern:patternIndex];
        }
    }];
}

#pragma mark - Notes
- (void)toggleNote:(id)sender
{
    int string;
    int fret;
    
    for(int s = 0; s < STRINGS_ON_GTAR; s++){
        for(int f = 0; f < FRETS_ON_GTAR; f++){
            if(noteButtons[activePattern][activeMeasure][FRETS_ON_GTAR*s+f] == sender){
                fret = f;
                string = s;
                break;
            }
        }
    }
    
    Pattern * p = currentInst.patterns[activePattern];
    Measure * m = p.measures[activeMeasure];
    
    if([m isNoteOnAtString:string andFret:fret]){
        [sender setBackgroundColor:[UIColor grayColor]];
    }else{
        [sender setBackgroundColor:colors[string]];
    }
    
    [m changeNoteAtString:string andFret:fret];
    
    // SAVE CONTEXT
    [delegate saveContext:nil];
}


#pragma mark - System

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
