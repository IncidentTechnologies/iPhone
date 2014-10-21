//
//  InstrumentViewController.m
//  Sequence
//
//  Created by Kate Schnippering on 2/4/14.
//  Copyright (c) 2014 Incident Technologies. All rights reserved.
//

#import "InstrumentViewController.h"

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

#define MEASURE_WIDTH 480
#define MEASURE_MARGIN_SM 0
#define MEASURE_MARGIN_LG 14.7

#define NOTE_WIDTH 30
#define NOTE_HEIGHT 30
#define NOTE_GAP 2
#define MUTE_SEGMENT_INDEX 4
#define SCROLL_SPEED_MIN 0
#define SCROLL_SPEED_MAX 0.3

#define PAGE_OPACITY_OFF 0.3
#define PAGE_OPACITY_MID 0.5
#define PAGE_OPACITY_ON 1.0

@implementation InstrumentViewController

@synthesize tutorialViewController;
@synthesize isFirstLaunch;
@synthesize delegate;
@synthesize scrollView;
@synthesize instrumentIconButton;
@synthesize instrumentIcon;
@synthesize iconOverlap;
@synthesize patternA;
@synthesize patternB;
@synthesize patternC;
@synthesize patternD;
@synthesize offButton;
@synthesize volumeKnob;
@synthesize volumeKnobView;
@synthesize pageOne;
@synthesize pageTwo;
@synthesize pageThree;
@synthesize pageFour;
@synthesize offMask;
@synthesize isMute;
@synthesize customIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        activePattern = -1;
        activeMeasure = -1;
        targetMeasure = -1;
        measureToDelete = -1;
        
        patternButtons = nil;
        selectedPatternButton = nil;
        
        // string colors
        [self initColors];
        
        for(int i = 0; i < NUM_PATTERNS; i++){
            declaredActiveMeasures[i] = -1;
        }
        
        [self resetPlayband];
        
    }
    return self;
}

- (void)initColors
{
    colors[5] = [UIColor colorWithRed:148/255.0 green:102/255.0 blue:177/255.0 alpha:1.0]; // purple
    colors[4] = [UIColor colorWithRed:0/255.0 green:141/255.0 blue:218/255.0 alpha:1.0]; // blue
    colors[3] = [UIColor colorWithRed:43/255.0 green:198/255.0 blue:34/255.0 alpha:1.0]; // green
    colors[2] = [UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]; // yellow
    colors[1] = [UIColor colorWithRed:234/255.0 green:154/255.0 blue:41/255.0 alpha:1.0]; // orange
    colors[0] = [UIColor colorWithRed:239/255.0 green:92/255.0 blue:53/255.0 alpha:1.0]; // red
    
    /*
     
     colors[5] = [UIColor colorWithRed:170/255.0 green:114/255.0 blue:233/255.0 alpha:1.0]; // blue
     colors[4] = [UIColor colorWithRed:30/255.0 green:108/255.0 blue:213/255.0 alpha:1.0]; // blue
     colors[3] = [UIColor colorWithRed:5/255.0 green:195/255.0 blue:77/255.0 alpha:1.0]; // green
     colors[2] = [UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]; // yellow
     colors[1] = [UIColor colorWithRed:234/255.0 green:154/255.0 blue:0/255.0 alpha:1.0]; // orange
     colors[0] = [UIColor colorWithRed:238/255.0 green:28/255.0 blue:36/255.0 alpha:1.0]; // red
     
     */
    
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
    [self initVolumeKnob];
    
    if(patternButtons == nil)
    {
        patternButtons = [[NSMutableArray alloc] initWithObjects:patternA, patternB, patternC, patternD, offButton, nil];
    }
    
    // Measures
    for(int j = 0; j < NUM_MEASURES; j++){
        activeMeasureSet[j] = [self drawActiveMeasures:j];
        inactiveMeasureSet[j] = [self drawInactiveMeasures:j];
    }
    
    // Back button
    // [self drawBackButton];
    
    // Instrument icon
    instrumentIconButton.layer.borderWidth = 0.5;
    instrumentIconButton.layer.borderColor = [UIColor whiteColor].CGColor;
    instrumentIconButton.layer.cornerRadius = 5.0;
    
    iconOverlap.layer.borderWidth = 0.5;
    iconOverlap.layer.borderColor = [UIColor whiteColor].CGColor;
    iconOverlap.layer.cornerRadius = 5.0;
    
    // Pages
    [self initPages];
    
    [self checkIsFirstLaunch];
    if(isFirstLaunch){
        [self launchFTUTutorial];
    }
    
}

- (void)initPages
{
    pageOnColor = [UIColor colorWithRed:108/255.0 green:192/255.0 blue:214/255.0 alpha:1.0];
    pageOffColor = [UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0];
    
    pages[0] = pageOne;
    pages[1] = pageTwo;
    pages[2] = pageThree;
    pages[3] = pageFour;
    
    for(int i = 0; i < NUM_MEASURES; i++){
        pages[i].alpha = PAGE_OPACITY_OFF;
        
        if(i < measureCounts[activePattern]){
            [pages[i] setBackgroundColor:pageOnColor];
        }else{
            [pages[i] setBackgroundColor:pageOffColor];
        }
        
        //
        // GESTURES
        //
        
        if(i > 0){
            
            // Double tap on
            UITapGestureRecognizer * doubleTapPage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapPage:)];
            doubleTapPage.numberOfTapsRequired = 2;
            
            [pages[i] addGestureRecognizer:doubleTapPage];
            
            // Long press off
            UILongPressGestureRecognizer * longPressPage = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressPage:)];
            longPressPage.minimumPressDuration = 0.5;
            
            [pages[i] addGestureRecognizer:longPressPage];
        }
    }
}

