//
//  SequencerViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SequencerViewController.h"

#define LAST_FRET 15
#define LAST_MEASURE 3

#define TABLEHEIGHT 264
#define NAVWIDTH 131
#define NAVTAB 0
#define SELECTORWIDTH 364
#define SELECTORHEIGHT 276

#define DEFAULT_SET_NAME @"Tutorial"

#define FONT_DEFAULT @"Avenir Next"
#define FONT_BOLD @"AvenirNext-Bold"

@implementation SequencerViewController

@synthesize isFirstLaunch;
@synthesize optionsViewController;
@synthesize seqSetViewController;
@synthesize instrumentViewController;
@synthesize playControlViewController;
@synthesize infoViewController;
@synthesize tutorialViewController;
@synthesize recordShareController;
@synthesize leftNavigator;
@synthesize setName;

//@synthesize yesButton;
//@synthesize noButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initGlobalData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    
    // Load default set for FTU
    NSString * filePath = (isFirstLaunch) ? [self getDefaultSetFilepath] : nil;
    [self loadStateFromDisk:filePath];
    [self selectNavChoice:@"Set" withShift:NO];
    [self saveContext:nil force:NO];
    
    if(isFirstLaunch){
        [self launchFTUTutorial];
    }
    
    // Check for gTar Connection
    [self checkGtarConnected];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view
    self.seqSetViewController = nil;
    self.playControlViewController = nil;
    
}

- (void)initGlobalData
{
    
    // Paths to load/save on disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    instrumentDataFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"sequencerCurrentState"];
    
    // Gtar delegate and connection spoof
    if(TESTMODE) NSLog(@"Setup and connect gTar");
    //isConnected = NO;
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
    
    if(TESTMODE){
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:guitarView selector:@selector(observeGtar) userInfo:nil repeats:NO];
    }
    
    string = 0;
    fret = 0;
    
    patternQueue = [NSMutableArray array];
}

- (void)initSubviews
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    isScreenLarge = (screenBounds.size.height == XBASE_LG) ? YES : NO;
    int screensize = (isScreenLarge) ? XBASE_LG : XBASE_SM;
    
    onScreenMainFrame = CGRectMake(0,0,screensize,TABLEHEIGHT);
    overScreenMainFrame = CGRectMake(NAVWIDTH-NAVTAB,0,screensize,TABLEHEIGHT);
    
    //
    // SUBVIEW: OPTIONS
    //
    
    optionsViewController = [[OptionsViewController alloc] initWithNibName:@"OptionsView" bundle:nil];
    [optionsViewController.view setFrame:onScreenMainFrame];
    [optionsViewController setDelegate:self];
    
    [optionsViewController.view setHidden:YES];
    [self.view addSubview:optionsViewController.view];
    
    //
    // SUBVIEW: SET
    //
    
    seqSetViewController = [[SeqSetViewController alloc] initWithNibName:@"SeqSetView" bundle:nil];
    [seqSetViewController.view setFrame:onScreenMainFrame];
    [seqSetViewController setDelegate:self];
    
    NSLog(@"Get current instrument: Sequencer View Controller");
    Instrument * currentInstrument = [seqSetViewController getCurrentInstrument];
    
    if (currentInstrument){
        guitarView.measure = currentInstrument.selectedPattern.selectedMeasure;
    }
    
    [seqSetViewController.view setHidden:NO];
    [self.view addSubview:seqSetViewController.view];
    
    //
    // SUBVIEW: INSTRUMENT
    //
    
    NSString * instrumentNibName = (isScreenLarge) ? @"InstrumentViewController_4" : @"InstrumentViewController";
    instrumentViewController = [[InstrumentViewController alloc] initWithNibName:instrumentNibName bundle:nil];
    [instrumentViewController.view setFrame:onScreenMainFrame];
    [instrumentViewController setDelegate:self];
    
    [instrumentViewController.view setHidden:YES];
    [self.view addSubview:instrumentViewController.view];
    
    //
    // SUBVIEW: RECORD SHARE
    //
    
    NSString * recordShareNibName = (isScreenLarge) ? @"RecordShareView_4" : @"RecordShareView";
    recordShareController = [[RecordShareViewController alloc] initWithNibName:recordShareNibName bundle:nil];
    [recordShareController.view setFrame:onScreenMainFrame];
    [recordShareController setDelegate:self];
    
    [recordShareController.view setHidden:YES];
    [self.view addSubview:recordShareController.view];
    
    //
    // SUBVIEW: INFO
    //
    
    infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    [infoViewController.view setFrame:onScreenMainFrame];
    [infoViewController setDelegate:self];
    
    [infoViewController.view setHidden:YES];
    [self.view addSubview:infoViewController.view];
    
    //
    //  BOTTOM BAR
    //
    
    NSString * playControlNibName = (isScreenLarge) ? @"BottomBar_4" : @"BottomBar";
    playControlViewController = [[PlayControlViewController alloc] initWithNibName:playControlNibName bundle:nil];
    [playControlViewController.view setFrame:CGRectMake(0,TABLEHEIGHT-4,screenBounds.size.height,YBASE-TABLEHEIGHT+3)];
    [playControlViewController setDelegate:self];
    
    isPlaying = NO;
    
    [self.view addSubview:playControlViewController.view];
    
    //
    // LEFT NAVIGATOR
    //
    
    onScreenNavigatorFrame = CGRectMake(0,0,NAVWIDTH,TABLEHEIGHT);
    offLeftNavigatorFrame = CGRectMake(-2*(NAVWIDTH+NAVTAB),0,0,TABLEHEIGHT);
    
    leftNavigator = [[LeftNavigatorViewController alloc] initWithNibName:@"LeftNavigatorViewController" bundle:nil];
    [leftNavigator.view setFrame:offLeftNavigatorFrame];
    [leftNavigator setDelegate:self];
    leftNavOpen = false;
    
    [self.view addSubview:leftNavigator.view];
    
    //
    // GTAR CONNECTED
    //
    
    [leftNavigator changeConnectedButton:false];
    
    //
    // GESTURES
    //
    
    [self startGestures];
    
}

