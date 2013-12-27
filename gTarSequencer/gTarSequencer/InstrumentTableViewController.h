//
//  InstrumentView.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstrumentTableViewController : UITableViewController {
    
    UITableView * instrumentTable;
    
    NSMutableArray * masterInstrumentOptions;
    NSMutableArray * remainingInstrumentOptions;
    
}

@property (nonatomic, retain) IBOutlet UITableView *instrumentTable;

@end