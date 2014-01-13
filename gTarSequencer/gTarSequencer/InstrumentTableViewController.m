//
//  InstrumentView.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "InstrumentTableViewController.h"

@implementation InstrumentTableViewController

@synthesize instrumentTable;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSLog(@"enter table view controller");
        
        // get instruments
        [self retrieveInstrumentOptions];
        
        // load instrument selector
        [self initInstrumentSelector];
        
        instruments = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"InstrumentTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"TrackCell"];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

#pragma mark Instruments Data

- (void)retrieveInstrumentOptions
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sequencerInstruments" ofType:@"plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSLog(@"The sequencer instrument plist exists");
    } else {
        NSLog(@"The sequencer instrument plist does not exist");
    }
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    masterInstrumentOptions = [plistDictionary objectForKey:@"Instruments"];
    remainingInstrumentOptions = [[NSMutableArray alloc] init];
    
    // Copy master options into remaining options:
    for (NSDictionary * dict in masterInstrumentOptions) {
        [remainingInstrumentOptions addObject:dict];
    }
 
}

#pragma mark - Adding instruments

- (void)addNewInstrumentWithIndex:(int)index andName:(NSString *)instName andIconName:(NSString *)iconName
{
    Instrument * newInstrument = [[Instrument alloc] init];
    newInstrument.instrument = index;
    newInstrument.instrumentName = instName;
    newInstrument.iconName = iconName;
    
    [instruments addObject:newInstrument];
 
    [self selectInstrument:[instruments count] - 1];
    
    // insert cell:
    if ([instruments count] == 1){
        
        [delegate turnOffGuitarEffects];
        
        // Reloading data forcibly resizes the add inst button
        // TODO: is this necessary?
        [instrumentTable reloadData];
        
    }else{
        
        // If there are no more options in the options array, then reload the table to get rid of the +inst cell.
        if ([remainingInstrumentOptions count] == 0){
            [instrumentTable reloadData];
        }else{
            [instrumentTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[instruments count] -1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            
            if(![delegate checkIsPlaying]){
                [self updateAllVisibleCells];
            }
        }
    }
    
    [delegate saveContext];
}

#pragma mark Table View Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([remainingInstrumentOptions count] == 0)
        return [instruments count];
    else
        return [instruments count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tableHeight = instrumentTable.frame.size.height;
    
    if([instruments count] == 0)
        return tableHeight+3;
    else
        return tableHeight/3+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (indexPath.row < [instruments count])
    {
    
        static NSString *CellIdentifier = @"TrackCell";
        
        InstrumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[InstrumentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.parent = self;
        
        Instrument * tempInst = [instruments objectAtIndex:indexPath.row];
        [tempInst turnOnAllFlags];
        
        cell.instrumentName = tempInst.instrumentName;
        cell.instrumentIcon = [UIImage imageNamed:tempInst.iconName];
        cell.instrument = tempInst;
        
        // Display icon
        cell.instrumentIconView.image = cell.instrumentIcon;
        
        // Initialize pattern etc data
        [cell initMeasureViews];
        
        if(![delegate checkIsPlaying]){
            [cell update];
        }
        
        return cell;
        
    }
    else
    {
        UIColor *customGrey = [UIColor colorWithRed:118/255.0 green:136/255.0 blue:137/255.0 alpha:1];
        
        static NSString *CellIdentifier = @"AddInstrument";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.textLabel setText:@"ADD INSTRUMENT"];
        
        [cell.textLabel setTextColor:customGrey];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica Bold" size:25.0]];
        
        return cell;
    }
}

#pragma mark Instrument Selector

- (void)initInstrumentSelector
{
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    // construct selector:
    CGFloat selectorWidth = 364;
    CGFloat selectorHeight = 276;
    
    onScreenSelectorFrame = CGRectMake((x-selectorWidth)/2,
                                       (y-selectorHeight)/2,
                                       selectorWidth,
                                       selectorHeight);
    
    offLeftSelectorFrame = CGRectMake(-1.0f * onScreenSelectorFrame.size.width,
                                      onScreenSelectorFrame.origin.y,
                                      onScreenSelectorFrame.size.width,
                                      onScreenSelectorFrame.size.height);
    
    instrumentSelector = [[ScrollingSelector alloc] initWithFrame:offLeftSelectorFrame];
    [instrumentSelector setDelegate:self];
    
    // overlay by adding to the main view
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:instrumentSelector];

    [instrumentSelector setHidden:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == [instruments count] )
    {
        [self loadInstrumentSelector:self];
    }
}

- (IBAction)loadInstrumentSelector:(id)sender
{
    
    // Turn off selected status of the add instrument button (which was just clicked):
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[instruments count] inSection:0];
    UITableViewCell * addInstCell = [instrumentTable cellForRowAtIndexPath:indexPath];
    addInstCell.selected = NO;
    
    // Set instrumentSelectors options and move off screen:
    instrumentSelector.options = remainingInstrumentOptions;
    [instrumentSelector moveFrame:offLeftSelectorFrame];
    
    // Unhide instrument selector:
    [instrumentSelector setHidden:NO];
    instrumentSelector.alpha = 1.0;
    
    // Animate movement onscreen from the left:
    [UIView animateWithDuration:0.5f animations:^{[instrumentSelector moveFrame:onScreenSelectorFrame];}];
}

