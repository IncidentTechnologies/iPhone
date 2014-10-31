//
//  InstrumentView.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SeqSetViewController.h"
#import "SoundMaster_.mm"

#define MAX_TRACKS 5

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"
#define DEFAULT_STATE_NAME @"sequenceCurrentState"

@implementation SeqSetViewController

@synthesize tutorialViewController;
@synthesize isFirstLaunch;
@synthesize instrumentTable;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        DLog(@"enter table view controller");
        
        soundMaster = [[SoundMaster alloc] init];
        
        // get instruments
/*        [self retrieveInstrumentOptions];
        
        // load instrument selector
        [self initInstrumentSelector];
        
        // load custom instrument selector
        [self initCustomInstrumentSelector];
        */
        
        self.tableView.bounces = NO;
        [self turnContentDrawingOn];
        
    }
    return self;
}


// Load state from disk
- (void)initTempTutorialSequence
{
    /*sequence = [[NSSequence alloc] initWithXMPFilename:DEFAULT_SET_PATH fromBundle:YES];
    [self setInstrumentsFromData];
    [delegate setTempo:sequence.m_tempo];
    [delegate setVolume:sequence.m_volume];
     */
}

- (void)initSequenceWithFilename:(NSString *)filename
{
    if(filename != nil){
        sequence = [[NSSequence alloc] initWithXMPFilename:filename fromBundle:NO];
        [self refreshSequenceName:filename];
        [self setInstrumentsFromData];
        [delegate setTempo:sequence.m_tempo];
        [delegate setVolume:sequence.m_volume];
    }
}

- (void)initSequenceWithSequence:(NSSequence *)newsequence
{
    sequence = newsequence;
    
    // Compare to list to get xmpName
    NSDictionary * sequenceList = [g_ophoMaster getSequenceList];
    NSArray * sequenceIds = [sequenceList objectForKey:OPHO_LIST_IDS];
    NSArray * sequenceNames = [sequenceList objectForKey:OPHO_LIST_NAMES];
    
    NSString * xmpName = sequence.m_xmpName;
    
    for(int i = 0; i < [sequenceIds count]; i++){
        if([[sequenceIds objectAtIndex:i] intValue] == sequence.m_id){
            xmpName = [sequenceNames objectAtIndex:i];
            break;
        }
    }
    
    [self refreshSequenceName:xmpName];
    
    [self setInstrumentsFromData];
    
    if([sequence.m_xmpName isEqualToString:DEFAULT_SET_NAME]){
        
        [delegate setTempo:DEFAULT_TEMPO];
        [delegate setVolume:DEFAULT_VOLUME];
        
    }else{
        
        [delegate setTempo:sequence.m_tempo];
        [delegate setVolume:sequence.m_volume];
    }
}

- (void)initFirstSequence
{
    sequence = [[NSSequence alloc] initWithName:BLANK_SET_NAME tempo:DEFAULT_TEMPO volume:DEFAULT_VOLUME];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    BOOL isScreenLarge = [frameGenerator isScreenLarge];
    
    // Check screen size for nib
    NSString * nibname = @"SeqSetViewCell";
    if(isScreenLarge){
        nibname = @"SeqSetViewCell_4";
    }
    
    UINib *nib = [UINib nibWithNibName:nibname bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"TrackCell"];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self turnEditingOn];
    
    [self checkIsFirstLaunch];
    if(isFirstLaunch){
        [self launchFTUTutorial];
    }else{
        [self endTutorialIfOpen];
    }
}

- (void)refreshSequenceName:(NSString *)filename
{
    if(![filename isEqualToString:DEFAULT_STATE_NAME]){
        
        // Refresh the name in case it's been updated
        //sequence.m_name = filename;
        
        [sequence renameToName:filename];
        
        [self saveChangesToActiveSequence:filename withId:sequence.m_id];
        [self saveStateToDiskWithForce:YES];
    }
}

