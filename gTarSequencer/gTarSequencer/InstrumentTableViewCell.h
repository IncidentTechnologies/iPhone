//
//  InstrumentTableCell.h
//  gTarSequencer
//
//  Created by Kate Schnippering on 12/20/13.
//  Copyright (c) 2013 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"

@class InstrumentTableViewController;

@interface InstrumentTableViewCell : UITableViewCell
{
    
    BOOL deleteMode;

}

- (IBAction)userDidTapInstrumentIcon:(id)sender;

@property (weak, nonatomic) Instrument * instrument;
@property (retain, nonatomic) NSString * instrumentName;
@property (retain, nonatomic) UIImage * instrumentIcon;

@property (weak, nonatomic) InstrumentTableViewController * parent;

// cell elements
@property (weak, nonatomic) IBOutlet UIImageView * instrumentIconView;
@property (weak, nonatomic) IBOutlet UIButton * instrumentIconBorder;

@end