#pragma mark - Left Navigator Delegate

- (BOOL)isLeftNavOpen
{
    return leftNavOpen;
}

- (void)closeLeftNavigator
{
    if(TESTMODE) NSLog(@"Close left nav");
    
    [seqSetViewController turnEditingOn];
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.1 animations:^(){
        [leftNavigator.view setFrame:offLeftNavigatorFrame];
        [activeMainView setFrame:onScreenMainFrame];
    } completion:^(BOOL finished){
        [instrumentViewController leftNavDidClose];
        leftNavOpen = false;
    }];
}

- (void)openLeftNavigator
{
    if(TESTMODE) NSLog(@"Open left nav");
    
    [instrumentViewController leftNavWillOpen];
    [seqSetViewController turnEditingOff];
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.1 animations:^(){
        [leftNavigator.view setFrame:onScreenNavigatorFrame];
        [activeMainView setFrame:overScreenMainFrame];
    } completion:^(BOOL finished){
        leftNavOpen = true;
    }];
}

- (void)toggleLeftNavigator
{
    if(leftNavOpen){
        [self closeLeftNavigator];
    }else{
        [self openLeftNavigator];
    }
}

- (void)selectNavChoice:(NSString *)nav withShift:(BOOL)shift
{
    
    NSLog(@"Switch to %@ view",nav);
    
    [optionsViewController.view setHidden:YES];
    [seqSetViewController.view setHidden:YES];
    [instrumentViewController.view setHidden:YES];
    [recordShareController.view setHidden:YES];
    [infoViewController.view setHidden:YES];
    
    // Do any view unloading
    [optionsViewController unloadView];
    [playControlViewController hideSessionOverlay];
    
    // Switch to new main subview
    if([nav isEqualToString:@"Options"]){
        
        [optionsViewController reloadFileTable];
        activeMainView = optionsViewController.view;
        
    }else if([nav isEqualToString:@"Set"]){
    
        [seqSetViewController reloadTableData];
        activeMainView = seqSetViewController.view;
        
    }else if([nav isEqualToString:@"Instrument"]){
        
        [instrumentViewController reopenView];
        activeMainView = instrumentViewController.view;
        
        Instrument * newInstrument = [seqSetViewController getCurrentInstrument];
        
        [instrumentViewController setActiveInstrument:newInstrument];
        
    }else if([nav isEqualToString:@"Share"]){
        
        activeMainView = recordShareController.view;
        [recordShareController reloadInstruments];
        [self stopAll];
        
        if(patternData != nil){
            SoundMaster * soundMaster = [seqSetViewController getSoundMaster];
            [recordShareController loadPattern:patternData withTempo:[playControlViewController getTempo] andSoundMaster:soundMaster];
        }
        
        if([recordShareController showHideSessionOverlay]){
            [playControlViewController hideSessionOverlay];
        }else{
            [playControlViewController showSessionOverlay];
        }
        
    }else if([nav isEqualToString:@"Info"]){
        
        activeMainView = infoViewController.view;
    }
    
    // Hover set name?
    if([nav isEqualToString:@"Set"] && !isTutorialOpen){
        [self hoverSetName];
    }else{
        [self hideSetName];
    }
    
    // Share mode?
    if([nav isEqualToString:@"Share"]){
        [playControlViewController setShareMode:YES];
    }else{
        [playControlViewController setShareMode:NO];
        [recordShareController stopRecordPlayback];
    }
    
    [activeMainView setAlpha:1.0];
    
    // set nav button
    [leftNavigator setNavButtonOn:nav];
    
    // handle positioning
    if(leftNavOpen){
        [self closeLeftNavigator];
        [activeMainView setFrame:onScreenMainFrame];
    }else{
        if(shift){
            [activeMainView setFrame:overScreenMainFrame];
        }else{
            [activeMainView setFrame:onScreenMainFrame];
        }
    }
    [activeMainView setHidden:NO];
    
}

- (void)viewSeqSetWithAnimation:(BOOL)animate
{
    if(animate){
        [UIView animateWithDuration:0.3 animations:^(void){
            [activeMainView setAlpha:0.0];
        } completion:^(BOOL finished){
            [self selectNavChoice:@"Set" withShift:NO];
        }];
    }else{
        [self selectNavChoice:@"Set" withShift:NO];
    }
    
}

- (void)viewSelectedInstrument
{
    [self selectNavChoice:@"Instrument" withShift:NO];
}

- (void)setSelectedInstrument:(Instrument *)inst
{
    [leftNavigator enableInstrumentViewWithIcon:inst.iconName showCustom:[inst checkIsCustom]];
}

- (void)openInstrument:(int)instIndex
{
    Instrument * inst = [seqSetViewController getInstrumentAtIndex:instIndex];
    
    [self setSelectedInstrument:inst];
    [self viewSelectedInstrument];
 
    //[instrumentViewController reopenView];
    [instrumentViewController setActiveInstrument:inst];
}

#pragma mark - Save Load Delegate

- (void)userDidLoadSequenceOptions
{
    //[optionsViewController userDidSaveSequence];
}

- (void)saveWithName:(NSString *)filename
{
    activeSequencer = filename;
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [self saveContext:filepath force:YES];
    [self saveContext:nil force:YES];
}

