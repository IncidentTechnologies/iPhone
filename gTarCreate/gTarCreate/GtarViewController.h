//
//  GtarViewController.h
//  gTarCreate
//
//  Created by Idan Beck on 5/13/14.
//  Copyright (c) 2014 Incident Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GtarControllerInternal.h"

@interface GtarViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GtarControllerDelegate> {
    NSArray *m_firmwares;
    UIView *m_disableView;
    
    NSArray *m_piezoFirmwares;
}

@property (nonatomic, retain) IBOutlet UIButton *m_buttonFWUpgrade;
@property (nonatomic, retain) IBOutlet UITableView *m_tableViewFirmwares;

@property (nonatomic, retain) IBOutlet UIButton *m_buttonPiezoFWUpgrade;
@property (nonatomic, retain) IBOutlet UITableView *m_tableViewPiezoFirmwares;

-(IBAction)OnFWUpgradeClick:(id)sender;
-(IBAction)OnPiezoFWUpgradeClick:(id)sender;

- (void)receivedFirmwareUpdateProgress:(unsigned char)percentage;
- (void)receivedFirmwareUpdateStatusSucceeded;
- (void)receivedFirmwareUpdateStatusFailed;

@end
