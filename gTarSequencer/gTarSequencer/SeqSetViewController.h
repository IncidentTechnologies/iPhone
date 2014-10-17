//
//  InstrumentView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "NSSequence.h"
#import "SeqSetViewCell.h"
#import "ScrollingSelector.h"
#import "CustomInstrumentSelector.h"

@protocol SeqSetDelegate <NSObject>

- (void) saveContext:(NSString *)filepath force:(BOOL)forceSave;
- (void) resetPlayLocation;

- (void) stopAll;
- (void) startAll;
- (BOOL) checkIsPlaying;
- (BOOL) checkIsRecording;

- (void) turnOffGuitarEffects;
- (void) setMeasureAndUpdate:(NSMeasure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

- (void) enqueuePattern:(NSMutableDictionary *)pattern;
- (int) getQueuedPatternIndexForTrack:(NSTrack *)track;
- (void) removeQueuedPatternForInstrumentAtIndex:(int)instIndex;

- (void) updateGuitarView;
- (void) updatePlaybandForTrack:(NSTrack *)track;

- (void) numInstrumentsDidChange:(int)numInstruments;

- (void) updateSelectedInstrument;
- (void) openInstrument:(int)instIndex;

- (void) setTempo:(int)tempo;
- (void) setVolume:(double)volume;


- (void)loadFromXmpId:(NSInteger)xmpId andType:(NSString *)type;
- (NSInteger)getActiveSongId;

- (BOOL)isLeftNavOpen;

@end

extern OphoMaster * g_ophoMaster;

@interface SeqSetViewController : UITableViewController <ScrollingSelectorDelegate,CustomInstrumentSelectorDelegate,TutorialDelegate>
{
    SoundMaster * soundMaster;
    
    NSSequence * sequence;
    long selectedInstrumentIndex;
    
    NSMutableArray * masterInstrumentOptions;
    NSMutableArray * remainingInstrumentOptions;
    NSMutableArray * customInstrumentOptions;
    
    ScrollingSelector * instrumentSelector;
    CGRect onScreenSelectorFrame;
    CGRect offLeftSelectorFrame;
    
    CustomInstrumentSelector * customSelector;
    CGRect onScreenCustomSelectorFrame;
    CGRect offLeftCustomSelectorFrame;
    
    NSString * sequencerInstrumentsPath;
    NSString * customInstrumentsPath;
    
    BOOL canEdit;
    BOOL allowContentDrawing;
    
    // State
    NSMutableDictionary * currentState;
    int activeSequenceXmpId;
    
    NSTimer * saveContextTimer;
}


@property (weak, nonatomic) id<SeqSetDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *instrumentTable;

@property (retain, nonatomic) TutorialViewController * tutorialViewController;

@property (nonatomic) BOOL isFirstLaunch;


- (void)startSoundMaster;
- (void)stopSoundMaster;
- (void)resetSoundMaster;
- (SoundMaster *)getSoundMaster;

- (void)turnEditingOn;
- (void)turnEditingOff;

- (void)turnContentDrawingOn;
- (void)turnContentDrawingOff;

- (void)commitSelectingPatternAtIndex:(int)indexToSelect forTrack:(NSTrack *)track;
- (void)deleteSeqSetViewCell:(UITableViewCell *)cell;
- (void)deleteAllCells;

- (void)reloadTableData;
- (void)updateAllVisibleCells;
- (void)userDidSelectMeasure:(id)sender atIndex:(int)index;
- (BOOL)userDidSelectPattern:(id)sender atIndex:(int)index;
- (void)userDidAddMeasures:(id)sender;
- (void)userDidRemoveMeasures:(id)sender;

- (void)setSelectedInstrumentIndex:(int)index;
- (long)getSelectedInstrumentIndex;
- (void)resetSelectedInstrumentIndex;
- (void)viewSelectedInstrument:(SeqSetViewCell *)sender;
- (void)setSelectedCellToSelectedInstrument;

- (void)notifyQueuedPatternsAtIndex:(int)index andResetCount:(BOOL)reset;
- (void)clearQueuedPatternButtonAtIndex:(int)index;
- (void)dequeueAllPatternsForTrack:(id)sender;

- (void)setInstrumentsFromData;

- (void)initSequenceWithFilename:(NSString *)filename;
- (void)initSequenceWithSequence:(NSSequence *)newsequence;
- (NSSequence *)getSequence;
- (NSMutableArray *)getTracks;

- (long)countTracks;
- (int)countMasterInstrumentOptions;
- (int)countSamples;

- (NSTrack *)getCurrentTrack;
- (NSTrack *)getTrackAtIndex:(int)index;

- (void)updateTrackTempo:(int)tempo;
- (void)updateMasterVolume:(double)volume;

- (BOOL)isValidInstrumentIndex:(int)inst;

- (NSString *)loadStateFromDisk;
- (void)saveContext:(NSString *)filepath force:(BOOL)forceSave;

- (void)disableKnobIfEnabledForInstrument:(int)instIndex;
- (void)enableKnobIfDisabledForInstrument:(int)instIndex;

- (BOOL)isLeftNavOpen;

@end