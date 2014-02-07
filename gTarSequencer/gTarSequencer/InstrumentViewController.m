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
#define MUTE_SEGMENT_INDEX 4

@implementation InstrumentViewController

@synthesize delegate;
@synthesize scrollView;
@synthesize instrumentTitle;
@synthesize instrumentIcon;
@synthesize patternA;
@synthesize patternB;
@synthesize patternC;
@synthesize patternD;
@synthesize offButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        activePattern = -1;
        activeMeasure = -1;
    
        patternButtons = nil;
        selectedPatternButton = nil;
        
        // prevent double scrolling of measures
        freezeMeasureChange = nil;
        
        // string colors
        [self initColors];
        
        for(int i = 0; i < NUM_PATTERNS; i++){
            declaredActiveMeasures[i] = -1;
        }
        
        [self resetPlayband];
        
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
    
    // Pattern buttons
    if(patternButtons == nil)
    {
        patternButtons = [[NSMutableArray alloc] initWithObjects:patternA, patternB, patternC, patternD, offButton, nil];
    }
    
    [self initPatternButtonUI];
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
    
    // Reset playband
    [self resetPlayband];
    
    // Measure counts
    for(int i = 0; i < NUM_PATTERNS; i++){
        Pattern * p = [inst.patterns objectAtIndex:i];
        measureCounts[i] = p.measureCount;
    }
    
    // Update active pattern and active measure
    if(activePattern < 0) activePattern = inst.selectedPatternIndex;
    if(activeMeasure < 0) activeMeasure = inst.selectedPattern.selectedMeasureIndex;
    [self changePatternToPattern:inst.selectedPatternIndex thenChangeActiveMeasure:inst.selectedPattern.selectedMeasureIndex];
    
    // Set pattern button
    [self selectPatternButton:activePattern];
    
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
    [UIView animateWithDuration:0.5 animations:^(){
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
    
    // remove playbands
    [playbandView[measureIndex] removeFromSuperview];
    playbandView[measureIndex] = nil;
    playband[measureIndex] = -1;
    
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
            [newMeasure setAlpha:0.3];
        }
    }
    
    [scrollView addSubview:newMeasure];
    
    //
    // PLAYBAND
    //
    
    NSLog(@"REDRAW PLAYBAND");
    
    CGRect playbandFrame = CGRectMake(0, 0, NOTE_WIDTH, NOTE_HEIGHT*STRINGS_ON_GTAR);
    
    playbandView[measureIndex] = [[UIView alloc] initWithFrame:playbandFrame];
    [playbandView[measureIndex] setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7]];
    [playbandView[measureIndex] setHidden:YES];
    
    [newMeasure addSubview:playbandView[measureIndex]];
    
    
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

-(void)changePatternToPattern:(int)patternIndex thenChangeActiveMeasure:(int)measureIndex
{
    // Ensure drawing does not happen before pattern is cleared
    if(activePattern != patternIndex){
        
        [self fadeOutPattern:activePattern andLoadPattern:patternIndex andLoadMeasure:measureIndex];
        
    }else{
        
        [self instateNewPattern:patternIndex andNewMeasure:measureIndex];
    
    }
}

- (void)fadeOutPattern:(int)patternIndex andLoadPattern:(int)newPattern andLoadMeasure:(int)newMeasure
{
    
    [UIView animateWithDuration:0.5 animations:^(){
        for(int i = 0; i < NUM_MEASURES; i++){
            [playbandView[i] setHidden:YES];
            [measureSet[patternIndex][i] setAlpha:0.3];
        }
    } completion:^(BOOL finished){
        for(int i = 0; i < NUM_MEASURES; i++){
            [self clearMeasure:i forPattern:patternIndex];
        }
        
        [self instateNewPattern:newPattern andNewMeasure:newMeasure];
    }];
}