- (void)reopenView
{
    // Clear previous pattern data
    /*if(activePattern > 0){
     DLog(@"Clear previous pattern data");
     
     @synchronized(self){
     for(int i = 0; i < NUM_PATTERNS; i++){
     for(int j = 0; j < NUM_MEASURES; j++){
     [self clearMeasure:j forPattern:i];
     }
     }
     }
     }*/
    
    [self checkIsFirstLaunch];
    if(isFirstLaunch){
        [self launchFTUTutorial];
    }
}

#pragma mark - Instrument Updates
- (void)setMeasureCountTo:(int)measureCount forPattern:(int)patternIndex
{
    NSPattern * p = [currentTrack.m_patterns objectAtIndex:patternIndex];
    
    if(measureCount < measureCounts[patternIndex]){
        
        [p halveMeasures];
        if(measureCount == measureCounts[patternIndex]/4){
            [p halveMeasures];
        }
        
    }else if(measureCount > measureCounts[patternIndex]){
        
        [p doubleMeasures:YES];
        if(measureCount == measureCounts[patternIndex]*4){
            [p doubleMeasures:YES];
        }
    }
    
    measureCounts[patternIndex] = measureCount;
}

- (void)setActiveMeasureIndex:(int)measureIndex forPattern:(int)patternIndex
{
    DLog(@"Set Active Measure Index m:%i, p:%i, i:%@",measureIndex,patternIndex,currentTrack.m_instrument);
    
    NSPattern * p = [currentTrack.m_patterns objectAtIndex:patternIndex];
    NSMeasure * m = [p.m_measures objectAtIndex:measureIndex];
    
    [p setSelectedMeasure:m];
    [p setSelectedMeasureIndex:measureIndex];
}

- (void)setActivePatternIndex:(int)patternIndex
{
    [currentTrack setSelectedPatternIndex:patternIndex];
    [currentTrack setSelectedPattern:currentTrack.m_patterns[patternIndex]];
}

#pragma mark - Instruments
- (IBAction)viewSeqSet:(id)sender
{
    [delegate viewSeqSetWithAnimation:NO];
}

- (void)setActiveTrack:(NSTrack *)track
{
    
    if(track == NULL){
        // TODO: handle 0 instruments case
        return;
    }
    
    currentTrack = track;
    
    // Check muting before patterns
    BOOL toMute = track.m_muted;
    
    // Icon
    [instrumentIcon setImage:[UIImage imageNamed:track.m_instrument.m_iconName]];
    
    // Reset playband
    [self resetPlayband];
    
    // Clear everything
    /*@synchronized(self){
     for(int i = 0; i < NUM_PATTERNS; i++){
     for(int j = 0; j < NUM_MEASURES; j++){
     [self clearMeasure:j forPattern:i];
     }
     }
     }*/
    
    // Measure counts
    @synchronized(self){
        for(int i = 0; i < NUM_PATTERNS; i++){
            NSPattern * p = [track.m_patterns objectAtIndex:i];
            measureCounts[i] = p.measureCount;
        }
    }
    
    // Custom Indicator
    [self showHideCustomIndicator:currentTrack.m_instrument.m_custom];
    
    // Update active pattern and active measure
    activePattern = track.selectedPatternIndex;
    activeMeasure = track.selectedPattern.selectedMeasureIndex;
    [self changePatternToPattern:track.selectedPatternIndex thenChangeActiveMeasure:track.selectedPattern.selectedMeasureIndex];
    
    // Set pattern button
    [self selectPatternButton:activePattern];
    
    // Determine if there is a queued pattern
    int queuedIndex = [delegate getQueuedPatternIndexForTrack:currentTrack];
    if(queuedIndex >= 0){
        DLog(@"Enqueue pattern button for newly added instrument");
        [self enqueuePatternButton:queuedIndex];
    }
    
    [volumeKnob SetValue:currentTrack.m_level];
    
    // Determine on or off
    isMute = toMute;
    if(isMute){
        [self turnOffInstrumentView];
    }else{
        [self turnOnInstrumentView];
    }
    
    DLog(@"Using pattern %i and measure %i",activePattern,activeMeasure);
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
    [delegate saveStateToDiskWithForce:NO];
}

- (void)drawMeasuresForPattern:(int)patternIndex
{
    
    @synchronized(self){
        for(int i = 0; i < NUM_MEASURES; i++){
            
            BOOL isActive = (i == activeMeasure) ? YES : NO;
            
            if(i < measureCounts[activePattern]){
                [self setMeasureOnActive:i forPattern:activePattern isActive:isActive];
            }else{
                [self setMeasureOff:i isActive:isActive];
            }
        }
    }
}

