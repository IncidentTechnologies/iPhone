//
//  InstrumentTableCell.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SeqSetViewCell.h"
#import "SeqSetViewController.h"

@implementation SeqSetViewCell

@synthesize parent;
@synthesize instrumentIconView;
@synthesize instrumentIconBorder;
@synthesize instrument;
@synthesize editingScrollView;
@synthesize patternContainer;
@synthesize borderContainer;
@synthesize patternToDisplay;
@synthesize measureViews;
@synthesize measureBorders;
@synthesize isSelected;
@synthesize isMute;
@synthesize instrumentIcon;
@synthesize instrumentName;
@synthesize customIndicator;
@synthesize measureOne;
@synthesize measureTwo;
@synthesize measureThree;
@synthesize measureFour;
@synthesize measureOneBorder;
@synthesize measureTwoBorder;
@synthesize measureThreeBorder;
@synthesize measureFourBorder;
@synthesize patternA;
@synthesize patternB;
@synthesize patternC;
@synthesize patternD;
@synthesize offButton;
@synthesize volumeKnob;
@synthesize patternABorder;
@synthesize patternDBorder;
@synthesize addMeasuresButton;
@synthesize removeMeasuresButton;
@synthesize deleteButton;
@synthesize rightSliderPin;
@synthesize offMask;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if ( self )
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    isSelected = NO;
    
    measureViews = nil;
    measureBorders = nil;
    patternButtons = nil;
    
    deleteMode = NO;
    
    selectedPatternButton = nil;
    
    loopModCount = 0;
    
    for(UIView * subview in self.subviews){
        if([subview isKindOfClass:[UIScrollView class]]){
            UIScrollView * scrollView = (UIScrollView *)subview;
            scrollView.delegate = self;
            
            editingScrollView = scrollView;
        }
    }
}

- (void)layoutSubviews
{
    [offMask setHidden:YES];
    
    [self initVolumeKnob];
    
    instrumentIconBorder.layer.cornerRadius = 5.0;
    instrumentIconBorder.layer.borderWidth = 1.0;
    instrumentIconBorder.layer.borderColor = [UIColor whiteColor].CGColor;
    
    addMeasuresButton.layer.cornerRadius = 14.0;
    addMeasuresButton.layer.borderColor = [UIColor whiteColor].CGColor;
    addMeasuresButton.layer.borderWidth = 1.0;
    
    removeMeasuresButton.layer.cornerRadius = 14.0;
    removeMeasuresButton.layer.borderColor = [UIColor whiteColor].CGColor;
    removeMeasuresButton.layer.borderWidth = 1.0;
    
    rightSliderPin.layer.cornerRadius = 2.0;
    
    [self initPatternButtonUI];
    
    if(isMute){
        [self turnOffInstrumentView];
    }else{
        [self turnOnInstrumentView];
    }
    
    for(UIButton * p in patternButtons){
        if(p == selectedPatternButton){
            [self setStateForButton:p state:2];
        }else{
            [self setStateForButton:p state:0];
        }
    }
    
    // get previous selected pattern if off
    if(selectedPatternButton == offButton){
        int selectedPattern = instrument.selectedPatternIndex;
        previousPatternButton = [patternButtons objectAtIndex:selectedPattern];
        [self setStateForButton:previousPatternButton state:4];
    }
    
    // TODO: make different variants for the 4in
    
    // Table Cells require programmatic constraints
    /*NSLayoutConstraint * bodyleading = [NSLayoutConstraint
     constraintWithItem:patternContainer
     attribute:NSLayoutAttributeLeading
     relatedBy:NSLayoutRelationEqual
     toItem: self
     attribute:NSLayoutAttributeLeading
     multiplier:1.0f
     constant:0];
     
     NSLayoutConstraint * bodytrailing = [NSLayoutConstraint
     constraintWithItem:patternContainer
     attribute:NSLayoutAttributeTrailing
     relatedBy:NSLayoutRelationEqual
     toItem: self
     attribute:NSLayoutAttributeTrailing
     multiplier:1.0f
     constant:0];*/
    
    //[self addConstraints:@[bodyleading,bodytrailing]];
    
    [self setUserInteractionEnabled:YES];
    
}

