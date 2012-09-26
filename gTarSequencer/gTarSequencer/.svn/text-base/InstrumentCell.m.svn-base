//
//  TrackCell.m
//  gTarSequencer
//
//  Created by Ilan Gray on 7/9/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "InstrumentCell.h"
#import "gTarSequencerViewController.h"

@implementation InstrumentCell

@synthesize instrument;
@synthesize patternToDisplay;
@synthesize measureViews;
@synthesize isSelected;
@synthesize parent;
@synthesize addMeasureButton;
@synthesize removeMeasureButton;
@synthesize instrumentIcon;
@synthesize instrumentIconView;
@synthesize instrumentIconViewBorder;
@synthesize instrumentName;
@synthesize minimapBorder;
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
        // Initialization code
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
    
    trashcanIcon = [UIImage imageNamed:@"Icon_Trash"];
    
    selectedPatternButton = nil;
}

- (void)layoutSubviews
{
    instrumentIconFrame = instrumentIconView.frame;
    
    minimapBorder.layer.borderWidth = 1.0;
    minimapBorder.layer.cornerRadius = 5.0;
    minimapBorder.layer.borderColor = [UIColor colorWithRed:110/255.0 green:110/255.0 blue:114/255.0 alpha:1].CGColor;
    
    CGFloat trashcanWidth = 35;
    CGFloat trashcanHeight = 45;
    trashcanFrame = CGRectMake((instrumentIconViewBorder.frame.size.width - trashcanWidth)/2 + instrumentIconViewBorder.frame.origin.x, 
                               (instrumentIconViewBorder.frame.size.height - trashcanHeight)/2 + instrumentIconViewBorder.frame.origin.y,
                               trashcanWidth,
                               trashcanHeight);
}

/*
 *  This function exists because the measureViews array needs to be init'ed before the cell can be updated,
 * which occurs at the end of cellForRowAtIndexPath in the main VC. At that point, however, layoutSubviews has not been called,
 * so something must be called explicitly.
 */
- (void)initMeasureViews
{
    if ( measureViews == nil )
    {
        measureViews = [[NSMutableArray alloc] initWithObjects:measureOne, measureTwo, measureThree, measureFour, nil];
        
        for (int i=0;i<[measureViews count];i++)
        {
            MeasureView * mv = [measureViews objectAtIndex:i];
            mv.bounds = CGRectMake(-2, -2, mv.frame.size.width + 2, mv.frame.size.height + 4);
            mv.backgroundColor = [UIColor clearColor];
            
            [mv addTarget:self action:@selector(userDidSelectNewMeasure:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    if ( patternButtons == nil )
    {
        patternButtons = [[NSMutableArray alloc] initWithObjects:patternA, patternB, patternC, patternD, offButton, nil];
        [self selectPatternButton:0];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

#pragma mark Deleting

- (IBAction)userDidTapInstrumentIcon:(id)sender
{
    if ( deleteMode )
    {
        [self disableDeleteMode];
        
        [parent deleteCell:self];
    }
    else {
        [self enableDeleteMode];
    }
}

- (void)enableDeleteMode
{
    deleteMode = YES;
    
    instrumentIconView.frame = trashcanFrame;
    
    instrumentIconView.image = trashcanIcon;
    
    instrumentIconViewBorder.backgroundColor = [UIColor redColor];
    
    // touch catcher:
    [self updateTouchCatcher];
    [touchCatcher setHidden:NO];
}

- (void)disableDeleteMode
{
    deleteMode = NO;
    
    instrumentIconView.frame = instrumentIconFrame;
    
    instrumentIconView.image = instrumentIcon;
    
    instrumentIconViewBorder.backgroundColor = backgroundColor;
    
    // touch catcher:
    [touchCatcher setHidden:YES];
}

- (void)updateTouchCatcher
{
    touchCatcher.delegate = self;
    
    CGRect cellFrame = [parent.instrumentTable rectForRowAtIndexPath:[parent.instrumentTable indexPathForCell:self]];
    
    CGRect newCatcherFrame = CGRectMake(0, -1 * cellFrame.origin.y, 480, 320);
    touchCatcher.frame = newCatcherFrame;

    [touchCatcher setAreaToIgnore:instrumentIconViewBorder.frame inParentView:self];
}

- (void)touchWasCaught:(CGPoint)touchCaught
{
    [self disableDeleteMode];
}

#pragma mark Minimap

- (void)update
{
    // update selected pattern:
    if ( instrument.selectedPatternDidChange )
    {
        self.patternToDisplay = instrument.selectedPattern;
        
        // If the instrument is muted, then the OFF button needs to be selected
        if ( instrument.isMuted )
        {
            [self selectPatternButton:MUTE_SEGMENT_INDEX];
        }
        else {
            [self selectPatternButton:instrument.selectedPatternIndex];
        }
    
        instrument.selectedPatternDidChange = NO;
    }
    
    // update the number of measures:
    if ( patternToDisplay.countChanged )
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
    for (int i=0;i<patternToDisplay.measureCount;i++)
    {
        MeasureView * mv = [measureViews objectAtIndex:i];
        [mv update];
    }
}

- (void)fillWithMeasures:(int)newCount
{
    for (int i=newCount;i<MAX_MEASURES_IN_UI;i++)
    {
        [[measureViews objectAtIndex:i] drawBorder];
    }
}


- (void)selectPatternButton:(int)index
{
    UIButton * newSelection = [patternButtons objectAtIndex:index];
    
    if ( selectedPatternButton == newSelection )
    {
        return;
    }
    else {
        [selectedPatternButton setSelected:NO];
        selectedPatternButton = newSelection;
        [selectedPatternButton setSelected:YES];
    }
}

- (void)selectMeasure:(int)indexToSelect
{
    [self deselect];

    MeasureView * mv = [measureViews objectAtIndex:indexToSelect];
    mv.backgroundColor = [UIColor colorWithRed:247/255.0 green:148/255.0 blue:29/255.0 alpha:1];
}

- (void)deselect
{
    for (MeasureView * mv in measureViews)
    {
        mv.backgroundColor = [UIColor clearColor];
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
    [selectedPatternButton setSelected:NO];
    [sender setSelected:YES];

    [self performSelector:@selector(selectNewPattern:) withObject:sender afterDelay:0.0];
}

// Split up into two functions to allow the UI to update immediately
- (void)selectNewPattern:(id)sender
{
    selectedPatternButton = sender;
    
    int tappedIndex = [patternButtons indexOfObject:sender];
    
    if ( tappedIndex == MUTE_SEGMENT_INDEX )
    {
        [parent muteInstrument:self];
    }
    else {
        [parent unmuteInstrument:self];
        [parent userDidSelectPattern:self atIndex:tappedIndex];
    }
}

#pragma mark Selecting Measures

- (IBAction)userDidSelectNewMeasure:(id)sender
{
    int tappedIndex = [measureViews indexOfObject:sender];
    
    if ( tappedIndex >= patternToDisplay.measureCount ) 
    {
        return;
    }
    else {
        [parent userDidSelectMeasure:self atIndex:tappedIndex];
    }
}

#pragma mark Adding and Removing Measures

- (IBAction)addMeasures:(id)sender
{
    [parent userDidAddMeasures:self];
}

- (IBAction)removeMeasures:(id)sender
{
    [parent userDidRemoveMeasures:self];
}

@end