- (void)doubletapMeasure:(UITapGestureRecognizer *)recognizer
{
    DLog(@"Double tap measure");
    
    UIView * tappedMeasure = (UIView *)recognizer.view;
    
    for(int i = 0; i <NUM_MEASURES; i++){
        if(inactiveMeasureSet[i] == tappedMeasure){
            if(i < measureCounts[activePattern]){
                [self setNewMeasureFromPage:i];
            }else{
                [self activateMeasure:i];
            }
            
            return;
        }
    }
}

- (void)doubleTapPage:(UITapGestureRecognizer *)recognizer
{
    DLog(@"Double tap page");
    
    UIButton * tappedPage = (UIButton *)recognizer.view;
    
    if(measureToDelete > -1){
        [self hideDeleteForMeasure:measureToDelete];
    }
    
    for(int i =0; i < NUM_MEASURES; i++){
        if(pages[i] == tappedPage){
            [self activateMeasure:i];
            return;
        }
    }
}

- (void)longPressPage:(UILongPressGestureRecognizer *)recognizer
{
    DLog(@"Long press page");
    
    UIButton * pressedPage = (UIButton *)recognizer.view;
    
    for(int i = 0; i < NUM_MEASURES; i++){
        if(pages[i] == pressedPage){
            
            if(measureToDelete != i && measureToDelete > -1){
                [self hideDeleteForMeasure:measureToDelete];
            }
            
            [self showDeleteForMeasure:i];
            return;
        }
    }
}

- (void)activateMeasure:(int)tappedIndex
{
    // measure is inactive
    if(tappedIndex >= measureCounts[activePattern]){
        
        switch (tappedIndex) {
            case 1:
                DLog(@"ACTIVATE %i",tappedIndex);
                
                //[self clearMeasure:1 forPattern:activePattern];
                
                // These must be called before drawing the measure so data is up to date
                [self setMeasureCountTo:2 forPattern:activePattern];
                
                [self setMeasureOnActive:1 forPattern:activePattern isActive:YES];
                
                break;
            case 2:
            case 3:
                DLog(@"ACTIVATE %i",tappedIndex);
                
                BOOL isMeasure2Active = (tappedIndex == 2) ? YES : NO;
                BOOL isMeasure3Active = (tappedIndex == 3) ? YES : NO;
                
                if(measureCounts[activePattern] < 2){
                    
                    //[self clearMeasure:1 forPattern:activePattern];
                    //[self clearMeasure:2 forPattern:activePattern];
                    //[self clearMeasure:3 forPattern:activePattern];
                    
                    [self setMeasureCountTo:4 forPattern:activePattern];
                    
                    [self setMeasureOnActive:1 forPattern:activePattern isActive:NO];
                    [self setMeasureOnActive:2 forPattern:activePattern isActive:isMeasure2Active];
                    [self setMeasureOnActive:3 forPattern:activePattern isActive:isMeasure3Active];
                    
                }else{
                    //[self clearMeasure:2 forPattern:activePattern];
                    //[self clearMeasure:3 forPattern:activePattern];
                    
                    [self setMeasureCountTo:4 forPattern:activePattern];
                    
                    [self setMeasureOnActive:2 forPattern:activePattern isActive:isMeasure2Active];
                    [self setMeasureOnActive:3 forPattern:activePattern isActive:isMeasure3Active];
                }
                
                break;
        }
        
        [self changeActiveMeasureToMeasure:tappedIndex scrollSlow:YES];
        
        // SAVE CONTEXT
        [delegate saveStateToDiskWithForce:NO];
    }
}

- (void)showDeleteForMeasure:(int)measureIndex
{
    if(measureToDelete > -1 && measureToDelete != measureIndex){
        [self hideDeleteForMeasure:measureToDelete];
    }
    
    if(measureIndex != activeMeasure){
        [self setNewMeasureFromPage:measureIndex];
    }
    
    if(measureIndex < measureCounts[activePattern] && measureToDelete != measureIndex){
        measureToDelete = measureIndex;
        
        [pages[measureIndex] setBackgroundColor:[UIColor colorWithRed:216/255.0 green:64/255.0 blue:64/255.0 alpha:1.0]];
        
        UIImageView * trashButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Trash_Icon"]];
        
        float trashWidth = 22;
        float trashHeight = 26;
        
        [trashButton setFrame:CGRectMake(pages[measureIndex].frame.size.width/2-trashWidth/2,2,trashWidth,trashHeight)];
        
        [pages[measureIndex] addSubview:trashButton];
    }
}

- (void)hideDeleteForMeasure:(int)measureIndex
{
    
    if(measureIndex == activeMeasure){
        pages[measureIndex].alpha = PAGE_OPACITY_ON;
    }else{
        pages[measureIndex].alpha = PAGE_OPACITY_OFF;
    }
    
    if(measureIndex < measureCounts[activePattern]){
        [pages[measureIndex] setBackgroundColor:pageOnColor];
    }else{
        [pages[measureIndex] setBackgroundColor:pageOffColor];
    }
    
    for(UIView * v in pages[measureIndex].subviews){
        [v removeFromSuperview];
    }
    
    measureToDelete = -1;
    
}