- (void)closeInstrumentSelector
{
    // Animate movement offscreen to the left:
    [UIView animateWithDuration:0.5f
                     animations:^{[instrumentSelector moveFrame:offLeftSelectorFrame]; instrumentSelector.alpha = 0.3;}
                     completion:^(BOOL finished){[self hideInstrumentSelector]; }];
}

- (void)hideInstrumentSelector
{
    [instrumentSelector setHidden:YES];
}

#pragma mark Instrument Selector Delegate

- (void)scrollingSelectorUserDidSelectIndex:(int)indexSelected
{
    [self closeInstrumentSelector];
    
    if ( indexSelected >= 0 )
    {
        NSDictionary * dict = [remainingInstrumentOptions objectAtIndex:indexSelected];
        
        // Remove that instrument from the array:
        [remainingInstrumentOptions removeObjectAtIndex:indexSelected];
        
        NSNumber * instIndex = [dict objectForKey:@"Index"];
        NSString * instName = [dict objectForKey:@"Name"];
        NSString * iconName = [dict objectForKey:@"IconName"];
        
        [self addNewInstrumentWithIndex:[instIndex intValue] andName:instName andIconName:iconName];
    }
}

#pragma mark Selecting Instrument

- (void)selectInstrument:(int)index
{
    // Deselect old:
    for (Instrument * seq in instruments)
    {
        [seq setSelected:NO];
    }
    
    selectedInstrumentIndex = index;
    
    [delegate updateInstruments:instruments setSelected:index];
    
    NSLog(@"Selected Instrument Index is %i",index);
    
    // Select new:
    Instrument * newSelection = [instruments objectAtIndex:selectedInstrumentIndex];
    [newSelection setSelected:YES];
    
    // Update guitarView's measureToDisplay
    [delegate setMeasureAndUpdate:newSelection.selectedPattern.selectedMeasure checkNotPlaying:TRUE];
    
    if(![delegate checkIsPlaying]){
        [delegate updateGuitarView];
    }
}

- (void)deleteCell:(id)sender
{
    NSIndexPath * pathToDelete = [instrumentTable indexPathForCell:sender];
    
    // Remove from data structure:
    [self removeSequencerWithIndex:pathToDelete.row];
    
    // If the remaining options was previously empty (aka current count == 1),
    //      then reload the table to get the +inst cell back.
    if([remainingInstrumentOptions count] == 1){
        [instrumentTable reloadData];
    }else{
        // Else, delete the cell that the user requested:
        [instrumentTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathToDelete] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if ([instruments count] == 0){
        [instrumentTable reloadData];
    }
    
    // Update cells:
    if([instruments count] > 0){
        if(![delegate checkIsPlaying]){
            [self updateAllVisibleCells];
        }
    }else{
        [delegate forceStopAll];
    }
    
    [delegate saveContext];
}

- (void)removeSequencerWithIndex:(int)indexToRemove
{
    // Remove object from array:
    Instrument * removedInst = [instruments objectAtIndex:indexToRemove];
    [instruments removeObjectAtIndex:indexToRemove];
    
    // Add isntrument back into instrument options array:
    [self addInstrumentBackIntoOptions:removedInst];
    
    /* If the selected instrument is about to be removed, then a new one must be selected.
     The selected index must also be updated if an instrument above the selected is deleted.
     If the instrument being deleted is the last instrument, then the guitarView must be cleared
     and the playband reset */
    if(selectedInstrumentIndex == indexToRemove){
        // If there are no more instruments:
        if ([instruments count] == 0){
            // Clear guitarView and playspot
            selectedInstrumentIndex = -1;
            [delegate setMeasureAndUpdate:nil checkNotPlaying:FALSE];

            [delegate resetPlayLocation];
        }else{
            // If there are instruments before this one...
            if(indexToRemove > 0){
                // Then select an instrument before.
                [self selectInstrument:indexToRemove - 1];
            }else{
                // Else, select one after (at the same index because everything shifts)
                [self selectInstrument:indexToRemove];
            }
        }
    }
    else if(selectedInstrumentIndex > indexToRemove){
        /* If the selected one is not being deleted, but something
         above it is, than the index in the array needs to be shifted */
        [self selectInstrument:selectedInstrumentIndex - 1];
    }
}

#pragma mark Re-adding Instruments

- (void)addInstrumentBackIntoOptions:(Instrument *)inst
{
    // Get the dictionary associated with this inst:
    NSDictionary * instrumentDictionary;
    
    int i = 0;
    for(NSDictionary * instDict in masterInstrumentOptions){
        
        if([[instDict objectForKey:@"Name"] isEqualToString:inst.instrumentName]){
            instrumentDictionary = instDict;
        }
        
        i++;
    }
    
    // Add this dictionary to the end:
    [remainingInstrumentOptions addObject:instrumentDictionary];
    
    // Bubble up:
    int lastIndex = [remainingInstrumentOptions count] - 1;
    
    [self bubbleUp:lastIndex];
}

- (void)bubbleUp:(int)index
{
    // Base case:
    if (index == 0){
        return;
    }
    
    if([self does:[remainingInstrumentOptions objectAtIndex:index] comeBefore:[remainingInstrumentOptions objectAtIndex:index-1]
            inArray:masterInstrumentOptions]){
        
        [self swap:index with:index-1 inArray:remainingInstrumentOptions];
    }
    
    [self bubbleUp:index-1];
}

- (void)swap:(int)indexOne with:(int)indexTwo inArray:(NSMutableArray *)array
{
    id tempObj = [array objectAtIndex:indexOne];
    
    [array replaceObjectAtIndex:indexOne withObject:[array objectAtIndex:indexTwo]];
    
    [array replaceObjectAtIndex:indexTwo withObject:tempObj];
}

- (BOOL)does:(NSDictionary *)first comeBefore:(NSDictionary *)second inArray:(NSArray *)array
{
    if([array indexOfObject:first] < [array indexOfObject:second]){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark Mute Unmute Instrument Update View
- (void)muteInstrument:(InstrumentTableViewCell *)sender isMute:(BOOL)isMute
{

    if(isMute == YES) NSLog(@"Mute instrument");
    
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];
    
    tempInst.isMuted = isMute;
}

#pragma mark UI Input

- (void)userDidSelectPattern:(InstrumentTableViewCell *)sender atIndex:(int)index
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];
    
    if ([delegate checkIsPlaying]){
        
        // Add it to the queue:
        NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
        
        [pattern setObject:[NSNumber numberWithInt:index] forKey:@"Index"];
        [pattern setObject:tempInst forKey:@"Instrument"];
        
        [delegate enqueuePattern:pattern];
        
    } else {
        [self commitSelectingPatternAtIndex:index forInstrument:tempInst];
    }
}