- (void)loadFromName:(NSString *)filename
{
    activeSequencer = filename;
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    
    [self loadStateFromDisk:filepath];
    [self saveContext:nil force:YES];
    
    if([activeSequencer isEqualToString:DEFAULT_SET_NAME]){
        [self relaunchFTUTutorial];
    }
}

- (void)renameFromName:(NSString *)filename toName:(NSString *)newname
{
    if([activeSequencer isEqualToString:filename]){
        activeSequencer = newname;
    }
    
    filename = [@"usr_" stringByAppendingString:filename];
    newname = [@"usr_" stringByAppendingString:newname];
    
    // move
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * currentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSString * newPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:newname];
    NSError * error = NULL;
    
    BOOL result = [[NSFileManager defaultManager] moveItemAtPath:currentPath toPath:newPath error:&error];
    
    if(!result)
        NSLog(@"Error moving");
   
    [self saveContext:nil force:YES];
}

- (void)createNewSaveName:(NSString *)filename
{
    
    // Save previous set if not blank
    if([seqSetViewController countInstruments] > 0 && ![filename isEqualToString:DEFAULT_SET_NAME]){
        
        // TODO: prompt
        NSString * promptTitle = [@"Save " stringByAppendingFormat:@"%@",filename];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:promptTitle message:@"Save changes to your current set?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES",nil];
        
        [alert show];
        
        sequencerToSave = filename;
    }else{
        [self createNewSet];
    }
}

- (void)createNewSet
{
    activeSequencer = @"";
    
    // Delete all cells
    [seqSetViewController deleteAllCells];
    
    [optionsViewController reloadFileTable];
    [optionsViewController.loadTable reloadData];
    [self viewSeqSetWithAnimation:YES];
}

- (void)createNewSetAndSave
{
    [self saveWithName:sequencerToSave];
    sequencerToSave = @"";
    [self createNewSet];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self createNewSet];
    }else if(buttonIndex == 1){
        [self createNewSetAndSave];
    }
}

- (void)deleteWithName:(NSString *)filename
{
    /*NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError * error;
    NSString * directoryPath = [paths objectAtIndex:0];
    
    NSMutableArray * fileSet = (NSMutableArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    // Exclude four default files
    for(NSString * path in fileSet){
        
        NSString * fullPath = [directoryPath stringByAppendingPathComponent:path];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        
    }*/
    
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * currentPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSError * error = NULL;
    
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:currentPath error:&error];
    
    if(!result)
        NSLog(@"Error deleting");
    
    [self saveContext:nil force:YES];
}


#pragma mark - Auto Save Load
- (void)saveContext:(NSString *)filepath force:(BOOL)forceSave
{
    if(saveContextTimer == nil || filepath != nil || forceSave){
        
        // Prevent from saving many times in a row, but never block a manual save
        [self clearSaveContextTimer];
        saveContextTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(clearSaveContextTimer) userInfo:nil repeats:NO];
        
        if(filepath == nil){
            filepath = instrumentDataFilePath;
            NSLog(@"Save state to disk");
        }else{
            NSLog(@"Save state to disk at %@",filepath);
        }
        
        NSData * instData = [NSKeyedArchiver archivedDataWithRootObject:[seqSetViewController getInstruments]];
        
        NSNumber * tempoNumber = [NSNumber numberWithInt:[playControlViewController getTempo]];
        
        NSNumber * volumeNumber = [NSNumber numberWithDouble:[playControlViewController getVolume]];
        
        NSNumber * selectedInstIndexNumber = [NSNumber numberWithInt:[seqSetViewController getSelectedInstrumentIndex]];
        
        [currentState setObject:instData forKey:@"Instruments Data"];
        [currentState setObject:tempoNumber forKey:@"Tempo"];
        [currentState setObject:volumeNumber forKey:@"Volume"];
        [currentState setObject:selectedInstIndexNumber forKey:@"Selected Instrument Index"];
        
        if(activeSequencer){
            [currentState setObject:activeSequencer forKey:@"Active Sequencer"];
        }else{
            [currentState setObject:@"" forKey:@"Active Sequencer"];
        }
        
        BOOL success = [currentState writeToFile:filepath atomically:YES];
        
        NSLog(@"Save success: %i", success);
            
    }
}

- (void)clearSaveContextTimer
{
    [saveContextTimer invalidate];
    saveContextTimer = nil;
}

- (void)loadStateFromDisk:(NSString *)filepath
{
    
    if(filepath == nil){
        filepath = instrumentDataFilePath;
        NSLog(@"Load state from disk");
    }else{
        NSLog(@"Load sequencer from disk at %@", filepath);
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filepath]) {
        NSLog(@"The sequencer save plist exists");
    } else {
        NSLog(@"The sequencer save plist does not exist");
    }
    
    currentState = [[NSDictionary dictionaryWithContentsOfFile:filepath] mutableCopy];
    
    if (currentState == nil )
        currentState = [[NSMutableDictionary alloc] init];
    
    if ( [[currentState allKeys] count] > 0 )
    {
        // Decode tempo:
        int tempo = [[currentState objectForKey:@"Tempo"] intValue];
        [playControlViewController setTempo:tempo];
        
        double volume = [[currentState objectForKey:@"Volume"] doubleValue];
        volume = MIN(volume,MAX_VOLUME);
        [playControlViewController setVolume:volume];
        
        // Decode selectedInstrumentIndex
        [seqSetViewController setSelectedInstrumentIndex:[[currentState objectForKey:@"Selected Instrument Index"] intValue]];
        
        // Decode array of instruments:
        
        NSData * instrumentData = [currentState objectForKey:@"Instruments Data"];
        
        [seqSetViewController setInstrumentsFromData:instrumentData];
        
        // Decode active sequencer filename
        NSString * sequencerName = [currentState objectForKey:@"Active Sequencer"];
        if(![sequencerName isEqualToString:@""]){
            activeSequencer = sequencerName;
            optionsViewController.activeSequencer = sequencerName;
        }

        // Load icon into left navigator
        
        NSLog(@"Get current instrument: Load Icon");
        Instrument * selectedInst = [seqSetViewController getCurrentInstrument];
        if(selectedInst != nil){
            [leftNavigator enableInstrumentViewWithIcon:selectedInst.iconName showCustom:[selectedInst checkIsCustom]];
        }
        
    }else{
        [playControlViewController resetTempo];
        [playControlViewController resetVolume];
        [seqSetViewController resetSelectedInstrumentIndex];
    }
}