- (void)setActivePage:(int)measureIndex
{
    // pagination
    for(int i=0; i<NUM_MEASURES;i++){
        
        if(i == measureIndex){
            pages[i].alpha = PAGE_OPACITY_ON;
        }else{
            pages[i].alpha = PAGE_OPACITY_OFF;
        }
        
        if(i != measureToDelete){
            for(UIView * v in pages[i].subviews){
                [v removeFromSuperview];
            }
            
            if(i < measureCounts[activePattern]){
                [pages[i] setBackgroundColor:pageOnColor];
            }else{
                [pages[i] setBackgroundColor:pageOffColor];
            }
        }
        
    }
}


- (void)deactivateMeasure:(int)tappedIndex
{
    
    //scrollView.scrollEnabled = NO;
    
    // measure is active
    if(tappedIndex < measureCounts[activePattern]){
        
        switch(tappedIndex){
            case 1:
                DLog(@"DEACTIVATE %i",tappedIndex);
                
                if(measureCounts[activePattern] > 2){
                    
                    //[self clearMeasure:1 forPattern:activePattern];
                    //[self clearMeasure:2 forPattern:activePattern];
                    //[self clearMeasure:3 forPattern:activePattern];
                    
                    [self setMeasureCountTo:1 forPattern:activePattern];
                    
                    [self setMeasureOff:1 isActive:NO];
                    [self setMeasureOff:2 isActive:NO];
                    [self setMeasureOff:3 isActive:NO];
                    
                }else{
                    
                    //[self clearMeasure:1 forPattern:activePattern];
                    
                    [self setMeasureCountTo:1 forPattern:activePattern];
                    
                    [self setMeasureOff:1 isActive:NO];
                }
                
                [self changeActiveMeasureToMeasure:0 scrollSlow:YES];
                
                break;
            case 2:
            case 3:
                DLog(@"DEACTIVATE %i",tappedIndex);
                
                //[self clearMeasure:2 forPattern:activePattern];
                //[self clearMeasure:3 forPattern:activePattern];
                
                [self setMeasureCountTo:2 forPattern:activePattern];
                
                [self setMeasureOff:2 isActive:NO];
                [self setMeasureOff:3 isActive:NO];
                
                [self changeActiveMeasureToMeasure:1 scrollSlow:YES];
                
                break;
        }
        
        [self hideDeleteForMeasure:tappedIndex];
        
        // SAVE CONTEXT
        [delegate saveStateToDiskWithForce:NO];
    }
}

/*
 // Drawn elements are now reused
 - (void)clearMeasure:(int)measureIndex forPattern:(int)patternIndex
 {
 DLog(@"Clear measure %i at pattern %i",measureIndex,patternIndex);
 }
 */

- (void)setDeclaredActiveMeasure:(int)measureIndex
{
    if(measureIndex < measureCounts[activePattern]){
        
        int prevIndex = declaredActiveMeasures[activePattern];
        
        declaredActiveMeasures[activePattern] = measureIndex;
        [self setActiveMeasureIndex:declaredActiveMeasures[activePattern] forPattern:activePattern];
        
        // remove old border
        if(prevIndex >= 0){
            //measureSet[activePattern][prevIndex].layer.borderWidth = 0.0f;
            activeMeasureSet[prevIndex].layer.borderWidth = 0.0f;
        }
        
        activeMeasureSet[measureIndex].layer.borderColor = [UIColor whiteColor].CGColor;
        activeMeasureSet[measureIndex].layer.borderWidth = 0.0f;
        
        [activeMeasureSet[measureIndex] setAlpha:PAGE_OPACITY_ON];
    }
}

-(UIView *)drawActiveMeasures:(int)measureIndex
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
                CGRect noteFrame = CGRectMake(NOTE_GAP+f*NOTE_WIDTH-1,NOTE_GAP+(STRINGS_ON_GTAR-s-1)*NOTE_HEIGHT,NOTE_WIDTH-NOTE_GAP,NOTE_HEIGHT-NOTE_GAP);
                UIButton * newButton = [[UIButton alloc] initWithFrame:noteFrame];
                
                newButton.layer.borderWidth = 0.5;
                newButton.layer.borderColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6].CGColor;
                
                [newButton addTarget:self action:@selector(toggleNote:) forControlEvents:UIControlEventTouchUpInside];
                
                noteButtons[measureIndex][FRETS_ON_GTAR*s+f] = newButton;
                
                [newMeasure addSubview:newButton];
            }
        }
    }
    
    [newMeasure setHidden:YES];
    [scrollView addSubview:newMeasure];
    
    //
    // PLAYBAND
    //
    
    CGRect playbandFrame = CGRectMake(1, 2, NOTE_WIDTH-2, NOTE_HEIGHT*STRINGS_ON_GTAR-2);
    
    playbandView[measureIndex] = [[UIView alloc] initWithFrame:playbandFrame];
    [playbandView[measureIndex] setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7]];
    [playbandView[measureIndex] setHidden:YES];
    
    [newMeasure addSubview:playbandView[measureIndex]];
    
    return newMeasure;
}

