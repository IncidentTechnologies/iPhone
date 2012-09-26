    //
//  MultipleTracksViewController.m
//  gTarSequencer
//
//  Created by Ilan Gray on 7/9/12.
//  Copyright (c) 2012 Congruity . All rights reserved.
//

#import "gTarSequencerViewController.h"
#import "InstrumentCell.h"

SoundMaker * audio;
UIColor * backgroundColor;
TouchCatcher * touchCatcher = nil;

@implementation gTarSequencerViewController

@synthesize tempoSlider;
@synthesize startStopButton;
@synthesize playNotesButton;
@synthesize instrumentTable;
@synthesize gTarLogoImageView;
@synthesize gTarConnectedText;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    // Load stuff from disk:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES); 
    instrumentDataFilePath = [[paths objectAtIndex:0]
                stringByAppendingPathComponent:@"sequencerCurrentState"];
    
    [self retrieveInstrumentOptions];
    
    [self loadStateFromDisk];
    
    // Init everything else:
    isConnected = NO;
    
    isPlaying = NO;
    currentFret = -1;
    currentAbsoluteMeasure = 0;
    patternQueue = [NSMutableArray array];
    
    [instrumentTable setDelegate:self];
    
    backgroundColor = [UIColor colorWithRed:22/255.0 green:41/255.0 blue:68/255.0 alpha:1];
    
    audio = [[SoundMaker alloc] init];
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
    if ( selectedInstrumentIndex >= 0 )
    {
        Instrument * tempInst = [instruments objectAtIndex:selectedInstrumentIndex];
        guitarView.measure = tempInst.selectedPattern.selectedMeasure;
    }
    [guitarView observeGtar];

    string = 0;
    fret = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Turn off bouncing of table:
    [self.instrumentTable setBounces:NO];
    
    // Set up tempo slider:
    [tempoSlider setToValue:tempo];
    [tempoSlider setDelegate:self];
    
    // construct selector:
    CGFloat selectorWidth = 364;
    CGFloat selectorHeight = 276;
    
    onScreenSelectorFrame = CGRectMake((480-selectorWidth)/2, 
                                       (320-selectorHeight)/2,
                                       selectorWidth, 
                                       selectorHeight);
    
    offLeftSelectorFrame = CGRectMake(-1 * onScreenSelectorFrame.size.width, 
                                      onScreenSelectorFrame.origin.y, 
                                      onScreenSelectorFrame.size.width, 
                                      onScreenSelectorFrame.size.height);
    
    instrumentSelector = [[ScrollingSelector alloc] initWithFrame:offLeftSelectorFrame];
    [instrumentSelector setDelegate:self];
    [self.view addSubview:instrumentSelector];
    [instrumentSelector setHidden:YES];
    
    [self updateConnectedImages];
    
    // Touch catcher:
    if ( touchCatcher == nil )
    {
        touchCatcher = [[TouchCatcher alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
        [self.view insertSubview:touchCatcher atIndex:[self.view.subviews count] - 1];
        [touchCatcher setHidden:YES];
    }
    
    // Pre-dequeue extra cells to make adding isntruments faster
    for (int i=0;i<4;i++)
    {
        [instrumentTable dequeueReusableCellWithIdentifier:@"TrackCell"];
    }
    
    [guitarView update];
    
    [instrumentTable reloadData];
}

- (void)viewDidUnload
{
    [self setTempoSlider:nil];
    [self setStartStopButton:nil];
    [self setPlayNotesButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.instrumentTable = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - Saving / Loading

- (void)save
{
    NSData * instrumentsData = [NSKeyedArchiver archivedDataWithRootObject:instruments];
    
    NSNumber * tempoNumber = [NSNumber numberWithInt:tempo];
    
    NSNumber * selectedInstIndexNumber = [NSNumber numberWithInt:selectedInstrumentIndex];
    
    [currentState setObject:instrumentsData forKey:@"Instruments Data"];
    [currentState setObject:tempoNumber forKey:@"Tempo"];
    [currentState setObject:selectedInstIndexNumber forKey:@"Selected Instrument Index"];
    
    BOOL success = [currentState writeToFile:instrumentDataFilePath atomically:YES];
    NSLog(@"Save success: %i", success);
}

- (void)loadStateFromDisk
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:instrumentDataFilePath]) {
        NSLog(@"The sequencer save plist exists");
    } else {
        NSLog(@"The sequencer save plist does not exist");
    }
    
    currentState = [[NSDictionary dictionaryWithContentsOfFile:instrumentDataFilePath] mutableCopy];
    
    if (currentState == nil )
        currentState = [[NSMutableDictionary alloc] init];
    
    if ( [[currentState allKeys] count] > 0 )
    {
        // Decode tempo:
        tempo = [[currentState objectForKey:@"Tempo"] intValue];
        
        // Decode selectedInstrumentIndex
        selectedInstrumentIndex = [[currentState objectForKey:@"Selected Instrument Index"] intValue];
        
        // Decode array of instruments:
        NSData * instrumentData = [currentState objectForKey:@"Instruments Data"];
        instruments = [NSKeyedUnarchiver unarchiveObjectWithData:instrumentData];
        
        // Remove all the previously used instruments from the remaining list:
        NSMutableArray * dictionariesToRemove = [[NSMutableArray alloc] init];
        for (Instrument * inst in instruments)
        {
            for (NSDictionary * dict in remainingInstrumentOptions)
            {
                if ( [[dict objectForKey:@"Name"] isEqualToString:inst.instrumentName] )
                {
                    [dictionariesToRemove addObject:dict];
                }
            }
        }
        
        [remainingInstrumentOptions removeObjectsInArray:dictionariesToRemove];
    }
    else {
        tempo = DEFAULT_TEMPO;

        selectedInstrumentIndex = -1;
        
        instruments = [[NSMutableArray alloc] init];
    }
}