#pragma mark - Load Context
- (BOOL)loadStateFromDisk
{
    DLog(@"Load state from disk");
    
    // sequenceCurrentState
    NSString * filepath = DEFAULT_STATE_NAME;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * sequenceFilepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"Sequences/" stringByAppendingString:[filepath stringByAppendingString:@".xml"]]];
    
    NSString * stateMetaDataPath = [[paths objectAtIndex:0]
                                    stringByAppendingPathComponent:@"metadataCurrentState"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:sequenceFilepath]) {
        DLog(@"The state XML exists");
    } else {
        DLog(@"The state XML does not exist");
        return FALSE;
    }
    
    // Other state data
    currentState = [[NSDictionary dictionaryWithContentsOfFile:stateMetaDataPath] mutableCopy];
    
    if (currentState == nil ){
        currentState = [[NSMutableDictionary alloc] init];
    }
    
    BOOL loadSequence = true;
        
    if ( [[currentState allKeys] count] > 0 )
    {
        // Decode selectedInstrumentIndex
        [self setSelectedInstrumentIndex:[[currentState objectForKey:@"Selected Instrument Index"] intValue]];
        
        NSInteger activeSong = [[currentState objectForKey:@"Active Song"] intValue];
        
        if(activeSong){
            // Sequence will automatically load
            loadSequence = false;
            [delegate loadFromXmpId:activeSong andType:TYPE_SONG];
        }
    }
    
    if(loadSequence){
        // Load as edited from disk
        [self initSequenceWithFilename:filepath];
    }
    
    return TRUE;

}

#pragma mark - Save Context
- (void)saveChangesToActiveSequence:(NSString *)newName withId:(NSInteger)xmpId
{
    DLog(@"Save changes to active sequence");
    
    if(![newName isEqualToString:DEFAULT_SET_NAME]){
        
        // If ID is 0, save as new set (empty one will be loaded in after)
        if(xmpId == 0){
            sequence.m_id = 0;
        }
        
        if(xmpId > 0 && xmpId != sequence.m_id){
            DLog(@"ERROR SAVING: XMP ID mismatch");
            return;
        }
        
        // Save the sequence
        [sequence renameToName:newName];
        [g_ophoMaster saveSequence:sequence];
    }
    
}

- (void)saveStateToDiskWithForce:(BOOL)forceSave
{
    if(saveContextTimer == nil || forceSave){
        
        // Prevent from saving many times in a row, but never block a manual save
        [self clearSaveContextTimer];
        saveContextTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(clearSaveContextTimer) userInfo:nil repeats:NO];
        
        NSString * filepath = DEFAULT_STATE_NAME;
        
        // Any additional metadata to save for this state?
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString * stateMetaDataPath = [[paths objectAtIndex:0]
                                        stringByAppendingPathComponent:@"metadataCurrentState"];
        
        [currentState setObject:[NSNumber numberWithInteger:[self getSelectedInstrumentIndex]] forKey:@"Selected Instrument Index"];
        
        NSInteger activeSong = [delegate getActiveSongId];
        if(activeSong){
            [currentState setObject:[NSNumber numberWithInteger:activeSong] forKey:@"Active Song"];
        }
        
        BOOL success = [currentState writeToFile:stateMetaDataPath atomically:YES];
        
        DLog(@"Save metadata success: %i", success);
        
        // Save to file on disk
        [sequence saveToFile:filepath];
        
    }
}

- (void)requestSaveXmpCallback
{
    DLog(@"Request Save Sequence XMP Callback");
    
    // TODO: fetch the ID (and other stuff)
    activeSequenceXmpId = 1;
}

- (void)clearSaveContextTimer
{
    [saveContextTimer invalidate];
    saveContextTimer = nil;
}

#pragma mark Instruments Data

- (void)initInstrumentOptions
{
    
    // get instruments
    [self retrieveInstrumentOptions];
    
    // load instrument selector
    [self initInstrumentSelector];
    
    // load custom instrument selector
    [self initCustomInstrumentSelector];
    
    //[instrumentTable reloadData];
    
}


