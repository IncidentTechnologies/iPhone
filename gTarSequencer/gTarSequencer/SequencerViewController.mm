//
//  SequencerViewController.m
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "SequencerViewController.h"
#import "NSSequence.h"
#import "CloudController.h"

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
#define DEFAULT_STATE_NAME @"sequenceCurrentState"
#define TABLE_SETS @"Sequences"
#define TABLE_SONGS @"Songs"

@implementation SequencerViewController

@synthesize isFirstLaunch;
@synthesize optionsViewController;
@synthesize seqSetViewController;
@synthesize instrumentViewController;
@synthesize playControlViewController;
@synthesize infoViewController;
@synthesize tutorialViewController;
@synthesize gatekeeperViewController;
@synthesize recordShareController;
@synthesize leftNavigator;
@synthesize setName;

@synthesize loadedSong;

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
    
    // Check to remove the old FTU set?
    BOOL convertTutorialSet = [[NSUserDefaults standardUserDefaults] boolForKey:@"ConvertTutorialSet"];
    
    // Load default set for FTU
    // Remove the old one if necessary
    if(isFirstLaunch || !convertTutorialSet){
        [self copyTutorialFile];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"ConvertTutorialSet"];
    }
    
    
    NSString * filePath = (isFirstLaunch) ? @"usr_Tutorial" : nil;
    
    [self loadStateFromDisk:filePath];
    
    [self selectNavChoice:@"Set" withShift:NO];
    [self saveContext:nil force:NO];
    
    // Overlay tutorial?
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
    // Gtar delegate and connection spoof
    DLog(@"Setup and connect gTar");
    //isConnected = NO;
    
    guitarView = [[GuitarView alloc] init];
    guitarView.delegate = self;
    
    //[NSTimer scheduledTimerWithTimeInterval:3.0 target:guitarView selector:@selector(observeGtar) userInfo:nil repeats:NO];
    
    string = 0;
    fret = 0;
    
    patternQueue = [NSMutableArray array];
}

- (void)initSubviews
{
    frameGenerator = [[FrameGenerator alloc] init];
    
    bool isScreenLarge = [frameGenerator isScreenLarge];
    float x = [frameGenerator getFullscreenWidth];
    
    onScreenMainFrame = CGRectMake(0,0,x,TABLEHEIGHT);
    overScreenMainFrame = CGRectMake(NAVWIDTH-NAVTAB,0,x,TABLEHEIGHT);
    
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
    
    DLog(@"Get current instrument: Sequencer View Controller");
    NSTrack * currentTrack = [seqSetViewController getCurrentTrack];
    
    if (currentTrack){
        guitarView.measure = currentTrack.selectedPattern.selectedMeasure;
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
    [playControlViewController.view setFrame:CGRectMake(0,TABLEHEIGHT-4,[frameGenerator getFullscreenWidth],YBASE-TABLEHEIGHT+3)];
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
    // LOGGED OUT
    //
    
    gatekeeperViewController = [[GatekeeperViewController alloc] init];
    
    gatekeeperViewController.delegate = self;
    
    // TODO: if we are not logged in but have cached creds, login
    if(g_cloudController.m_loggedIn == NO && g_loggedInUser.m_username != nil){
        
        [gatekeeperViewController requestCachedLogin];
        
        // If we are not logged in but have cached credits, login
        [self loggedIn:NO];
        
    }else if(g_cloudController.m_loggedIn == NO){
        
        // logged out screen
        [self loggedOut:NO];
    }
    
    //
    // GTAR CONNECTED
    //
    
    [leftNavigator changeConnectedButton:false];
    
    //
    // GESTURES
    //
    
    [self startGestures];
    
}

#pragma mark - File Management

-(void)copyTutorialFile
{
    NSString * defaultSetPath = [[NSBundle mainBundle] pathForResource:@"tutorialSet" ofType:@"xml"];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * newDefaultSetPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sequences/usr_Tutorial.xml"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sequences"];
    
    NSError * err = NULL;
    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&err];
    
    // Delete if it already exists
    [fileManager removeItemAtPath:newDefaultSetPath error:&err];
    
    // Then copy it
    if(![fileManager copyItemAtPath:defaultSetPath toPath:newDefaultSetPath error:&err]){
        DLog(@"Error copying");
    }
    
    DLog(@"Copied tutorial file from %@ to %@",defaultSetPath,newDefaultSetPath);
}

#pragma mark - Left Navigator