#pragma mark - Playing/Pausing

- (IBAction)startStop:(id)sender
{
    if ( isPlaying )
    {
        [self stopAll];
    }
    else {
        if ( currentFret == -1 )
        {
            [self increasePlayLocation];
        }

        [self playAll];
    }
}

- (void)stopAll
{
    startStopButton.selected = NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    [playTimer invalidate];
    playTimer = nil;
    isPlaying = NO;
}

- (void)playAll
{
    startStopButton.selected = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Compute seconds per beat from tempo:
    double beatsPerSecond = tempo/SECONDS_PER_MIN;
    beatsPerSecond*=4;
    secondsPerBeat = 1/beatsPerSecond;
    
    NSLog(@"Seconds per beat: %f", secondsPerBeat);
    
    isPlaying = YES;
    
    [self performSelectorInBackground:@selector(startBackgroundLoop) withObject:nil];
}

- (void)startBackgroundLoop
{
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    
    playTimer = [NSTimer scheduledTimerWithTimeInterval:secondsPerBeat target:self selector:@selector(mainEventLoop) userInfo:nil repeats:YES];
    
    [runLoop run];
}

- (void)mainEventLoop
{
    // Tell all of the sequencers to play their next fret
    for (int i=0;i<[instruments count];i++)
    {
        Instrument * instToPlay = [instruments objectAtIndex:i];
        
        @synchronized(instToPlay.selectedPattern)
        {
            int realMeasure = [instToPlay.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
            
            // If we are back at the beginning of the pattern, then check the queue:
            if ( realMeasure == 0 && currentFret == 0 && [patternQueue count] > 0)
            {
                [self checkQueueForPatternsFromInstrument:instToPlay];
            }
            
            [instToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!instToPlay.isMuted];
        }
    }

    [self updateAllVisibleCells];
    
    [guitarView update];
    
    [self increasePlayLocation];
}

- (void)checkQueueForPatternsFromInstrument:(Instrument *)inst
{
    NSMutableArray * objectsToRemove = [NSMutableArray array];
    
    @synchronized(patternQueue)
    {
        // Pull out every pattern in the queue and select it
        for ( NSDictionary * patternToSelect in patternQueue )
        {
            int nextPatternIndex = [[patternToSelect objectForKey:@"Index"] intValue];
            Instrument * nextPatternInstrument = [patternToSelect objectForKey:@"Instrument"];
            
            if ( inst == nextPatternInstrument )
            {
                [objectsToRemove addObject:patternToSelect];
                [self commitSelectingPatternAtIndex:nextPatternIndex forInstrument:nextPatternInstrument];
            }
        }
        
        [patternQueue removeObjectsInArray:objectsToRemove];
    }
}

- (void)updateAllVisibleCells
{
    NSArray * visibleCells = [[instrumentTable visibleCells] copy];
    
    int limit = [visibleCells count];
    
    for (int i=0;i<limit;i++)
    {
        InstrumentCell * track = (InstrumentCell *) [visibleCells objectAtIndex:i];
        if ( [track respondsToSelector:@selector(update)] )
        {
            [track update];
        }
    }
}

- (void)increasePlayLocation
{
    currentFret++;
    
    if ( currentFret > LAST_FRET )
    {
        currentFret = 0;
        currentAbsoluteMeasure++;
        if ( currentAbsoluteMeasure > LAST_MEASURE )
        {
            currentAbsoluteMeasure = 0;
        }
    }
}

- (void)resetPlaySpot
{
    currentFret = -1;
    currentAbsoluteMeasure = 0;
}

- (void)muteInstrument:(InstrumentCell *)sender
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];
    
    if ( tempInst.isMuted )
    {
        
    }
    else {
        tempInst.isMuted = YES;
    }
}