- (void)retrieveInstrumentOptions
{
    // Init
    customInstrumentOptions = [[NSMutableArray alloc] init];
    masterInstrumentOptions = [[NSMutableArray alloc] init];
    sequencerInstrumentsPath = [[NSBundle mainBundle] pathForResource:@"sequencerInstruments" ofType:@"plist"];
    
    NSMutableDictionary * plistDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:sequencerInstrumentsPath];
    
    
    // Get instrument list from the server
    NSDictionary * customInstDictionary = [g_ophoMaster getInstrumentList];
    NSArray * customInstIds = [customInstDictionary objectForKey:OPHO_LIST_IDS];
    NSArray * customInstNames = [customInstDictionary objectForKey:OPHO_LIST_NAMES];
    
    [masterInstrumentOptions addObjectsFromArray:[plistDictionary objectForKey:@"Instruments"]];
    
    if([customInstIds count] > 0){
        DLog(@"The custom instruments plist exists");
        
        for(int i = 0; i < [customInstIds count]; i++){
            
            NSMutableDictionary * instDict = [[NSMutableDictionary alloc] init];
            [instDict setObject:customInstIds[i] forKey:@"Index"];
            [instDict setObject:customInstNames[i] forKey:@"Name"];
            [instDict setObject:[NSNumber numberWithBool:true] forKey:@"Custom"];
            
            [customInstrumentOptions addObject:instDict];
            [masterInstrumentOptions addObject:instDict];
            
        }
        
        DLog(@"Custom Inst Dictionary is %@",customInstDictionary);
        
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

- (void)setInstrumentsFromData
{
    
    [self setRemainingInstrumentOptionsFromMasterOptions];
    
    NSMutableArray * dictionariesToRemove = [[NSMutableArray alloc] init];
    for(NSTrack * track in sequence.m_tracks){
        NSInstrument * inst = track.m_instrument;
        
        for(NSDictionary * dict in remainingInstrumentOptions){
            if([[dict objectForKey:@"Name"] isEqualToString:inst.m_name]){
                
                NSMutableArray * stringPaths = [[NSMutableArray alloc] init];
                NSMutableArray * stringSet = [[NSMutableArray alloc] init];
                NSMutableArray * stringIdSet = [[NSMutableArray alloc] init];
                
                for(NSSample * sample in inst.m_sampler.m_samples){
                    NSString * isCustom = (sample.m_custom) ? @"Custom" : @"Default";
                    [stringSet addObject:sample.m_name];
                    [stringPaths addObject:isCustom];
                    [stringIdSet addObject:[NSNumber numberWithInt:sample.m_xmpFileId]];
                }
                
                [inst.m_sampler initAudioWithInstrument:inst.m_id andName:inst.m_name andSoundMaster:soundMaster stringSet:stringSet stringPaths:stringPaths stringIds:stringIdSet];
                [dictionariesToRemove addObject:dict];
            }
        }
        
    }
    
    [remainingInstrumentOptions removeObjectsInArray:dictionariesToRemove];
    
    [instrumentTable reloadData];
    
    [delegate numInstrumentsDidChange:[sequence trackCount]];
    
}

- (long)countTracks
{
    return [sequence trackCount];
}

- (int)countMasterInstrumentOptions
{
    return [masterInstrumentOptions count];
}

- (int)countSamples
{
    return [customSelector countSamples];
}

- (NSSequence *)getSequence
{
    return sequence;
}

- (NSMutableArray *)getTracks
{
    return sequence.m_tracks;
}

- (NSTrack *)getTrackAtIndex:(int)index
{
    if(index < [sequence trackCount] && index >= 0){
        return [sequence.m_tracks objectAtIndex:index];
    }else{
        return nil;
    }
}

- (void)updateTrackTempo:(int)tempo
{
    sequence.m_tempo = tempo;
}

- (void)updateMasterVolume:(double)volume
{
    sequence.m_volume = volume;
}

- (BOOL)isValidInstrumentIndex:(int)inst
{
    for(NSTrack * t in sequence.m_tracks){
        if(t.m_instrument.m_id == inst){
            return YES;
        }
    }
    
    return NO;
}

- (NSMutableArray *)getCustomInstrumentOptions
{
    return customInstrumentOptions;
}

#pragma mark - Instrument View Delegate
- (void)reloadTableData
{
    [instrumentTable reloadData];
    
    [self checkIsFirstLaunch];
    if(isFirstLaunch){
        [self launchFTUTutorial];
    }else{
        [self endTutorialIfOpen];
    }
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
    
    DLog(@"Selecting instrument at index %li",senderIndex);
    
    [self selectInstrument:senderIndex];
    
    [delegate openInstrument:senderIndex];
    
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

- (void)addNewInstrumentWithXmpId:(NSInteger)xmpId
{
    [g_ophoMaster loadFromId:xmpId callbackObj:self selector:@selector(addNewInstrumentFromServer:)];
    
}

- (void)addNewInstrumentFromServer:(CloudResponse *)cloudResponse
{
    DLog(@"Request Load Instrument XMP Callback");
    
    XmlDom * instrumentXmp = [cloudResponse.m_xmpDom getChildWithName:@"instrument"];
    
    NSInstrument * instrument = [[NSInstrument alloc] initWithXmlDom:instrumentXmp];
    
    NSMutableArray * stringPaths = [[NSMutableArray alloc] init];
    NSMutableArray * stringSet = [[NSMutableArray alloc] init];
    NSMutableArray * stringIdSet = [[NSMutableArray alloc] init];
    
    for(NSSample * sample in instrument.m_sampler.m_samples){
        NSString * isCustom = (sample.m_custom) ? @"Custom" : @"Default";
        [stringSet addObject:sample.m_name];
        [stringPaths addObject:isCustom];
        [stringIdSet addObject:[NSNumber numberWithInt:sample.m_xmpFileId]];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [instrument.m_sampler initAudioWithInstrument:instrument.m_xmpid andName:instrument.m_name andSoundMaster:soundMaster stringSet:stringSet stringPaths:stringPaths stringIds:stringIdSet];
    });
    
    
    NSTrack * newTrack = [[NSTrack alloc] initWithName:instrument.m_name level:1.0 muted:NO];
    
    newTrack.m_instrument = instrument;
    
    // Add Track
    [sequence addTrack:newTrack];
    
    [self selectInstrument:[sequence trackCount] - 1];
    
    // insert cell:
    if ([sequence trackCount] == 1){
        
        [delegate turnOffGuitarEffects];
        
        // Reloading data forcibly resizes the add inst button
        [instrumentTable reloadData];
        
    }else{
        
        // If there are no more options in the options array, then reload the table to get rid of the +inst cell.
        if ([remainingInstrumentOptions count] == 0){
            [instrumentTable reloadData];
        }else{
            [instrumentTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sequence trackCount] -1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            
            if(![delegate checkIsPlaying]){
                [self updateAllVisibleCells];
            }
        }
    }
    
    [delegate numInstrumentsDidChange:[sequence trackCount]];
    [self saveStateToDiskWithForce:YES];
}

/*
- (void)addNewInstrumentWithIndex:(int)index andName:(NSString *)instName andIconName:(NSString *)iconName andStringSet:(NSArray *)stringSet andStringPaths:(NSArray *)stringPaths andStringIds:(NSArray *)stringIds andIsCustom:(BOOL)isCustom
{
    NSTrack * newTrack = [[NSTrack alloc] initWithName:instName level:1.0 muted:NO];
    
    
    // Add Track
    [sequence addTrack:newTrack];

    NSInstrument * newInstrument = newTrack.m_instrument;
    newInstrument.m_id = index;
    newInstrument.m_name= instName;
    newInstrument.m_iconName = iconName;
    newInstrument.m_custom = isCustom;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [newInstrument.m_sampler initAudioWithInstrument:index andName:newInstrument.m_name andSoundMaster:soundMaster stringSet:stringSet stringPaths:stringPaths stringIds:stringIds];
    });
    
    [self selectInstrument:[sequence trackCount] - 1];
    
    // insert cell:
    if ([sequence trackCount] == 1){
        
        [delegate turnOffGuitarEffects];
        
        // Reloading data forcibly resizes the add inst button
        [instrumentTable reloadData];
        
    }else{
        
        // If there are no more options in the options array, then reload the table to get rid of the +inst cell.
        if ([remainingInstrumentOptions count] == 0){
            [instrumentTable reloadData];
        }else{
            [instrumentTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sequence trackCount] -1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            
            if(![delegate checkIsPlaying]){
                [self updateAllVisibleCells];
            }
        }
    }
    
    [delegate numInstrumentsDidChange:[sequence trackCount]];
    [self saveStateToDiskWithForce:YES];
}
*/
 
 
#pragma mark Table View Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //if ([remainingInstrumentOptions count] == 0){
    //    return [sequence trackCount];
    //}else{
        return [sequence trackCount] + 1;
    //}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tableHeight = instrumentTable.frame.size.height;
    
    if([sequence trackCount] >= MAX_TRACKS && indexPath.row == [sequence trackCount]){
        return 0;
    }else if([sequence trackCount] == 0)
        return tableHeight;
    else if(indexPath.row < [sequence trackCount])
        return tableHeight/3+1;
    else if([sequence trackCount] == 1)
        return 2*tableHeight/3-1;
    else if([sequence trackCount] == 2)
        return tableHeight/3-2;
    
    // else
    return tableHeight/3;
}

