//
//  BatteryViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/23/12.
//  Copyright (c) 2012 Incident Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GtarControllerInternal.h>

@interface BatteryViewController : UIViewController<GtarControllerDelegate>

- (IBAction)testBatteryClicked:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel * chargingLabel;
@property (nonatomic, strong) IBOutlet UILabel * percentageLabel;

@end