- (void)unmuteInstrument:(InstrumentCell *)sender
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];
    
    tempInst.isMuted = NO;
}

#pragma mark UI Input

- (void)userDidSelectPattern:(InstrumentCell *)sender atIndex:(int)index
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * tempInst = [instruments objectAtIndex:senderIndex];  
    
    if ( isPlaying )
    {
        // Add it to the queue:
        NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
        
        [pattern setObject:[NSNumber numberWithInt:index] forKey:@"Index"];
        [pattern setObject:tempInst forKey:@"Instrument"];
        
        @synchronized(patternQueue)
        {
            [patternQueue addObject:pattern];
        }
    }
    else {
        [self commitSelectingPatternAtIndex:index forInstrument:tempInst];
    }
}

- (void)commitSelectingPatternAtIndex:(int)indexToSelect forInstrument:(Instrument *)inst
{
    if ( inst.selectedPatternIndex == indexToSelect )
    {
        return;
    }
    
    Pattern * newSelection = [inst selectPattern:indexToSelect];
    
    [self updatePlaybandForInstrument:inst];
    
    [self selectInstrument:[instruments indexOfObject:inst]];
    
    guitarView.measure = newSelection.selectedMeasure;
    
    if ( !isPlaying )
    {
        [guitarView update];
        [self updateAllVisibleCells];
    }
    
    [self save];
}

- (void)userDidSelectMeasure:(InstrumentCell *)sender atIndex:(int)index
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * sequencerAtIndex = [instruments objectAtIndex:senderIndex];
    
    // -- update DS
    [sequencerAtIndex selectMeasure:index];
    
    // -- select the (potentially new) instrument
    [self selectInstrument:senderIndex];
    
    // -- update minimap
    if ( !isPlaying )
    {
        [self updateAllVisibleCells];
    }
    
    [self save];
}

- (void)userDidAddMeasures:(InstrumentCell *)sender
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * instrumentAtIndex = [instruments objectAtIndex:senderIndex];
    [instrumentAtIndex addMeasure];
    
    [self updatePlaybandForInstrument:instrumentAtIndex];
    
    [self selectInstrument:senderIndex];

    if ( !isPlaying )
    {
        [self updateAllVisibleCells];
    }
    
    [self save];
}

- (void)userDidRemoveMeasures:(InstrumentCell *)sender
{
    int senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    Instrument * instrumentAtIndex = [instruments objectAtIndex:senderIndex];
    [instrumentAtIndex removeMeasure];
    
    [self updatePlaybandForInstrument:instrumentAtIndex];
    
    [sender update];
    
    guitarView.measure = instrumentAtIndex.selectedPattern.selectedMeasure;
    [guitarView update];
    
    [self save];
}

/* Ensures that the current playband is accurately reflected in
 the data, provided that there is a playband to display (ie >= 0).
 Only needs to be called when the number of measures changes. */
