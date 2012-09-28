//
//  BatteryViewController.h
//  gTarFunctionalVerification
//
//  Created by Joel Greenia on 8/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GuitarController.h"

@interface BatteryViewController : UIViewController<GuitarControllerDelegate>

- (IBAction)testBatteryClicked:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel * chargingLabel;
@property (nonatomic, strong) IBOutlet UILabel * percentageLabel;

@end
