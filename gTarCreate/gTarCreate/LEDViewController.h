//
//  LEDViewController.h
//  gTarCreate
//
//  Created by Idan Beck on 5/14/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GtarControllerInternal.h"

@interface LEDViewController : UIViewController {
    unsigned char oldR;
    unsigned char oldG;
    unsigned char oldB;
}

@property (nonatomic, retain) IBOutlet UILabel *m_labelFretFollow;

@property (nonatomic, retain) IBOutlet UISegmentedControl *m_segmentedRed;
@property (nonatomic, retain) IBOutlet UISegmentedControl *m_segmentedGreen;
@property (nonatomic, retain) IBOutlet UISegmentedControl *m_segmentedBlue;

- (IBAction)OnSegmentChanged:(id)sender;
- (void) UpdateView;

@end
