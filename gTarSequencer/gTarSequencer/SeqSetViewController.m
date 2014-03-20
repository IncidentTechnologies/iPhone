//
//  InstrumentView.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SeqSetViewController.h"

#define MAX_INSTRUMENTS 5

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@implementation SeqSetViewController

@synthesize instrumentTable;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSLog(@"enter table view controller");
        
        soundMaster = [[SoundMaster alloc] init];
        
        // get instruments
        [self retrieveInstrumentOptions];
        
        // load instrument selector
        [self initInstrumentSelector];
        
        // load custom instrument selector
        [self initCustomInstrumentSelector];
        
        instruments = [[NSMutableArray alloc] init];
        
        self.tableView.bounces = NO;
        [self turnContentDrawingOn];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Check screen size for nib
    NSString * nibname = @"SeqSetViewCell";
    if([[UIScreen mainScreen] bounds].size.height == XBASE_LG){
        nibname = @"SeqSetViewCell_4";
    }
    
    UINib *nib = [UINib nibWithNibName:nibname bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"TrackCell"];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self turnEditingOn];
    
}

#pragma mark Save Context
- (void)saveContext:(NSString *)filepath
{
    [delegate saveContext:filepath];
}

#pragma mark Instruments Data

- (void)retrieveInstrumentOptions
{
    
    // Init
    customInstrumentOptions = [[NSMutableArray alloc] init];
    masterInstrumentOptions = [[NSMutableArray alloc] init];
    sequencerInstrumentsPath = [[NSBundle mainBundle] pathForResource:@"sequencerInstruments" ofType:@"plist"];
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:sequencerInstrumentsPath];
    
    // Check for the local custom instrument list
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    customInstrumentsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"customSequencerInstruments.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // If it exists append it to the regular list
    if([fileManager fileExistsAtPath:customInstrumentsPath]){
        NSLog(@"The custom instruments plist exists");
        
        NSMutableDictionary * customDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:customInstrumentsPath];
        
        [customInstrumentOptions addObjectsFromArray:[customDictionary objectForKey:@"Instruments"]];
        
        [masterInstrumentOptions addObjectsFromArray:[plistDictionary objectForKey:@"Instruments"]];
        [masterInstrumentOptions addObjectsFromArray:customInstrumentOptions];
        
        
    }else{
        NSLog(@"The custom instruments plist does not exist");
        masterInstrumentOptions = [plistDictionary objectForKey:@"Instruments"];
    }

    [self setRemainingInstrumentOptionsFromMasterOptions];
 
}

- (void)setRemainingInstrumentOptionsFromMasterOptions
{
    remainingInstrumentOptions = [[NSMutableArray alloc] init];
    
    // Copy master options into remaining options:
    for (NSDictionary * dict in masterInstrumentOptions) {
        [remainingInstrumentOptions addObject:dict];
    }
}

- (void)setInstrumentsFromData:(NSData *)instData
{
    
    // clear table if it's not empty
    if([instruments count] > 0){
        for(int i = 0; i < [instruments count]; i++){
            [self deleteCell:[instrumentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] withAnimation:NO];
        }
    }
    
    [self setRemainingInstrumentOptionsFromMasterOptions];    
    instruments = [NSKeyedUnarchiver unarchiveObjectWithData:instData];
    
    // Remove all the previously used instruments from the remaining list:
    NSMutableArray * dictionariesToRemove = [[NSMutableArray alloc] init];
    NSMutableArray * instrumentsToRemove = [[NSMutableArray alloc] init];
    for (Instrument * inst in instruments)
    {
        BOOL found = false;
        for (NSDictionary * dict in remainingInstrumentOptions)
        {
            if ( [[dict objectForKey:@"Name"] isEqualToString:inst.instrumentName] )
            {
                found = true;
                [inst initAudioWithInstrumentName:inst.instrumentName andSoundMaster:soundMaster];
                [dictionariesToRemove addObject:dict];
            }
        }
        
        // extra cleanup
        if(!found){
            [instrumentsToRemove addObject:inst];
        }
    }
    
    [instruments removeObjectsInArray:instrumentsToRemove];
    [remainingInstrumentOptions removeObjectsInArray:dictionariesToRemove];
    
    [instrumentTable reloadData];
    
    [delegate numInstrumentsDidChange:[instruments count]];
    
}

- (Instrument *)getCurrentInstrument
{
    if([instruments count] > 0 && selectedInstrumentIndex >= 0 && selectedInstrumentIndex < [instruments count])
        return [instruments objectAtIndex:selectedInstrumentIndex];
    else
        return nil;
}

