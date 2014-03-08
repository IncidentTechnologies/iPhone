//
//  InstrumentViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "InstrumentViewController.h"

#define MEASURE_WIDTH 418
#define MEASURE_MARGIN_SM 10.5
#define MEASURE_MARGIN_LG 25

#define NOTE_WIDTH 26
#define NOTE_HEIGHT 26
#define NOTE_GAP 2
#define MUTE_SEGMENT_INDEX 4
#define SCROLL_SPEED_MIN 0
#define SCROLL_SPEED_MAX 0.5

@implementation InstrumentViewController

@synthesize delegate;
@synthesize scrollView;
@synthesize instrumentIconButton;
@synthesize instrumentIcon;
@synthesize patternA;
@synthesize patternB;
@synthesize patternC;
@synthesize patternD;
@synthesize offButton;
@synthesize pageOne;
@synthesize pageTwo;
@synthesize pageThree;
@synthesize pageFour;
@synthesize offMask;
@synthesize isMute;
@synthesize customIndicator;
@synthesize backButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        activePattern = -1;
        activeMeasure = -1;
        targetMeasure = -1;
        
        patternButtons = nil;
        selectedPatternButton = nil;
        
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
    colors[5] = [UIColor colorWithRed:170/255.0 green:114/255.0 blue:233/255.0 alpha:1.0]; // purple
    colors[4] = [UIColor colorWithRed:30/255.0 green:108/255.0 blue:213/255.0 alpha:1.0]; // blue
    colors[3] = [UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0]; // green
    colors[2] = [UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]; // yellow
    colors[1] = [UIColor colorWithRed:234/255.0 green:154/255.0 blue:0/255.0 alpha:1.0]; // orange
    colors[0] = [UIColor colorWithRed:238/255.0 green:28/255.0 blue:36/255.0 alpha:1.0]; // red
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [offMask setHidden:YES];
    
    //
    // SCROLLING
    //
    
    scrollView.bounces = NO;
    scrollView.delegate = self;
    scrollView.userInteractionEnabled = YES;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [scrollView setShowsHorizontalScrollIndicator:NO];
    
    float measureMargin = [self getMeasureMargin];
    double totalWidth = NUM_MEASURES*(MEASURE_WIDTH+measureMargin)+3*measureMargin;
    double totalHeight = scrollView.frame.size.height;
    
    [scrollView setContentSize:CGSizeMake(totalWidth,totalHeight)];
    scrollView.contentOffset = CGPointMake(0,0);
    
    // Pattern buttons
    if(patternButtons == nil)
    {
        patternButtons = [[NSMutableArray alloc] initWithObjects:patternA, patternB, patternC, patternD, offButton, nil];
    }
    
    // Back button
    [self drawBackButton];
    
    // Instrument icon
    instrumentIconButton.layer.borderWidth = 0.5;
    instrumentIconButton.layer.borderColor = [UIColor whiteColor].CGColor;
    instrumentIconButton.layer.cornerRadius = 5.0;
    
    // Pages
    [self initPages];
    
}

- (void)initPages
{
    pages[0] = pageOne;
    pages[1] = pageTwo;
    pages[2] = pageThree;
    pages[3] = pageFour;
    
    for(int i = 0; i < NUM_MEASURES; i++){
        pages[i].layer.cornerRadius = 7.5;
        pages[i].alpha = 0.4;
    }
}