- (NSString *)getDefaultSetFilepath
{
    return [[NSBundle mainBundle] pathForResource:@"defaultSet" ofType:@""];
}

#pragma mark - Play Events

- (void)startBackgroundLoop:(NSNumber *)spb
{
    if(playTimer == nil){
        
        if(TESTMODE) NSLog(@"Starting Background Loop with %f seconds per beat",[spb floatValue]);
        
        @synchronized(playTimer){
            [playTimer invalidate];
            
            NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
            
            forceRecord = NO;
            [self resetPatternData];
            
            playTimer = [NSTimer scheduledTimerWithTimeInterval:[spb floatValue] target:self selector:@selector(mainEventLoop) userInfo:nil repeats:YES];
            
            [runLoop run];
        }
    }
}

- (void)mainEventLoop
{
    
    // Tell all of the sequencers to play their next fret
    int instrumentCount = [seqSetViewController countInstruments];
    
    Instrument * currentInst = [seqSetViewController getCurrentInstrument];
    
    //@synchronized(self){
        for (int i=0; i<instrumentCount; i++){
            
            Instrument * instToPlay = [seqSetViewController getInstrumentAtIndex:i];
            
            @synchronized(instToPlay.selectedPattern){
                
                //
                // PLAY
                //
                int realMeasure = [instToPlay.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
                
                // If we are back at the beginning of the pattern, then check the queue:
                if (realMeasure == 0 && currentFret == 0 && [patternQueue count] > 0){
                    [self checkQueueForPatternsFromInstrument:instToPlay];
                }else if([patternQueue count] > 0){
                    
                    BOOL resetCount = NO;
                    if(currentFret == 0){
                        resetCount = YES;
                    }
                    
                    // Cause queued pattern to blink
                    [seqSetViewController notifyQueuedPatternsAtIndex:i andResetCount:resetCount];
                    
                    // update Instrument view if it's open
                    if(activeMainView == instrumentViewController.view && instToPlay == [seqSetViewController getCurrentInstrument]){
                        [instrumentViewController notifyQueuedPatternAndResetCount:resetCount];
                    }
                }
                
                // play sound and update Set view
                [instToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!instToPlay.isMuted withAmplitude:playVolume];
                
                // update Instrument view if it's open
                if(activeMainView == instrumentViewController.view && instToPlay == currentInst){
                    [instrumentViewController setPlaybandForMeasure:realMeasure toPlayband:currentFret];
                }
                
                
                //
                // RECORD
                //
                if(isRecording){
                    
                    int patternIndex = instToPlay.selectedPatternIndex;
                    if(instToPlay.isMuted){
                        patternIndex = 4;
                    }
                    
                    BOOL patternRepeat = NO;
                    if(instToPlay.selectedPattern.measureCount-1 == realMeasure && !instToPlay.isMuted){
                        patternRepeat = YES;
                    }
                    
                    BOOL updateMeasure = FALSE;
                    
                    int startPattern = -1;
                    double deltaI = -1;
                    int delta = -1;
                    
                    if(currentFret == 0){

                        startPattern = patternIndex;
                        deltaI = 0;
                        updateMeasure = TRUE;
                        
                        //[self updateMeasureDictionaryForInstrumentIndex:instToPlay.instrument withStartingPattern:patternIndex andDeltaI:0 andDelta:-1 andPatternRepeat:patternRepeat addFret:nil];
                        
                        
                        startPatterns[i] = patternIndex;
                        
                    }else{
                        
                        // if the instrument is toggled off
                        if(startPatterns[i] != patternIndex){
                            
                            deltaI = currentFret/16.0;
                            delta = patternIndex;
                            updateMeasure = TRUE;
                            
                            //[self updateMeasureDictionaryForInstrumentIndex:instToPlay.instrument withStartingPattern:-1 andDeltaI:(currentFret/16.0) andDelta:patternIndex andPatternRepeat:patternRepeat addFret:nil];
                            
                            startPatterns[i] = patternIndex;
                        }
                        
                        // last fret, about to change patterns
                        if(currentFret == 15 && [self getQueuedPatternIndexForInstrument:instToPlay] > -1){
                            
                            patternRepeat = NO;
                            updateMeasure = TRUE;
                            //[self updateMeasureDictionaryForInstrumentIndex:instToPlay.instrument withStartingPattern:-1 andDeltaI:-1 andDelta:-1 andPatternRepeat:NO addFret:nil];
                            
                        // pattern repeat may change if measures are added/subtracted
                        }else if(currentFret == 15 && patternRepeat != [[tempMeasures[i] objectForKey:@"patternrepeat"] boolValue]){
                            
                            updateMeasure = TRUE;
                            
                            //[[self updateMeasureDictionaryForInstrumentIndex:instToPlay.instrument withStartingPattern:-1 andDeltaI:-1 andDelta:-1 andPatternRepeat:patternRepeat addFret:nil];
                         }
                    }
                    
                    // Add notes at fret
                    NSString * strings = @"";
                    for(int s = 0; s < STRINGS_ON_GTAR; s++){
                        BOOL isStringOn = [instToPlay.selectedPattern.measures[realMeasure] isNoteOnAtString:s andFret:currentFret];
                        
                        strings = [strings stringByAppendingString:((isStringOn) ? @"1" : @"0")];
                        
                        if(isStringOn){
                            updateMeasure = TRUE;
                        }
                     }
                    
                    if(updateMeasure){
                        NSArray * fretObjArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:currentFret],strings,[NSNumber numberWithBool:instToPlay.isMuted],[NSNumber numberWithDouble:instToPlay.amplitude], nil];
                        
                        NSArray * fretKeyArray = [NSArray arrayWithObjects:@"fretindex",@"strings",@"ismuted",@"amplitude", nil];
                        
                        NSDictionary * fretDict = [[NSDictionary alloc] initWithObjects:fretObjArray forKeys:fretKeyArray];
                        
                        [self updateMeasureDictionaryForInstrumentIndex:instToPlay.instrument withStartingPattern:startPattern andDeltaI:deltaI andDelta:delta andPatternRepeat:patternRepeat addFret:fretDict];
                    }
                }
            }
        }
    //}
    
    if(isRecording && (currentFret == 15 || forceRecord)){
        
        NSMutableArray * newMeasure = [[NSMutableArray alloc] init];
        NSMutableArray * measureForIndex = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < MAX_INSTRUMENTS; i++){
            
            int instIndex = [[tempMeasures[i] objectForKey:@"instrument"] intValue];
            
            // Check that it's a valid instrument and hasn't already been added
            if([seqSetViewController isValidInstrumentIndex:instIndex] && [measureForIndex indexOfObject:[NSNumber numberWithInt:instIndex]] == NSNotFound){
                [newMeasure addObject:[NSMutableDictionary dictionaryWithDictionary:tempMeasures[i]]];
                [measureForIndex addObject:[NSNumber numberWithInt:instIndex]];
            }
            
            // Clear temp data
            [self clearMeasureDictionary:i];
        }
        
        [self addMeasureToPattern:newMeasure];
    }
    
    [seqSetViewController updateAllVisibleCells];
    
    [guitarView update];
    
    [self increasePlayLocation];
    
    if(TESTMODE) NSLog(@"Main event loop");
}