- (long)countInstruments
{
    return [instruments count];
}

- (NSMutableArray *)getInstruments
{
    return instruments;
}

- (Instrument *)getInstrumentAtIndex:(int)i
{
    if(i < [instruments count] && i >= 0)
        return [instruments objectAtIndex:i];
    else
        return nil;
}

- (NSMutableArray *)getCustomInstrumentOptions
{
    return customInstrumentOptions;
}

#pragma mark - Instrument View Delegate
- (void)reloadTableData
{
    [instrumentTable reloadData];
}

#pragma mark - Selected Instrument Data
- (void)resetSelectedInstrumentIndex
{
    [self selectInstrument:-1];
}

- (long)getSelectedInstrumentIndex
{
    return selectedInstrumentIndex;
}

- (void)setSelectedInstrumentIndex:(int)index
{
    [self selectInstrument:index];
}

// Update the selected instrument and have delegate load view
- (void)viewSelectedInstrument:(SeqSetViewCell *)sender
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    NSLog(@"Selecting instrument at index %li",senderIndex);
    
    [self selectInstrument:senderIndex];
    
    [delegate viewSelectedInstrument];
}

- (void)setSelectedCellToSelectedInstrument
{
    /*@synchronized(instruments){
        for(int i = 0; i < [instruments count]; i++){
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:indexPath];
            
            if([cell respondsToSelector:@selector(instrument)] && cell.instrument != nil){
                
                if(i == selectedInstrumentIndex){
                    [self fadeCell:cell animateIn:YES];
                }else{
                    [self fadeCell:cell animateIn:NO];
                }
            }else{
                return;
            }
        }
    }*/
}

- (void)fadeCell:(SeqSetViewCell *)cell animateIn:(BOOL)isIn
{
    float newAlpha = (isIn) ? 1.0 : 0.7;
    [UIView animateWithDuration:0.2 animations:^(void){cell.alpha=newAlpha;}];
    
}

#pragma mark - Adding instruments

- (void)addNewInstrumentWithIndex:(int)index andName:(NSString *)instName andIconName:(NSString *)iconName andStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths andIsCustom:(NSNumber *)isCustom
{
    Instrument * newInstrument = [[Instrument alloc] init];
    newInstrument.instrument = index;
    newInstrument.instrumentName = instName;
    newInstrument.iconName = iconName;
    newInstrument.stringSet = stringSet;
    newInstrument.stringPaths = stringPaths;
    newInstrument.isCustom = isCustom;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [newInstrument initAudioWithInstrumentName:instName andSoundMaster:soundMaster];
    });
    
    [instruments addObject:newInstrument];
 
    [self selectInstrument:[instruments count] - 1];
    
    // insert cell:
    if ([instruments count] == 1){
        
        [delegate turnOffGuitarEffects];
        
        // Reloading data forcibly resizes the add inst button
        [instrumentTable reloadData];
        
    }else{
        
        // If there are no more options in the options array, then reload the table to get rid of the +inst cell.
        if ([remainingInstrumentOptions count] == 0){
            [instrumentTable reloadData];
        }else{
            [instrumentTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[instruments count] -1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            
            if(![delegate checkIsPlaying]){
                [self updateAllVisibleCells];
            }
        }
    }
    
    [delegate numInstrumentsDidChange:[instruments count]];
    [delegate saveContext:nil];
}

#pragma mark Table View Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([remainingInstrumentOptions count] == 0){
        return [instruments count];
    }else{
        return [instruments count] + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tableHeight = instrumentTable.frame.size.height;
    
    if([instruments count] >= MAX_INSTRUMENTS && indexPath.row == [instruments count]){
        return 0;
    }else if([instruments count] == 0)
        return tableHeight;
    else if(indexPath.row < [instruments count])
        return tableHeight/3+1;
    else if([instruments count] == 1)
        return 2*tableHeight/3-1;
    else if([instruments count] == 2)
        return tableHeight/3-2;
    
    // else
    return tableHeight/3;
}