/*
 *  This function exists because the measureViews array needs to be init'ed before the cell can be updated,
 * which occurs at the end of cellForRowAtIndexPath in the main VC. At that point, however, layoutSubviews has not been called,
 * so something must be called explicitly.
 */
- (void)initMeasureViews
{
    if (measureViews == nil)
    {
        measureViews = [[NSMutableArray alloc] initWithObjects:measureOne, measureTwo, measureThree, measureFour, nil];
        
        measureBorders = [[NSMutableArray alloc] initWithObjects:measureOneBorder, measureTwoBorder, measureThreeBorder, measureFourBorder, nil];
        
        for (int i=0;i<[measureViews count];i++)
        {
            //MeasureView * mv = [measureViews objectAtIndex:i];
            //mv.bounds = CGRectMake(-2, -2, mv.frame.size.width + 2, mv.frame.size.height + 4);
            //mv.backgroundColor = [UIColor clearColor];
            
            [[measureBorders objectAtIndex:i] setHidden:YES];
        }
    }
    
    if(patternButtons == nil)
    {
        patternButtons = [[NSMutableArray alloc] initWithObjects:patternA, patternB, patternC, patternD, offButton, nil];
        
        [self selectPatternButton:0];
    }
}

- (void)setBeatSequenceToDisplay:(Pattern *)newBS
{
    patternToDisplay = newBS;
    
    [self distributeMeasures];
}

- (void)setInstrumentIcon:(UIImage *)newImage
{
    instrumentIcon = newImage;
    
    instrumentIconView.image = newImage;
}

- (void)initPatternButtonUI
{
    if(patternABorder == nil && patternDBorder == nil){
        
        UIBezierPath * pathA = [UIBezierPath bezierPathWithRoundedRect:patternA.bounds byRoundingCorners:(UIRectCornerBottomLeft) cornerRadii:CGSizeMake(10.0,10.0)];
        UIBezierPath * pathD = [UIBezierPath bezierPathWithRoundedRect:patternD.bounds byRoundingCorners:(UIRectCornerBottomRight) cornerRadii:CGSizeMake(10.0,10.0)];
        
        [self drawShapedButton:patternA withBezierPath:pathA];
        patternABorder = [self drawStrokedButton:patternA withBezierPath:pathA andBorderColor:[UIColor whiteColor]];
        
        [self drawShapedButton:patternD withBezierPath:pathD];
        patternDBorder = [self drawStrokedButton:patternD withBezierPath:pathD andBorderColor:[UIColor whiteColor]];
    }
}

- (void)resetQueuedPatternButton
{
    [self setStateForButton:queuedPatternButton state:0];
    queuedPatternButton = nil;
}

- (void)enqueuePatternButton:(int)index
{
    UIButton * newButton = [patternButtons objectAtIndex:index];
    
    queuedPatternButton = newButton;
    [self setStateForButton:queuedPatternButton state:1];
    
}

- (BOOL)hasQueuedPatternButton
{
    if(queuedPatternButton != nil){
        return TRUE;
    }
    
    return FALSE;
}

-(void)turnOnInstrumentView
{
    
    if(TESTMODE) DLog(@"*** UNMUTING ***");
    //[parent muteInstrument:self isMute:NO];
    [offMask setHidden:YES];
    if(volumeKnob && ![volumeKnob isEnabled]){
        [volumeKnob EnableKnob];
    }
    [instrument setIsMuted:NO];
    isMute = NO;
    
    [parent saveContext:nil force:NO];
}