- (void)updatePlaybandForInstrument:(Instrument *)inst
{
    if ( currentFret >= 0 )
    {
        int realMeasure = [inst.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
        [inst playFret:currentFret inRealMeasure:realMeasure withSound:NO];
    }
}

#pragma mark - Tempo Slider Delegate

- (void)scrollButtonValueDidChange:(int)newValue
{
    if ( tempo != newValue )
    {
        tempo = newValue;
        if ( isPlaying )
        {
            [self stopAll];
            [self playAll];
        }
    }
    
    [self save];
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
    if ( [instruments count] == 1 )
    {
        [self turnOffGuitarEffects];
        [instrumentTable reloadData];       // Reloading data forcibly resizes the add inst button
    }
    else {
        // If there are no more options in the options array, then reload the table to get rid of the +inst cell.
        if ( [remainingInstrumentOptions count] == 0 )
        {
            [instrumentTable reloadData];
        }
        else
        {
            [instrumentTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[instruments count] -1 inSection:0]] 
                               withRowAnimation:UITableViewRowAnimationRight];
            
            if ( !isPlaying )
            {
                [self updateAllVisibleCells];
            }
        }
    }
    
    [self save];
}

- (void)turnOffGuitarEffects
{
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:guitarView.guitar selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:guitarView.guitar selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:guitarView.guitar selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:guitarView.guitar selector:@selector(turnOffAllEffects) userInfo:nil repeats:NO];
}

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
    
    // copy master options into remaining options:
    for (NSDictionary * dict in masterInstrumentOptions)
    {
        [remainingInstrumentOptions addObject:dict];
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
     
    // Select new:
    Instrument * newSelection = [instruments objectAtIndex:selectedInstrumentIndex];
    [newSelection setSelected:YES];
    
    // Update guitarView's measureToDisplay:
    guitarView.measure = newSelection.selectedPattern.selectedMeasure;
    if ( !isPlaying )
    {
        [guitarView update];
    }
}

- (IBAction)playSomeNotes:(id)sender 
{
    [guitarView.guitar turnOffAllEffects];

    [self notePlayedAtString:5 andFret:3];
    
    /*
    [self notePlayedAtString:string+1 andFret:fret+1];
    fret++;
    if ( fret > LAST_FRET )
    {
        fret = 0;
        string++;
        if ( string > 5 )
        {
            string = 0;
        }
    }*/
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( [remainingInstrumentOptions count] == 0 )
    {
        return [instruments count];
    }
    else 
    {
        return [instruments count] + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int lastInstIndex = [instruments count] - 1;

    if ( row <= lastInstIndex)
    {
        return 86;
    }
    else {
        if ( [instruments count] == 0 )
            return instrumentTable.frame.size.height;
        else
            return 81;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row < [instruments count] )
    {
        NSLog(@"Instrument cell");
        
        InstrumentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell"];

        [cell initMeasureViews];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.parent = self;
        
        Instrument * tempInst = [instruments objectAtIndex:indexPath.row];
        [tempInst turnOnAllFlags];
        
        cell.instrumentName = tempInst.instrumentName;
        cell.instrumentIcon = [UIImage imageNamed:tempInst.iconName];
        cell.instrument = tempInst;
        
        if ( !isPlaying )
        {
            [cell update];
        }
        
        return cell;
    }
    else 
    {
        NSLog(@"Add measure cell");
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AddInstrument"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        double iconWidth = 200;
        double iconHeight = 25;
    
        for ( UIView * view in cell.contentView.subviews )
            [view removeFromSuperview];
        
        UIImageView * addInstIcon;
        
        // This conditional makes the add inst cell take up the whole tableview if there are no instruments being displayed
        if ( [instruments count] == 0 )
        {
            CGRect bigFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, instrumentTable.frame.size.height);
            cell.frame = bigFrame;
            
            CGPoint inset = CGPointMake(( cell.frame.size.width - iconWidth ) / 2, (cell.frame.size.height - iconHeight) / 2 + 2);
            
            addInstIcon = [[UIImageView alloc] initWithFrame:CGRectMake(inset.x, inset.y, iconWidth, iconHeight)];
        }
        else
        {
            CGRect normalFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 85);
            cell.frame = normalFrame;
            
            CGPoint inset = CGPointMake(( cell.frame.size.width - iconWidth ) / 2, (cell.frame.size.height - iconHeight) / 2);
            
            addInstIcon = [[UIImageView alloc] initWithFrame:CGRectMake(inset.x, inset.y, iconWidth, iconHeight)];
        }
    
        addInstIcon.image = [UIImage imageNamed:@"Add_Instrument"];
        
        [cell.contentView addSubview:addInstIcon];
        
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self removeSequencerWithIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}*/