- (void)setRecordMode:(BOOL)record andAnimate:(BOOL)animate
{
    isRecording = record;
    
    if(isRecording){
        
        [recordShareController interruptRecording];
        
        if(activeMainView != seqSetViewController.view && activeMainView != instrumentViewController.view){
            [self selectNavChoice:@"Set" withShift:NO];
        }
    }else{
        
        if([seqSetViewController countInstruments] > 0){
            
            if(animate){
                [recordShareController reloadInstruments];
                [self stopAll];
                
                if(patternData != nil){
                    SoundMaster * soundMaster = [seqSetViewController getSoundMaster];
                    [recordShareController loadPattern:patternData withTempo:[playControlViewController getTempo] andSoundMaster:soundMaster];
                }
                
                [UIView setAnimationsEnabled:YES];
                
                [recordShareController.view setHidden:NO];
                [recordShareController.view setFrame:CGRectMake(0,-activeMainView.frame.size.height,activeMainView.frame.size.width,activeMainView.frame.size.height)];
                
                [UIView animateWithDuration:0.3 animations:^(void){
                    [recordShareController.view setFrame:CGRectMake(0, 0, activeMainView.frame.size.width, activeMainView.frame.size.height)];
                } completion:^(BOOL finished){
                    [self selectNavChoice:@"Share" withShift:NO];
                }];
            }else{
                [self selectNavChoice:@"Share" withShift:NO];
            }
        }        
    }
}

- (void)playRecordPlayback
{
    [recordShareController playRecordPlayback];
}

- (void)pauseRecordPlayback
{
    [recordShareController pauseRecordPlayback];
}

-(void)recordPlaybackDidEnd
{
    [playControlViewController pauseRecordPlayback];
}

-(void)addFinalRecordedPartialMeasure
{
    forceRecord = YES;
    [self mainEventLoop];
    forceRecord = NO;
}

#pragma mark - Record
- (void)resetPatternData
{
    patternData = [[NSMutableArray alloc] init];
    tempMeasures = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < MAX_INSTRUMENTS; i++){
        
        NSMutableArray * fretArray = [[NSMutableArray alloc] init];
        
        NSArray * objArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:-1],
                              @"",
                              [NSNumber numberWithInt:-1],
                              @"",
                              @"",
                              fretArray,nil];
        
        NSArray * keyArray = [NSArray arrayWithObjects:@"instrument",
                              @"start",
                              @"deltai",
                              @"delta",
                              @"patternrepeat",
                              @"frets",nil];
        
        [tempMeasures addObject:[NSMutableDictionary dictionaryWithObjects:objArray forKeys:keyArray]];
    }

}

- (void)updateMeasureDictionaryForInstrumentIndex:(int)inst withStartingPattern:(int)startIndex andDeltaI:(double)deltai andDelta:(int)delta andPatternRepeat:(BOOL)patternrepeat addFret:(NSDictionary *)newfret
{
    @synchronized(tempMeasures){
        
        NSArray * patternNames = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"OFF", nil];
        
        int m = [self chooseMeasureIndexForInstrument:inst];
    
        if(inst > -1){
            [tempMeasures[m] setObject:[NSNumber numberWithInt:inst] forKey:@"instrument"];
        }
        
        if(startIndex > -1){
            [tempMeasures[m] setObject:patternNames[startIndex] forKey:@"start"];
        }
        
        if(deltai > -1){
            [tempMeasures[m] setObject:[NSNumber numberWithDouble:deltai] forKey:@"deltai"];
        }
        
        if(delta > -1) {
            NSString * deltaName = (delta < 0) ? @"" : patternNames[delta];
            [tempMeasures[m] setObject:deltaName forKey:@"delta"];
        }
        
        [[tempMeasures objectAtIndex:m] setObject:[NSNumber numberWithBool:patternrepeat] forKey:@"patternrepeat"];
        
        if(newfret != nil){
            [[tempMeasures[m] objectForKey:@"frets"] addObject:newfret];
        }
    }
}

