//
//  InstrumentView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "InstrumentTableViewCell.h"
#import "ScrollingSelector.h"


@protocol InstrumentDelegate <NSObject>

- (void) saveContext;
- (BOOL) checkIsPlaying;
- (void) resetPlayLocation;
- (void) forceStopAll;

- (void) turnOffGuitarEffects;
- (void) setMeasureAndUpdate:(Measure *)measure checkNotPlaying:(BOOL)checkNotPlaying;

- (void) updateInstruments:(NSMutableArray *)instrumentlist setSelected:(int)index;
- (void) enqueuePattern:(NSMutableDictionary *)pattern;

- (void) updateGuitarView;
@end


@interface InstrumentTableViewController : UITableViewController <ScrollingSelectorDelegate> {
    
    UITableView * instrumentTable;
    
    NSMutableArray * instruments;
    int selectedInstrumentIndex;
    
    NSMutableArray * masterInstrumentOptions;
    NSMutableArray * remainingInstrumentOptions;
    
    ScrollingSelector * instrumentSelector;
    CGRect onScreenSelectorFrame;
    CGRect offLeftSelectorFrame;
    
}
- (void)muteInstrument:(InstrumentTableViewCell *)sender isMute:(BOOL)isMute;
- (void)commitSelectingPatternAtIndex:(int)indexToSelect forInstrument:(Instrument *)inst;
- (void)deleteCell:(id)sender;

- (void)updateAllVisibleCells;
- (void)userDidSelectMeasure:(id)sender atIndex:(int)index;
- (void)userDidSelectPattern:(id)sender atIndex:(int)index;
- (void)userDidAddMeasures:(id)sender;
- (void)userDidRemoveMeasures:(id)sender;


@property (weak, nonatomic) id<InstrumentDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *instrumentTable;

@end