- (void)commitSelectingPatternAtIndex:(int)indexToSelect forInstrument:(Instrument *)inst
{
    if (inst.selectedPatternIndex == indexToSelect){
        return;
    }
    
    Pattern * newSelection = [inst selectPattern:indexToSelect];
    
    [self updatePlaybandForInstrument:inst];
    
    [self selectInstrument:[instruments indexOfObject:inst]];
    
    [delegate setMeasureAndUpdate:newSelection.selectedMeasure checkNotPlaying:TRUE];

    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [delegate saveContext];
}

- (void)userDidSelectMeasure:(InstrumentTableViewCell *)sender atIndex:(int)index
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * sequencerAtIndex = [instruments objectAtIndex:senderIndex];
    
    // -- update DS
    [sequencerAtIndex selectMeasure:index];
    
    // -- select the (potentially new) instrument
    [self selectInstrument:senderIndex];
    
    // -- update minimap
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [delegate saveContext];
    
}

- (void)userDidAddMeasures:(InstrumentTableViewCell *)sender
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * instrumentAtIndex = [instruments objectAtIndex:senderIndex];
    [instrumentAtIndex addMeasure];
    
    [self updatePlaybandForInstrument:instrumentAtIndex];
    
    [self selectInstrument:senderIndex];
    
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [delegate saveContext];
    
}

- (void)userDidRemoveMeasures:(InstrumentTableViewCell *)sender
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * instrumentAtIndex = [instruments objectAtIndex:senderIndex];
    [instrumentAtIndex removeMeasure];
    
    [self updatePlaybandForInstrument:instrumentAtIndex];
    
    [sender update];
    
    [delegate setMeasureAndUpdate:instrumentAtIndex.selectedPattern.selectedMeasure checkNotPlaying:FALSE];
    
    [delegate saveContext];
}

/* Ensures that the current playband is accurately reflected in
 the data, provided that there is a playband to display (ie >= 0).
 Only needs to be called when the number of measures changes. */
- (void)updatePlaybandForInstrument:(Instrument *)inst
{
    /*if ( currentFret >= 0 )
    {
        int realMeasure = [inst.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
        [inst playFret:currentFret inRealMeasure:realMeasure withSound:NO];
    }*/
    
    NSLog(@"update playband...");
}


- (void)updateAllVisibleCells
{
    NSArray * visibleCells = [[instrumentTable visibleCells] copy];
    
    int limit = [visibleCells count];
    
    for (int i=0;i<limit;i++){
        
        InstrumentTableViewCell * track = (InstrumentTableViewCell *) [visibleCells objectAtIndex:i];
        
        if ([track respondsToSelector:@selector(update)]){
            [track update];
        }
    }
}

@end