- (int)chooseMeasureIndexForInstrument:(int)instIndex
{
    int i = 0;
    for(; i < MAX_INSTRUMENTS; i++){
        
        int tempInst = [[tempMeasures[i] objectForKey:@"instrument"] intValue];
        if(tempInst == -1 || tempInst == instIndex){
            break;
        }
    }
    
    return i;
}

- (void)clearMeasureDictionary:(int)m
{
    @synchronized(tempMeasures){
        
        [[tempMeasures objectAtIndex:m] setObject:[NSNumber numberWithInt:-1] forKey:@"instrument"];
        [[tempMeasures objectAtIndex:m] setObject:@"" forKey:@"start"];
        [[tempMeasures objectAtIndex:m] setObject:[NSNumber numberWithInt:-1] forKey:@"deltai"];
        [[tempMeasures objectAtIndex:m] setObject:@"" forKey:@"delta"];
        [[tempMeasures objectAtIndex:m] setObject:@"" forKey:@"patternrepeat"];
        [[tempMeasures objectAtIndex:m] setObject:[[NSMutableArray alloc] init] forKey:@"frets"];
        
    }
}

- (void)addMeasureToPattern:(NSMutableArray *)m
{
    [patternData addObject:m];
}

#pragma mark - Pattern Queue

- (void)checkQueueForPatternsFromInstrument:(Instrument *)inst
{
    
    if(TESTMODE) NSLog(@"CHECK QUEUE FOR PATTERNS FROM INSTRUMENT");
    
    NSMutableArray * objectsToRemove = [NSMutableArray array];
  
    
    @synchronized(patternQueue)
    {
        // Pull out every pattern in the queue and select it
        for (NSDictionary * patternToSelect in patternQueue)
        {
            int nextPatternIndex = [[patternToSelect objectForKey:@"Index"] intValue];
            Instrument * nextPatternInstrument = [patternToSelect objectForKey:@"Instrument"];
            
            if (inst == nextPatternInstrument){
                if(TESTMODE) NSLog(@"DEQUEUEING THE NEXT PATTERN");
                [objectsToRemove addObject:patternToSelect];
                [seqSetViewController commitSelectingPatternAtIndex:nextPatternIndex forInstrument:nextPatternInstrument];
                
                if(activeMainView == instrumentViewController.view && inst==[seqSetViewController getCurrentInstrument]){
                    [instrumentViewController commitPatternChange:nextPatternIndex];
                }
                
                [self dequeuePatternAtIndex:inst.instrument];
            }
        }
        
        [patternQueue removeObjectsInArray:objectsToRemove];
    }
}

- (void)enqueuePattern:(NSMutableDictionary *)pattern
{
    if(TESTMODE) NSLog(@"Enqueue a new pattern");
    // For now, clear all the queued patterns for the active instrument
    [self removeQueuedPatternForInstrumentAtIndex:[seqSetViewController getCurrentInstrument].instrument];
    
    @synchronized(patternQueue){
        [patternQueue addObject:pattern];
    }
    
   if(TESTMODE)  NSLog(@"Pattern Queue is: %@",patternQueue);
}

-(void)dequeueAllPatternsForInstrument:(Instrument *)inst
{
    @synchronized(patternQueue){
        for(NSMutableDictionary * p in patternQueue){
            Instrument * i = [p objectForKey:@"Instrument"];
            if(i == inst){
                [patternQueue removeObject:p];
            }
        }
    }
}

-(void)removeQueuedPatternForInstrumentAtIndex:(int)instIndex
{
    @synchronized(patternQueue){
        for(NSMutableDictionary * p in patternQueue){
            Instrument * i = [p objectForKey:@"Instrument"];
            if(i.instrument == instIndex)
            {
                [patternQueue removeObject:p];
            }
        }
    }
}

- (void)dequeuePatternAtIndex:(int)instIndex
{
    if(TESTMODE) NSLog(@"dequeuing pattern for instrument at index %i",instIndex);
    [seqSetViewController clearQueuedPatternButtonAtIndex:instIndex];
}

- (int)getQueuedPatternIndexForInstrument:(Instrument *)inst
{
    @synchronized(patternQueue){
        for(NSMutableDictionary * pq in patternQueue){
            Instrument * i = [pq objectForKey:@"Instrument"];
            if(i == inst){
                NSNumber * p = [pq objectForKey:@"Index"];
                int pIndex = (int)[p intValue];
                return pIndex;
            }
        }
    }
    
    return -1;
}

#pragma mark - Play Control Delegate

- (void)startGestures
{
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeLeftNavigator)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [swipeLeft setNumberOfTouchesRequired:1];
    
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openLeftNavigator)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [swipeRight setNumberOfTouchesRequired:1];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    [seqSetViewController.view setUserInteractionEnabled:YES];

}

- (void)stopGestures
{
    [self.view removeGestureRecognizer:swipeLeft];
    [self.view removeGestureRecognizer:swipeRight];
    [seqSetViewController.view setUserInteractionEnabled:NO];
}

- (void)stopDrawing
{
    [seqSetViewController turnContentDrawingOff];
}

- (void)startDrawing
{
    [seqSetViewController turnContentDrawingOn];
    [seqSetViewController updateAllVisibleCells];
}

- (void)forceHideSessionOverlay
{
    [playControlViewController hideSessionOverlay];
}