- (void)enforceTableWidth
{
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    float x = [frameGenerator getFullscreenWidth];
    
    [self.view setFrame:CGRectMake(0, 0, x, self.view.frame.size.height)];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self enforceTableWidth];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (indexPath.row < [sequence trackCount]){
        
        static NSString *CellIdentifier = @"TrackCell";
        
        SeqSetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[SeqSetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.parent = self;
        
        NSTrack * tempTrack = [sequence.m_tracks objectAtIndex:indexPath.row];
        [tempTrack turnOnAllFlags];
        
        cell.instrumentName = tempTrack.m_instrument.m_name;
        cell.instrumentIcon = [UIImage imageNamed:tempTrack.m_instrument.m_iconName];
        cell.track = tempTrack;
        cell.isMute = tempTrack.m_muted;
        
        [cell resetVolume];
        
        if(tempTrack.m_instrument.m_custom){
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
    //if(indexPath.row == [sequence trackCount]){
        return NO;
    //}else{
    //    return canEdit;
    //}
}

- (BOOL)isLeftNavOpen
{
    return [delegate isLeftNavOpen];
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

- (void)deleteSeqSetViewCell:(UITableViewCell *)cell
{
    SeqSetViewCell * seqCell = (SeqSetViewCell *)cell;
    
    [self endTutorialIfOpen];
    [self deleteCell:seqCell withAnimation:YES];
}
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // make sure the cell is open
    SeqSetViewCell * cell = (SeqSetViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(editingStyle == UITableViewCellEditingStyleDelete && cell.editingScrollView.contentOffset.x > 0){
        [self endTutorialIfOpen];
        [self deleteCell:[tableView cellForRowAtIndexPath:indexPath] withAnimation:YES];
    }
}
*/
- (void)notifyQueuedPatternsAtIndex:(int)index andResetCount:(BOOL)reset
{
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:indexPath];
    
    // Double check the cell knows it has a queued pattern
    if(![cell hasQueuedPatternButton]){
        int queuedIndex = [delegate getQueuedPatternIndexForTrack:cell.track];
        if(queuedIndex >= 0){
            DLog(@"Auto enqueuing a pattern button");
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
        
        if(cell.track.m_instrument.m_id == index){
            [cell resetQueuedPatternButton];
        }
    }
}

// Bottom to top
- (void)dequeueAllPatternsForTrack:(id)sender
{
    SeqSetViewCell * cell = (SeqSetViewCell *)sender;
    NSTrack * track = cell.track;
    int instIndex = track.m_instrument.m_id;
    
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
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    // Get dimensions
    float y = [frameGenerator getFullscreenHeight];
    float x = [frameGenerator getFullscreenWidth];
    
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
    if(indexPath.row == [sequence trackCount]){
        [self loadInstrumentSelector:self andScroll:NO];
    }
}

- (IBAction)loadInstrumentSelector:(id)sender andScroll:(BOOL)scroll
{
    // Clear all sounds
    [soundMaster reset];
    
    // Turn off selected status of the add instrument button (which was just clicked):
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:[sequence trackCount] inSection:0];
    UITableViewCell * addInstCell = [instrumentTable cellForRowAtIndexPath:indexPath];
    addInstCell.selected = NO;
    
    // Set instrumentSelectors options and move off screen:
    [instrumentSelector setOptions:remainingInstrumentOptions];
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
        
        [self addNewInstrumentWithXmpId:[instIndex intValue]];
        
        /*
        NSString * instName = [dict objectForKey:@"Name"];
        NSArray * stringSet = [dict objectForKey:@"Strings"];
        NSArray * stringPaths = [dict objectForKey:@"StringPaths"];
        NSArray * stringIds = [dict objectForKey:@"StringXmpIds"];
        NSNumber * isCustom = [dict objectForKey:@"Custom"];
        
        [self addNewInstrumentWithIndex:[instIndex intValue] andName:instName andIconName:iconName andStringSet:stringSet andStringPaths:stringPaths andStringIds:stringIds andIsCustom:[isCustom boolValue]];
         */
    }
}

- (void)scrollingSelectorDidRemoveIndex:(int)indexSelected
{
    if(indexSelected >= 0){
        
        // Remove that instrument from the array:
        NSDictionary * instOption = [remainingInstrumentOptions objectAtIndex:indexSelected];
        NSNumber * instIndex = [instOption objectForKey:@"Index"];
        
        [g_ophoMaster deleteWithId:[instIndex intValue]];
        
        DLog(@"Remove instrument at selected index %i",indexSelected);
        
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
        //[self saveCustomInstrumentToPlist:customInstrumentOptions];
        
    }
}

- (void)initCustomInstrumentSelector
{
    
    DLog(@"Init custom instrument selector");
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    // Get dimensions
    float y = [frameGenerator getFullscreenHeight];
    float x = [frameGenerator getFullscreenWidth];
    
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
- (void)saveCustomInstrumentWithStrings:(NSArray *)stringSet stringIds:(NSArray *)stringIdSet andName:(NSString *)instName andStringPaths:(NSArray *)stringPaths andIcon:(NSString *)iconName
{
    NSInstrument * instrument = [[NSInstrument alloc] initWithName:instName id:0 iconName:iconName isCustom:TRUE];
    
    for(int i = 0; i < [stringSet count]; i++){
        NSSample * sample = [[NSSample alloc] initWithName:stringSet[i] custom:[stringPaths[i] isEqualToString:@"Custom"] value:[NSString stringWithFormat:@"%i",i] xmpFileId:[stringIdSet[i] intValue]];
        
        [instrument.m_sampler addSample:sample];
    }
    
    [g_ophoMaster saveInstrument:instrument];
    
    /*
    
    NSNumber * newIndex = [NSNumber numberWithInt:[self getCustomInstrumentsNewIndex]];
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithBool:TRUE] forKey:@"Custom"];
    [dict setValue:newIndex forKey:@"Index"];
    [dict setValue:instName forKey:@"Name"];
    [dict setValue:stringSet forKey:@"Strings"];
    [dict setValue:stringPaths forKey:@"StringPaths"];
    [dict setValue:stringIdSet forKey:@"StringXmpIds"];
    
    [masterInstrumentOptions addObject:dict];
    [remainingInstrumentOptions addObject:dict];
    [customInstrumentOptions addObject:dict];
    
    [self saveCustomInstrumentToPlist:customInstrumentOptions];
    
    */
    
    [self closeCustomInstrumentSelectorAndScroll:NO];
}


#pragma mark Selecting Instrument

- (void)selectInstrument:(long)index
{
    // Deselect old:
    for (NSTrack * t in sequence.m_tracks)
    {
        [t setSelected:NO];
    }
    
    selectedInstrumentIndex = index;
    
    // Select new:
    if(selectedInstrumentIndex >= 0 && selectedInstrumentIndex < [sequence trackCount]){
        
        NSTrack * newSelection = [sequence.m_tracks objectAtIndex:selectedInstrumentIndex];
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

- (NSTrack *)getCurrentTrack
{
    if(selectedInstrumentIndex < [sequence.m_tracks count]){
        return [sequence.m_tracks objectAtIndex:selectedInstrumentIndex];
    }
    
    return nil;
}

- (void)deleteCell:(id)sender withAnimation:(BOOL)animate
{
    
    DLog(@"Delete cell");
    
    NSIndexPath * pathToDelete = [instrumentTable indexPathForCell:sender];
    int row = pathToDelete.row;
    int section = pathToDelete.section;
    
    // Beware race conditions deleting 5+ instruments at a time
    @synchronized(sequence.m_tracks){
        // Remove from data structure:
        [self removeSequencerWithIndex:pathToDelete.row];
        
        DLog(@"Removed from data structure");
        
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
        
        DLog(@"Deleted row");
    }
}

-(void)removeCellAtRow:(int)row andSection:(int)section
{
    
    [instrumentTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
    
    DLog(@"Reload data");
    
    if ([sequence trackCount] == 0){
        [instrumentTable reloadData];
    }
    
    // Remove any enqueued patterns
    [delegate removeQueuedPatternForInstrumentAtIndex:row];
    
    DLog(@"Enqueued patterns removed");
    
    // Update cells:
    if([sequence trackCount] > 0){
        if(![delegate checkIsPlaying]){
            [self updateAllVisibleCells];
        }
    }else{
        [self stopAllPlaying];
    }
    
    [delegate numInstrumentsDidChange:[sequence trackCount]];
    [self saveStateToDiskWithForce:YES];
}

- (void)deleteAllCells
{
    for(int i = [sequence trackCount] - 1; i >= 0; i--){
        SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [self deleteCell:cell withAnimation:NO];
    }
}

- (void)removeSequencerWithIndex:(long)indexToRemove
{
    DLog(@"Remove sequencer with index %li",indexToRemove);
    
    // Remove object from array:
    NSTrack * removedTrack = [sequence.m_tracks objectAtIndex:indexToRemove];
    
    [removedTrack releaseSounds];
    [sequence.m_tracks removeObjectAtIndex:indexToRemove];
    
    // Add instrument back into instrument options array:
    [self addInstrumentBackIntoOptions:removedTrack.m_instrument];
    
    /* If the selected instrument is about to be removed, then a new one must be selected.
     The selected index must also be updated if an instrument above the selected is deleted.
     If the instrument being deleted is the last instrument, then the guitarView must be cleared
     and the playband reset */
    if(selectedInstrumentIndex == indexToRemove){
        // If there are no more instruments:
        if ([sequence trackCount] == 0){
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

- (void)enableKnobIfDisabledForInstrument:(int)instIndex
{
    DLog(@"Enable knob if disabled for instrument");
    
    for(int i = 0; i < [sequence trackCount]; i++){
        NSTrack * track = [sequence.m_tracks objectAtIndex:i];
        if(track.m_instrument.m_id == instIndex){
            
            DLog(@"Sending to %i",instIndex);
            SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell enableKnobIfDisabled];
            
            track.m_muted = NO;
        }
    }
}

- (void)disableKnobIfEnabledForInstrument:(int)instIndex
{
    
    DLog(@"Disable knob if enabled for instrument");
    
    for(int i = 0; i < [sequence trackCount]; i++){
        NSTrack * track = [sequence.m_tracks objectAtIndex:i];
        if(track.m_instrument.m_id == instIndex){
            SeqSetViewCell * cell = (SeqSetViewCell *)[instrumentTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell disableKnobIfEnabled];
            
            track.m_muted = YES;
        }
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

- (BOOL)checkIsRecording
{
    return [delegate checkIsRecording];
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

- (void)resetSoundMaster
{
    [soundMaster reset];
}

- (SoundMaster *)getSoundMaster
{
    return soundMaster;
}

#pragma mark Re-adding Instruments

- (void)addInstrumentBackIntoOptions:(NSInstrument *)inst
{
    DLog(@"Add instrument back into options");
    
    // Get the dictionary associated with this inst:
    NSDictionary * instrumentDictionary;
    
    int i = 0;
    for(NSDictionary * instDict in masterInstrumentOptions){
        
        if([[instDict objectForKey:@"Name"] isEqualToString:inst.m_name]){
            instrumentDictionary = instDict;
        }
        
        i++;
    }
    
    // Add this dictionary to the end:
    DLog(@"Add dictionary to the end");
    if(instrumentDictionary != nil){
        [remainingInstrumentOptions addObject:instrumentDictionary];
    }
    
    // Bubble up:
    long lastIndex = [remainingInstrumentOptions count] - 1;
    
    [self bubbleUp:lastIndex];
    
    DLog(@"Bubbled up");
    
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

#pragma mark UI Input

- (BOOL)userDidSelectPattern:(SeqSetViewCell *)sender atIndex:(int)index
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    NSTrack * tempTrack = [sequence.m_tracks objectAtIndex:senderIndex];
    
    // double check this isn't the current pattern
    if ([delegate checkIsPlaying] && tempTrack.selectedPatternIndex != index){
        
        // Add it to the queue:
        NSMutableDictionary * pattern = [NSMutableDictionary dictionary];
        
        [pattern setObject:[NSNumber numberWithInt:index] forKey:@"Index"];
        [pattern setObject:tempTrack forKey:@"Instrument"];
        
        [delegate enqueuePattern:pattern];
        
        return YES;
        
    } else if (tempTrack.selectedPatternIndex == index){
        
        [self dequeueAllPatternsForTrack:sender];
        
    }
    
    [self commitSelectingPatternAtIndex:index forTrack:tempTrack];
    
    return NO;
}

- (void)commitSelectingPatternAtIndex:(int)indexToSelect forTrack:(NSTrack *)track
{
    if (track.selectedPatternIndex == indexToSelect){
        return;
    }
    
    NSPattern * newSelection = [track selectPattern:indexToSelect];
    
    [delegate updatePlaybandForTrack:track];
    
    [self selectInstrument:track.m_instrument.m_id];
    
    [delegate setMeasureAndUpdate:newSelection.selectedMeasure checkNotPlaying:TRUE];
    
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [self saveStateToDiskWithForce:NO];
}

- (void)userDidSelectMeasure:(SeqSetViewCell *)sender atIndex:(int)index
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    NSTrack * trackAtIndex = [sequence.m_tracks objectAtIndex:senderIndex];
    
    // -- update DS
    [trackAtIndex selectMeasure:index];
    
    // -- select the (potentially new) instrument
    [self selectInstrument:senderIndex];
    
    // -- update minimap
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [self saveStateToDiskWithForce:NO];
    
}

- (void)userDidAddMeasures:(SeqSetViewCell *)sender
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    NSTrack * trackAtIndex = [sequence.m_tracks objectAtIndex:senderIndex];
    [trackAtIndex addMeasure];
    
    [delegate updatePlaybandForTrack:trackAtIndex];
    
    [self selectInstrument:senderIndex];
    
    if (![delegate checkIsPlaying]){
        [self updateAllVisibleCells];
    }
    
    [self saveStateToDiskWithForce:YES];
    
}

- (void)userDidRemoveMeasures:(SeqSetViewCell *)sender
{
    long senderIndex = [instrumentTable indexPathForCell:sender].row;
    
    NSTrack * trackAtIndex = [sequence.m_tracks objectAtIndex:senderIndex];
    [trackAtIndex removeMeasure];
    
    [delegate updatePlaybandForTrack:trackAtIndex];
    
    [sender update];
    
    [delegate setMeasureAndUpdate:trackAtIndex.selectedPattern.selectedMeasure checkNotPlaying:FALSE];
    
    [self saveStateToDiskWithForce:YES];
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

#pragma mark - FTU Tutorial
-(void)checkIsFirstLaunch
{
    
    // Check for first launch
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedSeqSetView"]){
        isFirstLaunch = FALSE;
    }else{
        isFirstLaunch = TRUE;
    }
    
    // Double check for muted instrument
    if([sequence trackCount] > 3){
        
        NSTrack * mutedTrack = [sequence.m_tracks objectAtIndex:3];
        
        if(!mutedTrack.m_muted){
            isFirstLaunch = FALSE;
        }
        
    }else{
        isFirstLaunch = FALSE;
    }
    
}


- (void)launchFTUTutorial
{
    
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    // Get dimensions
    float y = [frameGenerator getFullscreenHeight];
    float x = [frameGenerator getFullscreenWidth];
    
    DLog(@" *** Launch FTU Tutorial *** %f %f",x,y);
    
    CGRect tutorialFrame = CGRectMake(0,0,x,y-BOTTOMBAR_HEIGHT-1);
    
    if(tutorialViewController){
        [tutorialViewController clear];
    }
    
    tutorialViewController = [[TutorialViewController alloc] initWithFrame:tutorialFrame andTutorial:@"SeqSet"];
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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedSeqSetView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
