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
}

- (void)layoutSubviews
{
    minimapBorder.layer.borderWidth = 1.0;
    minimapBorder.layer.cornerRadius = 5.0;
    minimapBorder.layer.borderColor = [UIColor colorWithRed:110/255.0 green:110/255.0 blue:114/255.0 alpha:1.0].CGColor;

    // Table Cells require programmatic constraints
    NSLayoutConstraint * bodyleading = [NSLayoutConstraint
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
                                         constant:0];
    
    NSLayoutConstraint * borderwidth = [NSLayoutConstraint
                                        constraintWithItem:borderContainer
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:NSLayoutRelationEqual
                                        toItem: self
                                        attribute:NSLayoutAttributeWidth
                                        multiplier:1.0f
                                        constant:20];
    
    [self addConstraints:@[bodyleading,bodytrailing,borderwidth]];
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
    if (deleteMode)
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
    
    //UIColor * customRed = [UIColor redColor];
    UIColor * customRed = [UIColor colorWithRed:131/255.0 green:12/255.0 blue:54/255.0 alpha:1];
    deleteMode = YES;
    
    instrumentIconView.backgroundColor = customRed;
    instrumentIconBorder.backgroundColor = customRed;
    
    self.instrumentIconView.image = [UIImage imageNamed:@"Icon_Trash"];
    
    // touch catcher:
    //[self updateTouchCatcher];
    //[touchCatcher setHidden:NO];
}

- (void)disableDeleteMode
{
    
    UIColor * customBlue = [UIColor colorWithRed:22/255.0 green:41/255.0 blue:68/255.0 alpha:1];
    
    deleteMode = NO;
    
    instrumentIconView.backgroundColor = customBlue;
    instrumentIconBorder.backgroundColor = customBlue;
    
    self.instrumentIconView.image = self.instrumentIcon;
    
    // touch catcher:
    // [touchCatcher setHidden:YES];
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
        [selectedPatternButton setSelected:NO];
        selectedPatternButton = newSelection;
        [selectedPatternButton setSelected:YES];
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
    [selectedPatternButton setSelected:NO];
    [sender setSelected:YES];
    
    [self performSelector:@selector(selectNewPattern:) withObject:sender afterDelay:0.0];
}

// Split up into two functions to allow the UI to update immediately
- (void)selectNewPattern:(id)sender
{
    selectedPatternButton = sender;
    
    int tappedIndex = [patternButtons indexOfObject:sender];
    
    NSLog(@"Select new pattern at %i", tappedIndex);
    
    if (tappedIndex == MUTE_SEGMENT_INDEX){
        [parent muteInstrument:self isMute:YES];
    }else{
        [parent muteInstrument:self isMute:NO];
        [parent userDidSelectPattern:self atIndex:tappedIndex];
    }
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
