//
//  InstrumentView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import "AppData.h"
#import "Instrument.h"
#import "InstrumentTableViewCell.h"
#import "ScrollingSelector.h"
#import "CustomInstrumentSelector.h"


@protocol InstrumentDelegate <NSObject>

- (void) saveContext:(NSString *)filepath;
- (BOOL) checkIsPlaying;
- (void) resetPlayLocation;
- (void) forceStopAll;

- (void) turnOffGuitarEffects;
- (void) setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

- (void) enqueuePattern:(NSMutableDictionary *)pattern;

- (void) updateGuitarView;
- (void) updatePlaybandForInstrument:(Instrument *)inst;
@end


@interface InstrumentTableViewController : UITableViewController <ScrollingSelectorDelegate,CustomInstrumentSelectorDelegate> {
    
    UITableView * instrumentTable;
    
    NSMutableArray * instruments;
    long selectedInstrumentIndex;
    
    NSMutableArray * masterInstrumentOptions;
    NSMutableArray * remainingInstrumentOptions;
    
    ScrollingSelector * instrumentSelector;
    CGRect onScreenSelectorFrame;
    CGRect offLeftSelectorFrame;
    
    CustomInstrumentSelector * customSelector;
    CGRect onScreenCustomSelectorFrame;
    CGRect offLeftCustomSelectorFrame;
    
    NSString * sequencerInstrumentsPath;
    
}
- (void)muteInstrument:(InstrumentTableViewCell *)sender isMute:(BOOL)isMute;
- (void)commitSelectingPatternAtIndex:(int)indexToSelect forInstrument:(Instrument *)inst;
- (void)deleteCell:(id)sender;

- (void)updateAllVisibleCells;
- (void)userDidSelectMeasure:(id)sender atIndex:(int)index;
- (BOOL)userDidSelectPattern:(id)sender atIndex:(int)index;
- (void)userDidAddMeasures:(id)sender;
- (void)userDidRemoveMeasures:(id)sender;

- (void)setSelectedInstrumentIndex:(int)index;
- (long)getSelectedInstrumentIndex;
- (void)resetSelectedInstrumentIndex;

- (void)notifyQueuedPatternsAtIndex:(int)index andResetCount:(BOOL)reset;

- (void)setInstrumentsFromData:(NSData *)instData;
- (NSMutableArray *)getInstruments;
- (long)countInstruments;
- (Instrument *)getCurrentInstrument;
- (Instrument *)getInstrumentAtIndex:(int)i;

@property (weak, nonatomic) id<InstrumentDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *instrumentTable;

@end