- (void)enforceTableWidth
{
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    int tableWidth = (screenHeight >= XBASE_LG) ? XBASE_LG : XBASE_SM;
    
    [self.view setFrame:CGRectMake(0, 0, tableWidth, self.view.frame.size.height)];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self enforceTableWidth];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (indexPath.row < [instruments count]){
    
        static NSString *CellIdentifier = @"TrackCell";
        
        SeqSetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[SeqSetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.parent = self;
        
        Instrument * tempInst = [instruments objectAtIndex:indexPath.row];
        [tempInst turnOnAllFlags];
        
        cell.instrumentName = tempInst.instrumentName;
        cell.instrumentIcon = [UIImage imageNamed:tempInst.iconName];
        cell.instrument = tempInst;
        cell.isMute = tempInst.isMuted;
        
        [cell resetVolume];
        
        if([tempInst checkIsCustom]){
            [cell showCustomIndicator];
        }else{
            [cell hideCustomIndicator];
        }
        
        // Display icon
        cell.instrumentIconView.image = cell.instrumentIcon;
        
        // Initialize pattern etc data
        [cell initMeasureViews];
        
        if(![delegate checkIsPlaying]){
            [cell update];
        }
        
        [cell setMultipleTouchEnabled:YES];
        
        // Check if selected
        /*if(cell.isSelected || selectedInstrumentIndex == indexPath.row){
            selectedInstrumentIndex = indexPath.row;
            [self fadeCell:cell animateIn:YES];
        }else{
            [self fadeCell:cell animateIn:NO];
        }*/
        
        return cell;
        
    }else{
        
        static NSString *CellIdentifier = @"AddInstrument";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.textLabel setText:@"ADD TRACK"];
        
        [cell.textLabel setTextColor:[UIColor colorWithRed:36/255.0 green:109/255.0 blue:127/255.0 alpha:1]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        
        [cell.textLabel setFont:[UIFont fontWithName:FONT_DEFAULT size:25.0]];
        
        [cell setMultipleTouchEnabled:NO];
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [instruments count]){
        return NO;
    }else{
        return canEdit;
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self turnContentDrawingOff];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self scrollingDidFinish];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingDidFinish];
}

-(void)scrollingDidFinish
{
    [self turnContentDrawingOn];
    [self updateAllVisibleCells];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // make sure the cell is open
    SeqSetViewCell * cell = (SeqSetViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(editingStyle == UITableViewCellEditingStyleDelete && cell.editingScrollView.contentOffset.x > 0){
        [self deleteCell:[tableView cellForRowAtIndexPath:indexPath] withAnimation:YES];
    }
}

- (void)notifyQueuedPatternsAtIndex:(int)index andResetCount:(BOOL)reset
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:indexPath];
    
    // Double check the cell knows it has a queued pattern
    if(![cell hasQueuedPatternButton]){
        int queuedIndex = [delegate getQueuedPatternIndexForInstrument:cell.instrument];
        if(queuedIndex >= 0){
            NSLog(@"Auto enqueuing a pattern button");
            [cell enqueuePatternButton:queuedIndex];
        }
    }
    
    [cell notifyQueuedPatterns:reset];
    
}

// Top to bottom
- (void)clearQueuedPatternButtonAtIndex:(int)index
{
    // Switch from instrument index to table index
    
    for(int i = 0; i < [instrumentTable numberOfRowsInSection:0] - 1; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:indexPath];
        
        if(cell.instrument.instrument == index){
            [cell resetQueuedPatternButton];
        }
    }
}

// Bottom to top
- (void)dequeueAllPatternsForInstrument:(id)sender
{
    SeqSetViewCell * cell = (SeqSetViewCell *)sender;
    Instrument * inst = cell.instrument;
    int instIndex = inst.instrument;
    
    [delegate removeQueuedPatternForInstrumentAtIndex:instIndex];
    
}


- (void)turnEditingOff
{
    canEdit = NO;
}

- (void)turnEditingOn
{
    canEdit = YES;
}

- (void)turnContentDrawingOff
{
    allowContentDrawing = NO;
}

- (void)turnContentDrawingOn
{
    allowContentDrawing = YES;
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
    if(indexPath.row == [instruments count]){
        [self loadInstrumentSelector:self andScroll:NO];
    }
}

- (IBAction)loadInstrumentSelector:(id)sender andScroll:(BOOL)scroll
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
    
    if(scroll){
        [NSTimer scheduledTimerWithTimeInterval:0.2 target:instrumentSelector selector:@selector(scrollToMax) userInfo:nil repeats:NO];
    }
    
    [self turnContentDrawingOff];
    
}

