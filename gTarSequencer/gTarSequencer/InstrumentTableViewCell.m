//
//  InstrumentTableCell.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "InstrumentTableViewCell.h"
#import "InstrumentTableViewController.h"

@implementation InstrumentTableViewCell

@synthesize parent;
@synthesize instrumentIconView;
@synthesize instrumentIconBorder;
@synthesize instrument;
@synthesize minimapBorder;
@synthesize patternContainer;
@synthesize borderContainer;
@synthesize patternToDisplay;
@synthesize measureViews;
@synthesize isSelected;
@synthesize addMeasureButton;
@synthesize removeMeasureButton;
@synthesize instrumentIcon;
@synthesize instrumentName;
@synthesize measureOne;
@synthesize measureTwo;
@synthesize measureThree;
@synthesize measureFour;
@synthesize patternA;
@synthesize patternB;
@synthesize patternC;
@synthesize patternD;
@synthesize offButton;

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
    patternButtons = nil;
    
    deleteMode = NO;
    
    selectedPatternButton = nil;
    
    loopModCount = 0;
}

- (void)layoutSubviews
{
    minimapBorder.layer.borderWidth = 1.0;
    minimapBorder.layer.cornerRadius = 3.0;
    minimapBorder.layer.borderColor = [UIColor colorWithRed:10/255.0 green:155/255.0 blue:191/255.0 alpha:1.0].CGColor;

    addMeasureButton.layer.borderWidth = 1.5;
    addMeasureButton.layer.cornerRadius = 3.0;
    addMeasureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    addMeasureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    addMeasureButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [addMeasureButton setTitleEdgeInsets:UIEdgeInsetsMake(-13.0f,3.5f,0.0f,0.0f)];
    
    removeMeasureButton.layer.borderWidth = 1.5;
    removeMeasureButton.layer.cornerRadius = 3.0;
    removeMeasureButton.layer.borderColor = [UIColor whiteColor].CGColor;
    removeMeasureButton.contentVerticalAlignment = UIControlContentHorizontalAlignmentLeft;
    removeMeasureButton.contentHorizontalAlignment = UIControlContentVerticalAlignmentTop;
    [removeMeasureButton setTitleEdgeInsets:UIEdgeInsetsMake(-13.0f,6.0f,0.0f,0.0f)];
    
    [self initPatternButtonUI];
    
    
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
        
        for (int i=0;i<[measureViews count];i++)
        {
            MeasureView * mv = [measureViews objectAtIndex:i];
            //mv.bounds = CGRectMake(-2, -2, mv.frame.size.width + 2, mv.frame.size.height + 4);
            mv.backgroundColor = [UIColor clearColor];
            
            [mv addTarget:self action:@selector(userDidSelectNewMeasure:) forControlEvents:UIControlEventTouchUpInside];
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
    
    for (int i=0;i<[patternButtons count];i++)
    {
        UIButton * patternN = [patternButtons objectAtIndex:i];
        patternN.layer.cornerRadius = 3.0;
        [patternN setTitleEdgeInsets:UIEdgeInsetsMake(2.0f,0.0f,0.0f,0.0f)];
    }
    
    // special case
    [patternA setTitleEdgeInsets:UIEdgeInsetsMake(2.0f,2.0f,0.0f,0.0f)];
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
        queuedPatternButton = newButton;
        [self setStateForButton:queuedPatternButton state:1];
        
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
        case 0:
            backgroundColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
            titleColor = [UIColor whiteColor];
            break;
        case 1:
            backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.6];
            titleColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
            break;
        case 2:
            backgroundColor = [UIColor whiteColor];
            titleColor = [UIColor colorWithRed:14/255.0 green:194/255.0 blue:239/255.0 alpha:1.0];
            break;
        case 3:
            backgroundColor = [UIColor clearColor];
            titleColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            break;
    }
    
    [button setBackgroundColor:backgroundColor];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
}

#pragma mark Change Instrument
- (void)userDidTapInstrumentIcon:(id)sender
{
    
    // TODO: implement instrument change
    
}

#pragma mark Minimap

- (void)update
{
    // update selected pattern:
   if ( instrument.selectedPatternDidChange )
    {
        self.patternToDisplay = instrument.selectedPattern;
        
        // If the instrument is muted, then the OFF button needs to be selected
        if (instrument.isMuted){
            [self selectPatternButton:MUTE_SEGMENT_INDEX];
        } else {
            [self selectPatternButton:instrument.selectedPatternIndex];
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
    
    for(int i = 0; i < MAX_MEASURES_IN_UI; i++){
        if(i < newCount){
            [[measureViews objectAtIndex:i] drawMeasure:FALSE];
        }else{
            [[measureViews objectAtIndex:i] drawMeasure:TRUE];
        }
    }
    
}

- (void)selectPatternButton:(int)index
{
    UIButton * newSelection = [patternButtons objectAtIndex:index];
    
    if (selectedPatternButton == newSelection){
        return;
    }else {
        [self updatePatternButton:newSelection playState:NO];
    }
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

    [self performSelector:@selector(selectNewPattern:) withObject:sender afterDelay:0.0];
}

// Split up into two functions to allow the UI to update immediately
- (void)selectNewPattern:(id)sender
{
    
    int tappedIndex = [patternButtons indexOfObject:sender];
    
    BOOL isPlaying = NO;
    
    NSLog(@"Select new pattern at %i", tappedIndex);
    
    if (tappedIndex == MUTE_SEGMENT_INDEX){
        [parent muteInstrument:self isMute:YES];
        isPlaying = [parent.delegate checkIsPlaying];
    }else{
        [parent muteInstrument:self isMute:NO];
        isPlaying = [parent userDidSelectPattern:self atIndex:tappedIndex];
    }
    
    [self updatePatternButton:sender playState:isPlaying];
    
}

#pragma mark Selecting Measures

- (IBAction)userDidSelectNewMeasure:(id)sender
{
    int tappedIndex = [measureViews indexOfObject:sender];
    
    if (tappedIndex >= patternToDisplay.measureCount)
        return;
    else
        [parent userDidSelectMeasure:self atIndex:tappedIndex];
}

#pragma mark Adding and Removing Measures

- (IBAction)addMeasures:(id)sender {
    NSLog(@"add a measure");
    [parent userDidAddMeasures:self];
}

- (IBAction)removeMeasures:(id)sender {
    NSLog(@"remove a measure");
    [parent userDidRemoveMeasures:self];
}


@end