-(void)turnOffInstrumentView
{
    if(TESTMODE) DLog(@"*** MUTING ***");
    //[parent muteInstrument:self isMute:YES];
    [offMask setHidden:NO];
    if(volumeKnob && [volumeKnob isEnabled]){
        [volumeKnob DisableKnob];
    }
    [instrument setIsMuted:YES];
    isMute = YES;
    
    [parent saveContext:nil force:NO];
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
        [self setStateForButton:previousPatternButton state:4];
        
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

- (void)notifyQueuedPatterns:(BOOL)reset
{
    if(queuedPatternButton != nil){
        
        if(reset){
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
            if(button == offButton){
                backgroundColor = [UIColor clearColor];
            }else{
                //backgroundColor = [UIColor clearColor];
                backgroundColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1.0];
                [self showButtonBorders:button];
            }
            titleColor = [UIColor whiteColor];
            break;
        case 1: // queued
            backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
            titleColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
            [self showButtonBorders:button];
            break;
        case 2: // on
        case 4: // on but instrument mute
            titleColor = [UIColor whiteColor];
            backgroundColor = [UIColor clearColor];
            [self hideButtonBorders:button];
            break;
        case 3: // queued blinking
            backgroundColor = [UIColor colorWithRed:23/255.0 green:163/255.0 blue:198/255.0 alpha:1.0];
            titleColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
            [self showButtonBorders:button];
            break;
    }
    
    [button setBackgroundColor:backgroundColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
}

-(void)showButtonBorders:(UIButton *)patternButton
{
    
    if(patternButton == patternA){
        
        [patternABorder setHidden:NO];
        
    }else if(patternButton == patternB || patternButton == patternC){
        
        patternButton.layer.borderColor = [UIColor whiteColor].CGColor;
        patternButton.layer.borderWidth = 1.0f;
        
    }else if(patternButton == patternD){
        
        [patternDBorder setHidden:NO];
        
    }
}

-(void)hideButtonBorders:(UIButton *)patternButton
{
    if(patternButton == patternA){
        [patternABorder setHidden:YES];
    }else if(patternButton == patternB || patternButton == patternC){
        patternButton.layer.borderWidth = 0.0f;
    }else if(patternButton == patternD){
        [patternDBorder setHidden:YES];
    }
}

-(void)drawShapedButton:(UIButton *)patternButton withBezierPath:(UIBezierPath *)bezierPath
{
    CAShapeLayer * bodyLayer = [CAShapeLayer layer];
    
    [bodyLayer setPath:bezierPath.CGPath];
    patternButton.layer.mask = bodyLayer;
    patternButton.clipsToBounds = YES;
    patternButton.layer.masksToBounds = YES;
    
}

-(UIView *)drawStrokedButton:(UIButton *)patternButton withBezierPath:(UIBezierPath *)bezierPath andBorderColor:(UIColor *)borderColor
{
    CAShapeLayer * strokeLayer = [CAShapeLayer layer];
    strokeLayer.path = bezierPath.CGPath;
    strokeLayer.fillColor = [UIColor clearColor].CGColor;
    strokeLayer.strokeColor = borderColor.CGColor;
    strokeLayer.lineWidth = 2.0;
    
    UIView * strokeView = [[UIView alloc] initWithFrame:patternButton.bounds];
    strokeView.userInteractionEnabled = NO;
    [strokeView.layer addSublayer:strokeLayer];
    
    [patternButton addSubview:strokeView];
    
    return strokeView;
}

-(void)showCustomIndicator
{
    customIndicator.layer.cornerRadius = customIndicator.frame.size.width/2;
    [customIndicator setHidden:NO];
}

-(void)hideCustomIndicator
{
    [customIndicator setHidden:YES];
}

#pragma mark Change Instrument
- (IBAction)userDidTapInstrumentIcon:(id)sender
{
    DLog(@"User did tap instrument icon for instrument %@ id %i",instrument,instrument.instrument);
    
    [parent viewSelectedInstrument:self];
}

#pragma mark Minimap

- (void)update
{
    if(TESTMODE) DLog(@"Minimap update");
    
    // update selected pattern:
    if ( instrument.selectedPatternDidChange )
    {
        self.patternToDisplay = instrument.selectedPattern;
        
        // If the instrument is muted, then the OFF button needs to be selected
        if (instrument.isMuted){
            [self selectPatternButton:MUTE_SEGMENT_INDEX];
            [self turnOffInstrumentView];
        } else {
            [self selectPatternButton:instrument.selectedPatternIndex];
            [self turnOnInstrumentView];
        }
        
        instrument.selectedPatternDidChange = NO;
    }
    
    // update the number of measures:
    if (patternToDisplay.countChanged)
    {
        [self fillWithMeasures:patternToDisplay.measureCount];
        patternToDisplay.countChanged = NO;
        
        [self distributeMeasures];
    }
    
    // update the currently selected measure:
    if ( [instrument isSelected] )
    {
        if ( patternToDisplay.selectionChanged )
        {
            [self selectMeasure:patternToDisplay.selectedMeasureIndex];
            patternToDisplay.selectionChanged = NO;
        }
    }
    else {
        [self deselect];
    }
    
    // call update on each MeasureView
    for (int i = 0; i < patternToDisplay.measureCount; i++) {
        MeasureView * mv = [measureViews objectAtIndex:i];
        [mv update];
    }
}

- (void)fillWithMeasures:(int)newCount
{
    if(TESTMODE) DLog(@"Fill with measures");
    
    for(int i = 0; i < NUM_MEASURES; i++){
        if(i < newCount){
            [[measureBorders objectAtIndex:i] setHidden:NO];
            [[measureViews objectAtIndex:i] drawMeasure:FALSE];
            
            [[measureViews objectAtIndex:i] addTarget:self action:@selector(userDidSelectNewMeasure:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [[measureBorders objectAtIndex:i] setHidden:YES];
            [[measureViews objectAtIndex:i] drawMeasure:TRUE];
        }
    }
}

- (void)selectPatternButton:(int)index
{
    if(TESTMODE) DLog(@"Select pattern button");
    
    UIButton * newSelection = [patternButtons objectAtIndex:index];
    
    /*if (selectedPatternButton == newSelection){
     DLog(@"Already set - returning");
     return;
     }else {
     DLog(@"Now updating");*/
    [self updatePatternButton:newSelection playState:NO];
    //}
}

- (void)selectMeasure:(int)indexToSelect
{
    [self deselect];
    
    MeasureView * mv = [measureViews objectAtIndex:indexToSelect];
    
    [mv selectMeasure];
}

- (void)deselect
{
    for (MeasureView * mv in measureViews) {
        [mv deselectMeasure];
    }
}

- (void)distributeMeasures
{
    for (int i=0;i<[patternToDisplay.measures count];i++)
    {
        MeasureView * mv = [measureViews objectAtIndex:i];
        
        Measure * tempMeasure = [patternToDisplay.measures objectAtIndex:i];
        
        [mv setMeasure:tempMeasure];
    }
}

#pragma mark Beat Sequence Selector

- (IBAction)userDidSelectNewPattern:(id)sender
{
    [self selectNewPattern:sender];
    
    //    [self performSelector:@selector(selectNewPattern:) withObject:sender afterDelay:0.0];
    
}

// Split up into two functions to allow the UI to update immediately
- (void)selectNewPattern:(id)sender
{
    int tappedIndex = [patternButtons indexOfObject:sender];
    
    BOOL isPlaying = NO;
    
    DLog(@"SeqSet Select new pattern at %i", tappedIndex);
    
    if (tappedIndex == MUTE_SEGMENT_INDEX && selectedPatternButton != offButton){
        //[self turnOffInstrumentView];
        isPlaying = [parent.delegate checkIsPlaying];
        [self resetQueuedPatternButton];
        [parent dequeueAllPatternsForInstrument:self];
    }else if(tappedIndex == MUTE_SEGMENT_INDEX && selectedPatternButton == offButton){
        //[self turnOnInstrumentView];
        isPlaying = [parent.delegate checkIsPlaying];
        [self resetQueuedPatternButton];
        [parent dequeueAllPatternsForInstrument:self];
    }else{
        //[self turnOnInstrumentView];
        isPlaying = [parent userDidSelectPattern:self atIndex:tappedIndex];
    }
    
    [self updatePatternButton:sender playState:isPlaying];
    
}

#pragma mark - Selecting Measures

- (IBAction)userDidSelectNewMeasure:(id)sender
{
    int tappedIndex = [measureViews indexOfObject:sender];
    
    if (tappedIndex >= patternToDisplay.measureCount){
        return;
    }else{
        [parent userDidSelectMeasure:self atIndex:tappedIndex];
    }
}

#pragma mark - Adding and Removing Measures

- (IBAction)addMeasures:(id)sender {
    DLog(@"add a measure");
    [parent userDidAddMeasures:self];
}

- (IBAction)removeMeasures:(id)sender {
    DLog(@"remove a measure");
    [parent userDidRemoveMeasures:self];
}

#pragma mark - Deleting
// Prevent bouncing
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static CGFloat targetOffset = 82;
    if(scrollView.contentOffset.x >= targetOffset){
        scrollView.contentOffset = CGPointMake(targetOffset, 0.0);
    }
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
        
        [volumeKnob EnableKnob];
        [volumeKnob SetValue:[instrument getAmplitude]];
        
        DLog(@"init volume is %f",[volumeKnob GetValue]);
        
        offButtonDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enableKnobIfDisabled)];
        offButtonDoubleTap.numberOfTapsRequired = 2;
        
        [offButton addGestureRecognizer:offButtonDoubleTap];
    }
    
    isTracking = NO;
}