- (void)closeInstrumentSelector
{
    // Animate movement offscreen to the left:
    [UIView animateWithDuration:0.5f
                     animations:^{[instrumentSelector moveFrame:offLeftSelectorFrame]; instrumentSelector.alpha = 0.3;}
                     completion:^(BOOL finished){
                         [self hideInstrumentSelector];
                         [self turnContentDrawingOn];
                     }];
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
        NSArray * stringSet = [dict objectForKey:@"Strings"];
        NSArray * stringPaths = [dict objectForKey:@"StringPaths"];
        NSNumber * isCustom = [dict objectForKey:@"Custom"];
        
        [self addNewInstrumentWithIndex:[instIndex intValue] andName:instName andIconName:iconName andStringSet:stringSet andStringPaths:stringPaths andIsCustom:isCustom];
    }
}

- (void)scrollingSelectorDidRemoveIndex:(int)indexSelected
{
    if(indexSelected >= 0){
        
        // Remove that instrument from the array:
        NSDictionary * instOption = [remainingInstrumentOptions objectAtIndex:indexSelected];
        NSNumber * instIndex = [instOption objectForKey:@"Index"];
        
        NSLog(@"Remove instrument at selected index %i",indexSelected);
        
        [remainingInstrumentOptions removeObjectAtIndex:indexSelected];

        for(int i = 0; i < [masterInstrumentOptions count]; i++){
            NSDictionary * dict = [masterInstrumentOptions objectAtIndex:i];
            if([dict objectForKey:@"Index"] == instIndex){
                [masterInstrumentOptions removeObjectAtIndex:i];
            }
        }
        
        for(int i = 0; i < [customInstrumentOptions count]; i++){
            NSDictionary * dict = [customInstrumentOptions objectAtIndex:i];
            if([dict objectForKey:@"Index"] == instIndex){
                [customInstrumentOptions removeObjectAtIndex:i];
            }
        }
        
        instrumentSelector.options = remainingInstrumentOptions;
        
        // Resave pList
        [self saveCustomInstrumentToPlist:customInstrumentOptions];
    
    }
}

- (void)initCustomInstrumentSelector
{
    
    // TODO: figure out positioning for 4"
    NSLog(@"Init custom instrument selector");
    
    // Get dimensions
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    // construct selector:
    CGFloat selectorWidth = 364;
    CGFloat selectorHeight = 276;
    
    onScreenCustomSelectorFrame = CGRectMake((x-selectorWidth)/2,
                                       (y-selectorHeight)/2,
                                       selectorWidth,
                                       selectorHeight);
    
    offLeftCustomSelectorFrame = CGRectMake(onScreenCustomSelectorFrame.origin.x,
                                            y,
                                            onScreenCustomSelectorFrame.size.width,
                                            onScreenCustomSelectorFrame.size.height);
    
    customSelector = [[CustomInstrumentSelector alloc] initWithFrame:offLeftCustomSelectorFrame];
    [customSelector setDelegate:self];
    
    UIWindow *window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [window addSubview:customSelector];
    
    [customSelector setHidden:YES];
}

// open
- (void)launchCustomInstrumentSelector
{
    [customSelector setHidden:NO];
    [customSelector moveFrame:offLeftCustomSelectorFrame];
    [customSelector launchSelectorView];
    
    customSelector.alpha = 1.0;
    
    [UIView animateWithDuration:0.5f animations:^{[customSelector moveFrame:onScreenCustomSelectorFrame];}];
    [self closeInstrumentSelector];
    
    customSelector.userInteractionEnabled = YES;
}

// close
- (void)closeCustomInstrumentSelectorAndScroll:(BOOL)scroll
{
    
    [UIView animateWithDuration:0.5f
                     animations:^{[customSelector moveFrame:offLeftCustomSelectorFrame]; customSelector.alpha = 0.3;}
                     completion:^(BOOL finished){[self hideCustomInstrumentSelector]; }];

    [self loadInstrumentSelector:self andScroll:scroll];
}

// hide (call close instead)
-(void)hideCustomInstrumentSelector
{
    [customSelector setHidden:YES];
}

// save a new instrument
- (void)saveCustomInstrumentWithStrings:(NSArray *)stringSet andName:(NSString *)instName andStringPaths:(NSArray *)stringPaths andIcon:(NSString *)iconName
{
    NSNumber * newIndex = [NSNumber numberWithInt:[self getCustomInstrumentsNewIndex]];

    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithBool:TRUE] forKey:@"Custom"];
    [dict setValue:iconName forKey:@"IconName"];
    [dict setValue:newIndex forKey:@"Index"];
    [dict setValue:instName forKey:@"Name"];
    [dict setValue:stringSet forKey:@"Strings"];
    [dict setValue:stringPaths forKey:@"StringPaths"];
    
    [masterInstrumentOptions addObject:dict];
    [remainingInstrumentOptions addObject:dict];
    [customInstrumentOptions addObject:dict];
    
    [self saveCustomInstrumentToPlist:customInstrumentOptions];
    [self closeCustomInstrumentSelectorAndScroll:NO];
}