- (void)forceShowSessionOverlay
{
    [playControlViewController showSessionOverlay];
}

- (void)stopAllPlaying
{
    if(isRecording){
        [self addFinalRecordedPartialMeasure];
    }
    
    isPlaying = FALSE;
    isRecording = FALSE;
    [playTimer invalidate];
    playTimer = nil;
    
    [seqSetViewController stopSoundMaster];
    
    //[playControlViewController stopAll];
}

- (void)startAllPlaying:(float)spb withAmplitude:(double)volume
{
    // Clean up playing without setting false
    [playTimer invalidate];
    playTimer = nil;
    
    [seqSetViewController stopSoundMaster];
    
    // Start again
    isPlaying = TRUE;
    playVolume = volume;
    
    [seqSetViewController startSoundMaster];
    
    [self performSelectorInBackground:@selector(startBackgroundLoop:) withObject:[NSNumber numberWithFloat:spb]];
}

- (void)changePlayVolume:(double)newVolume
{
    playVolume = newVolume;
}

- (void)initPlayLocation
{
    if(currentFret == -1){
        [self increasePlayLocation];
    }
}

- (void)increasePlayLocation
{
    if(TESTMODE) NSLog(@"Increase play location");
    
    currentFret++;
    
    if (currentFret > LAST_FRET){
        currentFret = 0;
        currentAbsoluteMeasure++;
        
        if (currentAbsoluteMeasure > LAST_MEASURE){
            currentAbsoluteMeasure = 0;
        }
    }
}

- (void)resetPlayLocation
{
    currentFret = -1;
    currentAbsoluteMeasure = 0;
}

#pragma mark - Hover Set Name
- (void)hoverSetName
{
    NSString * setNameText = ([activeSequencer isEqualToString:@""] || activeSequencer == nil) ? @"New set" : activeSequencer;
    
    float x = (isScreenLarge) ? XBASE_LG : XBASE_SM;
    float setNameWidth = [setNameText length];
    if([setNameText length] < 11){
        setNameWidth *= 14;
    }else{
        setNameWidth *= 10.5;
    }
    float setNameHeight = 40;
    float cornerRadius = 10;

    setNameOnScreenFrame = CGRectMake(x-setNameWidth+cornerRadius, -1*cornerRadius, setNameWidth, setNameHeight);
    setNameOffScreenFrame = CGRectMake(x-setNameWidth+cornerRadius, -1*setNameHeight, setNameWidth, setNameHeight);
    
    if(setName == nil){
        setName = [[UIButton alloc] init];
    }
    
    [setName setFrame:setNameOffScreenFrame];
    [setName setBackgroundColor:[UIColor colorWithRed:40/255.0 green:47/255.0 blue:51/255.0 alpha:1.0]];
    [setName setTitle:setNameText forState:UIControlStateNormal];

    [setName setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [setName.titleLabel setFont:[UIFont fontWithName:FONT_BOLD size:17.0]];
    [setName setTitleEdgeInsets:UIEdgeInsetsMake(7,0,0,0)];
    
    setName.layer.cornerRadius = 10.0;
    setName.layer.borderColor = [UIColor whiteColor].CGColor;
    setName.layer.borderWidth = 2.0f;

    [self.view addSubview:setName];

    [setName setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^(void){
        [setName setFrame:setNameOnScreenFrame];
    } completion:^(BOOL finished){
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideSetName) userInfo:nil repeats:NO];
    }];
}

-(void)hideSetName
{
    //if(setName != nil){
    if(![setName isHidden]){
        [setName setFrame:setNameOnScreenFrame];
        [UIView animateWithDuration:0.5 animations:^(void){
            [setName setFrame:setNameOffScreenFrame];
        } completion:^(BOOL finished){
            [setName setHidden:YES];
            //[setName removeFromSuperview];
            //setName = nil;
        }];
    }
    //}
}

#pragma mark - Play control

- (BOOL)checkIsPlaying
{
    return isPlaying;
}

- (BOOL)checkIsRecording
{
    if(isRecording){
        NSLog(@"RECORDING");
    }else{
        NSLog(@"NOT RECORDING");
    }
    return isRecording;
}

- (void)stopAll
{
    [playControlViewController stopPlayRecord];

}

- (void)startAll
{
    [playControlViewController startStop:self];
}

- (void)userDidSelectShare
{
    [recordShareController openShareScreen];
}

#pragma mark - Seq Set Delegate

- (void)setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying
{
    guitarView.measure = measure;
    
    if(!checkNotPlaying || (checkNotPlaying && !isPlaying)){
        [guitarView update];
    }
}

- (void)turnOffGuitarEffects
{
    [NSTimer scheduledTimerWithTimeInterval:0.0 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:guitarView selector:@selector(turnOffEffects) userInfo:nil repeats:NO];
}

- (void)updateGuitarView
{
    [guitarView update];
    
    // Also update selected instrument
    Instrument * inst = [seqSetViewController getCurrentInstrument];
    [self setSelectedInstrument:inst];
    
    // Also update the selected table cell
    //[seqSetViewController setSelectedCellToSelectedInstrument];
    
}

- (void)updateSelectedInstrument
{
    Instrument * inst = [seqSetViewController getCurrentInstrument];
    [self setSelectedInstrument:inst];
}