-(void)resetVolume
{
    [volumeKnob SetValue:[instrument getAmplitude]];
}

- (void)drawVolumeOverlay
{
    DLog(@"volume tracking began");
    isTracking = YES;
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    BOOL isScreenLarge = (screenBounds.size.height == XBASE_LG) ? YES : NO;
    
    // Set up radial display:
    CGRect wholeScreen;
    if(isScreenLarge){
        wholeScreen = CGRectMake(0, 0, XBASE_LG, YBASE-1);
    }else{
        wholeScreen = CGRectMake(0, 0, XBASE_SM, YBASE-1);
    }
    
    volumeBg = [[UIView alloc] initWithFrame:wholeScreen];
    [volumeBg setBackgroundColor:[UIColor clearColor]];
    
    tempVolumeKnob = [[UIKnob alloc] initWithFrame:CGRectMake(self.frame.origin.x+offButton.frame.origin.x-editingScrollView.contentOffset.x,self.frame.origin.y+offButton.frame.origin.y-parent.instrumentTable.contentOffset.y,offButton.frame.size.width,offButton.frame.size.height)];
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
    [instrument setAmplitude:[tempVolumeKnob GetValue]];
}

-(void)trackingDidEnd
{
    isTracking = NO;
    
    [volumeKnob SetValue:[tempVolumeKnob GetValue]];
    
    DLog(@"new volume is %f",[volumeKnob GetValue]);
    [instrument setAmplitude:[volumeKnob GetValue]];
    
    [volumeBg removeFromSuperview];
    [volumeKnob setHidden:NO];
    
    [parent saveContext:nil force:NO];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * hitView = [super hitTest:point withEvent:event];
    
    if(hitView == offButton || hitView == volumeKnob){
        if(!isTracking && [volumeKnob isEnabled]){
            [self drawVolumeOverlay];
        }
    }
    
    return hitView;
}

-(void)enableKnobIfDisabled
{
    /*DLog(@"Enable knob if disabled");
     if(![volumeKnob isEnabled]){
     DLog(@"Enable previous button");
     [self selectNewPattern:previousPatternButton];
     [self turnOnInstrumentView];
     [volumeKnob EnableKnob];
     }*/
    
    DLog(@"*** enable knob if disabled");
    
    [self selectNewPattern:previousPatternButton];
    [self turnOnInstrumentView];
}

-(void)enableKnob:(id)sender
{
    
}

-(void)disableKnob:(id)sender
{
    UIKnob * senderKnob = (UIKnob *)sender;
    
    if(senderKnob == tempVolumeKnob && offButton != nil){
        [volumeKnob DisableKnob];
        [self selectNewPattern:offButton];
        [self turnOffInstrumentView];
    }
}

-(void)disableKnobIfEnabled
{
    /*DLog(@"Disable knob if enabled");
     if([volumeKnob isEnabled]){
     [self disableKnob:tempVolumeKnob];
     }*/
    
    DLog(@"*** disable knob if enabled");
    
    [self selectNewPattern:offButton];
    [self turnOffInstrumentView];
}

@end