- (int)getCustomInstrumentsNewIndex
{
    
    if([customInstrumentOptions count] > 0){
        NSMutableDictionary * lastInst = [customInstrumentOptions lastObject];
        return [[lastInst objectForKey:@"Index"] intValue]+1;
    }else{
        return [masterInstrumentOptions count];
    }
}

- (void)saveCustomInstrumentToPlist:(NSArray *)options
{
    
    NSMutableDictionary * wrapperDict = [[NSMutableDictionary alloc] init];
    [wrapperDict setValue:options forKey:@"Instruments"];
    
    [wrapperDict writeToFile:customInstrumentsPath atomically:YES];
}


#pragma mark Selecting Instrument

- (void)selectInstrument:(long)index
{
    // Deselect old:
    for (Instrument * seq in instruments)
    {
        [seq setSelected:NO];
    }
    
    selectedInstrumentIndex = index;
    
    // Select new:
    if(selectedInstrumentIndex >= 0 && selectedInstrumentIndex < [instruments count]){
        
        Instrument * newSelection = [instruments objectAtIndex:selectedInstrumentIndex];
        [newSelection setSelected:YES];
        
        // Update guitarView's measureToDisplay
        [delegate setMeasureAndUpdate:newSelection.selectedPattern.selectedMeasure checkNotPlaying:TRUE];
    }
    
    if(![delegate checkIsPlaying]){
        [delegate updateGuitarView];
    }else{
        [delegate updateSelectedInstrument];
    }
}

- (void)deleteCell:(id)sender withAnimation:(BOOL)animate
{
    
    NSLog(@"Delete cell");
    
    NSIndexPath * pathToDelete = [instrumentTable indexPathForCell:sender];
    int row = pathToDelete.row;
    int section = pathToDelete.section;
    
    // Beware race conditions deleting 5+ instruments at a time
    @synchronized(instruments){
        // Remove from data structure:
        [self removeSequencerWithIndex:pathToDelete.row];
        
        if(TESTMODE) NSLog(@"Removed from data structure");
        
        SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        
        if(animate){
            [UIView animateWithDuration:0.3 animations:^(void){
                [cell setAlpha:0.0];
            } completion:^(BOOL finished){
                [self removeCellAtRow:row andSection:section];
            }];
        }else{
            [self removeCellAtRow:row andSection:section];
        }
        
        if(TESTMODE) NSLog(@"Deleted row");
    }
}

