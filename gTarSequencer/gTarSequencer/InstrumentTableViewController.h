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

- (void)deleteCell:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *instrumentTable;

@end