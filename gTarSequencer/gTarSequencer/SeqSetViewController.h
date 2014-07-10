//
//  InstrumentView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "Instrument.h"
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
- (void) setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

- (void) enqueuePattern:(NSMutableDictionary *)pattern;
- (int) getQueuedPatternIndexForInstrument:(Instrument *)inst;
- (void) removeQueuedPatternForInstrumentAtIndex:(int)instIndex;

- (void) updateGuitarView;
- (void) updatePlaybandForInstrument:(Instrument *)inst;


- (void) numInstrumentsDidChange:(int)numInstruments;

- (void) viewSelectedInstrument;
- (void) updateSelectedInstrument;
@end


@interface SeqSetViewController : UITableViewController <ScrollingSelectorDelegate,CustomInstrumentSelectorDelegate,TutorialDelegate> {
    
    SoundMaster * soundMaster;
    
    //UITableView * instrumentTable;
    
    NSMutableArray * instruments;
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
    
}

- (void)startSoundMaster;
- (void)stopSoundMaster;
- (void)resetSoundMaster;
- (SoundMaster *)getSoundMaster;

- (void)turnEditingOn;
- (void)turnEditingOff;

- (void)turnContentDrawingOn;
- (void)turnContentDrawingOff;

- (void)commitSelectingPatternAtIndex:(int)indexToSelect forInstrument:(Instrument *)inst;
- (void)deleteCell:(id)sender withAnimation:(BOOL)animate;
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
- (void)dequeueAllPatternsForInstrument:(id)sender;

- (void)setInstrumentsFromData:(NSData *)instData;
- (NSMutableArray *)getInstruments;
- (long)countInstruments;
- (Instrument *)getCurrentInstrument;
- (Instrument *)getInstrumentAtIndex:(int)i;
- (BOOL)isValidInstrumentIndex:(int)inst;

- (void)saveContext:(NSString *)filepath force:(BOOL)forceSave;

- (void)disableKnobIfEnabledForInstrument:(int)instIndex;
- (void)enableKnobIfDisabledForInstrument:(int)instIndex;

@property (weak, nonatomic) id<SeqSetDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITableView *instrumentTable;

@property (retain, nonatomic) TutorialViewController * tutorialViewController;

@property (nonatomic) BOOL isFirstLaunch;


@end