-(void)removeCellAtRow:(int)row andSection:(int)section
{
    
    [instrumentTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    
    if(TESTMODE) NSLog(@"Reload data");
    
    if ([instruments count] == 0){
        [instrumentTable reloadData];
    }
    
    // Remove any enqueued patterns
    [delegate removeQueuedPatternForInstrumentAtIndex:row];
    
   if(TESTMODE)  NSLog(@"Enqueued patterns removed");
    
    // Update cells:
    if([instruments count] > 0){
        if(![delegate checkIsPlaying]){
            [self updateAllVisibleCells];
        }
    }else{
        [self stopAllPlaying];
    }
    
    [delegate numInstrumentsDidChange:[instruments count]];
    [delegate saveContext:nil];
}

- (void)deleteAllCells
{
    for(int i = [instruments count] - 1; i >= 0; i--){
        SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [self deleteCell:cell withAnimation:NO];
    }
}

- (void)removeSequencerWithIndex:(long)indexToRemove
{
    if(TESTMODE) NSLog(@"Remove sequencer with index %li",indexToRemove);
    
    // Remove object from array:
    Instrument * removedInst = [instruments objectAtIndex:indexToRemove];
    
    [removedInst releaseSounds];
    [instruments removeObjectAtIndex:indexToRemove];
    
    // Add instrument back into instrument options array:
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

#pragma mark - Check and start/stop playing

- (void)stopAllPlaying
{
    [delegate stopAll];
}

- (BOOL)checkIsPlaying
{
    return [delegate checkIsPlaying];
}

- (void)startAllPlaying
{
    [delegate startAll];
}

- (void)startSoundMaster
{
    [soundMaster start];
}

- (void)stopSoundMaster
{
    [soundMaster stop];
}

#pragma mark Re-adding Instruments

- (void)addInstrumentBackIntoOptions:(Instrument *)inst
{
    NSLog(@"Add instrument back into options");
    
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
    NSLog(@"Add dictionary to the end");
    if(instrumentDictionary != nil){
        [remainingInstrumentOptions addObject:instrumentDictionary];
    }
    
    // Bubble up:
    long lastIndex = [remainingInstrumentOptions count] - 1;
    
    [self bubbleUp:lastIndex];
    
    NSLog(@"Bubbled up");
    
}

- (void)bubbleUp:(long)index
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

- (void)swap:(long)indexOne with:(long)indexTwo inArray:(NSMutableArray *)array
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
/*
#pragma mark Mute Unmute Instrument Update View
- (void)muteInstrument:(SeqSetViewCell *)sender isMute:(BOOL)isMute
{
    if(isMute == YES) NSLog(@"Mute instrument");
    else NSLog(@"Unmute instrument");
    
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];
    
    tempInst.isMuted = isMute;
    
    [delegate saveContext:nil];
}
 */

#pragma mark UI Input

- (BOOL)userDidSelectPattern:(SeqSetViewCell *)sender atIndex:(int)index
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];
    
    // double check this isn't the current pattern
    if ([delegate checkIsPlaying] && tempInst.selectedPatternIndex != index){
        
        // Add it to the queue:
        NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
        
        [pattern setObject:[NSNumber numberWithInt:index] forKey:@"Index"];
        [pattern setObject:tempInst forKey:@"Instrument"];
        
        [delegate enqueuePattern:pattern];
        
        return YES;
        
    } else if (tempInst.selectedPatternIndex == index){
        
        [self dequeueAllPatternsForInstrument:sender];
        
    }
    
    [self commitSelectingPatternAtIndex:index forInstrument:tempInst];
    
    return NO;
}

- (void)commitSelectingPatternAtIndex:(int)indexToSelect forInstrument:(Instrument *)inst
{
    if (inst.selectedPatternIndex == indexToSelect){
        return;
    }
    
    Pattern * newSelection = [inst selectPattern:indexToSelect];
    
    [delegate updatePlaybandForInstrument:inst];
    
    [self selectInstrument:[instruments indexOfObject:inst]];
    
    [delegate setMeasureAndUpdate:newSelection.selectedMeasure checkNotPlaying:TRUE];

    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [delegate saveContext:nil];
}

- (void)userDidSelectMeasure:(SeqSetViewCell *)sender atIndex:(int)index
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * sequencerAtIndex = [instruments objectAtIndex:senderIndex];
    
    // -- update DS
    [sequencerAtIndex selectMeasure:index];
    
    // -- select the (potentially new) instrument
    [self selectInstrument:senderIndex];
    
    // -- update minimap
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [delegate saveContext:nil];
    
}

- (void)userDidAddMeasures:(SeqSetViewCell *)sender
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * instrumentAtIndex = [instruments objectAtIndex:senderIndex];
    [instrumentAtIndex addMeasure];
    
    [delegate updatePlaybandForInstrument:instrumentAtIndex];
    
    [self selectInstrument:senderIndex];
    
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [delegate saveContext:nil];
    
}

- (void)userDidRemoveMeasures:(SeqSetViewCell *)sender
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * instrumentAtIndex = [instruments objectAtIndex:senderIndex];
    [instrumentAtIndex removeMeasure];
    
    [delegate updatePlaybandForInstrument:instrumentAtIndex];
    
    [sender update];
    
    [delegate setMeasureAndUpdate:instrumentAtIndex.selectedPattern.selectedMeasure checkNotPlaying:FALSE];
    
    [delegate saveContext:nil];
}

- (void)updateAllVisibleCells
{
    if(allowContentDrawing){
        NSArray * visibleCells = [[instrumentTable visibleCells] copy];
        
        long limit = [visibleCells count];
        
        for (int i=0;i<limit;i++){
            SeqSetViewCell * cell = (SeqSetViewCell *) [visibleCells objectAtIndex:i];
            if ([cell respondsToSelector:@selector(update)]){
                //[cell update];
                [cell performSelectorInBackground:@selector(update) withObject:nil];
            }
        }
    }
    
    //[self setSelectedCellToSelectedInstrument];
}

@end