- (void)reopenView
{
    // Clear previous pattern data
    if(activePattern > 0){
        NSLog(@"Clear previous pattern data");
        
        @synchronized(self){
            for(int i = 0; i < NUM_PATTERNS; i++){
                for(int j = 0; j < NUM_MEASURES; j++){
                    [self clearMeasure:j forPattern:i];
                }
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
    NSLog(@"Set Active Measure Index m:%i, p:%i, i:%@",measureIndex,patternIndex,currentInst);
    
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
- (IBAction)viewSeqSet:(id)sender
{
    [delegate viewSeqSetWithAnimation:NO];
}

- (void)setActiveInstrument:(Instrument *)inst
{
 
    if(inst == NULL){
        // TODO: handle 0 instruments case
        return;
    }
 
    currentInst = inst;
    
    // Icon
    [instrumentIcon setImage:[UIImage imageNamed:inst.iconName]];
    
    // Reset playband
    [self resetPlayband];
    
    // Clear everything
    @synchronized(self){
        for(int i = 0; i < NUM_PATTERNS; i++){
            for(int j = 0; j < NUM_MEASURES; j++){
                [self clearMeasure:j forPattern:i];
            }
        }
    }
    
    // Measure counts
    @synchronized(self){
        for(int i = 0; i < NUM_PATTERNS; i++){
            Pattern * p = [inst.patterns objectAtIndex:i];
            measureCounts[i] = p.measureCount;
        }
    }
    
    // Custom Indicator
    [self showHideCustomIndicator:[currentInst checkIsCustom]];

    // Update active pattern and active measure
    activePattern = inst.selectedPatternIndex;
    activeMeasure = inst.selectedPattern.selectedMeasureIndex;
    [self changePatternToPattern:inst.selectedPatternIndex thenChangeActiveMeasure:inst.selectedPattern.selectedMeasureIndex];
    
    // Set pattern button
    [self selectPatternButton:activePattern];
    
    // Determine if there is a queued pattern
    int queuedIndex = [delegate getQueuedPatternIndexForInstrument:currentInst];
    if(queuedIndex >= 0){
        NSLog(@"Enqueue pattern button for newly added instrument");
        [self enqueuePatternButton:queuedIndex];
    }
    
    // Determine on or off
    isMute = inst.isMuted;
    if(isMute){
        [self turnOffInstrumentView];
    }else{
        [self turnOnInstrumentView];
    }
    
    NSLog(@"Using pattern %i and measure %i",activePattern,activeMeasure);
}

- (void)showHideCustomIndicator:(BOOL)isCustom
{
    customIndicator.layer.cornerRadius = customIndicator.frame.size.width/2;
    if(isCustom){
        [customIndicator setHidden:NO];
    }else{
        [customIndicator setHidden:YES];
    }
}

#pragma mark - Measures
- (void)changeActiveMeasureToMeasure:(int)measureIndex scrollSlow:(BOOL)isSlow
{
    [self scrollToAndSetActiveMeasure:measureIndex scrollSlow:isSlow];
    
    // SAVE CONTEXT
    [delegate saveContext:nil];
}

- (void)drawMeasuresForPattern:(int)patternIndex
{
    
    @synchronized(self){
        for(int i = 0; i < NUM_MEASURES; i++){
            
            UIView * newMeasure = [[UIView alloc] init];
            
            if(i < measureCounts[activePattern]){
                newMeasure = [self drawMeasureOnActive:i forPattern:activePattern];
            }else{
                newMeasure = [self drawMeasureOff:i forPattern:activePattern];
            }
                
            measureSet[activePattern][i] = newMeasure;
        }
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
    
    scrollView.scrollEnabled = NO;
    
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
                    
                    [self changeActiveMeasureToMeasure:0 scrollSlow:YES];
                    
                    break;
                case 2:
                case 3:
                    NSLog(@"DEACTIVATE %i",activeMeasure);
                    
                    [self clearMeasure:2 forPattern:activePattern];
                    [self clearMeasure:3 forPattern:activePattern];
                    
                    [self setMeasureCountTo:2 forPattern:activePattern];
                    
                    measureSet[activePattern][2] = [self drawMeasureOff:2 forPattern:activePattern];
                    measureSet[activePattern][3] = [self drawMeasureOff:3 forPattern:activePattern];
                    
                    [self changeActiveMeasureToMeasure:1 scrollSlow:YES];
                    
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
            
            [self changeActiveMeasureToMeasure:activeMeasure scrollSlow:YES];
            
            // SAVE CONTEXT
            [delegate saveContext:nil];
        }
    }
}

- (void)clearMeasure:(int)measureIndex forPattern:(int)patternIndex
{
    NSLog(@"Clear measure %i at pattern %i",measureIndex,patternIndex);
    
    @synchronized(self){
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
}

- (void)setDeclaredActiveMeasure:(int)measureIndex
{
    if(measureIndex < measureCounts[activePattern]){
        
        int prevIndex = declaredActiveMeasures[activePattern];
        
        declaredActiveMeasures[activePattern] = measureIndex;
        [self setActiveMeasureIndex:declaredActiveMeasures[activePattern] forPattern:activePattern];
        
        // remove old border
        if(prevIndex >= 0){
            measureSet[activePattern][prevIndex].layer.borderWidth = 0.0f;
        }
            
        // draw new border
        measureSet[activePattern][measureIndex].layer.borderColor = [UIColor whiteColor].CGColor;
        measureSet[activePattern][measureIndex].layer.borderWidth = 0.5f;
        
        [measureSet[activePattern][measureIndex] setAlpha:1.0];
    }
}

- (UIView *)drawMeasureOnActive:(int)measureIndex forPattern:(int)patternIndex
{

    float measureMargin = [self getMeasureMargin];
    
    CGRect measureFrame = CGRectMake(3*measureMargin+measureIndex*(MEASURE_WIDTH+measureMargin), 0, MEASURE_WIDTH, scrollView.frame.size.height);
    UIView * newMeasure = [[UIView alloc] initWithFrame:measureFrame];
    
    [newMeasure setBackgroundColor:[UIColor colorWithRed:29/255.0 green:88/255.0 blue:103/255.0 alpha:1.0]];
    
    @synchronized(self)
    {
        for (int s = 0; s < STRINGS_ON_GTAR; s++)
        {
            for (int f = 0; f < FRETS_ON_GTAR; f++)
            {
                CGRect noteFrame = CGRectMake(NOTE_GAP+f*NOTE_WIDTH,NOTE_GAP+(STRINGS_ON_GTAR-s-1)*NOTE_HEIGHT,NOTE_WIDTH-NOTE_GAP,NOTE_HEIGHT-NOTE_GAP);
                UIButton * newButton = [[UIButton alloc] initWithFrame:noteFrame];
                
                Pattern * p = currentInst.patterns[patternIndex];
                Measure * m = p.measures[measureIndex];
                
                if([m isNoteOnAtString:s andFret:f]){
                    [newButton setBackgroundColor:colors[s]];
                }else{
                    [newButton setBackgroundColor:[UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
                }
                
                newButton.layer.borderWidth = 0.5;
                newButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6].CGColor;
                
                [newButton addTarget:self action:@selector(toggleNote:) forControlEvents:UIControlEventTouchUpInside];
                
                noteButtons[patternIndex][measureIndex][FRETS_ON_GTAR*s+f] = newButton;
                
                [newMeasure addSubview:newButton];
            }
        }
    }
    
    // default invisible
    [newMeasure setAlpha:0.3];
    
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
    float measureMargin = [self getMeasureMargin];
    
    CGRect measureFrame = CGRectMake(3*measureMargin+measureIndex*(MEASURE_WIDTH+measureMargin),0,MEASURE_WIDTH,scrollView.frame.size.height);
    UIView * newOffMeasure = [[UIView alloc] initWithFrame:measureFrame];
    
    [newOffMeasure setBackgroundColor:[UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
    
    [scrollView addSubview:newOffMeasure];
    
    // Title
    float labelWidth = 300;
    float labelHeight = 80;
    CGRect labelFrame = CGRectMake(measureFrame.size.width/2-labelWidth/2,measureFrame.size.height/2-labelHeight/2,labelWidth,labelHeight);
    UILabel * offMeasureLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    offMeasureLabel.textAlignment = NSTextAlignmentCenter;
    offMeasureLabel.numberOfLines = 3;
    
    [offMeasureLabel setFont:[UIFont systemFontOfSize:16.0]];
    [offMeasureLabel setTextColor:[UIColor colorWithRed:1 green:1 blue: 1 alpha:0.3]];
    [offMeasureLabel setText:@"EXPAND TO ADD \n\n PINCH TO DELETE"];
    
    [newOffMeasure addSubview:offMeasureLabel];
    
    
    //
    // GESTURES
    //
    
    if(measureIndex > 0){
        UIPinchGestureRecognizer * pinchMeasure = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchMeasure:)];
        [newOffMeasure addGestureRecognizer:pinchMeasure];
    }
    
    return newOffMeasure;
}

- (void)updateActiveMeasure
{
    // Redraw measure
    [self clearMeasure:activeMeasure forPattern:activePattern];
    UIView * newMeasure = [[UIView alloc] init];
    newMeasure = [self drawMeasureOnActive:activeMeasure forPattern:activePattern];
    measureSet[activePattern][activeMeasure] = newMeasure;
    
    // The measure the guitar is editing is always the active measure
    [self setDeclaredActiveMeasure:activeMeasure];
}

- (void)updateGuitarView
{
    [currentInst.selectedPattern.selectedMeasure turnOnGuitarFlags];
    [delegate setMeasureAndUpdate:currentInst.selectedPattern.selectedMeasure checkNotPlaying:NO];
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
        @synchronized(self){
            for(int i = 0; i < NUM_MEASURES; i++){
                [self clearMeasure:i forPattern:patternIndex];
            }
        }
        
        [self instateNewPattern:newPattern andNewMeasure:newMeasure];
    }];
}

- (void)instateNewPattern:(int)patternIndex andNewMeasure:(int)measureIndex
{
    activePattern = patternIndex;
    [self drawMeasuresForPattern:activePattern];
    
    [self setActivePatternIndex:activePattern];
    
    // Update active measure (context save happens within)
    [self changeActiveMeasureToMeasure:measureIndex scrollSlow:YES];
    
}

#pragma mark - On Off
- (void)turnOnInstrumentView
{
    [offMask setHidden:YES];
    isMute = NO;
}

- (void)turnOffInstrumentView
{
    [offMask setHidden:NO];
    isMute = YES;
}


#pragma mark - Notes
- (void)toggleNote:(id)sender
{
    int string;
    int fret;
    
    @synchronized(self){
        for(int s = 0; s < STRINGS_ON_GTAR; s++){
            for(int f = 0; f < FRETS_ON_GTAR; f++){
                if(noteButtons[activePattern][activeMeasure][FRETS_ON_GTAR*s+f] == sender){
                    fret = f;
                    string = s;
                    break;
                }
            }
        }
    }
    
    if(string > STRINGS_ON_GTAR || fret > FRETS_ON_GTAR){
        NSLog(@"ERROR with string %i or fret %i",string,fret);
        return;
    }
    
    Pattern * p = currentInst.patterns[activePattern];
    Measure * m = p.measures[activeMeasure];
    
    if([m isNoteOnAtString:string andFret:fret]){
        [sender setBackgroundColor:[UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
    }else{
        [sender setBackgroundColor:colors[string]];
    }
    
    [m changeNoteAtString:string andFret:fret];
    [self updateGuitarView];
    
    // SAVE CONTEXT
    [delegate saveContext:nil];
}

#pragma mark - Playband

- (void)resetPlayband
{
    @synchronized(self){
        for(int i = 0; i < NUM_MEASURES; i++){
            playband[i] = -1;
            [playbandView[i] removeFromSuperview];
            playbandView[i] = nil;
        }
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

- (IBAction)userDidSelectNewPattern:(id)sender
{
    [self performSelector:@selector(selectNewPattern:) withObject:sender afterDelay:0.0];
}

// Split up into two functions to allow the UI to update immediately
- (void)selectNewPattern:(id)sender
{
    int tappedIndex = [patternButtons indexOfObject:sender];
    
    BOOL isPlaying = [delegate checkIsPlaying];
    
    NSLog(@"Inst Select new pattern at %i", tappedIndex);
    
    if (tappedIndex == MUTE_SEGMENT_INDEX && selectedPatternButton != offButton){
        isMute = YES;
        isPlaying = [delegate checkIsPlaying];
        [self clearQueuedPatternButton];
        [delegate dequeueAllPatternsForInstrument:currentInst];
    }else if(tappedIndex == MUTE_SEGMENT_INDEX && selectedPatternButton == offButton){
        isMute = NO;
        isPlaying = [delegate checkIsPlaying];
        [self clearQueuedPatternButton];
        [delegate dequeueAllPatternsForInstrument:currentInst];
    }else{
        
        isMute = NO;
        
        if(isPlaying && tappedIndex != activePattern){
            
            NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
            [pattern setObject:[NSNumber numberWithInt:tappedIndex] forKey:@"Index"];
            [pattern setObject:currentInst forKey:@"Instrument"];
            
            [delegate enqueuePattern:pattern];
            
        }else if(tappedIndex == activePattern){
            
            [delegate dequeueAllPatternsForInstrument:currentInst];
            
            [self commitPatternChange:tappedIndex];
        }else{
            
            [self commitPatternChange:tappedIndex];
        }
        
        
    }
    
    currentInst.isMuted = isMute;
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

- (void)enqueuePatternButton:(int)index
{
    UIButton * newButton = [patternButtons objectAtIndex:index];
    
    queuedPatternButton = newButton;
    [self setStateForButton:queuedPatternButton state:1];
    
}

- (void)clearQueuedPatternButton
{
    [self setStateForButton:queuedPatternButton state:0];
    queuedPatternButton = nil;
}


- (void)updatePatternButton:(UIButton *)newButton playState:(BOOL)isPlaying
{
    
    // First check if switching off
    if(newButton == offButton && selectedPatternButton != offButton){
        [self turnOffInstrumentView];
    }else{
        [self turnOnInstrumentView];
    }
    
    // Adjust pattern buttons
    if(newButton == offButton && selectedPatternButton == offButton){
        
        //former button
        [self setStateForButton:selectedPatternButton state:0];
        
        //new button
        selectedPatternButton = previousPatternButton;
        [self setStateForButton:selectedPatternButton state:2];
        
        // queue nothing
    }else if(newButton == offButton){
        
        previousPatternButton = selectedPatternButton;
        
        //dequeue anything queued
        [self setStateForButton:queuedPatternButton state:0];
        
        //former button
        //[self setStateForButton:selectedPatternButton state:0];
        selectedPatternButton = newButton;
        
        //new button
        [self setStateForButton:selectedPatternButton state:2];
        
    }else if(!isPlaying || selectedPatternButton == newButton){
        
        //dequeue anything queued
        [self setStateForButton:queuedPatternButton state:0];
        queuedPatternButton = nil;
        
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
            titleColor = [UIColor whiteColor];
            break;
        case 1: // queued
            backgroundColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:0.5];
            titleColor = [UIColor whiteColor];
            break;
        case 2: // on
            if(button == offButton){
                backgroundColor = [UIColor clearColor];
            }else{
                backgroundColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
            }
            titleColor = [UIColor whiteColor];
            break;
        case 3: // queued blinking
            backgroundColor = [UIColor clearColor];
            titleColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8];
            break;
    }
    
    [button setBackgroundColor:backgroundColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
}

#pragma mark - Scrolling
- (void)scrollToAndSetActiveMeasure:(int)measureIndex scrollSlow:(BOOL)isSlow
{
    activeMeasure = measureIndex;
    [self setDeclaredActiveMeasure:measureIndex];
    
    float measureMargin = [self getMeasureMargin];
    
    CGPoint newOffset = CGPointMake(measureIndex*(MEASURE_WIDTH+measureMargin),0);
    double scrollSpeed = isSlow ? SCROLL_SPEED_MAX : SCROLL_SPEED_MIN;
    
    [UIView animateWithDuration:scrollSpeed animations:^(){
        [scrollView setContentOffset:newOffset];
        for(int i = 0; i < NUM_MEASURES; i++){
            if(i == measureIndex){
                [measureSet[activePattern][i] setAlpha:1.0];
            }else{
                [measureSet[activePattern][i] setAlpha:0.5];
            }
        }
    } completion:^(BOOL finished){
        for(int i=0; i<NUM_MEASURES;i++){
            if(i == measureIndex){
                pages[i].alpha = 1.0;
            }else{
                pages[i].alpha = 0.4;
            }
        }
        scrollView.scrollEnabled = YES;
        
        [self updateGuitarView];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroller
{
    targetMeasure = MAX(targetMeasure,0);
    [self snapScrollerToPlace:scroller];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scroller
{
    scrollView.scrollEnabled = NO;
    scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scroller willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        targetMeasure = MAX(targetMeasure,0);
        [self snapScrollerToPlace:scroller];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scroller
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scroller
{
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scroller withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    // First check how swipes interfere with left nav
    if(activeMeasure == 0 && velocity.x <= 0 && targetContentOffset->x <= 0 && lastContentOffset.x == 0 && ![delegate isLeftNavOpen]){
        
        [delegate openLeftNavigator];
        targetMeasure = activeMeasure;
        
    }else if([delegate isLeftNavOpen]){
        
        [delegate closeLeftNavigator];
        //velocity = CGPointMake(0, 0);
        targetMeasure = activeMeasure;
        
    }else{
        
        // Determine a target measure to scroll to
        double velocityOffset = floor(abs(velocity.x)/3.0)+1;
        
        if(scrollView.contentOffset.x > lastContentOffset.x){
            targetMeasure = MIN(activeMeasure+velocityOffset,NUM_MEASURES-1);
        }else if(scrollView.contentOffset.x < lastContentOffset.x){
            targetMeasure = MAX(activeMeasure-velocityOffset,0);
        }
        
        CGPoint newOffset = CGPointMake(targetMeasure*(MEASURE_WIDTH+[self getMeasureMargin]),0);
        
        targetContentOffset->x = newOffset.x;
        lastContentOffset.x = newOffset.x;
    }
    
}

- (void)snapScrollerToPlace:(UIScrollView *)scroller
{
    [self changeActiveMeasureToMeasure:targetMeasure scrollSlow:NO];
}

- (float)getMeasureMargin
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float measureMargin = (screenBounds.size.height == XBASE_LG) ? MEASURE_MARGIN_LG : MEASURE_MARGIN_SM;
    
    return measureMargin;
}

#pragma mark - Other Drawing
-(void)drawBackButton
{
    CGSize size = CGSizeMake(backButton.frame.size.width, backButton.frame.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0); // use this to antialias
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int playWidth = 12;
    int playX = backButton.frame.size.width;
    int marginX = 6;
    int playY = 5;
    CGFloat playHeight = backButton.frame.size.height - 2*playY;
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 4.0);
    
    CGContextMoveToPoint(context, playX-marginX, playY);
    CGContextAddLineToPoint(context, playX-marginX-playWidth, playY+(playHeight/2));
    CGContextAddLineToPoint(context, playX-marginX, playY+playHeight);
    //CGContextClosePath(context);
    //CGContextFillPath(context);
    CGContextStrokePath(context);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView * image = [[UIImageView alloc] initWithImage:newImage];
    
    [backButton addSubview:image];
    
    UIGraphicsEndImageContext();
}


#pragma mark - System

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