- (void)instateNewPattern:(int)patternIndex andNewMeasure:(int)measureIndex
{
    activePattern = patternIndex;
    [self drawMeasuresForPattern:activePattern];
    
    //patternButton.titleLabel.font = [UIFont systemFontOfSize:40.0];
    //[patternButton setTitle:patternTitles[activePattern] forState:UIControlStateNormal];
    
    [self setActivePatternIndex:activePattern];
    
    // Update active measure (context save happens within)
    [self changeActiveMeasureToMeasure:measureIndex];
    
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

#pragma mark - Playband

- (void)resetPlayband
{
    for(int i = 0; i < NUM_MEASURES; i++){
        playband[i] = -1;
        [playbandView[i] removeFromSuperview];
        playbandView[i] = nil;
    }
}

- (void)movePlaybandForMeasure:(int)measureIndex
{
    if (playband[measureIndex] >= 0) {
        CGRect newFrame = playbandView[measureIndex].frame;
        newFrame.origin.x = playband[measureIndex] * NOTE_WIDTH;
        
        playbandView[measureIndex].frame = newFrame;
        
        [playbandView[measureIndex] setHidden:NO];
        
    } else {
        [playbandView[measureIndex] setHidden:YES];
    }
}

- (void)setPlaybandForMeasure:(int)measureIndex toPlayband:(int)p
{
    for(int i = 0; i < NUM_MEASURES; i++){
        if(i != measureIndex){
            playband[i] = -1;
        }else{
            playband[i] = p;
        }
        
        [self movePlaybandForMeasure:i];
    }
    
}

#pragma mark - Pattern Buttons

- (void)initPatternButtonUI
{
    
    for (int i=0;i<[patternButtons count];i++)
    {
        UIButton * patternN = [patternButtons objectAtIndex:i];
        patternN.layer.cornerRadius = 3.0;
        [patternN setTitleEdgeInsets:UIEdgeInsetsMake(2.0f,0.0f,0.0f,0.0f)];
    }
}

- (IBAction)userDidSelectNewPattern:(id)sender
{
    
    [self performSelector:@selector(selectNewPattern:) withObject:sender afterDelay:0.0];
}

// Split up into two functions to allow the UI to update immediately
- (void)selectNewPattern:(id)sender
{
    
    int tappedIndex = [patternButtons indexOfObject:sender];
    
    BOOL isPlaying = [delegate checkIsPlaying];;
    
    NSLog(@"Select new pattern at %i", tappedIndex);
    
    if (tappedIndex == MUTE_SEGMENT_INDEX){
        NSLog(@"Mute the instrument");
        currentInst.isMuted = YES;
        
        [self clearQueuedPatternButton];
    }else{
        currentInst.isMuted = NO;
        
        if([delegate checkIsPlaying]){
            
            // Add it to the queue:
            NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
            
            [pattern setObject:[NSNumber numberWithInt:tappedIndex] forKey:@"Index"];
            [pattern setObject:currentInst forKey:@"Instrument"];
            
            [delegate enqueuePattern:pattern];
            
        }else{
            
            [self commitPatternChange:tappedIndex];
           
        }
    }
    
    [self updatePatternButton:sender playState:isPlaying];
    
}

- (void)commitPatternChange:(int)patternIndex
{
    [self setActivePatternIndex:patternIndex];
    [self changePatternToPattern:patternIndex thenChangeActiveMeasure:0];
    
    [self updatePatternButton:patternButtons[patternIndex] playState:NO];
    [self clearQueuedPatternButton];
}

- (void)selectPatternButton:(int)index
{
    UIButton * newSelection = [patternButtons objectAtIndex:index];
    
    //if (selectedPatternButton == newSelection){
    //    NSLog(@"Already set - returning");
    //    return;
    //}else {
    //    NSLog(@"Now updating");
        [self updatePatternButton:newSelection playState:NO];
    //}
}

- (void)clearQueuedPatternButton
{
    [self setStateForButton:queuedPatternButton state:0];
    queuedPatternButton = nil;
}


- (void)updatePatternButton:(UIButton *)newButton playState:(BOOL)isPlaying
{
    if(!isPlaying || selectedPatternButton == newButton){
        
        //dequeue anything queued
        [self setStateForButton:queuedPatternButton state:0];
        queuedPatternButton = nil;
        
        //former button
        [self setStateForButton:selectedPatternButton state:0];
        selectedPatternButton = newButton;
        
        //new button
        [self setStateForButton:selectedPatternButton state:2];
        
    }else if(newButton == offButton){
        
        previousPatternButton = selectedPatternButton;
        
        //dequeue anything queued
        [self setStateForButton:queuedPatternButton state:0];
        
        //former button
        [self setStateForButton:selectedPatternButton state:0];
        selectedPatternButton = newButton;
        
        //new button
        [self setStateForButton:selectedPatternButton state:2];
        
    }else if(selectedPatternButton == offButton){
        
        //former button
        [self setStateForButton:selectedPatternButton state:0];
        
        //new button
        selectedPatternButton = previousPatternButton;
        [self setStateForButton:selectedPatternButton state:2];
        
        //queue actual button
        if(newButton != selectedPatternButton){
            queuedPatternButton = newButton;
            [self setStateForButton:queuedPatternButton state:1];
        }
        
    }else if(queuedPatternButton == nil){
        
        queuedPatternButton = newButton;
        [self setStateForButton:queuedPatternButton state:1];
        
    }else if(queuedPatternButton != nil){
        
        //former button
        [self setStateForButton:queuedPatternButton state:0];
        queuedPatternButton = newButton;
        
        // new button
        [self setStateForButton:queuedPatternButton state:1];
    }
}

- (void)notifyQueuedPatternAndResetCount:(BOOL)resetCount
{
    if(queuedPatternButton != nil){
        
        if(resetCount){
            loopModCount = 0;
        }
        
        if(loopModCount%8==3 || loopModCount%8==4){
            [self setStateForButton:queuedPatternButton state:3];
        }else{
            [self setStateForButton:queuedPatternButton state:1];
        }
        
        loopModCount++;
    }
    
}

- (void)setStateForButton:(UIButton *)button state:(int)stateindex
{
    UIColor * backgroundColor = nil;
    UIColor * titleColor = nil;
    
    switch(stateindex){
        case 0: // off
            backgroundColor = [UIColor clearColor];
            titleColor = [UIColor blackColor];
            break;
        case 1: // queued
            backgroundColor = [UIColor clearColor];
            titleColor = [UIColor orangeColor];
            break;
        case 2: // on
            backgroundColor = [UIColor clearColor];
            titleColor = [UIColor redColor];
            break;
        case 3: // queued blinking
            backgroundColor = [UIColor clearColor];
            titleColor = [UIColor purpleColor];
            break;
    }
    
    [button setBackgroundColor:backgroundColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
}

#pragma mark - System

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