- (UIView *)drawInactiveMeasures:(int)measureIndex
{
    float measureMargin = [self getMeasureMargin];
    
    CGRect measureFrame = CGRectMake(3*measureMargin+measureIndex*(MEASURE_WIDTH+measureMargin),1,MEASURE_WIDTH,scrollView.frame.size.height-2);
    UIView * newOffMeasure = [[UIView alloc] initWithFrame:measureFrame];
    
    [newOffMeasure setBackgroundColor:[UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
    
    // Title
    float pinchWidth = 100;
    float pinchHeight = 100;
    CGRect labelFrame = CGRectMake(measureFrame.size.width/2-pinchWidth/2,measureFrame.size.height/2-pinchHeight/2,pinchWidth,pinchHeight);
    UILabel * offMeasureLabel = [[UILabel alloc] initWithFrame:labelFrame];
    
    [offMeasureLabel setText:[@"" stringByAppendingFormat:@"%i",measureIndex+1]];
    [offMeasureLabel setTextColor:[UIColor whiteColor]];
    [offMeasureLabel setFont:[UIFont fontWithName:FONT_BOLD size:50.0]];
    [offMeasureLabel setTextAlignment:NSTextAlignmentCenter];
    [offMeasureLabel setAlpha:PAGE_OPACITY_OFF];
    
    [newOffMeasure addSubview:offMeasureLabel];
    
    [newOffMeasure setHidden:YES];
    [scrollView addSubview:newOffMeasure];
    
    //
    // GESTURES
    //
    
    if(measureIndex > 0){
        UITapGestureRecognizer * doubleTapMeasure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubletapMeasure:)];
        doubleTapMeasure.numberOfTapsRequired = 2;
        
        [newOffMeasure addGestureRecognizer:doubleTapMeasure];
    }
    
    return newOffMeasure;
}