- (void)deleteCell:(id)sender
{
    NSIndexPath * pathToDelete = [instrumentTable indexPathForCell:sender];
    
    // Remove from data structure:
    [self removeSequencerWithIndex:pathToDelete.row];
    
    
    // If the remaining options was previously empty (aka current count == 1),
    //      then reload the table to get the +inst cell back.
    if ([remainingInstrumentOptions count] == 1 )
    {
        [instrumentTable reloadData];
    }
    else {
        // Else, delete the cell that the user requested:
        [instrumentTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:pathToDelete] withRowAnimation:UITableViewRowAnimationFade];   
    }

    if ( [instruments count] == 0 )
    {
        [instrumentTable reloadData];
    }
        
    // Update cells:
    if ( [instruments count] > 0 )
    {
        if ( !isPlaying )
        {
            [self updateAllVisibleCells];
        }
    }
    else {
        [self stopAll];
    }

    [self save];
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
    if ( selectedInstrumentIndex == indexToRemove )
    {
        // If there are no more instruments:
        if ( [instruments count] == 0 )
        {
            // Clear guitarView and playspot
            selectedInstrumentIndex = -1;
            guitarView.measure = nil;
            [guitarView update];
            [self resetPlaySpot];
        }
        else 
        {
            // If there are instruments before this one...
            if ( indexToRemove > 0 )
            {   
                // Then select an instrument before.
                [self selectInstrument:indexToRemove - 1];
            }
            else {
                // Else, select one after (at the same index because everything shifts)
                [self selectInstrument:indexToRemove];
            }
        }
    }
    else if ( selectedInstrumentIndex > indexToRemove )
    {
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
    for (NSDictionary * instDict in masterInstrumentOptions)
    {
        if ( [[instDict objectForKey:@"Name"] isEqualToString:inst.instrumentName] )
        {
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
    if ( index == 0 )
    {
        return;
    }
    
    if ( [self does:[remainingInstrumentOptions objectAtIndex:index]
         comeBefore:[remainingInstrumentOptions objectAtIndex:index-1]
            inArray:masterInstrumentOptions] )
    {
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
    if ( [array indexOfObject:first] < [array indexOfObject:second] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.row == [instruments count] )
    {
        [self loadInstrumentSelector:self];
    }
}

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{  
    if ( !isConnected || fr == 0 )
    {
        return;
    }
    
    if ( selectedInstrumentIndex < 0 || [instruments count] == 0 )
    {
        NSLog(@"No instruments opened, or selected instrument index < 0");
        return;
    }
    NSLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];
}

- (void)notePlayed:(SEQNote *)note
{
    NSLog(@"gTarSeq received note played message");
    
    // Pass note-played message onto the selected instrument
    Instrument * selectedInst = [instruments objectAtIndex:selectedInstrumentIndex];
    [selectedInst notePlayedAtString:note.string andFret:note.fret];
    
    [self updateAllVisibleCells];
    
    [guitarView update];
    
    [self save];
}

- (void)guitarConnected
{
    NSLog(@"Guitar connected");
    
    isConnected = YES;
    
    [self updateConnectedImages];
}

- (void)guitarDisconnected
{
    NSLog(@"Guitar disconnected");
    
    isConnected = NO;
    
    [self updateConnectedImages];
}

- (void)updateConnectedImages
{
    if ( isConnected )
    {
        gTarLogoImageView.image = [UIImage imageNamed:@"gTarConnectedLogo"];
        
        CGRect connectedTextFrame = CGRectMake(gTarConnectedText.frame.origin.x, 
                                                 gTarConnectedText.frame.origin.y, 
                                                 54, 
                                                 gTarConnectedText.frame.size.height);
        
        gTarConnectedText.frame = connectedTextFrame;
        
        gTarConnectedText.image = [UIImage imageNamed:@"Text_Connected"];
        
    }
    else {
        gTarLogoImageView.image = [UIImage imageNamed:@"gTarNotConnectedLogo"];
        
        
        CGRect notConnectedTextFrame = CGRectMake(gTarConnectedText.frame.origin.x,
                                                  gTarConnectedText.frame.origin.y,
                                                  70, 
                                                  gTarConnectedText.frame.size.height);
        
        gTarConnectedText.frame = notConnectedTextFrame;
        
        gTarConnectedText.image = [UIImage imageNamed:@"Text_NotConnected"];
    }
}

@end