// Ensure current playband is reflected in the data if displayed (>=0)
// Only need to call when # measures changes
- (void)updatePlaybandForInstrument:(Instrument *)inst
{
    if (currentFret >= 0){
        int realMeasure = [inst.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
        [inst playFret:currentFret inRealMeasure:realMeasure withSound:NO withAmplitude:playVolume];
        
        // update Instrument view if it's open
        if(activeMainView == instrumentViewController.view && inst == [seqSetViewController getCurrentInstrument]){
            [instrumentViewController setPlaybandForMeasure:realMeasure toPlayband:currentFret];
        }
    }
    
    if(TESTMODE) NSLog(@"updatePlaybandForInstrument");
}

- (void) numInstrumentsDidChange:(int)numInstruments
{
    if(numInstruments > 0){
        Instrument * inst = [seqSetViewController getCurrentInstrument];
        [leftNavigator enableInstrumentViewWithIcon:inst.iconName showCustom:[inst checkIsCustom]];
    }else{
        [leftNavigator disableInstrumentView];
    }
}

- (NSMutableArray *)getInstruments
{
    return [seqSetViewController getInstruments];
}

- (void)refreshVolumeSliders
{
    [seqSetViewController reloadTableData];
    [instrumentViewController resetVolume];
}

- (void)enableInstrument:(int)instIndex
{
    if([seqSetViewController getCurrentInstrument].instrument == instIndex){
        [instrumentViewController enableKnobIfDisabled];
    }
    [seqSetViewController enableKnobIfDisabledForInstrument:instIndex];
}

- (void)disableInstrument:(int)instIndex
{
    if([seqSetViewController getCurrentInstrument].instrument == instIndex){
        [instrumentViewController disableKnobIfEnabled];
    }
    [seqSetViewController disableKnobIfEnabledForInstrument:instIndex];
}

#pragma mark - Guitar Observer

- (void)notePlayedAtString:(int)str andFret:(int)fr
{
    if (!isConnected || fr == 0){
        return;
    }
    
    if ([seqSetViewController getSelectedInstrumentIndex] < 0 || [seqSetViewController countInstruments] == 0){
        NSLog(@"No Instruments opened, or selected instrument index < 0");
        return;
    }
    
    if(TESTMODE) NSLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];
    
}

- (void)notePlayed:(SEQNote *)note
{
    if(TESTMODE) NSLog(@"gTarSeq received note played message string %i and fret %i",note.string,note.fret);
    
    // Pass note-played message onto the selected instrument
    [[seqSetViewController getCurrentInstrument] notePlayedAtString:note.string andFret:note.fret];
    
    [seqSetViewController updateAllVisibleCells];
    [instrumentViewController updateActiveMeasure];
    
    [guitarView update];
    
    [self saveContext:nil force:NO];
}

#pragma mark - gTar Connected

- (void)checkGtarConnected
{
    if([guitarView isGtarConnected]){
        [self gtarConnected:YES];
    }
}

- (void)gtarConnected:(BOOL)toConnect
{
    if(toConnect) NSLog(@"gTar connected");
    else NSLog(@"gTar disconnected");
    
    isConnected = toConnect;
    
    // display active measure on gTar
    if(isConnected){
        guitarView.measure = [seqSetViewController getCurrentInstrument].selectedPattern.selectedMeasure;
    }
    
    // change connected button
    [leftNavigator changeConnectedButton:isConnected];
    
}

#pragma mark - External file sharing

- (void)userDidLaunchEmailWithAttachment:(NSString *)filename
{
    MFMailComposeViewController * email = [[MFMailComposeViewController alloc] init];
    email.mailComposeDelegate = self;
    
    // Subject
    [email setSubject:@"Sequence"];
    
    // Body
    NSString * body = @"Check out this song I just made with <a href='http://www.incidentgtar.com/'>Sequence</a>!";
    [email setMessageBody:body isHTML:YES];
    
    // Attachment
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
    NSString * filepath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSData * fileData = [NSData dataWithContentsOfFile:filepath];
    
    [email addAttachmentData:fileData mimeType:@"audio/m4a" fileName:filename];
    
    [self.navigationController presentViewController:email animated:YES completion:nil];
    
}

- (void)userDidLaunchSMSWithAttachment:(NSString *)filename
{
    NSLog(@"Launching SMS");
    
    MFMessageComposeViewController * message = [[MFMessageComposeViewController alloc] init];
    message.messageComposeDelegate = self;
    
    // Body
    NSString * body = @"Check out this song I just made with Sequence! http://gtar.fm/";
    [message setBody:body];
    
    // Attachment
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
    NSString * filepath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSData * fileData = [NSData dataWithContentsOfFile:filepath];
    
    //kUTTypeMPEG4Audio
    [message addAttachmentData:fileData typeIdentifier:@"kUTTypeMPEG4Audio" filename:filename];
    
    if(message != nil){
        [self.navigationController presentViewController:message animated:YES completion:nil];
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - FTU Tutorial

-(void)relaunchFTUTutorial
{
    [self stopAll];
    
    [self launchFTUTutorial];
    
    // Reset other BOOLs
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedInstrumentView"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedCustom"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedSeqSetView"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)launchFTUTutorial
{
    float y = [[UIScreen mainScreen] bounds].size.width;
    float x = [[UIScreen mainScreen] bounds].size.height;
    
    NSLog(@" *** Launch FTU Tutorial *** %f %f",x,y);
    
    CGRect tutorialFrame = CGRectMake(0,0,x,y);
    
    
    if(tutorialViewController){
        [tutorialViewController clear];
    }
    
    tutorialViewController = [[TutorialViewController alloc] initWithFrame:tutorialFrame andTutorial:@"Intro"];
    tutorialViewController.delegate = self;
        
    [self.view addSubview:tutorialViewController];
    
    [tutorialViewController launch];
    
    isTutorialOpen = YES;
    
    [self stopGestures];
}

- (void)endTutorialIfOpen
{
    [tutorialViewController end];
}

- (void)notifyTutorialEnded
{
    isTutorialOpen = NO;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self startGestures];
}

- (void)forceToPlay
{
    [self startAll];
}

@end