- (void)setMeasureOnActive:(int)measureIndex forPattern:(int)patternIndex isActive:(BOOL)isActive
{
    
    @synchronized(self)
    {
        for (int s = 0; s < STRINGS_ON_GTAR; s++)
        {
            for (int f = 0; f < FRETS_ON_GTAR; f++)
            {
                UIButton * note = noteButtons[measureIndex][FRETS_ON_GTAR*s+f];
                
                NSPattern * p = currentTrack.m_patterns[patternIndex];
                NSMeasure * m = p.m_measures[measureIndex];
                
                if([m isNoteOnAtString:s andFret:f]){
                    [note setBackgroundColor:colors[s]];
                }else{
                    [note setBackgroundColor:[UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
                }
            }
        }
    }
    
    //
    // DISPLAY
    //
    
    if(isActive){
        [activeMeasureSet[measureIndex] setAlpha:PAGE_OPACITY_ON];
    }else{
        [activeMeasureSet[measureIndex] setAlpha:PAGE_OPACITY_MID];
    }
    
    [activeMeasureSet[measureIndex] setHidden:NO];
    [inactiveMeasureSet[measureIndex] setHidden:YES];
    
}

- (void)setMeasureOff:(int)measureIndex isActive:(BOOL)isActive
{
    
    if(isActive){
        [inactiveMeasureSet[measureIndex] setAlpha:PAGE_OPACITY_ON];
    }else{
        [inactiveMeasureSet[measureIndex] setAlpha:PAGE_OPACITY_MID];
    }
    
    [inactiveMeasureSet[measureIndex] setHidden:NO];
    [activeMeasureSet[measureIndex] setHidden:YES];
    
}

- (void)updateActiveMeasure
{
    // Redraw measure
    if(activeMeasure > -1 && activePattern > -1){
        //[self clearMeasure:activeMeasure forPattern:activePattern];
        [self setMeasureOnActive:activeMeasure forPattern:activePattern isActive:YES];
        
        // The measure the guitar is editing is always the active measure
        [self setDeclaredActiveMeasure:activeMeasure];
    }
}

- (void)updateGuitarView
{
    [currentTrack.selectedPattern.selectedMeasure turnOnGuitarFlags];
    [delegate setMeasureAndUpdate:currentTrack.selectedPattern.selectedMeasure checkNotPlaying:NO];
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
    
    for(int i = 0; i < NUM_MEASURES; i++){
        [playbandView[i] setHidden:YES];
    }
    
    /*@synchronized(self){
     for(int i = 0; i < NUM_MEASURES; i++){
     [self clearMeasure:i forPattern:patternIndex];
     }
     }*/
    
    [self instateNewPattern:newPattern andNewMeasure:newMeasure];
    
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
    DLog(@"*** UNMUTING ***");
    [offMask setHidden:YES];
    if(volumeKnob && ![volumeKnob isEnabled]){
        [volumeKnob EnableKnob];
    }
    currentTrack.m_muted = NO;
    isMute = NO;
    
    [delegate saveStateToDiskWithForce:YES];
}

- (void)turnOffInstrumentView
{
    DLog(@"*** MUTING ***");
    [offMask setHidden:NO];
    if(volumeKnob && [volumeKnob isEnabled]){
        [volumeKnob DisableKnob];
    }
    currentTrack.m_muted = YES;
    isMute = YES;
    
    [delegate saveStateToDiskWithForce:YES];
}


#pragma mark - Notes
- (void)toggleNote:(id)sender
{
    int string;
    int fret;
    
    UIButton * noteButton = (UIButton *) sender;
    
    @synchronized(self){
        for(int s = 0; s < STRINGS_ON_GTAR; s++){
            for(int f = 0; f < FRETS_ON_GTAR; f++){
                //noteButtons[activePattern][activeMeasure][FRETS_ON_GTAR*s+f] == sender
                if(noteButtons[activeMeasure][FRETS_ON_GTAR*s+f] == sender){
                    fret = f;
                    string = s;
                    break;
                }
            }
        }
    }
    
    if(string > STRINGS_ON_GTAR || fret > FRETS_ON_GTAR){
        DLog(@"ERROR with string %i or fret %i",string,fret);
        return;
    }
    
    NSPattern * p = currentTrack.m_patterns[activePattern];
    NSMeasure * m = p.m_measures[activeMeasure];
    
    if([m isNoteOnAtString:string andFret:fret]){
        [noteButton setBackgroundColor:[UIColor colorWithRed:29/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
    }else{
        [noteButton setBackgroundColor:colors[string]];
    }
    
    [p changeNoteAtString:string andFret:fret forMeasure:m];
    [self updateGuitarView];
    
    // SAVE CONTEXT
    [delegate saveStateToDiskWithForce:YES];
}

#pragma mark - Playband

- (void)resetPlayband
{
    @synchronized(self){
        for(int i = 0; i < NUM_MEASURES; i++){
            playband[i] = -1;
            [playbandView[i] setHidden:YES];
            //[playbandView[i] removeFromSuperview];
            //playbandView[i] = nil;
        }
    }
}

- (void)movePlaybandForMeasure:(int)measureIndex
{
    if (playband[measureIndex] >= 0) {
        CGRect newFrame = playbandView[measureIndex].frame;
        newFrame.origin.x = playband[measureIndex] * NOTE_WIDTH + 1;
        
        playbandView[measureIndex].frame = newFrame;
        
        [playbandView[measureIndex] setHidden:NO];
        
        // ensure notes can be turned on/off through it
        [playbandView[measureIndex] setUserInteractionEnabled:NO];
        
        if(isMute){
            [playbandView[measureIndex] setAlpha:0.3];
        }else{
            [playbandView[measureIndex] setAlpha:0.7];
        }
        
        // Move along with the playband
        //[self changeActiveMeasureToMeasure:measureIndex scrollSlow:YES];
        
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
    
    measureToDelete = -1;
    
    BOOL isPlaying = [delegate checkIsPlaying];
    
    DLog(@"Inst Select new pattern at %i", tappedIndex);
    
    if (tappedIndex == MUTE_SEGMENT_INDEX && selectedPatternButton != offButton){
        DLog(@"Case 1");
        isMute = YES;
        isPlaying = [delegate checkIsPlaying];
        [self clearQueuedPatternButton];
        [delegate dequeueAllPatternsForTrack:currentTrack];
    }else if(tappedIndex == MUTE_SEGMENT_INDEX && selectedPatternButton == offButton){
        DLog(@"Case 2");
        isMute = NO;
        isPlaying = [delegate checkIsPlaying];
        [self clearQueuedPatternButton];
        [delegate dequeueAllPatternsForTrack:currentTrack];
    }else{
        DLog(@"Case 3");
        isMute = NO;
        
        if(isPlaying && tappedIndex != activePattern){
            
            NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
            [pattern setObject:[NSNumber numberWithInt:tappedIndex] forKey:@"Index"];
            [pattern setObject:currentTrack forKey:@"Instrument"];
            
            [delegate enqueuePattern:pattern];
            
        }else if(tappedIndex == activePattern){
            
            [delegate dequeueAllPatternsForTrack:currentTrack];
            
            [self commitPatternChange:tappedIndex];
        }else{
            
            [self commitPatternChange:tappedIndex];
        }
    }
    
    //if(isMute){
    //    [self turnOffInstrumentView];
    //}else{
    //   [self turnOnInstrumentView];
    //}
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
    //    DLog(@"Already set - returning");
    //    return;
    //}else {
    //    DLog(@"Now updating");
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
    //if(newButton == offButton && selectedPatternButton != offButton){
    //    [self turnOffInstrumentView];
    //}else{
    //    [self turnOnInstrumentView];
    //}
    
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
- (void)userDidSelectNewMeasure:(id)sender
{
    DLog(@"User did select new measure");
    
    int newMeasureIndex;
    
    if(sender == pageOne){
        DLog(@"Scroll to measure 1");
        newMeasureIndex = 0;
        
    }else if(sender == pageTwo){
        DLog(@"Scroll to measure 2");
        newMeasureIndex = 1;
        
    }else if(sender == pageThree){
        DLog(@"Scroll to measure 3");
        newMeasureIndex = 2;
        
    }else{
        DLog(@"Scroll to measure 4");
        newMeasureIndex = 3;
    }
    
    [self setNewMeasureFromPage:newMeasureIndex];
    
}

- (void)setNewMeasureFromPage:(int)measureIndex
{
    if(measureToDelete > -1){
        
        if(measureToDelete == measureIndex){
            [self deactivateMeasure:measureToDelete];
        }else{
            [self hideDeleteForMeasure:measureToDelete];
        }
        
    }else{
        
        [self setActivePage:measureIndex];
        [self highlightMeasure:measureIndex];
        
        activeMeasure = measureIndex;
        targetMeasure = activeMeasure;
        [self scrollToMeasure:measureIndex scrollSlow:YES];
    }
}

- (void)scrollToAndSetActiveMeasure:(int)measureIndex scrollSlow:(BOOL)isSlow
{
    activeMeasure = measureIndex;
    targetMeasure = activeMeasure;
    [self setDeclaredActiveMeasure:measureIndex];
    [self scrollToMeasure:measureIndex scrollSlow:isSlow];
}

- (void)scrollToMeasure:(int)measureIndex scrollSlow:(BOOL)isSlow
{
    float measureMargin = [self getMeasureMargin];
    
    CGPoint newOffset = CGPointMake(measureIndex*(MEASURE_WIDTH+measureMargin),0);
    double scrollSpeed = isSlow ? SCROLL_SPEED_MAX : SCROLL_SPEED_MIN;
    
    DLog(@"Active measure is %i",activeMeasure);
    
    [UIView animateWithDuration:scrollSpeed animations:^(){
        [scrollView setContentOffset:newOffset];
        [self highlightMeasure:measureIndex];
    } completion:^(BOOL finished){
        
        [self setActivePage:measureIndex];
        scrollView.scrollEnabled = YES;
        [self updateGuitarView];
        
    }];
    
}

- (void)highlightMeasure:(int)measureIndex
{
    if(activePattern > -1){
        for(int i = 0; i < NUM_MEASURES; i++){
            
            double activeOpacity = (i == measureIndex) ? PAGE_OPACITY_ON : PAGE_OPACITY_MID;
            
            if(i < measureCounts[activePattern]){
                [activeMeasureSet[i] setAlpha:activeOpacity];
            }else{
                [inactiveMeasureSet[i] setAlpha:activeOpacity];
            }
        }
    }
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
    
    CGPoint location = [scroller.panGestureRecognizer locationInView:scroller];
    float x = location.x - activeMeasure*(MEASURE_WIDTH+[self getMeasureMargin]);
    float velocityX = [scroller.panGestureRecognizer velocityInView:scrollView].x;
    
    if((x < 50 || (activeMeasure == 0 && x < 300)) && velocityX >= 0){
        [delegate openLeftNavigator];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scroller
{
    if(measureToDelete > -1){
        [self hideDeleteForMeasure:measureToDelete];
    }
    
    if(!scrollView.scrollEnabled){
        [self pinScrollViewToActiveMeasure];
    }
}

-(void)leftNavWillOpen
{
    if(measureToDelete > -1){
        [self hideDeleteForMeasure:measureToDelete];
    }
    
    targetMeasure = activeMeasure;
    scrollView.userInteractionEnabled = NO;
    scrollView.scrollEnabled = NO;
    [self pinScrollViewToActiveMeasure];
    [self.view setUserInteractionEnabled:NO];
    
}

- (void)leftNavDidClose
{
    targetMeasure = activeMeasure;
    scrollView.userInteractionEnabled = YES;
    scrollView.scrollEnabled = YES;
    [self.view setUserInteractionEnabled:YES];
    [self pinScrollViewToActiveMeasure];
}

- (void)pinScrollViewToActiveMeasure
{
    
    [scrollView setContentOffset:CGPointMake(activeMeasure*(MEASURE_WIDTH+[self getMeasureMargin]), 0)];
    [self highlightMeasure:activeMeasure];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scroller withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    float velocityX = [scroller.panGestureRecognizer velocityInView:scrollView].x;
    
    if(scrollView.scrollEnabled){
        // Determine a target measure to scroll to
        //double velocityOffset = floor(abs(velocity.x)/3.0)+1;
        double velocityOffset = 1;
        
        /*if(scrollView.contentOffset.x > lastContentOffset.x){
         targetMeasure = MIN(activeMeasure+velocityOffset,NUM_MEASURES-1);
         }else if(scrollView.contentOffset.x < lastContentOffset.x){
         targetMeasure = MAX(activeMeasure-velocityOffset,0);
         }*/
        
        if(velocityX < 0){
            targetMeasure = MIN(activeMeasure+velocityOffset,NUM_MEASURES-1);
        }else if(velocityX > 0){
            targetMeasure = MAX(activeMeasure-velocityOffset,0);
        }
        
        [self setActivePage:targetMeasure];
        [self highlightMeasure:targetMeasure];
        
        CGPoint newOffset = CGPointMake(targetMeasure*(MEASURE_WIDTH+[self getMeasureMargin]),0);
        
        targetContentOffset->x = newOffset.x;
        lastContentOffset.x = newOffset.x;
    }else{
        [self pinScrollViewToActiveMeasure];
    }
    
}

- (void)snapScrollerToPlace:(UIScrollView *)scroller
{
    //if(scrollView.scrollEnabled){
    [self changeActiveMeasureToMeasure:targetMeasure scrollSlow:NO];
    //}else{
    //    [self pinScrollViewToActiveMeasure];
    //}
}

- (float)getMeasureMargin
{
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    BOOL isScreenLarge = [frameGenerator isScreenLarge];
    
    
    float measureMargin = (isScreenLarge) ? MEASURE_MARGIN_LG : MEASURE_MARGIN_SM;
    
    return measureMargin;
}

#pragma mark - Other Drawing
/*
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
 */

#pragma mark - System

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FTU Tutorial
-(void)checkIsFirstLaunch
{
    // Check for first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedInstrumentView"]){
        isFirstLaunch = FALSE;
    }else{
        isFirstLaunch = TRUE;
    }
}


- (void)launchFTUTutorial
{
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    float x = [frameGenerator getFullscreenWidth];
    float y = [frameGenerator getFullscreenHeight];
    
    DLog(@" *** Launch FTU Tutorial *** %f %f",x,y);
    
    CGRect tutorialFrame = CGRectMake(0,0,x,y-BOTTOMBAR_HEIGHT-1);
    
    if(tutorialViewController){
        [tutorialViewController clear];
    }
    
    tutorialViewController = [[TutorialViewController alloc] initWithFrame:tutorialFrame andTutorial:@"Instrument"];
    tutorialViewController.delegate = self;
    
    [self.view addSubview:tutorialViewController];
    
    [tutorialViewController launch];
}

- (void)endTutorialIfOpen
{
    [tutorialViewController end];
}

- (void)notifyTutorialEnded
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedInstrumentView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Volume Control

- (void)initVolumeKnob
{
    if(!volumeKnob){
        volumeKnob = [[UIKnob alloc] initWithFrame:CGRectMake(0,0,offButton.frame.size.width,offButton.frame.size.height)];
        [volumeKnob setBackgroundColor:[UIColor clearColor]];
        [volumeKnob setOuterColor:[UIColor whiteColor]];
        [volumeKnob setHighlightColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        [volumeKnob setLineColor:[UIColor whiteColor]];
        [volumeKnob setTouchTrackerColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
        [volumeKnob setDelegate:self];
        [volumeKnob setUserInteractionEnabled:NO];
        [offButton addSubview:volumeKnob];
        
        [volumeKnob SetValue:currentTrack.m_level];
        
        volumeKnobView.delegate = self;
        
        offButtonDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enableKnobIfDisabled)];
        offButtonDoubleTap.numberOfTapsRequired = 2;
        
        [volumeKnobView addGestureRecognizer:offButtonDoubleTap];
    }
    
    isTracking = NO;
}

- (void)resetVolume
{
    [volumeKnob SetValue:currentTrack.m_level];
}

- (void)knobRegionHit
{
    if(!isTracking && [volumeKnob isEnabled]){
        [self drawVolumeOverlay];
    }
}

- (void)drawVolumeOverlay
{
    DLog(@"volume tracking began");
    isTracking = YES;
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    float x = [frameGenerator getFullscreenWidth];
    float y = [frameGenerator getFullscreenHeight];
    
    // Set up radial display:
    CGRect wholeScreen = CGRectMake(0, 0, x, y-1);
    volumeBg = [[UIView alloc] initWithFrame:wholeScreen];
    [volumeBg setBackgroundColor:[UIColor clearColor]];
    
    tempVolumeKnob = [[UIKnob alloc] initWithFrame:CGRectMake(self.view.frame.origin.x+offButton.frame.origin.x,self.view.frame.origin.y+offButton.frame.origin.y,offButton.frame.size.width,offButton.frame.size.height)];
    [tempVolumeKnob setBackgroundColor:[UIColor clearColor]];
    [tempVolumeKnob setDelegate:self];
    [tempVolumeKnob SetValue:[volumeKnob GetValue]];
    [tempVolumeKnob setUserInteractionEnabled:YES];
    [tempVolumeKnob setOuterColor:[UIColor whiteColor]];
    [tempVolumeKnob setHighlightColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
    [tempVolumeKnob setTouchTrackerColor:[UIColor colorWithRed:204/255.0 green:234/255.0 blue:0/255.0 alpha:1.0]];
    [tempVolumeKnob setLineColor:[UIColor whiteColor]];
    [tempVolumeKnob setRotateFactor:0.004f];
    
    [volumeBg addSubview:tempVolumeKnob];
    
    // overlay by adding to the main view
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:volumeBg];
    
    [volumeKnob setHidden:YES];
}

-(void)trackingDidBegin
{
    
}

-(void)trackingDidChange
{
    currentTrack.m_level = [tempVolumeKnob GetValue];
}

-(void)trackingDidEnd
{
    isTracking = NO;
    
    [volumeKnob SetValue:[tempVolumeKnob GetValue]];
    
    DLog(@"new volume is %f",[volumeKnob GetValue]);
    currentTrack.m_level = [volumeKnob GetValue];
    
    [volumeBg removeFromSuperview];
    [volumeKnob setHidden:NO];
    
    [delegate saveStateToDiskWithForce:NO];
}


-(void)enableKnobIfDisabled
{
    DLog(@"Enable knob if disabled");
    if(![volumeKnob isEnabled]){
        DLog(@"Enable previous button");
        if(previousPatternButton){
            [self selectNewPattern:previousPatternButton];
        }
        [self turnOnInstrumentView];
        [volumeKnob EnableKnob];
    }
}

-(void)enableKnob:(id)sender
{
    
}

-(void)disableKnob:(id)sender
{
    UIKnob * senderKnob = (UIKnob *)sender;
    
    if(senderKnob == tempVolumeKnob && offButton != nil){
        [volumeKnob DisableKnob];
        if(offButton){
            [self selectNewPattern:offButton];
        }
        [self turnOffInstrumentView];
    }
}

-(void)disableKnobIfEnabled
{
    DLog(@"Disable knob if enabled");
    if([volumeKnob isEnabled]){
        [self disableKnob:tempVolumeKnob];
    }
}


@end