- (BOOL)isLeftNavOpen
{
    return leftNavOpen;
}

- (void)closeLeftNavigator
{
    DLog(@"Close left nav");
    
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
    DLog(@"Open left nav");
    
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
    
    DLog(@"Switch to %@ view",nav);
    
    [optionsViewController.view setHidden:YES];
    [seqSetViewController.view setHidden:YES];
    [instrumentViewController.view setHidden:YES];
    [recordShareController.view setHidden:YES];
    [infoViewController.view setHidden:YES];
    
    // Do any view unloading
    [optionsViewController unloadView];
    if(!isRecording){
        [playControlViewController hideSessionOverlay];
    }
    
    // Switch to new main subview
    if([nav isEqualToString:@"Options"]){
        
        activeMainView = optionsViewController.view;
        
    }else if([nav isEqualToString:@"Set"]){
        
        [seqSetViewController reloadTableData];
        activeMainView = seqSetViewController.view;
        
    }else if([nav isEqualToString:@"Instrument"]){
        
        [instrumentViewController reopenView];
        activeMainView = instrumentViewController.view;
        
        NSTrack * track = [seqSetViewController getCurrentTrack];
        
        [instrumentViewController setActiveTrack:track];
        
    }else if([nav isEqualToString:@"Share"]){
        
        activeMainView = recordShareController.view;
        //[recordShareController reloadInstruments];
        [self stopAll];
        
        if(recordingSong != nil){
            //SoundMaster * soundMaster = [seqSetViewController getSoundMaster];
            //[recordShareController loadPattern:patternData withTempo:[playControlViewController getTempo] andSoundMaster:soundMaster activeSequence:[seqSetViewController getSequence] activeSong:activeSong];
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
    if([nav isEqualToString:@"Set"] && !isTutorialOpen && g_cloudController.m_loggedIn == YES){
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
        [seqSetViewController startSoundMaster];
    }
    
    // Lock record?
    if([nav isEqualToString:@"Options"]){
        if(isRecording){
            //[recordShareController interruptRecording];
            [playControlViewController stopPlayRecordAndAnimate:NO showEndScreen:NO];
            
            DLog(@"IS Recording is %i",isRecording);
            
        }
        [playControlViewController setLockRecord:YES];
    }else{
        [playControlViewController setLockRecord:NO];
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

- (void)viewRecordShareWithAnimation:(BOOL)animate
{
    if(animate){
        [UIView animateWithDuration:0.3 animations:^(void){
            [activeMainView setAlpha:0.0];
        } completion:^(BOOL finished){
            [self selectNavChoice:@"Share" withShift:NO];
        }];
    }else{
        [self selectNavChoice:@"Share" withShift:NO];
    }
}

- (void)viewSelectedInstrument
{
    [self selectNavChoice:@"Instrument" withShift:NO];
}

- (void)setSelectedInstrument:(NSInstrument *)inst
{
    [leftNavigator enableInstrumentViewWithIcon:inst.m_iconName showCustom:inst.m_custom];
}

- (void)openInstrument:(int)instIndex
{
    NSTrack * track = [seqSetViewController getTrackAtIndex:instIndex];
    
    [self setSelectedInstrument:track.m_instrument];
    [self viewSelectedInstrument];
    
    [instrumentViewController setActiveTrack:track];
}

- (void)commitMasterLevelSlider:(UILevelSlider *)masterSlider
{
    SoundMaster * soundMaster = [seqSetViewController getSoundMaster];
    [soundMaster releaseMasterLevelSlider];
    [soundMaster commitMasterLevelSlider:masterSlider];
}

#pragma mark - Options View Controller

- (int)countInstruments
{
    return [seqSetViewController countMasterInstrumentOptions];
}

- (int)countSounds
{
    return [seqSetViewController countSamples];
}

#pragma mark - Save Load

- (void)userDidLoadSequenceOptions
{
    //[optionsViewController userDidSaveSequence];
}

- (void)saveWithName:(NSString *)filename
{
    [self setActiveSequence:filename];
    filename = [@"usr_" stringByAppendingString:filename];
    
    [self saveContext:filename force:YES];
    [self saveContext:nil force:YES];
}

- (void)loadFromName:(NSString *)filename andType:(NSString *)type
{
    if([type isEqualToString:TABLE_SETS]){
        DLog(@"Load set from name %@",filename);
        
        // First clear any sound playing
        [seqSetViewController resetSoundMaster];
        
        [self setActiveSequence:filename];
        
        [self loadStateFromDisk:filename];
        [self saveContext:nil force:YES];
        
        if([activeSequencer isEqualToString:DEFAULT_SET_NAME]){
            [self relaunchFTUTutorial];
        }
    }else if([type isEqualToString:TABLE_SONGS]){
        DLog(@"Load song from name %@",filename);
        
        // First clear any sound playing
        [seqSetViewController stopSoundMaster];
        [seqSetViewController resetSoundMaster];
        
        [self setActiveSong:filename];
        filename = [@"usr_" stringByAppendingString:filename];
        
        // Init the song
        loadedSong = [[NSSong alloc] initWithXMPFilename:filename];
        
        if(loadedSong != nil){
            // Set the active sequencer accordingly
            [self loadStateFromDisk:loadedSong.m_sequenceName];
            [self saveContext:nil force:YES];
        
            // Load into record share view
            SoundMaster * soundMaster = [seqSetViewController getSoundMaster];
            
            isRecording = TRUE;
            [recordShareController loadSong:loadedSong andSoundMaster:soundMaster activeSequence:[seqSetViewController getSequence] activeSong:activeSong];
        }
        
    }
}

- (void)renameFromName:(NSString *)filename toName:(NSString *)newname andType:(NSString *)type
{
    if([type isEqualToString:TABLE_SETS]){
        if([activeSequencer isEqualToString:filename]){
            [self setActiveSequence:newname];
        }
    }else if([type isEqualToString:TABLE_SONGS]){
        if([activeSong isEqualToString:filename]){
            [self setActiveSong:newname];
        }
    }
    
    filename = [@"usr_" stringByAppendingString:filename];
    filename = [filename stringByAppendingString:@".xml"];
    
    NSString * newnamepath = [@"usr_" stringByAppendingString:newname];
    newnamepath = [newnamepath stringByAppendingString:@".xml"];
    
    // move
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:type];
    NSString * currentPath = [directory stringByAppendingPathComponent:filename];
    NSString * newPath = [directory stringByAppendingPathComponent:newnamepath];
    NSError * error = NULL;
    
    BOOL result = [[NSFileManager defaultManager] moveItemAtPath:currentPath toPath:newPath error:&error];
    
    if(!result)
        DLog(@"Error moving");
    
    if([type isEqualToString:TABLE_SETS]){
        if([activeSequencer isEqualToString:newname]){
            [self saveContext:[@"usr_" stringByAppendingString:newname] force:YES];
        }
    }
    [self saveContext:nil force:YES];
}

- (void)createNewSaveName:(NSString *)filename
{
    
    // Save previous set if not blank
    if([seqSetViewController countTracks] > 0 && ![filename isEqualToString:DEFAULT_SET_NAME]){
        
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
    [self setActiveSequence:@""];
    
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

- (void)deleteWithName:(NSString *)filename andType:(NSString *)type
{
    // Reset active if it's being deleted
    if([type isEqualToString:TABLE_SETS] && [filename isEqualToString:activeSequencer]){
        [self setActiveSequence:@""];
    }else if([type isEqualToString:TABLE_SONGS] && [filename isEqualToString:activeSong]){
        [self setActiveSong:@""];
    }
    
    // Then delete
    filename = [@"usr_" stringByAppendingString:filename];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * directory = [[paths objectAtIndex:0] stringByAppendingPathComponent:type];
    NSString * currentPath = [[directory stringByAppendingPathComponent:filename] stringByAppendingString:@".xml"];
    NSError * error = NULL;
    
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:currentPath error:&error];
    
    if(!result)
        DLog(@"Error deleting");
    
    [self saveContext:nil force:YES];
}

#pragma mark - Active Sequence / Active Song

- (void)setActiveSequence:(NSString *)sequence
{
    activeSequencer = sequence;
    [optionsViewController setActiveSequencer:sequence];
}

- (void)setActiveSong:(NSString *)song
{
    activeSong = song;
    [optionsViewController setActiveSong:song];
}

- (NSString *)getActiveSongName
{
    return activeSong;
}


#pragma mark - Auto Save Load
- (void)saveContext:(NSString *)filepath force:(BOOL)forceSave
{
    // Save the sequence
    [seqSetViewController saveContext:filepath force:forceSave];

}

- (void)updateTempo:(int)tempo
{
    [seqSetViewController updateTrackTempo:tempo];
}

- (void)setTempo:(int)tempo
{
    [playControlViewController setTempo:tempo];
}

-(void)setVolume:(double)volume
{
    volume = MIN(volume,MAX_VOLUME);
    [playControlViewController setVolume:volume];
}

- (void)loadStateFromDisk:(NSString *)filepath
{
    NSString * sequencerName = [seqSetViewController loadStateFromDisk:filepath];
    
    if(![sequencerName isEqualToString:@""] && ![sequencerName isEqualToString:DEFAULT_STATE_NAME]){
        
        [self setActiveSequence:sequencerName];
        [self setActiveSong:activeSong];
    }
    
    // Reset
    if(filepath == nil){
        
        [playControlViewController resetTempo];
        [playControlViewController resetVolume];
            
    }
}

#pragma mark - Play Events

- (void)startBackgroundLoop:(NSNumber *)spb
{
    if(playTimer == nil){
        
        DLog(@"Starting Background Loop with %f seconds per beat",[spb floatValue]);
        
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
    int trackCount = [seqSetViewController countTracks];
    
    NSTrack * currentTrack = [seqSetViewController getCurrentTrack];
    
    //@synchronized(self){
    for (int i=0; i<trackCount; i++){
        
        NSTrack * trackToPlay = [seqSetViewController getTrackAtIndex:i];
        
        @synchronized(trackToPlay.selectedPattern){
            
            //
            // PLAY
            //
            int realMeasure = [trackToPlay.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
            
            // If we are back at the beginning of the pattern, then check the queue:
            if (realMeasure == 0 && currentFret == 0 && [patternQueue count] > 0){
                [self checkQueueForPatternsFromTrack:trackToPlay];
            }else if([patternQueue count] > 0){
                
                BOOL resetCount = NO;
                if(currentFret == 0){
                    resetCount = YES;
                }
                
                // Cause queued pattern to blink
                [seqSetViewController notifyQueuedPatternsAtIndex:i andResetCount:resetCount];
                
                // update Instrument view if it's open
                if(activeMainView == instrumentViewController.view && trackToPlay == [seqSetViewController getCurrentTrack]){
                    [instrumentViewController notifyQueuedPatternAndResetCount:resetCount];
                }
            }
            
            // play sound and update Set view
            [trackToPlay playFret:currentFret inRealMeasure:realMeasure withSound:!trackToPlay.m_muted withAmplitude:playVolume];
            
            // update Instrument view if it's open
            if(activeMainView == instrumentViewController.view && trackToPlay == currentTrack){
                [instrumentViewController setPlaybandForMeasure:realMeasure toPlayband:currentFret];
            }
            
            // RECORD XMP
            if(isRecording){
                
                NSTrack * songTrack = [recordingSong trackWithName:trackToPlay.m_name level:trackToPlay.m_level mute:trackToPlay.m_muted instrument:trackToPlay.m_instrument];
                NSClip * songClip = [songTrack lastClipComparePattern:trackToPlay.selectedPattern.m_name andMuted:trackToPlay.m_muted atBeat:r_beat/4.0];
                
                NSString * strings = @"";
                for(int s = 0; s < STRINGS_ON_GTAR; s++){
                    BOOL isStringOn = [trackToPlay.selectedPattern.m_measures[realMeasure] isNoteOnAtString:s andFret:currentFret];
                    
                    strings = [strings stringByAppendingString:((isStringOn) ? @"1" : @"0")];
                    
                    if(isStringOn){
                        NSNote * newNote = [[NSNote alloc] initWithValue:[NSString stringWithFormat:@"%i",s] beatstart:r_beat/4.0 duration:0.25];
                        [songClip addNote:newNote];
                    }
                }
            }
            
        }
    }
    
    [seqSetViewController updateAllVisibleCells];
    
    [guitarView update];
    
    [self increasePlayLocation];
}

- (void)setRecordMode:(BOOL)record andAnimate:(BOOL)animate
{
    isRecording = record;
    
    if(isRecording){
        
        //[recordShareController interruptRecording];
        
        if(activeMainView != seqSetViewController.view && activeMainView != instrumentViewController.view){
            [self selectNavChoice:@"Set" withShift:NO];
        }
        
    }else{
        
        if([seqSetViewController countTracks] > 0){
            
            [recordShareController reloadInstruments];
            [self stopAll];
            
            if(recordingSong != nil){
                
                DLog(@"Record did end");
                [recordingSong finishTracks];
                
                // XMP recording
                [recordingSong printTree];
                
                SoundMaster * soundMaster = [seqSetViewController getSoundMaster];
                
                [recordShareController loadSong:recordingSong andSoundMaster:soundMaster activeSequence:[seqSetViewController getSequence] activeSong:activeSong];
                
                [self setActiveSong:recordingSong.m_title];
            }
            
            if(animate){
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
    
    // Ensure volume has been set
    playVolume = (playVolume == 0) ? DEFAULT_VOLUME : playVolume;
    
    [self mainEventLoop];
    
    forceRecord = NO;
}

#pragma mark - Record
- (void)resetPatternData
{
    NSString * nextSongName = [recordShareController generateNextRecordedSongName];
    
    recordingSong = [[NSSong alloc] initWithTitle:nextSongName author:g_loggedInUser.m_username description:@"" tempo:[playControlViewController getTempo] looping:false loopstart:0 loopend:0 sequenceName:[seqSetViewController getSequence].m_name sequenceId:[seqSetViewController getSequence].m_id];
    
    r_beat = 0;
    
}

#pragma mark - Pattern Queue

- (void)checkQueueForPatternsFromTrack:(NSTrack *)track
{
    
    DLog(@"CHECK QUEUE FOR PATTERNS FROM INSTRUMENT");
    
    NSMutableArray * objectsToRemove = [NSMutableArray array];
    
    @synchronized(patternQueue)
    {
        // Pull out every pattern in the queue and select it
        for (NSDictionary * patternToSelect in patternQueue)
        {
            int nextPatternIndex = [[patternToSelect objectForKey:@"Index"] intValue];
            NSTrack * nextPatternTrack = [patternToSelect objectForKey:@"Instrument"];
            
            if (track == nextPatternTrack){
                DLog(@"DEQUEUEING THE NEXT PATTERN");
                [objectsToRemove addObject:patternToSelect];
                [seqSetViewController commitSelectingPatternAtIndex:nextPatternIndex forTrack:nextPatternTrack];
                
                if(activeMainView == instrumentViewController.view && track==[seqSetViewController getCurrentTrack]){
                    [instrumentViewController commitPatternChange:nextPatternIndex];
                }
                
                [self dequeuePatternAtIndex:track.m_instrument.m_id];
            }
        }
        
        [patternQueue removeObjectsInArray:objectsToRemove];
    }
}

- (void)enqueuePattern:(NSMutableDictionary *)pattern
{
    DLog(@"Enqueue a new pattern");
    // For now, clear all the queued patterns for the active instrument
    [self removeQueuedPatternForInstrumentAtIndex:[[seqSetViewController getCurrentTrack] m_instrument].m_id];
    
    @synchronized(patternQueue){
        [patternQueue addObject:pattern];
    }
    
    DLog(@"Pattern Queue is: %@",patternQueue);
}

-(void)dequeueAllPatternsForTrack:(NSTrack *)track
{
    @synchronized(patternQueue){
        for(NSMutableDictionary * p in patternQueue){
            NSTrack * t = [p objectForKey:@"Instrument"];
            if(t == track){
                [patternQueue removeObject:p];
            }
        }
    }
}

-(void)removeQueuedPatternForInstrumentAtIndex:(int)instIndex
{
    @synchronized(patternQueue){
        for(NSMutableDictionary * p in patternQueue){
            NSTrack * t = [p objectForKey:@"Instrument"];
            if(t.m_instrument.m_id == instIndex)
            {
                [patternQueue removeObject:p];
            }
        }
    }
}

- (void)dequeuePatternAtIndex:(int)instIndex
{
    DLog(@"dequeuing pattern for instrument at index %i",instIndex);
    [seqSetViewController clearQueuedPatternButtonAtIndex:instIndex];
}

- (int)getQueuedPatternIndexForTrack:(NSTrack *)track
{
    @synchronized(patternQueue){
        for(NSMutableDictionary * pq in patternQueue){
            NSTrack * t = [pq objectForKey:@"Instrument"];
            if(t == track){
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
    [self stopGestures];
    
    //DLog(@"******** start gestures");
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
    //DLog(@" ***** stop gestures ");
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

- (void)stopSoundMaster
{
    [seqSetViewController stopSoundMaster];
    [seqSetViewController resetSoundMaster];
}

- (void)startSoundMaster
{
    [seqSetViewController resetSoundMaster];
    [seqSetViewController startSoundMaster];
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
    [seqSetViewController resetSoundMaster];
    
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
    [seqSetViewController updateMasterVolume:newVolume];
}

- (void)initPlayLocation
{
    if(currentFret == -1){
        [self increasePlayLocation];
    }
}

- (void)increasePlayLocation
{
    currentFret++;
    r_beat++;
    
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
    
    float x = [frameGenerator getFullscreenWidth];
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
        DLog(@"RECORDING");
    }else{
        DLog(@"NOT RECORDING");
    }
    return isRecording;
}

- (void)stopAll
{
    [playControlViewController stopPlayRecordAndAnimate:NO showEndScreen:YES];
    
}

- (void)startAll
{
    [playControlViewController startStop:self];
}

- (void)userDidSelectShare
{
    [recordShareController openShareScreen];
}

- (void)showRecordOverlay
{
    [playControlViewController showRecordOverlay];
}

- (void)hideRecordOverlay
{
    [playControlViewController hideRecordOverlay];
}

#pragma mark - Seq Set Delegate

- (void)setMeasureAndUpdate:(NSMeasure *)measure checkNotPlaying:(BOOL)checkNotPlaying
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
    NSTrack * track = [seqSetViewController getCurrentTrack];
    [self setSelectedInstrument:track.m_instrument];
    
    // Also update the selected table cell
    //[seqSetViewController setSelectedCellToSelectedInstrument];
    
}

- (void)updateSelectedInstrument
{
    NSTrack * track = [seqSetViewController getCurrentTrack];
    [self setSelectedInstrument:track.m_instrument];
}

// Ensure current playband is reflected in the data if displayed (>=0)
// Only need to call when # measures changes
- (void)updatePlaybandForTrack:(NSTrack *)track
{
    if (currentFret >= 0){
        int realMeasure = [track.selectedPattern computeRealMeasureFromAbsolute:currentAbsoluteMeasure];
        [track playFret:currentFret inRealMeasure:realMeasure withSound:NO withAmplitude:playVolume];
        
        // update Instrument view if it's open
        if(activeMainView == instrumentViewController.view && track == [seqSetViewController getCurrentTrack]){
            [instrumentViewController setPlaybandForMeasure:realMeasure toPlayband:currentFret];
        }
    }
    
    DLog(@"updatePlaybandForInstrument");
}

- (void) numInstrumentsDidChange:(int)numInstruments
{
    if(numInstruments > 0){
        NSTrack * track = [seqSetViewController getCurrentTrack];
        [leftNavigator enableInstrumentViewWithIcon:track.m_instrument.m_iconName showCustom:track.m_instrument.m_custom];
    }else{
        [leftNavigator disableInstrumentView];
    }
}

- (NSMutableArray *)getTracks
{
    return [seqSetViewController getTracks];
}

- (void)refreshVolumeSliders
{
    [seqSetViewController reloadTableData];
    [instrumentViewController resetVolume];
}

- (void)enableInstrument:(int)instIndex
{
    if([[seqSetViewController getCurrentTrack] m_instrument].m_id == instIndex){
        [instrumentViewController enableKnobIfDisabled];
    }
    [seqSetViewController enableKnobIfDisabledForInstrument:instIndex];
}

- (void)disableInstrument:(int)instIndex
{
    if([[seqSetViewController getCurrentTrack] m_instrument].m_id == instIndex){
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
    
    if ([seqSetViewController getSelectedInstrumentIndex] < 0 || [seqSetViewController countTracks] == 0){
        DLog(@"No Instruments opened, or selected instrument index < 0");
        return;
    }
    
    DLog(@"Valid selection & valid data, so playing");
    
    SEQNote * note = [[SEQNote alloc] initWithString:str-1 andFret:fr-1];
    
    [self performSelectorOnMainThread:@selector(notePlayed:) withObject:note waitUntilDone:YES];
    
}

- (void)notePlayed:(SEQNote *)note
{
    DLog(@"gTarSeq received note played message string %i and fret %i",note.string,note.fret);
    
    // Pass note-played message onto the selected instrument
    [[seqSetViewController getCurrentTrack] notePlayedAtString:note.string andFret:note.fret];
    
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
    if(toConnect) DLog(@"gTar connected");
    else DLog(@"gTar disconnected");
    
    isConnected = toConnect;
    
    // display active measure on gTar
    if(isConnected){
        guitarView.measure = [seqSetViewController getCurrentTrack].selectedPattern.selectedMeasure;
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
    [email setSubject:@"Check Out the Song I Made"];
    
    // Body
    NSString * body = @"Check out the song I just made with Sequence!<br/><br/>Get it for free and make your own here: <a href='http://gtar.fm/seq'>http://gtar.fm/seq</a>";
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
    DLog(@"Launching SMS");
    
    MFMessageComposeViewController * message = [[MFMessageComposeViewController alloc] init];
    message.messageComposeDelegate = self;
    
    // Body
    NSString * body = @"Check out the song I just made with Sequence! Get it for free and make your own here: http://gtar.fm/seq";
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

- (void)userDidLaunchSoundCloudAuthWithFile:(NSString *)filename
{
    if([SCSoundCloud account] == nil){
        
        SCLoginViewControllerCompletionHandler handler = ^(NSError *error){
            if(SC_CANCELED(error)){
                DLog(@"Canceled");
            }else if(error){
                DLog(@"Error: %@", [error localizedDescription]);
            }else{
                DLog(@"Done!");
                [self shareFileToSoundCloud:filename];
            }
        };
        
        [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
            SCLoginViewController *loginViewController;
            
            loginViewController = [SCLoginViewController loginViewControllerWithPreparedURL:preparedURL completionHandler:handler];
            
            [self.navigationController presentViewController:loginViewController animated:YES completion:nil];
        }];
        
    }else{
        [self shareFileToSoundCloud:filename];
    }
}

-(void)shareFileToSoundCloud:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Sessions"];
    NSString * filepath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSURL * fileURL = [NSURL fileURLWithPath:filepath];
    
    SCShareViewController *shareViewController;
    SCSharingViewControllerCompletionHandler handler;
    
    handler = ^(NSDictionary *trackInfo, NSError *error){
        if(SC_CANCELED(error)){
            DLog(@"Canceled!");
        }else if(error){
            DLog(@"Error: %@", [error localizedDescription]);
        }else{
            DLog(@"Uploaded track: %@", trackInfo);
        }
    };
    
    shareViewController = [SCShareViewController shareViewControllerWithFileURL:fileURL completionHandler:handler];
    
    [shareViewController setTitle:[filename substringToIndex:([filename length]-4)]];
    [shareViewController setPrivate:YES];
    
    [self.navigationController presentViewController:shareViewController animated:YES completion:nil];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Logged Out
- (void)loggedOut:(BOOL)animate
{
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    float x = [frameGenerator getFullscreenWidth];
    float y = [frameGenerator getFullscreenHeight];
    
    [gatekeeperViewController.view setFrame:CGRectMake(0,0,x,y)];
    
    [self.view addSubview:gatekeeperViewController.view];
    
    [self presentGatekeeper:animate];
    
    // Be sure tempo slider and other interferences get disabled
    [playControlViewController.view setUserInteractionEnabled:NO];
    
    [gatekeeperViewController requestLogout];
    
    DLog(@"Logged Out");
    
    // Clear the cache
    [g_loggedInUser clear];
    
}


- (void)loggedIn:(BOOL)animate
{
    DLog(@"Logged In");
    
    double duration = animate ? 0.5 : 0.0;
    
    [UIView animateWithDuration:duration animations:^(void){
        [gatekeeperViewController.view setAlpha:0.0];
    }completion:^(BOOL finished){
        [gatekeeperViewController.view removeFromSuperview];
        [playControlViewController.view setUserInteractionEnabled:YES];
    }];
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
    FrameGenerator * frameGenerator = [[FrameGenerator alloc] init];
    
    float x = [frameGenerator getFullscreenWidth];
    float y = [frameGenerator getFullscreenHeight];
    
    DLog(@" *** Launch FTU Tutorial *** %f %f",x,y);
    
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
    
    // Hide login during tutorial
    [gatekeeperViewController.view setHidden:YES];
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

- (void)presentGatekeeper:(BOOL)animate
{
    double duration = (animate) ? 0.5 : 0.0;
 
    [gatekeeperViewController resetScreen];
    
    [gatekeeperViewController.view setAlpha:0.0];
    [gatekeeperViewController.view setHidden:NO];
    [self.view bringSubviewToFront:gatekeeperViewController.view];
    
    [UIView animateWithDuration:duration animations:^(void){
        [gatekeeperViewController.view setAlpha:1.0];
    }];
}

@end
